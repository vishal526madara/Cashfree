/**
 * @description       :
 * @author            :
 * @group             :
 * @last modified on  : 11-30-2022
 **/
public with sharing class CashfreeAPIUtil {
  public static List<Cashfree_API_Token__mdt> fetchAPIValue() {
    List<Cashfree_API_Token__mdt> tokenAPIList = new List<Cashfree_API_Token__mdt>();
    tokenAPIList = [
      SELECT Id, End_Point__c, Key__c
      FROM Cashfree_API_Token__mdt
      WHERE Active__c = TRUE
      LIMIT 1
    ];
    return tokenAPIList;
  }

  /**
   * @description : method to Create ErrorLog Object Records For any Exception from API Callouts
   * @parameter: Exception and Status Code Of API-response
   *@return: void
   */
  public static void generateErrorLog(
    Exception exceptionMessage,
    String className
  ) {
    Error_Log__c log = new Error_Log__c();
    log.Class_Name__c = className;
    log.Error_Message__c = exceptionMessage.getMessage();
    insert log;
  }
}
