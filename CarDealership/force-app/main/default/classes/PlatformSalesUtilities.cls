/**
    @author: Dylan Chorley
    @date: 27-Sep-2022
    @group: Platform Cache
    @description: Platform Cache utility methods for accessing data and refreshing 
    @test class: PlatformSalesUtilitiesTest
**/
public with sharing class PlatformSalesUtilities {
        // second assumption: Someone looking to access the cached data knows the make AND model even if just looking for model data
        // We do not consider the situation where the name of vehicle make/model is the same as sales rep name
        /**
            @author: Dylan Chorley
            @date: 27-Sep-2022
            @description: Gets the sales rep cache data 
            @param: String for the name of the sales rep 
            @return: Map of a map with the bigger map key being the name of the sales rep and the smaller map coinciding with following form 
            ////Map<Sales Rep, <Number of Sales, Value >
                               <Profits Generated, Value>
        **/
        public static Map<String, Integer> getSaleRepCache(String salesRepName){
            //if value trying to be accessed doesnt exist: refresh and put in cache 
            //Build key
            List<Opportunity> closedWonSales = new List<Opportunity>([SELECT Id, Vehicle__c, Sales_Rep__c, Total_Due__c, StageName FROM Opportunity WHERE StageName =: Constants.STAGE_NAMES.CLOSED_WON]);
        
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.SaleSplit');
            String kewy = salesRepName.deleteWhitespace();
            if(orgPart.contains(kewy)){
                return (Map<String, Integer>) orgPart.get(kewy);
            }
            else{
                System.debug(closedWonSales.size());
                if(Constants.SALES_REPS.contains(salesRepName) && closedWonSales.size() > 0){
                    //check through opportunity\
                    refreshSalesRepCache(closedWonSales);
                    //System.debug(Cache.Org.getPartition('SaleSplit').getName()); // local.SaleSplit
                    return (Map<String, Integer>) orgPart.get(kewy);
                }
                else{
                    Logger.insertErrorLog('Line 35', 'This is not the name of a sales rep'+ salesRepName, null);
                    return null;
                }
            }
        }

        /**
            @author: Dylan Chorley
            @date: 27-Sep-2022
            @description: Gets the particular vehicle make or model aggregate data from the cache
            @param: String make or model name to search by 
            @return: The data from cache
        **/
        public static Map<String, Integer> getVehicleCache(String makeOrModel){
            List<Opportunity> closedWonSales = new List<Opportunity>([SELECT Id, Vehicle__c, Sales_Rep__c, Total_Due__c, StageName FROM Opportunity WHERE StageName =: Constants.STAGE_NAMES.CLOSED_WON]);
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.VehicleSplit');
            if(orgPart.contains(makeOrModel.deleteWhitespace())){
                return (Map<String, Integer>) Cache.Org.get(makeOrModel.deleteWhitespace());
            }
            else{
                //check through opportunity\
                List<Make__c> mk = new List<Make__c>([SELECT Id FROM Make__c WHERE Name=:makeOrModel]);
                List<Model__c> ml = new List<Model__c>([SELECT Id FROM Model__c WHERE Name=:makeOrModel]);
                if(closedWonSales.size() > 0 && (mk != null || ml.size() != null)){
                    refreshVehicleSalesCache(closedWonSales);
                    return (Map<String, Integer>) Cache.Org.get(makeOrModel.deleteWhitespace());
                }
                else{
                    Logger.insertErrorLog('Line 66', 'This is not the name of a make or model'+ makeOrModel, null);
                    return null;
                }
            }
        }
        /**
            @author: Dylan Chorley
            @date: 27-Sep-2022
            @description: Refreshes the vehicle sales cache 
            @param: none 
            @return: none
        **/
        public static void refreshVehicleSalesCache(List<Opportunity> closedWonSales){
            Cache.OrgPartition orgPart2 = Cache.Org.getPartition('VehicleSplit');
            List<Id> makeList = new List<Id>();
            List<Id> modelList = new List<Id>();
            List<Id> vehicles = new List<Id>();
            for(Opportunity opp: closedWonSales){
                vehicles.add(opp.Vehicle__c);
            }
            System.debug(vehicles);
            System.debug(closedWonSales);
            List<AggregateResult> vehsModels = new List<AggregateResult>([SELECT COUNT(Id)ct, SUM(Price__c)pr, SUM(Purchase_Price__c)pp, Model__r.Name, COUNT(Status__c) FROM Vehicle__c WHERE ID IN:vehicles AND Status__c=:Constants.VEHICLE_STATUSES.SOLD GROUP BY Model__r.Name]); 
            // Refresh by Models
            for(AggregateResult arg: vehsModels){
                Map<String, Integer> temp = new Map<String, Integer>();
                temp.put('NumberOfSales', Integer.valueOf(arg.get('ct')));
                temp.put('GrossProfits', Integer.valueOf(arg.get('pr'))-Integer.valueOf(arg.get('pp')));
                System.debug(temp);
                System.debug(arg);
                orgPart2.put(String.valueOf(arg.get('Name')).deleteWhitespace(), temp, 28800);
            }
            List<AggregateResult> vehsMakes = new List<AggregateResult>([SELECT COUNT(ID)ct, SUM(Price__c)pr, SUM(Purchase_Price__c)pp, Model__r.Vehicle_Make__r.Name, COUNT(Status__c) FROM Vehicle__c WHERE ID IN:vehicles AND Status__c=:Constants.VEHICLE_STATUSES.SOLD GROUP BY Model__r.Vehicle_Make__r.Name]); 
            for(AggregateResult arg: vehsMakes){
                Map<String, Integer> temp = new Map<String, Integer>();
                temp.put('NumberOfSales', Integer.valueOf(arg.get('ct')));
                temp.put('GrossProfits', Integer.valueOf(arg.get('pr'))-Integer.valueOf(arg.get('pp')));
                orgPart2.put(String.valueOf(arg.get('Name')).deleteWhitespace(), temp, 28800);
            }
            System.debug(Cache.Org.getKeys());
        
        }
        /**
            @author: Dylan Chorley
            @date: 27-Sep-2022
            @description: refreshes the sales rep cache
            @param: none
            @return: none
        **/
        //put in all at the same time
        //If we recalculate through opportunity if not in cache should I place in cache or should cache be placed all at once in 8 hour intervals by running refresh function
        public static void refreshSalesRepCache(List<Opportunity> closedWonSales){
            //list of all sales rep names 
            //get map of opportunities from sales rep list and stage is closed
            //get vehicle map using the vehicleIds from the list of opportunities 
            Cache.OrgPartition orgPart1 = Cache.Org.getPartition('local.SaleSplit');
            Map<String,Map<String,Integer>> results = new Map<String,Map<String,Integer>>();
           
            Map<String, List<Id>> vehics = new Map<String, List<Id>>();
            for(Opportunity opp: closedWonSales){
                if(vehics.containsKey(opp.Sales_Rep__c)){
                    vehics.get(opp.Sales_Rep__c).add(opp.Vehicle__c); 
                }
                else{
                    List<Id> lister = new List<Id>();
                    lister.add(opp.Vehicle__c);
                    vehics.put(opp.Sales_Rep__c, lister);
                }
            }
            System.debug(closedWonSales.size());
            for(String sr: vehics.keySet()){
                List<Id> ids = vehics.get(sr);
                Map<String, Integer> temp = new Map<String, Integer>();
                List<AggregateResult> count = new List<AggregateResult>([SELECT SUM(Purchase_Price__c)pp FROM Vehicle__c WHERE Id IN:ids]);
                List<AggregateResult> count2 = new List<AggregateResult>([SELECT SUM(Price__c)pr FROM Vehicle__c WHERE Id IN:ids]);
                temp.put('NumberOfSales', ids.size());
                temp.put('GrossProfits', Integer.valueOf(count2[0].get('pr'))-Integer.valueOf(count[0].get('pp')));
                results.put(sr, temp);
                System.debug(results);
                System.debug(temp);
                orgPart1.put(sr.deleteWhitespace(), temp, 28800);
            }
            System.debug(orgPart1.getKeys());
            System.debug(Cache.Org.getKeys());
        }
        // {Str salesRepName: {NS: V, GP:V}}

        // amount of time in seconds to keep cached value : 28800 ~ 8 hours 
    }