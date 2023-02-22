@RestResource(urlMapping='/merchantProductUpdate/*')
global class MerchantProductWebservice {
  //Webservice method to insert order and invoice
  @HttpPost
  global static void updateMerchantProducts() {
    RestRequest resReq = RestContext.Request;
    System.debug('request body' + resReq.requestBody.toString());
    String response = MerchantProductReader.readRequest(
      resReq.requestBody.toString()
    );
    RestContext.response.addHeader('Content-Type', 'application/json');
    RestContext.response.responseBody = Blob.valueOf(response);
  }
}
