trigger OpportunityTrigger on Opportunity (before insert,
                                           after insert,
                                           before update,
                                           after update) {

        for(Opportunity thisOpp : Trigger.new) {
                System.debug('========================================');
                System.debug(thisOpp.Vehicle__c);
                System.debug(thisOpp.Vehicle__r.Year__c);
                System.debug(thisOpp.Vehicle__r.Status__c);
                System.debug('========================================');
        }
      
        OpportunityTriggerHandler.filterTrig(Trigger.OperationType, Trigger.new, Trigger.oldMap);
   
}