@isTest
public with sharing class DisplayRaiseCaseControllerTest {
    
    @TestSetup 
    static void makedata(){
        
        List<Account> accList=TestUtill.createAccount(1);
        system.debug('accList1>>'+accList);
        insert accList;
        
        List<Commercial__c> comList=TestUtill.createCommercial(1);
        insert comList;
      
        List<Entitlement> ent=TestUtill.createentitlement(1);
        ent[0].AccountId=accList[0].Id;
        ent[0].Name='Order support ent.';
        insert ent;
        
        List<Case> ce = TestUtill.createCase(1);
        ce[0].Status = 'Open';
        ce[0].EntitlementId = ent[0].Id;
        insert ce;

        List<WorkOrder> wo  = TestUtill.createworkorder(1);
        wo[0].AccountId = accList[0].Id;
        wo[0].Status = 'New';
        wo[0].EntitlementId = ent[0].Id;
        wo[0].Case_For__c = 'SC';
        wo[0].EntitlementId = ent[0].Id; 
        wo[0].CaseId = ce[0].Id;
        wo[0].Commercial__c = comList[0].id;
        wo[0].Discrepancy__c='We would need the GSTIN details of your business to proceed with this request further.';        
        insert wo;
        
        }
    
    @isTest
    static void testFetchWorkOrderNumber() {
        // Create a test work order record
        WorkOrder wo = [Select Id, WorkOrderNumber From WorkOrder LIMIT 1];
		Test.StartTest();
        // Call the fetchWorkOrderNumber method with the work order record Id
        String result = DisplayRaiseCaseController.fetchWorkOrderNumber(wo.Id);
		Test.stopTest();
        // Verify that the returned WorkOrderNumber matches the expected value
        System.assertEquals(wo.WorkOrderNumber, result);
    }
    
    
     @isTest
    static void fetchWorkOrderNullTest() {
        // Create a test work order record
       // WorkOrder wo = [Select Id, WorkOrderNumber From WorkOrder where Id = null LIMIT 1];
		Test.StartTest();
        // Call the fetchWorkOrderNumber method with the work order record Id
        String result = DisplayRaiseCaseController.fetchWorkOrderNumber(null);
		Test.stopTest();
        // Verify that the returned WorkOrderNumber matches the expected value
       // System.assertEquals(wo.WorkOrderNumber, result);
    }
}