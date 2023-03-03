@isTest
public class AccountCreationWebserviceTest { 
	
    @isTest
    static void testCreateOrUpdateAccount_Scenario1() {
        // Set up test data
        List<User> userList = TestUtill.createUser(2);
        userList[0].City='test';
		userList[0].email='abc@pqr.com';
         userList[1].City='test1';
		userList[1].email='test002221223@cashfree.com';
        Insert userList;
        
        Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
        // Set up mock request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/accountCreationandUpdation';
        req.addHeader('Content-Type', 'application/json'); 
        req.httpMethod = 'PATCH';
        
        //Setting requestBody Data
        String jsonString= '{'+
		'    \"accountName\" : \"Cashfree Testing Account\",'+
		'    \"mid\" : \"001001\",'+
		'    \"phone\" : \"9807609654\",'+
		'    \"type\" : \"Merchant\",'+
		'    \"ownerEmailId\" : \"test002221223@cashfree.com\",'+
		'    \"accountSource\" : \"Partner Merchant Onboarding\",'+
		'    \"referralId\" : \"495\",'+
		'    \"lineOfProducts\" : \"Payment Gateway\",'+
		'    \"accountOwner\" : \"test002221223@cashfree.com\",'+
		''+
		'    \"teamMember\" : ['+
		'         {'+
		'            \"user\" : \"abc@pqr.com\",'+
		'            \"teamRole\" : \"Account Manager\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         },'+
		'         {'+
		'            \"user\" : \"abc1@pqr.com\",'+
		'            \"teamRole\" : \"Sales Rep\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         }'+
		'     ],'+
		''+
		'    \"primarySPOC\" : {'+
		'  \"primarySPOCName\" : \"Vikram Rathore\",'+
		'         \"email\" : \"test002221223@cashfree.com\",'+
		'         \"mobile\" : \"9807609654\"'+
		'     },'+
		''+
		'    \"otherDetails\" : {'+
		'        \"lob\" : \"Education\",'+
		'        \"subLob\" : \"EdTech\",'+
		'        \"registeredName\" : \"TestRegistered Name\",'+
		'        \"entityType\" : \"Partnership\",'+
		'        \"bankAccountNumber\" : \"4003830171874018\",'+
		'        \"accountIFSC\" : \"SBIN0011513\",'+
		'        \"owner_or_Director_PAN\" : \"KJDLAA5678A\",'+
		'        \"businessPAN\" : \"RLDOIA5678A\",'+
		'        \"website\" : \"www.cashfree.com\"'+
		'     },'+
		''+
		'    \"PartnerDetails\" : {'+
		'        \"pid\" : \"Test\",'+
		'        \"partnerName\" : \"EdTest\",'+
		'        \"partnerEmail\" : \"TestRegistered@gmail.com\",'+
		'        \"partnerPhone\" : \"9878765645\",'+
		'        \"partnerKycSpoc\" : \"Merchant\",'+
		'        \"partnerCareSpoc\" : \"Partner\"'+
		'     }'+
		''+
		'}';
        
        // Account Wrapper to be instanciated Here for requestBody
        AccountCreationWrapper accountWrapperObject = AccountCreationWrapper.parse(jsonString);
        req.requestBody = Blob.valueOf(JSON.serialize(accountWrapperObject));
        
        //Setting up ResponseBody Data
        String responseJsonBody = '{'+
            '"accountId":"001C1000005MgP7IAK",'+
            '"status":"success",'+
            '"message":"Account updated Successfully!",'+
            '}';

         // Set up mock response
        res.statusCode = 201;
       
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(responseJsonBody);
                
        
        RestContext.request = req;
        RestContext.response = res;
        
       
        // Call web service method
        Test.startTest();
        AccountCreationWebservice.create_or_UpdateAccount();
        Test.stopTest();

        // Assert expected result
       /* RestResponse expectedRes = new RestResponse();
        expectedRes.addHeader('Content-Type', 'application/json');
        expectedRes.statusCode = 201;
        expectedRes.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => 'Success',
            'accountId' => '001C1000005MgP7IAK',
            'message' => 'Account updated successfully'
        }));

        System.assertEquals(expectedRes.statusCode, RestContext.response.statusCode);*/
		
    }
    
