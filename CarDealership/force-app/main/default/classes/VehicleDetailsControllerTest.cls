@IsTest
public with sharing class VehicleDetailsControllerTest {
    @TestSetup
    static void makeData(){
        TestFactory.createTestParkingLot();
        TestFactory.createTestAccount(true);
        TestFactory.createTestVehicle(true, 6, true);
    }
    @IsTest
    static void testGetVehicleForOpportunity(){
        TestFactory.createTestOpportunity(true, true);
        Opportunity opp = [SELECT ID, Vehicle__c FROM Opportunity Limit 1];
        Id oppCurrent = [SELECT Id FROM Vehicle__c WHERE Id=:opp.Vehicle__c LIMIT 1].Id;
        System.assertEquals(VehicleDetailsController.getVehicleForOpportunity(opp.Id).currentVehicle.Id, oppCurrent, 'Should be same vehicle');
        System.assert(VehicleDetailsController.getVehicleForOpportunity(opp.Id).similarVehicles2 != null, 'Should be two similar vehicles');
        System.assert(VehicleDetailsController.getVehicleForOpportunity(opp.Id).similarVehicles1 != null, 'Should be two similar vehicles');
        Boolean correctValue = false;
        try{
            VehicleDetailsController.getSimilarVehicleForOpportunity(null);
        }
        catch(Exception ex){
            System.assertEquals(90, ex.getLineNumber(), 'Testing message');
            correctValue = ex.getLineNumber() == 90;
        }
        System.assertEquals(true, correctValue, 'Correct error thrown');

    }
}