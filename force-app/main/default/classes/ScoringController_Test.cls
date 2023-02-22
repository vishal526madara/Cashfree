@isTest
public class ScoringController_Test {
    
    @testSetup
    static void makeData(){
        List<Lead> lead = TestUtill.createLead(1);
        lead[0].Budget_Confirmed__c = true;
        lead[0].Decision_Maker__c = true;
        lead[0].Time_Frame__c = 'One Month';
        Insert lead;
        List<Opportunity> opportunity = TestUtill.createOpportunity(1);
        Insert opportunity;
    }
    
    @isTest
    static void getScore_Test_1(){
        Lead  lead = [Select Id From Lead LIMIT 1];
        Test.startTest();
        ScoringController.DataWrapper result = ScoringController.getScore(lead.Id);
        Test.stopTest();
        System.assert(result != null);
    }
    
    @isTest
    static void getScore_Test_2(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        Test.startTest();
        ScoringController.DataWrapper result = ScoringController.getScore(opp.Id);
        Test.stopTest();
        System.assert(result != null);
    }
    
    @isTest
    static void getScore_Test_3(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        Event event = new Event();
        event.WhatId = opp.Id;
        event.Subject = 'Test Subject';
        event.StartDateTime = System.today() + 2;
        event.EndDateTime = System.today() + 6;
        Insert event;
        Test.startTest();
        ScoringController.DataWrapper result = ScoringController.getScore(opp.Id);
        Test.stopTest();
        System.assert(result != null);
    }
    
    @isTest
    static void getScore_Test_4(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        
        Task task = new Task();
        task.WhatId = opp.Id;
        task.Subject = 'Test Subject';
        task.ActivityDate = System.today() + 3;
        Insert task;
        
        Test.startTest();
        ScoringController.DataWrapper result = ScoringController.getScore(opp.Id);
        Test.stopTest();
        System.assert(result != null);
    }
    
    @isTest
    static void getScore_Test_5(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        
        Event event = new Event();
        event.WhatId = opp.Id;
        event.Subject = 'Test Subject';
        event.StartDateTime = System.today() + 2;
        event.EndDateTime = System.today() + 6;
        Insert event;
        
        Task task = new Task();
        task.WhatId = opp.Id;
        task.Subject = 'Test Subject';
        task.ActivityDate = System.today() + 3;
        Insert task;
        
        Test.startTest();
        ScoringController.DataWrapper result = ScoringController.getScore(opp.Id);
        Test.stopTest();
       System.assert(result != null);
    }
    
    @isTest
    static void getScore_Test_6(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        
        Event event = new Event();
        event.WhatId = opp.Id;
        event.Subject = 'Test Subject';
        event.StartDateTime = System.today() + 2;
        event.EndDateTime = System.today() + 6;
        Insert event;
        Test.setCreatedDate(event.Id, System.today() + 2);
        
        Task task = new Task();
        task.WhatId = opp.Id;
        task.Subject = 'Test Subject';
        task.ActivityDate = System.today() + 3;
        Insert task;
        Test.setCreatedDate(task.Id, System.today() - 2);
        
        Test.startTest();
        ScoringController.DataWrapper result = ScoringController.getScore(opp.Id);
        Test.stopTest();
       System.assert(result != null);
    }

    
    @isTest
    static void getScore_Test_7(){
        Opportunity opp = [Select Id From Opportunity LIMIT 1];
        
        Event event = new Event();
        event.WhatId = opp.Id;
        event.Subject = 'Test Subject';
        event.StartDateTime = System.today() + 2;
        event.EndDateTime = System.today() + 6;
        Insert event;
        Test.setCreatedDate(event.Id, System.today() - 2);
        
        Task task = new Task();
        task.WhatId = opp.Id;
        task.Subject = 'Test Subject';
        task.ActivityDate = System.today() + 3;
        Insert task;
        Test.setCreatedDate(task.Id, System.today() + 2);
        
        
        Test.startTest();
        ScoringController.DataWrapper result = ScoringController.getScore(opp.Id);
        Test.stopTest();
        System.assert(result != null);
    }

}