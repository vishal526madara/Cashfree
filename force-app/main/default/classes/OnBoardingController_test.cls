@isTest
public class OnBoardingController_test {
  @testSetup
  static void makeData() {
    List<User> userlst = TestUtill.createUser(1);
    userlst[0].LastName = 'Test User@1';
    userlst[0].Division1__c = 'Outbound';
    insert userlst;

    List<Account> accountList = TestUtill.createAccount(1);
    accountList[0].OwnerId = userlst[0].Id;
    //  accountList[0].Division__c = 'Outbound';         ///////
    insert accountList;

    List<Contact> contactList = TestUtill.createContact(1);
    insert contactList;

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
      caseRecord.OwnerId = userlst[0].Id;
      caseRecord.AccountId = accountList[0].Id;
    }
    insert caseList;

    List<OpportunityContactRole> oppcontactlist = TestUtill.createoppcontactrole(
      1
    );
    oppcontactlist[0].OpportunityId = oppList[0].Id;
    oppcontactlist[0].ContactId = contactList[0].Id;
    insert oppcontactlist;

    List<Project_Milestone__c> onboardinglist = TestUtill.createProjectMilestone(
      1
    );
    insert onboardinglist;

    List<Checklist__c> checklist = TestUtill.createCheckList(1);
    checklist[0].Project_Milestone__c = onboardinglist[0].Id;
    insert checklist;

    List<Milestone_Task__c> miltasklist = TestUtill.createMileStoneTask(1);
    miltasklist[0].Checklist__c = checklist[0].Id;
    miltasklist[0].Select_Entity_Type__c = 'Public';
    insert miltasklist;

    List<Collected_Document__c> collecteddoclist = TestUtill.createcollecteddoc(
      1
    );
    insert collecteddoclist;

    List<Group> grouprec = TestUtill.creategroup(1);
    grouprec[0].Type = 'Queue';
    grouprec[0].Name = 'Outbound';

    insert grouprec;

    //  List<Task> tasklist =  TestUtill.createTask(1);
    //  Insert tasklist;

    List<Task> taskData = TestUtill.createTask(1);
    taskData[0].Description = 'Data Completed';
    //  taskData[0].Link__c='www.google.com';
    insert taskData;

