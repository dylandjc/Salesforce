/**
    @author: Dylan Chorley
    @date: 06-Oct-2022
    @group: Lightning Web Component BackEnd
    @description: Gets the top three performers in sales and amount for vehicle make model and sales rep
    @test class: TopPerformersTest
**/
global with sharing class TopPerformers {
    /**
        @author: Dylan Chorley
        @date: 06-Oct-2022
        @description: Gets the top three sales reps in the cache
        @param: is profit which is true for checking top three by profit and false for number of sales
        @return: List of wrapper class in decreasing order 
    **/
    @AuraEnabled
    public static List<TopSalesPerformersWrapper> getTopSalesReps(Boolean isProfit){
        try {
            List<TopSalesPerformersWrapper> topSales = new List<TopSalesPerformersWrapper>();
        //chefck partition 
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.SaleSplit');
            if(isProfit){
                //Looking at highest profit
                List<Integer> profits = new List<Integer>();
                Map<String, Integer> names = new Map<String, Integer>();
                if(orgPart.getNumKeys() == 0){
                    List<Opportunity> closedWonSales = new List<Opportunity>([SELECT Id, Vehicle__c, Sales_Rep__c, Total_Due__c, StageName FROM Opportunity WHERE StageName =: Constants.STAGE_NAMES.CLOSED_WON]);
                    PlatformSalesUtilities.refreshSalesRepCache(closedWonSales);
                }
                for(String keyName: orgPart.getKeys()){
                    Map<String, Integer> temp = PlatformSalesUtilities.getSaleRepCache(keyName);
                    profits.add(temp.get('GrossProfits'));
                    names.put(putWhiteSpaceBack(keyName), temp.get('GrossProfits'));
                }
                profits.sort();
                Map<String, Integer> completeSort =  sortByValue(names, profits);
                for(String name: completeSort.keySet()){
                    topSales.add(new TopSalesPerformersWrapper(name, null, completeSort.get(name)));
                }
                if(topSales.isEmpty()){
                    ListException excep = new ListException();
                    excep.setMessage(String.valueOf(orgPart.getNumKeys()));
                    throw excep;
                }
                return topSales;
            }
            else{
                List<Integer> sales = new List<Integer>();
                Map<String, Integer> names = new Map<String, Integer>();
                if(orgPart.getNumKeys() == 0){
                    List<Opportunity> closedWonSales = new List<Opportunity>([SELECT Id, Vehicle__c, Sales_Rep__c, Total_Due__c, StageName FROM Opportunity WHERE StageName =: Constants.STAGE_NAMES.CLOSED_WON]);
                    PlatformSalesUtilities.refreshSalesRepCache(closedWonSales);
                }
                for(String keyName: orgPart.getKeys()){
                    Map<String, Integer> temp = PlatformSalesUtilities.getSaleRepCache(keyName);
                    sales.add(temp.get('NumberOfSales'));
                    names.put(putWhiteSpaceBack(keyName), temp.get('NumberOfSales'));
                }
                sales.sort();
                Map<String, Integer> completeSort =  sortByValue(names, sales);
                for(String name: completeSort.keySet()){
                    topSales.add(new TopSalesPerformersWrapper(name, completeSort.get(name), null));
                }
                if(topSales.isEmpty()){
                    ListException excep = new ListException();
                    excep.setMessage(excep.getStackTraceString());
                    throw excep;
                }
                return topSales;
            }
        } catch (Exception e) {
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.SaleSplit');
            throw new AuraHandledException(String.valueOf(OrgPart.getKeys()));
        }
    }
    /**
        @author: Dylan Chorley
        @date: 06-Oct-2022
        @description: Gets top three vehicle performers for amount and total sales
        @param: isProfit true for checking profit false otherwise 
        @return: list of wrapper class in decreasinf order 
    **/
    @AuraEnabled
    public static List<TopVehiclePerformersWrapper> getTopVehicles(Boolean isProfit, Boolean isMake){
        try {
            List<TopVehiclePerformersWrapper> topSales = new List<TopVehiclePerformersWrapper>();
            //chefck partition 
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.VehicleSplit');
            if(isProfit){
                //Looking at highest profit
                List<Integer> profits = new List<Integer>();
                Map<String, Integer> names = new Map<String, Integer>();
                if(orgPart.getNumKeys() == 0){
                    List<Opportunity> closedWonSales = new List<Opportunity>([SELECT Id, Vehicle__c, Sales_Rep__c, Total_Due__c, StageName FROM Opportunity WHERE StageName =: Constants.STAGE_NAMES.CLOSED_WON]);
                    System.debug(closedWonSales.size());
                    PlatformSalesUtilities.refreshVehicleSalesCache(closedWonSales);
                }
                Set<String> makeOrModelKeys = getMakeOrModelKeys(orgPart.getKeys(), isMake);
                for(String keyName: makeOrModelKeys){
                    Map<String, Integer> temp = PlatformSalesUtilities.getVehicleCache(keyName);
                    profits.add(temp.get('GrossProfits'));
                    names.put(putWhiteSpaceBack(keyName), temp.get('GrossProfits'));
                }
                profits.sort();
                Map<String, Integer> completeSort =  sortByValue(names, profits);
                for(String name: completeSort.keySet()){
                    topSales.add(new TopVehiclePerformersWrapper(name, null, completeSort.get(name)));
                }
                if(topSales.isEmpty()){
                    ListException excep = new ListException();
                    excep.setMessage('Empty top sales');
                    throw excep;
                }
                return topSales;
            }
            else{
                List<Integer> sales = new List<Integer>();
                Map<String, Integer> names = new Map<String, Integer>();
                if(orgPart.getNumKeys() == 0){
                    List<Opportunity> closedWonSales = new List<Opportunity>([SELECT Id, Vehicle__c, Sales_Rep__c, Total_Due__c, StageName FROM Opportunity WHERE StageName =: Constants.STAGE_NAMES.CLOSED_WON]);
                    PlatformSalesUtilities.refreshVehicleSalesCache(closedWonSales);
                }
                Set<String> makeOrModelKeys = getMakeOrModelKeys(orgPart.getKeys(), isMake);
                for(String keyName: makeOrModelKeys){
                    Map<String, Integer> temp = PlatformSalesUtilities.getVehicleCache(keyName);
                    sales.add(temp.get('NumberOfSales'));
                    names.put(putWhiteSpaceBack(keyName), temp.get('NumberOfSales'));
                }
                sales.sort();
                Map<String, Integer> completeSort =  sortByValue(names, sales);
                for(String name: completeSort.keySet()){
                    topSales.add(new TopVehiclePerformersWrapper(name, completeSort.get(name), null));
                }
                if(topSales.isEmpty()){
                    ListException excep = new ListException();
                    excep.setMessage(String.valueOf(excep.getLineNumber()));
                    throw excep;
                }
                return topSales;
            }
        } catch (Exception e) {
            throw new AuraHandledException(String.valueOf(e.getLineNumber()));
        }
    }
    global class TopSalesPerformersWrapper{
        @AuraEnabled public Integer sales;
        @AuraEnabled public Integer profits;
        @AuraEnabled public String name;
        public TopSalesPerformersWrapper(String salesRep, Integer sales, Integer profits){
            this.name = salesRep;
            this.sales = sales;
            this.profits = profits;
        }
    }
    global class TopVehiclePerformersWrapper{
        @AuraEnabled public Integer sales;
        @AuraEnabled public Integer profits;
        @AuraEnabled public String name;
        public  TopVehiclePerformersWrapper(String make, Integer sales, Integer profits){
            this.name = make;
            this.sales = sales;
            this.profits = profits;
        }
    }
    /**
        @author: Dylan Chorley
        @date: 06-Oct-2022
        @description: Utility function to add whitespace back where capitalization occurs in a name
        @param: String name from keys to clean up
        @return: string oif the key converted to readable format
    **/
    public static String putWhiteSpaceBack(String name){
        Integer x = 0;
        if(name == null || name.length() == 0){
            return null;
        }
        String newString = name.substring(0,1);
        for(x=1;x<name.length();x++){
            String temp = name.substring(x, x+1);
            if(temp.isAllUpperCase()){
                newString = newString + ' ' + name.substring(x, x+1);
            }
            else{
                newString = newString + name.substring(x, x+1);
            }
        }
        return newString;
    }

    public static Set<String> getMakeOrModelKeys(Set<String> allKeys, Boolean isMake){
        Set<String> results = new Set<String>();
        Set<String> returnThis = new Set<String>();
        for(String current:allKeys){
            results.add(putWhiteSpaceBack(current));
        }
        if(isMake){
            List<Model__c> soldVehs = new List<Model__c>([SELECT Vehicle_Make__r.Name FROM Model__c WHERE Vehicle_Make__r.Name=:results]);
            for(Model__c current: soldVehs){
                returnThis.add(current.Vehicle_Make__r.Name.deleteWhitespace());
            }
        }else{
            List<Model__c> soldVehs = new List<Model__c>([SELECT Name FROM Model__c WHERE Name=:results]);
            for(Model__c current: soldVehs){
                returnThis.add(current.Name.deleteWhitespace());
            }
        }
        return returnThis;
    }
    /**
        @author: Dylan Chorley
        @date: 06-Oct-2022
        @description: Sort the map given the three top values list of integers and return only the top three
        @param: names map to be sorted and the list of already sorted values 
        @return: new map
    **/
    public static Map<String,Integer> sortByValue(Map<String,Integer> toSort, List<Integer> sorted){
        Map<String,Integer> completedSort = new Map<String, Integer>();
        Integer index = 0;
        for(index=sorted.size()-1; index>-1; index--){
            if(completedSort.size()<3){
                for(String name: toSort.keySet()){
                    if(toSort.get(name) == sorted[index]){
                        completedSort.put(name, toSort.get(name));
                        toSort.remove(name); 
                        break;
                    }
                }
            }
        }
        return completedSort;
    }
}