/**
 * @description       : RaiseCaseControllerTest for raiseCaseCustomComponent's Controller
 * @author            : Saurav Kashyap
 * @group             : Self Group
 * @last modified on  : 11-18-2022
 **/
@isTest
public class RaiseCaseControllerTest {
  //creating a temporary DB
  @testSetup
  static void makeData() {
    //structure data from test.utils

    //account record
    List<Account> returnList = TestUtill.createAccount(1);
    insert returnList;

    //case record
    List<Case> caseList = TestUtill.createCase(1);
    caseList[0].Origin = 'Internal';
    insert caseList;

    //
    Entitlement et = new Entitlement();
    et.Name = 'Order support ent.';
    et.AccountId = returnList[0].Id;
    insert et;

    ////workorder record
    List<WorkOrder> workorderlist = TestUtill.createworkorder(1);
    workorderlist[0].AccountId = returnList[0].Id;
    workorderlist[0].CaseId = caseList[0].Id;
    workorderlist[0].EntitlementId = et.Id;
    insert workorderlist;

    //Discrepancy__c record
    Discrepancy__c discrepancyRecList = new Discrepancy__c();
    discrepancyRecList.Discrepancy_Values__c = 'This instrument is not allowed for your business category. If you would like to get your category changed, you can raise a request for the same.';
    insert discrepancyRecList;
  }

  //Positive Case Scenario....
  @isTest
  static void getDiscrepancy_Test() {
    //querying data from Temporary DB
    List<RaiseCaseController.DiscrepancyWrapper> dw = new List<RaiseCaseController.DiscrepancyWrapper>();
    //creating an object instance of Discrepancy__c
    Discrepancy__c discrepancyRecList = new Discrepancy__c();
    discrepancyRecList.Discrepancy_Values__c = 'This instrument is not allowed for your business category. If you would like to get your category changed, you can raise a request for the same.';
    insert discrepancyRecList;

    //startTest and StopTest Method Implementation
    Test.startTest();
    dw = RaiseCaseController.getDiscrepancy();
    Test.stopTest();
    // Checking the output using assert method
    System.assert(dw != null);
  }

  //Positive Case Scenario
  @isTest
  static void insertCases_Test() {
    //querying data from Temporary DB
    List<WorkOrder> workorderlist = [
      SELECT Id, AccountId, CaseId, Status, WorkOrderNumber, MID__c
      FROM WorkOrder
    ];
    //creating an object instance of Discrepancy
    List<RaiseCaseController.DiscrepancyWrapper> dw = new List<RaiseCaseController.DiscrepancyWrapper>();
    RaiseCaseController.DiscrepancyWrapper wrap = new RaiseCaseController.DiscrepancyWrapper();
    wrap.caseForValue = 'SC';
    wrap.discrepValue = 'This instrument is not allowed for your business category. If you would like to get your category changed, you can raise a request for the same.';
    dw.add(wrap);

    Boolean b;
    //startTest and StopTest Method Implementation
    Test.startTest();
    b = RaiseCaseController.insertCases(workorderlist[0].Id, dw);
    Test.stopTest();
    // Checking the output using assert method
    System.assert(b != false);
  }

  //Positive Case Scenario
  @isTest
  static void getFieldPicklistValue_Test() {
    //querying data from Temporary DB
    List<RaiseCaseController.OptionsWrapper> dw = new List<RaiseCaseController.OptionsWrapper>();
    //RaiseCaseController.OptionsWrapper wrap = new RaiseCaseController.OptionsWrapper();
    //startTest and StopTest Method Implementation
    Test.startTest();
    dw = RaiseCaseController.getFieldPicklistValue(
      'WorkOrder',
      'Discrepancy__c'
    );
    Test.stopTest();
    // Checking the output using assert method
    System.assert(dw != null);
  }
}
