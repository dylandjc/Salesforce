/**
  @author: Dylan Chorley
  @date: 14-Sep-2022
  @group: Trigger Handlers
  @description: The trigger handler for the custom object lead staging that handles the json
  @test class: LeadStagingTriggerTest
**/
public with sharing class LeadStagingTriggerHandler{
 
  /**
    @author: Dylan Chorley
    @date: 14-Sep-2022
    @description: filters trigger based on response to either insert or an update and passes on files
    @param: the newly inserted/updated/changed leadstaging objects a map of the old staging objects and the trigger type
    @return: none
  **/
  public static void filterTrig(System.TriggerOperation operationType, 
  List<Lead_Staging__c> newOpp, Map<Id, Lead_Staging__c> oldMap){
  
    handleBeforeInsert(newOpp);
  
  }

  /**
    @author: Dylan Chorley
    @date: 14-Sep-2022
    @description: Handles the trigger for when a lead staging object is about ot be inserted and breaks down json
    @param: List of lead staging objects that are trying to be inserted 
    @return: none
  **/  
  public static void handleBeforeInsert(List<Lead_Staging__c> newOpp){
  
    LeadStagingTriggerHandlerHelper.jsonHandler(newOpp[0]);
  
  }

}