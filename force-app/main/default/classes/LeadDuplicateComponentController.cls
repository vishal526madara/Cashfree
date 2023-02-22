/**
 * @description       :
 * @author            : Saurav Kashyap
 * @group             : Self Group
 * @last modified on  : 10-13-2022
 **/
public with sharing class LeadDuplicateComponentController {
  @AuraEnabled
  public static List<Lead> getLeadRecords(string recordId) {
    List<Lead> leadList = new List<Lead>();
    Lead leadRecord = new Lead();
    leadRecord = [
      SELECT Id, LastName, MobilePhone, Phone, Email, CreatedDate
      FROM Lead
      WHERE Id = :recordId
    ];
    System.debug('leadRecord for size checck >>' + leadRecord);

    leadList = [
      SELECT Id, LastName, MobilePhone, Phone, Email, CreatedDate
      FROM Lead
      WHERE Phone = :leadRecord.Phone AND Id != :recordId AND Phone != NULL
    ];
    System.debug('leadList for size checck >>' + leadList);

    return leadList;
  }
}
