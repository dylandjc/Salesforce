/**
    @author: Dan Thoreson
    @date: 13-Aug-2022
    @description: Test class for Logger
**/
@IsTest
private class LoggerTest {

    private static final String TEST_ERROR_MESSAGE = 'Test Exception';

    @IsTest
    static void testErrorLogCreationFromException() {
        try {
            throw new TestLoggerException(TEST_ERROR_MESSAGE);
        } catch(TestLoggerException tle) {
            Logger.insertErrorLog(tle, UserInfo.getUserId());
        }

        // Verify the record was created to expectation by querying with filters.  
        System.assertEquals(1, [SELECT COUNT() FROM Error_Log__c WHERE Record_Id__c = :UserInfo.getUserId()],
                                'One Error Log should have been created');
    }

    @IsTest 
    static void testErrorLogFromStrings() {
        String stackTrace;

        // Again, using startTest() and stopTest() as a visual separator for the actions of the test. Optional. 
        Test.startTest();
            try {
                throw new TestLoggerException(TEST_ERROR_MESSAGE);
            } catch(TestLoggerException tle) {
                stackTrace = tle.getStackTraceString();

                Logger.insertErrorLog(tle.getStackTraceString(), tle.getMessage(), UserInfo.getUserId());
            }
        Test.stopTest();

        // Verify the record was created to expectation by running a general query and using assertions on the field
        // values afterwards.
        Error_Log__c createdLog = [SELECT Id, Record_Id__c, Message__c, Stack_Trace__c FROM Error_Log__c LIMIT 1]; 
        System.assertEquals(TEST_ERROR_MESSAGE, createdLog.Message__c);
        System.assertEquals(stackTrace, createdLog.Stack_Trace__c);
        System.assertEquals(UserInfo.getUserId(), createdLog.Record_Id__c);
    }

    // Cannot throw standard Apex exceptions like NullPointerException, so using a custom exception for testing.
    private class TestLoggerException extends Exception {}
}