/**
 * @description: trigger used to assign lead to respected campaign
 * @parameter: Na
 * @return: Na
 * **/
trigger LeadTrigger on Lead (after Insert, before insert, before update){
    if(Trigger.isAfter && Trigger.isInsert && LeadTriggerHandler.checkStatus){
        LeadTriggerHandler.afterInsert(Trigger.new);
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){
             LeadTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            LeadTriggerHandler.beforeUpdate(Trigger.newMap,Trigger.oldMap);
        }
    }
}