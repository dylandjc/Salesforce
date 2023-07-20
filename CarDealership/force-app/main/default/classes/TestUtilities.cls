/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Test Utilities
    @description: Helper functions that are used in test factory
    @test class: 
**/
public with sharing class TestUtilities {

    // Sometimes it's convenient to have test data attributes as class variables, for access in the various test methods.
   
    // Returns a Vehicle that's either In Stock or not In Stock, depending on the argument.
    public static Id getVehicle(Boolean isInStock) {
        if(isInStock) {
            return [SELECT Id FROM Vehicle__c WHERE Status__c = :Constants.VEHICLE_STATUSES.IN_STOCK  LIMIT 1].Id;
        } else {
            return [SELECT Id FROM Vehicle__c WHERE Status__c != :Constants.VEHICLE_STATUSES.IN_STOCK  LIMIT 1].Id;
        }
    }

    

    /**
        @author: Dylan Chorley
        @date: 17-Aug-2022
        @description: Returns an OwnerId that is not in the sales queue if the 
        boolean is true and returns ownerId in sales queue if boolean is false  

        @param: Boolean check will be True or False
        @return: User/OwnerId
    **/
    public static Id getOwner(Boolean check){
        List<Group> ggId = new List<Group>([SELECT Id FROM Group WHERE Name='Sales' and Type = 'Queue' LIMIT 1]); 
        if(check){
            return [SELECT Id FROM User WHERE Id NOT IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId=:ggId) LIMIT 1].Id;
        }
        else{
            List<GroupMember> allMembers = new List<GroupMember>([SELECT UserOrGroupId FROM GroupMember WHERE GroupId=:ggId]);
            return allMembers[0].UserOrGroupId;
        }
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates a test task using an opportunity
        @param: an opportunity opp
        @return: New task not inserted
    **/
    public static Task createTestTask(Opportunity opp){
            Task testTask = new Task();
            testTask.WhatId = opp.Id;
            return testTask;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates a Lead Staging custom object
        @param: Integer val with value 0 for unique new object 1 for next object with similar id and 2 for object with same number as 1
        @return: 
    **/
    public static Lead_Staging__c createTestLeadStaging(Integer val){
        Lead_Staging__c ls = new Lead_Staging__c();
        String testStageID = [SELECT Lead_Service_Id__c FROM LEAD LIMIT 1].Lead_Service_Id__c;
        if(val == 0){
            ls.Completed__c = false;
            ls.Request_Body__c = '{"id": "x1234","name": {"first": "John","last": "Doedrio","salutation": "Mr"},"phone": "636-363-8636","email": "johndoe@test.com"}';
            return ls;
        }
        else{
            if(val == 1){
                ls.Completed__c = false;
                ls.Request_Body__c = '{"id":"x1234","name": {"first": "John","last": "Doedrio","salutation": "Mr"},"phone": "214-773-6100","email": "johndo1234e@test.com"}';
                return ls;
            }
            else{
                ls.Completed__c = false;
                ls.Request_Body__c = '{"id": "x1erh","name": {"first": "John","last": "Doedrio","salutation": "Mr"},"phone": "214-773-6100","email": "johndo1r1e@test.com"}';
                return ls;

            }
        }

    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates a count list or list of user wrapper class objects
        @param: Boolean check that if true returns list sorted 
        @return: List of user wrapper class objects to test on
    **/
    public static List<UserCountWrapper> createCountList(Boolean check){
        List<UserCountWrapper> ls = new List<UserCountWrapper>();
        List<Opportunity> owners = new List<Opportunity>([SELECT OwnerId FROM Opportunity LIMIT 2]);
        UserCountWrapper count1 = new UserCountWrapper(owners[0].OwnerId,3);
        UserCountWrapper count2 = new UserCountWrapper(owners[1].OwnerId,2);
        ls.add(count1);
        ls.add(count2);
        
        if(check){
            ls.sort();
            return ls;
        }
        else{
            return ls;
        }
    }
    /** 
        @AuraEnabled
        public static List<TopPerformers.TopSalesPerformersWrapper> getTopSalesRepsMock(Boolean isProfit){
            try{
                List<TopPerformers.TopSalesPerformersWrapper> topSales = new List<TopPerformers.TopSalesPerformersWrapper>();
                if(isProfit){
                    
                    topSales.add(new TopPerformers.TopSalesPerformersWrapper('Dylan Chorley', null, 1200));
                    topSales.add(new TopPerformers.TopSalesPerformersWrapper('John Product', null, 1100));
                    topSales.add(new TopPerformers.TopSalesPerformersWrapper('Sales Senior', null, 1000));
                    return topSales;
                }
                else{
                    topSales.add(new TopPerformers.TopSalesPerformersWrapper('Dan Thoreson', 30, null));
                    topSales.add(new TopPerformers.TopSalesPerformersWrapper('Rakesh Senthilnathan', 20, null));
                    topSales.add(new TopPerformers.TopSalesPerformersWrapper('Sriram Swaminathan', 10, null));
                    return topSales;
                }
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }

        @AuraEnabled
        public static List<TopPerformers.TopVehiclePerformersWrapper> getTopVehiclesMock(Boolean isProfit){
            try{
                List<TopPerformers.TopVehiclePerformersWrapper> topSales = new List<TopPerformers.TopVehiclePerformersWrapper>();
                if(isProfit){
                    
                    topSales.add(new TopPerformers.TopVehiclePerformersWrapper('Audi', null, 1200));
                    topSales.add(new TopPerformers.TopVehiclePerformersWrapper('Toyota', null, 1100));
                    topSales.add(new TopPerformers.TopVehiclePerformersWrapper('Ford', null, 1000));
                    return topSales;
                }
                else{
                    topSales.add(new TopPerformers.TopVehiclePerformersWrapper('Porsche', 30, null));
                    topSales.add(new TopPerformers.TopVehiclePerformersWrapper('Ferrari', 20, null));
                    topSales.add(new TopPerformers.TopVehiclePerformersWrapper('Aston Martin', 10, null));
                    return topSales;
                }
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
    */
}