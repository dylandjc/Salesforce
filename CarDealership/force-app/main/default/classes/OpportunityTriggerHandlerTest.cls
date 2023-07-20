/**
    @author: Dan Thoreson
    @date: 08-Aug-2022
    @description: Test class for OpportunityTriggerHandler
**/
// Test classes are defined with an @IsTest annotation
// Commonly you will see test classes marked with the "private" access modifier, since they should not be called from
// anywhere apart from Salesforce during test runs or deployments. Making test classes private is not required, however.
@IsTest
private class OpportunityTriggerHandlerTest{

    // The @TestSetup annotation denotes a method in a test class as a "setup method", which will run before each test method
    // The purpose of the setup method is to create data which will be used in the test methods. 
    // Commonly, data will be created using a Factory or Builder pattern, which prevents duplicating record initialization throughout
    // the code base, as seen below. 
    @TestSetup 
    static void initData() {
        // 2 Users
        
        Parking_Lot__c dealership = TestFactory.createTestParkingLot();
        // add profiles to constants system admin and regular user
        
        TestFactory.createTestGroup(true);

        TestFactory.createTestAccountList(true, 3);
        TestFactory.createTestVehicle(true, 15, false);
       
    }
    /**
        @author: Dylan Chorley
        @date: 08-16-2022
        @description: Tests the trigger
        that checks to make sure a new vehicle can't be added to an existing opportunity
     */
    @IsTest
    static void verifyCannotModifyVehicleOnOpportunity(){
        Opportunity testSale = TestFactory.createTestOpportunity(false, true);
        Id original = TestUtilities.getVehicle(true);
        testSale.Vehicle__c = TestUtilities.getVehicle(true);
        insert testSale;
        Boolean correctErrorThrown = false;
        try{
            testSale.Vehicle__c = TestUtilities.getVehicle(true);
            update testSale;
        } catch(Exception ex){
            testSale.Vehicle__c = original;
            correctErrorThrown = ex.getMessage().contains('The vehicle cannot be changed in an ongoing sale. If the customer would like to switch vehicles, please close this opportunity and create a new one with the updated vehicle.');
        }
        System.assert(correctErrorThrown, 'The vehicle should not have been allowed to be changed');
        System.assertEquals(testSale.Vehicle__c, original);

    }
    // T
    // addError() is an interesting method to test, because, if you insert data that will trigger the custom
    // error, then the code will throw an exception and the tests will fail. So you have to both trigger the 
    // error AND catch the exception, and when catching, make sure that we received the error we were looking for.
    @IsTest 
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: his method is to verify that the "In Stock" Opportunity / Vehicle validation is working correctly. 
        @param: none
        @return: none
    **/
    static void verifyCannotAddUnavailableVehicleToOpportunity() {
        // First try to get an unavailable Vehicle. Our code should throw an error and not insert the Opportunity/Sale.
        Opportunity testSale = TestFactory.createTestOpportunity(false, true);
        testSale.Vehicle__c = TestUtilities.getVehicle(false);

        Boolean correctErrorThrown = false;

        try {
            insert testSale;
        } catch(Exception ex) {
            // correctErrorThrown will only be true if our validation ran and was successful in stopping the transaction
            correctErrorThrown = ex.getMessage().contains('Sorry, this vehicle is not available');
        }

        System.assert(correctErrorThrown, 'A Vehicle that is not In Stock should NOT be allowed to be added to the Opportunity');
        System.assert([SELECT COUNT() FROM Opportunity WHERE AccountId = :TestFactory.testCustomerId] == 0, 'This Opportunity should not have been inserted.');

        // Get an In-Stock Vehicle and the Sale should work
        testSale.Vehicle__c = TestUtilities.getVehicle(true);
        insert testSale;

        System.assert([SELECT COUNT() FROM Opportunity WHERE AccountId = :TestFactory.testCustomerId] == 1, 'This Opportunity should have been inserted successfully');
    }
    /**
        @author: Dylan Chorley
        @date: 08-15-2022
        @description: Confirms vehicle in closed lost opportunity is back in stock
    */
    @IsTest
    static void verifyLostVehicleInStock(){
        Opportunity testSale = TestFactory.createTestOpportunity(false, true);
        Id theVehicle = TestUtilities.getVehicle(true);
        testSale.Vehicle__c = theVehicle;
        insert testSale;
        testSale.StageName = Constants.STAGE_NAMES.CLOSED_LOST;
        Boolean correctErrorThrown = false;
        try{
            update testSale;
        }catch(Exception ex){
            correctErrorThrown = ex.getMessage().contains('You must fill out the reason why this opportunity is closed');
        }
        System.assert(correctErrorThrown, 'Still need a Lost Reason');
        testSale.Lost_Reason__c = 'Could not Agree on Terms';
        update testSale;
        System.assert([SELECT Status__c FROM Vehicle__c WHERE  Id = :theVehicle].Status__c == Constants.VEHICLE_STATUSES.IN_STOCK, 'This vehicle should be available now.');
        //System.assert([SELECT COUNT() FROM Opportunity WHERE AccountId = :testCustomerId] == 0, 'This Opportunity should not have been inserted.');
    }


