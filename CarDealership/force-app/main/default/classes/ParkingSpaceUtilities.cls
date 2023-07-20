/**
    @author: Dylan Chorley
    @date: 19-Sep-2022
    @group: Parking Space helper class
    @description: Utilities class with all the possible changes for a parking space
    @test class: OpportunityTriggerHandlerTest
**/
public with sharing class ParkingSpaceUtilities {

    public static final Parking_Lot__c DEALERSHIP {get {
        if(DEALERSHIP == null) {
            List<Parking_Lot__c> lot = [SELECT ID FROM Parking_Lot__c ORDER BY Name ASC LIMIT 1];
            DEALERSHIP = (!lot.isEmpty()) ? lot[0] : null;
        }
        return DEALERSHIP;
    } set;}
        

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Remove vehicles from lot and clear up the parking space
        @param: The dealership as parking lot object and the parking place the vehicle is in as a string
        @return: none only updates
    **/
    public static void removeFromLot(Parking_Lot__c dealership, List<String> parkingPlace){
        //access the parking lot section based on index one of the string for position 
        //get index from list of 
            List<String> lots = new List<String>();
            List<Parking_Space__c> ps = [SELECT Id,Space_Filled__c, Name FROM Parking_Space__c WHERE Name IN:parkingPlace];
            for(Parking_Space__c pz:ps){
                pz.Space_Filled__c = false;
                if(!lots.contains(pz.Name.substring(0,1))){
                    lots.add(pz.Name.substring(0,1));
                }
            }
            update ps;
            List<Lot_Section__c> pl = [SELECT Name, Spaces_Full__c, Parking_Lot__c FROM Lot_Section__c WHERE Name IN:lots AND Parking_Lot__c=:dealership.Id AND Spaces_Full__c=true];
            findPercentFull(-1*parkingPlace.size());
            for(Lot_Section__c lot: pl){
                lot.Spaces_Full__c = false;
            }
            update pl;
        }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Returns first available open space in alphabetic and numeric order ascending
        @param: The parking lot object known as a dealership 
        @return: String value for the parking space location the vehicle is being placed in 
    **/
    public static List<Vehicle__c> placeInLot(Parking_Lot__c dealership, List<Vehicle__c> vehsPlace){
        Integer spacesNeeded = vehsPlace.size();
        List<String> openSpaces = new List<String>();
        List<Lot_Section__c> allLotsUpdated = new List<Lot_Section__c>();
        List<Parking_Space__c> allSpacesUpdated = new List<Parking_Space__c>();
        List<Lot_Section__c> lotChange = new List<Lot_Section__c>();
        List<Lot_Section__c> lots = new List<Lot_Section__c>([SELECT ID, Name, Number_of_Spaces__c, Spaces_Full__c, Parking_Lot__c FROM Lot_Section__c WHERE Parking_Lot__c=:dealership.Id AND Spaces_Full__c=false ORDER BY Name ASC]);
        for(Lot_Section__c current: lots){
            List<Parking_Space__c> ps = new List<Parking_Space__c>([SELECT ID, Name, Lot_Section__c, Space_Filled__c FROM Parking_Space__c WHERE Lot_Section__c=:current.Id AND Space_Filled__c=false ORDER BY Name ASC]);
            for(Parking_Space__c open: ps){
                openSpaces.add(open.Name);
                open.Space_Filled__c = true;
                allSpacesUpdated.add(open);
                if(openSpaces.size() == spacesNeeded){
                    break;
                }
            }
            if(openSpaces.size() == spacesNeeded){
                if(ps.isEmpty() || ps.size()==1){
                    current.Spaces_Full__c = true;
                    allLotsUpdated.add(current);
                }
                break;
            }
            else{
                current.Spaces_Full__c = true;
                allLotsUpdated.add(current);
            }
        }
        update allSpacesUpdated;
        if(!allLotsUpdated.isEmpty()){
            update allLotsUpdated;
        }
        Integer space = 0;
        openSpaces.sort();

        for(Vehicle__c vech: vehsPlace){
            vech.Parking_Space__c = openSpaces[space];
            space = space + 1;
        }
        //update vehsPlace;
        findPercentFull(spacesNeeded);
        return vehsPlace;
    }


    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Updates the Percent Full field for the Parking Lot given list of newly updated parking spaces
        @param: List of parking spaces known as spacesUpdated
        @return: none updates lot 
    **/
    public static void findPercentFull(Integer addOrRemove){
        //not starting with dealership but instead list of spaces updated
        //migfht be from different parking lots so start by collecting the lot section
        //List of filter lot sections from the parking spaces: collect parking lot ids/dealership id
        //for each unique dealership in that list :
        Parking_Lot__c dealership = [SELECT Id,Percent_Full__c FROM Parking_Lot__c LIMIT 1];
        List<Parking_Lot__c> updatedDealerships = new List<Parking_Lot__c>();
        //way around this is grouping method --bring up with dan next meeting 
        
        if(dealership.Percent_Full__c != 0.00){
            Decimal temp = (Constants.DEALERSHIP_SIZE*dealership.Percent_Full__c)/100.0;
            dealership.Percent_Full__c = ((temp+AddorRemove)/Constants.DEALERSHIP_SIZE)*100.0;
            updatedDealerships.add(dealership);
        }
        else{
            List<Lot_Section__c> lots = new List<Lot_Section__c>([SELECT ID, Number_of_Spaces__c, Spaces_Full__c, Parking_Lot__c FROM Lot_Section__c WHERE Parking_Lot__c=:dealership.Id]);
            List<Lot_Section__c> notFull = new List<Lot_Section__c>();
            Integer totalCount = 0;
            Integer openSpace = 0;
            for(Lot_Section__c lot: lots){
                if(lot.Spaces_Full__c){
                    openSpace = openSpace + (Integer) lot.Number_of_Spaces__c;
                }
                else{
                    notFull.add(lot);
                }
            }
            Integer count = [SELECT Lot_Section__c, Space_Filled__c FROM Parking_Space__c WHERE Lot_Section__c IN: notFull AND Space_Filled__c=true].size();    
            Decimal temp = count+openSpace;
            dealership.Percent_Full__c = ((temp)/Constants.DEALERSHIP_SIZE)*100;
            updatedDealerships.add(dealership);
        }
        
        if(!updatedDealerships.isEmpty()){
            update updatedDealerships;
        }
    }
    /**
        @author: Dylan Chorley
        @date: 12-Sep-2022
        @description: Find dealership given the parking space 
        @param: List of parking spaces
        @return: The set of dealerships the parking spaces are apart of 
    
    public static Set<Parking_Lot__c> findDealership(List<Parking_Space__c> spaces){
        List<Id> lotList = new List<Id>();
        List<Id> returnDeal = new List<Id>();
        for(Parking_Space__c space:spaces){
            lotList.add(space.Lot_Section__c);
        }
        List<Lot_Section__c> dealerships = new List<Lot_Section__c>([SELECT Id,Parking_Lot__c FROM Lot_Section__c WHERE Id IN:lotList]);
        for(Lot_Section__c d:dealerships){
            returnDeal.add(d.Parking_Lot__c);
        }
        Set<Parking_Lot__c> lots = new Set<Parking_Lot__c>([SELECT Id FROM Parking_Lot__c WHERE Id IN:returnDeal]);
        return lots;
    }
    **/
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Filters vehicles to determine whether they should be added to lot or removed
        @param: List of vehicles
        @return: return vehicles that are now updated 
    **/
    public static List<Vehicle__c> handleVehicleList(List<Vehicle__c> vehics){
        List<Vehicle__c> vhPLace = new List<Vehicle__c>();
        List<String> vhInStock = new List<String>();
        List<Vehicle__c> finalizedData = new List<Vehicle__c>();
        for(Vehicle__c v: vehics){
            if(v.Status__c == Constants.VEHICLE_STATUSES.IN_STOCK && (v.Parking_Space__c == 'Auto' || v.Parking_Space__c == null)){
                //v.Parking_Space__c = placeInLot(Constants.DEALERSHIP);
                vhPlace.add(v);
                //v.Parking_Space__c = placeInLot(DEALERSHIP);
            }
            else{
                if(v.Status__c != Constants.VEHICLE_STATUSES.IN_STOCK && (v.Parking_Space__c != 'Auto' && v.Parking_Space__c != null)){
                    vhInStock.add(v.Parking_Space__c);
                    //removeFromLot(DEALERSHIP, v.Parking_Space__c);
                    v.Parking_Space__c = 'Auto';
                    finalizedData.add(v);
                }
                else{
                    if(v.Status__c != Constants.VEHICLE_STATUSES.IN_STOCK){
                        v.Parking_Space__c = 'Auto';
                        finalizedData.add(v);
                    }
                }
            }
        }
        if(!vhInStock.isEmpty()){
            removeFromLot(DEALERSHIP, vhInStock);
        }
        if(!vhPLace.isEmpty()){
            vhPlace = placeInLot(DEALERSHIP, vhPlace);
            finalizedData.addAll(vhPlace);
        }
        return finalizedData;
    }

    public static void deleteVehicleList(List<Vehicle__c> vehs){
        List<String> removeMe = new List<String>();
        for(Vehicle__c veh: vehs){
            removeMe.add(veh.Parking_Space__c);
        }
        removeFromLot(DEALERSHIP, removeMe);
    }
}