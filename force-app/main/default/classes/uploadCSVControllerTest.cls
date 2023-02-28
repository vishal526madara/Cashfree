@isTest
public class uploadCSVControllerTest {
  @testSetup
  public static void makeData() {
    List<Account> AccData = TestUtill.createAccount(1);
    insert AccData;

    Entitlement ent = new Entitlement();
    ent.AccountId = AccData[0].Id;
    ent.Name = 'Order support ent.';
    insert ent;

    List<WorkOrder> mapwork = new List<WorkOrder>();
    WorkOrder work = new WorkOrder();
    work.AccountId = AccData[0].Id;
    work.Status = 'New';
    work.Case_For__c = 'SC';
    work.EntitlementId = ent.Id;
    // work.CaseId=ce.Id;
    work.Discrepancy__c = 'We would need the GSTIN details of your business to proceed with this request further.';
    mapwork.add(work);
    insert mapwork;
  }
  @isTest
  public static void insertWorkOrder_Test() {
    List<WorkOrder> workListquery = [
      SELECT Id, Status, Case_For__c, Discrepancy__c
      FROM WorkOrder
      LIMIT 1
    ];
    system.debug('workListquery>>' + workListquery);
    WorkOrder workQuery = [
      SELECT Id, Status, Case_For__c, Discrepancy__c
      FROM WorkOrder
      LIMIT 1
    ];

    test.startTest();
    string workO = uploadCSVController.insertWorkOrder(
      workListquery,
      workQuery.Id
    );
    test.stopTest();

    //system.assert('success');
  }
  @isTest
  public static void getTemplateApiNames_Test() {
    List<WorkOrder> workListquery = [
      SELECT Id, Status, Case_For__c, Discrepancy__c
      FROM WorkOrder
      LIMIT 1
    ];
    system.debug('workListquery>>' + workListquery);
    WorkOrder workQuery = [
      SELECT Id, Status, Case_For__c, Discrepancy__c
      FROM WorkOrder
      LIMIT 1
    ];

    test.startTest();
    string workO = uploadCSVController.getTemplateApiNames();
    test.stopTest();

    //system.assert('success');
  }
}
