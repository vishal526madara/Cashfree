trigger AccountTrigger on Account (before insert,before update) {
       
    if(Trigger.isBefore){
        
        
        if(Trigger.isInsert){
            AccountTriggerHandler.onbeforeInsert(Trigger.new);
        }
        
        if(Trigger.isUpdate){
            AccountTriggerHandler.onbeforeUpdate(Trigger.new,trigger.oldMap);
        }
    }

}