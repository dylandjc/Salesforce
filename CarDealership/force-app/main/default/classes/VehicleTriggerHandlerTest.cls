@IsTest
/**
   @author: Dylan Chorley
   @date: 20-Sep-2022
   @group: Testing Trigger Handlers
   @description: Tests the Vehicle__C trigger handler
   @test class: this is it
**/
public with sharing class VehicleTriggerHandlerTest {
   @TestSetup
   static void makeData(){
      TestFactory.createTestParkingLot();
   }

   @IsTest
   /**
      @author: Dylan Chorley
      @date: 20-Sep-2022
      @description: Tests that parking spaces are created and filled correctly on vehicle insert
      @param: none
      @return: none
   **/
   static void testBeforeInsert(){
      System.assertEquals(0, [SELECT COUNT() FROM Parking_Space__c WHERE Space_Filled__c=TRUE]);
      TestFactory.createTestVehicle(true, 10, true);
     
      System.assert(true, [SELECT Space_Filled__c FROM Parking_Space__c WHERE Name=:'A1'].Space_Filled__c);
      System.assertEquals(0, [SELECT Parking_Space__c FROM Vehicle__c WHERE Parking_Space__c=:'Auto'].size());

      //TEST FOR NOT IN STOCK VEHICLES INSERTED 
      TestFactory.createTestVehicle(true, 1, false);
      System.assertEquals(1, [SELECT Parking_Space__c FROM Vehicle__c WHERE Parking_Space__c=:'Auto'].size(), 'The vehicle should be sold and therefore not have a space');
   }


   @IsTest
   /**
      @author: Dylan Chorley
      @date: 20-Sep-2022
      @description: Tests that spaces are filled appropriately when updated and removed as such
      @param: none
      @return: none just assert statements
   **/
   static void testBeforeUpdate(){
      TestFactory.createTestVehicle(true, 13, true);
      //test for update in stock to pending 
      Vehicle__c test = [SELECT Id, Parking_Space__c, Status__c FROM Vehicle__c LIMIT 1];
      test.Status__c = Constants.VEHICLE_STATUSES.PENDING;
      update test;
      System.assertEquals(12, [SELECT Parking_Space__c FROM Vehicle__c WHERE Parking_Space__c!=:'Auto'].size());
      System.assertEquals(1, [SELECT Parking_Space__c FROM Vehicle__c WHERE Parking_Space__c=:'Auto'].size(), 'The vehicle should be pending and therefore not have a space');
      //test for update pending back to instock 
      Vehicle__c test2 = [SELECT Id, Parking_Space__c, Status__c FROM Vehicle__c WHERE Status__c=:Constants.VEHICLE_STATUSES.PENDING LIMIT 1];
      test2.Status__c = Constants.VEHICLE_STATUSES.IN_STOCK;
      update test2;
      System.assertEquals(13, [SELECT Parking_Space__c FROM Vehicle__c WHERE Parking_Space__c!=:'Auto'].size(), 'There should be no vehicles pending and should all be parked');
      System.assertEquals(0, [SELECT Parking_Space__c FROM Vehicle__c WHERE Parking_Space__c=:'Auto'].size(), 'The vehicle should be pending and therefore not have a space');
   }
   /**
      @author: Dylan Chorley
      @date: 27-Sep-2022
      @description: Tests that upon update of api data the data is changed and flag becomes true 
      @param: none
      @return: none
   **/
   @IsTest
   static void testVehApiUpdated(){
      Test.startTest();
      Test.setMock(HTTPCalloutMock.class, new MockT());
      TestFactory.createTestMake(true, 1);
      List<Make__c> mks = new List<Make__c>([SELECT Id FROM Make__c LIMIT 1]);
      List<Model__c> makez = TestFactory.createTestModel(false,mks[0].Id, 1);
      makez[0].Name = 'Camry';
      insert makez;
      List<Vehicle__c> veh = TestFactory.createTestVehicle(false,1,true);
      veh[0].Year__c = 1993;
      veh[0].Year_Str__c = '1993';
      veh[0].Model__c = [SELECT Id, Name FROM Model__c WHERE Name=:'Camry' LIMIT 1].Id;
      System.assertEquals(false, veh[0].Api_Overwritten__c, 'Flag should not have been raised yet');
      System.assertEquals(false, veh[0].Populated_From_Api__c, 'Flag should not have been raised yet');
      
      insert veh;
      System.assertEquals(1, [SELECT COUNT(ID)ct FROM Vehicle__c][0].get('ct'), 'Should be one new vehicle added');
      // finish checking this 
      Test.stopTest();
      List<Vehicle__c> camry = new List<Vehicle__c>([SELECT Id, Cylinders__c FROM Vehicle__c LIMIT 1]);
      System.assertEquals(4, camry[0].Cylinders__c, 'has not changed yet');
     
      camry[0].Cylinders__c = 8;
      update camry;
      System.assertEquals(1, [SELECT COUNT(ID)ct FROM Vehicle__c][0].get('ct'), 'Should still be one new vehicle added');
      List<Vehicle__c> camry2 = new List<Vehicle__c>([SELECT Id, Populated_From_Api__c, Cylinders__c, Api_Overwritten__c FROM Vehicle__c LIMIT 1]);
      System.assertEquals(true, camry2[0].Populated_From_Api__c, 'Should be populated');
      System.assertEquals(8, camry2[0].Cylinders__c, 'Cylinder value should have changed');
      System.assertEquals(true, camry2[0].Api_Overwritten__c, 'Flag raised as data is updated');
   }
   /**
      @author: Dylan Chorley
      @date: 28-Sep-2022
      @description: FOr testing the api work we need a mock class with a fake json response 
      @param: none 
      @return: httpresponse 
   **/
   private class MockT implements HttpCalloutMock{
      public HttpResponse respond(HttpRequest req){
         HttpResponse res = new HttpResponse();
         String jso1 = '[{"city_mpg": 18,"class": "midsize car","combination_mpg": 21,"cylinders": 4,"displacement": 2.2,"drive": "fwd","fuel_type": "gas","highway_mpg": 26,"make": "toyota","model": "camry","transmission": "a","year": 1993}]';
         res.setBody(jso1);
         res.setStatusCode(200);
         return res;
      }
   }

      /**
      @author: Dylan Chorley
      @date: 28-Sep-2022
      @description: FOr testing the api work we need a mock class with a fake json response that causes failure
      @param: none 
      @return: httpresponse 
   **/
  private class MockT2 implements HttpCalloutMock{
   public HttpResponse respond(HttpRequest req){
      HttpResponse res = new HttpResponse();
      String jso1 = '[{""class": "midsize car"}]';
      res.setBody(jso1);
      res.setStatusCode(200);
      return res;
   }
}

   @IsTest
   static void notInApi(){
      
      Test.startTest();
      Test.setMock(HTTPCalloutMock.class, new MockT2());
      TestFactory.createTestMake(true, 1);
      List<Make__c> mks = new List<Make__c>([SELECT Id FROM Make__c LIMIT 1]);
      List<Model__c> makez = TestFactory.createTestModel(false,mks[0].Id, 1);
      makez[0].Name = 'CamO';
      insert makez;
      List<Vehicle__c> veh = TestFactory.createTestVehicle(false,1,true);
      veh[0].Year__c = 1994;
      veh[0].Year_Str__c = '1994';
      veh[0].Model__c = [SELECT Id, Name FROM Model__c WHERE Name=:'CamO' LIMIT 1].Id;
      insert veh;
      Test.stopTest();
      System.assertEquals(1, [SELECT Count(ID)ct From Error_Log__c][0].get('ct'), 'One item should be added into the error log');
      
      
   }
   /**
      @author: Dylan Chorley
      @date: 30-Sep-2022
      @description: Tests the before delete ability of code
      @param: none
      @return: none
   **/
   @IsTest
   static void testBeforeDelete(){
      
      Test.startTest();
      List<Vehicle__c> veh = TestFactory.createTestVehicle(true, 1, true);
      Vehicle__c veh1 = [SELECT ID FROM Vehicle__c LIMIT 1];
      try{
         DELETE veh1;
         Parking_Space__C ps = [SELECT ID, Space_Filled__c FROM Parking_Space__C WHERE Name='A1'];
         System.assertEquals(false, ps.Space_Filled__c, 'Space should be open again');
      }
      catch(Exception e){
         System.debug(e.getMessage());
         Throw new JSONException();
      }
      Test.stopTest();
      
   }

   @IsTest
   static void testCheckYearValue(){
      List<Vehicle__c> vex = TestFactory.createTestVehicle(false, 1, true);
      vex[0].Year_Str__c = '1001';
      Boolean correctErrorThrown = false;
      try{
         insert vex;
      }
      catch(Exception ex)
      {
         correctErrorThrown = ex.getMessage().contains('Please give a proper year value!');
         System.assertEquals(0,[SELECT COUNT(ID)ct FROM VEHICLE__C][0].get('ct') ,'No vehicles should have been inserted');
      }
      System.assertEquals(true, correctErrorThrown, 'This ius the correct error message');
   }

}