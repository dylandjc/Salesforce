/**
    @author: Dylan Chorley
    @date: 01-Sep-2022
    @description: FollowUp is a batch class that sends email reminders when five weeks after an opportunity is closed
    six weeks without finishing task it informs the manager of the opp owner to inform them they must do it
    @test class: FollowUpTest
**/
public with sharing class FollowUp implements Database.Batchable<SObject>, Database.Stateful{
    //Used for Database.Stateful and keeping updated on what tasks to send in emails
    public static List<Task> updatedTasks = new List<Task>();

    //Static list of all users
    public static Map<Id, User> names = new Map<Id, User>([SELECT Id, Name FROM USER]);
    
    /**
        @author: Dylan Chorley
        @date: 22-Aug-2022
        @description: Start method as pulled from Batch starts wuthe base query to collect the right opportunities
        @param: Batchable context variable (unused)
        @return: Returns the query locator which collects the list of opportunities from the query
    **/
    public Database.QueryLocator start(Database.BatchableContext sc){
        String query = 'SELECT Id, Name, OwnerId, CloseDate FROM Opportunity WHERE CloseDate>=N_DAYS_AGO:30';
        return Database.getQueryLocator(query);
    }
    /**
        @author: Dylan Chorley
        @date: 22-Aug-2022
        @description: Execute function implemented from Database.Batchable inserts the new tasks built based on query
        @param: List of opportunities from the query in start
        @return: Inserts new tasks no return
    **/
    public void execute(Database.BatchableContext s, List<Opportunity> allOpps){
        //clean allOpps
        Map<Id, Opportunity> theOpps = new Map<Id,Opportunity>(allOpps);
        List<Task> taskedOnes = getOpenOpps(theOpps);
        if(!taskedOnes.isEmpty()){
            updatedTasks = missedFollowUp(taskedOnes);
        }
        List<Task> newTasks = sendFollowUp(theOpps);
        insert newTasks;

    }
    /**
        @author: Dylan Chorley
        @date: 22-Aug-2022
        @description: Finish function implemented from batch that sends emails and debugs for testing
        @param: batchable context (unused)
        @return: sends emails to manager otherwise nada
    **/
    public void finish(Database.BatchableContext sc){
        if(updatedTasks.isEmpty()){
            System.debug('No tasks');
        }
        else{
            update updatedTasks;
            tellManager(updatedTasks);
            //System.debug(Test.isRunningTest());
        }

    }

    /**
        @author: Dylan Chorley
        @date: 22-Aug-2022
        @description: Builds task for the particular opportunity to be follwoed up on 
        @param: An opportunity opp which the task points to
        @return: New task built from opportunity for opportunity
    **/
    public static Task buildTask(Opportunity opp){
        // create task and due dates 
        Task newT = new Task();
        newT.Subject = 'Follow up on sale: ' + opp.Name;
        User owner = [SELECT ID FROM User WHERE ID=:opp.OwnerId LIMIT 1];
        // relate to owner, opportunity and customer
        newT.OwnerId = opp.OwnerId;
        newT.WhoId = opp.AccountId;
        newT.WhatId = opp.Id;
        newT.Status = 'Not Started';
        newT.Priority = 'Normal';
        newT.ActivityDate = Date.today()+6;
        return newT;
    } 
    /**
        @author: Dylan Chorley
        @date: 22-Aug-2022
        @description: Checks if an opportunity that has a follow up still hasn't been followed up
        @param: List of tasks missed which are all over a week old and past due date 
        @return: Returns list of tasks to send to manager null if parameter missed, list of tasks is empty
    **/
    public static List<Task> missedFollowUp(List<Task> missed){
        if(missed != null || missed.isEmpty() == false){
            for(Task t: missed){
                t.ActivityDate = Date.today()+6;
                t.Priority = 'High';
                t.Status = 'Overdue';
            }
            return missed;
        }
        return null;
    }

    /**
        @author: Dylan Chorley
        @date: 22-Aug-2022
        @description: Sends follow up if five weeks have passed after close date of opportunity
        @param: Builds first round of tasks based on the passage of five weeks for opportunity, calls task builder function to build list of tasks
        @return: List of tasks built to be inserted for owners to follow up with these closed opportunities to see how customer likes vehicle
    **/
    public static List<Task> sendFollowUp(Map<Id,Opportunity> currentOpps){
       
        Map<Id,Opportunity> oppWithTasks = getAllTaskedOpps();
        currentOpps.keySet().removeAll(oppWithTasks.keySet());
        List<Task> newFollowUps = new List<Task>();
        for(Id opp: currentOpps.keySet()){
            newFollowUps.add(buildTask(currentOpps.get(opp)));
        }
        return newFollowUps;
    }

    /**
        @author: Dylan Chorley
        @date: 22-Aug-2022
        @description: Returns a list of opportunities for a particlar amount of time past the close date
        @param: Map of opportunities by OpportunityId to opportunity 
        @return: List of tasks based on opportunities that have tasks that are not false and id in opp list
    **/
    public static List<Task> getOpenOpps(Map<Id,Opportunity> opps){
        List<Task> withTasks = new List<Task>([SELECT ActivityDate, Priority, Status FROM Task WHERE IsClosed = FALSE AND Id=:opps.keySet()]);
        return withTasks;
    }

    /**
        @author: Dylan Chorley
        @date: 23-Aug-2022
        @description: Returns a list of opportunities where the tasks have already been completed 
        @param: None
        @return: Map of opportunities to id for all opps that have tasks
    **/
    public static Map<Id, Opportunity> getAllTaskedOpps(){
        Map<Id, Opportunity> allTasks = new Map<Id,Opportunity>([SELECT Id, CloseDate, (Select Id, Subject from Tasks) FROM Opportunity WHERE CloseDate >=N_DAYS_AGO:30]);
        return allTasks;
    }

    /**
        @author: Dylan Chorley
        @date: 01-Sep-2022
        @description: Sends a singular email to manager with list of opportunities owners and tasks that were not completed the week before in an html table 
        @param: List of all tasks that did not get completed in the fifth week and now overdue
        @return: List of results from sending the list of emails- checks success of each 
    **/
    public static List<Messaging.SendEmailResult> tellManager(List<Task> allTasks){
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>{};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String manager = 'dylan.chorley@doordash.com';
        String table = '<table border="1" style="border-collapse: collapse"><caption>Opportunities that Need Follow Up</caption><tr><th>Opportunity Name</th><th>Owner Name</th><th>Opportunity Close Date</th></tr>';
        for(Task t: allTasks){
            //get the opportunity associated to the task
            table += sendRow(t);
        }
        String msg = 'This is a notification that a number of your employees have Opportunities that they were supposed to follow up on. They have until Saturday to finish this task. Make sure to close task upon reaching out.';
        mail.ToAddresses = new String[]{manager};
        mail.setHtmlBody(table);
        mail.setSenderDisplayName('Opportunity Support');
        mail.setSubject('Opportunity Follow-Up Final Reminder');
        mail.setPlainTextBody(msg);
        mails.add(mail);
        return Messaging.sendEmail(mails);
    }

    /**
        @author: Dylan Chorley
        @date: 01-Sep-2022
        @description: Helper function that builds the table in sendManager() -- colllects the info for the row and places in html form
        @param: Task t that is broken apart to get the data used for placing in each column of table
        @return: String form of html table row
    **/
    public static String sendRow(Task t){
        //change to one email inside of it
        Opportunity opp = [SELECT Id, OwnerId, CloseDate, Name FROM Opportunity WHERE Id=:t.WhatId];
        User u = names.get(opp.OwnerId);
        String htmlBody = '';
        htmlBody = '<tr><td>'+ opp.Name + '</td><td>' + u.Name + '</td><td>' + opp.CloseDate + '</td><td></tr>';      
        return htmlBody;
        //send all emails in checkOppDate instead of here for increased efficiency
    }
}