/**
    @author: Dylan Chorley
    @date: 16-Sep-2022
    @group: Trigger Handlers
    @description: The trigger handler for the Lead Object 
    @test class: LeadTriggerHandlerTest
**/
public with sharing class LeadTriggerHandler implements TriggerHandler {
    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: filters trigger based on response to either insert or an update and passes on files 
        @param: Trigger information ie the type of trigger operation, list of the newly updated/inserted objects and map of old objects
        @return: none -- calls correct trigger handler
    **/
    public static void filterTrig(System.TriggerOperation operationType, List<SObject> newOpp,
                                    Map<Id, SObject> oldMap){
                                        System.debug(newOpp);
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
        @date: 16-Sep-2022
        @description: Handles before insert situations
        @param: List of to be inserted lead objects
        @return: calls other functions
    **/
    public static void handleBeforeInsert(List<SObject> newOpp){
        System.debug(newOpp);
        LeadTriggerHelper.setCompany((List<Lead>) newOpp);
        LeadTriggerHelper.fillDateOnLead((List<Lead>)newOpp);
        //LeadTriggerHelper.checkVehicle((List<Lead>) newOpp);
    }

    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Handles after insert situations
        @param: List of inserted lead objects 
        @return: Calls other functions
    **/
    public static void handleAfterInsert(List<SObject> newOpp){
        System.debug(newOpp);
        LeadTriggerHelper.checkStatusConvert((List<Lead>) newOpp);
    }
    

       /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Handles before update situations
        @param: List of to be updated lead objects 
        @return: Calls other functions
    **/
    public static void handleBeforeUpdate(List<SObject> newOpp, Map<Id, SObject> oldMap){
        LeadTriggerHelper.fillDateOnLead((List<Lead>)newOpp);
        LeadTriggerHelper.setCompany((List<Lead>) newOpp);
    }
    
       /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Handles after update situations
        @param: List of updated lead objects 
        @return: Calls other functions
    **/
    public static void handleAfterUpdate(List<SObject> newOpp){
        System.debug(newOpp);
        LeadTriggerHelper.checkStatusConvert((List<Lead>) newOpp);
        
    }


}