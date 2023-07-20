@IsTest
public with sharing class TestFactoryTest {
    @TestSetup
    static void makeData(){
        TestFactory.createTestParkingLot();
        TestFactory.createTestGroup(true);
        TestFactory.createTestAccountList(true, 10);
        TestFactory.createTestVehicle(true, 100, true);
        TestFactory.createTestOpportunityList(true, 50);
    }

    @IsTest
    static void testLimits(){
        System.assertEquals(100, [SELECT COUNT(Id)ct FROM Vehicle__c][0].get('ct'), '150 Vehicles created');
        System.assertEquals(50, [SELECT COUNT(Id)ct FROM Opportunity][0].get('ct'), '100 Opportunities build');
    }

}



/**
 * SALESFORCE ORG CURRENT TEST FACTORY LIMITS
 * Vehicle: 155 equal to number of parking spaces
 * Account: at least 300
 * Opportunity: 50
 * 
 * 
 */