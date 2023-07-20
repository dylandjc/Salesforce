/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Testing Queues
    @description: Tests the reassignment queue actions
    @test class: this is a test class
**/
@IsTest
public with sharing class QueueableReassignmentTest{
    @TestSetup
    static void makeData(){
    
         // 2 Users
         Profile p = [SELECT Id From Profile LIMIT 1];
         // add profiles to constants system admin and regular user
         TestFactory.createTestUser(p.id, true);
         TestFactory.createTestGroup(true);
         TestFactory.createTestParkingLot();
         TestFactory.createTestAccount(true);
 
         TestFactory.createTestVehicle(true, 30, true);

         List<User> allUsers = TestUserFactory.createUsers(3, null, true);
         TestFactory.createTestOpportunityList(true, 15);
    }
    @IsTest
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Tests if email is actually sent
        @param: none
        @return: none assert statements
    **/
    public static void testEmailSend(){
        List<UserCountWrapper> reassigned = TestUtilities.createCountList(true);
        List<Messaging.SendEmailResult> emailSuccess = QueueableReassignment.sendEmail('dylan.chorley@doordash.com', reassigned);
        for(Messaging.SendEmailResult res: emailSuccess){
            System.assertEquals(true, res.isSuccess(), 'Emails have succeeded in being produced and sending');
        }
    }
    @IsTest
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Test that the users are actually redistributed
        @param: none
        @return: none
    **/
    public static void testRedistribute(){
        List<UserCountWrapper> reassigned = TestUtilities.createCountList(true);
        List<Opportunity> addOpps = new List<Opportunity>([SELECT Id FROM Opportunity]);
        Integer newtotal = 0;
        Integer total = 0;
        //Owners in the usercount wrapper start with 5 opportunities
        for(UserCountWrapper res: reassigned){
            total+=res.getCount();
        }
        Integer originalCount = addOpps.size() + total;
        System.assertEquals(20, originalCount, 'Number of open assignments should be the same');
       //System.assertEquals(null, reassigned, 'Number of open assignments should be the same');
        List<UserCountWrapper> updated = QueueableReassignment.redistribute(addOpps, reassigned);
        for(UserCountWrapper wrap: updated){
            newtotal+=wrap.getCount();
        }
        //Assert that the new total number of open opps is the same 
        System.assertEquals(originalCount, newtotal, 'Number of open assignments should be the same');
        System.assertEquals(10, updated[0].getCount(), 'Expected count after redistributing the list ');
        System.assertEquals(10, updated[1].getCount(), 'Expected count after redistributing the list ');
        //Assert the number for the first value 
        
    }
    @IsTest
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Tests owner is picked correctly
        @param: none
        @return: assert statements but otherwise nothing
    **/
    public static void testPickOwner(){
        List<UserCountWrapper> reassigned = TestUtilities.createCountList(false);
        // I make the assumption that there will always be at least two users not necessarily two open opportunities
        Integer max = 99999999; 
        UserCountWrapper index = QueueableReassignment.pickOwner(reassigned, 1);
        for(UserCountWrapper min:reassigned){
            if(min.getCount() < max){
                max = min.getCount();
            }
        }
        //assert order of two item list is correct 
        System.assertEquals(max, index.getCount(), 'The first index should be used after sorting ');
    }
    @IsTest
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Tests that current distribution of owners to opportunities is correct
        @param: none
        @return: none
    **/
    public static void testGetCurrentDistribution(){
        List<Opportunity> addOpps = new List<Opportunity>([SELECT Id FROM Opportunity]);
        List<UserCountWrapper> currentDistribution = QueueableReassignment.getCurrentDistribution();
        //check the order is sorted 
        Integer before = 0;
        for(UserCountWrapper dis: currentDistribution){
            System.assertEquals(true, dis.getCount()>=before, 'list is sorted');
        }
        // expected value of first and last indexes
    }

}