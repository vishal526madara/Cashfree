@isTest
public class BankOpsController_Test {
  @testSetup
  static void makeData() {
    List<User> userlst = TestUtill.createUser(1);
    userlst[0].LastName = 'TestUser';
    insert userlst;

    List<Account> accountList = TestUtill.createAccount(1);
    insert accountList;

    List<Entitlement> entitle = TestUtill.createentitlement(2);
    entitle[0].Name = 'case support ent.';
    entitle[0].AccountId = accountList[0].Id;
    entitle[1].Name = 'Order support ent.';
    entitle[1].AccountId = accountList[0].Id;
    insert entitle;

    List<Opportunity> oppList = TestUtill.createOpportunity(1);
    insert oppList;

    List<Case> caseList = TestUtill.createCase(2);
    for (Case caseRecord : caseList) {
      caseRecord.Opportunity__c = oppList[0].Id;
      caseRecord.OwnerId = userlst[0].Id;
    }
    insert caseList;

    List<Method_Type__c> mehtodlist = TestUtill.createmethod(1);
    insert mehtodlist;

    List<Product__c> productList = TestUtill.createProduct(2);
    insert productList;

    List<Opportunity_Product__c> oppProductList = TestUtill.createOpportunityProduct(
      2
    );
    oppProductList[0].Opportunity__c = oppList[0].Id;
    oppProductList[1].Opportunity__c = oppList[0].Id;
    // oppProductList[2].Opportunity__c = oppList[0].Id;
    insert oppProductList;

    List<Commercial__c> commlst = TestUtill.createCommercial(1);
    insert commlst;

    List<Opportunity_Mode__c> oppModeList = TestUtill.createOpportunityMode(2);
    oppModeList[0].Opportunity_Product__c = oppProductList[0].Id;
    oppModeList[0].Method_Type__c = mehtodlist[0].Id;
    oppModeList[0].Commercial__c = commlst[0].id;
    oppModeList[0].Actual_Price__c = 101;
    oppModeList[0].Opportunity_Product__c = oppProductList[0].id;
    oppModeList[1].Opportunity_Product__c = oppProductList[0].Id;
    oppModeList[1].Method_Type__c = mehtodlist[0].Id;

    oppModeList[1].Commercial__c = commlst[0].id;
    oppModeList[1].Actual_Price__c = 101;
    oppModeList[1].Opportunity_Product__c = oppProductList[0].id;

    insert oppModeList;

    List<Modes__c> modeList = TestUtill.createMode(2);
    modeList[0].Product__c = productList[0].Id;
    modeList[1].Product__c = productList[1].Id;
    // modeList[2].Product__c = productList[2].Id;
    insert modeList;

    List<Commercial__c> commercialList = TestUtill.createCommercial(3);
    commercialList[0].Mode__c = modeList[0].Id;
    commercialList[1].Mode__c = modeList[0].Id;
    commercialList[2].Mode__c = modeList[1].Id;
    //  commercialList[3].Mode__c = modeList[1].Id;
    //  commercialList[4].Mode__c = modeList[2].Id;
    //  commercialList[5].Mode__c = modeList[2].Id;
    insert commercialList;

    List<WorkOrder> workorderlist = TestUtill.createworkorder(1);
    workorderlist[0].AccountId = accountList[0].Id;
    workorderlist[0].CaseId = caseList[0].Id;
    insert workorderlist;

    List<Bank_Ops__c> bankOpslist = TestUtill.createbankops(2);
    insert bankOpsList;

    List<Bank_Ops_Junction__c> bankOpsJunctionRecordList = TestUtill.createBankOpsJunction(
      1
    );
    bankOpsJunctionRecordList[0].Commercial__c = commercialList[0].Id;
    bankOpsJunctionRecordList[0].Bank_Ops__c = bankOpslist[0].Id;
    //   bankOpsJunctionRecordList[1].Commercial__c = commercialList[2].Id;
    //   bankOpsJunctionRecordList[1].Bank_Ops__c = bankOpslist[1].Id;
    insert bankOpsJunctionRecordList;

    List<Group> grouprec = TestUtill.creategroup(1);
    insert grouprec;
  }
  @isTest
  static void getParentCaseDetails_Test() {
    Case caserec = [SELECT Id FROM Case LIMIT 1];
    List<BankOpsController.ProductWrapper> wraplist = new List<BankOpsController.ProductWrapper>();
    String MYJSON = JSON.serialize(wraplist);
    Test.startTest();
    String result = BankOpsController.getParentCaseDetails(
      caserec.Id,
      MYJSON,
      null,
      'Onboarding Team'
    );
    Test.stopTest();
    system.assertEquals(result, result);
  }

