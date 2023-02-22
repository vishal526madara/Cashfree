@isTest
public class GetLastInboundLead_Test {
  @testSetup
  public static void makeData() {
    //create user records
    List<User> createUsers = TestUtill.createUser(3);
    insert createUsers;

    //create round robin records
    List<Round_Robin__c> createRoundRobin = TestUtill.createRoundRobin(1);
    insert createRoundRobin;

    //create round robin assignee records
    List<Round_Robin_Assignee__c> createAssigness = TestUtill.createRoundRobinAssignee(
      3,
      createRoundRobin[0].Id
    );
    for (Integer i = 0; i < 3; i++) {
      createAssigness[i].User__c = createUsers[i].Id;
      createAssigness[i].Name = createUsers[i].Name;
    }
    insert createAssigness;

    List<Lead> createLeads = TestUtill.createLead(1);
    createLeads[0].LeadSource = 'Inbound';
    //createLeads[0].Lead_Type__c = 'Payment Forms';
    createLeads[0].Lead_Order_Number__c = 1;
    createLeads[0].Previous_Lead_Owner__c = createUsers[0].Id;
    createLeads[0].Email = 'TestInbound-PF@test.com';
    insert createLeads;
  }

  //no previous leads exist
  @isTest
  public static void getLastLeadTest() {
    Test.startTest();
    List<Lead> getLeads = [SELECT Id FROM Lead];
    delete getLeads;

    List<Round_Robin_Assignee__c> getAssignees = [
      SELECT Id, Order_Number__c, User__c
      FROM Round_Robin_Assignee__c
      WHERE Order_Number__c = 1
      LIMIT 1
    ];

    List<Lead> createLeads = TestUtill.createLead(1);
    createLeads[0].LeadSource = 'Inbound';
    //createLeads[0].Lead_Type__c = 'Web';
    createLeads[0].Company = 'Company 1';
    createLeads[0].LastName = 'Last Name 1';
    createLeads[0].Email = 'TestCompany1@test.com';
    insert createLeads;

    createLeads[0].Phone = '5738291829';
    update createLeads;

    String leadId = createLeads[0].Id;

    Test.stopTest();
    List<Lead> getInsertedLeads = [
      SELECT Id, OwnerId
      FROM Lead
      WHERE Id = :leadId
      LIMIT 1
    ];
    System.assertEquals(getAssignees[0].User__c, getInsertedLeads[0].OwnerId);
  }

  //previous inbound lead exists
  @isTest
  public static void getLastLeadTest2() {
    Test.startTest();

    List<Round_Robin_Assignee__c> getAssignees = [
      SELECT Id, Order_Number__c, User__c
      FROM Round_Robin_Assignee__c
      WHERE Order_Number__c = 2
      LIMIT 1
    ];

    List<Lead> createLeads = TestUtill.createLead(1);
    createLeads[0].LeadSource = 'Inbound';
    //createLeads[0].Lead_Type__c = 'Intercom';
    createLeads[0].Company = 'Company Inbound-Intercom';
    createLeads[0].LastName = 'Last Name Inbound-Intercom';
    createLeads[0].Email = 'TestInbound-Intercom@test.com';

    insert createLeads;

    createLeads[0].Phone = '7382101829';
    update createLeads;

    String leadId = createLeads[0].Id;
    Test.stopTest();
    List<Lead> getInsertedLeads = [
      SELECT Id, OwnerId
      FROM Lead
      WHERE Id = :leadId
      LIMIT 1
    ];
    System.debug('getInsertedLeads: ' + getInsertedLeads);
    System.assertEquals(getAssignees[0].User__c, getInsertedLeads[0].OwnerId);
  }

  //if next user is deactivated
  @isTest
  public static void getLastLeadTest3() {
    Test.startTest();
    List<Lead> getLeads = [SELECT Id, Previous_Lead_Owner__c FROM Lead LIMIT 1];
    //get the previous owner order number
    List<Round_Robin_Assignee__c> getAssignees = [
      SELECT Id, Order_Number__c, User__c
      FROM Round_Robin_Assignee__c
      WHERE User__c = :getLeads[0].Previous_Lead_Owner__c
      LIMIT 1
    ];

    //getAssignees[0].Is_Active__c = false;

    //find the next owner order number
    Integer assigneeNumber =
      Integer.valueOf(getAssignees[0].Order_Number__c) + 1;

    List<Round_Robin_Assignee__c> getNextAssignees = [
      SELECT Id, Order_Number__c, User__c
      FROM Round_Robin_Assignee__c
      WHERE Order_Number__c = :assigneeNumber
      LIMIT 1
    ];
    getNextAssignees[0].Is_Active__c = false;
    update getNextAssignees;

    //get the new order number owner after deactivation
    List<Round_Robin_Assignee__c> getActualAssignees = [
      SELECT Id, Order_Number__c, User__c
      FROM Round_Robin_Assignee__c
      WHERE Order_Number__c = :assigneeNumber
      LIMIT 1
    ];

    List<Lead> createLeads = TestUtill.createLead(1);
    createLeads[0].LeadSource = 'Inbound';
    //createLeads[0].Lead_Type__c = 'Web';
    createLeads[0].Company = 'Company Inbound-Web';
    createLeads[0].LastName = 'Last Name Inbound-Web';
    createLeads[0].Email = 'TestInbound-Web@test.com';

    insert createLeads;

    createLeads[0].Phone = '4738291829';
    update createLeads;

    String leadId = createLeads[0].Id;
    Test.stopTest();
    List<Lead> getInsertedLeads = [
      SELECT Id, OwnerId
      FROM Lead
      WHERE Id = :leadId
      LIMIT 1
    ];
    System.debug('getInsertedLeads: ' + getInsertedLeads);
    System.assertEquals(
      getActualAssignees[0].User__c,
      getInsertedLeads[0].OwnerId
    );
  }
}
