@isTest
public class CaseTriggerTest {
  @isTest
  public static void insertRecordTest1() {
    Case caseRec = new Case();
    caseRec.Case_For__c = 'SC';
    insert caseRec;
  }

  @isTest
  public static void insertRecordTest2() {
    Case caseRec = new Case();
    caseRec.Case_For__c = 'Risk Team';
    insert caseRec;
  }

  @isTest
  public static void insertRecordTest3() {
    Case caseRec = new Case();
    caseRec.Case_For__c = 'Bank Ops Team';
    insert caseRec;
  }

  @isTest
  public static void insertRecordTest4() {
    Case caseRec = new Case();
    caseRec.Case_For__c = 'Onboarding Team';
    insert caseRec;
  }

  @testSetup
  public static void createSampleData() {
    List<Case> ParentCaseList = new List<Case>();
    for (Integer i = 0; i < 2; i++) {
      Case Parentcase = new Case();
      Parentcase.Status = 'Pending';
      ParentCaseList.add(Parentcase);
    }
    insert ParentCaseList;

    List<Case> ChildCaseList = new List<Case>();
    for (integer i = 0; i < 5; i++) {
      Case Childcase = new Case();
      Childcase.Status = 'New';
      Childcase.Description = 'Task Succesfully Completed';
      Childcase.ParentId = ParentCaseList[0].Id;
      ChildCaseList.add(Childcase);
    }

    for (integer i = 0; i < 5; i++) {
      Case Childcase = new Case();
      Childcase.Status = 'New';
      Childcase.Description = 'Task Succesfully Completed';
      Childcase.ParentId = ParentCaseList[1].Id;
      ChildCaseList.add(Childcase);
    }
    insert ChildCaseList;

    List<Task> TaskList = new List<Task>();

    Task Task1 = new Task();
    Task1.Subject = 'To complete the Task';
    Task1.Priority = 'Normal';
    Task1.WhatId = ParentCaseList[0].Id;
    Task1.Description = 'Task Successfully Complted';
    Task1.Status = 'open';
    TaskList.add(Task1);

    Task Task2 = new Task();
    Task2.Subject = 'To complete the Task';
    Task2.Priority = 'Medium';
    Task2.WhatId = ParentCaseList[0].Id;
    Task2.Description = 'Task Successfully Complted';
    Task2.Status = 'open';
    TaskList.add(Task2);

    Task Task3 = new Task();
    Task3.Subject = 'To complete the Task';
    Task3.Priority = 'Normal';
    Task3.WhatId = ParentCaseList[1].Id;
    Task3.Description = 'Task Successfully Complted';
    Task3.Status = 'open';
    TaskList.add(Task3);
  }

  @isTest
  public static Void updateRecordTest1() {
    List<case> ParentCaseList = [
      SELECT Id, Status
      FROM Case
      WHERE Status = 'Pending'
    ];
    List<case> ChildCaseList = [
      SELECT Id, Status, ParentId
      FROM Case
      WHERE Status = 'New'
    ];
    List<Task> TaskList = [
      SELECT Subject, WhatId, Status, Priority
      FROM Task
      WHERE
        WhatId IN :ParentCaseList
        AND Status = 'Open'
        AND Priority = 'Normal'
    ];
    List<Case> ChildCaseList2 = new List<Case>();
    for (Case Case1 : ChildCaseList) {
      case1.status = 'Closed';
      ChildCaseList2.add(case1);
    }

    Test.startTest();
    update ChildCaseList2;
    Test.stopTest();
  }
}
