@IsTest
public with sharing class PlatformSalesUtilitiesTest {
    @TestSetup
    static void makeData(){
        // 10 opportunities 
        TestFactory.createTestParkingLot();
        Profile p = [SELECT Id From Profile LIMIT 1];
        TestFactory.createTestUser(p.id, true);
        TestFactory.createTestGroup(true);
        TestFactory.createTestAccountList(true, 3);
        TestFactory.createTestVehicle(true, 3, true);
       
        // 10 vehicles
        // make all closed won 
    }
    /**
        @author: Dylan Chorley
        @date: 28-Sep-2022
        @description: Tests the vehicle cache adn checks via model and make
        @param: none
        @return: none
    **/
    @IsTest
    static void testVehicleCacheGetterRefresher(){
        List<AggregateResult> err = [SELECT Count(Id)ct FROM Error_Log__c];
        PlatformSalesUtilities.getVehicleCache('bozo');
        List<AggregateResult> err2 = [SELECT Count(Id)ct FROM Error_Log__c];
        System.assertEquals(Integer.valueOf(err[0].get('ct'))+1, Integer.valueOf(err2[0].get('ct')), 'Should add to error log if name is not in the list');
        List<Opportunity> opps =  TestFactory.createTestOpportunityList(false, 3);
        for(Opportunity opp: opps){
            opp.StageName = Constants.STAGE_NAMES.CLOSED_WON;
        }
        insert opps;
        //Grab vehicle id from an opportunity
        //Try one with make 
        List<Opportunity> vehIDs = new List<Opportunity>([SELECT Vehicle__c FROM Opportunity LIMIT 2]);
        String makeId = vehIDs[0].Vehicle__c;
        String modelId = vehIDs[1].Vehicle__c;
        
        String vehicleMake = [SELECT Name, Model__r.Vehicle_Make__r.Name FROM Vehicle__c WHERE Id=:makeId].Model__r.Vehicle_Make__r.Name;
        String vehicleModel = [SELECT Name, Model__r.Name FROM Vehicle__c WHERE Id=:modelId].Model__r.Name;
        System.debug([SELECT Id, Vehicle__c, Sales_Rep__c, Total_Due__c, StageName FROM Opportunity WHERE StageName =: Constants.STAGE_NAMES.CLOSED_WON].size());

        Test.startTest();
    
        Map<String, Integer> resultMake = PlatformSalesUtilities.getVehicleCache(vehicleMake);
        Map<String, Integer> resultModel = PlatformSalesUtilities.getVehicleCache(vehicleModel);
        //System.assertEquals(null, result, 'Name of overall map is correct');
        Integer count = (Integer) [SELECT COUNT(Id)ct FROM Vehicle__c WHERE Model__r.Vehicle_Make__r.Name=:vehicleMake AND Status__c=:Constants.VEHICLE_STATUSES.SOLD][0].get('ct');
        System.debug([SELECT Id FROM Opportunity WHERE Vehicle__c=:makeId]);
        System.debug(resultMake);
        System.debug(makeId);
        System.debug(vehicleMake);
        System.assertEquals(count, resultMake.get('NumberOfSales'), 'Number of sales should be the same');
        System.assertEquals(5000*count, resultMake.get('GrossProfits'), 'GrossProfits');
        //Try one with model 
        Integer count2 = (Integer) [SELECT COUNT(Id)ct FROM Vehicle__c WHERE Model__r.Name=:vehicleModel AND Status__c=:Constants.VEHICLE_STATUSES.SOLD][0].get('ct');
        System.assertEquals(count2, resultModel.get('NumberOfSales'), 'Number of sales should be the same');
        System.assertEquals(5000*count2, resultModel.get('GrossProfits'), 'GrossProfits');
        Test.stopTest();
    }
    /**
        @author: Dylan Chorley
        @date: 28-Sep-2022
        @description: Tests the sales rep cache checking the getter and refresher 
        @param: none
        @return: none
    **/
    @IsTest
    static void testSalesRepCacheGetterRefresher(){
        List<AggregateResult> err = [SELECT Count(Id)ct FROM Error_Log__c];
        PlatformSalesUtilities.getSaleRepCache('bozo');
        List<AggregateResult> err2 = [SELECT Count(Id)ct FROM Error_Log__c];
        System.assertEquals(Integer.valueOf(err[0].get('ct'))+1, Integer.valueOf(err2[0].get('ct')), 'Should add to error log if name is not in the list');

        List<Opportunity> opps =  TestFactory.createTestOpportunityList(false, 2);
        for(Opportunity opp: opps){
            opp.StageName = Constants.STAGE_NAMES.CLOSED_WON;
        }
        insert opps;
        List<Opportunity> oppsolete = new List<Opportunity>([SELECT Id, Sales_Rep__c FROM Opportunity LIMIT 1]);
        oppsolete[0].Sales_Rep__c = Constants.SALES_REPS.get(0);
        update oppsolete[0];
        Test.startTest();
        Map<String, Integer> result = PlatformSalesUtilities.getSaleRepCache(Constants.SALES_REPS.get(0));
        
        //System.assertEquals(null, result, 'Name of overall map is correct');
        System.debug(result);
        Integer count = (Integer) [SELECT COUNT(Id)ct FROM Opportunity WHERE Sales_Rep__c=:Constants.SALES_REPS.get(0)][0].get('ct');
        System.assertEquals(count, result.get('NumberOfSales'), 'Number of sales should have increased');

        System.assertEquals(5000*count, result.get('GrossProfits'), 'GrossProfits');
        //check the results of running getter 
        Test.stopTest();
        Opportunity ope = TestFactory.createTestOpportunity(false, true);
        ope.StageName = Constants.STAGE_NAMES.CLOSED_WON;
        ope.Sales_Rep__c = Constants.SALES_REPS.get(0);
        insert ope;
        List<Opportunity> oppsolete2 = new List<Opportunity>([SELECT Id, Sales_Rep__c FROM Opportunity WHERE Sales_Rep__C !=:Constants.SALES_REPS.get(0) LIMIT 1]);
        oppsolete2[0].Sales_Rep__c = Constants.SALES_REPS.get(0);
        update oppsolete2[0];
        System.assertEquals(count, result.get('NumberOfSales'), 'Number of sales should not increase for 8 hours');
        System.assertEquals(5000*count, result.get('GrossProfits'), 'Gross profits should not be updated until 8 hours');

        // add a new opportunity closed won and update sales rep 
        // run the cache refresh and check sales rep data changed 
    }



}