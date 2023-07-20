/**
    @author: Dan Thoreson
    @date: 19-Aug-2022
    @description: Test class for data setup class called DataInitializer
**/
@IsTest
private class DataInitializerTest {

    /**
        @author: Dylan Chorley and Dan Thoreson
        @date: 13-Sep-2022
        @description: extensive testing of DataInitializer especially vehicles and parking lot
        @param: none
        @return: assert statements
    **/
    @IsTest
    static void testInitData() {
        Test.startTest();
            new DataInitializer().initData();
        Test.stopTest();

        System.assertEquals(getNumberOfModels(), [SELECT COUNT() FROM Model__c], 'The number of models should be the same');
        System.assertEquals(Constants.ALL_MAKES.size(), [SELECT COUNT() FROM Make__c], 'There should be the same amount of makes');
        System.assertEquals(1, [SELECT COUNT() FROM Parking_Lot__c], 'There should just be one parking lot currently initialized and inserted');
        System.assertEquals('A1', [SELECT Name FROM Parking_Space__c ORDER BY Name ASC LIMIT 1].Name, 'There should be 155 spaces in the parking lot as a whole');
        System.assertEquals(DataInitializer.NUMBER_OF_VEHICLES, [SELECT COUNT() FROM Vehicle__c], 'There should be 100 vehicles');
        
        System.assertEquals(1, [SELECT COUNT() FROM Vehicle__c WHERE Parking_Space__c=:'A1'], 'A1 does not exist anymore');
    }

    /**
        @author: Dan Thoreson
        @date: 13-Sep-2022
        @description: Testing for json breakdown and collection of total models
        @param: none
        @return: number of models used in other test class
    **/
    private static Integer getNumberOfModels() {
        Integer totalModels = 0;

        for(String thisMake : Constants.MODELS_BY_MAKES.keySet()) {
            totalModels += Constants.MODELS_BY_MAKES.get(thisMake).size();
        }

        return totalModels;
    }
}