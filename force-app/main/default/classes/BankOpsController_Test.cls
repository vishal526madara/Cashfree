@isTest
public class BankOpsController_Test {
@testSetup 
    static void makeData(){
        
        List<Cashfree_Document_Master__c> docMasterList = TestUtill.createcashfreedoc(3);
        docMasterList[0].KYC_Category__c = 'Regular';
        docMasterList[0].Name = 'Public Limited';

        docMasterList[1].KYC_Category__c = 'Regular';
        docMasterList[1].Name = 'Private Limited';

        docMasterList[2].KYC_Category__c = 'LOB';
        docMasterList[2].Name = 'Government';

        Insert docMasterList;

        List<Document_Type__c> docTypeList = TestUtill.createdocumenttype(7);
        docTypeList[0].Cashfree_Document_Master__c = docMasterList[2].Id;
        docTypeList[0].Name = 'Document';

        docTypeList[1].Cashfree_Document_Master__c = docMasterList[0].Id;
        docTypeList[1].Name = 'Business Registration';

        docTypeList[2].Cashfree_Document_Master__c = docMasterList[0].Id;
        docTypeList[2].Name = 'Company PAN';

        docTypeList[3].Cashfree_Document_Master__c = docMasterList[0].Id;
        docTypeList[3].Name = 'Director/ Owner\'s PAN';

        docTypeList[4].Cashfree_Document_Master__c = docMasterList[1].Id;
        docTypeList[4].Name = 'Business Registration';

        docTypeList[5].Cashfree_Document_Master__c = docMasterList[1].Id;
        docTypeList[5].Name = 'Company PAN';

        docTypeList[6].Cashfree_Document_Master__c = docMasterList[1].Id;
        docTypeList[6].Name = 'Director/ Owner\'s PAN';

        Insert docTypeList;

        List<Document_List__c> docList = TestUtill.createdocumentlist(10);
        docList[0].Name = 'Registration Certificate';
        docList[0].External_Doc_Type__c = 'lobReg' ;
        docList[0].Document_Type__c = docTypeList[0].Id;


        docList[1].Name = 'COI';
        docList[1].External_Doc_Type__c = 'recoi';
        docList[1].Document_Type__c = docTypeList[1].Id;


        docList[2].Name = 'GST';
        docList[2].External_Doc_Type__c = 'regst';
        docList[2].Document_Type__c = docTypeList[1].Id;


        docList[3].Name = 'Company PAN';
        docList[3].External_Doc_Type__c = 'repan';
        docList[3].Document_Type__c = docTypeList[2].Id;


        docList[4].Name = 'Director/ Owner PAN';
        docList[4].External_Doc_Type__c = 'reopan';
        docList[4].Document_Type__c = docTypeList[3].Id;



        docList[5].Name = 'COI';
        docList[5].External_Doc_Type__c = 'recoi';
        docList[5].Document_Type__c = docTypeList[4].Id;



        docList[6].Name = 'GST';
        docList[6].External_Doc_Type__c = 'regst';
        docList[6].Document_Type__c = docTypeList[4].Id;


        docList[8].Name = 'Company PAN';
        docList[8].External_Doc_Type__c = 'repan';
        docList[8].Document_Type__c = docTypeList[5].Id;


        docList[9].Name = 'Director/ Owner PAN';
        docList[9].External_Doc_Type__c = 'reopen';
        docList[9].Document_Type__c = docTypeList[6].Id;

        Insert docList;

        
        
        List<User> userlst = TestUtill.createUser(1);
        userlst[0].LastName = 'TestUser';
        Insert userlst;
        
        Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
        List<Account> accountList = TestUtill.createAccount(1);
        accountList[0].MID__c='126546';
        Insert accountList;
        
        List<Entitlement> entitle = TestUtill.createentitlement(2);
        entitle[0].Name = 'case support ent.';
        entitle[0].AccountId = accountList[0].Id;
        entitle[1].Name = 'Order support ent.';
        entitle[1].AccountId = accountList[0].Id;
        Insert entitle;

        List<Opportunity> oppList = TestUtill.createOpportunity(1);
        Insert oppList;
        
        List<Case> caseList = TestUtill.createCase(2);
        for(Case caseRecord : caseList){
            caseRecord.Opportunity__c = oppList[0].Id;
            caseRecord.OwnerId = userlst[0].Id;
        }
        Insert caseList;
        
        List<Method_Type__c> mehtodlist = TestUtill.createmethod(1);
        Insert mehtodlist;
        
        List<Product__c> productList = TestUtill.createProduct(2);
        Insert productList;
        
         List<Opportunity_Product__c> oppProductList = TestUtill.createOpportunityProduct(2);
        oppProductList[0].Opportunity__c = oppList[0].Id;
        oppProductList[1].Opportunity__c = oppList[0].Id;
       // oppProductList[2].Opportunity__c = oppList[0].Id;
        Insert oppProductList;
        
        List<Commercial__c> commlst = TestUtill.createCommercial(1);
        Insert commlst;
        
        List<Opportunity_Mode__c> oppModeList = TestUtill.createOpportunityMode(2);
        oppModeList[0].Opportunity_Product__c = oppProductList[0].Id;
        oppModeList[0].Method_Type__c = mehtodlist[0].Id;
        oppModeList[0].Commercial__c	= commlst[0].id;
        oppModeList[0].Actual_Price__c = 101;
        oppModeList[0].Opportunity_Product__c =oppProductList[0].id;
        oppModeList[1].Opportunity_Product__c = oppProductList[0].Id;
        oppModeList[1].Method_Type__c = mehtodlist[0].Id;
        
        oppModeList[1].Commercial__c	= commlst[0].id;
        oppModeList[1].Actual_Price__c = 101;
        oppModeList[1].Opportunity_Product__c =oppProductList[0].id;
        
        Insert oppModeList;

        
         List<Modes__c> modeList = TestUtill.createMode(2);
        modeList[0].Product__c = productList[0].Id;
        modeList[1].Product__c = productList[1].Id;
       // modeList[2].Product__c = productList[2].Id;
        Insert modeList;
        
        List<Commercial__c> commercialList = TestUtill.createCommercial(3);
        commercialList[0].Mode__c = modeList[0].Id; 
        commercialList[1].Mode__c = modeList[0].Id; 
        commercialList[2].Mode__c = modeList[1].Id; 
      //  commercialList[3].Mode__c = modeList[1].Id; 
      //  commercialList[4].Mode__c = modeList[2].Id; 
      //  commercialList[5].Mode__c = modeList[2].Id; 
        Insert commercialList;

        List<WorkOrder> workorderlist = TestUtill.createworkorder(1);
        workorderlist[0].AccountId =accountList[0].Id;
        workorderlist[0].CaseId =caseList[0].Id;
        Insert workorderlist;
        
        List<Bank_Ops__c> bankOpslist = TestUtill.createbankops(2);
        Insert bankOpsList;
        
        List<Bank_Ops_Junction__c> bankOpsJunctionRecordList =  TestUtill.createBankOpsJunction(1);
            bankOpsJunctionRecordList[0].Commercial__c = commercialList[0].Id;
            bankOpsJunctionRecordList[0].Bank_Ops__c = bankOpslist[0].Id;
         //   bankOpsJunctionRecordList[1].Commercial__c = commercialList[2].Id;
         //   bankOpsJunctionRecordList[1].Bank_Ops__c = bankOpslist[1].Id;
          Insert bankOpsJunctionRecordList;
        
        List<Group> grouprec =  TestUtill.creategroup(1);
        Insert grouprec;
        
    }
    @isTest
    static void getParentCaseDetails_Test(){
      Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
        Case caserec = [Select Id From Case Limit 1];
        List<BankOpsController.ProductWrapper> wraplist = new List<BankOpsController.ProductWrapper>();
        String MYJSON = JSON.serialize(wraplist);
        Test.startTest();
        String result = BankOpsController.getParentCaseDetails(caserec.Id,MYJSON,null,'Onboarding Team');
        Test.stopTest();
        system.assertEquals(result, result);
    }
    
