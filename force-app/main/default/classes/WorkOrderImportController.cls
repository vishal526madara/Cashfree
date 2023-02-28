public class WorkOrderImportController {
  public String workOrderId { get; set; }
  public String workOrderListName { get; set; }

  public WorkOrderImportController() {
    System.debug('Value::::');
    ListView listViewData = new ListView();
    listViewData = [
      SELECT Id, DeveloperName
      FROM ListView
      WHERE SObjectType = 'WorkOrder'
      ORDER BY CreatedDate
      LIMIT 1
    ];
    if (listViewData != null) {
      workOrderId = listViewData.Id;
      workOrderListName = listViewData.DeveloperName;
    } else {
      workOrderId = '';
      workOrderListName = '';
    }
  }
}
