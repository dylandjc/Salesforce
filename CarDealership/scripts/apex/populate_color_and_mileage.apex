List<Vehicle__c> vehicles = new List<Vehicle__c>([SELECT Id, Color__c, Mileage__c, Pre_Owned__c FROM Vehicle__c]);

for(Vehicle__c v : vehicles) {
    v.Color__c = (String) RandomizationUtils.getRandomElementFromList(Constants.ALL_COLORS);

    Integer randomNewMileage = Integer.valueof((Math.random() * 1000));
    Integer randomUsedMileage = Integer.valueof((Math.random() * 100000));

    v.Mileage__c = (v.Pre_Owned__c == 'New') ? randomNewMileage : randomUsedMileage;
}

update vehicles;