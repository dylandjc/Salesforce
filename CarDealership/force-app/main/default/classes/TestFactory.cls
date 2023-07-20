/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: TestFactories
    @description: The main test factory used for testing in this org
    @test class: none covered by previous test classes
**/
public with sharing class TestFactory {

    public static Id customerRecordTypeId {get {
        if(customerRecordTypeId == null) {
            customerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        }

        return customerRecordTypeId;
    } set;}

    public static Id testCustomerId {get {
        if(testCustomerId == null) {
            testCustomerId = [SELECT Id FROM Account WHERE RecordTypeId = :customerRecordTypeId LIMIT 1].Id;
        }

        return testCustomerId;
    } set;}

    
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates one test account 
        @param: isInserted for whether it should be inserted automatically or not
        @return: new test Account
    **/
    public static Account createTestAccount(Boolean isInserted){
        Account customer = new Account();
        customer.RecordTypeId = customerRecordTypeId;
        customer.FirstName = RandomizationUtils.generateRandomString(5);
        customer.LastName = RandomizationUtils.generateRandomString(9);
        customer.Phone = RandomizationUtils.generateRandomPhone();
        customer.Number_of_Purchases__c = 0;
        customer.State__c = 'Alabama';

        if(isInserted){
        insert customer;
        }
        
        return customer;
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: List of accounts
        @param: isInserted for whether to insert length for the length of list to be made
        @return: List of accounts
    **/
    public static List<Account> createTestAccountList(Boolean isInserted, Integer length){
        List<Account> accz = new List<Account>();
        Integer x = 0;
        while(x<length){
            Account acc = createTestAccount(false);
            switch on x{
                when 0{
                    acc.State__c = 'Alabama';
                }
                when 1{
                    acc.State__c = 'New York';
                }   
                when 2{
                    acc.State__c = 'Texas';
                }
                when else{
                    acc.State__c = 'Alabama';
                }   
            }
            accz.add(acc);
            x++;
        }
        if(isInserted){
            insert accz;
        }
        return accz;
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Create Test opportunity 
        @param: isInserted on whether to insert or not 
        @return: New test Opportunity
    **/
    public static Opportunity createTestOpportunity(Boolean isInserted, Boolean isVehicle) {
        Opportunity testSale = new Opportunity();
        testSale.Name = RandomizationUtils.generateRandomString(12);
        testSale.CloseDate = System.today().addDays(7);
        testSale.StageName = 'In-Person Inquiry';
        if(isVehicle){
            testSale.AccountId = testCustomerId;
            testSale.Vehicle__c = TestUtilities.getVehicle(true);
            testSale.OwnerId = TestUtilities.getOwner(false);
        }
        testSale.Amount = Math.random()*1000;
        if(isInserted){
            insert testSale;
        }
        return testSale;
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: List of opportunities to test with is built
        @param: isInserted for whether to insert all the opportunities, length for length of list 
        @return: List of opportunities
    **/
    public static List<Opportunity> createTestOpportunityList(Boolean isInserted, Integer length){
        List<Opportunity> opps = new List<Opportunity>();
        Id tester = testCustomerId;
        List<Group> ggId = new List<Group>([SELECT Id FROM Group WHERE Name='Sales' and Type = 'Queue' LIMIT 1]); 
        List<GroupMember> allMembers = new List<GroupMember>([SELECT UserOrGroupId FROM GroupMember WHERE GroupId=:ggId LIMIT 1]);
        List<Vehicle__c> vehs = new List<Vehicle__c>([SELECT Id FROM Vehicle__c]);
        if(length > vehs.size()){
            TestFactory.createTestVehicle(true, length-vehs.size()+1, true);
        }
        vehs = new List<Vehicle__c>([SELECT Id FROM Vehicle__c]);
        Integer x = 0;
        while(x<length){
            Opportunity opp = createTestOpportunity(false, false);
            opp.AccountId = tester;
            opp.Vehicle__c = vehs[x].Id;
            opp.OwnerId = allMembers[0].UserOrGroupId;
            opps.add(opp);
            x++;
        }
        if(isInserted){
            insert opps;
        }
        return opps;
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Create test lead with or without a vehicle
        @param: isInserted to insert or not/ isVehicle to include a test vehicle or not 
        @return: new test lead
    **/
    public static Lead createTestLead(Boolean isInserted, Boolean isVehicle){
        Lead ls = new Lead();
        ls.Salutation = 'Dr.';
        ls.FirstName = RandomizationUtils.generateRandomString(6);
        ls.LastName = RandomizationUtils.generateRandomString(6);
        ls.Company = RandomizationUtils.generateRandomString(6);
        ls.Phone = RandomizationUtils.generateRandomPhone();
        ls.Email = RandomizationUtils.generateRandomString(6) + '@doordash.com';
        ls.Status = 'Open - Not Contacted';
        //ls.Planned_Purchase_Time__c = '1-2 Weeks';
        ls.Potential_Number_of_Purchases__c = 2;
        if(isVehicle){
            ls.Vehicle__c = [SELECT Id, Price__c FROM VEHICLE__c WHERE Status__c=:Constants.VEHICLE_STATUSES.IN_STOCK LIMIT 1].Id;
        }
        //ls.State__c = 'Alabama'; 
        ls.Lead_Service_Id__c =  RandomizationUtils.generateRandomString(6);
        if(isInserted){
            insert ls;
        }
        return ls;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Create list of test leads
        @param: isInserted true if list of leads should be inserted, isVehicle if it includes a vehicle
        and length for how many in list
        @return: List of leads 
    **/
    public static List<Lead> createTestLeadList(Boolean isInserted, Boolean isVehicle, Integer length){
        List<Lead> leadz = new List<Lead>();
        Integer x = 0;
        if(isVehicle){
            List<Vehicle__c> ls = [SELECT Id FROM Vehicle__c WHERE Status__c = :Constants.VEHICLE_STATUSES.IN_STOCK];
            while(x<length){
                Lead temp = createTestLead(false, false);
                temp.Vehicle__c = ls[x].Id;
                leadz.add(temp);
                x++;
            }
        }else{
            while(x<length){
                leadz.add(createTestLead(false, false));
                x++;
            }
        }
        if(isInserted){
            insert leadz;
        }
        return leadz;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Create test groups 
        @param: isInserted true if group should be inserted 
        @return: new test Group with name Sales
    **/
    public static Group createTestGroup(Boolean isInserted){
        Group sales = new Group();
        sales.Name = 'Sales';
        if(isInserted){
            insert sales;
        }
        return sales;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates a test user 
        @param: profile id known as pid and boolean isInserted for whether or not to insert the user
        @return: new test User
    **/
    public static User createTestUser(Id pid, Boolean isInserted){
        User u = new User();
        String email = RandomizationUtils.generateRandomString(7) + '@doordash.com';
        u.Username = email;
        u.LastName = RandomizationUtils.generateRandomString(10);
        u.Email = email;
        u.Alias= RandomizationUtils.generateRandomString(5);
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey= 'UTF-8';
        u.ProfileId = pid;
        u.LanguageLocaleKey ='en_US';
        if(isInserted){
            insert u;
        }
        return u;
    }   

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates test parking lot
        @param: required for almost all test classes ** no params
        @return: Parking Lot object and parking spaces/lot sections inserted
    **/
    public static Parking_Lot__c createTestParkingLot(){
        //Dealership -- Parking Lot
        Parking_Lot__c dealershipo = new Parking_Lot__c(Name = 'Dealership', Number_of_Lots__c = 15);
        Database.insert(dealershipo, false);

        List<Lot_Section__c> parkingLots = new List<Lot_Section__c>();
        List<Parking_Space__c> parkingSpaces = new List<Parking_Space__c>();
        //Parking Lots
        for(String lotName: Constants.LOTSPACES.keySet()){
            Lot_Section__c current = new Lot_Section__c();
            current.Name = lotName;
            current.Number_of_Spaces__c = Constants.LOTSPACES.get(lotName);
            current.Parking_Lot__c = ParkingSpaceUtilities.DEALERSHIP.Id;
            current.Spaces_Full__c = false;
            parkingLots.add(current);

        }
        Database.insert(parkingLots);

        //Parking Spaces 
        for(Lot_Section__c current: parkingLots){
            Integer x = 0;
            for(x=0; x<current.Number_of_Spaces__c; x++){
                Parking_Space__c ps = new Parking_Space__c();
                ps.Name = current.Name+(x+1);
                ps.Space_Filled__c = false;
                ps.Lot_Section__c = current.Id;
                parkingSpaces.add(ps);
            }
        }
        Database.insert(parkingSpaces);
        return dealershipo;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates a test vehicle 
        @param: isInserted inserts vehicle if true,
         length for number of vehicles isInStock if true makes all vehicles instock otherwise randomizes
        @return: List of vehicles
    **/
    public static List<Vehicle__c> createTestVehicle(Boolean isInserted, Integer length, Boolean isInStock){
        List<Make__c> mk = createTestMake(true, 2*length);
        List<Parking_Space__c> ps = new List<Parking_Space__c>([SELECT Id, Name FROM Parking_Space__c ORDER BY Name ASC]);
        List<Model__c> model = createTestModel(true, mk[0].Id, 2*length);
        model.addAll(createTestModel(true, mk[1].Id, 2));
        List<Vehicle__c> vehics = new List<Vehicle__c>();
        Vehicle__c inStockVehicle = new Vehicle__c();
        if(isInStock){
            for(Integer x=0; x<length; x++){
                Vehicle__c vex = new Vehicle__c();
                vex.Model__c = ((Model__c)RandomizationUtils.getRandomElementFromList(model)).Id;
                vex.VIN_Number__c = RandomizationUtils.generateRandomString(Constants.VIN_LENGTH);
                vex.Purchase_Date__c = Date.today();
                vex.Status__c = 'In Stock';
                vex.Purchase_Price__c = 10000;
                vex.Price__c = 15000;
                vex.Year__c = 2023;
                vex.Pre_Owned__c = 'New';
                vex.Color__c = 'Beige';
                vex.Mileage__c = Math.round(Math.random()*100);
                vehics.add(vex);
            }
        }
        else{
            Boolean switcher = false;
            for(Integer x=0; x<length; x++){
                Vehicle__c vex = new Vehicle__c();
                vex.Model__c = ((Model__c)RandomizationUtils.getRandomElementFromList(model)).Id;
                vex.VIN_Number__c = RandomizationUtils.generateRandomString(Constants.VIN_LENGTH);
                vex.Purchase_Date__c = Date.today();
                if(switcher){
                    vex.Status__c = Constants.VEHICLE_STATUSES.IN_STOCK;
                }
                else{
                    vex.Status__c = Constants.VEHICLE_STATUSES.PENDING;
                }
                switcher = !switcher;
                vex.Purchase_Price__c = 10000;
                vex.Price__c = 15000;
                vex.Year__c = 2023;
                vex.Pre_Owned__c = 'New';
                vex.Color__c = 'Beige';
                vex.Mileage__c = Math.round(Math.random()*100);
                vehics.add(vex);
            }
        }
        if(isInserted){
            insert vehics;
        }
        return vehics;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates a list of test makes
        @param: isInserted true if make should be inserted, length for number of makes
        @return: List of makes
    **/
    public static List<Make__c> createTestMake(Boolean isInserted,  Integer length){
        
        List<Make__c> testMakes = new List<Make__c>();
        for(Integer x=0; x<length; x++){
            Make__c testMake = new Make__c();
            testMake.Name = String.valueOf(RandomizationUtils.getRandomElementFromList(Constants.ALL_MAKES));
            testMake.Country_of_Origin__c = Constants.COUNTRIES.USA;
            testMakes.add(testMake);
        }
        if(isInserted){
            insert testMakes;
        }
        return testMakes;
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates list of test models
        @param: isInserted true if would like to insert them all,
         makeId is the id of the make for particular model, length is numberof models in list
        @return: List of models 
    **/
    public static List<Model__c> createTestModel(Boolean isInserted, Id makeId, Integer length){
        List<Model__c> testModels = new List<Model__c>();
        String makeName = [SELECT NAME FROM MAKE__c WHERE Id=:makeId LIMIT 1].Name;
        for(Integer x=0; x<length; x++){
            Model__c testModel = new Model__c();
            testModel.Name = String.valueOf(RandomizationUtils.getRandomElementFromList(Constants.MODELS_BY_MAKES.get(makeName)));
            testModel.Vehicle_Make__c = makeId;
            testModel.In_Production__c = true;
            testModel.Vehicle_Type__c = 'SUV';
            testModels.add(testModel);
        }
        if(isInserted){
            insert testModels;
        }
        return testModels;    
    }

       // Returns a Vehicle that's either In Stock or not In Stock, depending on the argument.
       public static List<Vehicle__c> getVehicleList(Boolean isInStock) {
        if(isInStock) {
            return [SELECT Id FROM Vehicle__c WHERE Status__c = :Constants.VEHICLE_STATUSES.IN_STOCK];
        } else {
            return [SELECT Id FROM Vehicle__c WHERE Status__c != :Constants.VEHICLE_STATUSES.IN_STOCK];
        }
    }

    public static void createTestSalesRepCache(Integer numberOfRecords){
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.SaleSplit');
        Integer index = 0 ;
        while(index < numberOfRecords){
            String sr = 'Dylan' + String.valueOf(index);
            Map<String, Integer> temp = new Map<String, Integer>();
            temp.put('NumberOfSales', index*10);
            temp.put('GrossProfits', Crypto.getRandomInteger()*1000);
            orgPart.put(sr.deleteWhitespace(), temp, 28800);
            index++;
        }

    }

    public static void createTestVehicleCache(Integer numberOfRecords){
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.VehicleSplit');
        Integer index = 0;
        List<String> allMakeModels = new List<String>();
        TestFactory.createTestParkingLot();
        List<Vehicle__c> allVehics = TestFactory.createTestVehicle(false, numberOfRecords, true);
        insert allVehics;
        TestFactory.createTestAccountList(true, 3);
        List<Opportunity> opps = TestFactory.createTestOpportunityList(false, numberOfRecords);
        for(Opportunity op: opps){
            op.StageName = Constants.STAGE_NAMES.CLOSED_WON;
        }
        for(Vehicle__c vex: [SELECT Model__r.Vehicle_Make__r.Name, Model__r.Name FROM Vehicle__c]){
            allMakeModels.add(vex.Model__r.Vehicle_Make__r.Name);
            allMakeModels.add(vex.Model__r.Name);
        }
        while(index < numberOfRecords){
            String sr = String.valueOf(RandomizationUtils.getRandomElementFromList(allMakeModels));
            Map<String, Integer> temp = new Map<String, Integer>();
            temp.put('NumberOfSales', index*10);
            temp.put('GrossProfits', Crypto.getRandomInteger()*1000);
            orgPart.put(sr.deleteWhitespace(), temp, 28800);
            index++;
        }
    }   


}