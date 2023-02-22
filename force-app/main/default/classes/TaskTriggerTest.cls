@isTest
public class TaskTriggerTest {
    @testSetup
    Public static void createSampleRecords(){
        
        List<Case> ParentCaseList=new List<Case>();
        for(Integer i=0;i<2;i++){
        Case Parentcase=new Case();
        Parentcase.Status='Pending';
        ParentCaseList.add(Parentcase);
        }
        Insert ParentCaseList;
        
        
        List<Case> ChildCaseList=new List<Case>();
        for(integer i=0;i<5;i++){
            Case Childcase=new Case();
            Childcase.Status='New';
            Childcase.ParentId=ParentCaseList[0].Id;
            ChildCaseList.add(Childcase);
        }
               
        Insert ChildCaseList;
        
        List<Task>TaskList=new List<Task>();
            
        Task task1=new Task();
        task1.Subject='To complete the Task';
        task1.Priority='Normal';
        task1.WhatId=ParentCaseList[0].Id;
        task1.Description='Task Successfully Complted';
        task1.Status='open';
        TaskList.add(task1);
        
        Task task2=new Task();
        task2.Subject='To complete the Task';
        task2.Priority='Medium';
        task2.WhatId=ParentCaseList[0].Id;
        task2.Description='Task Successfully Complted';
        task2.Status='Open';
        TaskList.add(task2);
        
        Task task3=new Task();
        task3.Subject='To complete the Task';
        task3.Priority='Normal';
        task3.WhatId=ParentCaseList[1].Id;
        task3.Description='Task Successfully Complted';
        task3.Status='Open';
        TaskList.add(task3);
        
        Insert TaskList;
        
     
    }
    
    @istest
    Public static void taskTriggerTestMethod(){
        
        List<Case> ParentCaseList=[select Id , Status from Case];
        List<Case> ChildCaseList=[select Id ,ParentId, Status from Case where Status='Pending' AND ParentId in :ParentCaseList];
        List<Task> TaskListtoUpdate=[select Subject,WhatId,Status,Priority from Task where WhatId in :ParentCaseList AND Status='Open'AND Priority='Normal'];
        
        for(Task tsk:TaskListtoUpdate){
            tsk.Status='Completed';
        }
      
        Test.startTest();
        Update TaskListtoUpdate;
        Test.stopTest();
        }
  
}