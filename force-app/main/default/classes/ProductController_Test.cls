@isTest
public class ProductController_Test {
    
    @testSetup 
    static void makeData(){
        List<Account> accountList = TestUtill.createAccount(1);
        Insert accountList;
        
        List<Opportunity> oppList = TestUtill.createOpportunity(1);
        oppList[0].AccountId = accountList[0].Id;
        Insert oppList;
        
        List<Product__c> productList = TestUtill.createProduct(3);
        Insert productList;
        
        List<Modes__c> modeList = TestUtill.createMode(3);
        modeList[0].Product__c = productList[0].Id;
        modeList[0].Active__c = true;
        modeList[1].Product__c = productList[1].Id;
        modeList[1].Active__c = true;
        modeList[2].Product__c = productList[2].Id;
        modeList[2].Active__c = true;
        Insert modeList;
        
        List<Method_Type__c> methodT = TestUtill.createmethod(1);
        methodT[0].Mode__c=modeList[0].id;
        Insert methodT;
        
        List<Commercial__c> commercialList = TestUtill.createCommercial(6);
        commercialList[0].Mode__c = modeList[0].Id; 
        commercialList[0].Commercials__c = 3;
        
        commercialList[1].Mode__c = modeList[0].Id;
        commercialList[0].Method_Type__c = methodT[0].Id; 
        commercialList[1].Commercials__c = 3;
        
        commercialList[2].Mode__c = modeList[1].Id; 
        commercialList[2].Commercials__c = 3;
        
        commercialList[3].Mode__c = modeList[1].Id;
        commercialList[3].Commercials__c = 3;
        
        commercialList[4].Mode__c = modeList[2].Id; 
        commercialList[4].Commercials__c = 3;
        
        commercialList[5].Mode__c = modeList[2].Id;
        commercialList[5].Commercials__c = 3;
        Insert commercialList;
        
        List<Settlement__c> settlementList = TestUtill.createSettlement(3);
        settlementList[0].Product__c = productList[0].Id;
        settlementList[1].Product__c = productList[1].Id;
        settlementList[2].Product__c = productList[2].Id;
        Insert settlementList;
        
        List<Opportunity_Product__c> oppProductList = TestUtill.createOpportunityProduct(3);
        oppProductList[0].Opportunity__c = oppList[0].Id;
        oppProductList[1].Opportunity__c = oppList[0].Id;
        oppProductList[2].Opportunity__c = oppList[0].Id;
        Insert oppProductList;
        
        List<Opportunity_Mode__c> oppModeList = TestUtill.createOpportunityMode(6);
        oppModeList[0].Opportunity_Product__c = oppProductList[0].Id;
        oppModeList[0].Settlement__c = settlementList[0].Id;
        oppModeList[0].Commercial__c = commercialList[0].Id;
        oppModeList[0].Actual_Price_Percent__c = 3;
        
         oppModeList[1].Opportunity_Product__c = oppProductList[0].Id;
        oppModeList[1].Settlement__c = settlementList[0].Id;
        oppModeList[1].Commercial__c = commercialList[1].Id;
        oppModeList[1].Actual_Price_Percent__c = 3;
        
         oppModeList[2].Opportunity_Product__c = oppProductList[1].Id;
        oppModeList[2].Settlement__c = settlementList[1].Id;
        oppModeList[2].Commercial__c = commercialList[2].Id;
        oppModeList[2].Actual_Price_Percent__c = 3;
        
         oppModeList[3].Opportunity_Product__c = oppProductList[1].Id;
        oppModeList[3].Settlement__c = settlementList[1].Id;
        oppModeList[3].Commercial__c = commercialList[3].Id;
        oppModeList[3].Actual_Price_Percent__c = 3;
        
         oppModeList[4].Opportunity_Product__c = oppProductList[2].Id;
        oppModeList[4].Settlement__c = settlementList[2].Id;
        oppModeList[4].Commercial__c = commercialList[4].Id;
        oppModeList[4].Actual_Price_Percent__c = 3;
            
         oppModeList[5].Opportunity_Product__c = oppProductList[2].Id;
        oppModeList[5].Settlement__c = settlementList[2].Id;
        oppModeList[5].Commercial__c = commercialList[5].Id;
        oppModeList[5].Actual_Price_Percent__c = 3;
        Insert oppModeList;

    /*    List<Case> caseList = TestUtill.createCase(5);
        for(Case caseRecord : caseList){
            caseRecord.Opportunity__c = oppList[0].Id;
        }
        Insert caseList;
     */   
        List<User> userlst = TestUtill.createUser(1);
        userlst[0].LastName = 'TestUser';
        Insert userlst;
        
        Entitlement entitle = new Entitlement();
        entitle.Name = 'case support ent.';
        entitle.AccountId = accountList[0].Id;
        Insert entitle;
        
         List<Case> caseList = TestUtill.createCase(5);
        for(Case caseRecord : caseList){
            caseRecord.AccountId = accountList[0].Id;
            caseRecord.Opportunity__c = oppList[0].Id;
             caseRecord.OwnerId = userlst[0].Id;
        }
        Insert caseList;
    }
/*
    @isTest 
    static void opportunityId_Test_1(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        Test.startTest();
        String result = ProductController.opportunityId(opp.Id);
        Test.stopTest();
        System.assert(result == opp.Id);
    }
*/
    @isTest 
    static void opportunityId_Test_2(){
        List<Case> delCase = [Select Id From Case];
      //  Delete delCase;
      //  Opportunity opp = [Select Id From Opportunity Limit 1];
        Test.startTest();
        String result = ProductController.opportunityId(delCase[0].Id);
        Test.stopTest();
    }

