@istest
public class CaseRoundRobinHandlerTest {
@testsetup
    public static void createdata(){
        
        List<User> returnList1 = TestUtill.createUser(1);        
        insert returnList1;
        
       
        Case caseList = new case();
        caseList.Status = 'Open';
        caseList.Origin = 'Email';
        insert caseList;
        
        List<Case_RoundRobin_Asignee__c> returnList3 = TestUtill.createRounRobinAssignee(1);
        insert returnList3;
        
        List<Case_Round_Robin__c> returnList = TestUtill.createCaseRoundRobin(2);
        returnList[0].ProfileName__c = 'System Administrator';
        insert returnList;
        
    }
@istest
    public static void vroundRobinAssignment_Test(){
        list<case> cs = [select id,ParentId,Work_Job__c,CreatedById from case where Origin = 'Email' limit 1]; 
        Profile p = [SELECT Id FROM Profile WHERE Name='system administrator'];
        list<User> us = [SELECT Id,Profile.Name,ProfileId FROM User limit 1];
        us[0].ProfileId= p.Id;
        update us;
        
        test.startTest();
        CaseRoundRobinHandler.roundRobinAssignment(cs);
        test.stopTest();
    }    
    
    @istest
    public static void vroundRobinAssignment_Test1(){
        list<case> cs = [select id,ParentId,Work_Job__c,CreatedById from case where Origin = 'Email' limit 1]; 
        List<Case_Round_Robin__c> returnList = [select id,ProfileName__c from Case_Round_Robin__c];
        returnList[1].ProfileName__c = 'Compulsive;Utility';

        update returnList;
       /* System.runAs(u2){
            
        }*/
        test.startTest();
        CaseRoundRobinHandler.roundRobinAssignment(cs);
        
        test.stopTest();
        
    }    
}