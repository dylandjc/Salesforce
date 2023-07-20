/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Schedulables
    @description: Schedules alerts for close dates
    @test class: SchedCloseDateAlertstest
**/
public with sharing class SchedCloseDateAlerts implements Schedulable{

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: required for schedulable
        @param: none
        @return: sends emails 
    **/
    public void execute(SchedulableContext sc){
        Messaging.SingleEmailMessage[] mails = checkOppDate();  
        Messaging.sendEmail(mails);

    }

    /**
        @author: Dylan Chorley
        @date: 22-Aug-2022
        @description: Returns list of emails to be sent for reminding user the close date has passed and that they need to close the case
        @param: 
        @return: Returns list of emails to be sent in execute
    **/
    public static Messaging.SingleEmailMessage[] checkOppDate(){
        // add is closed instead
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>{};
        User manager = null;
        List<Opportunity> allOpps = new List<Opportunity>([SELECT Id, OwnerId, Name, CloseDate FROM Opportunity WHERE isClosed != True]);
        for(Opportunity current: allOpps){
            if(current.CloseDate < System.today() && current.CloseDate.daysBetween(System.today()) <=3){
                //use id to access correct owner 
                User owner = [SELECT Id, Email, ManagerId FROM User WHERE ID=:current.OwnerId];
                if(owner.ManagerId != null){
                    manager = [SELECT Id FROM User WHERE ID=:owner.ManagerId];
                }
                mails.add(sendEmail(owner, manager, current.Name, current.Id));
            
            }
        }
        return mails;
    }

    /**
        @author: Dylan Chorley
        @date: 22-Aug-2022
        @description: Creates the email for the particular opportunity and owner
        @param: the owner of the opportunity (User), the manager of the owner (User), the name of the opportunity, and the id of the opportunity
        @return: A single email in the form of a Messaging.SingleEmailMessage object
    **/
    public static Messaging.SingleEmailMessage sendEmail(User owner, User manager, String name, Id opport){
        System.debug('Well well');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Opportunity op = new Opportunity();
        // organization class getBaseUrl()
        String hyperLink = URL.getSalesforceBaseUrl().toExternalForm()+Id.valueOf(opport)+'/view';
        String msg = 'This is a notification that you have an Opportunity (' + name + ') whose projected Close Date is now in the past: ' + hyperLink + '. Please close the Opportunity or update the Close Date.';
        mail.ToAddresses = new String[]{owner.Email};
        if(manager != null){
            mail.CcAddresses = new String[]{manager.Email};
        }
        mail.setSenderDisplayName('Opportunity Support');
        mail.setSubject('Opportunity has exceeded Close Date');
        mail.setPlainTextBody(msg);
        return mail;
        //send all emails in checkOppDate instead of here for increased efficiency
        

    }

}