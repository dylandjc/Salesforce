/**
    @author: Dylan Chorley
    @date: 06-Oct-2022
    @group: Test Classes for LWC Back-End
    @description: The testing for top performers checking sales rep and vehicle
    @test class: this is it 
**/
@IsTest
public with sharing class TopPerformersTest {
    @IsTest
    static void testGetTopSalesReps(){
        //test profits
        try{
            List<TopPerformers.TopSalesPerformersWrapper> result = TopPerformers.getTopSalesReps(true);
        }
        catch(AuraHandledException e){
            System.assertEquals(73, e.getLineNumber(), 'correct error message');
        }
        try{
            List<TopPerformers.TopSalesPerformersWrapper> result = TopPerformers.getTopSalesReps(false);
        }
        catch(AuraHandledException e){
            System.assertEquals(73, e.getLineNumber(), 'correct error message');
        }

        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.SaleSplit');
        String sr = 'Dylan Chorley';
        Map<String, Integer> temp = new Map<String, Integer>();
        temp.put('NumberOfSales', 10);
        temp.put('GrossProfits', 1000);
        orgPart.put(sr.deleteWhitespace(), temp, 28800);
        List<TopPerformers.TopSalesPerformersWrapper> result = TopPerformers.getTopSalesReps(true);
        System.assertEquals(1, result.size(), 'Should only be one item in the list');
        System.assertEquals(1000, result[0].profits, 'Profits value should be returned');
        List<TopPerformers.TopSalesPerformersWrapper> result2 = TopPerformers.getTopSalesReps(false);
        System.assertEquals(10, PlatformSalesUtilities.getSaleRepCache(sr).get('NumberOfSales'));
        System.assertEquals(1, result2.size(), 'Should only be one item in the list');
        System.assertEquals(10, result2[0].sales, 'Profits value should be returned');
        System.assertEquals('Dylan Chorley', result2[0].name, 'Should only be one item in the list');
        TestFactory.createTestSalesRepCache(4);
        List<TopPerformers.TopSalesPerformersWrapper> result3 = TopPerformers.getTopSalesReps(true);
        System.assertEquals(3, result3.size(), 'Should only be one item in the list');
        //System.assertEquals(null, result3);
        System.assert(result3[0].profits >= result3[1].profits, 'Profits value should be returned with largest first');
        System.assert(result3[1].profits >= result3[2].profits, 'Profits value should be returned with largest first');
        List<TopPerformers.TopSalesPerformersWrapper> result4 = TopPerformers.getTopSalesReps(false);
        System.assertEquals(3, result4.size(), 'Should only be one item in the list');
        System.assert(result4[0].sales >= result4[1].sales, 'Profits value should be returned with largest first');
        System.assert(result4[1].sales >= result4[2].sales, 'Profits value should be returned with largest first');
            //test for 1 and 4
        // test number of sales
            // test for 1 and 4 
    }
    @IsTest
    static void testGetTopVehiclePerformers(){
        try{
            List<TopPerformers.TopVehiclePerformersWrapper> result = TopPerformers.getTopVehicles(true, true);
        }
        catch(AuraHandledException e){
            System.assertEquals(142, e.getLineNumber(), 'correct error message');
        }
        try{
            List<TopPerformers.TopVehiclePerformersWrapper> result = TopPerformers.getTopVehicles(false, false);
        }
        catch(AuraHandledException e){
            System.assertEquals(142, e.getLineNumber(), 'correct error message');
        }
        //Make data for this test here 
        TestFactory.createTestParkingLot();
        TestFactory.createTestAccount(true);
        List<Vehicle__c> toInsert = TestFactory.createTestVehicle(false, 10, true);
        insert toInsert[0];
        TestFactory.createTestOpportunity(true, true);
        Opportunity opp = [SELECT ID, StageName FROM Opportunity LIMIT 1];
        opp.StageName = Constants.STAGE_NAMES.CLOSED_WON;
        update opp;
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.VehicleSplit');
        List<TopPerformers.TopVehiclePerformersWrapper> result = TopPerformers.getTopVehicles(true, true);
        System.assertEquals(1, result.size(), 'Should only be one item in the list');
        System.assertEquals(5000, result[0].profits, 'Profits value should be returned');
  
        List<TopPerformers.TopVehiclePerformersWrapper> result3 = TopPerformers.getTopVehicles(true, false);
        System.assertEquals(1, result3.size(), 'Should only be one item in the list');
        //System.assertEquals(null, result3);
        System.assertEquals(5000, result3[0].profits, 'Profits value should be returned');

        List<TopPerformers.TopVehiclePerformersWrapper> result2 = TopPerformers.getTopVehicles(false, true);
        System.assertEquals(1, result2.size(), 'Should only be one item in the list');
        System.assertEquals(1, result2[0].sales, 'Profits value should be returned');
  
        List<TopPerformers.TopVehiclePerformersWrapper> result4 = TopPerformers.getTopVehicles(false, false);
        System.assertEquals(1, result4.size(), 'Should only be one item in the list');
        //System.assertEquals(null, result3);
        System.assertEquals(1, result4[0].sales, 'Profits value should be returned');

        // test number of sales
            // test for 1 and 4 
    }

    @IsTest
    static void testClearWhiteSpace(){
        //test with null
        System.assertEquals('bo Zo', TopPerformers.putWhiteSpaceBack('boZo'), 'White space should be added');
        System.assertEquals(null, TopPerformers.putWhiteSpaceBack(null), 'No whitespace no string should be null ');
        System.assertEquals(null, TopPerformers.putWhiteSpaceBack(''), 'No whitespace no string should be null ');
        //test normal string   
     
    }
}