/**
 * @description       : Exposing the SubCaseCreationWebservice Class to the External System 
 *                      for Child Case Creation
 * @author            : Saurav Kashyap
 * @group             : Appstrail
 * @last modified on  : 06-03-2023
 * @last modified by  : Saurav Kashyap
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   28-12-2022   Saurav Kashyap   Initial Version
**/
@RestResource(urlMapping='/subCaseCreation/*')
global class SubCaseCreationWebservice {
    /**
    * @description 
    * @author Saurav Kashyap | 06-03-2023 
    * @returnType : void
    **/
    @HttpPost
    global static void createSubCase() {
        //to get the Request Data 
        RestRequest restReq = RestContext.request;

        //for Response to the Request
        RestResponse restresponse = RestContext.response;
        
        //temporary Response for Mapping to the actual Response
        RestResponse tempResonse =  SubCaseCreationReader.readrequest(restReq.requestBody.toString());
        
        // Mapping the Response from temporary Response to the Actual Response
        restResponse.addHeader('Content-Type', 'application/json');
        restResponse.statusCode = tempResonse.statusCode;
        restResponse.responseBody = tempResonse.responseBody;
        System.debug('Main Fxn. Called::::'+ restresponse);
    }

}