@isTest
public class WorkOrderTriggerHandlerTest {
  @TestSetup
  static void makeData() {
    List<Account> accList = TestUtill.createAccount(1);
    insert accList;

    List<Commercial__c> comList = TestUtill.createCommercial(1);
    insert comList;

    Entitlement ent = new Entitlement();
    ent.AccountId = accList[0].Id;
    ent.Name = 'Order support ent.';
    insert ent;

    Entitlement entc = new Entitlement();
    entc.AccountId = accList[0].Id;
    entc.Name = 'case support ent.';
    insert entc;

    Case ce = new Case();
    ce.Status = 'Open';
    ce.EntitlementId = entc.Id;
    insert ce;

    //    List<Case> createCas=TestUtill.createCase(1);
    // createCas.EntitlementId=entc.Id;
    //  insert createCas;

    Map<Id, WorkOrder> mapwork = new Map<Id, WorkOrder>();
    WorkOrder work = new WorkOrder();
    work.AccountId = accList[0].Id;
    work.Status = 'New';
    work.Case_For__c = 'SC';
    work.EntitlementId = ent.Id;
    work.CaseId = ce.Id;
    work.Commercial__c = comList[0].id;
    work.Discrepancy__c = 'We would need the GSTIN details of your business to proceed with this request further.';
    mapwork.put(work.Id, work);
    insert mapwork.values();
    system.debug('mapwork>>' + mapwork);
  }
  @isTest
  public static void afterInsert_Test() {
    Map<Id, WorkOrder> mapwork1 = new Map<Id, WorkOrder>(
      [
        SELECT
          id,
          AccountId,
          Commercial__c,
          WorkOrderNumber,
          Status,
          Case_For__c,
          EntitlementId,
          CaseId,
          Discrepancy__c
        FROM WorkOrder
        LIMIT 1
      ]
    );
    mapwork1.values().Status = 'Action Required Internal';
    update mapwork1.values();
    /*
        Map<Id,WorkOrder> mapwork1=New Map<Id,WorkOrder>();
         WorkOrder work1=new WorkOrder();
       //  work1.AccountId=accList[0].Id;
         work1.Status='Action Required Internal';
         work1.Case_For__c='SC';
       //  work1.EntitlementId=ent.Id; 
         work1.Discrepancy__c='We would need the GSTIN details of your business to proceed with this request further.';
 		mapwork1.put(work1.Id,work1);
        insert mapwork1.values();
       */
    // Map<Id,WorkOrder> nworkquery=new Map<Id,WorkOrder>([select Id,Status,Case_For__c,Discrepancy__c from WorkOrder limit 1]);
    //  nworkquery.values().Status='Action Required Internal';
    //  update nworkquery.values();

    Test.startTest();
    WorkOrderTriggerHandler.afterInsert(mapwork1);
    Test.stopTest();
    //System.assertEquals(1, result.size());
  }
  /*
@isTest
    public static void afterUpdate_Test(){
        Map<Id,WorkOrder> oldworkquery=new Map<Id,WorkOrder>([select Id,Status,Case_For__c,Discrepancy__c from WorkOrder limit 1]);
        
        Map<Id,WorkOrder> newworkquery=new Map<Id,WorkOrder>([select Id,Status,Case_For__c,Discrepancy__c from WorkOrder limit 1]);
        newworkquery.values().Status='Action Required Internal';            
        update newworkquery.values();
        
        Test.startTest();
        WorkOrderTriggerHandler.afterUpdate(newworkquery,oldworkquery);
        Test.stopTest();
        //System.assertEquals(1, result.size());
    }*/
  @isTest
  public static void afterUpdate_Test2() {
    Map<Id, WorkOrder> oldworkquery = new Map<Id, WorkOrder>(
      [
        SELECT Id, WorkOrderNumber, Status, Case_For__c, Discrepancy__c
        FROM WorkOrder
        LIMIT 1
      ]
    );

    Map<Id, WorkOrder> newworkquery = new Map<Id, WorkOrder>(
      [
        SELECT Id, WorkOrderNumber, Status, Case_For__c, Discrepancy__c
        FROM WorkOrder
        LIMIT 1
      ]
    );
    newworkquery.values().Status = 'New';
    update newworkquery.values();

    Test.startTest();
    WorkOrderTriggerHandler.afterUpdate(newworkquery, oldworkquery);
    Test.stopTest();
    //System.assertEquals(1, result.size());
  }
}
