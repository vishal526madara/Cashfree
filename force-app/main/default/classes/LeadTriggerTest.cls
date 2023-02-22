@isTest
public class LeadTriggerTest {
  @testSetup
  static void makeData() {
    List<Campaign> campaignList = TestUtill.createCampaign(4);
    insert campaignList;
    List<User> userList = TestUtill.createUser(10);
    insert userList;
    List<Account> testAccount = TestUtill.createAccount(1);
    insert testAccount;
    List<Cashfree_Document_Master__c> docMasterList = TestUtill.createcashfreedoc(
      3
    );
    docMasterList[0].KYC_Category__c = 'Regular';
    docMasterList[0].Name = 'Public Limited';

    docMasterList[1].KYC_Category__c = 'Regular';
    docMasterList[1].Name = 'Private Limited';

    docMasterList[2].KYC_Category__c = 'LOB';
    docMasterList[2].Name = 'Government';

    insert docMasterList;

    List<Document_Type__c> docTypeList = TestUtill.createdocumenttype(7);
    docTypeList[0].Cashfree_Document_Master__c = docMasterList[2].Id;
    docTypeList[0].Name = 'Document';

    docTypeList[1].Cashfree_Document_Master__c = docMasterList[0].Id;
    docTypeList[1].Name = 'Business Registration';

    docTypeList[2].Cashfree_Document_Master__c = docMasterList[0].Id;
    docTypeList[2].Name = 'Company PAN';

    docTypeList[3].Cashfree_Document_Master__c = docMasterList[0].Id;
    docTypeList[3].Name = 'Director/ Owner\'s PAN';

    docTypeList[4].Cashfree_Document_Master__c = docMasterList[1].Id;
    docTypeList[4].Name = 'Business Registration';

    docTypeList[5].Cashfree_Document_Master__c = docMasterList[1].Id;
    docTypeList[5].Name = 'Company PAN';

    docTypeList[6].Cashfree_Document_Master__c = docMasterList[1].Id;
    docTypeList[6].Name = 'Director/ Owner\'s PAN';

    insert docTypeList;

    List<Document_List__c> docList = TestUtill.createdocumentlist(10);
    docList[0].Name = 'Registration Certificate';
    docList[0].External_Doc_Type__c = 'lobReg';
    docList[0].Document_Type__c = docTypeList[0].Id;

    docList[1].Name = 'COI';
    docList[1].External_Doc_Type__c = 'recoi';
    docList[1].Document_Type__c = docTypeList[1].Id;

    docList[2].Name = 'GST';
    docList[2].External_Doc_Type__c = 'regst';
    docList[2].Document_Type__c = docTypeList[1].Id;

    docList[3].Name = 'Company PAN';
    docList[3].External_Doc_Type__c = 'repan';
    docList[3].Document_Type__c = docTypeList[2].Id;

    docList[4].Name = 'Director/ Owner PAN';
    docList[4].External_Doc_Type__c = 'reopan';
    docList[4].Document_Type__c = docTypeList[3].Id;

    docList[5].Name = 'COI';
    docList[5].External_Doc_Type__c = 'recoi';
    docList[5].Document_Type__c = docTypeList[4].Id;

    docList[6].Name = 'GST';
    docList[6].External_Doc_Type__c = 'regst';
    docList[6].Document_Type__c = docTypeList[4].Id;

    docList[8].Name = 'Company PAN';
    docList[8].External_Doc_Type__c = 'repan';
    docList[8].Document_Type__c = docTypeList[5].Id;

    docList[9].Name = 'Director/ Owner PAN';
    docList[9].External_Doc_Type__c = 'reopen';
    docList[9].Document_Type__c = docTypeList[6].Id;

    insert docList;
  }

  @isTest
  static void triggerTest() {
    List<Campaign> campaignList = [SELECT Id, Campaign_ID__c FROM Campaign];
    List<Lead> leadList = TestUtill.createLead(200);
    for (Integer i = 0; i < leadList.size(); i++) {
      if (Math.mod(i, 4) == 0) {
        leadList[i].External_Campaign_ID__c = campaignList[0].Campaign_ID__c;
      } else if (Math.mod(i, 4) == 1) {
        leadList[i].External_Campaign_ID__c = campaignList[1].Campaign_ID__c;
      } else if (Math.mod(i, 4) == 2) {
        leadList[i].External_Campaign_ID__c = campaignList[2].Campaign_ID__c;
      } else {
        leadList[i].External_Campaign_ID__c = campaignList[3].Campaign_ID__c;
      }
    }

    System.debug('leadList: ' + leadList);
    Test.startTest();
    insert leadList;
    System.debug(
      [SELECT Id, Name, Campaign__c, External_Campaign_ID__c FROM Lead]
    );
    Test.stopTest();
    for (Lead lead : [SELECT Id, Campaign__c FROM Lead]) {
      System.debug('Campaign__c: ' + lead.Campaign__c);
      System.assert(lead.Campaign__c != null);
    }
    System.debug(
      [SELECT Id, Name, Campaign__c, External_Campaign_ID__c FROM Lead]
    );
  }

