/**
 * @description       : LeadScoringControllerTest{}
 * @author            : Saurav Kashyap
 * @group             : Appstrail
 * @last modified on  : 10-19-2022
 **/
@isTest
public with sharing class LeadScoringControllerTest {
  //Creating TestData In The Temporary Sfdc-DB
  @TestSetup
  static void makeData() {
    //Lead Record Creation
    List<Lead> leadList = new List<Lead>();
    for (Integer i = 0; i < 4; i++) {
      Lead ld = new Lead();
      ld.LastName = 'leadTest' + i;
      ld.Status = 'New';
      ld.Lead_Type__c = 'Outbound';
      ld.LeadSource = 'Outbound';
      ld.Company = 'TestCompany' + i;
      ld.Campaign_Type__c = 'Paid';
      ld.Campaign_Sub_type__c = 'Google Search';
      ld.UTM_Campaign__c = 'Google Search';
      ld.Action_Type__c = 'Contact Sales';
      ld.Website = 'www.axel.com';
      leadList.add(ld);
    }
    if (leadList.size() > 0) {
      //Insertion of lead records
      insert leadList;
    }
  }

  //Method For Positive Scenario
  @isTest
  public static void getLeadDetails_PositiveTest() {
    //Create Object/Instance of Lead
    List<Lead> leadList = new List<Lead>();
    //Query the data created in temporary Sfdc-DB
    leadList = [
      SELECT
        Id,
        LeadSource,
        Status,
        Company,
        Campaign_Type__c,
        Campaign_Sub_type__c,
        Action_Type__c,
        Website,
        LastName,
        Lead_Type__c
      FROM Lead
    ];

    //Create The Wrapper Instance to take the return type value from the parent controller to the test class
    LeadScoringController.leadWrapper leadWrapper = new LeadScoringController.leadWrapper();
    //Test Start and Stop Methods
    Test.startTest();
    //Passing the Lead Id Having all the Required value needed by the standard controller
    leadWrapper = LeadScoringController.getLeadDetails(leadList[0].Id);
    Test.stopTest();

    //Syatem Check using Assertion Method
    System.Assert(leadWrapper != null);
  }

  //Method For Negative Scenario
  @isTest
  public static void getLeadDetails_NegativeTest() {
    //Create a dummy Data
    Lead ld = new Lead();
    ld.LastName = 'leadTest';
    ld.Status = 'New';
    //ld.Lead_Type__c ='Inbound';
    ld.Company = 'TestCompany';
    //ld.Campaign_Type__c = 'Paid';
    ld.Campaign_Sub_type__c = null;
    ld.Action_Type__c = null;
    ld.Website = null;
    insert ld;

    //Create The Wrapper Instance to take the return type value from the parent controller to the test class
    LeadScoringController.leadWrapper leadWrapper = new LeadScoringController.leadWrapper();
    //Test Start and Stop Methods
    Test.startTest();
    //Passing the Lead Id Having Required value needed by the standard controller Null For Worst Case Scenario
    leadWrapper = LeadScoringController.getLeadDetails(ld.Id);
    Test.stopTest();

    //Syatem Check using Assertion Method
    System.Assert(leadWrapper != null);
  }

  @isTest
  public static void getLeadDetails_NegativeTest2() {
    //Create a dummy Data
    Lead ld = new Lead();
    ld.LastName = 'leadTest';
    ld.Status = 'New';
    ld.Lead_Type__c = 'Coverage';
    ld.LeadSource = 'Coverage';
    ld.Company = 'TestCompany';
    ld.Campaign_Type__c = 'Coverage';
    ld.UTM_Campaign__c = 'Coverage';
    ld.Action_Type__c = 'Coverage';
    //ld.Campaign_Sub_type__c ='Coverage';
    ld.Website = 'wwwgooglecom';
    insert ld;

    //Create The Wrapper Instance to take the return type value from the parent controller to the test class
    LeadScoringController.leadWrapper leadWrapper = new LeadScoringController.leadWrapper();
    //Test Start and Stop Methods
    Test.startTest();
    //Passing the Lead Id Having Required value needed by the standard controller Null For Worst Case Scenario
    leadWrapper = LeadScoringController.getLeadDetails(ld.Id);
    Test.stopTest();

    //Syatem Check using Assertion Method
    System.Assert(leadWrapper != null);
  }
}
