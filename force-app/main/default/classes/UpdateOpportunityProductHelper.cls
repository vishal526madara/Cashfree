public without sharing class UpdateOpportunityProductHelper {
  public static RestResponse updateOpportunityProducts(String oppJSON) {
    RestResponse tempResponse = new RestResponse();
    SavePoint sp = Database.setSavePoint();

    OpportunityProductWrapper opportunityProduct = (OpportunityProductWrapper) JSON.deserialize(
      oppJSON,
      OpportunityProductWrapper.class
    );

    RestResponse validationStatus = validateJSONBody(opportunityProduct);
    System.debug('Function Calledd:::::' + validationStatus);
    if (validationStatus.responseBody != null) {
      Database.rollback(sp);
      return validationStatus;
    } else {
      tempResponse = createOpportunityProduct(
        opportunityProduct,
        opportunityProduct.opportunityId
      );
      Map<String, Object> responseReturnMap = (Map<String, Object>) JSON.deserializeUntyped(
        tempResponse.responseBody.toString()
      );
      if (responseReturnMap.get('status') == 'error') {
        Database.rollback(sp);
      }
      return tempResponse;
    }
  }

  private static RestResponse validateJSONBody(
    OpportunityProductWrapper jsonRequest
  ) {
    RestResponse temResponse = new RestResponse();
    if (jsonRequest.opportunityId == null || jsonRequest.opportunityId == '') {
      System.debug('Opportunity If ::::' + jsonRequest.opportunityId);
      return errorResponse('Opportunity Id Does Not Exist');
    } else if (
      jsonRequest.opportunityProduct.productCode == null ||
      jsonRequest.opportunityProduct.productCode == ''
    ) {
      return errorResponse('Please Provide Product Code');
    } else if (jsonRequest.opportunityProduct.commercialItems.size() == 0) {
      return errorResponse('Please Provide Product Detail');
    }
    return validateProductList(jsonRequest);
  }

  private static RestResponse validateProductList(
    OpportunityProductWrapper jsonRequest
  ) {
    RestResponse tempResponse = new RestResponse();
    for (
      OpportunityProductWrapper.MerchantCommercialItem commercialItem : jsonRequest.opportunityProduct.commercialItems
    ) {
      if (
        commercialItem.commercialName == '' ||
        commercialItem.commercialName == null
      ) {
        return errorResponse('Commercial Not Found');
      }
      if (
        (commercialItem.methodCode == '' ||
        commercialItem.methodCode == null) &&
        (commercialItem.modeCode == '' ||
        commercialItem.modeCode == null)
      ) {
        return errorResponse('Please Provide Valid Mode');
      }
      //  if((commercialItem.modeCode != null || commercialItem.modeCode != '') &&
      //      (commercialItem.methodCode == null || commercialItem.methodCode == '')){
      //       return errorResponse('Please Provide Method Code');
      //      }
    }
    return tempResponse;
  }

  private static RestResponse deleteOpportunityProduct(String oppId) {
    RestResponse tempResponse = new RestResponse();
    List<Opportunity_Product__c> oppProductList = [
      SELECT Id
      FROM Opportunity_Product__c
      WHERE Opportunity__c = :oppId
    ];
    /***
     * if no opportuntiy product found
     */
    if (oppProductList.size() == 0) {
      return errorResponse('No Product Found');
    } else {
      Map<Id, Opportunity_Mode__c> opportunityModeMap = new Map<Id, Opportunity_Mode__c>(
        [
          SELECT Id
          FROM Opportunity_Mode__c
          WHERE Opportunity_Product__c = :oppProductList[0].Id
        ]
      );

      if (opportunityModeMap.size() == 0) {
        return errorResponse('No Product Found');
      } else {
        List<Id> deleteOpportuityModeList = new List<Id>();
        for (Id opportunityModeId : opportunityModeMap.keySet()) {
          deleteOpportuityModeList.add(opportunityModeId);
        }
        Database.DeleteResult saveResponse = Database.delete(
          oppProductList[0].Id,
          true
        );

        if (saveResponse.isSuccess()) {
          List<Database.DeleteResult> deleteSaveResponse = Database.delete(
            deleteOpportuityModeList,
            true
          );
        } else {
          return errorResponse('Failed To Update Record');
        }
      }
    }

    return tempResponse;
  }

  private static RestResponse errorResponse(String message) {
    RestResponse response = new RestResponse();

    Map<String, String> responseMap = new Map<String, String>();
    responseMap.put('status', 'error');
    responseMap.put('message', message);

    response.statusCode = 400;
    response.responseBody = Blob.valueOf(JSON.serialize(responseMap));

    return response;
  }

  private static RestResponse createOpportunityProduct(
    OpportunityProductWrapper oppProduct,
    String oppId
  ) {
    RestResponse tempResponse = new RestResponse();
    try {
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
      if (
        oppProduct.opportunityProduct.productCode == null ||
        oppProduct.opportunityProduct.productCode == ''
      ) {
        return errorResponse('Product Does Not Exist Or May Be Not Configured');
      }
      merchantProductCode = oppProduct.opportunityProduct.productCode;

      List<Product__c> merchantProduct = [
        SELECT Id, Name
        FROM Product__c
        WHERE Product_Code__c = :merchantProductCode
      ];

      if (merchantProduct.size() == 0) {
        return errorResponse('Product Not Found');
      }

      System.debug('Product List:::::' + merchantProduct);

      //crate set of modes and iterate over json product mode

      for (
        OpportunityProductWrapper.MerchantCommercialItem externalMode : oppProduct.opportunityProduct.commercialItems
      ) {
        if (externalMode.modeCode != null || externalMode.modeCode != '') {
          externalModeSet.add(externalMode.modeCode);
          externalMethodSet.add(externalMode.methodCode);
        }
      }

      System.debug('External Id Method Set:::' + externalMethodSet);

      mdoeList = [
        SELECT Id, Active__c, Mode_Code__c, Name
        FROM Modes__c
        WHERE
          Product__c = :merchantProduct[0].Id
          AND Mode_Code__c IN :externalModeSet
      ];
      System.debug('Mode List:::::' + mdoeList);

      if (mdoeList.size() == 0) {
        return errorResponse('Mode Not Found');
      }

      for (Modes__c mode : mdoeList) {
        modeIdSet.add(mode.Id);
        sfModeMap.put(mode.Mode_Code__c, mode);
      }

      System.debug('SF Mode Map:::' + sfModeMap);
      System.debug('Mode Id Set:::' + modeIdSet);
      methodTypeList = [
        SELECT Id, Method_Code__c, Mode__c, Mode__r.Mode_Code__c, Name
        FROM Method_Type__c
        WHERE Mode__c IN :modeIdSet AND Method_Code__c IN :externalMethodSet
      ];
      System.debug('Method List::::' + methodTypeList);

      for (Method_Type__c methodType : methodTypeList) {
        /**********************************************************************************************
         * upadetDate: 27 Jan,2023
         *********************************************************************************************/
        for (
          OpportunityProductWrapper.MerchantCommercialItem updateOpportunityProduct : oppProduct.opportunityProduct.commercialItems
        ) {
          if (
            updateOpportunityProduct.methodCode == methodType.Method_Code__c &&
            updateOpportunityProduct.modeCode == methodType.Mode__r.Mode_Code__c
          ) {
            if (!sfModeMethodMap.containsKey(methodType.Method_Code__c)) {
              List<Method_Type__c> tempMethodTypeList = new List<Method_Type__c>();
              tempMethodTypeList.add(methodType);
              sfModeMethodMap.put(
                methodType.Method_Code__c,
                tempMethodTypeList
              );
            } else {
              sfModeMethodMap.get(methodType.Method_Code__c).add(methodType);
            }
            methodIdSet.add(methodType.Id);
            break;
          }
        }

        /***********************************************************************************************/
      }

      System.debug('Method Id Set:::' + methodIdSet);
      System.debug('Map data:::::' + sfModeMethodMap);

      commercialList = [
        SELECT
          Id,
          Commercials__c,
          Name,
          Method_Type__c,
          Mode__c,
          Bank_Validation__c,
          Commercial_Price__c
        FROM Commercial__c
        WHERE Method_Type__c IN :methodIdSet
      ];

      System.debug('Commercial List:::' + commercialList);

      twoLevelCommercialProduct = [
        SELECT
          Id,
          Commercials__c,
          Name,
          Method_Type__c,
          Mode__c,
          Bank_Validation__c,
          Commercial_Price__c
        FROM Commercial__c
        WHERE Mode__c IN :modeIdSet
      ];

      for (Commercial__c commercial : twoLevelCommercialProduct) {
        if (!sfModeCommercialMap.containsKey(commercial.Mode__c)) {
          List<Commercial__c> tempList = new List<Commercial__c>();
          tempList.add(commercial);
          sfModeCommercialMap.put(commercial.Mode__c, tempList);
        } else {
          sfModeCommercialMap.get(commercial.Mode__c).add(commercial);
        }
      }

      System.debug('Two Level Map Data:::::' + sfModeCommercialMap);

      for (Commercial__c commercial : commercialList) {
        if (!sfMethodCommercialMap.containsKey(commercial.Method_Type__c)) {
          List<Commercial__c> tempList = new List<Commercial__c>();
          tempList.add(commercial);
          sfMethodCommercialMap.put(commercial.Method_Type__c, tempList);
        } else {
          sfMethodCommercialMap.get(commercial.Method_Type__c).add(commercial);
        }
      }

      Opportunity_Product__c merchantOppProduct = new Opportunity_Product__c();
      merchantOppProduct.Opportunity__c = Id.valueOf(oppId);
      merchantOppProduct.Product__c = merchantProduct[0].Id;
      merchantOppProduct.Name = merchantProduct[0].Name;

      /*********************************************************************************/
      tempResponse = deleteOpportunityProduct(oppId);
      if (tempResponse.responseBody != null) {
        return tempResponse;
      } else {
        /**********************************************************************************/

        Database.SaveResult oppProductResult = Database.insert(
          merchantOppProduct,
          true
        );

        if (oppProductResult.isSuccess()) {
          System.debug(
            'Pass 1::::::' +
            oppProduct.opportunityProduct.commercialItems.size()
          );

          for (
            OpportunityProductWrapper.MerchantCommercialItem newOpportunityCommercial : oppProduct.opportunityProduct.commercialItems
          ) {
            System.debug(
              'sfModeCommercialMap::::::' + sfModeCommercialMap.size()
            );
            System.debug(
              'newOpportunityCommercial.modeCode::::' +
              newOpportunityCommercial.modeCode
            );
            System.debug(
              'newOpportunityCommercial.methodCode::::::' +
              newOpportunityCommercial.methodCode
            );
            System.debug('External Body::::::' + newOpportunityCommercial);
            System.debug(
              'Commercial Mode code:::' + newOpportunityCommercial.modeCode
            );
            System.debug(
              'Commercial Mode code:::' + newOpportunityCommercial.methodCode
            );
            if (newOpportunityCommercial.methodCode == '') {
              System.debug('Condition Satisfied:::');
            }
            if (
              sfModeMethodMap.size() != 0 &&
              newOpportunityCommercial.modeCode != null &&
              newOpportunityCommercial.methodCode != null
            ) {
              if (
                sfModeMethodMap.containsKey(newOpportunityCommercial.methodCode)
              ) {
                for (
                  Method_Type__c methodType : sfModeMethodMap.get(
                    newOpportunityCommercial.methodCode
                  )
                ) {
                  System.debug('Method Code::::::' + methodType.Method_Code__c);
                  System.debug(
                    'Method Code::::::' + newOpportunityCommercial.methodCode
                  );
                  for (
                    Commercial__c oppCommercialItem : sfMethodCommercialMap.get(
                      methodType.Id
                    )
                  ) {
                    if (
                      oppCommercialItem.Name ==
                      newOpportunityCommercial.commercialName
                    ) {
                      Opportunity_Mode__c newOpportunityMode = new Opportunity_Mode__c();
                      newOpportunityMode.Opportunity_Product__c = oppProductResult.getId();
                      newOpportunityMode.Name = newOpportunityCommercial.commercialName;
                      newOpportunityMode.Actual_Price_Percent__c = newOpportunityCommercial.actualPrice;
                      newOpportunityMode.Actual_Price__c = newOpportunityCommercial.actualPricePercent;
                      newOpportunityMode.Add_On_Price__c = newOpportunityCommercial.addPrice;
                      newOpportunityMode.Add_On__c = newOpportunityCommercial.addPercent;
                      newOpportunityMode.Commercial__c = oppCommercialItem.Id;
                      newOpportunityMode.Method_Type__c = oppCommercialItem.Method_Type__c;
                      opportunityModeList.add(newOpportunityMode);
                      break;
                    }
                  }
                }
              } else {
                return errorResponse('Malformed Product Found');
              }
            } else if (
              sfModeCommercialMap.size() != 0 &&
              newOpportunityCommercial.modeCode != null &&
              newOpportunityCommercial.methodCode == null
            ) {
              if (sfModeMap.containsKey(newOpportunityCommercial.modeCode)) {
                for (
                  Commercial__c commercial : sfModeCommercialMap.get(
                    sfModeMap.get(newOpportunityCommercial.modeCode).Id
                  )
                ) {
                  if (
                    commercial.Name == newOpportunityCommercial.commercialName
                  ) {
                    System.debug('Else If Condition Passed:::');
                    Opportunity_Mode__c newOpportunityMode = new Opportunity_Mode__c();
                    newOpportunityMode.Opportunity_Product__c = oppProductResult.getId();
                    newOpportunityMode.Name = newOpportunityCommercial.commercialName;
                    newOpportunityMode.Actual_Price_Percent__c = newOpportunityCommercial.actualPrice;
                    newOpportunityMode.Actual_Price__c = newOpportunityCommercial.actualPricePercent;
                    newOpportunityMode.Add_On_Price__c = newOpportunityCommercial.addPrice;
                    newOpportunityMode.Add_On__c = newOpportunityCommercial.addPercent;
                    newOpportunityMode.Commercial__c = commercial.Id;
                    newOpportunityMode.Mode__c = commercial.Mode__c;
                    opportunityModeList.add(newOpportunityMode);
                    break;
                  }
                }
              } else {
                return errorResponse('Malform Opportunity Product');
              }
            }
          }
          System.debug('Account Id::::::' + opportunityModeList);

          List<Database.SaveResult> opportunityModeResult = Database.insert(
            opportunityModeList,
            true
          );
          System.debug('Mode List:::::' + opportunityModeResult[0].getId());
          for (Database.SaveResult tempSaveResult : opportunityModeResult) {
            if (!tempSaveResult.isSuccess()) {
              return errorResponse('Failed To Update Record');
            }
          }

          return tempResponse = successResponse(
            'Opportunity Record Updated Successfully',
            oppId
          );
        }
      }
      return tempResponse;
    } catch (Exception e) {
      System.debug('Error Line Number::::' + e.getLineNumber());
      return errorResponse(e.getMessage());
    }
  }

  private static RestResponse successResponse(String message, String oppId) {
    RestResponse successResponse = new RestResponse();

    Map<String, String> responseMap = new Map<String, String>();
    responseMap.put('opportunityId', oppId);
    responseMap.put('status', 'success');
    responseMap.put('message', message);
    successResponse.statusCode = 200;
    successResponse.responseBody = Blob.valueOf(JSON.serialize(responseMap));

    return successResponse;
  }
}
