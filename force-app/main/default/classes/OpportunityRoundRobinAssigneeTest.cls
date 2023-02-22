@isTest
public class OpportunityRoundRobinAssigneeTest {


    @testSetup
    static void makeData(){
        List<User> userList = TestUtill.createUser(9);
        Insert userList;
        List<Opportunity_Round_Robin__c> oppRRList = TestUtill.createOpportunityRoundRobin(3);
        oppRRList[0].Lead_Type__c = 'Inbound';
        oppRRList[0].Lead_Source__c = 'Intercom;Web';
        oppRRList[0].Active_Field__c = 'Lead_Type__c,Lead_Source__c';

        oppRRList[1].Lead_Type__c = 'Outbound';
        oppRRList[1].Active_Field__c = 'Lead_Type__c';

        oppRRList[2].Lead_Type__c = 'Partner';
        oppRRList[2].Active_Field__c = 'Lead_Type__c';

        Insert oppRRList;
        
        List<Opportunity_Round_Robin_Assignee__c> oppRRAList = TestUtill.createOpportunityRoundRobinAssignee(9);
        oppRRAList[0].Name = 'Test User 1';
        oppRRAList[0].User__c = userList[0].Id;
        oppRRAList[0].Is_Active__c = true;
        oppRRAList[0].Opportunity_Round_Robin__c = oppRRList[0].Id;

        oppRRAList[1].Name = 'Test User 2';
        oppRRAList[1].User__c = userList[1].Id;
        oppRRAList[1].Is_Active__c = true;
        oppRRAList[1].Opportunity_Round_Robin__c = oppRRList[0].Id;

        oppRRAList[2].Name = 'Test User 3';
        oppRRAList[2].User__c = userList[2].Id;
        oppRRAList[2].Is_Active__c = true;
        oppRRAList[2].Opportunity_Round_Robin__c = oppRRList[0].Id;


        oppRRAList[3].Name = 'Test User 4';
        oppRRAList[3].User__c = userList[3].Id;
        oppRRAList[3].Is_Active__c = true;
        oppRRAList[3].Opportunity_Round_Robin__c = oppRRList[1].Id;


        oppRRAList[4].Name = 'Test User 5';
        oppRRAList[4].User__c = userList[4].Id;
        oppRRAList[4].Is_Active__c = true;
        oppRRAList[4].Opportunity_Round_Robin__c = oppRRList[1].Id;


        oppRRAList[5].Name = 'Test User 6';
        oppRRAList[5].User__c = userList[5].Id;
        oppRRAList[5].Is_Active__c = true;
        oppRRAList[5].Opportunity_Round_Robin__c = oppRRList[1].Id;

        oppRRAList[6].Name = 'Test User 7';
        oppRRAList[6].User__c = userList[6].Id;
        oppRRAList[6].Is_Active__c = true;
        oppRRAList[6].Opportunity_Round_Robin__c = oppRRList[2].Id;

        oppRRAList[7].Name = 'Test User 8';
        oppRRAList[7].User__c = userList[7].Id;
        oppRRAList[7].Is_Active__c = true;
        oppRRAList[7].Opportunity_Round_Robin__c = oppRRList[2].Id;

        oppRRAList[8].Name = 'Test User 9';
        oppRRAList[8].User__c = userList[8].Id;
        oppRRAList[8].Is_Active__c = true;
        oppRRAList[8].Opportunity_Round_Robin__c = oppRRList[2].Id;

        
        Insert oppRRAList;
        
    }
  

    @isTest 
    static void insertTest(){
        List<User> userList = TestUtill.createUser(9);
        Insert userList;
        List<Opportunity_Round_Robin__c> oppRRList = TestUtill.createOpportunityRoundRobin(3);
        oppRRList[0].Lead_Type__c = 'Inbound';
        oppRRList[0].Lead_Source__c = 'Intercom;Web';
        oppRRList[0].Active_Field__c = 'Lead_Type__c,Lead_Source__c';

        oppRRList[1].Lead_Type__c = 'Outbound';
        oppRRList[1].Active_Field__c = 'Lead_Type__c';

        oppRRList[2].Lead_Type__c = 'Partner';
        oppRRList[2].Active_Field__c = 'Lead_Type__c';

        Insert oppRRList;
        
        List<Opportunity_Round_Robin_Assignee__c> oppRRAList = TestUtill.createOpportunityRoundRobinAssignee(9);
        oppRRAList[0].Name = 'Test User 1';
        oppRRAList[0].User__c = userList[0].Id;
        oppRRAList[0].Is_Active__c = true;
        oppRRAList[0].Opportunity_Round_Robin__c = oppRRList[0].Id;

        oppRRAList[1].Name = 'Test User 2';
        oppRRAList[1].User__c = userList[1].Id;
        oppRRAList[1].Is_Active__c = true;
        oppRRAList[1].Opportunity_Round_Robin__c = oppRRList[0].Id;

        oppRRAList[2].Name = 'Test User 3';
        oppRRAList[2].User__c = userList[2].Id;
        oppRRAList[2].Is_Active__c = true;
        oppRRAList[2].Opportunity_Round_Robin__c = oppRRList[0].Id;


        oppRRAList[3].Name = 'Test User 4';
        oppRRAList[3].User__c = userList[3].Id;
        oppRRAList[3].Is_Active__c = true;
        oppRRAList[3].Opportunity_Round_Robin__c = oppRRList[1].Id;


        oppRRAList[4].Name = 'Test User 5';
        oppRRAList[4].User__c = userList[4].Id;
        oppRRAList[4].Is_Active__c = true;
        oppRRAList[4].Opportunity_Round_Robin__c = oppRRList[1].Id;


        oppRRAList[5].Name = 'Test User 6';
        oppRRAList[5].User__c = userList[5].Id;
        oppRRAList[5].Is_Active__c = true;
        oppRRAList[5].Opportunity_Round_Robin__c = oppRRList[1].Id;

        oppRRAList[6].Name = 'Test User 7';
        oppRRAList[6].User__c = userList[6].Id;
        oppRRAList[6].Is_Active__c = true;
        oppRRAList[6].Opportunity_Round_Robin__c = oppRRList[2].Id;

        oppRRAList[7].Name = 'Test User 8';
        oppRRAList[7].User__c = userList[7].Id;
        oppRRAList[7].Is_Active__c = true;
        oppRRAList[7].Opportunity_Round_Robin__c = oppRRList[2].Id;

        oppRRAList[8].Name = 'Test User 9';
        oppRRAList[8].User__c = userList[8].Id;
        oppRRAList[8].Is_Active__c = true;
        oppRRAList[8].Opportunity_Round_Robin__c = oppRRList[2].Id;

        Test.startTest();
        Insert oppRRAList;
        Test.stopTest();

        List<Opportunity_Round_Robin_Assignee__c> result = [Select Id From Opportunity_Round_Robin_Assignee__c];
        System.assertEquals(18, result.size());
    }


    @isTest 
    static void updateTest(){
        Opportunity_Round_Robin_Assignee__c updateRecord = [Select Id,Opportunity_Round_Robin__c,Is_Active__c From Opportunity_Round_Robin_Assignee__c LIMIT 1];
        updateRecord.Is_Active__c = false;
        Test.startTest();
        Update updateRecord;
        Test.stopTest();
        List<Opportunity_Round_Robin_Assignee__c> result = [Select Id,Order_Number__c From Opportunity_Round_Robin_Assignee__c Where Opportunity_Round_Robin__c =: updateRecord.Opportunity_Round_Robin__c Order By Order_Number__c ASC];
         System.assertEquals(null, result[0].Order_Number__c);
    }
}