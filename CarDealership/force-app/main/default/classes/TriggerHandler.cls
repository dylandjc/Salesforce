/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Interface for Trigger Handlers
    @description: Methods used by all trigger handlers 
    @test class: none
**/
public interface TriggerHandler {
    //filters trigger based on response to either insert or an update and passes on files
    void filterTrig(System.TriggerOperation operationType, List<SObject> newOpp,
                                    Map<Id, SObject> oldMap);

    //calls necessary functions before inserting data
    void handleBeforeInsert(List<SObject> newOpp);

    //calls necessary functions after inserting data
    void handleAfterInsert(List<SObject> newOpp);
    

    //calls necessary functions before updating data
    void handleBeforeUpdate(List<SObject> newOpp, Map<Id, SObject> oldMap);
    
    //calls necessary functions after updating data
    void handleAfterUpdate(List<SObject> newOpp);

}