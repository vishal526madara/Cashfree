/**
 * @description: Sf -----> Cf sync operation of account records and all
 * @author: Vishal Hembrom
 * @createdDate:
 * @updateDate: 13 Dec, 2022
 */
public without sharing class CashfreeDataSync {
  /****************************************************************************************
     * @description: method used to sync account data from Salesforce to Cashfree System
     * @parameter: NA
     * @resquestBody: {
        "businessName": "merchant name - SF account name",
        "orgType": "SF entityType",
        "merchantType": "SF LOB",
        "websiteUrl": "SF Website",
        "businessRegisteredName": "SF RegisteredName",
        "addresses": [
            {
            "addressType": "Operating Address",
            "address": "SLS",
            "city": "Patna",
            "country": "India",
            "pinCode": "800011",
            "state": "Bihar"
            },
            {
            "addressType": "Website Address",
            "address": "SLS",
            "city": "Patna",
            "country": "India",
            "pinCode": "800011",
            "state": "Bihar"
            }
        ],
        "analytics": {
            "fbclid": "fbclid",
            "gclid": "gclid",
            "utmCampaign": "utmCampaign",
            "utmContent": "utmContent",
            "utmMedium": "utmMedium",
            "utmSource": "utmSource",
            "utmTerm": "utmTerm",
            "parentAccount": "SF parent account name",
            "bankName": "SF bankName",
            "bankRMName": "SF RM name"
        },
        "bankAccountNumber": "SF Bank Account Number",
        "bankIFSC": "SF Account IFSC",
        "bankAccountHolderName": "SF Account Holder Name",
        "contacts": [
            {
            "eamil": "contactEmail@email.com",
            "name": "contact name",
            "phone": "contact phone"
            }
        ],
        "merchantEmail": "SF Primary SPOC Email",
        "merchantId": 279772,
        "partnerId": 23,
        "merchantPhone": "Primary SPOC Mobile",
        "salesManager": "nafey@gocashfree.com",
        "accountManager": "nafey@gocashfree.com",
        "accountSource": "SF Account Source",
        "subLob": "SF SUB LOB"
        }
     *@responseBody: 
            {
            "status": 200,
            "message": "Data synced successfully"
            }
     *******************************************************************************/
  public static String accountDataSync(
    DataSyncWrapper.DataRequest cashfreeAccountRecords
  ) {
    List<Account> accList = [
      SELECT Id
      FROM Account
      WHERE MID__c = :String.valueOf(cashfreeAccountRecords.merchantId)
    ];
    String result = 'Fail';
    try {
      System.debug('Wrapper Data:::::' + cashfreeAccountRecords);
      List<Cashfree_API_Token__mdt> cashfreeToken = CashfreeAPIUtil.fetchAPIValue();
      if (cashfreeToken.size() != 0) {
        String cashfreEndpoint =
          cashfreeToken[0].End_Point__c +
          '/integration/salesforce/v1/merchantdetails/sync';
        String jsonInput = JSON.serialize(cashfreeAccountRecords);
        CashfreeAPIUtil.CombinedWrapper cashfreejsonwebtoken = CashfreeAPIUtil.generateJWTToken();
        Blob authorixationHeader = Blob.valueOf(cashfreejsonwebtoken.jwtToken);

        String jsonAuthCode = 'Bearer ' + cashfreejsonwebtoken.jwtToken;
        // Blob headerValue = Blob.valueOf('Test' + ':' + 'test');
        // String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

        HttpRequest request = new HttpRequest();
        request.setEndpoint(cashfreEndpoint);
        System.debug('End Pont::::' + cashfreEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', jsonAuthCode);
        System.debug('JWT Data::::' + jsonAuthCode);
        request.setBody(jsonInput);

        Http http = new Http();

        HttpResponse response = http.send(request);
        System.debug('Check Status Code::::' + response.getStatusCode());
        if (response.getStatusCode() == 200) {
          API_Logger__c apiLog = API_Logger.createAPI_Logger(
            'CashfreeDataSync',
            jsonInput,
            response.getBody(),
            cashfreEndpoint,
            String.valueOf(response.getStatusCode()),
            accList.size() != 0 ? accList[0].Id : null
          );
          insert apiLog;

          DataSyncWrapper.DataResponse responseResult = (DataSyncWrapper.DataResponse) JSON.deserializeStrict(
            response.getBody(),
            DataSyncWrapper.DataResponse.class
          );
          System.debug('Resulted Data:::::' + responseResult);
          result = 'Pass';
          return result;
        } else {
          API_Logger__c apiLog = API_Logger.createAPI_Logger(
            'CashfreeDataSync',
            jsonInput,
            response.getBody(),
            cashfreEndpoint,
            String.valueOf(response.getStatusCode()),
            accList.size() != 0 ? accList[0].Id : null
          );
          insert apiLog;
        }
      }

      return result;
    } catch (Exception e) {
      Error_Log__c errorLog = ErrorLogger.createErrorLogger(
        'CashfreeDataSync',
        'accountDataSync',
        e.getTypeName(),
        e.getMessage(),
        e.getLineNumber(),
        accList.size() != 0 ? accList[0].Id : null
      );
      insert errorLog;

      System.debug('Exception::::' + e.getMessage());
      return result;
    }
  }
}
