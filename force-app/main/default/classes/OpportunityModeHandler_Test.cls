@isTest
public class OpportunityModeHandler_Test {
  @testSetup
  static void makeData() {
    List<Commercial__c> commlst = TestUtill.createCommercial(1);
    insert commlst;

    List<Opportunity> oppolst = TestUtill.createOpportunity(1);
    oppolst[0].Any_Deviation__c = 'No';
    insert oppolst;

    List<Product__c> productList = TestUtill.createProduct(1);
    insert productList;

    List<Opportunity_Product__c> oppoprodlst = TestUtill.createOpportunityProduct(
      1
    );
    oppoprodlst[0].Opportunity__c = oppolst[0].id;
    oppoprodlst[0].product__c = productList[0].id;
    insert oppoprodlst;
  }
  @isTest
  static void OpportunityModeHandlerupdate_Test() {
    Commercial__c commlst = [
      SELECT Id, Commercial_Price__c, Commercials__c
      FROM Commercial__c
      LIMIT 1
    ];
    Opportunity oppolst = [
      SELECT Id, Any_Deviation__c, Product_Price__c, StageName
      FROM Opportunity
      LIMIT 1
    ];
    Opportunity_Product__c oppoprodlst = [
      SELECT Id, Opportunity__c
      FROM Opportunity_Product__c
      LIMIT 1
    ];

    List<Opportunity_Mode__c> OpportunityModelst = TestUtill.createOpportunityMode(
      1
    );
    OpportunityModelst[0].Commercial__c = commlst.id;
    OpportunityModelst[0].Actual_Price__c = 101;
    OpportunityModelst[0].Opportunity_Product__c = oppoprodlst.id;

    insert OpportunityModelst;
    List<Opportunity_Mode__c> OpportunityModeupdateList = [
      SELECT Id, Name, Actual_Price__c, Commercial__c, Opportunity_Product__c
      FROM Opportunity_Mode__c
    ];
    OpportunityModeupdateList[0].Actual_Price__c = 101;
    system.debug('OpportunityModeupdateList' + OpportunityModeupdateList);

    Test.startTest();
    update OpportunityModeupdateList;
    Test.stopTest();
    // system.assertEquals(result, result);
  }

  @isTest
  static void checkDeviation_Test() {
    List<Account> accList = TestUtill.createAccount(1);
    accList[0].AccountSource = 'Banking Alliance';
    insert accList;

    Commercial__c commlst = [
      SELECT Id, Commercial_Price__c, Commercials__c
      FROM Commercial__c
      LIMIT 1
    ];

    Opportunity oppolst = [
      SELECT
        Id,
        Any_Deviation__c,
        Product_Price__c,
        StageName,
        Account.AccountSource
      FROM Opportunity
      LIMIT 1
    ];
    oppolst.AccountId = accList[0].Id;
    update oppolst;
    system.debug('oppolst ' + oppolst);

    Opportunity_Product__c oppoprodlst = [
      SELECT Id, Opportunity__c
      FROM Opportunity_Product__c
      LIMIT 1
    ];

    List<Opportunity_Mode__c> OpportunityModelst = TestUtill.createOpportunityMode(
      1
    );
    OpportunityModelst[0].Commercial__c = commlst.id;
    OpportunityModelst[0].Actual_Price__c = 101;
    OpportunityModelst[0].Opportunity_Product__c = oppoprodlst.id;
    insert OpportunityModelst;

    List<Opportunity_Mode__c> OpportunityModeupdateList = [
      SELECT Id, Name, Actual_Price__c, Commercial__c, Opportunity_Product__c
      FROM Opportunity_Mode__c
    ];
    OpportunityModeupdateList[0].Actual_Price__c = 11;
    system.debug('OpportunityModeupdateList' + OpportunityModeupdateList);
    List<User> getCurrentUser = TestUtill.createUser(2);
    getCurrentUser[0].Division1__c = 'Banking & Alliances';
    getCurrentUser[0].Sub_Division__c = 'Banking & Alliance - Product';
    getCurrentUser[1].Division1__c = 'Enterprises';
    getCurrentUser[1].Sub_Division__c = 'SMB Outbound';
    insert getCurrentUser;
    List<Pricing_Approval_Matrix__c> pricingApprovalMatrixList = new List<Pricing_Approval_Matrix__c>();
    Pricing_Approval_Matrix__c pricingApprovalMatrixRec = new Pricing_Approval_Matrix__c();
    pricingApprovalMatrixRec.Account_Source__c = 'Banking Alliance';
    pricingApprovalMatrixRec.Approver__c = getCurrentUser[0].Id;
    pricingApprovalMatrixRec.Division__c = getCurrentUser[1].Division1__c;
    pricingApprovalMatrixRec.Sub_Division__c = getCurrentUser[1]
      .Sub_Division__c;
    pricingApprovalMatrixRec.Is_Active__c = true;
    pricingApprovalMatrixRec.Name = 'test';
    pricingApprovalMatrixList.add(pricingApprovalMatrixRec);

    Test.startTest();
    insert pricingApprovalMatrixList;
    update OpportunityModeupdateList;
    Test.stopTest();
    // system.assertEquals(result, result);
  }
}