    List<Opportunity_Product__c> oppoPro = TestUtill.createOpportunityProduct(
      1
    );
    oppoPro[0].Opportunity__c = oppList[0].id;
    insert oppoPro;
  }
  @isTest
  static void currentOpportunityRec_test() {
    Opportunity opplist = [SELECT Id, Name, AccountId FROM Opportunity LIMIT 1];
    Test.startTest();
    OnBoardingController.OpportunityDataWrapper result = OnBoardingController.currentOpportunityRec(
      opplist.id
    );
    Test.stopTest();
    System.debug('Result:::' + result);
  }
  @isTest
  static void updateAccount_test() {
    Account accrec = [
      SELECT Id, Name, Ownership, Industry
      FROM Account
      LIMIT 1
    ];
    List<OnBoardingController.AccountWrapper> wraplist = new List<OnBoardingController.AccountWrapper>();
    OnBoardingController.AccountWrapper wrap = new OnBoardingController.AccountWrapper();
    wrap.accountId = accrec.Id;
    wrap.cin = 'test';
    wrap.gst = '100';
    wrap.lob = 'Education';
    wrap.pan = 'Test';
    wrap.subLob = 'ERPs';
    wrap.phone = '9876543211';
    String jsonstring = JSON.serialize(wrap);
    Test.startTest();
    String result = OnBoardingController.updateAccount(jsonstring);
    Test.stopTest();
  }
  @isTest
  static void ChecklistTaskData_test() {
    List<Project_Milestone__c> projectlist = [
      SELECT Id, Name
      FROM Project_Milestone__c
      LIMIT 1
    ];
    List<Milestone_Task__c> miletasklist = [
      SELECT Id, Name, Select_Entity_Type__c
      FROM Milestone_Task__c
      LIMIT 1
    ];
    Test.startTest();
    List<OnBoardingController.ChecklistWrapper> result = OnBoardingController.ChecklistTaskData(
      projectlist[0].Id,
      'Public'
    );
    Test.stopTest();
  }
  ///////////////////////
  @isTest
  static void createCaseChecklist_Test() {
    User userRec = [
      SELECT Id, LastName
      FROM User
      WHERE LastName = 'Test User@1'
    ];

    Account accrec = [
      SELECT Id, Name, Ownership, Industry
      FROM Account
      LIMIT 1
    ];
    Group grouprec = [
      SELECT Id, Name
      FROM Group
      WHERE Name = 'Outbound'
      LIMIT 1
    ];
    System.runAs(new User(Id = userRec.Id)) {
      QueuesObject testQueue = new QueueSObject(
        QueueID = grouprec.id,
        SObjectType = 'Case'
      );
      insert testQueue;
    }

    // GroupMember groupmem = new GroupMember();
    //  groupmem.GroupId = grouprec.Id;
    //  groupmem.UserOrGroupId = userRec.Id;
    //  Insert groupmem;

    List<Milestone_Task__c> miltasklist = TestUtill.createMileStoneTask(1);
    insert miltasklist;
    List<Case> caserec = TestUtill.createCase(1);
    caserec[0].OwnerId = userRec.Id;
    List<Task> tskLst = [SELECT Id, OwnerId, ActivityDate FROM Task LIMIT 1];
    List<Checklist__c> checklist = [SELECT Id, Name FROM Checklist__c LIMIT 1];

    List<OnBoardingController.ChecklistWrapper> checkwraplist = new List<OnBoardingController.ChecklistWrapper>();
    List<OnBoardingController.TaskWrapper> taskwraplist = new List<OnBoardingController.TaskWrapper>();
    OnBoardingController.TaskWrapper taskwrap = new OnBoardingController.TaskWrapper();
    taskwrap.taskId = tskLst[0].Id;
    taskwrap.checklistId = checklist[0].Id;
    taskwrap.taskRec = miltasklist[0];
    taskwrap.checklistName = 'Test Check';
    taskwrap.selected = true;
    taskwraplist.add(taskwrap);
    system.debug('taskwraplist>>' + taskwraplist);
    OnBoardingController.ChecklistWrapper checkwrap = new OnBoardingController.ChecklistWrapper();
    checkwrap.Name = 'Test Check';
    checkwrap.checklistId = checklist[0].Id;
    checkwrap.taskList = taskwraplist;
    checkwrap.newTask = false;
    checkwraplist.add(checkwrap);
    List<OnBoardingController.DocChecklistWrapper> doccheckwraplist = new List<OnBoardingController.DocChecklistWrapper>();
    OnBoardingController.DocChecklistWrapper doccheckwrap = new OnBoardingController.DocChecklistWrapper();
    doccheckwrap.label = 'Test';
    doccheckwrap.selected = true;
    doccheckwraplist.add(doccheckwrap);
    Test.startTest();
    String result = OnBoardingController.createCaseChecklist(
      caserec[0],
      checkwraplist,
      doccheckwraplist,
      accrec.Id
    );
    Test.stopTest();
  }
  ////////////////////
  @isTest
  public static void caseChecklist_Test() {
    case casequery = [SELECT Id FROM case LIMIT 1];

    Case_Checklist__c caseCheck = new Case_Checklist__c();
    caseCheck.Case__c = casequery.Id;
    caseCheck.Name = 'appstraill';
    insert caseCheck;

    test.startTest();
    List<Case_Checklist__c> taskres = OnBoardingController.caseChecklist(
      caseCheck.Case__c
    );
    test.stopTest();
  }
  @isTest
  public static void updateTask_Test() {
    Task taskData = [SELECT Id FROM Task LIMIT 1];

    test.startTest();
    string taskres = OnBoardingController.updateTask(taskData.id, 'Open');
    test.stopTest();
  }
  @isTest
  public static void caseCollDocuments_Test() {
    case casequery = [SELECT Id FROM case LIMIT 1];

    test.startTest();
    List<Collected_Document__c> taskres = OnBoardingController.caseCollDocuments(
      casequery.id
    );
    test.stopTest();
  }
  @isTest
  public static void createTask_Test() {
    Account AccData = [SELECT Id FROM Account LIMIT 1];
    date duedate = system.today() + 10;
    test.startTest();
    string taskres = OnBoardingController.createTask(
      duedate,
      'subject',
      AccData.id
    );
    test.stopTest();
  }
  @isTest
  public static void deleteTask_Test() {
    Task taskData = [SELECT Id FROM Task LIMIT 1];

    test.startTest();
    string taskres = OnBoardingController.deleteTask(taskData.id);
    test.stopTest();
  }
  @isTest
  public static void updateTaskSubject_Test() {
    Task taskData = [SELECT Id FROM Task LIMIT 1];

    test.startTest();
    string taskres = OnBoardingController.updateTaskSubject(
      taskData.id,
      'subject data'
    );
    test.stopTest();
  }
  @isTest
  public static void createNewCaseChecklist_Test() {
    case casequery = [SELECT Id FROM case LIMIT 1];

    test.startTest();
    string taskres = OnBoardingController.createNewCaseChecklist(
      casequery.id,
      'checklist'
    );
    test.stopTest();
  }
  @isTest
  public static void getOptionsForApprovalType_Test() {
    case casequery = [SELECT Id FROM case LIMIT 1];

    test.startTest();
    List<OnBoardingController.OptionsWrapper> taskres = OnBoardingController.getOptionsForApprovalType(
      casequery.Id
    );
    test.stopTest();
  }
  @isTest
  public static void fetchSubLobPicklistValues_Test() {
    // case casequery =[SELECT Id FROM case limit 1];

    test.startTest();
    List<OnBoardingController.OptionsWrapper> taskres = OnBoardingController.fetchSubLobPicklistValues();
    test.stopTest();
  }
  @isTest
  public static void getOptionsForOwnershipPicklist_Test() {
    case casequery = [SELECT Id FROM case LIMIT 1];

    test.startTest();
    List<OnBoardingController.OptionsWrapper> taskres = OnBoardingController.getOptionsForOwnershipPicklist(
      casequery.Id
    );
    test.stopTest();
  }
  @isTest
  public static void getOptionsForOppApprovalType_Test() {
    case casequery = [SELECT Id FROM case LIMIT 1];

    test.startTest();
    List<OnBoardingController.OptionsWrapper> taskres = OnBoardingController.getOptionsForOppApprovalType(
      casequery.Id
    );
    test.stopTest();
  }
  @isTest
  public static void updateOpportunity_Test() {
    opportunity oppoquery = [SELECT Id FROM opportunity LIMIT 1];

    Test.startTest();
    String taskres = OnBoardingController.updateOpportunity(
      oppoquery.id,
      'Sales Approval',
      'comments',
      'Yes'
    );
    Test.stopTest();
    System.assert(taskres == 'success');
  }
  @isTest
  public static void updateCase_Test() {
    case casequery = [SELECT Id FROM case LIMIT 1];

    test.startTest();
    string taskres = OnBoardingController.updateCase(
      casequery.id,
      'Bank Approval',
      'Test Comment'
    );
    test.stopTest();
  }
  @isTest
  public static void updateDeviation_Test() {
    opportunity oppoquery = [SELECT Id FROM opportunity LIMIT 1];
    test.startTest();
    string taskres = OnBoardingController.updateDeviation(oppoquery.id, 'Yes');
    test.stopTest();
  }
  @isTest
  public static void createCaseWrapperVariable_Test() {
    opportunity oppoquery = [SELECT Id FROM opportunity LIMIT 1];

    test.startTest();
    OnBoardingController.CaseMappingWrapper taskres = OnBoardingController.createCaseWrapperVariable(
      oppoquery.id
    );
    test.stopTest();
  }
  @isTest
  public static void fetchContactRecord_Test() {
    contact conquery = [SELECT Id FROM contact LIMIT 1];

    test.startTest();
    contact taskres = OnBoardingController.fetchContactRecord(conquery.id);
    test.stopTest();
  }
  @isTest
  public static void checkDeviationAndCaseStatus_Test() {
    opportunity oppoquery = [SELECT Id FROM opportunity LIMIT 1];

    test.startTest();
    OnBoardingController.InitiateOnboardingWrapper taskres = OnBoardingController.checkDeviationAndCaseStatus(
      oppoquery.id
    );
    test.stopTest();
  }
  @isTest
  public static void createCaseSubjectName_Test() {
    opportunity oppoquery = [SELECT Id FROM opportunity LIMIT 1];

    test.startTest();
    OnBoardingController.CaseSubjectName taskres = OnBoardingController.createCaseSubjectName(
      oppoquery.id
    );
    test.stopTest();
  }
  @isTest
  public static void updateSingleTaskRecord_Test() {
    Task taskData = [SELECT Id, Subject, status, Link__c FROM Task LIMIT 1];

    List<OnBoardingController.TaskUpdateWrapper> wraplistt = new List<OnBoardingController.TaskUpdateWrapper>();
    OnBoardingController.TaskUpdateWrapper wrapinst = new OnBoardingController.TaskUpdateWrapper();
    wrapinst.taskId = taskData.id;
    wrapinst.Subject = ' Data Completed';
    wrapinst.status = 'Completed';
    wrapinst.Link = 'www.google.com';
    /*
        Task taskData = new Task();
        taskData.status='Open';
        taskData.Subject=' Data Completed';
        taskData.Link__c='www.google.com';  */
    //  taskData.Description='Data Completed';
    // insert taskData;

    //    taskData.status='Completed';
    //    update taskData;
    //update taskData;

    string jsonDataa = JSON.serialize(wrapinst);
    system.debug('jsonData>>' + jsonDataa);
    test.startTest();
    string taskres = OnBoardingController.updateSingleTaskRecord(jsonDataa);
    test.stopTest();
  }
  @isTest
  public static void getPaymentGatewayProduct_Test() {
    Opportunity_Product__c oppoProquery = [
      SELECT Id
      FROM Opportunity_Product__c
      LIMIT 1
    ];

    test.startTest();
    string taskres = OnBoardingController.getPaymentGatewayProduct(
      oppoProquery.id
    );
    test.stopTest();
  }
  @isTest
  public static void getingCaseId_Test() {
    case casequery = [SELECT Id FROM case LIMIT 1];

    test.startTest();
    string taskres = OnBoardingController.getingCaseId(casequery.id);
    test.stopTest();
  }
}
