/*
 * @description       :
 * @author            : Saurav Kashyap
 * @group             :
 * @last modified on  : 12-01-2022
 */
@isTest
public class AddMerchantRequestWrapperTest {
  public static testMethod void validateAMRW() {
    AddMerchantRequestWrapper addMWrapper = new AddMerchantRequestWrapper();
    String str;
    Test.startTest();
    addMWrapper = AddMerchantRequestWrapper.parse(str);
    Test.stopTest();

    System.assert(addMWrapper != null);
  }
}
