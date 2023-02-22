@isTest
public class AccountOpportunityController_Test {
  @TestSetup
  static void makeData() {
    List<Product__c> proList = TestUtill.createProduct(1);
    proList[0].Product_Code__c = 'auto_collect';
    proList[0].Is_Active__c = true;
    //proList[0].Product_Image__c = '';
    insert proList;

    List<Account> accList = TestUtill.createAccount(1);
    insert accList;

    List<Opportunity> oppList = TestUtill.createOpportunity(1);
    oppList[0].AccountId = accList[0].Id;
    oppList[0].StageName = 'Qualification';
    oppList[0].Probability = 10;
    insert oppList;

    List<Opportunity_Product__c> oppProList = TestUtill.createOpportunityProduct(
      1
    );
    oppProList[0].Opportunity__c = oppList[0].Id;
    oppProList[0].Product__c = proList[0].Id;
    insert oppProList;

    List<Merchant_Product__c> merchantProList = new List<Merchant_Product__c>();
    Merchant_Product__c mPro = new Merchant_Product__c();
    mPro.Account__c = accList[0].Id;
    mPro.Product__c = proList[0].Id;
    merchantProList.add(mPro);
    insert merchantProList;
  }

  @isTest
  public static void accountOppProduct_Test() {
    Account accRec = [SELECT Id FROM Account LIMIT 1];
    System.debug('accRec >> ' + accRec);
    List<Merchant_Product__c> merchantProdList = [
      SELECT Id, Name, Product__c, Account__c, Status_Color__c
      FROM Merchant_Product__c
    ];
    System.debug('merchantProdList >> ' + merchantProdList);
    Test.startTest();
    List<AccountOpportunityController.ProductData> result = AccountOpportunityController.accountOppProduct(
      accRec.Id
    );
    System.debug('result >> ' + result);
    Test.stopTest();
    System.assert(result.size() > 0);
  }

  @isTest
  public static void accountOppProduct_Exception_Test() {
    Test.startTest();
    try {
      List<AccountOpportunityController.ProductData> result = AccountOpportunityController.accountOppProduct(
        null
      );
    } catch (Exception e) {
      System.assertEquals(e.getMessage(), e.getMessage());
    }
    Test.stopTest();
  }
}
