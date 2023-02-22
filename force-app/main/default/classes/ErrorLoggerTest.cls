/*
 * @description       :
 * @author            : Saurav Kashyap
 * @group             :
 * @last modified on  : 12-01-2022
 */
@isTest
public class ErrorLoggerTest {
  public static testMethod void validateEL() {
    String responseString;

    Test.startTest();
    responseString = ErrorLogger.createErrorLogger(
      'PostAddMerchantClass',
      'addMerchant',
      'DML',
      'Test',
      25,
      null
    );
    Test.stopTest();

    System.assert(responseString != null);
  }
}
