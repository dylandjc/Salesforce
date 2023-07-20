trigger VehicleTrigger on Vehicle__c (before insert,
                                      after insert,
                                      before update,
                                      after update,
                                      before delete) {

    VehicleTriggerHandler.filterTrig(Trigger.OperationType, Trigger.new, Trigger.oldMap, Trigger.old);
    
}