@RestResource(urlMapping='/updateOpportunityProducts')
global without sharing class UpdateOpportunityProductWebService {
  @HttpPost
  global static void updateOpportunityProduct() {
    RestRequest request = RestContext.request;
    RestResponse response = RestContext.response;
    RestResponse tempResponse = new RestResponse();
    tempResponse = UpdateOpportunityProductHelper.updateOpportunityProducts(
      request.requestBody.toString()
    );
    response.addHeader('Content-Type', 'application/json');
    response.responseBody = tempResponse.responseBody;
    response.statusCode = tempResponse.statusCode;
  }
}
