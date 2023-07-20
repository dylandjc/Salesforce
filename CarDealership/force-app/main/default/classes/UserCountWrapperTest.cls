@IsTest
/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Testing Customs
    @description: Tests the UserCountWrapper class
    @test class: this is it
**/
public with sharing class UserCountWrapperTest{

    @TestSetup 
    static void initData() {
        // 2 Users
        Profile p = [SELECT Id From Profile LIMIT 1];

        // add profiles to constants system admin and regular user
        TestFactory.createTestUser(p.id, true);
        TestFactory.createTestParkingLot();
        TestFactory.createTestGroup(true);
        TestFactory.createTestAccount(true);
        TestFactory.createTestVehicle(true, 13, true);
     
    }

    @IsTest
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Confirms that comparison method in usercountwrapper works correctly
        @param: none
        @return: none system assert
    **/
    public static void verifyCompareTo(){
        Opportunity testSale = TestFactory.createTestOpportunity(true, true);
        Opportunity testSale2 = TestFactory.createTestOpportunity(true, true);
        List<UserCountWrapper> userList = new List<UserCountWrapper>();
        // Check direct comparison
        UserCountWrapper ucw = new UserCountWrapper(testSale.OwnerId, 1);
        UserCountWrapper ucw2 = new UserCountWrapper(testSale.OwnerId, 1);
        System.assertEquals(0, ucw.compareTo(ucw2), 'These should be equal');
        ucw.addCount();
        System.assertEquals(1, ucw.compareTo(ucw2), 'Should return 1 because ucw is greater than ucw2');
        System.assertEquals(-1, ucw2.compareTo(ucw), 'Should return -1 because ucw is less than ucw2');
        //Check in list sort 
        userList.add(ucw);
        userList.add(ucw2);
        userList.sort();
        System.assertEquals(ucw2, userList[0], 'These should be equal after sorting');


    }
    @IsTest
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Verifies count gets updated as usercount wrapper gets updated/redistribution occurs
        @param: none
        @return: none just assert statements
    **/
    public static void verifyAdd(){
        Opportunity testSale = TestFactory.createTestOpportunity(true, true);
        UserCountWrapper ucw = new UserCountWrapper(testSale.OwnerId, 1);
        ucw.addCount();
        System.assertEquals(2, ucw.getCount(), 'Count should have increased');
        UserCountWrapper ucw2 = new UserCountWrapper(testSale.OwnerId, 1);
        System.assertEquals(1, ucw2.getCount(), 'Count should not increase without calling add count');
    }
    @IsTest
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Verifies get name function of usercount wrapper
        @param: none
        @return: none, assertEquals statement 
    **/
    public static void verifyGetName(){
        Opportunity testSale = TestFactory.createTestOpportunity(true, true);
        UserCountWrapper ucw = new UserCountWrapper(testSale.OwnerId, 1);
        String userList = [SELECT Id, Name FROM USER WHERE id=:testSale.OwnerId].Name; 
        System.assertEquals(userList, ucw.getUserName(), 'String names should be the same based on soql queries');

    }
}