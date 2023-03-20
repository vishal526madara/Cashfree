@isTest
public  class CaseTriggerTest {
 static String  parentCaseId  = null;
    @testSetup
    Public static void dataSet(){
       
        List<Case_Round_Robin__c> returnList = TestUtill.createCaseRoundRobin(2);
        returnList[0].ProfileName__c = 'B & A Sales;';
        returnList[0].Is_Active__c = true;
        returnList[1].ProfileName__c = 'Compulsive;Inbound';
        returnList[1].Is_Active__c = true;
        Insert returnList;


        
        Profile baProfileId = [SELECT Id FROM Profile WHERE Name='Operations - Merchant Onboarding'];

        List<User> userList = TestUtill.createUser(4);

        userList[0].ProfileId = baProfileId.Id;
        userList[1].ProfileId = baProfileId.Id;
        userList[2].ProfileId = baProfileId.Id;
        userList[3].ProfileId =  baProfileId.Id;

        Insert userList;

        List<Case_RoundRobin_Asignee__c> caseRoundRobinAssigneeList = TestUtill.createRoundRobinAssignee(4);
        caseRoundRobinAssigneeList[0].User__c = userList[0].Id;
        caseRoundRobinAssigneeList[0].Case_Round_Robin__c = returnList[0].Id;
        caseRoundRobinAssigneeList[1].User__c = userList[1].Id;
        caseRoundRobinAssigneeList[1].Case_Round_Robin__c = returnList[0].Id;
        caseRoundRobinAssigneeList[2].User__c = userList[2].Id;
        caseRoundRobinAssigneeList[2].Case_Round_Robin__c = returnList[1].Id;
        caseRoundRobinAssigneeList[3].User__c = userList[3].Id;
        caseRoundRobinAssigneeList[3].Case_Round_Robin__c = returnList[1].Id;

        Insert caseRoundRobinAssigneeList;
        
        List<Account> accList=TestUtill.createAccount(1);
        insert accList;
        
        List<Commercial__c> comList=TestUtill.createCommercial(1);
        insert comList;
        
        Entitlement ent=New Entitlement();
        ent.AccountId=accList[0].Id;
        ent.Name='Order support ent.';
        insert ent;
        
        Entitlement entc=New Entitlement();
        entc.AccountId=accList[0].Id;
        entc.Name='case support ent.';
        insert entc;

        
       List<WorkOrder> workList=new List<WorkOrder>();
        WorkOrder work=new WorkOrder();
        work.AccountId=accList[0].Id;
        work.Status='Pending With Bank';
        work.Case_For__c='SC';
        work.EntitlementId=ent.Id; 
        work.Commercial__c=comList[0].id;
        work.Discrepancy__c='We would need the GSTIN details of your business to proceed with this request further.';
        workList.add(work);
        insert workList;
        
        List<Case> ParentCaseList = new List<Case>();
        for(Integer i=0;i<1;i++){
        Case Parentcase = new Case();
        Parentcase.Status='Pending';
        Parentcase.Subject = 'Test 123';
        Parentcase.Work_Order_Status__c='New';
        Parentcase.Registered_Business_Name__c = accList[0].Name;
        Parentcase.Entity_Type__c = 'LLP';
        Parentcase.Merchant_Site_Url__c = 'https://itstu2pro.com/';
        Parentcase.LOB__c = 'E-commerce';
        Parentcase.Website__c = 'https://itstu2pro.com/';
        Parentcase.Entity_Type__c = 'LLP';
        Parentcase.AccountId = accList[0].Id;
        Parentcase.ParentId = null;
        parentCaseId  = Parentcase.Id;

        ParentCaseList.add(Parentcase);
        }
        // ParentCaseList[0].Case_For__c='Risk Team';
        // ParentCaseList[1].Case_For__c='Send to Account Manager';
        // ParentCaseList[1].AccountId =  accList[0].Id;
        // ParentCaseList[1].Subject =  'Test 1234';
        // ParentCaseList[2].Case_For__c='Bank Ops Team';
        ParentCaseList[0].Case_For__c='Onboarding Team';
      
     
        // ParentCaseList[4].Case_For__c='Risk Team';
        Insert ParentCaseList;
        
        List<Case> ChildCaseList = new List<Case>();
        for(integer i=0;i<5;i++){
            Case Childcase=new Case();
            Childcase.Status='New';
            Childcase.Subject = 'Test 123';
            Childcase.Description='Task Succesfully Completed';
            Childcase.ParentId=ParentCaseList[0].Id;
            Childcase.Work_Order_Status__c='New';
            //Childcase.Work_Job__c=workList[0].Id;    
            ChildCaseList.add(Childcase);
        }
        ChildCaseList[0].Case_For__c='Risk Team';
        ChildCaseList[1].Case_For__c='Bank Ops Team';
        ChildCaseList[2].Case_For__c='Bank Ops Team';
        ChildCaseList[3].Case_For__c='Onboarding Team';
        ChildCaseList[4].Case_For__c='Risk Team';
       System.debug('Child Case:::::'+ ChildCaseList[0]);
       System.debug('Child Case:::::'+ ChildCaseList[1]);
       System.debug('Child Case:::::'+ ChildCaseList[2]);
       System.debug('Child Case:::::'+ ChildCaseList[3]);
       System.debug('Child Case:::::'+ ChildCaseList[4]);
        Insert ChildCaseList;
      
        
        
        // List<Task> TaskList=new List<Task>();
        
        // Task Task1=new Task();
        // Task1.Subject='To complete the Task';
        // Task1.Priority='Normal';
        // Task1.WhatId=ParentCaseList[0].Id;
        // Task1.Description='Task Successfully Complted';
        // Task1.Status='open';
        // TaskList.add(Task1);
        
        // Task Task2=new Task();
        // Task2.Subject='To complete the Task';
        // Task2.Priority='Medium';
        // Task2.WhatId=ParentCaseList[0].Id;
        // Task2.Description='Task Successfully Complted';
        // Task2.Status='open';
        // TaskList.add(Task2);
        
        // Task Task3=new Task();
        // Task3.Subject='To complete the Task';
        // Task3.Priority='Normal';
        // Task3.WhatId=ParentCaseList[0].Id;
        // Task3.Description='Task Successfully Complted';
        // Task3.Status='open';
        // TaskList.add(Task3);        
        
        
     }
    
