/**
    @author: Dan Thoreson
    @date: 19-Aug-2022
    @description: Test class for RandomizationUtils
**/
@IsTest
private class RandomizationUtilsTest {

    @IsTest
    static void testGetRandomBoolean() {
        Boolean result = RandomizationUtils.getRandomBoolean();
        System.assertNotEquals(result, null);
        System.assert(result == true || result == false);
    }

    @IsTest
    static void testGenerateRandomString() {
        final Integer STRING_SIZE = 17;
        String testVehicleNumber = RandomizationUtils.generateRandomString(STRING_SIZE);
        System.assertEquals(STRING_SIZE, testVehicleNumber.length());
        System.assert(testVehicleNumber.isAlphanumeric());
    }

    @IsTest
    static void testGetRandomElementFromList() {
        List<Integer> listOfInts = new List<Integer>{3, 33, 333, 3333, 33333};
        List<String> listOfStrings = new List<String>{'a', 'ab', 'abc', 'abcd', 'abcde'};

        Test.startTest();
            Integer resultInt = (Integer) RandomizationUtils.getRandomElementFromList(listOfInts);
            String resultString = (String) RandomizationUtils.getRandomElementFromList(listOfStrings);            
        Test.stopTest();

        System.assert(listOfInts.contains(resultInt));
        System.assert(listOfStrings.contains(resultString));
        System.assertNotEquals(null, resultInt);
        System.assertNotEquals(null, resultString);
    }
}