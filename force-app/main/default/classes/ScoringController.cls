/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 10-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class ScoringController {
  public class DataWrapper {
    /*@AuraEnabled public Decimal budgetConfirm {get;set;}
        @AuraEnabled public Decimal decisionMaker {get;set;}
        @AuraEnabled public Decimal timeLine {get;set;}
        @AuraEnabled public Decimal rating {get;set;}
        @AuraEnabled public Decimal totalScore {get;set;}*/
    @AuraEnabled
    public String age { get; set; }
    @AuraEnabled
    public String dateSinceLastActivity { get; set; }
    @AuraEnabled
    public String firstCall { get; set; }
    @AuraEnabled
    public String lastCall { get; set; }
  }

  @AuraEnabled
  public static DataWrapper getScore(Id recordId) {
    DataWrapper result = new DataWrapper();
    DataWrapper activityWrapper = new DataWrapper();
    /* if(recordId.getSObjectType().getDescribe().getName() == 'Account'){
           Account acc = [Select Id,Age__c,Days_Since_Last_Activity__c From Account Where Id =: recordId];
           result = createWrapperValue(	acc.Budget_Confirmed__c,acc.Decision_Maker__c,acc.Rating,acc.Time_Frame__c);
           activityWrapper = createActivity(recordId,acc.Age__c,acc.Days_Since_Last_Activity__c);
           result.age = activityWrapper.age;
           result.dateSinceLastActivity = activityWrapper.dateSinceLastActivity;
           result.firstCall = activityWrapper.firstCall;
           result.lastCall = activityWrapper.lastCall;
        }*/
    if (recordId.getSObjectType().getDescribe().getName() == 'Lead') {
      Lead lead = [
        SELECT
          Id,
          Age__c,
          Days_Since_Last_Activity__c,
          Budget_Confirmed__c,
          Decision_Maker__c,
          Rating,
          Time_Frame__c
        FROM Lead
        WHERE Id = :recordId
      ];
      //result = createWrapperValue(lead.Budget_Confirmed__c,lead.Decision_Maker__c,lead.Rating,lead.Time_Frame__c);
      activityWrapper = createActivity(
        recordId,
        null,
        lead.Days_Since_Last_Activity__c
      );
      result.age = lead.Age__c;
      result.dateSinceLastActivity = activityWrapper.dateSinceLastActivity;
      result.firstCall = activityWrapper.firstCall;
      result.lastCall = activityWrapper.lastCall;
    } else {
      Opportunity opp = [
        SELECT Id, Age__c, Days_Since_Last_Activity__c
        FROM Opportunity
        WHERE Id = :recordId
      ];
      //result = createWrapperValue(opp.Budget_Confirmed__c,opp.Decision_Maker__c,opp.Rating__c,opp.Time_Frame__c);
      activityWrapper = createActivity(
        recordId,
        String.valueOf(opp.Age__c),
        opp.Days_Since_Last_Activity__c
      );
      result.age = opp.Age__c; //activityWrapper.age;
      result.dateSinceLastActivity = activityWrapper.dateSinceLastActivity;
      result.firstCall = activityWrapper.firstCall;
      result.lastCall = activityWrapper.lastCall;
    }
    return result;
  }

  /* private static DataWrapper createWrapperValue(Boolean budgetConfirmed, Boolean decisionMaker, String rating, String timeLine){
        DataWrapper result = new DataWrapper();
        result.budgetConfirm = 0;
        result.decisionMaker=0;
        result.timeLine=0;
        result.rating=0;
        result.totalScore=0;
        
        if(budgetConfirmed){
            result.budgetConfirm = 25;
        }
        
        if(decisionMaker){
            result.decisionMaker = 25;
        }
        
        switch on rating{
            when 'Hot'{
                result.rating = 25;
            }
            When 'Warm'{
                result.rating = 15;
            }
            When 'Cold'{
                result.rating = 10;
            }
        }
        
        switch on timeLine{
            When 'Immediately'{
                result.timeLine = 25;
            }
             When '15 Days'{
                result.timeLine = 15;
            }
             When '	One Month'{
                result.timeLine = 10;
            }
             When 'Two Three Month'{
                result.timeLine = 5;
            }
             When 'Indefinite'{
                result.timeLine = 0;
            }
        }
        
        result.totalScore = result.budgetConfirm + result.decisionMaker + result.timeLine + result.rating;
        return result;
    }*/

  private static DataWrapper createActivity(
    Id recordId,
    String age,
    Decimal activityDay
  ) {
    DataWrapper result = new DataWrapper();
    List<Event> mainEventList = new List<Event>();
    List<Task> mainTaskList = new List<Task>();
    if (
      Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Lead'
    ) {
      mainEventList = [
        SELECT Id, Subject, CreatedDate, WhatId, WhoId
        FROM Event
        WHERE WhoId = :recordId
      ];
      mainTaskList = [
        SELECT Id, Subject, CreatedDate, WhatId, WhoId
        FROM Task
        WHERE WhoId = :recordId
      ];
    } else {
      mainEventList = [
        SELECT Id, Subject, CreatedDate, WhatId, WhoId
        FROM Event
        WHERE WhatId = :recordId
      ];
      mainTaskList = [
        SELECT Id, Subject, CreatedDate, WhatId, WhoId
        FROM Task
        WHERE WhatId = :recordId
      ];
    }

    result.dateSinceLastActivity = String.valueOf(activityDay) + ' Days';
    result.age = String.valueOf(age) + ' Days';
    if (mainEventList.size() == 0 && mainTaskList.size() == 0) {
      result.firstCall = 'Not Started';
      result.lastCall = 'Not Started';
    } else if (mainEventList.size() != 0 && mainTaskList.size() != 0) {
      //Event Under Action
      //Initialisation
      DateTime eventFirstCreated = mainEventList[0].CreatedDate;
      DateTime eventLastCreated = mainEventList[0].CreatedDate;
      for (Event eventVar : mainEventList) {
        //If() targeting for FIRST
        if (eventFirstCreated >= eventVar.CreatedDate) {
          eventFirstCreated = eventVar.CreatedDate;
        }
        //If() targeting for LAST
        if (eventLastCreated <= eventVar.CreatedDate) {
          eventLastCreated = eventVar.CreatedDate;
        }
      }
      //Task Under Action
      //Initialisation
      DateTime taskFirstCreated = mainTaskList[0].CreatedDate;
      DateTime taskLastCreated = mainTaskList[0].CreatedDate;
      for (task taskVar : mainTaskList) {
        //If() targeting for FIRST
        if (taskFirstCreated >= taskVar.CreatedDate) {
          taskFirstCreated = taskVar.CreatedDate;
        }
        //If() targeting for LAST
        if (taskLastCreated <= taskVar.CreatedDate) {
          taskLastCreated = taskVar.CreatedDate;
        }
      }
      //First Interaction Pairing
      if (taskFirstCreated < eventFirstCreated) {
        result.firstCall = taskFirstCreated.format();
      } else {
        result.firstCall = eventFirstCreated.format();
      }
      //Last Interaction Pairing
      if (taskLastCreated > eventLastCreated) {
        result.lastCall = taskLastCreated.format();
      } else {
        result.lastCall = eventLastCreated.format();
      }
    } else if (mainEventList.size() == 0 && mainTaskList.size() != 0) {
      //Task Under Action
      //Initialisation
      DateTime taskFirstCreated = mainTaskList[0].CreatedDate;
      DateTime taskLastCreated = mainTaskList[0].CreatedDate;
      for (task taskVar : mainTaskList) {
        //If() targeting for FIRST
        if (taskFirstCreated >= taskVar.CreatedDate) {
          taskFirstCreated = taskVar.CreatedDate;
        }
        //If() targeting for LAST
        if (taskLastCreated <= taskVar.CreatedDate) {
          taskLastCreated = taskVar.CreatedDate;
        }
      }
      result.firstCall = taskFirstCreated.format();
      result.lastCall = taskLastCreated.format();
    } else if (mainEventList.size() != 0 && mainTaskList.size() == 0) {
      //Event Under Action
      //Initialisation
      DateTime eventFirstCreated = mainEventList[0].CreatedDate;
      DateTime eventLastCreated = mainEventList[0].CreatedDate;
      for (Event eventVar : mainEventList) {
        //If() targeting for FIRST
        if (eventFirstCreated >= eventVar.CreatedDate) {
          eventFirstCreated = eventVar.CreatedDate;
        }
        //If() targeting for LAST
        if (eventLastCreated <= eventVar.CreatedDate) {
          eventLastCreated = eventVar.CreatedDate;
        }
      }
      result.firstCall = eventFirstCreated.format();
      result.lastCall = eventLastCreated.format();
    }
    return result;
  }
}