  @isTest
  static void createWorkOrder_test() {
    Case caserec = [
      SELECT Id, Description, AccountId, OwnerId, Priority, ContactId
      FROM Case
      LIMIT 1
    ];
    List<User> userlist = [
      SELECT Id
      FROM User
      WHERE LastName = 'TestUser'
      LIMIT 1
    ];
    List<Bank_Ops_Junction__c> bankOpsJunctionRecordList = [
      SELECT Id, Commercial__c, Bank_Ops__c
      FROM Bank_Ops_Junction__c
      LIMIT 1
    ];
    List<Commercial__c> commerciallist = [
      SELECT Id, Name
      FROM Commercial__c
      LIMIT 2
    ];
    List<WorkOrder> worklist = [SELECT Id FROM WorkOrder LIMIT 1];

    List<BankOpsController.ProductWrapper> wraplist = new List<BankOpsController.ProductWrapper>();
    for (integer i = 0; i < 2; i++) {
      BankOpsController.ProductWrapper wrap = new BankOpsController.ProductWrapper();
      wrap.commercialId = commerciallist[i].id;
      wrap.commercialName = 'Test';
      wraplist.add(wrap);
      //  wrap.commercialId = commerciallist[1].id;
      //  wrap.commercialName = 'Test1';
      // wraplist.add(wrap);
    }
    system.debug('wraplist' + wraplist);

    List<Bank_Ops__c> bankopslist = TestUtill.createbankops(1);
    bankopslist[0].Name = 'Test#';
    bankopslist[0].Commercial__c = commerciallist[0].Id;

    Test.startTest();
    insert bankopslist;
    BankOpsController.createWorkOrder(caserec, wraplist, userlist[0].Id);
    Test.stopTest();
  }

  @isTest
  static void getOpportunityProductDetails_test() {
    List<Opportunity> opplist = [SELECT Id, Name FROM Opportunity LIMIT 1];
    List<Commercial__c> commerciallist = [
      SELECT Id, Name
      FROM Commercial__c
      LIMIT 1
    ];
    List<Opportunity_Mode__c> oppmod = [
      SELECT Id, Name, Commercial__c
      FROM Opportunity_Mode__c
      LIMIT 1
    ];
    List<BankOpsController.ProductWrapper> wraplist = new List<BankOpsController.ProductWrapper>();
    BankOpsController.ProductWrapper wrap = new BankOpsController.ProductWrapper();
    wrap.commercialId = oppmod[0].Commercial__c;
    wrap.commercialName = 'Test';
    wraplist.add(wrap);
    Test.startTest();
    List<BankOpsController.ProductWrapper> result = BankOpsController.getOpportunityProductDetails(
      opplist[0].Id
    );
    Test.stopTest();
  }

  @isTest
  static void getCaseRec_test() {
    Case caserec = [SELECT Id FROM Case LIMIT 1];
    Test.startTest();
    Case result = BankOpsController.getCaseRec(caserec.Id);
    Test.stopTest();
    system.assertEquals(result, result);
  }

  @isTest
  static void generatePaymentWrapper_test() {
    List<Opportunity> opplist = [SELECT Id, Name FROM Opportunity LIMIT 1];
    Test.startTest();
    List<BankOpsController.MethodTypeWrapper> result = BankOpsController.generatePaymentWrapper(
      opplist[0].Id
    );
    Test.stopTest();
    system.assertEquals(result, result);
  }

  @isTest
  static void opportunityProductName_test() {
    List<Opportunity_Product__c> oppprodlist = [
      SELECT Id, Name
      FROM Opportunity_Product__c
      LIMIT 1
    ];
    Test.startTest();
    String result = BankOpsController.opportunityProductName(oppprodlist[0].Id);
    Test.stopTest();
    system.assertEquals(result, result);
  }
}
