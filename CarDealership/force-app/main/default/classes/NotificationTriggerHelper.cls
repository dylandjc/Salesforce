/**
    @author: Dylan Chorley
    @date: 19-Sep-2022
    @group: Trigger Helper Functions
    @description: Helper class for notification usage that is called from opportunity
    @test class: Opportunitytriggerhandlertest
**/
public with sharing class NotificationTriggerHelper {
    /**
        @author: Dylan Chorley
        @date: 25-Aug-2022
        @description: When an opportunity is won it sends an sms message to the owner of opportunity
        @param: one opportunity known as this opportunity
        @return: List of database.saveresults for whether or not a message was successfully sent
    **/
    public static List<Database.SaveResult> uponClosedWon(Opportunity thisOpportunity){
        List<Notification__e> finalNotif = new List<Notification__e>();

        List<Id> updateNames = new List<Id>();
        List<Id> updateAccs = new List<Id>();

        Map<Id, User> names = new Map<Id, User>([SELECT Id, FirstName, Phone FROM User]);
        Map<Id, Account> accs = new Map<Id, Account>([SELECT Id, FirstName, Phone FROM Account WHERE Id=:thisOpportunity.AccountId]);
        User name = names.get(thisOpportunity.OwnerId);
        Account acco = accs.get(thisOpportunity.AccountId);
        Notification__e notif = new Notification__e(Type__c='SMS', 
                                                    Record_Id__c=acco.Id,
                                                    Message_Body__c='The sale of your ' + thisOpportunity.Name + ' has been finalized! ' + name.FirstName +'will be reaching out to you shortly to schedule delivery.', From_Number__c=name.Phone, To_Number__c=acco.Phone); 
        finalNotif.add(notif);
        
        
        List<Database.SaveResult> sr = EventBus.publish(finalNotif);
        return sr;
    }
    /**
        @author: Dylan Chorley
        @date: 25-Aug-2022
        @description: When a vehicle status is converted to pending for an opportunity, slack notification sent that displays info on pending sale
        @param: An opportunity known as thisOpportunity
        @return: List of database saveresult objects that declare whether slack notification was successfully sent
    **/
    public static List<Database.SaveResult> uponVehStatusPending(Opportunity thisOpportunity){
        List<Id> updateOpps = new List<Id>();
        List<Notification__e> finalNotif = new List<Notification__e>();
        Map<Id, Vehicle__c> vehicles = new Map<Id, Vehicle__c>([SELECT Id, Status__c, Vehicle_Full_Name__c, VIN_Number__c FROM Vehicle__c WHERE Id=:thisOpportunity.Vehicle__c]);
        //Map<Id, User> names = new Map<Id, User>([SELECT Id, FirstName FROM User WHERE Id IN :updateNames]);
        Vehicle__c referencedVehicle = vehicles.get(thisOpportunity.Vehicle__c);
        //String name = names.get(thisOpportunity.OwnerId).FirstName;
        //publish platformevent
        Notification__e notif = new Notification__e(Type__c='Slack', Record_Id__c=thisOpportunity.Vehicle__c, Message_Body__c=  referencedVehicle.Vehicle_Full_Name__c + ' (VIN Number: ' + referencedVehicle.VIN_Number__c + ') has a pending sale'); 
        finalNotif.add(notif);
        List<Database.SaveResult> sr = EventBus.publish(finalNotif);
        return sr;
    }
}