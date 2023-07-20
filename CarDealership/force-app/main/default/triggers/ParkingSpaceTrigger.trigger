trigger ParkingSpaceTrigger on Parking_Space__c (before insert,
                                                after insert,
                                                before update,
                                                after update) {
    
    
    ParkingSpaceTriggerHandler.filterTrig(Trigger.OperationType, Trigger.new, Trigger.oldMap);
}

//make a new text field called year with str value and trigger checks for either to be changd populate the other one
//make color and mileage required
//fix preowned help text
//formula field pull in images of car
// 2 makes 2 models  four vehicles in test factory for vehicle 
// get doesnt have a bodyt ---application json for post too