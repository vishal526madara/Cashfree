/*
 * @description       :
 * @author            : Saurav Kashyap
 * @group             :
 * @last modified on  : 12-01-2022
 */
@isTest
public class API_LoggerTest {
  public static testMethod void validateAPIL() {
    String responseString;
    Test.startTest();
    responseString = API_Logger.createAPI_Logger(
      'PostAddMerchantClass',
      'Req',
      'Res',
      'www.endPointURL.com',
      '200',
      null
    );
    Test.stopTest();

    System.assert(responseString != null);
  }
}
