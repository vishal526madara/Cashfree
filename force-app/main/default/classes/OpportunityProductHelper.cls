/******************************
 * @description: class functionality is to create opportunity and oppotyunity product
 *               class is related to web service class
 * @author: Vishal Hembrom
 * @createdDate: 06 Jan,2023
 *******************************/
public  without sharing class OpportunityProductHelper {

  

    public static RestResponse createOpportunityProduct(String oppJSON){
      try{
       System.debug('Passs::::');
        Savepoint sp = Database.setSavePoint();
        RestResponse response = new RestResponse();
        OpportunityProductWrapper oppProduct = (OpportunityProductWrapper)JSON.deserialize(oppJSON,OpportunityProductWrapper.class);
        String oppId = createOpportunity(oppProduct);
        System.debug('oppProduct:::::'+ oppProduct);
        System.debug('Opportunity:::::'+ oppId);
        if(oppId.equals('MID Does Not Exist')){
            Database.rollback(sp);
            return  errorResponse('MID Does Not Exist');
        }
        else if(oppId.equals('Product Does Not Exist Or May Be Not Configured')){
            Database.rollback(sp);
            return errorResponse('Product Does Not Exist');

        }else if(oppId.equals('Product Not Found')){
          Database.rollback(sp);
            return errorResponse('Product Not Found');
        }else if(oppId.equals('Mode Not Found')){
          Database.rollback(sp);
          return errorResponse('Mode Not Found');

        } else if((oppId).startsWith(Opportunity.sObjectType.getDescribe().getKeyPrefix())){
          //Database.rollback(sp);
          return successResponse('Successfully Created Opportunity', oppId);
        } 
        return response;
      }catch(Exception e){
        System.debug('Error Message::::'+ e.getLineNumber());
        return errorResponse(e.getMessage());
      }
    }

    private static RestResponse successResponse(String message, String oppId){
        RestResponse successResponse = new RestResponse();

        Map<String, String> responseMap = new Map<String, String>();
        responseMap.put('opportunityId', oppId);
        responseMap.put('status','success');
        responseMap.put('message',message);
        successResponse.statusCode = 200;
        successResponse.responseBody = Blob.valueOf(JSON.serialize(responseMap));

        return successResponse;
        
    }

    private static String createOpportunity(OpportunityProductWrapper opp){
      String opportunityId = '';
         List<Account> midAccountList = new List<Account>();
         List<Banking__c> bankList = new List<Banking__c>();

         

        if(opp.merchantId != null || opp.merchantId != ''){
         midAccountList = [Select Id, MID__c From Account Where MID__c =: opp.merchantId];
        }

        if(opp.bankName != null || opp.bankName != ''){
            bankList = [Select  Id,RM_Name__c  From Banking__c Where Name =: opp.bankName LIMIT 1];
        }


        /**
         * 
         * if Mid not exist on salesforce system
         */
        if(midAccountList.size() == 0){
            return 'MID Does Not Exist';
        }

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.AccountId = midAccountList.size() != 0 ? midAccountList[0].Id : null;
        newOpportunity.Name = opp.opportunityName;
        //type
        newOpportunity.CloseDate = opp.closeDate;
        newOpportunity.StageName = opp.stage;
        newOpportunity.Winning_Probability__c = opp.winningProbability;
        newOpportunity.Amount = opp.expectedGMV;
        newOpportunity.Probability = opp.probability;
        newOpportunity.Bank_Name__c = bankList.size() != 0 ? bankList[0].Id : null;
        newOpportunity.Expected_TXN_Count__c = opp.expectedTxnCount;
        newOpportunity.Manager_Email__c = opp.rManagerEmail;
        newOpportunity.Description = opp.description==null||opp.description==''?null:opp.description;  // to update the description this one is added  by Dinesh kumar on 31/01/2023.
		
        Database.SaveResult oppSaveResult = Database.insert(newOpportunity, true);
		System.debug('newOpportunity:::'+newOpportunity);
        if(oppSaveResult.isSuccess() ){
          opportunityId = oppSaveResult.getId();
          if( !String.isBlank(String.valueOf(opp.opportunityProduct))){
            return createOpportunityProduct(opp, oppSaveResult.getId());
          }
        }
        return opportunityId;


    }

    private static RestResponse errorResponse(String message){
        RestResponse response = new RestResponse();

        Map<String, String> responseMap = new Map<String, String>();
        responseMap.put('status','error');
        responseMap.put('message',message);

        response.statusCode = 400;
        response.responseBody = Blob.valueOf(JSON.serialize(responseMap));

        return response;
    }

    private static String createOpportunityProduct(OpportunityProductWrapper oppProduct, String oppId){
        String result = '';
        String merchantProductCode = '';
        List<Product__c> opportunityProduct = new List<Product__c>();
        List<Modes__c> mdoeList = new List<Modes__c>();
        List<Method_Type__c> methodTypeList = new List<Method_Type__c>();
        List<Commercial__c> commercialList = new List<Commercial__c>();

        List<Opportunity_Mode__c> opportunityModeList = new List<Opportunity_Mode__c>();


        Set<Id> modeIdSet = new Set<Id>();
        Set<Id> methodIdSet = new Set<Id>();

        Set<String> externalModeSet = new Set<String>();
        Set<String> externalMethodSet = new Set<String>();


       

        //key = 'mode code' && value = mode record
        Map<String, Modes__c> sfModeMap = new Map<String, Modes__c>();

        Map<String, List<Method_Type__c>> sfModeMethodMap = new Map<String, List<Method_Type__c>>();

       

        Map<Id, List<Commercial__c>> sfMethodCommercialMap = new Map<Id, List<Commercial__c>>();

        //for two level Products
        List<Commercial__c> twoLevelCommercialProduct = new List<Commercial__c>();
        Map<String, List<Commercial__c>> sfModeCommercialMap = new Map<String, List<Commercial__c>>();
        
      
    

      //throw exception when mid is not mention in jsonbody
       if(oppProduct.opportunityProduct.productCode == null || oppProduct.opportunityProduct.productCode == ''){
          return 'Product Does Not Exist Or May Be Not Configured';
       }
       merchantProductCode = oppProduct.opportunityProduct.productCode;

       List<Product__c> merchantProduct = [Select Id,Name from Product__c Where Product_Code__c =: merchantProductCode];
       
       if(merchantProduct.size() == 0){
        return 'Product Not Found';
       }

       System.debug('Product List:::::'+ merchantProduct);

       //crate set of modes and iterate over json product mode

       for(OpportunityProductWrapper.MerchantCommercialItem  externalMode : oppProduct.opportunityProduct.commercialItems){
            if(externalMode.modeCode != null || externalMode.modeCode != ''){
                externalModeSet.add(externalMode.modeCode);
                externalMethodSet.add(externalMode.methodCode);
            }
       }

       mdoeList = [Select Id, Active__c, Mode_Code__c, Name From Modes__c 
                   Where Product__c =: merchantProduct[0].Id AND Mode_Code__c IN: externalModeSet];
       System.debug('Mode List:::::'+ mdoeList);

      if(mdoeList.size() == 0){
        return 'Mode Not Found';
      }

      for(Modes__c mode : mdoeList){
        modeIdSet.add(mode.Id);
        sfModeMap.put(mode.Mode_Code__c, mode);
      }

      System.debug('SF Mode Map:::'+ sfModeMap);

      methodTypeList = [Select Id, Method_Code__c, Mode__c, Name, Mode__r.Mode_Code__c
                        From Method_Type__c 
                        Where Mode__c IN: modeIdSet AND Method_Code__c IN: externalMethodSet];
     System.debug('Method List::::'+ methodTypeList);
    
      //  if(methodTypeList.size() == 0){
      //   return 'Method Not Found';
      //  }

       for(Method_Type__c methodType : methodTypeList){
          for(OpportunityProductWrapper.MerchantCommercialItem updateOpportunityProduct :  oppProduct.opportunityProduct.commercialItems){
            if(updateOpportunityProduct.methodCode == methodType.Method_Code__c && updateOpportunityProduct.modeCode == methodType.Mode__r.Mode_Code__c){
              if(!sfModeMethodMap.containsKey(methodType.Method_Code__c)){
                  List<Method_Type__c> tempMethodTypeList = new List<Method_Type__c>();
                  tempMethodTypeList.add(methodType);
                  sfModeMethodMap.put(methodType.Method_Code__c,tempMethodTypeList);
              }else{
                sfModeMethodMap.get(methodType.Method_Code__c).add(methodType);
              }
              methodIdSet.add(methodType.Id);
              break;
            }
          }
       }

       System.debug('Map data:::::'+ sfModeMethodMap);

       commercialList = [Select Id, Commercials__c, Name, Method_Type__c, Mode__c,
                         Bank_Validation__c, Commercial_Price__c  
                         From Commercial__c 
                         Where Method_Type__c IN: methodIdSet];


      twoLevelCommercialProduct = [Select Id, Commercials__c, Name, Method_Type__c, Mode__c, 
                                    Bank_Validation__c, Commercial_Price__c  
                                    From Commercial__c 
                                    Where Mode__c IN: modeIdSet];

      System.debug('Two Level Commercial Product::::'+ twoLevelCommercialProduct);

      for(Commercial__c commercial : twoLevelCommercialProduct){
        if(!sfModeCommercialMap.containsKey(commercial.Mode__c)){
           List<Commercial__c> tempList = new List<Commercial__c>();
           tempList.add(commercial);
           sfModeCommercialMap.put(commercial.Mode__c,tempList);
        }else{
          sfModeCommercialMap.get(commercial.Mode__c).add(commercial);
        }
      }

      System.debug('Two Level Map Data:::::'+ sfModeCommercialMap);

      for(Commercial__c commercial : commercialList){
          if(!sfMethodCommercialMap.containsKey(commercial.Method_Type__c)){
            List<Commercial__c> tempList = new List<Commercial__c>();
            tempList.add(commercial);
            sfMethodCommercialMap.put(commercial.Method_Type__c, tempList);
          }else{
            sfMethodCommercialMap.get(commercial.Method_Type__c).add(commercial);
          } 
      }

    
        Opportunity_Product__c merchantOppProduct = new Opportunity_Product__c();
        merchantOppProduct.Opportunity__c = Id.valueOf(oppId);
        merchantOppProduct.Product__c = merchantProduct[0].Id;
        merchantOppProduct.Name = merchantProduct[0].Name;

        Database.SaveResult oppProductResult = Database.insert(merchantOppProduct, true);

        if(oppProductResult.isSuccess()){
            System.debug('Pass 1::::::'+oppProduct.opportunityProduct.commercialItems.size());

            for(OpportunityProductWrapper.MerchantCommercialItem newOpportunityCommercial : oppProduct.opportunityProduct.commercialItems){
              System.debug('sfModeCommercialMap::::::'+ sfModeCommercialMap.size());
              System.debug('newOpportunityCommercial.modeCode::::'+ newOpportunityCommercial.modeCode);
              System.debug('newOpportunityCommercial.methodCode::::::'+ newOpportunityCommercial.methodCode);
              System.debug('External Body::::::'+ newOpportunityCommercial);
              System.debug('Commercial Mode code:::'+ newOpportunityCommercial.modeCode);
              System.debug('Commercial Mode code:::'+ newOpportunityCommercial.methodCode);
              if(newOpportunityCommercial.methodCode == ''){
                System.debug('Condition Satisfied:::');
              }
              if(sfModeMethodMap.size() != 0 && newOpportunityCommercial.modeCode != null && newOpportunityCommercial.methodCode != null){
                for(Method_Type__c methodType : sfModeMethodMap.get(newOpportunityCommercial.methodCode)){
                    System.debug('Method Code::::::'+ methodType.Method_Code__c);
                    System.debug('Method Code::::::'+ newOpportunityCommercial.methodCode);
                            for(Commercial__c oppCommercialItem : sfMethodCommercialMap.get(methodType.Id)){
                                if(oppCommercialItem.Name == newOpportunityCommercial.commercialName){
                                    Opportunity_Mode__c newOpportunityMode = new Opportunity_Mode__c();
                                    newOpportunityMode.Opportunity_Product__c = oppProductResult.getId();
                                    newOpportunityMode.Name = newOpportunityCommercial.commercialName;
                                    newOpportunityMode.Actual_Price_Percent__c = newOpportunityCommercial.actualPricePercent ;
                                    newOpportunityMode.Actual_Price__c = newOpportunityCommercial.actualPrice;
                                    newOpportunityMode.Add_On_Price__c = newOpportunityCommercial.addPrice;
                                    newOpportunityMode.Add_On__c = newOpportunityCommercial.addPercent;
                                    newOpportunityMode.Commercial__c = oppCommercialItem.Id;
                                    newOpportunityMode.Method_Type__c = oppCommercialItem.Method_Type__c;
                                    opportunityModeList.add(newOpportunityMode);
                                    break;
                                }
                            }
                        
                }
               
              }else if(sfModeCommercialMap.size() != 0 && newOpportunityCommercial.modeCode != null && newOpportunityCommercial.methodCode == null){
                  
                    for(Commercial__c commercial : sfModeCommercialMap.get( sfModeMap.get(newOpportunityCommercial.modeCode).Id)){
                      if(commercial.Name == newOpportunityCommercial.commercialName){
                        System.debug('Else If Condition Passed:::');
                        Opportunity_Mode__c newOpportunityMode = new Opportunity_Mode__c();
                        newOpportunityMode.Opportunity_Product__c = oppProductResult.getId();
                        newOpportunityMode.Name = newOpportunityCommercial.commercialName;
                        newOpportunityMode.Actual_Price_Percent__c = newOpportunityCommercial.actualPricePercent ;
                        newOpportunityMode.Actual_Price__c = newOpportunityCommercial.actualPrice;
                        newOpportunityMode.Add_On_Price__c = newOpportunityCommercial.addPrice;
                        newOpportunityMode.Add_On__c = newOpportunityCommercial.addPercent;
                        newOpportunityMode.Commercial__c = commercial.Id;
                        newOpportunityMode.Mode__c = commercial.Mode__c;
                        opportunityModeList.add(newOpportunityMode);
                        break;
                      }
                    }
              }
            }
            System.debug('Account Id::::::'+ opportunityModeList);

            List<Database.SaveResult> opportunityModeResult = Database.insert(opportunityModeList, true);
            System.debug('Mode List:::::'+ opportunityModeResult[0].getId());
            result = oppId;
        }
        return result;
    }

   
}