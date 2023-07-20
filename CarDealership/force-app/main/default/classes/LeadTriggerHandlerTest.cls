/**
    @author: Dylan Chorley
    @date: 16-Sep-2022
    @group: Trigger Tests
    @description: The test class for lead trigger handler
    @test class: this is the test class
**/
@IsTest
public with sharing class LeadTriggerHandlerTest {
    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Makes the preliminary data 
        @param: none
        @return: calls to TestFactory 
    **/
    @TestSetup
    static void makeData(){
        TestFactory.createTestParkingLot();
        TestFactory.createTestVehicle(true, 14, true);
    }
    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Checks the lead conversion ability is handled correctly
        @param: none
        @return: System.assert statements 
    **/
    @IsTest
    public static void handleLeadConversion(){
        Lead ls = TestFactory.createTestLead(false, true);
        Lead ls2 = TestFactory.createTestLead(false, true);
        System.debug([SELECT COUNT(ID) FROM Vehicle__c WHERE Status__c=:'In Stock']);
        insert ls;
        insert ls2;
        Lead test1 = [SELECT Id, Status FROM LEAD LIMIT 1];
        test1.Status = Constants.LEAD_STATUSES.TEST_DRIVE_SCHEDULED;
        update test1;
        Integer count = [SELECT COUNT() FROM Opportunity];
        String st = [SELECT State__c FROM LEAD LIMIT 1].State__c;
        System.assert(count == 1, 'The lead should be converted now');
        System.assertEquals(1, [SELECT Id, IsConverted FROM LEAD WHERE IsConverted=false].size(), 'The lead should not be converted if not the correct status');
        System.assert(st == 'Alabama', 'The state should have been filled out by a default');
        //test if lead is converted after updating the status 
    }
    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Checks that the helper function also works in converting a lead separate from the trigger
        @param: none
        @return: calls to test factory and the helper function checked by assert statements 
    **/
    @IsTest
    public static void checkHelperConvert(){
        List<Lead> leadsToConvert = new List<Lead>();
        Lead ls = TestFactory.createTestLead(false, true);
        Lead ls2 = TestFactory.createTestLead(false, true);
        insert ls;
        insert ls2;
        ls.Status = Constants.LEAD_STATUSES.TEST_DRIVE_SCHEDULED;
        leadsToConvert.add(ls);
        leadsToConvert.add(ls2);
        Test.startTest();
        List<Database.LeadConvertResult> results = LeadTriggerHelper.checkStatusConvert(leadsToConvert);
        Test.stopTest();
        for(Database.LeadConvertResult res: results){
            System.assertEquals(res.isSuccess(), true, 'All leads that should be converted were converted successfully');
        }
    }
}