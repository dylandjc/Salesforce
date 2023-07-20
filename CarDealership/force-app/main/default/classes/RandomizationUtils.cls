/**
    @author: Dan Thoreson
    @date: 03-Aug-2022
    @description: Contains utility methods to generate random data
    @test class: RandomizationUtilsTest
**/
public class RandomizationUtils {

    public static String generateRandomString(Integer length) {
        String eligibleChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        
        String randomStr = '';
        
        while (randomStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), eligibleChars.length());
            randomStr += eligibleChars.substring(idx, idx+1);
        }

        return randomStr;
    }

    public static Object getRandomElementFromList(List<Object> elements) {
        Integer indexSizeOfList = elements.size() - 1;
        Integer randomIndex = Integer.valueOf(indexSizeOfList * Math.random());
        
        return elements[randomIndex];        
    }

    public static Boolean getRandomBoolean() {
        Integer randomNumber = Integer.valueof((Math.random() * 10));
        return Math.mod(randomNumber, 2) == 0;
    }
    /**
        @author: Dylan Chorley
        @date: 07-Sep-2022
        @description: Generates a random phone number of length 10
        @param: none
        @return: Returns phone number in string form
    **/
    public static String generateRandomPhone(){
        String randomStr = '';
        while (randomStr.length() <= 10) {
            Integer randomNumber = Integer.valueof((Math.random() * 9));
            randomStr += String.valueOf(randomNumber);
        }

        return randomStr;
    }

}