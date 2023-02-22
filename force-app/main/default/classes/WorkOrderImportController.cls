public class WorkOrderImportController {
    public String workOrderId{get;set;}
    public String workOrderListName{get;set;}
    
    public  WorkOrderImportController(){
        System.debug('Value::::');
        ListView listViewData = new ListView();
        listViewData = [Select Id,DeveloperName From ListView Where SObjectType = 'WorkOrder' Order By CreatedDate LIMIT 1];
        if(listViewData != null){
            workOrderId = listViewData.Id;
            workOrderListName = listViewData.DeveloperName;
        }
        else{
            workOrderId = '';
            workOrderListName = '';
        }
    }

}