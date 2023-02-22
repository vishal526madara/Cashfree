public class OrderEntitlementHandler {
    public static void manageEntitlement(List<WorkOrder> woList){
        List<Entitlement> entList= [SELECT Id, Name FROM Entitlement WHERE Name= 'Order support ent.' ];
        for(WorkOrder wo: woList){
            wo.EntitlementId= entList[0].Id;
        }
    }
}