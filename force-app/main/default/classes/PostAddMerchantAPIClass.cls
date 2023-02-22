/**
 * @description       : POST Add Merchant IN Cashfree
 * @author            : Saurav Kashyap
 * @group             : Appstrail
 * @last modified on  : 12-01-2022
**/
public without sharing class PostAddMerchantAPIClass {
    /**
     * @description: method used to callout to Cashfree database and perform POST Operation.
     * @parameter: serialize input in string format
     *@return: 'Pass' will return if callout is successfull otherwise it'll return 'Fail'.
     * whenever callout gets failed an "Error Log" will generate into
     * 
     * Later It'll Return ResponseWrapper From the callout
     */
  /*  public static ResponseWrapper CashfreeAPICallout(String jsonInput){
        // jsonInput Contains all the required Data Like Name.Email and Phone Number Of Merchant
        //String result = 'Fail'; //...............................for returnType
        String className = 'PostAddMerchantAPIClass';
        //response Wrapper Object
        ResponseWrapper responseWrapperObject = new ResponseWrapper();
        try{
            // fetching the Authentication data from APIUtils
            List<Cashfree_API_Token__mdt> cashFreeMetaData = CashfreeAPIUtil.fetchAPIValue();

            //Request Structure
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint(cashFreeMetaData[0].End_Point__c);
            request.setHeader('api-key', cashFreeMetaData[0].Key__c);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(jsonInput);
            request.setTimeout(120000);

            Http http = new Http();

            //response Structure
            HttpResponse response = new HttpResponse();
            //getting response...
            response = http.send(reques
            t);
            //response map to store data in structured form
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            //validation....
            if(response.getStatusCode() == 200){
                System.debug('Response Body:::'+ response.getBody());
                //response Wrapper Object Data...................................
                responseWrapperObject = ResponseWrapper.parse(response.getBody());

                if(responseMap.get('success') == true){
                    //result = 'Pass';
                    return responseWrapperObject;
                }
                else if(responseMap.get('success') == false){
                    CashfreeAPIUtil.generateErrorLog((new CustomException('Error Message')),className);
                    throw new CustomException('Error Message');
                }
            }
            else if(response.getStatusCode() == 400){
                // ErrorLogger.createErrorLogger('ClassName', 'Methodname', ex.getTypeName(), ex.getMessage(), ex.getLineNumber(), null);
                CashfreeAPIUtil.generateErrorLog((new CustomException('Error Message')),className);
                throw new CustomException('Error Message');
            }
            return responseWrapperObject;
        }
        catch(Exception e){
            CashfreeAPIUtil.generateErrorLog(e,className);
            return responseWrapperObject;
        }
    }
    /*
        public static string getRequest(string className,String parentId){
        return [SELECT Id, Name, Request__c, Class_Name__c, Parent_Id__c 
                FROM API_Logger__c where Class_Name__c=:className
                and Parent_Id__c=:parentId order by CreatedDate  desc Limit 1].Request__c;
        } 
    */
}