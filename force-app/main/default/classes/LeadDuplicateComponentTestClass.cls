/**
 * @description       : LeadDuplicateComponentTestClass for LeadDuplicateComponentController
 * @author            : Saurav Kashyap
 * @group             : Self Group
 * @last modified on  : 10-14-2022
 **/
@isTest
public class LeadDuplicateComponentTestClass {
  //creating a temporary DB
  @testSetup
  static void makeData() {
    //structure data from test.utils
    List<Lead> lead = TestUtill.createLead(2);
    lead[0].Budget_Confirmed__c = true;
    lead[0].Lead_Type__c = null;
    lead[0].Decision_Maker__c = true;
    lead[0].MobilePhone = '435354367';
    lead[0].Time_Frame__c = 'One Month';

    lead[1].Budget_Confirmed__c = true;
    lead[1].Decision_Maker__c = true;
    lead[1].Lead_Type__c = null;
    lead[1].MobilePhone = '435354356';
    lead[1].Time_Frame__c = 'One Month';
    insert lead;
  }
  @isTest
  static void getLeadRecords_Test() {
    //querying data from Temporary DB
    List<Lead> lead = [
      SELECT Id, LastName, MobilePhone, Email, CreatedDate
      FROM Lead
    ];
    //creating an object instance of lead
    List<Lead> leadList = new List<Lead>();
    //startTest and StopTest Method Implementation
    Test.startTest();
    leadList = LeadDuplicateComponentController.getLeadRecords(lead[0].Id);
    Test.stopTest();
    // Checking the output using assert method
    System.assert(leadList != null);
  }
}