  @isTest
  static void roundRobinAssigneeTest() {
    // for(User tempUser : [Select Id,Name From User]){
    //     System.debug('User Name Valid :::'+ tempUser.Name+' '+tempUser.Id);
    // }
    User adminUser = [SELECT Id FROM User WHERE Name = 'Salesforce Admin'];
    System.runAs(adminUser) {
      List<User> userList = [
        SELECT Id
        FROM User
        WHERE Name LIKE '%Test%'
        LIMIT 9
      ];
      List<Round_Robin__c> roundRobinList = TestUtill.createIndividualRoundRobin(
        3
      );
      roundRobinList[0].Lead_Type__c = 'Inbound';
      roundRobinList[0].Lead_Source__c = 'Intercom;Web';
      roundRobinList[0].On_Duty__c = Time.newInstance(6, 15, 0, 0);
      roundRobinList[0].Off_Duty__c = Time.newInstance(22, 15, 0, 0);
      roundRobinList[0].Active_Field__c = 'Lead_Type__c,Lead_Source__c';
      roundRobinList[0].Active_Time__c = true;

      roundRobinList[1].Lead_Type__c = 'Banking Alliance';
      roundRobinList[1].Lead_Source__c = 'Payment Forms';
      roundRobinList[1].On_Duty__c = Time.newInstance(6, 15, 0, 0);
      roundRobinList[1].Off_Duty__c = Time.newInstance(22, 15, 0, 0);
      roundRobinList[1].Active_Field__c = 'Lead_Type__c';
      roundRobinList[1].Active_Time__c = false;

      //BAAS;
      roundRobinList[2].Lead_Type__c = 'Partner';
      roundRobinList[2].Lead_Source__c = 'Partners';
      roundRobinList[2].On_Duty__c = Time.newInstance(6, 15, 0, 0);
      roundRobinList[2].Off_Duty__c = Time.newInstance(22, 15, 0, 0);
      roundRobinList[2].Active_Field__c = 'Lead_Type__c';
      roundRobinList[2].Active_Time__c = false;
      insert roundRobinList;

      List<Round_Robin_Assignee__c> roundRobinAssigneeList = TestUtill.createRounRobinAssignee(
        9
      );
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
      insert roundRobinAssigneeList;

      List<Lead> leadList = TestUtill.createLead(101);
      for (Integer i = 0; i < 50; i++) {
        leadList[i].Consider_Round_Robin_Owner_Assignment__c = true;
        leadList[i].LeadSource = 'Inbound';
        leadList[i].Lead_Type__c = 'Intercom';
        leadList[i].Email = 'Test526@Test.com';
        leadList[i].MobilePhone = '9877545' + i;
        leadList[i].Website = 'www.google.com';
        leadList[i].UTM_Campaign__c = 'Google Search';
        leadList[i].Action_Type__c = 'Contact Sales';
        leadList[i].Campaign_Type__c = 'Paid';
      }

      for (Integer i = 50; i < 71; i++) {
        leadList[i].Consider_Round_Robin_Owner_Assignment__c = true;
        leadList[i].LeadSource = 'Banking Alliance';
        leadList[i].Lead_Type__c = 'Bank Alliance';
        leadList[i].Email = 'Test526@Test.com';
        leadList[i].MobilePhone = '9845678' + i;
        leadList[i].Website = 'ABC';
        leadList[i].Action_Type__c = null;
        leadList[i].Campaign_Type__c = null;
        leadList[i].UTM_Campaign__c = null;
      }

      for (Integer i = 71; i < 100; i++) {
        leadList[i].Consider_Round_Robin_Owner_Assignment__c = true;
        leadList[i].LeadSource = 'Partner';
        leadList[i].Lead_Type__c = 'BAAS';
        leadList[i].Email = 'Test526@Test.com';
        leadList[i].MobilePhone = '9842234' + i;
        leadList[i].Website = null;
      }
      leadList[100].Consider_Round_Robin_Owner_Assignment__c = true;
      leadList[100].LeadSource = 'Outbound';
      leadList[100].Lead_Type__c = 'Outbound';
      leadList[100].Email = 'Test526@Test.com';
      leadList[100].MobilePhone = '9842234' + 100;

      Test.startTest();
      insert leadList;
      Test.stopTest();

      Set<Id> userIdSet = new Set<Id>();
      List<Round_Robin__c> result = [
        SELECT Id, Previous_Active_User__c
        FROM Round_Robin__c
        ORDER BY CreatedDate
      ];
      System.assertEquals('2', result[0].Previous_Active_User__c);
      System.assertEquals('3', result[1].Previous_Active_User__c);
      System.assertEquals('2', result[2].Previous_Active_User__c);
    }
  }

