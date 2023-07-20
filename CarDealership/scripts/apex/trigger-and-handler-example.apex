// TRIGGER BODY
trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {
    if(!TriggerUtilities.isTriggerDisabled('Contact')) {
        ContactTriggerHandler.handleTrigger(Trigger.operationType, Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}

// ContactTriggerHandler - entry point from trigger
public static void handleTrigger(System.TriggerOperation operationType, 
                                    List<Contact> newList, 
                                    Map<Id, Contact> newMap, 
                                    List<Contact> oldList, 
                                    Map<Id, Contact> oldMap) {
    switch on operationType {
        when BEFORE_INSERT {
            ContactTriggerHandler.handleBeforeInsert(newList);
        }            
        when AFTER_INSERT {
            ContactTriggerHandler.handleAfterInsert(newList, newMap);
        }
        when BEFORE_UPDATE {
            ContactTriggerHandler.handleBeforeUpdate(newList, oldMap);
        }
        when AFTER_UPDATE {
            ContactTriggerHandler.handleAfterUpdate(newList, oldMap);
        }
    }
}