@isTest
public class AccountCreationWebserviceTest {
  @isTest
  static void create_or_UpdateAccountTest() {
    Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
    Account accountList = new Account();
    accountList.Name = 'Test';
    accountList.Industry = 'Banking';
    accountList.MID__c = '';
    accountList.Website = 'test';
    accountList.type = 'Merchant';
    accountList.accountSource = 'Partner Merchant Onboarding';
    insert accountList;
    system.debug('Account:::' + accountList);

    List<User> userList = TestUtill.createUser(2);
    userList[0].City = 'test';
    userList[1].City = 'test1';
    insert userList;

    List<AccountTeamMember> accountTeamMemberList = TestUtill.createTeamMemberRolelist(
      1
    );
    accountTeamMemberList[0].AccountId = accountList.Id;
    accountTeamMemberList[0].userId = userList[0].Id;
    accountTeamMemberList[0].TeamMemberRole = 'Account Manager';
    accountTeamMemberList[0].AccountAccessLevel = 'Edit';
    accountTeamMemberList[0].OpportunityAccessLevel = 'Edit';
    accountTeamMemberList[0].CaseAccessLevel = 'Read';

    insert accountTeamMemberList;

    // Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
    // AccountTeamMember accRec=[Select Id,AccountId,TeamMemberRole,UserId,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel From AccountTeamMember LIMIT 1];

    Account accountRec = [
      SELECT
        Id,
        Name,
        MID__c,
        Primary_SPOC_Name__c,
        Primary_SPOC_Mobile__c,
        Primary_SPOC_Email__c,
        Account_Holder_Name__c,
        Type,
        Industry,
        Ownership,
        OwnerId,
        AccountSource,
        Referral_Id__c,
        Line_Of_Products__c,
        Bank_Account_Number__c,
        Account_IFSC__c,
        Owner_Director_PAN_Number__c,
        PAN__c,
        Registered_Name__c,
        Sub_LOB__c,
        Website
      FROM Account
    ];

    AccountTeamMember accRec = [
      SELECT
        Id,
        AccountId,
        TeamMemberRole,
        UserId,
        AccountAccessLevel,
        OpportunityAccessLevel,
        CaseAccessLevel
      FROM AccountTeamMember
      LIMIT 1
    ];

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/accountCreationandUpdation'; //Request URL
    req.httpMethod = 'POST';

    String json =
      '{' +
      '    \"accountName\" : \"Cashfree Testing Account\",' +
      '    \"mid\" : \"001001\",' +
      '    \"phone\" : \"9807609654\",' +
      '    \"type\" : \"Merchant\",' +
      '    \"ownerEmailId\" : \"test002221223@cashfree.com\",' +
      '    \"accountSource\" : \"Partner Merchant Onboarding\",' +
      '    \"referralId\" : \"495\",' +
      '    \"lineOfProducts\" : \"Payment Gateway\",' +
      '    \"accountOwner\" : \"test002221223@cashfree.com\",' +
      '' +
      '    \"teamMember\" : [' +
      '         {' +
      '            \"user\" : \"saurav.kashyap@appstrail.com\",' +
      '            \"teamRole\" : \"Account Manager\",' +
      '            \"accountAccess\" : \"Edit\",' +
      '            \"caseAccess\" : \"Read\",' +
      '            \"opportunityAccess\" : \"Edit\"' +
      '         },' +
      '         {' +
      '            \"user\" : \"vishal.hembrom@appstrail.com\",' +
      '            \"teamRole\" : \"Sales Rep\",' +
      '            \"accountAccess\" : \"Edit\",' +
      '            \"caseAccess\" : \"Read\",' +
      '            \"opportunityAccess\" : \"Edit\"' +
      '         }' +
      '     ],' +
      '' +
      '    \"primarySPOC\" : {' +
      '  \"primarySPOCName\" : \"Vikram Rathore\",' +
      '         \"email\" : \"test002221223@cashfree.com\",' +
      '         \"mobile\" : \"9807609654\"' +
      '     },' +
      '' +
      '    \"otherDetails\" : {' +
      '        \"lob\" : \"Education\",' +
      '        \"subLob\" : \"EdTech\",' +
      '        \"registeredName\" : \"TestRegistered Name\",' +
      '        \"entityType\" : \"Partnership\",' +
      '        \"bankAccountNumber\" : \"4003830171874018\",' +
      '        \"accountIFSC\" : \"SBIN0011513\",' +
      '        \"owner_or_Director_PAN\" : \"KJDLAA5678A\",' +
      '        \"businessPAN\" : \"RLDOIA5678A\",' +
      '        \"website\" : \"www.cashfree.com\"' +
      '     }' +
      '' +
      '}';

    AccountCreationWrapper wrap = AccountCreationWrapper.parse(json);

    req.requestBody = blob.valueOf(json);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    AccountCreationWebservice.create_or_UpdateAccount();
    Test.stopTest();
  }

