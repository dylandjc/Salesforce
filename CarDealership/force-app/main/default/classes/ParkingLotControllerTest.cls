@IsTest
public with sharing class ParkingLotControllerTest {
    
    @IsTest
    static void testLotDisplay(){
        try{
            Map<String, List<ParkingLotController.ParkingSpotWrapper>> results = ParkingLotController.initializeLotData();
        }catch(Exception e){
            System.assertEquals(31, e.getLineNumber(), 'Should error out');
        }
        Test.startTest();
        TestFactory.createTestParkingLot();
        Map<String, List<ParkingLotController.ParkingSpotWrapper>> results = ParkingLotController.initializeLotData();
        System.assert(results.size() > 0, 'The Results are not null');
        System.assert(results != null, 'The Results are not null');
        TestFactory.createTestVehicle(true, 10, true);
        Map<String, List<ParkingLotController.ParkingSpotWrapper>> resultsVehicle = ParkingLotController.initializeLotData();
        Vehicle__c vex = [SELECT Parking_Space__c, Name, Color__c FROM Vehicle__c WHERE Parking_Space__c = 'A1' LIMIT 1];
        System.assertEquals(!resultsVehicle.get('A')[0].isVacant, vex.Parking_Space__c != 'Auto', 'testing the behicle');
        //System.assertEquals(null, [SELECT Name, Parking_Space__c FROM Vehicle__c WHERE Parking_Space__c!='Auto'], 'Should not be vacant in A1');
        System.assertEquals(resultsVehicle.get('A')[0].name , vex.Parking_Space__c, 'Test that the name of vehicle is the same');
        //System.assertEquals(resultsVehicle.get('A')[0].vehicle , vex, 'Test that the name of vehicle is the same');
        System.assertEquals(resultsVehicle.get('A')[0].cssString, Constants.COLOR_HEX_CODES.get(vex.Color__c), 'Test that the name of vehicle is the same');
        System.assertEquals(resultsVehicle.get('A')[0].vehicleId, vex.Id, 'Test that the name of vehicle is the same');
        //System.assertEquals(null, vex.Name, 'Test that the name of vehicle is the same');
        Test.stopTest();
        
    }

    @IsTest
    static void testDealershipSummary(){
        TestFactory.createTestParkingLot();
        ParkingLotController.ParkingLotWrapper result = ParkingLotController.parkingLotLandingPage();
        System.assertEquals('Dealership', result.dealershipName, 'The name of the dealership ');
        System.assertEquals('0.00', result.percentFull, 'The dealership should be empty');
        System.assertEquals('15', result.numberOfLots, 'The number of lots in the dealership');

    }
    @IsTest
    static void testLotSectionWrapper(){
        TestFactory.createTestParkingLot();
        List<ParkingLotController.LotSectionWrapper> result = ParkingLotController.lotSectionsPage();
        System.assertEquals(false, result[0].isFull, 'lot should not be full ');
        System.assertEquals('A', result[0].name, 'The dealership should be empty');
        System.assertEquals(15, result.size(), 'The number of lots in the dealership');
    }

}