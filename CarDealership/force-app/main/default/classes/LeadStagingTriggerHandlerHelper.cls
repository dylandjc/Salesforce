/**
    @author: Dylan Chorley
    @date: 16-Sep-2022
    @group: TriggerHandler Helper classes
    @description: All methods for the lead staging trigger handler
    @test class: LeadStagingTrigger test
**/
public with sharing class LeadStagingTriggerHandlerHelper {

    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Takes in a lead staging object and breaks down json and creates lead if possible
        @param: Lead staging object newStaged
        @return: none
    **/
    public static void jsonHandler(Lead_Staging__c newStaged){
        //pick up new data from Lead Staging 
        //deserialize the json from request body
        //Check if lead exists  with lead_service_id__c that ex
        List<Lead> completeLeads = new List<Lead>();
        Map<String, Object> unpack = new Map<String, Object>();
        Map<String, Object> unpackNames = new Map<String, Object>();
        //Collect all ids phones and emails from the json 
       
        // ls id is the key 
        try{
            unpack = (Map<String, Object>) JSON.deserializeUntyped(newStaged.Request_Body__c);
        }
        catch(JSONException j){
              //one for deserialization and one for duplicate
            Logger.insertErrorLog(j, newStaged.Id);
            //might need to make own exception
            throw new JSONException();
        }
        
        unpackNames = (Map<String, Object>) unpack.get('name');
        completeLeads = new List<Lead>([SELECT Id, Lead_Service_Id__c FROM Lead WHERE Lead_Service_Id__c=:(String) unpack.get('id')]);
        if(!completeLeads.isEmpty()){
            Lead updated = completeLeads[0];
            updated.Phone =(String) unpack.get('phone');
            updated.Email = (String) unpack.get('email');
            updated.FirstName = (String) unpackNames.get('first');
            updated.LastName = (String) unpackNames.get('last');
            updated.Salutation = (String) unpackNames.get('salutation');
            //get name ones
            newStaged.Completed__c = true; 
            update updated;
        }
        else{
            try{
                completeLeads = new List<Lead>([SELECT Id, Lead_Service_Id__c, Phone, Email FROM Lead WHERE Phone=:(String) unpack.get('phone') OR MobilePhone=:(String)unpack.get('phone') OR Email=:(String) unpack.get('email')]);
                if(!completeLeads.isEmpty()){
                    throw new DuplicateLeadException('Lead exists with matching Phone or Email. Lead Details: ' + newStaged.Request_Body__c);
                }
                insert createNewLead(unpack, unpackNames);
                newStaged.Completed__c = true;
            }
            catch(DuplicateLeadException e){
                //one for deserialization and one for duplicate
                Logger.insertErrorLog(e, newStaged.Id);
                throw new DuplicateLeadException('Lead exists with matching Phone or Email. Lead Details: ' + newStaged.Request_Body__c);
            }
        }
    }

    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Creates a new lead given map from json handler
        @param: unpack map that houses the data that doesn't include name data, unpackNames -- all name data from json
        @return: a new Lead 
    **/
    public static Lead createNewLead(Map<String, Object> unpack, Map<String, Object> unpackNames){
        Lead l = new Lead();
        l.Lead_Service_Id__c = (String )unpack.get('id');
        l.Phone =(String) unpack.get('phone');
        l.Email = (String) unpack.get('email');
        l.Salutation = (String) unpackNames.get('salutation');
        l.FirstName = (String) unpackNames.get('first');
        l.LastName = (String) unpackNames.get('last');
        System.debug(l.LastName);
        System.debug(unpack.get('name.last'));
        
        return l;
    }
}