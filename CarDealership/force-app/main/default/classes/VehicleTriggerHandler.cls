/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Trigger Handlers
    @description: Trigger Handler for custom object Vehicle__c
    @test class: VehicleTriggerHandlerTest
**/
public with sharing class VehicleTriggerHandler{
    //filters trigger based on response to either insert or an update and passes on files
    public static void filterTrig(System.TriggerOperation operationType, List<SObject> newOpp,
    Map<Id, SObject> oldMap, List<SObject> oldOpp){
        Boolean recurseStop = True;
        //if(!TriggerUtilities.isBypassed('Vehicle__c') && recurseStop) {
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
                when BEFORE_DELETE{
                    handleBeforeDelete(oldOpp);
                    recurseStop = False;
                }
            }              
        //}
    }

    //calls necessary functions before inserting data
    public static void handleBeforeInsert(List<SObject> newOpp){
        //ParkingSpaceUtilities.handleVehicleList((List<Vehicle__c>) newOpp);
        VehicleTriggerHelper.checkYearValues((List<Vehicle__c>) newOpp);
        ParkingSpaceUtilities.handleVehicleList((List<Vehicle__c>) newOpp);
    }

    //calls necessary functions after inserting data
    public static void handleAfterInsert(List<SObject> newOpp){
        //Inserting a parking space only occurs when we initialize the parking lot (nothing to add here)
        //call the cars api 
        VehicleTriggerHelper.afterInsertHelper((List<Vehicle__c>) newOpp);
        System.debug(newOpp);

    }

    //calls necessary functions before updating data
    public static void handleBeforeUpdate(List<SObject> newOpp, Map<Id, SObject> oldMap){
        //check if the vehicle api fields have been changed 
        VehicleTriggerHelper.checkVehApiUpdated((List<Vehicle__c>) newOpp, (Map<Id, Vehicle__c>) oldMap);
        ParkingSpaceUtilities.handleVehicleList((List<Vehicle__c>) newOpp);
        VehicleTriggerHelper.checkYearValues((List<Vehicle__c>) newOpp);
    }

    //calls necessary functions after updating data
    public static void handleAfterUpdate(List<SObject> newOpp){
        System.debug(newOpp);
    
    }

    public static void handleBeforeDelete(List<SObject> newOpp){
        ParkingSpaceUtilities.deleteVehicleList((List<Vehicle__c>) newOpp);
    }

    
}