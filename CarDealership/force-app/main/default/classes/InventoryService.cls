@RestResource(urlMapping='/autos/v1/search-inventory/*')
global class InventoryService {


    //should there be a do post wrapper for each item to filter by?
    //
    /** 
    @HttpGet
    global static ResponseWrapper getCadillacs() {
        List<AutoWrapper> returnList = new List<AutoWrapper>();

        List<Vehicle__c> cadillacs = new List<Vehicle__c>([SELECT Name, Model__r.Name, Status__c, Vehicle_Make__c, Year__c, VIN_Number__c, 
                                                                    Vehicle_Full_Name__c, Color__c, Mileage__c
                                                            FROM Vehicle__c
                                                            WHERE Vehicle_Make__c = 'Cadillac']);

        for(Vehicle__c vehicle : cadillacs) {
            returnList.add(new AutoWrapper(vehicle));
        }

        return new AutoResponseWrapper(JSON.serialize(returnList));
    }
    */

    // It is pretty useful to name these methods like "doPost", "doGet", etc. since you can only have one method per HTTP method per class
    @HttpPost
    global static ResponseWrapper doPost() {
        String payload = RestContext.request.requestBody.toString();
        VehicleSearchParams params;

        try {
            payload = payload.replaceAll('\n',' ').replaceAll('\r',' '); // Remove tabs and line breaks
            params = (VehicleSearchParams) JSON.deserialize(payload, VehicleSearchParams.class);
        } catch(JSONException ex) {
            Logger.insertErrorLog(ex, null);
            return null; // TODO - Malformed request
        }
        //update to dynamic style query 
        String query = 'SELECT Name, Model__r.Name, Model__r.Vehicle_Type__c, Status__c, Model__r.Vehicle_Make__r.Name, Year__c, VIN_Number__c, Vehicle_Full_Name__c, Color__c, Mileage__c FROM Vehicle__c WHERE Status__c =' +'\'' + Constants.VEHICLE_STATUSES.IN_STOCK +'\'';
        Boolean checkForOne = false;
        if(params.maxYear != null){
            query = query + ' AND Year__c <=' + params.maxYear;
            checkForOne = True;
        }
        if(params.minYear != null){
            query = query + ' AND Year__c >=' + params.minYear;
            checkForOne = True;
        }
        if(params.make != null){
            query = query + ' AND Model__r.Vehicle_Make__r.Name =' +'\''+ params.make +'\'';
            checkForOne = True;
        }
        if(params.color != null){
            query = query + ' AND Color__c =' +'\''+ params.color +'\'';
            checkForOne = True;
        }
        if(params.type != null){
            query = query + ' AND Model__r.Vehicle_Type__c =' +'\''+ params.type +'\'';
            checkForOne = True;
        }
        if(checkForOne == false){
            //call to error log 
            AutoResponseErrorWrapper errorRes = new AutoResponseErrorWrapper();
            errorRes.res.statusCode = 422;
            Logger.insertErrorLog('LINE 70 INVENTORYSERVICE.CLS', 'Need to include at least one parameter', null);
            return errorRes;
        }
        params.setYears();
        List<Vehicle__c> vehicles = Database.query(query);
        List<AutoWrapper> autoWrappers = new List<AutoWrapper>();
        // add an additional header xapi-key
        for(Vehicle__c vehicle : vehicles) {
            autoWrappers.add(new AutoWrapper(vehicle));
        }        
        autoWrappers.sort();
        return new AutoResponseWrapper(JSON.serialize(autoWrappers));
    }

    // Return object for the APIs
    public class AutoWrapper implements Comparable{
        public String make;
        public String model;
        public String fullName;
        public String color;
        public String condition;
        public Integer year;

        public AutoWrapper(Vehicle__c vehicle) {
            this.make = vehicle.Model__r.Vehicle_Make__r.Name;
            this.model = vehicle.Model__r.Name;
            this.fullName = vehicle.Vehicle_Full_Name__c;
            this.color = vehicle.Color__c;
            this.condition = vehicle.Status__c;
            this.year = vehicle.Year__c != null ? Integer.valueOf(vehicle.Year__c) : null;
        }

        public Integer compareTo(Object aus){
            AutoWrapper au = (AutoWrapper) aus;
            if(this.make < au.make){
                return 1;
            }
            else{
                if(this.make == au.make){
                    if(this.year<au.year){
                        return -1;
                    }
                    else{
                        return 1;
                    }
                }
                else{
                    return -1;
                }
            }
        }

    }

    // Parameters for the POST request
    public class VehicleSearchParams {
        String make;
        Integer minYear;
        Integer maxYear;
        String color;
        String type;

        // Defaults the optional years values
        public void setYears() {
            if(minYear == null) {
                minYear = 1900; // A workaround but will make the query cleaner so we don't have to handle nulls
            }
            
            if(maxYear == null) {
                maxYear = System.today().addYears(5).year();
            }
        }
    }

    // Abstract Response type
    global abstract class ResponseWrapper {
        global Boolean success;
    }
    
    // Concrete Response instance
    global class AutoResponseWrapper extends ResponseWrapper {
        public List<AutoWrapper> vehicles;
        public System.RestResponse res;

        global AutoResponseWrapper(String vehiclesStr) {
            this.vehicles = (List<AutoWrapper>) JSON.deserialize(vehiclesStr, List<AutoWrapper>.class);
            this.success = true;
        }
    }

    global class AutoResponseErrorWrapper extends ResponseWrapper {
        public List<AutoWrapper> vehicles;
        public System.RestResponse res;

        global AutoResponseErrorWrapper() {
            this.res = new System.RestResponse();
            this.vehicles = null;
            this.success = false;
        }
    }    
}