@IsTest
public class CashfreeDataSynQueueTest {
 
    @isTest
    static void execute_Test() {
          Test.setMock(HttpCalloutMock.class, new AccountDocMappingMock());
         List<Banking__c> bankList = new List<Banking__c>();
        Banking__c bank = new Banking__c();
        bank.Name='SBI';
        bank.RM_Name__c='Test name';
        bankList.add(bank);
        insert bankList;
        List<Account> accList = TestUtill.createAccount(1);
        accList[0].Name='Test Account';
        accList[0].Type='Merchant';
        accList[0].Industry='Education';
        accList[0].Sub_LOB__c='EdTech';
        accList[0].MID__c='286329';
        accList[0].Website='www.test.com';
        accList[0].Registered_Name__c='Test Account';
        accList[0].BillingCity='Bangalore';
        accList[0].BillingCountry='India';
        accList[0].BillingPostalCode='800011';
        accList[0].BillingState='Karnataka';
        accList[0].ShippingCity='Karur';
        accList[0].ShippingCountry='India';
        accList[0].ShippingPostalCode='639201';
        accList[0].ShippingState='Tamil Nadu';
        accList[0].FBCLID__c=null;
        accList[0].GCLID__c=null;
        accList[0].UTM_Campaign__c=null;
        accList[0].UTM_Content__c=null;
        accList[0].UTM_Medium__c=null;
        accList[0].UTM_Source__c=null;
        accList[0].UTM_Term__c=null;
        accList[0].Bank_Account_Number__c='5100000000404390';
        accList[0].Account_IFSC__c='SBIN0125620';
        accList[0].Account_Holder_Name__c='Test Acc Holder';
        accList[0].Primary_SPOC_Email__c='test@gmail.com';
        accList[0].PID__c='23';
        accList[0].Primary_SPOC_Mobile__c='9000970355';
        accList[0].Banking__c=bankList[0].Id;
        insert accList;

       

        List<Contact> conList = TestUtill.createContact(2);
        conList[0].AccountId=accList[0].Id;
        conList[0].LastName='Test User';
        conList[0].Email='testuser@gmail.com';
        conList[0].Phone='9895948078';
        conList[1].AccountId=accList[0].Id;
        conList[1].LastName='Test User1';
        conList[1].Email='testuser1@gmail.com';
        conList[1].Phone='9534857172';
        insert conList;
 
        List<Case> caseList = TestUtill.createCase (1);
        caseList[0].AccountId= accList[0].Id;
        insert caseList;
           List<Case> caseList1 =[select Id from Case limit 1];
         // system.debug('case List:::::::'+caseList1);
          //system.debug('case List:::::::'+caseList1[0]);
          
          Test.startTest();
          CashfreeDataSynQueue dataSyn = new CashfreeDataSynQueue(caseList1[0].Id);
          ID jobID = System.enqueueJob(dataSyn);
          Test.stopTest();
    }



}

