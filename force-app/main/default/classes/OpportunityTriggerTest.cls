@isTest
public class OpportunityTriggerTest {
   
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

         List<Lead> leadList = TestUtill.createLead(10);
         for(Integer i=0; i<leadList.size(); i++){
            leadList[i].Industry = 'Education';
            leadList[i].Sub_Lob__c = 'Correspondence Schools';
            if(Math.mod(i, 3) == 0){
                leadList[i].LeadSource = 'Inbound';
                leadList[i].Lead_Type__c = 'Intercom';
                leadList[i].Company = 'Inbound Company';

            }else if(Math.mod(i, 3) == 1){
                leadList[i].leadSource = 'Outbound';
                leadList[i].Lead_Type__c = 'Outbound';
                leadList[i].Company = 'Outbound Company';

            }else{
                leadList[i].LeadSource = 'Partner';
                leadList[i].Lead_Type__c = 'Partners';
                leadList[i].Company = 'Partner Company';
            }
         }

         Insert leadList;
    }

    @isTest
    static void createCaseTeamMemberTest(){
        
       List<User> userList = [Select Id, Name From User Where Name LIKE '%Test 1%' LIMIT 1];
        System.debug('User Name::::'+ userList[0].Name);

        for(User userRecord : [Select Id, Name From User ]){
          System.debug('User Name::::'+ userRecord.Name);
        }
   
        
        List<opportunity> opp=TestUtill.createOpportunity(1);
        opp[0].OwnerId=userList[0].Id;
        Insert opp;
        
        Id recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Onboarding_Team').getRecordTypeId();
        List<case> caseList =TestUtill.createCase(1);
        caseList[0].Opportunity__c=opp[0].Id;
        caseList[0].RecordTypeId=recordTypeId;
        Insert caseList;
        
        opp[0].OwnerId=userList[0].Id;

        Test.startTest();
        Update opp;
        Test.stopTest(); 
        
    }

   


    @isTest 
    static void newOpportunityTest(){
        List<Opportunity> opportunityList = TestUtill.createOpportunity(9);
        for(Integer i=0; i<opportunityList.size(); i++){
            opportunityList[i].Converted_from_Lead__c = true;
            if(Math.mod(i, 3) == 0){
            System.debug('Condition True HH');
             opportunityList[i].LeadSource = 'Inbound';
             opportunityList[i].Opportunity_Type__c = 'Intercom';
            }else if(Math.mod(i,3) == 1){
                 opportunityList[i].LeadSource = 'Outbound';
                //opportunityList[i].Opportunity_Type__c = 'Outbound';
            }else if(Math.mod(i,3) == 2){
                opportunityList[i].LeadSource = 'Partner';
                //opportunityList[i].Opportunity_Type__c = 'Partner';
            }
        }
        Test.startTest();
        Insert opportunityList;
        Test.stopTest();
        for(Opportunity_Round_Robin__c result : [Select Id,Name,Previous_Active_User__c From Opportunity_Round_Robin__c Order By CreatedDate DESC]){
            System.assertEquals('3', result.Previous_Active_User__c);
        }
    }


    @isTest 
    static void withoutConditionTest(){
        List<Opportunity> oppList = TestUtill.createOpportunity(11);
        for(Opportunity opp : oppList){
            opp.Converted_from_Lead__c = true;
            opp.LeadSource = null;
        }
        Test.startTest();
        Insert oppList;
        Test.stopTest();
        for(Opportunity_Round_Robin__c result : [Select Id,Previous_Active_User__c From Opportunity_Round_Robin__c]){
            System.assertEquals(null, result.Previous_Active_User__c);
        }
    }
   
}