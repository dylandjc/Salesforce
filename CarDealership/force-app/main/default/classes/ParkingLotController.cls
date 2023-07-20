global with sharing class ParkingLotController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<ParkingSpotWrapper>> initializeLotData(){
        try {
            Map<String, List<ParkingSpotWrapper>> results = new Map<String, List<ParkingSpotWrapper>>();
            Map<String, ParkingSpotWrapper> spaceVehicle = new Map<String, ParkingSpotWrapper>();
            List<Lot_Section__c> lots = new List<Lot_Section__c>([SELECT Id, Name, Number_Of_Spaces__c FROM Lot_Section__c]);
            List<Parking_Space__c> parkingSpaces = new List<Parking_Space__c>([SELECT Id, Name, Space_Filled__c FROM Parking_Space__c WHERE Space_Filled__c = false]);
            List<Vehicle__c> vehicles = new List<Vehicle__c>([SELECT Id, Name, Parking_Space__c, Color__c, Year_Str__c, Price__c, Vehicle_Full_Name__c FROM Vehicle__c WHERE Parking_Space__c != 'Auto']);
            //Initialize the map
            for(Vehicle__c vehic: vehicles){
                spaceVehicle.put(vehic.Parking_Space__c, new ParkingSpotWrapper(vehic.Parking_Space__c, vehic));
            }
            for(Parking_Space__c ps: parkingSpaces){
                spaceVehicle.put(ps.Name, new ParkingSpotWrapper(ps.Name, null));
            }
            for(Lot_Section__c lot: lots){
                List<ParkingSpotWrapper> temp = new List<ParkingSpotWrapper>();
                for(Integer x=1; x<=lot.Number_of_Spaces__c; x++){
                    temp.add(spaceVehicle.get((lot.Name + String.valueOf(x))));
                }
                results.put(lot.Name, temp);
            }
            if(results.isEmpty()){
                throw new ListException('Parking Lot not');
            }
            return results;
            //fill the map with values from vehicle
            //fill in nulls 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static ParkingLotWrapper parkingLotLandingPage(){
        Parking_Lot__c dealership =[SELECT ID, Name, Number_Of_Lots__c, Percent_Full__c FROM Parking_Lot__c LIMIT 1];
        return new ParkingLotWrapper(dealership);
    }

    @AuraEnabled
    public static List<LotSectionWrapper> lotSectionsPage(){
        List<Lot_Section__c> lots = new List<Lot_Section__c>([SELECT Name, Spaces_Full__c FROM Lot_Section__c]);
        List<LotSectionWrapper> lotWrappers = new List<LotSectionWrapper>();
        for(Lot_Section__c current: lots){
            lotWrappers.add(new LotSectionWrapper(current));
        }
        return lotWrappers;
    }


    global class ParkingSpotWrapper{
        @AuraEnabled public String vehicleName;
        @AuraEnabled public String vehicleId;
        @AuraEnabled public String vehicleColor;
        @AuraEnabled public String vehiclePrice;
        @AuraEnabled public String vehicleYear;
        @AuraEnabled public Boolean isVacant;
        @AuraEnabled public String name;
        @AuraEnabled public String cssString;
        public ParkingSpotWrapper(String name, Vehicle__c vehicle){
            this.name = name;
            if(vehicle == null){
                this.isVacant = true;
                this.cssString = '';
            }else{
                this.isVacant = false;
                this.cssString = Constants.COLOR_HEX_CODES.get(vehicle.Color__c);
                if(vehicle.Vehicle_Full_Name__c.countMatches(' ') == 3){
                    String[] temp = (vehicle.Vehicle_Full_Name__c).split(' ');
                    this.vehicleName = temp[0] + ' ' +  temp[1] + '\n' + temp[2] + ' ' + temp[3];
                }   
                else{
                    this.vehicleName = vehicle.Vehicle_Full_Name__c;
                }
                this.vehiclePrice = String.valueOf(vehicle.Price__c);
                this.vehicleYear = vehicle.Year_Str__c;
                //String[] temp = (vehicle.Name).split('-');
                //this.vehicleId = temp[0]+'-' +temp[1];
                this.vehicleId = vehicle.Id;
                this.vehicleColor = vehicle.Color__c;
            }
            
        }
    }

    global class ParkingLotWrapper{
        @AuraEnabled public String dealershipName;
        @AuraEnabled public String percentFull;
        @AuraEnabled public String numberOfLots;
        @AuraEnabled public String nextOpenSpot;
        public ParkingLotWrapper(Parking_Lot__c p){
            this.dealershipName = p.Name;
            this.nextOpenSpot = [SELECT ID, Name, Lot_Section__c, Space_Filled__c FROM Parking_Space__c WHERE Space_Filled__c=false ORDER BY Lot_Section__c,Name ASC LIMIT 1].Name; 
            this.percentFull = String.valueOf(p.Percent_Full__c/100);
            this.numberOfLots = String.valueOf(p.Number_of_Lots__c);
        }
    }
    global class LotSectionWrapper{
        @AuraEnabled public String name;
        @AuraEnabled public Boolean isFull;
        public LotSectionWrapper(Lot_Section__c lot){
            this.name = lot.Name;
            this.isFull = lot.Spaces_Full__c;
        }
    }
}