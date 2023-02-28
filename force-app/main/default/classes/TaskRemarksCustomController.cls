/**
 * @description       :
 * @author            : Saurav Kashyap
 * @group             : SK Group
 * @last modified on  : 23-01-2023
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   23-01-2023   Saurav Kashyap   Initial Version
 **/
public with sharing class TaskRemarksCustomController {
  /**
   * @description
   * @author Saurav Kashyap | 23-01-2023
   * @param String recordId
   * @return List<DataWrapper>
   **/
  @AuraEnabled
  public static List<DataWrapper> getTask(String recordId) {
    List<Task> taskList = new List<Task>();
    List<Remarks__c> remarksList = new List<Remarks__c>();
    if (recordId != null) {
      taskList = [
        SELECT Id, Description, Subject, Status
        FROM Task
        WHERE Id = :recordId
      ];
      remarksList = [
        SELECT
          Id,
          CreatedDate,
          CreatedById,
          CreatedBy.Name,
          LastModifiedDate,
          Remarks__c,
          TaskID__c
        FROM Remarks__c
        WHERE TaskID__c = :recordId
      ];
    }

    List<DataWrapper> datawraplists = new List<DataWrapper>();
    for (Remarks__c taskcom : remarksList) {
      DataWrapper datawrp = new DataWrapper();
      datawrp.Comment = taskcom.Remarks__c;
      datawrp.taskIdWrap = taskcom.TaskID__c;
      datawrp.remarkIdWrap = taskcom.Id;
      datawrp.lastModifyDate = taskcom.LastModifiedDate;
      datawrp.createddate = taskcom.CreatedDate;
      datawrp.createdByName = taskcom.CreatedBy.Name;
      datawraplists.add(datawrp);
    }
    return datawraplists;
  }

  /**
   * @description
   * @author Saurav Kashyap | 23-01-2023
   * @param String recordId
   * @param String newValue
   * @return string
   **/
  @AuraEnabled
  public static string saveTask(String recordId, String newValue) {
    Remarks__c remarksObject = new Remarks__c();
    remarksObject.Remarks__c = newValue;
    remarksObject.TaskID__c = recordId;
    insert remarksObject;
    return 'success';
  }

  /**
   * @description
   * @author Saurav Kashyap | 23-01-2023
   * @param String taskcommentId
   * @param List<DataWrapper> datawraplist
   * @return string
   **/
  @AuraEnabled
  public static string updateTask(
    String taskcommentId,
    List<DataWrapper> datawraplist
  ) {
    List<Remarks__c> remarksList = new List<Remarks__c>();
    for (DataWrapper datawrap : datawraplist) {
      Remarks__c tskCommentupdate = new Remarks__c();
      tskCommentupdate.Remarks__c = datawrap.Comment;
      tskCommentupdate.Id = datawrap.remarkIdWrap;
      remarksList.add(tskCommentupdate);
    }
    if (remarksList.size() > 0) {
      update remarksList;
    }
    return 'success';
  }

  /**
   * @description
   * @author Saurav Kashyap | 23-01-2023
   * @param String taskcommentId
   * @return string
   **/
  @AuraEnabled
  public static string deletetaskcomment(String taskcommentId) {
    List<Remarks__c> remarksList = new List<Remarks__c>();
    if (taskcommentId != null) {
      remarksList = [
        SELECT
          Id,
          CreatedDate,
          CreatedById,
          CreatedBy.Name,
          LastModifiedDate,
          Remarks__c,
          TaskID__c
        FROM Remarks__c
        WHERE Id = :taskcommentId
      ];
    }
    if (remarksList.size() > 0) {
      delete remarksList;
    }
    return 'success';
  }

  /***
   * @author: Vishal(Appstrail Developer)
   * @createDate: 13 Feb, 2023
   *
   */

  @AuraEnabled
  public static void bulkRemarkInsertion(
    String taskId,
    String jsonRemarksList
  ) {
    try {
      List<DataWrapper> remarksList = (List<DataWrapper>) JSON.deserialize(
        jsonRemarksList,
        List<DataWrapper>.class
      );
      List<Remarks__c> newRemarksList = new List<Remarks__c>();

      for (DataWrapper remarkRecord : remarksList) {
        Remarks__c remark = new Remarks__c();
        remark.TaskID__c = taskId;
        remark.Remarks__c = remarkRecord.Comment;
        newRemarksList.add(remark);
      }
      List<Database.SaveResult> remarksResult = Database.insert(
        newRemarksList,
        true
      );
    } catch (Exception e) {
      System.debug('Exec:::' + e.getLineNumber());
      throw new AuraHandledException(e.getMessage());
    }
  }

  // Wrapper for details
  public class DataWrapper {
    @AuraEnabled
    public String Comment { get; set; }
    @AuraEnabled
    public String remarkIdWrap { get; set; }
    @AuraEnabled
    public String taskIdWrap { get; set; }
    @AuraEnabled
    public Datetime lastModifyDate { get; set; }
    @AuraEnabled
    public Datetime createddate { get; set; }
    @AuraEnabled
    public String createdByName { get; set; }
  }
}
