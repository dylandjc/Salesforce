/**
    @author: Dylan Chorley
    @date: 19-Sep-2022
    @group: Trigger Handlers
    @description: Trigger Handler for Notification Events
    @test class: NotificationTriggerHandlertest
**/
public with sharing class NotificationTriggerHandler implements EventTriggerHandler{
    //filters trigger based on response to either insert or an update and passes on files

    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Handles after notification event is inserted
        @param: list of trigger.new objects or opportunities
        @return: none, nothing happens as all done in opportunity
    **/
    public void handleAfterInsert(List<Opportunity> newOpp){
        System.debug(newOpp);
        //ignore because these should be called in opportunity 
        }
       
    }