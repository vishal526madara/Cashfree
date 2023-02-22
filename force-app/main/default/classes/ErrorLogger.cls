/**
 ** @File Name         : ErrorLogger.cls
 ** @Description       : This class is used to create the error records
 ** @author            : Saurav Kashyap
 ** @group             :
 ** @last modified on  : 12-01-2022
 **/
public class ErrorLogger {
  //SELECT , Line_Number__c, Error_Message__c,  FROM Error_Log__c
  public static String createErrorLogger(
    String className,
    String methodName,
    String expType,
    String expMessage,
    Integer lineNumber,
    String accountID
  ) {
    Error_Log__c ObjError = new Error_Log__c();
    ObjError.Class_Name__c = className;
    ObjError.Method_Name__c = methodName;
    ObjError.Exception_Type__c = expType;
    ObjError.Error_Message__c = expMessage;
    ObjError.Line_Number__c = String.valueOf(lineNumber);
    ObjError.Account__c = accountID;
    // ObjError.RecordTypeId = Schema.Sobjecttype.Error_Log__c.getRecordTypeInfosByName().get('Application Error').getRecordTypeId();
    insert ObjError;
    System.debug('Error Id :' + ObjError.Id);
    return ObjError.Id;
  }
}
