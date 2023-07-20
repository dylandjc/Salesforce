/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Helper function for Trigger Handling
    @description: Vehicle Trigger helper class that has the checks for vehicle
    @test class: VehicleTriggerHandlerTest
**/
public with sharing class VehicleTriggerHelper {

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Checks that the year values for vehicle are correct and convert correctly to string
        @param: list of vehicles being inserted or updated 
        @return: none
    **/
    public static void checkYearValues(List<Vehicle__c> vehics){
        for(Vehicle__c veh:vehics){
            if(veh.Year_Str__c == null && veh.Year__c != null){
                veh.Year_Str__c =String.valueOf(veh.Year__c);
            }
            else{
                if(veh.Year_Str__c.length() == 4 && veh.Year_Str__c.isNumeric() && 
                1900 <= Integer.valueOf(veh.Year_Str__c) && Integer.valueOf(veh.Year_Str__c)<=System.today().year()+1){
                veh.Year__c = Integer.valueOf(veh.Year_Str__c);
                }       
                else{
                    veh.Year_Str__c.addError('Please give a proper year value!');
                }
            }
        }
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: calls Cars API to obtain vehicle information post insert
        @param: list of vehicles
        @return: none
    **/
    public static void afterInsertHelper(List<Vehicle__c> vehics){
        List<Id> updatedVehs = new List<Id>();
        //Map<String, Boolean> alreadyCollected = collectCarMap();
        for(Vehicle__c veh: vehics){
            updatedVehs.add(veh.Id);
        }
        callCarApi(updatedVehs);
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Calls the car api and sets up the callout
        @param: vehicle to be calling api
        @return: Vehicle
    **/
    @future(callout=true)
    public static void callCarApi(List<Id> vehicleCheck){
        //api call using the model and year
        //This list will be used to fill error log or to fill out the text field 
        
        List<Vehicle__c> vehics = new List<Vehicle__c>([SELECT Id, Year_Str__c, Model__c, Model__r.Name FROM Vehicle__c WHERE Id IN: vehicleCheck LIMIT 1]);
        List<Vehicle__c> updatedVehicles = new List<Vehicle__c>();
        for(Vehicle__c veh: vehics){
            List<String> notObtained = new List<String>();
            String modelName = (String) veh.Model__r.Name;
            modelName = modelName.replaceAll(' ', '+');
            modelName = modelName.toLowerCase();
            String year = veh.Year_Str__c;
            String endpoint = 'https://api.api-ninjas.com/v1/cars?limit=1&year=' + year + '&model=' + modelName; 
            System.debug(endpoint);
            try{
                HttpResponse hits = HttpCalloutHelper.makeCallout('CARS_22',null,endpoint);
                if(hits.getBody() == null){
                    throw new XMLException();
                } else{
                    String json1 = hits.getBody();
                    //how to make sure I only got the values of the first in the deserialized version 
                    List<Object> data = new List<Object>();
                    data = (List<Object>)JSON.deserializeUntyped(json1);
                    Map<String, Object> dataUnpacked = new Map<String,Object>();
                    for(Object o: data){
                        dataUnpacked = (Map<String,Object>) o;
                        //to consider == check if the resulting object is numeric and actually renturns a number value 
                        if(dataUnpacked.containsKey('city_mpg')){
                            veh.City_MPG__c = (Integer) dataUnpacked.get('city_mpg');
                        }
                        else{
                            notObtained.add('City MPG');
                        }
                        if(dataUnpacked.containsKey('highway_mpg')){
                            veh.Highway_MPG__c = (Integer) dataUnpacked.get('highway_mpg');
                        }
                        else{
                            notObtained.add('Highway MPG');
                        }
                        if(dataUnpacked.containsKey('cylinders')){
                            veh.Cylinders__c = (Integer) dataUnpacked.get('cylinders');
                        }
                        else{
                            notObtained.add('Cylinders');
                        }
                        if(dataUnpacked.containsKey('transmission')){
                            if(dataUnpacked.get('transmission') == 'a'){
                                veh.Transmission__c = 'Automatic';
                            }
                            if(dataUnpacked.get('transmission') == 'm'){
                                veh.Transmission__c = 'Manual';
                            }
                        }
                        else{
                            notObtained.add('Transmission');
                        }
                        if(dataUnpacked.containsKey('drive')){
                            veh.Drive_Type__c = Constants.API_DRIVE_TYPES.get((String)dataUnpacked.get('drive'));
                        }
                        else{
                            notObtained.add('Drive Type');
                        }
                        if(notObtained.size() < 5){
                            veh.Populated_From_Api__c = true;
                        }
                        else{
                            throw new JSONException('Error: ' + dataUnpacked + ' None of the fields requested were found in the API');
                        }
                        updatedVehicles.add(veh);
                    }
                }
            }
            //add error for every variable that can't be filled or convert the checkbox for data from api to text area and
            // just add to it with what data is actually from api2
            catch(Exception e){
                Logger.insertErrorLog(e, veh.Id);
                //add to error log that no data exists in api for particular year plus car
            }
        //break down response into the new data values 
        //returns a list set veh.data_from_api__c to true
        //`https://api.api-ninjas.com/v1/cars?year=2019&model=range+rover`
        //collect the first item of list 
        //if list not returned  add to error log no data exists in api
        }
        update updatedVehicles;
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Checks if field populated from api is changed and checks overwritten if this is true
        @param: list of new opportunities and map  of old vehicles from previous state
        @return: 
    **/
    public static void checkVehApiUpdated(List<Vehicle__c> newOpp, Map<Id, Vehicle__c> oldMap){
        for(Vehicle__c veh:newOpp){
            Vehicle__c oldVeh = oldMap.get(veh.Id);
            if(veh.Populated_From_Api__c == true && (veh.City_MPG__c != oldVeh.City_MPG__c || 
            veh.Cylinders__c != oldVeh.Cylinders__c || veh.Highway_MPG__c != oldVeh.Highway_MPG__c || 
            veh.Mileage__c != oldVeh.Mileage__c || veh.Transmission__c != oldVeh.Transmission__c)){
                veh.Api_Overwritten__c = true;
            }
        }
    }
}