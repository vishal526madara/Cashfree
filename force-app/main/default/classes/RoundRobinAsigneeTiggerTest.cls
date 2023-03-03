@isTest 
public class RoundRobinAsigneeTiggerTest {
    
    @testSetup 
    public static void makeData(){

        Profile baProfileId = [SELECT Id FROM Profile WHERE Name='Operations - Merchant Onboarding'];

        List<User> userList = TestUtill.createUser(5);

        userList[0].ProfileId = baProfileId.Id;
        userList[1].ProfileId = baProfileId.Id;
        userList[2].ProfileId = baProfileId.Id;
        userList[3].ProfileId =  baProfileId.Id;
        userList[4].ProfileId =  baProfileId.Id;

        Insert userList;

        List<Case_Round_Robin__c> returnList = TestUtill.createCaseRoundRobin(2);
        returnList[0].ProfileName__c = 'B & A Sales';
        returnList[0].Previous_Active_User__c = '6';
        returnList[0].Is_Active__c = true;
        returnList[1].ProfileName__c = 'Compulsive;Inbound';
        returnList[1].Is_Active__c = true;
        Insert returnList;


        List<Case_RoundRobin_Asignee__c> caseRoundRobinAssigneeList = TestUtill.createRoundRobinAssignee(5);
        caseRoundRobinAssigneeList[0].User__c = userList[0].Id;
        caseRoundRobinAssigneeList[0].Case_Round_Robin__c = returnList[0].Id;
        caseRoundRobinAssigneeList[1].User__c = userList[1].Id;
        caseRoundRobinAssigneeList[1].Case_Round_Robin__c = returnList[0].Id;
        caseRoundRobinAssigneeList[2].User__c = userList[2].Id;
        caseRoundRobinAssigneeList[2].Case_Round_Robin__c = returnList[1].Id;
        caseRoundRobinAssigneeList[3].User__c = userList[3].Id;
        caseRoundRobinAssigneeList[3].Case_Round_Robin__c = returnList[1].Id;
        caseRoundRobinAssigneeList[4].User__c = userList[4].Id;
        caseRoundRobinAssigneeList[4].Case_Round_Robin__c = returnList[0].Id;

        Insert caseRoundRobinAssigneeList;

    }

    @isTest 
    static void roundRobinUpdateTest(){
        Case_RoundRobin_Asignee__c roundRobinAsignee = [Select Id, Case_Round_Robin__c,Case_Round_Robin__r.Name, Is_Active__c From Case_RoundRobin_Asignee__c LIMIT 1];
        roundRobinAsignee.Is_Active__c = false;
        Test.startTest();
         Update roundRobinAsignee;
        Test.stopTest();
        System.debug('Round Robin Id:::'+ roundRobinAsignee.Case_Round_Robin__c+'  '+ roundRobinAsignee.Case_Round_Robin__r.Name);
        Case_Round_Robin__c result =  [Select Id, Previous_Active_User__c From Case_Round_Robin__c Where Id =: roundRobinAsignee.Case_Round_Robin__c LIMIT 1];
       
        System.assertEquals(2, Integer.valueOf(result.Previous_Active_User__c));
       
     }

   
}