    /**
        @author: Dylan Chorley
        @date: 08-15-2022
        @description: Confirms vehicle added to opportunity is set as pending
    */
    @IsTest
    static void verifyVehicleIsPending(){
        Opportunity testSale = TestFactory.createTestOpportunity(false, true);
        testSale.Vehicle__c = TestUtilities.getVehicle(false);
        Boolean correctErrorThrown = false;
        try {
            insert testSale;
        } catch(Exception ex) {
            // correctErrorThrown will only be true if our validation ran and was successful in stopping the transaction
            correctErrorThrown = ex.getMessage().contains('Sorry, this vehicle is not available');
        }

        System.assert(correctErrorThrown, 'A Vehicle that is not In Stock should NOT be allowed to be added to the Opportunity');
        System.assert([SELECT COUNT() FROM Opportunity WHERE AccountId = :TestFactory.testCustomerId] == 0, 'This Opportunity should not have been inserted.');

        // Get an In-Stocusk Vehicle and the Sale should work
        testSale.Vehicle__c = TestUtilities.getVehicle(true);
        insert testSale;

        System.assert([SELECT Status__c FROM Vehicle__c WHERE Id = :testSale.Vehicle__c].Status__c == Constants.VEHICLE_STATUSES.PENDING, 'This vehicle should be now');
    }

    // Tests the automation off marking the Opportunity as Won, which includes moving the Vehicle to Sold
    // and incrementing the count of # of Vehicles Purchased on the Account
    @IsTest
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Tests when an opportunity is closed and won
        @param: none
        @return: none system assert statements
    **/
    static void testClosedWonOpportunity() {
        // handle multiple Opportunities at once to make sure our code really works for all scenarios
        Opportunity testSale = TestFactory.createTestOpportunity(true, true);

        // Verify state before automation
        System.assertEquals(0, [SELECT Number_of_Purchases__c FROM Account WHERE Id = :testSale.AccountId].Number_of_Purchases__c);
        System.assertEquals(Constants.VEHICLE_STATUSES.PENDING, [SELECT Status__c FROM Vehicle__c WHERE Id = :testSale.Vehicle__c].Status__c);

        // While we don't really need startTest() and stopTest() here, this serves as kind of a visual demarcation for where our actions begin.
        Test.startTest();
            testSale.StageName = Constants.STAGE_NAMES.CLOSED_WON;
            update testSale;
        Test.stopTest();

        System.assertEquals(1, [SELECT Number_of_Purchases__c FROM Account WHERE Id = :testSale.AccountId].Number_of_Purchases__c);
        System.assertEquals(Constants.VEHICLE_STATUSES.SOLD, [SELECT Status__c FROM Vehicle__c WHERE Id = :testSale.Vehicle__c].Status__c);
    }

    @IsTest
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Tests that opportunity name is set correct
        @param: none
        @return: none
    **/
    static void testSetOpportunityName() {
        Opportunity testSale = TestFactory.createTestOpportunity(false, true);
        String originalOpportunityName = testSale.Name;
        
        Test.startTest();
            insert testSale;
        Test.stopTest();

        String newName = [SELECT Name FROM Opportunity WHERE Id = :testSale.Id].Name;
        System.assertNotEquals(newName, originalOpportunityName, 'The Opportunity Name was not changed');

        String customerName = [SELECT Name FROM Account WHERE Id = :testSale.AccountId].Name;
        Vehicle__c vehicleForSale = [SELECT Year__c, Vehicle_Full_Name__c FROM Vehicle__c WHERE Id = :testSale.Vehicle__c];

        // Arguments for formatting the expected name string
        List<Object> args = new List<Object>();
        args.add(customerName);
        args.add(' - ');
        args.add(vehicleForSale.Year__c);
        args.add(' ');
        args.add(vehicleForSale.Vehicle_Full_Name__c);

        String expectedName = String.format('{0}{1}{2}{3}{4}', args);

        System.assertEquals(expectedName, newName, 'The Opportunity Name was not set correctly.');
    }

