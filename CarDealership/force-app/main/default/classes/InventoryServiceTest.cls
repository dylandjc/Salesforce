/** */
@IsTest
public with sharing class InventoryServiceTest {


    @IsTest
    static void testAutoWrapperComparison(){
        TestFactory.createTestParkingLot();    
        Test.startTest();
        List<Vehicle__c> vex = TestFactory.createTestVehicle(true, 5, true);
       // System.assertEquals(null, [SELECT ID,  Model__r.Make__r.Name FROM Vehicle__c]);

        List<Vehicle__c> differentMake = new List<Vehicle__c>();
        List<Vehicle__c> sameMake = new List<Vehicle__c>();
        sameMake.add(vex[0]);
        //vex2[0].Model__r.Vehicle_Make__c = [SELECT ID From Make__c WHERE Id!=:vex[0].Model__r.Vehicle_Make__c LIMIT 1].Id;
        //differentMake.add(vex2);
        vex[2].Year__c = 1999;
        sameMake.add(vex[2]);
        vex[3].Year__c = 2000;
        sameMake.add(vex[3]);
        //System.assert(sameMake.size()>1, 'make sure enough in each list');
        //System.assertEquals(null, sameMake, ' make sure enough in each list');
        //System.assert(differentMake.size()==1, ' make sure enough in each list');
        InventoryService.AutoWrapper aw1 = new InventoryService.AutoWrapper(sameMake[1]);
        InventoryService.AutoWrapper aw2 = new InventoryService.AutoWrapper(sameMake[2]);
        Integer wrapperComparison = aw1.compareTo(aw2);
        //System.assert(aw1.make!=aw2.make, 'Makes are diff');
        System.assertEquals(aw1.make<aw2.make, wrapperComparison==1,'Comparison of makes is correct');
        InventoryService.AutoWrapper aw3 = new InventoryService.AutoWrapper(sameMake[2]);
        Integer wrapperSameComparison = aw3.compareTo(aw2);
        System.assertEquals(sameMake[1].Year__c<sameMake[0].Year__c, wrapperSameComparison==1, 'the years are ordered');
        
        InventoryService.AutoWrapper aw4 = new InventoryService.AutoWrapper(sameMake[2]);
        Integer wrapperSameComparison2 = aw3.compareTo(aw4);
        System.assertEquals(sameMake[1].Year__c<sameMake[0].Year__c, wrapperSameComparison2==1, 'the years are ordered');
        Test.stopTest();
        
    }

    @IsTest
    static void testDoPost(){
        
        Test.startTest();
       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/autos/v1/search-inventory/';       
        String postData = '{test}';
        String jsonMsg=JSON.serialize(postData);
        req.requestBody = Blob.valueof(jsonMsg);
        Boolean fails = false;
        try{
            InventoryService.ResponseWrapper wrapperNone = InventoryService.doPost();
        }catch(Exception ex){
            fails = true;
        }
        System.assert(fails, 'Should fail with nothing to serialize');
        //System.assertEquals(1, [SELECT ID FROM Error_Log__c].size(), 'One new error');
        req = new RestRequest(); 
        res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.httpMethod = 'POST';
        req.requestUri = '/autos/v1/search-inventory/';       
        String postData1 = '{\r\n"make": "Land Rover",\r\n"type": "SUV",\r\n"minYear": 2019,\r\n"maxYear": null,\r\n"color": "Beige"\r\n}';
        //String jsonMsg1 = JSON.serialize(postData1);
        String jsonMsg1 = postData1;
        //System.assertEquals(null, jsonMsg1);
        req.requestBody = Blob.valueof(jsonMsg1);
        RestContext.request = req;
   	    RestContext.response= res;
        //System.assertEquals(null, JSON.deserialize(jsonMsg1).toString());
        InventoryService.ResponseWrapper wrapperOne = InventoryService.doPost();
        //System.assertEquals([SELECT Message__c FROM Error_Log__c].Message__c, null);
        System.assert(wrapperOne.success, true);
        Test.stopTest();
        
    }
}