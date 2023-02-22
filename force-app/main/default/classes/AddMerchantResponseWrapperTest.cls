/*
 * @description       :
 * @author            : Saurav Kashyap
 * @group             :
 * @last modified on  : 12-01-2022
 */
@isTest
public class AddMerchantResponseWrapperTest {
  public static testMethod void validateAMRW() {
    AddMerchantResponseWrapper addMWrapper = new AddMerchantResponseWrapper();
    String str;
    Test.startTest();
    addMWrapper = AddMerchantResponseWrapper.parse(str);
    Test.stopTest();

    System.assert(addMWrapper != null);
  }
}