  @isTest
  static void opportunityOwnerUpdate_Test() {
    test.startTest();
    Lead objLead = new Lead(
      FirstName = 'Test',
      LastName = 'Sample',
      Company = 'Testing Sample Co',
      Sub_LOB__c = 'Banking',
      Industry = 'Banking',
      Website_Live__c = 'Yes'
    );
    insert objLead;
    List<Opportunity> opp = TestUtill.createOpportunity(1);
    insert opp;

    //List<User> adminUser = [Select Id,Name From User Where Name LIKE '%Test%'];
    User adminUser = [SELECT Id FROM User WHERE Name = 'Test 1'];
    User adminUser2 = [SELECT Id FROM User WHERE Name = 'Test 2'];

    Account testAccount = new Account(
      Name = 'Test Account',
      OwnerId = adminUser.Id
    );
    insert testAccount;

    Contact con = new Contact();
    con.FirstName = 'ram';
    con.LastName = 'shyam';
    con.Email = 'sau@gmail.com';
    con.Phone = '4567889987';
    //con.OwnerId =adminUser2.Id
    insert con;

    Database.LeadConvert lc = new database.LeadConvert();
    lc.setLeadId(objLead.Id); //setAccountId(accountId)
    lc.setAccountId(testAccount.Id);
    lc.setContactId(con.Id);
    lc.setOpportunityId(opp[0].Id);
    lc.setDoNotCreateOpportunity(false);
    LeadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];
    lc.setConvertedStatus(convertStatus.MasterLabel);

    Database.LeadConvertResult lcr = Database.convertLead(lc);
    System.debug('Result:::' + lcr.isSuccess());

    Contact result = [SELECT Id, OwnerId FROM Contact LIMIT 1];
    Lead result2 = [
      SELECT Id, OwnerId, IsConverted
      FROM Lead
      WHERE Id = :objLead.Id
      LIMIT 1
    ];

    System.debug('contact details' + result);
    System.debug('lead details' + result2);
    System.debug('testAccount details' + testAccount);
    test.stopTest();
    system.assert(lcr.isSuccess());
  }

  @isTest
  static void merchantIdUpdateAPICallout_Test() {
    delete [SELECT Id FROM Account];

    Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());

    List<Lead> leadList = TestUtill.createLead(1);
    leadList[0].Company = 'Testing Update APICallout ';
    leadList[0].Sub_LOB__c = 'Banking';
    leadList[0].Industry = 'Banking';
    leadList[0].FirstName = 'ravi';
    leadList[0].LastName = 'krishna';
    leadList[0].Email = 'siv@gmail.com';
    leadList[0].MobilePhone = '9895948078';
    insert leadList;

    // List<Opportunity> oppList = TestUtill.createOpportunity(1);
    // Insert  oppList;

    //List<User> adminUser = [Select Id,Name From User Where Name LIKE '%Test%'];
    // User adminUser = [Select Id From User Where Name = 'Test 1'];

    List<Account> accountList = TestUtill.createAccount(1);

    insert accountList;

    // List<Contact> conList = TestUtill.createContact(1);
    // conList[0].FirstName = 'ravi';
    // conList[0].LastName = 'krishna';
    // conList[0].Email = 'siv@gmail.com';
    // conList[0].MobilePhone = '9895948078';
    // insert  conList;

    Database.LeadConvert leadc = new database.LeadConvert();
    leadc.setLeadId(leadList[0].Id); //setAccountId(accountId)
    leadc.setAccountId(accountList[0].Id);
    // leadc.setContactId(conList[0].Id);
    // leadc.setOpportunityId(oppList[0].Id);
    // leadc.setDoNotCreateOpportunity( false );
    leadc.setConvertedStatus('Converted');

    Test.startTest();

    Database.LeadConvertResult leadconres = Database.convertLead(leadc);

    // PostAddMerchantQueueableClass pqc = new PostAddMerchantQueueableClass(leadList[0].LastName,leadList[0].Email ,String.valueOf(leadList[0].MobilePhone),accountList[0].Id);
    // ID jobID = System.enqueueJob(pqc);

    // Account accResult = [Select Id,MID__c From  Account
    //                      LIMIT 1];

    // System.debug('Account Result >>>>>>>'+accResult);

    Account accResult = [SELECT Id, MID__c FROM Account LIMIT 1];
    System.debug('Accout Result:::::' + accResult);
    //System.assertEquals(accResult.MID__c,'287648');
    Test.stopTest();
  }
}
