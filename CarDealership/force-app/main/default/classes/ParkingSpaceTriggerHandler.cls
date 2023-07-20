/**
    @author: Dylan Chorley
    @date: 19-Sep-2022
    @group: Trigger Handler
    @description: Trigger Handler for Parking Space custom object
    @test class: ParkingSpaceTriggerTest
**/
public with sharing class ParkingSpaceTriggerHandler implements TriggerHandler {

    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Filters trigger response based on operation type
        @param: OperationType for type of trigger, list of objects being inserted or updated,
        map of objects by id for historic objects
        @return: none
    **/
    public static void filterTrig(System.TriggerOperation operationType, List<SObject> newOpp,
    Map<Id, SObject> oldMap){
        Boolean recurseStop = True;
        if(!TriggerUtilities.isBypassed('Parking_Lot__c') && recurseStop) {
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
        @description: none
        @param: List of opportunities
        @return: none
    **/
    public static void handleBeforeInsert(List<SObject> newOpp){
        //Inserting a parking space only occurs when we initialize the parking lot (nothing to add here)
        System.debug(newOpp);
    }

    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: none
        @param: List of opportunities
        @return: none
    **/
    public static void handleAfterInsert(List<SObject> newOpp){
        //Inserting a parking space only occurs when we initialize the parking lot (nothing to add here)
        System.debug(newOpp);
    }
    
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: none
        @param: ignore this function
        @return: none
    **/
    public static void handleBeforeUpdate(List<SObject> newOpp, Map<Id, SObject> oldMap){
        System.debug(newOpp);
    }

    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Finds how full a parking lot is
        @param: List of updated opportunities 
        @return: none
    **/
    public static void handleAfterUpdate(List<SObject> newOpp){
        //Cached for 8 hours 
        System.debug(newOpp);
    }
}