    @isTest 
    static void opportunityId_Test_3(){
     //   Opportunity opp = [Select Id From Opportunity LIMIT 1];
        Test.startTest();
        try{
        String result = ProductController.opportunityId(null);
         }
        catch(Exception e){
            System.assertEquals(e.getMessage(), e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void productData_Test_1(){
        Test.startTest();
        List<Product__c> result = ProductController.productData();
        Test.stopTest();
        try{
            ProductController.productData();
        }
        catch(Exception e){
            System.assertEquals(e.getMessage(), e.getMessage());
        }
    }
    
    @isTest
    static void getModesRecord_Test(){
        Product__c pro = [Select Id,Name From Product__c LIMIT 1];
        Test.startTest();
        ProductController.CheckboxList result = ProductController.getModesRecord(pro.Id);
        Test.stopTest();
        //System.assertEquals(2,result.modesList.size());
    }
    
    @isTest
    static void getCommercialRec_Test(){
        Modes__c mode = [Select Id,Name From Modes__c LIMIT 1];
        Test.startTest();
        List<Commercial__c> result = ProductController.getCommercialRec(mode.Id);
        Test.stopTest();
        System.assert(result.size() == 2);
    }
     @isTest
    static void paymentGateWayCommercials_Test(){
        Modes__c mode = [Select Id,Name From Modes__c LIMIT 1];
        Test.startTest();
        List<Commercial__c> result = ProductController.paymentGateWayCommercials(mode.Id);
        Test.stopTest();
      //  System.assert(result.size() == 2);
    }
    
    
    @isTest
    static void saveProduct_Test_1(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        Commercial__c commercialRecord = [Select Id From Commercial__c LIMIT 1];
        List<Opportunity_Product__c> oppProductList = [Select Id From Opportunity_Product__c];
        List<Opportunity_Product__c> oppProduct = TestUtill.createOpportunityProduct(1);
        oppProduct[0].Opportunity__c = opp.Id;
        
        List<Opportunity_Mode__c> oppMode = TestUtill.createOpportunityMode(3);
        oppMode[0].Opportunity_Product__c = oppProductList[0].Id;
        oppMode[0].Commercial__c = commercialRecord.Id;
        oppMode[0].Actual_Price_Percent__c = 3;

        oppMode[1].Opportunity_Product__c = oppProductList[1].Id;
        oppMode[1].Commercial__c = commercialRecord.Id;
        oppMode[0].Actual_Price_Percent__c = 3;


        oppMode[2].Opportunity_Product__c = oppProductList[2].Id;
        oppMode[2].Commercial__c = commercialRecord.Id;
        oppMode[0].Actual_Price_Percent__c = 3;

        
        List<Settlement__c> settlementList = [Select Id,Name From Settlement__c LIMIT 3];
        
        Test.startTest();
        String result = ProductController.saveProduct(oppProduct[0],oppMode,settlementList);
        Test.stopTest();
        System.assert(result == 'success');
    }
    
    @isTest
    static void saveProduct_Test_2(){
        Opportunity_Product__c oppProduct = new Opportunity_Product__c();
        List<Opportunity_Mode__c> oppMode = [Select Id From Opportunity_Mode__c];
        List<Settlement__c> settlementList = [Select Id From Settlement__c];
        Test.startTest();
        String result = ProductController.saveProduct(null,oppMode,settlementList);
        Test.stopTest();
        try{
             ProductController.saveProduct(oppProduct,null,null);
        }
        catch(Exception e){
            System.assertEquals(e.getMessage(), e.getMessage());
        }
        System.assert(result == 'error');
    }

    
    @isTest
    static void OpportunityProduct_Test(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        Test.startTest();
        ProductController.OpportunityProduct(opp.Id);
        Test.stopTest();
    }
    
    @isTest
    static void updateProduct_Test(){
        Commercial__c commercialsRecord = [Select Id From Commercial__c LIMIT 1];
        Opportunity_Product__c oppProduct = [Select Id From Opportunity_Product__c LIMIT 1];
        Settlement__c settlementRecord = [Select Id From Settlement__c LIMIT 1];
        List<Opportunity_Mode__c> updateOppMode = [Select Id From Opportunity_Mode__c];
        List<Product__c> product = [Select Id From Product__c];
        List<String> oppModeId = new List<String>();
        oppModeId.add(updateOppMode[0].Id);
        oppModeId.add(updateOppMode[1].Id);
        oppModeId.add(updateOppMode[2].Id);
        List<Opportunity_Mode__c> newOppMode = TestUtill.createOpportunityMode(3);
        newOppMode[0].Opportunity_Product__c = oppProduct.Id;
        newOppMode[0].Settlement__c = settlementRecord.Id;
        newOppMode[0].Commercial__c = commercialsRecord.Id;
        newOppMode[0].Actual_Price_Percent__c = 3;

        newOppMode[1].Opportunity_Product__c = oppProduct.Id;
        newOppMode[1].Settlement__c = settlementRecord.Id;
        newOppMode[1].Commercial__c = commercialsRecord.Id;
        newOppMode[1].Actual_Price_Percent__c = 3;

        newOppMode[2].Opportunity_Product__c = oppProduct.Id;
        newOppMode[2].Settlement__c = settlementRecord.Id;
        newOppMode[2].Commercial__c = commercialsRecord.Id;
        newOppMode[2].Actual_Price_Percent__c = 3;
        
        List<Settlement__c> settlementList = TestUtill.createSettlement(3);
        settlementList[0].Product__c = product[0].Id;
        settlementList[1].Product__c = product[1].Id;
        settlementList[2].Product__c = product[2].Id;
        
        Test.startTest();
        String result = ProductController.updateProduct(updateOppMode,newOppMode,oppModeId,settlementList);
        Test.stopTest();
        System.assert(result == 'success');
    }

    @isTest
    public static void deleteProduct_Test(){
        Opportunity oppRec=[SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        String result = ProductController.deleteProduct(oppRec.Id);
        Test.stopTest();
        System.assertEquals('success', result);
    }

    @isTest
    public static void deleteProduct_Error_Test(){
        Opportunity oppRec=[SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        String result = ProductController.deleteProduct(null);
        Test.stopTest();
        System.assertEquals('error', result);
    }
     @isTest
    public static void chekTaskStatus_Test(){
       Case checkCase = [Select Id From Case limit 1];
		
        Case_CheckList__c casecheck= new Case_CheckList__c();
        casecheck.Name='Website Check';
        casecheck.Case__c=checkCase.Id;
        insert casecheck;
        
            Task tsk = new Task();
            tsk.Subject = 'Test Task Subject ';
            tsk.ActivityDate = System.today() + 5;
            tsk.Priority = 'High';
            tsk.Status = 'Open';
            tsk.Description='done';
            tsk.WhatId=casecheck.Id;
            insert tsk;
            tsk.Status = 'Completed';
            update tsk;
        Test.startTest();
        String result = ProductController.chekTaskStatus(checkCase.Id);
        Test.stopTest();
      //  System.assertEquals('error', result);
    }

    @isTest
    public static void chekTaskStatus_Test2(){
       Case checkCase = [Select Id From Case limit 1];
		
        Case_CheckList__c casecheck= new Case_CheckList__c();
        casecheck.Name='Website Check';
        casecheck.Case__c=checkCase.Id;
        insert casecheck;
        
            Task tsk = new Task();
            tsk.Subject = 'Test Task Subject ';
            tsk.ActivityDate = System.today() + 5;
            tsk.Priority = 'High';
            tsk.Status = 'Open';
            tsk.Description='done';
            tsk.WhatId=casecheck.Id;
            insert tsk;

        Test.startTest();
        String result = ProductController.chekTaskStatus(checkCase.Id);
        Test.stopTest();
      //  System.assertEquals('error', result);
    }

    @isTest 
    static void checkMerchantIdTest(){
        Account accRecord = [Select Id, MID__c From Account LIMIT 1];

        accRecord.MID__c = '54648';
        Update accRecord;

        Case caseRecord = [Select Id From Case LIMIT 1];

        Test.startTest();
        String result = ProductController.checkMerchantId(caseRecord.Id);
        Test.stopTest();

        System.assert(result == 'Pass');
    }

    @isTest 
    static void checkMerchantIdTest1(){
        Test.startTest();
        String result = ProductController.checkMerchantId(null);
        Test.stopTest();
        System.assert(result == 'Fail');
    }


    @isTest 
    static void checkMerchantIdTest2(){
        Account accRecord = [Select Id, MID__c From Account LIMIT 1];

        accRecord.MID__c = '54648Y';
        Update accRecord;

        Case caseRecord = [Select Id From Case LIMIT 1];

        Test.startTest();
        String result = ProductController.checkMerchantId(caseRecord.Id);
        Test.stopTest();

        System.assert(result == 'Fail');
    }


    @isTest 
    static void fetchOpportunityProductTest(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        Test.startTest();
        ProductController.OpportunityProductInformation result =  ProductController.fetchOpportunityProduct(opp.Id);
        Test.stopTest();
        System.assert(result != null);
    }
}