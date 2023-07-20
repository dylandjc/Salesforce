/**
    @author: Dylan Chorley
    @date: 01-Sep-2022
    @description: Interface for eventtrigger handlers for OOP practice
    @test class: See platform event notification for testing
**/
public interface EventTriggerHandler {
    void handleAfterInsert(List<SObject> newOpp);
}