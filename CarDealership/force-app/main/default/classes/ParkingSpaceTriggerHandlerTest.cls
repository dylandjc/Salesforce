/**
    @author: Dylan Chorley
    @date: 19-Sep-2022
    @group: Trigger Handler Test Function
    @description: Trigger Handler testing class for parking space
    @test class: this is it
**/
@IsTest
public with sharing class ParkingSpaceTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        //Make fake parking lot 
        TestFactory.createTestParkingLot();
        //Make models 
        //Make makes
        //Make vehicles 

    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Tests the after update function
        @param: none
        @return: system assert to check how full parking lot is and if it gets updated correctly
    **/
    @IsTest
    static void testAfterUpdate(){

        TestFactory.createTestVehicle(true, 1, false);
        //test vehicle inserted into parking lot
        Parking_Lot__c dealership = [SELECT Id, Name, Percent_Full__c FROM Parking_Lot__c LIMIT 1];
        System.assertEquals(0, dealership.Percent_Full__c, 'Should not have any cars in the parking lot');
        //test vehicle removed
       TestFactory.createTestVehicle(true, 1, true);

        Parking_Lot__c dealership2 = [SELECT Id, Name, Percent_Full__c FROM Parking_Lot__c LIMIT 1];
        System.assertEquals(0.645161290322580645161290322580645 , dealership2.Percent_Full__c, 'Should only have one car in the parking lot');

        Vehicle__c sv3 = [SELECT Id, Status__c FROM Vehicle__c  WHERE Status__c !=:Constants.VEHICLE_STATUSES.PENDING LIMIT 1];
        sv3.Status__c = 'Pending';
        update sv3;

        Parking_Lot__c dealership3 = [SELECT Id, Name, Percent_Full__c FROM Parking_Lot__c LIMIT 1];
        System.assertEquals(0, dealership3.Percent_Full__c, 'Should not have any cars in the parking lot');

    }

}