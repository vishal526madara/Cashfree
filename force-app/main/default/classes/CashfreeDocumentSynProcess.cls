/**
 * @Description: functionality of this class is used to Generate json body of account and response
 * @author: Vishal Hembrom
 * *********************/
public without sharing class CashfreeDocumentSynProcess {

    public static void  jsonBodyCreation(Id caseRecordId){
      Case caseRecord = [Select Id,AccountId From Case Where Id =: caseRecordId];

      //udateDate : 21 March, 2023
      Account acc = [Select Id,Name, Type, Industry, Sub_LOB__c, Website, Registered_Name__c, BillingCity, BillingCountry, BillingPostalCode, 
                     BillingState, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, FBCLID__c, 
                     GCLID__c, UTM_Campaign__c, UTM_Content__c, UTM_Medium__c, UTM_Source__c, UTM_Term__c, Parent.Name,
                     Banking__r.Name, Banking__r.RM_Name__c, Bank_Account_Number__c, Account_IFSC__c, 
                     Account_Holder_Name__c, Primary_SPOC_Email__c, MID__c, PID__c, Primary_SPOC_Mobile__c,
                     GST__c,CIN__c,
                     (Select Id,Name,Email,Phone From Contacts) 
                     From Account Where Id =: caseRecord.AccountId];

   DataSyncWrapper.Analytics accountAnalytics = new DataSyncWrapper.Analytics();
   accountAnalytics.fbclid = acc.FBCLID__c; 
   accountAnalytics.gclid = acc.GCLID__c;
   accountAnalytics.utmCampaign = acc.UTM_Campaign__c;
   accountAnalytics.utmContent = acc.UTM_Content__c;
   accountAnalytics.utmMedium = acc.UTM_Medium__c;
   accountAnalytics.utmSource = acc.UTM_Source__c;
   accountAnalytics.utmTerm = acc.UTM_Term__c;
   accountAnalytics.parentAccount = acc.Parent.Name;
   accountAnalytics.bankName = acc.Banking__r.Name;
   accountAnalytics.bankRMName = acc.Banking__r.RM_Name__c;

   List<DataSyncWrapper.Addresses> finalAddressList = new List<DataSyncWrapper.Addresses>();

   DataSyncWrapper.Addresses billingAddress = new DataSyncWrapper.Addresses();
   //billingAddress.addressType = 
   //billingAddress.address = 
   billingAddress.city = acc.BillingCity;
   billingAddress.country = acc.BillingCountry;
   billingAddress.pinCode = acc.BillingPostalCode;
   billingAddress.state = acc.BillingState;
   finalAddressList.add(billingAddress);


   DataSyncWrapper.Addresses shippingAddress = new DataSyncWrapper.Addresses();
   //billingAddress.addressType = 
   //billingAddress.address = 
   shippingAddress.city = acc.ShippingCity;
   shippingAddress.country = acc.ShippingCountry;
   shippingAddress.pinCode = acc.ShippingPostalCode;
   shippingAddress.state = acc.ShippingState;
   finalAddressList.add(shippingAddress);


   List<DataSyncWrapper.ContactUser> contactList = new List<DataSyncWrapper.ContactUser>();

   for(Contact con : acc.Contacts){
    DataSyncWrapper.ContactUser contactRecord = new DataSyncWrapper.ContactUser();
    contactRecord.email = con.Email;
    contactRecord.name = con.Name;
    contactRecord.phone = con.Phone;
    contactList.add(contactRecord);
   }
                     
   DataSyncWrapper.DataRequest dataRequest = new DataSyncWrapper.DataRequest();
   dataRequest.businessName = acc.Name != null ? acc.Name :'';
   //dataRequest.orgType
   dataRequest.merchantType = acc.Industry != null ? acc.Industry :'';
   dataRequest.websiteUrl = acc.Website != null ? acc.Website  :'';
   dataRequest.businessRegisteredName = acc.Registered_Name__c != null ? acc.Registered_Name__c :'';
   dataRequest.analytics = accountAnalytics ;
   dataRequest.bankAccountNumber = acc.Bank_Account_Number__c != null ? acc.Bank_Account_Number__c :'';
   dataRequest.bankIFSC = acc.Account_IFSC__c != null ? acc.Account_IFSC__c :'';
   dataRequest.bankAccountHolderName = acc.Account_Holder_Name__c != null ? acc.Account_Holder_Name__c :'';
   dataRequest.addresses = finalAddressList;
   dataRequest.contactList = contactList;
   dataRequest.merchantEmail = acc.Primary_SPOC_Email__c != null ? acc.Primary_SPOC_Email__c :'';
   if(acc.MID__c != null){
    dataRequest.merchantId = Integer.valueOf(acc.MID__c);
   }
   if(acc.PID__c != null){
    dataRequest.partnerId = Integer.valueOf(acc.PID__c);
   }
   dataRequest.merchantPhone = acc.Primary_SPOC_Mobile__c != null ? acc.Primary_SPOC_Mobile__c :'';
   //dataRequest.salesManager = 
   //dataRequest.accountSource = 
   dataRequest.subLob = acc.Sub_LOB__c != null ? acc.Sub_LOB__c :'';

   //updateDate : 21 March, 2023
   dataRequest.gstin = String.isBlank(acc.GST__c) ? acc.GST__c : null;
   dataRequest.cin = String.isBlank(acc.CIN__c) ? acc.CIN__c : null;

   String jsonResponse = CashfreeDataSync.accountDataSync(dataRequest);
   if(jsonResponse == 'Pass'){
    Case updateCase = new Case();
    updateCase.Id = caseRecordId;
    //updateCase.Cashfree_Sync__c = true;

     //Database.SaveResult caseResult = Database.update(updateCase,true);
    }

    }
   
}