    @isTest
    Public Static Void updateRecordTest1(){
       

        List<WorkOrder> workList=[select Id,status from workOrder Limit 1];
        List<case> ParentCaseList=[select Id,Status, ParentId from Case where Status='Pending' AND Case_For__c = 'Onboarding Team'];
        List<case> ChildCaseList=[select Id,Status,ParentId from Case where Status='New'];
        List<Task> TaskList=[select Subject,WhatId,Status,Priority from Task where WhatId in :ParentCaseList AND Status='Open' AND Priority='Normal'];
        List<Case> childCaseList1=new List<Case>();
        for(Case Case1:childCaseList){
            case1.status='Closed';
            childCaseList1.add(case1);
        }
        
        Test.startTest();
        Update childCaseList1;
        Test.stopTest();
        for(Case caseRec : [select Id,CaseNumber,ParentId,Status,Is_Parent__c from Case]){
            System.debug('Pending:::'+caseRec.CaseNumber+' '+caseRec.ParentId+ ' '+caseRec.Status+ ' '+caseRec.Is_Parent__c);
        }
        for(Case caseRec : [Select Id,CaseNumber, ParentId, Status,Is_Parent__c From Case Where Status = 'Pendency Cleared']){
            System.debug('Pending:::'+ caseRec.CaseNumber+ ' '+caseRec.ParentId+' '+ caseRec.Status);
        }
    }


    @isTest
    public static void updateCaseRecord(){

      


      Profile profileId = [Select Id from Profile Where Name = 'Compulsive' LIMIT 1];
      List<User> userList = TestUtill.createUser(1);
      userList[0].ProfileId = profileId.Id;
      userList[0].Email = 'Onboarding@gmail.com';
      userList[0].UserName = 'onboardingg123@gmail.com';
      Insert userList;


      RecordType recordTypeId = [SELECT SobjectType, Name, DeveloperName, Id, IsActive FROM RecordType Where DeveloperName='Onboarding_Team'];
      List<Case> caseRecord = TestUtill.createCase(4);
      caseRecord[0].RecordTypeId = recordTypeId.Id;
      caseRecord[1].RecordTypeId = recordTypeId.Id;
      caseRecord[2].RecordTypeId = recordTypeId.Id;
      caseRecord[3].RecordTypeId = recordTypeId.Id;

      Test.startTest();
      System.runAs(userList[0]){
       Insert caseRecord;
      }
      Test.stopTest();

      Case result = [Select Id,OwnerId From Case Where Id =: caseRecord[0].Id LIMIT 1];
      // System.debug('Case Owner Id::::'+ result.OwnerId);
      // System.debug('User Id:::::'+ userList[0].Id);
       //System.assertNotEquals(userList[0].Id, result.OwnerId);

    }

}