    @isTest
    static void testCreateOrUpdateAccount_Scenario2() {
        // Set up test data
        List<User> userList = TestUtill.createUser(2);
        userList[0].City='test';
		userList[0].email='abc@pqr.com';
        userList[1].City='test1';
		userList[1].email='test002221223@cashfree.com';
        Insert userList;
        
        Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
        Account accountList = new Account();
        accountList.Name='Test';
        accountList.Industry = 'Banking';
        accountList.MID__c='64689';
		accountList.OwnerId=userList[0].Id;
        accountList.Website='test';
        accountList.type ='Merchant';
        accountList.accountSource ='Partner Merchant Onboarding';
        accountList.Primary_SPOC_Email__c ='peter@gmail.com';
        Insert accountList;
        system.debug('Account:::'+accountList);
        
        List<AccountTeamMember> accountTeamMemberList=TestUtill.createTeamMemberRolelist(1);
        accountTeamMemberList[0].AccountId= accountList.Id;
        accountTeamMemberList[0].userId= userList[0].Id;
        accountTeamMemberList[0].TeamMemberRole='Account Manager';
        accountTeamMemberList[0].AccountAccessLevel='Edit';
        accountTeamMemberList[0].OpportunityAccessLevel='Edit';
        accountTeamMemberList[0].CaseAccessLevel='Read';
        insert accountTeamMemberList;
		List<AccountTeamMember> accountRec2=[select id from AccountTeamMember];
        system.debug('AccountRec:::'+accountRec2);
        
        //Querying Existing Data...
        Account accountRec = [SELECT Id, Name, MID__c, Primary_SPOC_Name__c, Primary_SPOC_Mobile__c, 
                              Primary_SPOC_Email__c, Account_Holder_Name__c, Type, Industry, 
                              Ownership, OwnerId, AccountSource, Referral_Id__c, Line_Of_Products__c, 
                              Bank_Account_Number__c, Account_IFSC__c, Owner_Director_PAN_Number__c, 
                              PAN__c, Registered_Name__c, Sub_LOB__c, Website 
                              FROM Account];
        
        AccountTeamMember accRec=[Select Id,AccountId,TeamMemberRole,UserId,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel From AccountTeamMember LIMIT 1];
        
        
        // Set up mock request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/accountCreationandUpdation';
        req.addHeader('Content-Type', 'application/json'); 
        req.httpMethod = 'PATCH';
        
        //Setting requestBody Data
        String jsonString= '{'+
		'    \"accountName\" : \"Cashfree Testing Account\",'+
		'    \"mid\" : \"001001\",'+
		'    \"phone\" : \"9807609654\",'+
		'    \"type\" : \"Merchant\",'+
		'    \"ownerEmailId\" : \"test002221223@cashfree.com\",'+
		'    \"accountSource\" : \"Partner Merchant Onboarding\",'+
		'    \"referralId\" : \"495\",'+
		'    \"lineOfProducts\" : \"Payment Gateway\",'+
		'    \"accountOwner\" : \"test002221223@cashfree.com\",'+
		''+
		'    \"teamMember\" : ['+
		'         {'+
		'            \"user\" : \"abc@pqr.com\",'+
		'            \"teamRole\" : \"Account Manager\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         },'+
		'         {'+
		'            \"user\" : \"abc1@pqr.com\",'+
		'            \"teamRole\" : \"Sales Rep\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         }'+
		'     ],'+
		''+
		'    \"primarySPOC\" : {'+
		'  \"primarySPOCName\" : \"Vikram Rathore\",'+
		'         \"email\" : \"peter@gmail.com\",'+
		'         \"mobile\" : \"9807609654\"'+
		'     },'+
		''+
		'    \"otherDetails\" : {'+
		'        \"lob\" : \"Education\",'+
		'        \"subLob\" : \"EdTech\",'+
		'        \"registeredName\" : \"TestRegistered Name\",'+
		'        \"entityType\" : \"Partnership\",'+
		'        \"bankAccountNumber\" : \"4003830171874018\",'+
		'        \"accountIFSC\" : \"SBIN0011513\",'+
		'        \"owner_or_Director_PAN\" : \"KJDLAA5678A\",'+
		'        \"businessPAN\" : \"RLDOIA5678A\",'+
		'        \"website\" : \"www.cashfree.com\"'+
		'     },'+
		''+
		'    \"PartnerDetails\" : {'+
		'        \"pid\" : \"Test\",'+
		'        \"partnerName\" : \"EdTest\",'+
		'        \"partnerEmail\" : \"TestRegistered@gmail.com\",'+
		'        \"partnerPhone\" : \"9878765645\",'+
		'        \"partnerKycSpoc\" : \"Merchant\",'+
		'        \"partnerCareSpoc\" : \"Partner\"'+
		'     }'+
		''+
		'}';
        
        // Account Wrapper to be instanciated Here for requestBody
        AccountCreationWrapper accountWrapperObject = AccountCreationWrapper.parse(jsonString);
        req.requestBody = Blob.valueOf(JSON.serialize(accountWrapperObject));
        
        //Setting up ResponseBody Data
        String responseJsonBody = '{'+
            '"accountId":"001C1000005MgP7IAK",'+
            '"status":"success",'+
            '"message":"Account updated Successfully!",'+
            '}';

         // Set up mock response
        res.statusCode = 200;
       
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(responseJsonBody);
                
        
        RestContext.request = req;
        RestContext.response = res;
        
       
        // Call web service method
        Test.startTest();
        AccountCreationWebservice.create_or_UpdateAccount();
        Test.stopTest();

        // Assert expected result
       /* RestResponse expectedRes = new RestResponse();
        expectedRes.addHeader('Content-Type', 'application/json');
        expectedRes.statusCode = 200;
        expectedRes.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => 'Success',
            'accountId' => '001C1000005MgP7IAK',
            'message' => 'Account updated successfully'
        }));

        System.assertEquals(expectedRes.statusCode, RestContext.response.statusCode);*/
		
    }

