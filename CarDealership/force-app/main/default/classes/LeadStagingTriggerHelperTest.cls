/**
    @author: Dylan Chorley
    @date: 16-Sep-2022
    @group: Trigger Tests
    @description: Trigger tests for Lead Staging object
    @test class: this is the test class
**/
@IsTest
public with sharing class LeadStagingTriggerHelperTest {
    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Test setup of preliminary data
        @param: none
        @return: calls test factory to build env
    **/
    @TestSetup
    static void makeData(){
        // 3 Leads 
        Profile p = [SELECT Id From Profile LIMIT 1];
        TestFactory.createTestParkingLot();
        // add profiles to constants system admin and regular user
        TestFactory.createTestUser(p.id, true);
        TestFactory.createTestGroup(true);
        TestFactory.createTestAccountList(true, 3);
        TestFactory.createTestLeadList(true, false, 3);
    }
    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Tests the json handling 
        @param: none
        @return: System assert statements to determine if code passes 
    **/
    @IsTest
    static void testJsonHandling(){

        Lead_Staging__c newStaged = TestUtilities.createTestLeadStaging(0);
        Lead_Staging__c newStaged2= TestUtilities.createTestLeadStaging(1);
        Lead_Staging__c newStaged3 = TestUtilities.createTestLeadStaging(2);
        Integer count = [SELECT COUNT() FROM LEAD];
        System.assertEquals(3, count, 'Original number of leads');
        insert newStaged;
        count = [SELECT COUNT() FROM LEAD];
        System.assertEquals(4, count, 'New number of leads');
        Boolean correctErrorThrown = false;
        insert  newStaged2;
        System.assertEquals('214-773-6100', [SELECT Email, Phone FROM Lead WHERE Email=:'johndo1234e@test.com' LIMIT 1].Phone, 'Lead value changed');
        //Same ID different values inside of it
        // Same phone number but different id
        try{
            LeadStagingTriggerHandlerHelper.jsonHandler(newStaged3);
            //wghat a amerchant will buy 
            //new vs existing flow and learning the basics first 
            //doordash learing center
        }catch(Exception e){
            //Check message
            String result = e.getMessage();
            System.assert(result.contains('Lead exists with matching Phone or Email.'), 'Should send error for duplicates');
            //Check that there is an error added to error log
            Integer count1 = [SELECT COUNT() FROM Error_Log__c];
            System.assertEquals(1, count1, 'Error should be added to the error log');
            //check that count of lead has increased after calling json handling 
        } 
    }
}