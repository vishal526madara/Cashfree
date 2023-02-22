/**
 ** @File Name         : API_Logger.cls
 ** @Description       : This class is used to create the apiLogger records
 ** @author            : Saurav Kashyap
 ** @group             :
 ** @last modified on  : 12-01-2022
 **/
public class API_Logger {
  public static String createAPI_Logger(
    String className,
    String request,
    String response,
    String endPointURL,
    String StatusCode,
    String accountID
  ) {
    API_Logger__c ObjectAPILog = new API_Logger__c();
    ObjectAPILog.Class_Name__c = className;
    ObjectAPILog.Request__c = request;
    ObjectAPILog.Response__c = response;
    ObjectAPILog.EndPoint_URL__c = endPointURL;
    ObjectAPILog.Status_Code__c = StatusCode;
    ObjectAPILog.Account__c = accountID;
    // ObjectAPILog.RecordTypeId = Schema.Sobjecttype.API_Logger__c.getRecordTypeInfosByName().get('Application Error').getRecordTypeId();
    insert ObjectAPILog;
    System.debug('API--LOGGER Id :' + ObjectAPILog.Id);
    return ObjectAPILog.Id;
  }
}