     @isTest
    static void getParentCaseDetails_Test1(){
        Case caserec = [Select Id From Case Limit 1];
        List<BankOpsController.ProductWrapper> wraplist = new List<BankOpsController.ProductWrapper>();
        String MYJSON = JSON.serialize(wraplist);
        Test.startTest();
        String result = BankOpsController.getParentCaseDetails(caserec.Id,MYJSON,null,'Bank Ops Team');
        Test.stopTest();
        system.assertEquals(result, result);
    }
    
    
    @isTest
    static void createWorkOrder_test(){
        
        Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
      Case caserec = [Select Id,Description,AccountId,OwnerId,Priority,ContactId From Case Limit 1];
        List<User> userlist = [SELECT Id From User  Where LastName = 'TestUser' Limit 1];
        List<Bank_Ops_Junction__c> bankOpsJunctionRecordList =[SELECT Id,Commercial__c,Bank_Ops__c From Bank_Ops_Junction__c limit 1];
       List<Commercial__c> commerciallist = [Select Id, Name From Commercial__c Limit 2];
       List<WorkOrder> worklist = [Select Id From WorkOrder LIMIT 1];
        
        List<BankOpsController.ProductWrapper> wraplist = new List<BankOpsController.ProductWrapper>();
        for(integer i=0; i<2;i++){
                BankOpsController.ProductWrapper wrap = new BankOpsController.ProductWrapper();
                wrap.commercialId = commerciallist[i].id;
                wrap.commercialName = 'Test';
                wraplist.add(wrap);  
              //  wrap.commercialId = commerciallist[1].id;
              //  wrap.commercialName = 'Test1';
               // wraplist.add(wrap); 
        }
     system.debug('wraplist'+wraplist);
        
        List<Bank_Ops__c> bankopslist = TestUtill.createbankops(1);
        bankopslist[0].Name = 'Test#';
        bankopslist[0].Commercial__c = commerciallist[0].Id;
        try{
        Test.startTest();
        Insert bankopslist;
        BankOpsController.createWorkOrder(caserec,wraplist,userlist[0].Id);
        }
         catch(Exception ex){
             System.assertEquals(ex.getMessage(), ex.getMessage());
         }

        Test.stopTest();
    }
    
    
    @isTest
    static void getOpportunityProductDetails_test(){
        List<Opportunity> opplist = [SELECT Id, Name From Opportunity LIMIT 1];
        List<Commercial__c> commerciallist = [Select Id, Name From Commercial__c Limit 1];
        List<Opportunity_Mode__c> oppmod = [SELECT Id , Name ,Commercial__c From Opportunity_Mode__c LIMIT 1];
        List<BankOpsController.ProductWrapper> wraplist = new List<BankOpsController.ProductWrapper>();
         BankOpsController.ProductWrapper wrap = new BankOpsController.ProductWrapper();
        wrap.commercialId = oppmod[0].Commercial__c;
        wrap.commercialName = 'Test';
        wraplist.add(wrap);
        Test.startTest();
        List<BankOpsController.ProductWrapper> result =  BankOpsController.getOpportunityProductDetails(opplist[0].Id);
        Test.stopTest();
    }
    
    @isTest
    static void getCaseRec_test(){
        Case caserec = [Select Id From Case Limit 1];
        Test.startTest();
        Case result = BankOpsController.getCaseRec(caserec.Id);
        Test.stopTest();
        system.assertEquals(result, result);
    }
    
    
    @isTest
    static void generatePaymentWrapper_test(){
        List<Opportunity> opplist = [SELECT Id, Name From Opportunity LIMIT 1];
        Test.startTest();
        List<BankOpsController.MethodTypeWrapper> result = BankOpsController.generatePaymentWrapper(opplist[0].Id);
        Test.stopTest();
        system.assertEquals(result, result);
    }
    
    @isTest
    static void opportunityProductName_test(){
        List<Opportunity_Product__c> oppprodlist = [Select Id , Name From Opportunity_Product__c LIMIT 1];
        Test.startTest();
        String result = BankOpsController.opportunityProductName(oppprodlist[0].Id);
        Test.stopTest();
        system.assertEquals(result, result);
    }
    
}