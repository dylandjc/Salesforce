/**
    @author: Dylan Chorley
    @date: 19-Sep-2022
    @group: Trigger Handler
    @description: Trigger Handler for Opportunity
    @test class: OpportunityTriggerHandlerTest
**/
public with sharing class OpportunityTriggerHandler implements TriggerHandler{

    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Filters the trigger based on operationType to the correct trigger handler
        @param: operationType for what trigger this is, LIst of SObjects for newly changed/updated opportunities,
        and a map of previous values of said opportunities/SObjects
        @return: none calls methods 
    **/
    public static void filterTrig(System.TriggerOperation operationType, List<SObject> newOpp,
                                  Map<Id, SObject> oldMap) 
    {
        Boolean recurseStop = True;
        if(!TriggerUtilities.isBypassed('Opportunity') && recurseStop) {
            switch on operationType {
                when BEFORE_INSERT {
                    handleBeforeInsert(newOpp);
                    recurseStop = False;   
                }
                when AFTER_INSERT{
                    handleAfterInsert(newOpp);
                    recurseStop = False;   
                }
                when BEFORE_UPDATE{
                    handleBeforeUpdate(newOpp, oldMap);
                    recurseStop = False;   
                }
                when AFTER_UPDATE{
                    handleAfterUpdate(newOpp);
                    recurseStop = False;   
                }
            }
                          
        }

    }

    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Checks the opportunity name is correct, fills in the tax amounts based on account on record,
         adds opportunity info to a queue and converts close date if opportunity comes from a lead
        @param: List of potential opportunities to be checked before inserting
        @return: none 
    **/
    public static void handleBeforeInsert(List<Opportunity> newOpp)
    {
        OpportunityTriggerHelper.setSaleRep(newOpp);
        OpportunityTriggerHelper.checkOpportunityName(newOpp);
        OpportunityTriggerHelper.addTaxAmount(newOpp);
        OpportunityTriggerHelper.addToQueue(OpportunityTriggerHelper.oppToIds(newOpp, 'Opportunity'));
        OpportunityTriggerHelper.convertCloseDate(newOpp);
        Set<Id> vehicleIds = new Set<Id>();

        for(Opportunity actualOpportunity : newOpp) {
            //Opportunity oldOpportunity = Trigger.oldMap.get(actualOpportunity.Id);
            //If not In Stock, display error message: 
            //“Sorry, this vehicle is not available.”
            // don't hardcode in stock place in constants area 
            System.debug('STATUS VALUE:: ' + actualOpportunity.Vehicle__r.Status__c);

            vehicleIds.add(actualOpportunity.Vehicle__c);

            // if(actualOpportunity.Vehicle__r.Status__c != Constants.VEHICLE_STATUSES.IN_STOCK){
            //     actualOpportunity.Vehicle__c.addError('Sorry, this vehicle is not available');
            // }
            
            }
            
        Map<Id, Vehicle__c> vehicles = new Map<Id, Vehicle__c>([SELECT Id, Status__c FROM Vehicle__c WHERE Id IN :vehicleIds]);

        for(Opportunity thisOpportunity : newOpp) {
            Vehicle__c referencedVehicle = vehicles.get(thisOpportunity.Vehicle__c);

            if(referencedVehicle.Status__c != Constants.VEHICLE_STATUSES.IN_STOCK){
                thisOpportunity.addError('Sorry, this vehicle is not available');
            }            
        }

    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Converst vehicle to pending if attached to opportunity, checks if stage is closed, adds purchases for account, adds to queue
        @param: List of opportunities that now have ids after being inserted
        @return: none
    **/
    public static void handleAfterInsert(List<Opportunity> newOpp)
    {
        OpportunityTriggerHelper.vehicleToOpportunity(newOpp);
        OpportunityTriggerHelper.stageIsClosed(newOpp);
        OpportunityTriggerHelper.addPurchases(newOpp);
        OpportunityTriggerHelper.addToQueue(OpportunityTriggerHelper.oppToIds(newOpp, 'Opportunity'));
        //if(){
    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Checks if vehicle being updated is still valid and that opportunity name is still valid
        @param: LIst of opportunities and mapp of old opportunities
        @return: none
    **/
    public static void handleBeforeUpdate(List<Opportunity> newOpp, Map<Id, SObject> oldMap)
    {
        OpportunityTriggerHelper.checkVehicleValid((List<Opportunity>)newOpp, (Map<Id, Opportunity>)oldMap);
        OpportunityTriggerHelper.checkOpportunityName(newOpp);
        OpportunityTriggerHelper.addTaxAmount(newOpp);
        

        
    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Checks if stage is closed, adds to purchases, and adds to queue
        @param: List of opportunities that have been updated 
        @return: none
    **/
    public static void handleAfterUpdate(List<Opportunity> newOpp)
    {
        
        OpportunityTriggerHelper.stageIsClosed(newOpp);
        OpportunityTriggerHelper.addPurchases(newOpp);
        OpportunityTriggerHelper.addToQueue(OpportunityTriggerHelper.oppToIds(newOpp, 'Opportunity'));
        
        //List<Account> newAcc = new List<Account>();
        
    }

}