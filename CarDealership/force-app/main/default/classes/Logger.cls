/**
    @author: Dan Thoreson
    @date: 13-Aug-2022
    @description: Class for error logging-related functionality. Generally used like this:
                    try {
                        // Risky code
                    } catch(SomeException se) {
                        Logger.insertErrorLog(se, recordId); // OR...
                        Logger.insertErrorLog('my custom stack trace', 'my custom error message', recordId);
                    }

                    Use null for recordId if one does not exist. It is optional. 
    @test class: LoggerTest
**/
public class Logger {

    /**
        @author: Dan Thoreson
        @date: 13-Aug-2022
        @description: Creates an Error Log record from an inputted Exception object
    **/
    public static void insertErrorLog(Exception ex, Id recordId) {
        insert createErrorLog(ex.getStackTraceString(), ex.getMessage(), recordId);
    }

    /**
        @author: Dan Thoreson
        @date: 13-Aug-2022
        @description: Overloaded version of insertErrorLog, creating an Error Log from an 
                      inputted message/stack trace
    **/
    public static void insertErrorLog(String stackTrace, String message, Id recordId) {
        insert createErrorLog(stackTrace, message, recordId);
    }

    /**
        @author: Dan Thoreson
        @date: 13-Aug-2022
        @description: Method for initializing a new Error Log object; does not insert to database.
    **/
    public static Error_Log__c createErrorLog(String stackTrace, String message, Id recordId) {
        return new Error_Log__c(Stack_Trace__c=stackTrace, Message__c=message, Record_Id__c=recordId);
    }

}