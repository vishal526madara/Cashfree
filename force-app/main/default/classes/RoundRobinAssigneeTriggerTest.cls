@isTest
public with sharing class RoundRobinAssigneeTriggerTest {
    @testSetup
    static void makeData(){
        List<User> userList = TestUtill.createUser(13);
        Insert userList;
        
        List<Round_Robin__c> roundRobinList = TestUtill.createIndividualRoundRobin(3);
        roundRobinList[0].Lead_Type__c = 'Inbound';
        roundRobinList[0].Lead_Source__c = 'Intercom;Web';
        roundRobinList[0].On_Duty__c = Time.newInstance(6, 15, 00, 0000);
        roundRobinList[0].Off_Duty__c = Time.newInstance(22,15,00,000);
        roundRobinList[0].Is_Active__c = true;
        roundRobinList[0].Previous_Active_User__c = '1';


        roundRobinList[1].Lead_Type__c = 'Banking Alliance';
        roundRobinList[1].Lead_Source__c = 'Partners';
        roundRobinList[1].On_Duty__c = Time.newInstance(6, 15, 00, 0000);
        roundRobinList[1].Off_Duty__c = Time.newInstance(22,15,00,000);
        roundRobinList[1].Is_Active__c = true;
        roundRobinList[1].Previous_Active_User__c = '2';


        roundRobinList[2].Lead_Type__c = 'Partner';
        roundRobinList[2].Lead_Source__c = 'BAAS;Partners';
        roundRobinList[2].On_Duty__c = Time.newInstance(6, 15, 00, 0000);
        roundRobinList[2].Off_Duty__c = Time.newInstance(22,15,00,000);
        roundRobinList[2].Is_Active__c = true;
        roundRobinList[2].Previous_Active_User__c = '3';
        Insert roundRobinList;
       
        List<Round_Robin_Assignee__c> roundRobinAssigneeList = TestUtill.createRounRobinAssignee(9);
        roundRobinAssigneeList[0].Is_Active__c = true;
        roundRobinAssigneeList[0].Order_Number__c = 1;
        roundRobinAssigneeList[0].Round_Robin__c = roundRobinList[0].Id;
        roundRobinAssigneeList[0].User__c = userList[0].Id;

        roundRobinAssigneeList[1].Is_Active__c = true;
        roundRobinAssigneeList[1].Round_Robin__c = roundRobinList[0].Id;
        roundRobinAssigneeList[1].User__c = userList[1].Id;
        roundRobinAssigneeList[1].Order_Number__c = 2;

        roundRobinAssigneeList[2].Is_Active__c = true;
        roundRobinAssigneeList[2].Round_Robin__c = roundRobinList[0].Id;
        roundRobinAssigneeList[2].User__c = userList[2].Id;
        roundRobinAssigneeList[2].Order_Number__c = 3;


        roundRobinAssigneeList[3].Is_Active__c = true;
        roundRobinAssigneeList[3].Round_Robin__c = roundRobinList[1].Id;
        roundRobinAssigneeList[3].User__c = userList[3].Id;
        roundRobinAssigneeList[3].Order_Number__c = 1;


        roundRobinAssigneeList[4].Is_Active__c = true;
        roundRobinAssigneeList[4].Round_Robin__c = roundRobinList[1].Id;
        roundRobinAssigneeList[4].User__c = userList[4].Id;
        roundRobinAssigneeList[4].Order_Number__c = 2;


        roundRobinAssigneeList[5].Is_Active__c = true;
        roundRobinAssigneeList[5].Round_Robin__c = roundRobinList[1].Id;
        roundRobinAssigneeList[5].User__c = userList[5].Id;
        roundRobinAssigneeList[5].Order_Number__c = 3;

        roundRobinAssigneeList[6].Is_Active__c = true;
        roundRobinAssigneeList[6].Round_Robin__c = roundRobinList[2].Id;
        roundRobinAssigneeList[6].User__c = userList[6].Id;
        roundRobinAssigneeList[6].Order_Number__c = 1;



        roundRobinAssigneeList[7].Is_Active__c = true;
        roundRobinAssigneeList[7].Round_Robin__c = roundRobinList[2].Id;
        roundRobinAssigneeList[7].User__c = userList[7].Id;
        roundRobinAssigneeList[7].Order_Number__c = 2;


        roundRobinAssigneeList[8].Is_Active__c = true;
        roundRobinAssigneeList[8].Round_Robin__c = roundRobinList[2].Id;
        roundRobinAssigneeList[8].User__c = userList[8].Id;
        roundRobinAssigneeList[8].Order_Number__c = 3; 

        Insert roundRobinAssigneeList;
    }

    @isTest  
    static void roundRobinAssigneeTest(){
      Round_Robin__c roundRobinRecord = [Select Id From Round_Robin__c Where Previous_Active_User__c = '3' LIMIT 1];
      List<Round_Robin_Assignee__c> roundRobinAssigneeList = [Select Id,Is_Active__c From Round_Robin_Assignee__c Where Round_Robin__c =: roundRobinRecord.Id Order BY Order_Number__c];
      roundRobinAssigneeList[2].Is_Active__c = false;
      Test.startTest();
      Update roundRobinAssigneeList[2];
      Test.stopTest();
      Round_Robin__c updateRecord = [Select Id,Previous_Active_User__c From Round_Robin__c Where Id =: roundRobinRecord.Id];
      System.debug('Value::: 2 :::'+ updateRecord.Previous_Active_User__c);
        System.assertEquals('3', updateRecord.Previous_Active_User__c);
    }

    @isTest 
    static void roundRobinAssigneeTest1(){
     Round_Robin__c roundRobinRecord = [Select Id,Previous_Active_User__c From Round_Robin__c Where Previous_Active_User__c = '3' LIMIT 1];
     List<User> userList = [Select Id From User Where Name Like '%Test%' Order By CreatedDate];
     List<Round_Robin_Assignee__c> roundRobinAssigneeList = TestUtill.createRounRobinAssignee(4);
     roundRobinAssigneeList[0].Is_Active__c = true;
     roundRobinAssigneeList[0].Round_Robin__c = roundRobinRecord.Id;
     roundRobinAssigneeList[0].User__c = userList[9].Id;
    //  roundRobinAssigneeList[0].Order_Number__c = 4; 

     roundRobinAssigneeList[1].Is_Active__c = true;
     roundRobinAssigneeList[1].Round_Robin__c = roundRobinRecord.Id;
     roundRobinAssigneeList[1].User__c = userList[10].Id;
    //  roundRobinAssigneeList[1].Order_Number__c = 5; 


     roundRobinAssigneeList[2].Is_Active__c = true;
     roundRobinAssigneeList[2].Round_Robin__c = roundRobinRecord.Id;
     roundRobinAssigneeList[2].User__c = userList[11].Id;
    //  roundRobinAssigneeList[2].Order_Number__c = 6; 

     roundRobinAssigneeList[3].Is_Active__c = true;
     roundRobinAssigneeList[3].Round_Robin__c = roundRobinRecord.Id;
     roundRobinAssigneeList[3].User__c = userList[12].Id;
    //  roundRobinAssigneeList[3].Order_Number__c = 7; 

     Insert roundRobinAssigneeList;

     roundRobinRecord.Previous_Active_User__c = '5';
     Update roundRobinRecord;

     List<Round_Robin_Assignee__c> updateRoundRobinAssigneeList = [Select Id,Is_Active__c From Round_Robin_Assignee__c Order By Order_Number__c];
     updateRoundRobinAssigneeList[2].Is_Active__c = false;
     updateRoundRobinAssigneeList[3].Is_Active__c = false;

     Test.startTest();
      Update updateRoundRobinAssigneeList;
     Test.stopTest();
     Round_Robin__c updateRecord = [Select Id,Previous_Active_User__c From Round_Robin__c Where Id =: roundRobinRecord.Id];
     System.debug('Value::: 1 :::'+ updateRecord.Previous_Active_User__c);
    System.assertEquals('5', updateRecord.Previous_Active_User__c);
    }
}