    // This is an edge case of the testClosedWonOpportunity method above. In this case, there are multiple Opportunities for a single Account.
    // All the Opportunities get Closed - Won at the same time, and the Account's Number of Purchases should get set to the total number 
    // of Opportunity wins. We need to make sure we are incrementing the Purchases for each Account correctly, by also factoring in other
    // potential Opportunities in the same transaction.
    @IsTest
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Tests when multiple opportunities are closed for one customer
        @param: none
        @return: none
    **/
    static void testClosedWonMultipleOpportunitiesForOneCustomer() {
        // handle multiple Opportunities at once to make sure our code really works for all scenarios
        Opportunity testSale = TestFactory.createTestOpportunity(false, true);

        Opportunity testSale2 = TestFactory.createTestOpportunity(false, true);
        // Make sure we have two different Vehicles
        testSale2.Vehicle__c = [SELECT Id FROM Vehicle__c WHERE Id != :testSale.Vehicle__c AND Status__c = :Constants.VEHICLE_STATUSES.IN_STOCK LIMIT 1].ID;
        List<Opportunity> sales = new List<Opportunity>{ testSale, testSale2 };
        insert sales;

        // Verify state before automation
        System.assertEquals(0, [SELECT Number_of_Purchases__c FROM Account WHERE Id = :testSale.AccountId].Number_of_Purchases__c);
        System.assertEquals(Constants.VEHICLE_STATUSES.PENDING, [SELECT Status__c FROM Vehicle__c WHERE Id = :testSale.Vehicle__c].Status__c);
        System.assertEquals(Constants.VEHICLE_STATUSES.PENDING, [SELECT Status__c FROM Vehicle__c WHERE Id = :testSale2.Vehicle__c].Status__c);

        // While we don't really need startTest() and stopTest() here, this serves as kind of a visual demarcation for where our actions begin.
        Test.startTest();
            for(Opportunity thisSale : sales) {
                thisSale.StageName = Constants.STAGE_NAMES.CLOSED_WON;
            }
            
            update sales;
        Test.stopTest();

        System.assertEquals(2, [SELECT Number_of_Purchases__c FROM Account WHERE Id = :testSale.AccountId].Number_of_Purchases__c);
        System.assertEquals(Constants.VEHICLE_STATUSES.SOLD, [SELECT Status__c FROM Vehicle__c WHERE Id = :testSale.Vehicle__c].Status__c);
        System.assertEquals(Constants.VEHICLE_STATUSES.SOLD, [SELECT Status__c FROM Vehicle__c WHERE Id = :testSale2.Vehicle__c].Status__c);
    }    

    /**
        @author: Dylan Chorley
        @date: 17-Aug-2022
        @description: Tests the trigger capability to add Users to the Sales queue when they become owner of a queue 
    **/
    @IsTest
    static void testQueueAddition(){
        
        // Get count of number of members in group
        //Add to an empty queue
        Test.startTest();
        Profile p = [SELECT Id From Profile LIMIT 1];
        User u = TestFactory.createTestUser(p.id, true);
        Integer oldCount = [SELECT COUNT() FROM GroupMember WHERE Group.Name='Sales' and Group.Type = 'Queue'];
        Opportunity testSale = TestFactory.createTestOpportunity(false, true);
        testSale.OwnerId = u.Id;
        insert testSale;
        System.debug(oldCount);
        Test.stopTest();
        Integer oneCount = [SELECT COUNT() FROM GroupMember WHERE Group.Name='Sales' and Group.Type = 'Queue'];
        //Test.stopTest();
        System.assertEquals(oldCount+1, oneCount, 'There should be one new item in queue');
        //Add same name to queue of 1
        
        Opportunity testSale2 = TestFactory.createTestOpportunity(false, true);
        testSale2.OwnerId = u.Id;
        insert testSale2;
        System.assert(oneCount == [SELECT COUNT() FROM GroupMember WHERE Group.Name='Sales' and Group.Type = 'Queue'], 'Should be no new items in queue');
        

    }

    @IsTest
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Tests that the tax is added 
        @param: none
        @return: none
    **/
    static void testTaxAdded(){
        //create an opportunity
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opp = TestFactory.createTestOpportunity(false, true);
        opp.AccountId = [SELECT Id, State__c FROM Account WHERE State__c = 'Alabama' LIMIT 1][0].Id;
        opp.Amount = 10000;
        Id oppId = opp.AccountId;
        insert opp;
        Opportunity collected = [SELECT AccountId, Tax_Amount__c, Total_Due__c FROM Opportunity WHERE AccountId=:oppId LIMIT 1][0];
        System.assertEquals(600, collected.Tax_Amount__c,'The tax amount should now have a value');
        System.assertEquals(15600, collected.Total_Due__c,'The total amount should be populated');
        //create a second account and calculate for multiple opportunities inserted at once 
        Opportunity opp1 = TestFactory.createTestOpportunity(false, true);
        opp1.AccountId = [SELECT Id, State__c FROM Account WHERE State__c = 'Texas' LIMIT 1][0].Id;
        opp1.Amount = 100000;
        Opportunity opp2 = TestFactory.createTestOpportunity(false, true);
        opp2.AccountId = [SELECT Id, State__c FROM Account WHERE State__c = 'New York' LIMIT 1][0].Id;
        opp2.Amount = 100000;
        oppId = opp2.AccountId;
        oppList.add(opp1);
        oppList.add(opp2);
        insert oppList;
        Opportunity collected2 = [SELECT AccountId, Tax_Amount__c, Total_Due__c FROM Opportunity WHERE AccountId=:oppId LIMIT 1][0];
        System.assertEquals(600, collected2.Tax_Amount__c,'The tax amount should now have a value');
        System.assertEquals(15600, collected2.Total_Due__c,'The total amount should be populated');
        //System.assertEquals(10, [SELECT Parking_Space__c FROM Vehicle__c WHERE Parking_Space__c =:'Auto'].size());
    }
}