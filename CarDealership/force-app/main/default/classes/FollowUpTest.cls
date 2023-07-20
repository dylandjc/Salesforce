/**
    @author: Dylan Chorley
    @date: 01-Sep-2022
    @description: Test Class for FollowUp 
**/
@IsTest
public with sharing class FollowUpTest{
    /**
        @author: Dylan Chorley
        @date: 01-Sep-2022
        @description: 
        @param: 
        @return: 
    **/
    @TestSetup
    static void makeData(){
        //
         // 2 Users
         Profile p = [SELECT Id From Profile LIMIT 1];
         TestFactory.createTestUser(p.id, true);
         // add profiles to constants system admin and regular user
        TestFactory.createTestParkingLot();
        TestFactory.createTestGroup(true);
 
        TestFactory.createTestAccount(true);
        TestFactory.createTestVehicle(true, 20, true);
    }

    @IsTest
    public static void checkFollowUp(){
        // add a bunch of opportunities with close dates five weeks in the past
        Map<Id,Opportunity> opps = new Map<Id,Opportunity>();
        Opportunity opp1 = TestFactory.createTestOpportunity(false, true);
        opp1.CloseDate = Date.today().addDays(-30);
        opps.put(opp1.Id, opp1);
        insert opp1;
        List<Task> total = FollowUp.sendFollowUp(opps);
        //call sendFollowUp
        System.assertEquals(1, total.size(), 'Correct size for tasks');
        //check task was made to correct opportunity 
    }

    @IsTest
    public static void testMissedFollowUp(){
        List<Task> empty = new List<Task>();
        System.assertEquals(empty, FollowUp.missedFollowUp(new List<Task>()), 'Response should be null');
        Opportunity opp1 = TestFactory.createTestOpportunity(true, true);
        Task t = TestUtilities.createTestTask(opp1);
        List<Task> tasks = new List<Task>();
        tasks.add(t);
        System.assertEquals('High',FollowUp.missedFollowUp(tasks)[0].Priority, 'Priority changed');
        System.assertEquals('Overdue',FollowUp.missedFollowUp(tasks)[0].Status,  'Status updated');
        System.assertEquals(Date.today()+6,FollowUp.missedFollowUp(tasks)[0].ActivityDate, 'The date should change now');
    }

    @IsTest
    public static void checkManagerEmail(){
        List<Task> allTasks = new List<Task>();
        Opportunity opp1 = TestFactory.createTestOpportunity(true, true);
        Task t = TestUtilities.createTestTask(opp1);
        allTasks.add(t);
        List<Messaging.SendEmailResult> results = FollowUp.tellManager(allTasks);
        for(Messaging.SendEmailResult res: results){
            System.assertEquals(true, res.isSuccess(), 'Emails have succeeded in being produced and sending');
        }
    }


    // error testing batch overall review with dan
    @IsTest 
    public static void checkBatchFlow(){
        Opportunity opp1 = TestFactory.createTestOpportunity(false, true);
        opp1.CloseDate = Date.today().addDays(-30);
        insert opp1;
        Opportunity opp2 = TestFactory.createTestOpportunity(false, true);
        opp2.CloseDate = Date.today().addDays(-30);
        insert opp2;
        Test.startTest();
        FollowUp fup = new FollowUp();
        Id jobID = Database.executeBatch(fup);
        Test.stopTest();
        AsyncApexJob a = [SELECT Id, Status FROM AsyncApexJob WHERE ID=:jobID];
        System.assertEquals('Completed', a.Status, ' the batch file has finished running without errors');
    }
}