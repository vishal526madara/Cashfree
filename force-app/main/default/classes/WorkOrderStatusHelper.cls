/***************************************************
 * @descrition: helper class of webservice class
 * @createdDate: 13 Jan, 2023
 * @author: Vishal Hembrom
 ***************************************************/
public without sharing class WorkOrderStatusHelper {
  public static RestResponse readWorkOrderRequest(String restRequest) {
    RestResponse result = new RestResponse();
    try {
      WorkOrderStatusWrapper.WorkOrderRequest requestBody = (WorkOrderStatusWrapper.WorkOrderRequest) JSON.deserialize(
        restRequest,
        WorkOrderStatusWrapper.WorkOrderRequest.class
      );

      List<Account> accountList = [
        SELECT Id, MID__c
        FROM Account
        WHERE MID__c = :requestBody.merchantId
      ];
      if (accountList.size() == 0) {
        return errorResponse('MID Does Not Exist');
      }

      List<Commercial__c> twoLevelCommercialList = new List<Commercial__c>();

      /*********************************************************************/
      //when no product is available of respective product code
      //eg: Product (Payment Gateway) = payment_gateway( product Code)
      if (requestBody.productCode == '' || requestBody.productCode == null) {
        return errorResponse('Product Does Not Exist');
      }
      List<Product__c> productList = [
        SELECT Id, Name
        FROM Product__c
        WHERE Product_Code__c = :requestBody.productCode
      ];
      if (productList.Size() == 0) {
        return errorResponse('Product Does Not Exist');
      }

      /***********************************************************************/

      /**************************************************************************/
      //when no mode exist
      //eg: Mode Code = upi
      if (requestBody.modeCode == '' || requestBody.modeCode == null) {
        return errorResponse('Modes Does Not Exist');
      }
      List<Modes__c> mdoeList = [
        SELECT Id, Name
        FROM Modes__c
        WHERE
          Product__c = :productList[0].Id
          AND Mode_Code__c = :requestBody.modeCode
      ];
      if (mdoeList.Size() == 0) {
        return errorResponse('Modes Does Not Exist');
      }

      /********************************************************************************/

      /***********************************************************************************/
      //for two level products
      //eg: Auto Collect , Easy Split and many more
      if (requestBody.methodCode == '' || requestBody.methodCode == null) {
        if (
          requestBody.commercialName == '' ||
          requestBody.commercialName == null
        ) {
          return errorResponse('Commercial Not Found');
        }

        twoLevelCommercialList = [
          SELECT Id, Name
          FROM Commercial__c
          WHERE Mode__c = :mdoeList[0].Id AND Name = :requestBody.commercialName
        ];

        if (twoLevelCommercialList.size() == 0) {
          return errorResponse('Commercial Not Found');
        }

        if (requestBody.bank == '' || requestBody.bank == null) {
          List<WorkOrder> workOrderList = [
            SELECT Id, Status
            FROM WorkOrder
            WHERE
              Commercial__c = :twoLevelCommercialList[0].Id
              AND MID__c = :requestBody.merchantId
          ];
          if (workOrderList.size() == 0) {
            return errorResponse('Work Order Does Not Exist');
          }

          WorkOrder updateWorkOrder = new WorkOrder();
          updateWorkOrder.Id = workOrderList[0].Id;
          updateWorkOrder.Status = requestBody.status;
          updateWorkOrder.description = requestBody.description;

          Database.SaveResult workOrderUpdateResult = Database.update(
            updateWorkOrder,
            false
          );
          if (workOrderUpdateResult.isSuccess()) {
            return successResponse(workOrderUpdateResult.getId());
          }
        }

        List<WorkOrder> workOrderList = [
          SELECT Id, Status
          FROM WorkOrder
          WHERE
            Commercial__c = :twoLevelCommercialList[0].Id
            AND MID__c = :requestBody.merchantId
            AND Bank__c = :requestBody.bank
        ];
        if (workOrderList.Size() == 0) {
          return errorResponse('Work Order Does Not Exist');
        }
        WorkOrder updateWorkOrder = new WorkOrder();
        updateWorkOrder.Id = workOrderList[0].Id;
        updateWorkOrder.Status = requestBody.status;
        updateWorkOrder.description = requestBody.description;

        Database.SaveResult workOrderUpdateResult = Database.update(
          updateWorkOrder,
          false
        );
        if (workOrderUpdateResult.isSuccess()) {
          return successResponse(workOrderUpdateResult.getId());
        }
      }

      /********************************************************************************************/

      /*********************************************************************************************/
      //for three level product
      //eg: Payment Gateway, Cashgram and many more
      List<Method_Type__c> methodTypeList = [
        SELECT Id, Name
        FROM Method_Type__c
        WHERE
          Method_Code__c = :requestBody.methodCode
          AND Mode__c = :mdoeList[0].Id
      ];
      if (methodTypeList.size() == 0) {
        return errorResponse('Method Does Exist');
      }

      List<Commercial__c> commercialList = [
        SELECT Id, Name
        FROM Commercial__c
        WHERE
          Method_Type__c = :methodTypeList[0].Id
          AND Name = :requestBody.commercialName
      ];
      if (commercialList.size() == 0) {
        return errorResponse('Commercial Does Not Exist');
      }

      if (requestBody.bank == '' || requestBody.bank == null) {
        List<WorkOrder> workOrderList = [
          SELECT Id, Status
          FROM WorkOrder
          WHERE
            Commercial__c = :commercialList[0].Id
            AND MID__c = :requestBody.merchantId
        ];

        if (workOrderList.size() == 0) {
          return errorResponse('Workk Order Does Not Exist');
        }

        WorkOrder updateWorkOrder = new WorkOrder();
        updateWorkOrder.Id = workOrderList[0].Id;
        updateWorkOrder.Status = requestBody.status;
        updateWorkOrder.description = requestBody.description;

        Database.SaveResult workOrderUpdateResult = Database.update(
          updateWorkOrder,
          false
        );
        if (workOrderUpdateResult.isSuccess()) {
          return successResponse(workOrderUpdateResult.getId());
        }
      }

      List<WorkOrder> workOrderList = [
        SELECT Id, Status, Commercial__c, MID__c, Bank__c
        FROM WorkOrder
        WHERE
          Commercial__c = :commercialList[0].Id
          AND MID__c = :requestBody.merchantId
          AND Bank__c = :requestBody.bank
      ];

      if (workOrderList.size() == 0) {
        return errorResponse('Work Order Does Not Exist');
      }

      WorkOrder updateWorkOrder = new WorkOrder();
      updateWorkOrder.Id = workOrderList[0].Id;
      updateWorkOrder.Status = requestBody.status;
      updateWorkOrder.Description = requestBody.description;
      updateWorkOrder.Rejection_Reason__c = requestBody.rejectionReason !=
        null ||
        requestBody.rejectionReason != ''
        ? requestBody.rejectionReason
        : '';

      Database.SaveResult workOrderUpdateResult = Database.update(
        updateWorkOrder,
        false
      );
      if (workOrderUpdateResult.isSuccess()) {
        return successResponse(workOrderUpdateResult.getId());
      }
      /*******************************************************************************************/

      return result;
    } catch (Exception e) {
      WorkOrderStatusWrapper.WorkOrderResponse response = new WorkOrderStatusWrapper.WorkOrderResponse();
      Map<String, String> returnResponse = new Map<String, String>();
      returnResponse.put('status', 'error');
      returnResponse.put('message', e.getMessage());
      result.statusCode = 400;
      result.responseBody = Blob.valueOf(JSON.serialize(returnResponse));
      return result;
    }
  }

  public static RestResponse errorResponse(String errorMessage) {
    RestResponse response = new RestResponse();
    Map<String, String> tempMap = new Map<String, String>();
    tempMap.put('status', 'error');
    tempMap.put('message', errorMessage);
    response.statusCode = 400;
    response.responseBody = Blob.valueOf(JSON.serialize(tempMap));
    return response;
  }

  public static RestResponse successResponse(String workOrderId) {
    RestResponse result = new RestResponse();
    WorkOrderStatusWrapper.WorkOrderResponse response = new WorkOrderStatusWrapper.WorkOrderResponse();
    response.status = 'success';
    response.workOrderId = workOrderId;
    response.message = 'Work Order Updated Successfully';
    result.statusCode = 200;
    result.responseBody = Blob.valueOf(JSON.serialize(response));
    return result;
  }
}
