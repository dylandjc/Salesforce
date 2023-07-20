trigger LeadStagingTrigger on Lead_Staging__c(before insert) {
    LeadStagingTriggerHandler.filterTrig(Trigger.OperationType, Trigger.new, Trigger.oldMap);
}

//picks up new datat from lead staging and deserializes the json from request body
//search fo r a lead with lead_service_id__c that === id 
// if it exists update lead with json properties 
// if lead exists with different lead service id log exception