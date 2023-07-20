@IsTest
/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Testing Schedulables
    @description: Tests the schedulable for close date alerts
    @test class: this is it
**/
public class SchedCloseDateAlertsTest{
    
    @TestSetup 
    static void initData() {
        // 2 Users
        Profile p = [SELECT Id From Profile LIMIT 1];

        // add profiles to constants system admin and regular user
        TestFactory.createTestUser(p.id, true);
        TestFactory.createTestGroup(true);
        TestFactory.createTestAccount(true);
        TestFactory.createTestParkingLot();
        TestFactory.createTestVehicle(true, 13, true);


    }

    @IsTest
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Tests email is sent and checks multiple edge cases
        @param: none
        @return: none
    **/
    static void sendEmailTest(){
        // create three opportunities one with deadline passed and one without and one that is closed already
        //check to make sure list only has one in it 
        // Base Case where date is in future
        User u = [SELECT Id FROM USER LIMIT 1];
        Opportunity one = TestFactory.createTestOpportunity(true, true);
        Messaging.SingleEmailMessage[] mails = SchedCloseDateAlerts.checkOppDate(); 
        System.assertEquals(0, mails.size(), 'No email should be sent if date in future');

        Opportunity two = TestFactory.createTestOpportunity(false, true);
        two.CloseDate = System.Today().addDays(-2);
        insert two;
        mails = SchedCloseDateAlerts.checkOppDate();
        System.assertEquals(1, mails.size(), 'Should be one email sent for late message');  
        // Case when already closed
        Opportunity three = [SELECT Id, StageName FROM Opportunity WHERE CloseDate=:System.Today().addDays(-2)];
        three.StageName = Constants.Stage_Names.CLOSED_WON;
        update three;
        mails = SchedCloseDateAlerts.checkOppDate();
        System.assertEquals(0, mails.size(), 'Should be no changes if case closed');

    }
}