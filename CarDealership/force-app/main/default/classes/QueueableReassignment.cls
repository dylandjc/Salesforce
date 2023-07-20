/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Queue practice
    @description: Reassigns opportunities when user is to be deactivated 
    @test class: QueueableReassignmentTest
**/
public with sharing class QueueableReassignment implements Queueable{
    /**
        @author: Dylan Chorley
        @date: 23-Aug-2022
        @description: 
        @param: userId which is the record id of the deactivated user 
        @return: dis the constructor
    **/

    private Id userLeaving;
    public QueueableReassignment(Id userId) {
        //Get user information
        userLeaving = userId;
        
    }
    
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Sets up email with table of how opportunities have been reorganized
        @param: Manager's email and a list of the reassigned opportunities as it connects to users
        @return: List of email sending results to determine if email sending was successful
    **/
    public static List<Messaging.SendEmailResult> sendEmail(String manager, List<UserCountWrapper> reassigned){
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>{};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        // organization class getBaseUrl()
        String msg = 'This is a notification that opportunities have been reassigned. Please see below for the new breakdown:';
        // list of owner name to # of opps
        String breakdown = getHtmlEmailBodyFor(reassigned);
        //make this an html tabl
        mail.setHtmlBody(breakdown);
        mail.ToAddresses = new String[]{manager};
        mail.setSenderDisplayName('Opportunity Support');
        mail.setSubject('Opportunity Reassignment');
        mail.setPlainTextBody(msg);
        mails.add(mail);
        return Messaging.sendEmail(mails);
        //send all emails in checkOppDate instead of here for increased efficiency
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Redistributes new opportunities to users making it so no user gets all of them
        @param: List of opportunities that need to be redistributed 
        @return: List of newly redistributed user to number of opportunities 
    **/
    public static List<UserCountWrapper> redistribute(List<Opportunity> opps, List<UserCountWrapper> changes){
        List<Opportunity> newOwners = new List<Opportunity>();
        // collect current split of owners to number of opportunities order ascending 
        UserCountWrapper index;
        if(opps.size()<=(changes[1].getCount() - changes[0].getCount())){
            for(Opportunity oldOpp: opps){
                oldOpp.OwnerId = changes[0].getUser();
                changes[0].addCount();
            }
            update newOwners;
            return changes;
        }
        else{
            for(Opportunity oldOpp: opps){
                //pickOwner returns the index in changes where change to be made
                index = pickOwner(changes, 1);
                oldOpp.OwnerId = index.getUser();
                Integer actualIndex = changes.indexOf(index);
                changes[actualIndex].addCount();
                changes.sort();
                //changes.add(new UserCountWrapper(newHost, current.get(newHost) +1));
                newOwners.add(oldOpp);
            }
            update newOwners;
            return changes;
        }
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Gets the current distribution of users to opportunities they are owner of
        @param: none
        @return: List of wrapper class which puts user to number of opportunities they own
    **/
    public static List<UserCountWrapper> getCurrentDistribution(){
        List<UserCountWrapper> totals = new List<UserCountWrapper>();
        // order in ascending order 
        //someone who has closed all opportunities how do we access they are a salesperson 
        Set<Id> userlist = new Set<Id>();
        AggregateResult[] owned = [SELECT OwnerId, COUNT(Id) FROM Opportunity WHERE isClosed = False GROUP BY OwnerId];
        for(AggregateResult ar: owned){
            totals.add(new UserCountWrapper((Id)ar.get('OwnerId'), (Integer)ar.get('expr0')));
            userlist.add((Id)ar.get('OwnerId'));
        }
        Map<Id, Opportunity> leftover = new Map<Id, Opportunity>([SELECT OwnerId FROM Opportunity]);
        Set<Id> complete = leftover.keySet();
        complete.removeAll(userlist);
        // clean up whatever leftover people there are who might have zero sales currently open
        if(!complete.isEmpty()){
            for(Id zero: complete){
                totals.add(new UserCountWrapper(zero, 0));
            }
        }
        totals.sort();
        return totals;
    }
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Picks a new owner for the opportunity in question recursively selects owner with least number of opps
        @param: List of user wrapper objects and an index from where in the list to begin searching from 
        @return: User Wrapper object for the new owner of opportunity 
    **/
    public static UserCountWrapper pickOwner(List<UserCountWrapper> changes, Integer index){
        //picks the id with lowest value to add new user to 
        //User pickedUser = sortedUsers[0]; 
        Integer compared = changes[index-1].compareTo(changes[index]);
        if(compared < 1){
            return changes[index-1];
        }
        else{
            if(compared == 1){
                //check how many are the same value and make sure that still in ascending order 
                changes.sort();
                return pickOwner(changes, 1);
            }
            else{
                return null;
            }
        }
    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Required for Queueable object
        @param: Executes queue when resources available sc is ignored
        @return: none
    **/
    public void execute(System.QueueableContext sc){
        //in case I do end up needing the email of old user
        User leave = [SELECT Id, Email FROM User WHERE ID=:userLeaving];
        // Get all opportunities where user is the owner 
        List<Opportunity> needToCleanOpps = new List<Opportunity>([SELECT Id, OwnerId FROM Opportunity WHERE OwnerId = :userLeaving AND isClosed=False]);
        //get current spread of users to their opps
        List<UserCountWrapper> current = getCurrentDistribution();
        //reassign and redistribute open opps to users
        List<UserCountWrapper> reassigned = redistribute(needToCleanOpps, current);
        //completionEmail - show new value for number of oopen opportunities they have
        sendEmail('dylan.chorley@doordash.com', reassigned);

    }

    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Helper function for html 
        @param: results from redistributed user wrappers 
        @return: String of html body that cleans up and develops the table 
    **/
    public static String getHtmlEmailBodyFor(List<UserCountWrapper> thisResult) {
        String htmlBody = '<p>The opportunities listed in the tables below have been reassigned to your pipeline in Salesforce. Please review these records and follow up with each customer accordingly. If you have any questions, please contact your manager. </p><br /><br />';
        htmlBody += '<table border="1" style="border-collapse: collapse"><caption>Opportunity Reassignment Results</caption><tr><th>Owner Name</th><th>Id</th><th># Of Open Opps</th></tr>';
        
            // Include Lead Name (and link to), Status, Next Action Date, Next Event Date for Leads not in Unqualified status
            for(UserCountWrapper thisUser : thisResult) {
                htmlBody += '<tr><td>'+ thisUser.getUserName() + '</td><td>' + thisUser.getUser() + '</td><td>' + thisUser.getCount() + '</td><td></tr>';
            }       
        htmlBody += '</table>';
        htmlBody += '<br /><br /><br /><br />';       
        
        return htmlBody;        
    }
}