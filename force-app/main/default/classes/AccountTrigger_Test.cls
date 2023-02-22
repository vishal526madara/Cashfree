@IsTest
public class AccountTrigger_Test {
  @IsTest(SeeAllData=true)
  public static void testAccountInsert() {
    Test.startTest();
    Account createAcct = new Account();
    createAcct.Name = 'Hello Account';
    createAcct.Website = 'www.testaccount.com';
    createAcct.MID__c = '123456M4545';
    insert createAcct;
    Test.stopTest();

    List<Account> getAcct = [
      SELECT Id
      FROM Account
      WHERE Name = 'Hello Account'
      LIMIT 1
    ];
    System.assertEquals(createAcct.Id, getAcct[0].Id);

    //delete getAcct;
  }

  @IsTest(SeeAllData=true)
  public static void testAccountUpdate() {
    Test.startTest();
    Account createAcct = new Account();
    createAcct.Name = 'Hello Account 2';
    createAcct.Website = 'www.testaccount 2.com';
    createAcct.Owner_Email_ID__c = 'test@abdc.com';
    createAcct.Sales_Manager_Email_ID__c = 'test123@abdc.com';
    insert createAcct;

    createAcct.Website = 'www.testaccountnew.com';
    update createAcct;
    Test.stopTest();

    List<Account> getAcct = [
      SELECT Id, Website
      FROM Account
      WHERE Name = 'Hello Account 2'
      LIMIT 1
    ];
    System.assertEquals('www.testaccountnew.com', getAcct[0].Website);

    //delete getAcct;
  }
}
