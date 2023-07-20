/**
    @author: Dan Thoreson
    @date: 30-Sep-2022
    @description: Controller for the vehicleDetails LWC.
    @test class: VehicleDetailsController - TODO
**/
global with sharing class VehicleDetailsController {

    /**
        @author: Dan Thoreson
        @date: 30-Sep-2022
        @description: Retrieves a Vehicle related to the inputted Opportunity Id
    **/
    @AuraEnabled
    public static VehicleDetailsWrapper getVehicleForOpportunity(Id opportunityId) {
        try {
            Id vehicleId = [SELECT Vehicle__c FROM Opportunity WHERE Id = :opportunityId].Vehicle__c;

            if(vehicleId == null) {
                throw new AuraHandledException('Unable to find a Vehicle for Opportunity: ' + opportunityId);
            }

            Vehicle__c veh = [SELECT Id, City_MPG__c, Color__c, Cylinders__c, Drive_Type__c, 
                        Highway_MPG__c, Mileage__c, Model__c, Name, Parking_Space__c, 
                        Pre_Owned__c, Price__c, Purchase_Date__c, Purchase_Price__c, 
                        Sell_Date__c, Status__c,  Transmission__c, VIN_Number__c, Vehicle_Full_Name__c, 
                        Vehicle_Make__c, Year_Str__c, Year__c
                    FROM Vehicle__c
                    WHERE Id = :vehicleId];
            List<Vehicle__c> simlarVehs = getSimilarVehicleForOpportunity(veh);
            return new VehicleDetailsWrapper(veh, simlarVehs);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
        @author: Dylan Chorley
        @date: 05-Oct-2022
        @description: Gets list of similar vehicles for opportunity 
        @param: Vehicle veh to get similar vehicles for
        @return: List of vehicles
    **/
    @AuraEnabled
    global static List<Vehicle__c> getSimilarVehicleForOpportunity(Vehicle__c veh){
        try{
            if(veh == null){
                throw new AuraHandledException('Unable to find a Vehicle ' + veh);
            }
            //get list of vehicles with same make 
            List<Vehicle__c> cutToTwo = new List<Vehicle__c>();
            List<Vehicle__c> finalVehs = new List<Vehicle__c>();
            List<Vehicle__c> sameMake = new List<Vehicle__c>([SELECT Id, City_MPG__c, Color__c, Cylinders__c, Drive_Type__c, 
            Highway_MPG__c, Mileage__c, Model__c, Name, Parking_Space__c, 
            Pre_Owned__c, Price__c, Purchase_Date__c, Purchase_Price__c, 
            Sell_Date__c, Status__c,  Transmission__c, VIN_Number__c, Vehicle_Full_Name__c, 
            Vehicle_Make__c, Year_Str__c, Year__c
            FROM Vehicle__c WHERE Status__c =:Constants.VEHICLE_STATUSES.IN_STOCK AND Vehicle_Make__c=:veh.Vehicle_Make__c AND Id!=:veh.Id]);
            if(sameMake.size()< 2){
                if(sameMake.size() == 1){
                    finalVehs.add(sameMake[0]);
                }
                else{
                    Decimal lowRange = veh.Price__c - (veh.Price__c*0.2);
                    Decimal highRange = veh.Price__c + (veh.Price__c*0.2);
                    List<Vehicle__c> sameAmount = new List<Vehicle__c>([SELECT Id, City_MPG__c, Color__c, Cylinders__c, Drive_Type__c, 
                    Highway_MPG__c, Mileage__c, Model__c, Name, Parking_Space__c, 
                    Pre_Owned__c, Price__c, Purchase_Date__c, Purchase_Price__c, 
                    Sell_Date__c, Status__c,  Transmission__c, VIN_Number__c, Vehicle_Full_Name__c, 
                    Vehicle_Make__c, Year_Str__c, Year__c
                    FROM Vehicle__c WHERE Status__c =:Constants.VEHICLE_STATUSES.IN_STOCK AND Id!=:veh.Id AND Price__c>:lowRange AND Price__c<:highRange]);
                    if(sameAmount.size() > 0){
                        finalVehs.addAll(sameAmount);
                    }
                }
            }
            else{
                finalVehs.addAll(sameMake);
            }
            finalVehs.addAll([SELECT Id, City_MPG__c, Color__c, Cylinders__c, Drive_Type__c, 
                Highway_MPG__c, Mileage__c, Model__c, Name, Parking_Space__c, 
                Pre_Owned__c, Price__c, Purchase_Date__c, Purchase_Price__c, 
                Sell_Date__c, Status__c,  Transmission__c, VIN_Number__c, Vehicle_Full_Name__c, 
                Vehicle_Make__c, Year_Str__c, Year__c
                FROM Vehicle__c WHERE Status__c =:Constants.VEHICLE_STATUSES.IN_STOCK LIMIT 2]);
            cutToTwo.add(finalVehs[0]);
            cutToTwo.add(finalVehs[1]);
            return cutToTwo;
          
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
        @author: Dylan Chorley
        @date: 05-Oct-2022
        @group: 
        @description: Wrapper class for getting the vehicle details
        @test class: none just holds values from constructor
    **/
    global class VehicleDetailsWrapper{
        @AuraEnabled public Vehicle__c similarVehicles1;
        @AuraEnabled public Vehicle__c similarVehicles2;
        @AuraEnabled public Vehicle__c currentVehicle;

        public VehicleDetailsWrapper(Vehicle__c curr, List<Vehicle__c> similarVeh){
            this.currentVehicle = curr;
            this.similarVehicles1 = similarVeh[0];
            this.similarVehicles2 = similarVeh[1];
        }
    }

}