  @isTest
  static void create_or_UpdateAccount1() {
    Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
    Account accountList = new Account();
    accountList.Name = 'Test';
    accountList.Industry = 'Banking';
    accountList.MID__c = '0011';
    accountList.Website = 'test';
    accountList.type = 'Merchant';
    accountList.accountSource = 'Partner Merchant Onboarding';
    insert accountList;

    Account accountRec = [
      SELECT
        Id,
        Name,
        MID__c,
        Primary_SPOC_Name__c,
        Primary_SPOC_Mobile__c,
        Primary_SPOC_Email__c,
        Account_Holder_Name__c,
        Type,
        Industry,
        Ownership,
        OwnerId,
        AccountSource,
        Referral_Id__c,
        Line_Of_Products__c,
        Bank_Account_Number__c,
        Account_IFSC__c,
        Owner_Director_PAN_Number__c,
        PAN__c,
        Registered_Name__c,
        Sub_LOB__c,
        Website
      FROM Account
    ];
    accountRec.MID__c = '001001';
    update accountRec;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/caseCreation'; //Request URL
    req.httpMethod = 'POST';

    String json =
      '{' +
      '    \"accountName\" : \"Cashfree Testing Account\",' +
      '    \"mid\" : \"001001\",' +
      '    \"phone\" : \"9807609654\",' +
      '    \"type\" : \"Merchant\",' +
      '    \"ownerEmailId\" : \"test002221223@cashfree.com\",' +
      '    \"accountSource\" : \"Partner Merchant Onboarding\",' +
      '    \"referralId\" : \"495\",' +
      '    \"lineOfProducts\" : \"Payment Gateway\",' +
      '    \"accountOwner\" : \"test002221223@cashfree.com\",' +
      '' +
      '    \"teamMember\" : [' +
      '         {' +
      '            \"user\" : \"saurav.kashyap@appstrail.com\",' +
      '            \"teamRole\" : \"Account Manager\",' +
      '            \"accountAccess\" : \"Edit\",' +
      '            \"caseAccess\" : \"Read\",' +
      '            \"opportunityAccess\" : \"Edit\"' +
      '         },' +
      '         {' +
      '            \"user\" : \"vishal.hembrom@appstrail.com\",' +
      '            \"teamRole\" : \"Sales Rep\",' +
      '            \"accountAccess\" : \"Edit\",' +
      '            \"caseAccess\" : \"Read\",' +
      '            \"opportunityAccess\" : \"Edit\"' +
      '         }' +
      '     ],' +
      '' +
      '    \"primarySPOC\" : {' +
      '  \"primarySPOCName\" : \"Vikram Rathore\",' +
      '         \"email\" : \"test002221223@cashfree.com\",' +
      '         \"mobile\" : \"9807609654\"' +
      '     },' +
      '' +
      '    \"otherDetails\" : {' +
      '        \"lob\" : \"Education\",' +
      '        \"subLob\" : \"EdTech\",' +
      '        \"registeredName\" : \"TestRegistered Name\",' +
      '        \"entityType\" : \"Partnership\",' +
      '        \"bankAccountNumber\" : \"4003830171874018\",' +
      '        \"accountIFSC\" : \"SBIN0011513\",' +
      '        \"owner_or_Director_PAN\" : \"KJDLAA5678A\",' +
      '        \"businessPAN\" : \"RLDOIA5678A\",' +
      '        \"website\" : \"www.cashfree.com\"' +
      '     }' +
      '' +
      '}';

    AccountCreationWrapper wrap = AccountCreationWrapper.parse(json);

    req.requestBody = blob.valueOf(json);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    AccountCreationWebservice.create_or_UpdateAccount();
    Test.stopTest();
  }