    @isTest
    static void testCreateOrUpdateAccount_Scenario3() {
        // Set up test data
        List<User> userList = TestUtill.createUser(3);
        userList[0].City='test';
		userList[0].email='abc@pqr.com';
        userList[1].City='test1';
		userList[1].email='abc1@pqr.com';
        Insert userList;
        
        Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
        Account accountList = new Account();
        accountList.Name='Test';
        accountList.Industry = 'Banking';
        accountList.MID__c='001001';
		accountList.OwnerId=userList[0].Id;
        accountList.Website='test';
        accountList.type ='Merchant';
        accountList.accountSource ='Partner Merchant Onboarding';
        accountList.Primary_SPOC_Email__c ='peter@gmail.com';
        Insert accountList;
        system.debug('Account:::'+accountList);
        
        List<AccountTeamMember> accountTeamMemberList=TestUtill.createTeamMemberRolelist(1);
        accountTeamMemberList[0].AccountId= accountList.Id;
        accountTeamMemberList[0].userId= userList[0].Id;
        accountTeamMemberList[0].TeamMemberRole='Account Manager';
        accountTeamMemberList[0].AccountAccessLevel='Edit';
        accountTeamMemberList[0].OpportunityAccessLevel='Edit';
        accountTeamMemberList[0].CaseAccessLevel='Read';
        insert accountTeamMemberList;
		List<AccountTeamMember> accountRec2=[select id from AccountTeamMember];
        system.debug('AccountRec:::'+accountRec2);
        
        //Querying Existing Data...
        Account accountRec = [SELECT Id, Name, MID__c, Primary_SPOC_Name__c, Primary_SPOC_Mobile__c, 
                              Primary_SPOC_Email__c, Account_Holder_Name__c, Type, Industry, 
                              Ownership, OwnerId, AccountSource, Referral_Id__c, Line_Of_Products__c, 
                              Bank_Account_Number__c, Account_IFSC__c, Owner_Director_PAN_Number__c, 
                              PAN__c, Registered_Name__c, Sub_LOB__c, Website 
                              FROM Account];
        
        AccountTeamMember accRec=[Select Id,AccountId,TeamMemberRole,UserId,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel From AccountTeamMember LIMIT 1];
        
        
        // Set up mock request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/accountCreationandUpdation';
        req.addHeader('Content-Type', 'application/json'); 
        req.httpMethod = 'PATCH';
        
        //Setting requestBody Data
        String jsonString= '{'+
		'    \"accountName\" : \"Cashfree Testing Account\",'+
		'    \"mid\" : \"001001\",'+
		'    \"phone\" : \"9807609654\",'+
		'    \"type\" : \"Merchant\",'+
		'    \"ownerEmailId\" : \"test002221223@cashfree.com\",'+
		'    \"accountSource\" : \"Partner Merchant Onboarding\",'+
		'    \"referralId\" : \"495\",'+
		'    \"lineOfProducts\" : \"Payment Gateway\",'+
		'    \"accountOwner\" : \"test002221223@cashfree.com\",'+
		''+
		'    \"teamMember\" : ['+
		'         {'+
		'            \"user\" : \"abc@pqr.com\",'+
		'            \"teamRole\" : \"Account Manager\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         },'+
		'         {'+
		'            \"user\" : \"abc1@pqr.com\",'+
		'            \"teamRole\" : \"Sales Rep\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         }'+
		'     ],'+
		''+
		'    \"primarySPOC\" : {'+
		'  \"primarySPOCName\" : \"Vikram Rathore\",'+
		'         \"email\" : \"peter@gmail.com\",'+
		'         \"mobile\" : \"9807609654\"'+
		'     },'+
		''+
		'    \"otherDetails\" : {'+
		'        \"lob\" : \"Education\",'+
		'        \"subLob\" : \"EdTech\",'+
		'        \"registeredName\" : \"TestRegistered Name\",'+
		'        \"entityType\" : \"Partnership\",'+
		'        \"bankAccountNumber\" : \"4003830171874018\",'+
		'        \"accountIFSC\" : \"SBIN0011513\",'+
		'        \"owner_or_Director_PAN\" : \"KJDLAA5678A\",'+
		'        \"businessPAN\" : \"RLDOIA5678A\",'+
		'        \"website\" : \"www.cashfree.com\"'+
		'     },'+
		''+
		'    \"PartnerDetails\" : {'+
		'        \"pid\" : \"Test\",'+
		'        \"partnerName\" : \"EdTest\",'+
		'        \"partnerEmail\" : \"TestRegistered@gmail.com\",'+
		'        \"partnerPhone\" : \"9878765645\",'+
		'        \"partnerKycSpoc\" : \"Merchant\",'+
		'        \"partnerCareSpoc\" : \"Partner\"'+
		'     }'+
		''+
		'}';
        
        // Account Wrapper to be instanciated Here for requestBody
        AccountCreationWrapper accountWrapperObject = AccountCreationWrapper.parse(jsonString);
        req.requestBody = Blob.valueOf(JSON.serialize(accountWrapperObject));
        
        //Setting up ResponseBody Data
        String responseJsonBody = '{'+
            '"accountId":"001C1000005MgP7IAK",'+
            '"status":"success",'+
            '"message":"Account updated Successfully!",'+
            '}';

         // Set up mock response
        res.statusCode = 200;
       
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(responseJsonBody);
                
        
        RestContext.request = req;
        RestContext.response = res;
        
       
        // Call web service method
        Test.startTest();
        AccountCreationWebservice.create_or_UpdateAccount();
        Test.stopTest();

        // Assert expected result
       /* RestResponse expectedRes = new RestResponse();
        expectedRes.addHeader('Content-Type', 'application/json');
        expectedRes.statusCode = 200;
        expectedRes.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'status' => 'Success',
            'accountId' => '001C1000005MgP7IAK',
            'message' => 'Account updated successfully'
        }));

        System.assertEquals(expectedRes.statusCode, RestContext.response.statusCode);*/
		
    }
}
/*    @isTest
    static void create_or_UpdateAccountTest(){

		List<User> userList = TestUtill.createUser(2);

        userList[0].City='test';
		userList[0].email='abc@pqr.com';
        userList[1].City='test1';
		userList[1].email='abc1@pqr.com';
        Insert userList;
        
        
        Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
        Account accountList = new Account();
        accountList.Name='Test';
        accountList.Industry = 'Banking';
        accountList.MID__c='';
		accountList.OwnerId=userList[0].Id;
        accountList.Website='test';
        accountList.type ='Merchant';
		//accountList.Owner_Email_ID__c='test002221223@cashfree.com';
        accountList.accountSource ='Partner Merchant Onboarding';
        Insert accountList;
        system.debug('Account:::'+accountList);
        
        /*accountteammember mem = new AccountTeamMember();
        mem.AccountId = accountList.Id;
        mem.UserId = userList[0].Id;
        mem.AccountAccessLevel = ''*//*
		List<AccountTeamMember> accountRec1=[select id from AccountTeamMember];
        system.debug('AccountRec:::'+accountRec1);
    
        List<AccountTeamMember> accountTeamMemberList=TestUtill.createTeamMemberRolelist(1);
        accountTeamMemberList[0].AccountId= accountList.Id;
        accountTeamMemberList[0].userId= userList[0].Id;
        accountTeamMemberList[0].TeamMemberRole='Account Manager';
        accountTeamMemberList[0].AccountAccessLevel='Edit';
        accountTeamMemberList[0].OpportunityAccessLevel='Edit';
        accountTeamMemberList[0].CaseAccessLevel='Read';
        insert accountTeamMemberList;
		List<AccountTeamMember> accountRec2=[select id from AccountTeamMember];
        system.debug('AccountRec:::'+accountRec2);
         
        // Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
        // AccountTeamMember accRec=[Select Id,AccountId,TeamMemberRole,UserId,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel From AccountTeamMember LIMIT 1];
     
       
         Account accountRec = [SELECT Id, Name, MID__c, Primary_SPOC_Name__c, Primary_SPOC_Mobile__c, 
                                    Primary_SPOC_Email__c, Account_Holder_Name__c, Type, Industry, 
                                    Ownership, OwnerId, AccountSource, Referral_Id__c, Line_Of_Products__c, 
                                    Bank_Account_Number__c, Account_IFSC__c, Owner_Director_PAN_Number__c, 
                                    PAN__c, Registered_Name__c, Sub_LOB__c, Website 
                                    FROM Account];
        
        AccountTeamMember accRec=[Select Id,AccountId,TeamMemberRole,UserId,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel From AccountTeamMember LIMIT 1];
      
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/accountCreationandUpdation'; //Request URL
        req.httpMethod = 'POST';
        
        String json = '{'+
		'    \"accountName\" : \"Cashfree Testing Account\",'+
		'    \"mid\" : \"001001\",'+
		'    \"phone\" : \"9807609654\",'+
		'    \"type\" : \"Merchant\",'+
		'    \"ownerEmailId\" : \"test002221223@cashfree.com\",'+
		'    \"accountSource\" : \"Partner Merchant Onboarding\",'+
		'    \"referralId\" : \"495\",'+
		'    \"lineOfProducts\" : \"Payment Gateway\",'+
		'    \"accountOwner\" : \"test002221223@cashfree.com\",'+
		''+
		'    \"teamMember\" : ['+
		'         {'+
		'            \"user\" : \"abc@pqr.com\",'+
		'            \"teamRole\" : \"Account Manager\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         },'+
		'         {'+
		'            \"user\" : \"abc1@pqr.com\",'+
		'            \"teamRole\" : \"Sales Rep\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         }'+
		'     ],'+
		''+
		'    \"primarySPOC\" : {'+
		'  \"primarySPOCName\" : \"Vikram Rathore\",'+
		'         \"email\" : \"test002221223@cashfree.com\",'+
		'         \"mobile\" : \"9807609654\"'+
		'     },'+
		''+
		'    \"otherDetails\" : {'+
		'        \"lob\" : \"Education\",'+
		'        \"subLob\" : \"EdTech\",'+
		'        \"registeredName\" : \"TestRegistered Name\",'+
		'        \"entityType\" : \"Partnership\",'+
		'        \"bankAccountNumber\" : \"4003830171874018\",'+
		'        \"accountIFSC\" : \"SBIN0011513\",'+
		'        \"owner_or_Director_PAN\" : \"KJDLAA5678A\",'+
		'        \"businessPAN\" : \"RLDOIA5678A\",'+
		'        \"website\" : \"www.cashfree.com\"'+
		'     },'+
		''+
		'    \"PartnerDetails\" : {'+
		'        \"pid\" : \"Test\",'+
		'        \"partnerName\" : \"EdTest\",'+
		'        \"partnerEmail\" : \"TestRegistered@gmail.com\",'+
		'        \"partnerPhone\" : \"9878765645\",'+
		'        \"partnerKycSpoc\" : \"Merchant\",'+
		'        \"partnerCareSpoc\" : \"Partner\"'+
		'     }'+
		''+
		'}';
        
        
        AccountCreationWrapper wrap = AccountCreationWrapper.parse(json);
        
        
        req.requestBody = blob.valueOf(json);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        AccountCreationWebservice.create_or_UpdateAccount();
        Test.stopTest();
        List<Account> accountList1 = new List<Account>();
        accountList1 = [SELECT Id, Name, MID__c, Primary_SPOC_Name__c, Primary_SPOC_Mobile__c, 
                                    Primary_SPOC_Email__c
                                    FROM Account
                                    WHERE MID__c =:wrap.mid];
        system.assert(accountList1.size()>0);
        
    }
   
    @isTest
    static void create_or_UpdateAccount1(){
       
	    List<User> userList = TestUtill.createUser(2);
         userList[0].City='test';
		userList[0].email='abc@pqr.com';
        userList[1].City='test1';
		userList[1].email='abc1@pqr.com';
        Insert userList;

        Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
        Account accountList = new Account();
        accountList.Name='Test';
        accountList.Industry = 'Banking';
        accountList.MID__c='0011';
		accountList.OwnerId=userList[0].Id;
        accountList.Website='test';
        accountList.type ='Merchant';
		//accountList.Owner_Email_ID__c='test002221223@cashfree.com';
        accountList.accountSource ='Partner Merchant Onboarding';
        Insert accountList;
        
       Account accountRec = [SELECT Id, Name, MID__c, Primary_SPOC_Name__c, Primary_SPOC_Mobile__c, 
                                    Primary_SPOC_Email__c, Account_Holder_Name__c, Type, Industry, 
                                    Ownership, OwnerId, AccountSource, Referral_Id__c, Line_Of_Products__c, 
                                    Bank_Account_Number__c, Account_IFSC__c, Owner_Director_PAN_Number__c, 
                                    PAN__c, Registered_Name__c, Sub_LOB__c, Website 
                                    FROM Account];
        accountRec.MID__c='001001';
        update accountRec;
        
        List<AccountTeamMember> accountTeamMemberList=TestUtill.createTeamMemberRolelist(1);
        accountTeamMemberList[0].AccountId= accountRec.Id;
        accountTeamMemberList[0].userId= userList[0].Id;
        accountTeamMemberList[0].TeamMemberRole='Account Manager';
        accountTeamMemberList[0].AccountAccessLevel='Edit';
        accountTeamMemberList[0].OpportunityAccessLevel='Edit';
        accountTeamMemberList[0].CaseAccessLevel='Read';
        insert accountTeamMemberList;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/caseCreation'; //Request URL
        req.httpMethod = 'POST';
        
        String json = '{'+
		'    \"accountName\" : \"Cashfree Testing Account\",'+
		'    \"mid\" : \"001001\",'+
		'    \"phone\" : \"9807609654\",'+
		'    \"type\" : \"Merchant\",'+
		'    \"ownerEmailId\" : \"test002221223@cashfree.com\",'+
		'    \"accountSource\" : \"Partner Merchant Onboarding\",'+
		'    \"referralId\" : \"495\",'+
		'    \"lineOfProducts\" : \"Payment Gateway\",'+
		'    \"accountOwner\" : \"test002221223@cashfree.com\",'+
		''+
		'    \"teamMember\" : ['+
		'         {'+
		'            \"user\" : \"abc1@pqr.com\",'+
		'            \"teamRole\" : \"Account Manager\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         },'+
		'         {'+
		'            \"user\" : \"abc@pqr.com\",'+
		'            \"teamRole\" : \"Sales Rep\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         }'+
		'     ],'+
		''+
		'    \"primarySPOC\" : {'+
		'  \"primarySPOCName\" : \"Vikram Rathore\",'+
		'         \"email\" : \"test002221223@cashfree.com\",'+
		'         \"mobile\" : \"9807609654\"'+
		'     },'+
		''+
		'    \"otherDetails\" : {'+
		'        \"lob\" : \"Education\",'+
		'        \"subLob\" : \"EdTech\",'+
		'        \"registeredName\" : \"TestRegistered Name\",'+
		'        \"entityType\" : \"Partnership\",'+
		'        \"bankAccountNumber\" : \"4003830171874018\",'+
		'        \"accountIFSC\" : \"SBIN0011513\",'+
		'        \"owner_or_Director_PAN\" : \"KJDLAA5678A\",'+
		'        \"businessPAN\" : \"RLDOIA5678A\",'+
		'        \"website\" : \"www.cashfree.com\"'+
		'     },'+
		''+
		'    \"PartnerDetails\" : {'+
		'        \"pid\" : \"Test\",'+
		'        \"partnerName\" : \"EdTest\",'+
		'        \"partnerEmail\" : \"TestRegistered@gmail.com\",'+
		'        \"partnerPhone\" : \"9878765645\",'+
		'        \"partnerKycSpoc\" : \"Merchant\",'+
		'        \"partnerCareSpoc\" : \"Partner\"'+
		'     }'+
		''+
		'}';
        
        
        AccountCreationWrapper wrap = AccountCreationWrapper.parse(json);
        
        
        req.requestBody = blob.valueOf(json);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        AccountCreationWebservice.create_or_UpdateAccount();
        Test.stopTest();
        List<Account> accountList2 = new List<Account>();
        accountList2 = [SELECT Id, Name, MID__c, Primary_SPOC_Name__c, Primary_SPOC_Mobile__c, 
                                    Primary_SPOC_Email__c
                                    FROM Account
                                    WHERE MID__c =:wrap.mid];
        system.assert(accountList2.size()>0);
    }
    
    @isTest
    static void create_or_UpdateAccount2(){

		List<User> userList = TestUtill.createUser(2);
        userList[0].City='test';
        userList[1].City='test1';
        Insert userList;
        
        Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
        Account accountList = new Account();
        accountList.Name='Test';
        accountList.Industry = 'Banking';
        accountList.MID__c='001001';
		accountList.OwnerId=userList[0].Id;
        accountList.Website='test';
        accountList.type ='Merchant';
		//accountList.Owner_Email_ID__c='test002221223@cashfree.com';
        accountList.accountSource ='Partner Merchant Onboarding';
        Insert accountList;
        system.debug('Account:::'+accountList);
 
        List<AccountTeamMember> accountTeamMemberList=TestUtill.createTeamMemberRolelist(1);
        accountTeamMemberList[0].AccountId= accountList.Id;
        accountTeamMemberList[0].userId= userList[0].Id;
        accountTeamMemberList[0].TeamMemberRole='Account Manager';
        accountTeamMemberList[0].AccountAccessLevel='Edit';
        accountTeamMemberList[0].OpportunityAccessLevel='Edit';
        accountTeamMemberList[0].CaseAccessLevel='Read';
        insert accountTeamMemberList;
        
       User u =[SELECT Id, Name, Email FROM User where City='test1' LIMIT 1];
       u.Email='test1@test.com';
       //u[1].Email='test0022212234@cashfree.com';
       update u;
        
       AccountTeamMember accRec=[Select Id,AccountId,TeamMemberRole,UserId,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel From AccountTeamMember LIMIT 1];   
     
       Account accountRec = [SELECT Id, Name, MID__c, Primary_SPOC_Name__c, Primary_SPOC_Mobile__c, 
                                    Primary_SPOC_Email__c, Account_Holder_Name__c, Type, Industry, 
                                    Ownership, OwnerId, AccountSource, Referral_Id__c, Line_Of_Products__c, 
                                    Bank_Account_Number__c, Account_IFSC__c, Owner_Director_PAN_Number__c, 
                                    PAN__c, Registered_Name__c, Sub_LOB__c, Website 
                                    FROM Account];
        accountRec.Primary_SPOC_Email__c='test1@test.com';
        accountRec.OwnerId=u.Id;
        update accountRec;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/caseCreation'; //Request URL
        req.httpMethod = 'POST';
        
        String json = '{'+
		'    \"accountName\" : \"Cashfree Testing Account\",'+
		'    \"mid\" : \"001001\",'+
		'    \"phone\" : \"9807609654\",'+
		'    \"type\" : \"Merchant\",'+
		'    \"ownerEmailId\" : \"test002221223@cashfree.com\",'+
		'    \"accountSource\" : \"Partner Merchant Onboarding\",'+
		'    \"referralId\" : \"495\",'+
		'    \"lineOfProducts\" : \"Payment Gateway\",'+
		'    \"accountOwner\" : \"test002221223@cashfree.com\",'+
		''+
		'    \"teamMember\" : ['+
		'         {'+
		'            \"user\" : \"test1@test.com\",'+
		'            \"teamRole\" : \"Account Manager\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         },'+
		'         {'+
		'            \"user\" : \"abc@pqr.com\",'+
		'            \"teamRole\" : \"Sales Rep\",'+
		'            \"accountAccess\" : \"Edit\",'+
		'            \"caseAccess\" : \"Read\",'+
		'            \"opportunityAccess\" : \"Edit\"'+
		'         }'+
		'     ],'+
		''+
		'    \"primarySPOC\" : {'+
		'  \"primarySPOCName\" : \"Vikram Rathore\",'+
		'         \"email\" : \"test@xyz.com\",'+
		'         \"mobile\" : \"9807609654\"'+
		'     },'+
		''+
		'    \"otherDetails\" : {'+
		'        \"lob\" : \"Education\",'+
		'        \"subLob\" : \"EdTech\",'+
		'        \"registeredName\" : \"TestRegistered Name\",'+
		'        \"entityType\" : \"Partnership\",'+
		'        \"bankAccountNumber\" : \"4003830171874018\",'+
		'        \"accountIFSC\" : \"SBIN0011513\",'+
		'        \"owner_or_Director_PAN\" : \"KJDLAA5678A\",'+
		'        \"businessPAN\" : \"RLDOIA5678A\",'+
		'        \"website\" : \"www.cashfree.com\"'+
		'     },'+
		''+
		'    \"PartnerDetails\" : {'+
		'        \"pid\" : \"Test\",'+
		'        \"partnerName\" : \"EdTest\",'+
		'        \"partnerEmail\" : \"TestRegistered@gmail.com\",'+
		'        \"partnerPhone\" : \"9878765645\",'+
		'        \"partnerKycSpoc\" : \"Merchant\",'+
		'        \"partnerCareSpoc\" : \"Partner\"'+
		'     }'+
		''+
		'}';
        
        
        AccountCreationWrapper wrap = AccountCreationWrapper.parse(json);
        
        
        req.requestBody = blob.valueOf(json);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        AccountCreationWebservice.create_or_UpdateAccount();
        Test.stopTest();
        List<Account> accountList3 = new List<Account>();
        accountList3 = [SELECT Id, Name, MID__c, Primary_SPOC_Name__c, Primary_SPOC_Mobile__c, 
                                    Primary_SPOC_Email__c
                                    FROM Account
                                    WHERE MID__c =:wrap.mid];
        system.assert(accountList3.size()>0);
    }
	*/