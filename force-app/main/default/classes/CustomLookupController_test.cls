@isTest
public class CustomLookupController_test {
  @testSetup
  static void makeData() {
    List<Account> accountData = TestUtill.createAccount(5);
    insert accountData;
    System.debug('Account Data' + accountData);
  }
  @isTest
  static void Search_Test1() {
    List<Account> accountrecord = [
      SELECT Id, Name, Industry
      FROM Account
      LIMIT 5
    ];
    System.debug('Account Record 1' + accountrecord);

    Test.startTest();
    String Type = 'Industry = \'Agriculture\'';
    List<Account> result = CustomLookUpController.search(
      'Test',
      'Account',
      Type
    );
    Test.stopTest();

    System.debug('Result Value1' + result);

    //System.assert(result[0].Name == accountrecord[0].Name);
  }
  @isTest
  static void search_Test2() {
    List<Account> accountrecord = [
      SELECT Id, Name
      FROM Account
      ORDER BY Name DESC
    ];
    System.debug('Account Record 2' + accountrecord);

    Test.startTest();
    List<Account> result = CustomLookUpController.search(
      'Test',
      'Account',
      null
    );
    Test.stopTest();
    System.debug('Result Value 2' + result);

    System.assert(result != null);
  }
  @isTest
  static void search_Test3() {
    List<Account> accountrecord = [SELECT Id, Name FROM Account];
    System.debug('Object Record 3' + accountrecord);

    Test.startTest();
    List<Account> result = CustomLookUpController.search(
      'Test',
      'Account',
      null
    );
    Test.stopTest();

    System.debug('Result Value 3' + result);

    //System.assert(result == accountrecord);
  }
}