  @isTest
  static void create_or_UpdateAccount2() {
    Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
    Account accountList = new Account();
    accountList.Name = 'Test';
    accountList.Industry = 'Banking';
    accountList.MID__c = '001001';
    accountList.Website = 'test';
    accountList.type = 'Merchant';
    accountList.accountSource = 'Partner Merchant Onboarding';
    insert accountList;
    system.debug('Account:::' + accountList);

    List<User> userList = TestUtill.createUser(2);
    userList[0].City = 'test';
    userList[1].City = 'test1';
    insert userList;

    List<AccountTeamMember> accountTeamMemberList = TestUtill.createTeamMemberRolelist(
      1
    );
    accountTeamMemberList[0].AccountId = accountList.Id;
    accountTeamMemberList[0].userId = userList[0].Id;
    accountTeamMemberList[0].TeamMemberRole = 'Account Manager';
    accountTeamMemberList[0].AccountAccessLevel = 'Edit';
    accountTeamMemberList[0].OpportunityAccessLevel = 'Edit';
    accountTeamMemberList[0].CaseAccessLevel = 'Read';
    insert accountTeamMemberList;

    User u = [SELECT Id, Name, Email FROM User WHERE City = 'test1' LIMIT 1];
    u.Email = 'test1@test.com';
    //u[1].Email='test0022212234@cashfree.com';
    update u;

    AccountTeamMember accRec = [
      SELECT
        Id,
        AccountId,
        TeamMemberRole,
        UserId,
        AccountAccessLevel,
        OpportunityAccessLevel,
        CaseAccessLevel
      FROM AccountTeamMember
      LIMIT 1
    ];

    Account accountRec = [
      SELECT
        Id,
        Name,
        MID__c,
        Primary_SPOC_Name__c,
        Primary_SPOC_Mobile__c,
        Primary_SPOC_Email__c,
        Account_Holder_Name__c,
        Type,
        Industry,
        Ownership,
        OwnerId,
        AccountSource,
        Referral_Id__c,
        Line_Of_Products__c,
        Bank_Account_Number__c,
        Account_IFSC__c,
        Owner_Director_PAN_Number__c,
        PAN__c,
        Registered_Name__c,
        Sub_LOB__c,
        Website
      FROM Account
    ];
    accountRec.Primary_SPOC_Email__c = 'test1@test.com';
    accountRec.OwnerId = u.Id;
    update accountRec;
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/caseCreation'; //Request URL
    req.httpMethod = 'POST';

    String json =
      '{' +
      '    \"accountName\" : \"Cashfree Testing Account\",' +
      '    \"mid\" : \"001001\",' +
      '    \"phone\" : \"9807609654\",' +
      '    \"type\" : \"Merchant\",' +
      '    \"ownerEmailId\" : \"test002221223@cashfree.com\",' +
      '    \"accountSource\" : \"Partner Merchant Onboarding\",' +
      '    \"referralId\" : \"495\",' +
      '    \"lineOfProducts\" : \"Payment Gateway\",' +
      '    \"accountOwner\" : \"test002221223@cashfree.com\",' +
      '' +
      '    \"teamMember\" : [' +
      '         {' +
      '            \"user\" : \"test1@test.com\",' +
      '            \"teamRole\" : \"Account Manager\",' +
      '            \"accountAccess\" : \"Edit\",' +
      '            \"caseAccess\" : \"Read\",' +
      '            \"opportunityAccess\" : \"Edit\"' +
      '         },' +
      '         {' +
      '            \"user\" : \"vishal.hembrom@appstrail.com\",' +
      '            \"teamRole\" : \"Sales Rep\",' +
      '            \"accountAccess\" : \"Edit\",' +
      '            \"caseAccess\" : \"Read\",' +
      '            \"opportunityAccess\" : \"Edit\"' +
      '         }' +
      '     ],' +
      '' +
      '    \"primarySPOC\" : {' +
      '  \"primarySPOCName\" : \"Vikram Rathore\",' +
      '         \"email\" : \"test@xyz.com\",' +
      '         \"mobile\" : \"9807609654\"' +
      '     },' +
      '' +
      '    \"otherDetails\" : {' +
      '        \"lob\" : \"Education\",' +
      '        \"subLob\" : \"EdTech\",' +
      '        \"registeredName\" : \"TestRegistered Name\",' +
      '        \"entityType\" : \"Partnership\",' +
      '        \"bankAccountNumber\" : \"4003830171874018\",' +
      '        \"accountIFSC\" : \"SBIN0011513\",' +
      '        \"owner_or_Director_PAN\" : \"KJDLAA5678A\",' +
      '        \"businessPAN\" : \"RLDOIA5678A\",' +
      '        \"website\" : \"www.cashfree.com\"' +
      '     }' +
      '' +
      '}';

    AccountCreationWrapper wrap = AccountCreationWrapper.parse(json);

    req.requestBody = blob.valueOf(json);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    AccountCreationWebservice.create_or_UpdateAccount();
    Test.stopTest();
  }
}
