@isTest
public class DocumentManagementControllerNew_test {
  @testSetup
  static void makeData() {
    List<Account> accountList = TestUtill.createAccount(1);
    // accountList[0].Industry='Education';
    accountList[0].Ownership = 'Private Limited';
    insert accountList;

    List<Opportunity> oppList = TestUtill.createOpportunity(1);
    oppList[0].AccountId = accountList[0].Id;
    insert oppList;

    List<Entitlement> entitle = TestUtill.createentitlement(2);
    entitle[0].Name = 'case support ent.';
    entitle[0].AccountId = accountList[0].Id;
    entitle[1].Name = 'Order support ent.';
    entitle[1].AccountId = accountList[0].Id;
    insert entitle;

    List<Case> caseList = TestUtill.createCase(5);
    for (Case caseRecord : caseList) {
      caseRecord.Opportunity__c = oppList[0].Id;
      caseRecord.AccountId = accountList[0].Id;
      //caseRecord.OwnerId = userlst[0].Id;
    }
    insert caseList;

    List<Cashfree_Document_Master__c> cashfreedoclist = TestUtill.createcashfreedoc(
      1
    );
    cashfreedoclist[0].KYC_Category__c = 'Regular';
    cashfreedoclist[0].Name = 'Private Limited';
    insert cashfreedoclist;

    List<Document_Type__c> documentlist = TestUtill.createdocumenttype(1);
    documentlist[0].Name = 'New';
    documentlist[0].Cashfree_Document_Master__c = cashfreedoclist[0].id;
    insert documentlist;

    List<Document_List__c> docnewlist = TestUtill.createdocumentlist(1);
    docnewlist[0].Document_Type__c = documentlist[0].Id;
    docnewlist[0].Name = 'app';
    insert docnewlist;

    List<Folder__c> folderlist = TestUtill.createfolder(1);
    folderlist[0].Document__c = 'appstraill';
    folderlist[0].Account__c = accountList[0].id;
    //folderlist[0].Name='app';
    folderlist[0].Node__c = 'Test';
    folderlist[0].Category_Type__c = 'Test';
    folderlist[0].Document_Type__c = documentlist[0].Name;
    insert folderlist;
    /*    
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=folderlist[0].id;
      //  contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
*/
  }
  @isTest
  static void getNodeType_test() {
    List<Cashfree_Document_Master__c> chasfreedoclist = [
      SELECT Id, Name, KYC_Category__c
      FROM Cashfree_Document_Master__c
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getNodeType();
    Test.stopTest();
  }
  @isTest
  static void getCategoryType_test() {
    Account accrec = [
      SELECT Id, Name, Ownership, Industry
      FROM Account
      LIMIT 1
    ];
    List<Cashfree_Document_Master__c> chasfreedoclist = [
      SELECT Id, Name, KYC_Category__c
      FROM Cashfree_Document_Master__c
      LIMIT 1
    ];
    system.debug(
      'chasfreedoclist[0].KYC_Category__c>>' +
      chasfreedoclist[0].KYC_Category__c
    );
    system.debug('chasfreedoclist>>' + chasfreedoclist);
    Test.startTest();
    String result = DocumentManagementControllerNew.getCategoryType(
      chasfreedoclist[0].KYC_Category__c,
      accrec.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getCategoryType_test1() {
    Opportunity opplist = [SELECT Id, Name, AccountId FROM Opportunity LIMIT 1];
    List<Cashfree_Document_Master__c> chasfreedoclist = [
      SELECT Id, Name, KYC_Category__c
      FROM Cashfree_Document_Master__c
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getCategoryType(
      chasfreedoclist[0].KYC_Category__c,
      opplist.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getCategoryType_test2() {
    Case caserec = [SELECT Id, AccountId FROM Case LIMIT 1];
    List<Cashfree_Document_Master__c> chasfreedoclist = [
      SELECT Id, Name, KYC_Category__c
      FROM Cashfree_Document_Master__c
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getCategoryType(
      chasfreedoclist[0].KYC_Category__c,
      caserec.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getDocumentType_test() {
    List<DocumentManagementControllerNew.DocumentTypeWrapper> wraplist = new List<DocumentManagementControllerNew.DocumentTypeWrapper>();
    DocumentManagementControllerNew.DocumentTypeWrapper wrap = new DocumentManagementControllerNew.DocumentTypeWrapper();
    wrap.documentTypeValue = 'test';
    wraplist.add(wrap);
    Account accrec = [
      SELECT Id, Name, Ownership, Industry
      FROM Account
      LIMIT 1
    ];
    List<Cashfree_Document_Master__c> chasfreedoclist = [
      SELECT Id, Name, KYC_Category__c
      FROM Cashfree_Document_Master__c
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getDocumentType(
      chasfreedoclist[0].Id,
      'New',
      'Test',
      accrec.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getDocumentType_test1() {
    Opportunity opplist = [SELECT Id, Name, AccountId FROM Opportunity LIMIT 1];
    List<Cashfree_Document_Master__c> chasfreedoclist = [
      SELECT Id, Name, KYC_Category__c
      FROM Cashfree_Document_Master__c
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getDocumentType(
      chasfreedoclist[0].Id,
      'New',
      'Test',
      opplist.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getDocumentType_test2() {
    Case caserec = [SELECT Id, AccountId FROM Case LIMIT 1];
    List<Cashfree_Document_Master__c> chasfreedoclist = [
      SELECT Id, Name, KYC_Category__c
      FROM Cashfree_Document_Master__c
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getDocumentType(
      chasfreedoclist[0].Id,
      'New',
      'Test',
      caserec.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getDocumentList_test() {
    Account accrec = [
      SELECT Id, Name, Ownership, Industry
      FROM Account
      LIMIT 1
    ];
    List<Document_Type__c> doclist = [
      SELECT Id, Name
      FROM Document_Type__c
      LIMIT 1
    ];

    Test.startTest();
    Folder__c folderlist = [
      SELECT Id, Name, Document__c, Document_Type__c, Category_Type__c
      FROM Folder__c
      LIMIT 1
    ];
    folderlist.Document__c = 'app';
    update folderlist;

    String result = DocumentManagementControllerNew.getDocumentList(
      doclist[0].Id,
      'New',
      'Test',
      'Test',
      accrec.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getDocumentList_test1() {
    Opportunity opplist = [SELECT Id, Name, AccountId FROM Opportunity LIMIT 1];
    List<Document_Type__c> doclist = [
      SELECT Id, Name
      FROM Document_Type__c
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getDocumentList(
      doclist[0].Id,
      'New',
      'Test',
      'Test',
      opplist.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getDocumentList_test2() {
    Case caserec = [SELECT Id, AccountId FROM Case LIMIT 1];
    List<Document_Type__c> doclist = [
      SELECT Id, Name
      FROM Document_Type__c
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getDocumentList(
      doclist[0].Id,
      'New',
      'Test',
      'Test',
      caserec.Id
    );
    Test.stopTest();
  }
  @isTest
  static void deleteFile_Test() {
    ContentVersion cv = new ContentVersion();
    cv.Title = 'Test Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    insert cv;
    List<ContentVersion> cvList = [
      SELECT Id, Title, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
    ];
    List<Folder__c> folderlist = [
      SELECT Id, Name, Document_Type__c, Category_Type__c
      FROM Folder__c
      LIMIT 1
    ];

    Test.startTest();
    string result = DocumentManagementControllerNew.deleteFile(
      cvList[0].ContentDocumentId,
      folderlist[0].Id
    );
    Test.stopTest();
    System.assert(result == 'done');
  }
  @isTest
  static void getAccountId_test() {
    Account accrec = [
      SELECT Id, Name, Ownership, Industry
      FROM Account
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getAccountId(accrec.Id);
    Test.stopTest();
  }
  @isTest
  static void getAccountId_test1() {
    Opportunity opplist = [SELECT Id, Name, AccountId FROM Opportunity LIMIT 1];
    Test.startTest();
    String result = DocumentManagementControllerNew.getAccountId(opplist.Id);
    Test.stopTest();
    system.assertEquals(result, result);
  }
  @isTest
  static void getAccountId_test2() {
    Case caserec = [SELECT Id, AccountId FROM Case LIMIT 1];
    Test.startTest();
    String result = DocumentManagementControllerNew.getAccountId(caserec.Id);
    Test.stopTest();
    system.assertEquals(result, result);
  }
  @isTest
  static void getStoredDocuments_test() {
    Account accrec = [
      SELECT Id, Name, Ownership, Industry
      FROM Account
      LIMIT 1
    ];
    Test.startTest();
    List<Folder__c> result = DocumentManagementControllerNew.getStoredDocuments(
      accrec.Id
    );
    Test.stopTest();
    system.assertEquals(result, result);
  }
  @isTest
  static void getStoredDocuments_test1() {
    Opportunity opplist = [SELECT Id, Name, AccountId FROM Opportunity LIMIT 1];
    Test.startTest();
    List<Folder__c> result = DocumentManagementControllerNew.getStoredDocuments(
      opplist.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getStoredDocuments_test2() {
    Case caserec = [SELECT Id, AccountId FROM Case LIMIT 1];
    Test.startTest();
    List<Folder__c> result = DocumentManagementControllerNew.getStoredDocuments(
      caserec.Id
    );
    Test.stopTest();
  }
  @isTest
  static void getFileSize_test() {
    ContentVersion cv = new ContentVersion();
    cv.Title = 'Test Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    insert cv;
    List<ContentVersion> cvList = [
      SELECT Id, Title, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.getFileSize(
      cvList[0].ContentDocumentId,
      '100000'
    );
    Test.stopTest();
  }
  @isTest
  static void updateFolder_Test() {
    Folder__c folderlist = [
      SELECT Id, Name, Document_Type__c, Category_Type__c
      FROM Folder__c
      LIMIT 1
    ];
    Test.startTest();
    String result = DocumentManagementControllerNew.updateFolder(folderlist);
    Test.stopTest();
    System.assert(result == 'done');
  }
  @isTest
  static void getFieldPicklistValue_Test() {
    DocumentManagementControllerNew.OptionsWrapper pickListWrap = new DocumentManagementControllerNew.OptionsWrapper();
    Test.startTest();
    List<DocumentManagementControllerNew.OptionsWrapper> result = DocumentManagementControllerNew.getFieldPicklistValue();
    Test.stopTest();
    system.assertEquals(result, result);
  }
  @isTest
  static void checkIfOppClosedOrNotoppo_Test() {
    Opportunity opplist = [SELECT Id, Name, AccountId FROM Opportunity LIMIT 1];
    Test.startTest();
    string result = DocumentManagementControllerNew.checkIfOppClosedOrNot(
      opplist.id
    );
    Test.stopTest();
    system.assertEquals(result, result);
  }
  @isTest
  static void checkIfOppClosedOrNotacc_Test() {
    Account accrec = [
      SELECT Id, Name, Ownership, Industry
      FROM Account
      LIMIT 1
    ];
    Test.startTest();
    string result = DocumentManagementControllerNew.checkIfOppClosedOrNot(
      accrec.id
    );
    Test.stopTest();
    system.assertEquals(result, result);
  }
  @isTest
  static void checkIfOppClosedOrNotcase_Test() {
    Case caserec = [SELECT Id, AccountId FROM Case LIMIT 1];
    Test.startTest();
    string result = DocumentManagementControllerNew.checkIfOppClosedOrNot(
      caserec.id
    );
    Test.stopTest();
    system.assertEquals(result, result);
  }

  @isTest
  static void createDocument_Test() {
    ContentVersion cv = new ContentVersion();
    cv.Title = 'Test Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    insert cv;
    List<ContentVersion> cvList = [
      SELECT Id, Title, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
    ];
    Folder__c folderlist = [
      SELECT Id, Name, Document_Type__c, Category_Type__c
      FROM Folder__c
      LIMIT 1
    ];
    ContentDocumentLink contentlink = new ContentDocumentLink();
    contentlink.ShareType = 'V';
    //contentlink.LinkedEntityId = folderlist.Id;
    contentlink.ContentDocumentId = cvList[0].ContentDocumentId;
    contentlink.Visibility = 'AllUsers';
    Test.startTest();
    String result = DocumentManagementControllerNew.createDocument(
      contentlink,
      folderlist,
      'No'
    );
    Test.stopTest();
    system.assertEquals(result, result);
  }
}
