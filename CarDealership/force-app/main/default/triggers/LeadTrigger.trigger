trigger LeadTrigger on Lead (before insert,
after insert,
before update,
after update) {
//ignore for now but prob will need this in the future ha
LeadTriggerHandler.filterTrig(Trigger.OperationType, Trigger.new, Trigger.oldMap);
}