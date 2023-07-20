/**
    @author: Dylan Chorley
    @date: 19-Sep-2022
    @group: Trigger Handler Testing
    @description: Tests the notification trigger 
    @test class: this is the test class
**/
@IsTest
public with sharing class NotifcationTriggerHandlerTest{
    @TestSetup
    static void makeData(){
        // 2 Users
        Profile p = [SELECT Id From Profile LIMIT 1];

        // add profiles to constants system admin and regular user
        TestFactory.createTestUser(p.id, true);
        
        TestFactory.createTestParkingLot();
        TestFactory.createTestGroup(true);

        TestFactory.createTestAccount(true);
        TestFactory.createTestVehicle(true, 13, true);
       
    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Verifies SMS sent upon opportunity/vehicle sold
        @param: none
        @return: system assert checks database save results are successful
    **/
    @IsTest
    static void verifyNotifySoldSMS(){
        Opportunity testSale = TestFactory.createTestOpportunity(true, true);
        Test.startTest();
        testSale.StageName = Constants.STAGE_NAMES.CLOSED_WON;
        update testSale;
        List<Database.SaveResult> res = NotificationTriggerHelper.uponClosedWon(testSale);
        Test.stopTest();
        for(Database.SaveResult resolve: res){
            System.assertEquals(true, resolve.isSuccess(), 'published correctly');
        }

    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Verifies notification on slack is sent when vehicle status changes to pending
        @param: none
        @return: System assert checks that notifications are published correctly
    **/
    @IsTest
    static void verifyNotifyPendingSlack(){
        Opportunity testSale = TestFactory.createTestOpportunity(true, true);
        Test.startTest();
        List<Vehicle__c> vehicles = new List<Vehicle__c>([SELECT Id, Status__c FROM Vehicle__c WHERE Id=:testSale.Vehicle__c LIMIT 1]);
        vehicles[0].Status__c = Constants.VEHICLE_STATUSES.PENDING;
        update testSale;
        List<Database.SaveResult> res = NotificationTriggerHelper.uponVehStatusPending(testSale);
        Test.stopTest();
        for(Database.SaveResult resolve: res){
            System.assertEquals(true, resolve.isSuccess(), 'published correctly');
        }
    }
    
}