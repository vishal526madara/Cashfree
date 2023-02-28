@isTest
public class OrderEntitlementHandlerTest {
  @TestSetup
  static void makeData() {
    List<Account> accList = TestUtill.createAccount(1);
    system.debug('accList1>>' + accList);
    insert accList;

    Entitlement ent = new Entitlement();
    ent.AccountId = accList[0].Id;
    ent.Name = 'Order support ent.';

    //  WorkOrder work=new WorkOrder();
    //  work.AccountId=accList[0].Id;
    //  system.debug('');
    // insert work;
    //      system.debug('work>>'+work);
  }
  @isTest
  public static void manageEntitlement_Test() {
    List<WorkOrder> workquery = [SELECT Id FROM WorkOrder LIMIT 1];

    Test.startTest();
    OrderEntitlementHandler.manageEntitlement(workquery);
    Test.stopTest();
    //System.assertEquals(1, result.size());
  }
}
