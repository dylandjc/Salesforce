/**
    @author: Dan Thoreson
    @date: 03-Aug-2022
    @description: Class for initializing data on org setup or refresh.
    @test class: DataInitializerTest
**/
public class DataInitializer {

    public static final Integer NUMBER_OF_VEHICLES = 100;

    List<Make__c> makesToInsert;
    List<Model__c> modelsToInsert;
    List<Vehicle__c> vehiclesToInsert;

    /**
        @author: Dylan Chorley
        @date: 13-Sep-2022
        @description: Updated to include initialization of a parking lot 
        @param: none
        @return: none but data should be backfilled
    **/
    public void initData() {
        List<Parking_Space__c> ps = buildParkingLot();
        createMakes();
        createModels();
        createInStockVehicles(ps);
    }

    /**
        @author: Dan Thoreson
        @date: 13-Sep-2022
        @description: Creates a list of makes from the map of makes in the constants class
        @param: none
        @return: none
    **/
    private void createMakes() {
        makesToInsert = new List<Make__c>();

        for(String makeName : Constants.ALL_MAKES) {
            Make__c thisMake = new Make__c();
            thisMake.Name = makeName;
            thisMake.Country_of_Origin__c = Constants.COUNTRIES_FOR_MAKES.get(makeName);
            makesToInsert.add(thisMake);
        }

        Database.insert(makesToInsert, false);
    }

    /**
        @author: Dan Thoreson
        @date: 13-Sep-2022
        @description: Creates and inserts list of models based on models by makes constant map
        @param: none
        @return: none
    **/
    private void createModels() {
        modelsToInsert = new List<Model__c>();

        Map<String, ModelWrapper> modelDetails = getModelDetails();

        for(Make__c thisMake : makesToInsert) {
            for(String modelName : Constants.MODELS_BY_MAKES.get(thisMake.Name)) {
                Model__c thisModel = new Model__c();
                thisModel.Name = modelName;
                thisModel.Vehicle_Make__c = thisMake.Id;
                thisModel.In_Production__c = true;
                thisModel.Vehicle_Type__c = modelDetails.get(modelName)?.type;
                modelsToInsert.add(thisModel);
            }
        }

        Database.insert(modelsToInsert, false);
    }
    /**
        @author: Dylan Chorley
        @date: 13-Sep-2022
        @description: Builds a list of 100 vehicles and inserts them 
        @param: List of parking spaces to automatically fill all vehicles in at once instead of running through triggers
        @return: none
    **/
    private void createInStockVehicles(List<Parking_Space__c> ps) {
        //go through list of vehicles and add to parking spots 
        vehiclesToInsert = new List<Vehicle__c>();     
        
        List<Id> modelIds = getModelIds();
     
        for(Integer i = 0; i < NUMBER_OF_VEHICLES; i++) {
            // Randomize the creation of in stock models from the different makes
            Vehicle__c newVehicle = new Vehicle__c();
            newVehicle.Model__c = (Id) RandomizationUtils.getRandomElementFromList(modelIds);
            newVehicle.VIN_Number__c = generateVehicleIdentificationNumber();
            newVehicle.Purchase_Date__c = Date.today();
            newVehicle.Status__c = Constants.VEHICLE_STATUSES.IN_STOCK;
            newVehicle.Purchase_Price__c = 10000;
            newVehicle.Price__c = 15000;
            //newVehicle.Parking_Space__c = ps[i].Name;
            newVehicle.Color__c = 'Blue';

            Boolean isNew = RandomizationUtils.getRandomBoolean();
            Integer randomMileage;

            if(isNew) {
                newVehicle.Year__c = 2023;
                newVehicle.Pre_Owned__c = 'New';
                randomMileage = Integer.valueof((Math.random() * 1000));
            } else {
                newVehicle.Year__c = (Integer) RandomizationUtils.getRandomElementFromList(new List<Integer>{2022, 2021, 2019, 2018, 2017});
                newVehicle.Pre_Owned__c = 'Pre-Owned';
                randomMileage = Integer.valueof((Math.random() * 100000));
            }

            newVehicle.Mileage__c = randomMileage;            

            vehiclesToInsert.add(newVehicle);
        }
        // Insert Vehicle__c records
        Database.insert(vehiclesToInsert);

    }

    /**
        @author: Dan Thoreson
        @date: 13-Sep-2022
        @description: Generates a vehicle identification number randomly
        @param: none
        @return: A String of the randomly generated vin number
    **/
    private static String generateVehicleIdentificationNumber() {
        return RandomizationUtils.generateRandomString(Constants.VIN_LENGTH);
    }

    /**
        @author: Dan Thoreson
        @date: 13-Sep-2022
        @description: Gets the ids of the models and returns them as a list of ids
        @param: none
        @return: list of ids for the model ids
    **/
    private List<Id> getModelIds() {
        List<Id> modelIds = new List<Id>();

        for(Model__c thisModel : modelsToInsert) {
            modelIds.add(thisModel.Id);
        }

        return modelIds;
    }

    /**
        @author: Dan Thoreson
        @date: 13-Sep-2022
        @description: Gets the details of the model in form of wrapper that collects json
        @param: none
        @return: Map of string and wrapper where string is name deserialized from json and wrapper is the model info
    **/
    private Map<String, ModelWrapper> getModelDetails() {
        Map<String, ModelWrapper> modelsByName = new Map<String, ModelWrapper>();

        String modelJson = getModelJson();

        ModelJsonWrapper modelInfo = (ModelJsonWrapper) JSON.deserialize(modelJson, ModelJsonWrapper.class);

        for(ModelWrapper thisObj : modelInfo.vehicles) {
            modelsByName.put(thisObj.name, thisObj);
        }

        return modelsByName;
    }

    /**
        @author: Dan Thoreson
        @date: 13-Sep-2022
        @description: Gets the body of the jsonfile stored in static resource as a string
        @param: none
        @return: String form of the json body
    **/
    private String getModelJson() {
        StaticResource modelJsonFile = [SELECT Body FROM StaticResource WHERE Name = 'vehicles']; 
        return modelJsonFile.Body.toString();
    }
    /**
        @author: Dylan Chorley
        @date: 13-Sep-2022
        @description: Builds parking lot, lot sections, and parking spaces
        @param: none
        @return: List of all parking spaces to be filled by vehicles
    **/
    private static List<Parking_Space__c> buildParkingLot(){
        //for each lot in map fill out parking spaces 
        //get list of parking spaces returned

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
        Database.insert(parkingLots, false);

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
        Database.insert(parkingSpaces, false);
        return parkingSpaces;
    }

    /**
        @author: Dan Thoreson
        @date: 13-Sep-2022
        @group: wrapper class?
        @description: Breaks down json into list of vehicles with their name and type
        @test class: unknown 
    **/
    public class ModelJsonWrapper {
        public List<ModelWrapper> vehicles;
    }

    public class ModelWrapper {
        public String name;
        public String type;
    }
}