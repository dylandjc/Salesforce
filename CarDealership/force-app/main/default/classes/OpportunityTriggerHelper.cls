/**
    @author: Dylan Chorley
    @date: 19-Sep-2022
    @group: Trigger Helper
    @description: Helper functions for opportunity trigger handler
    @test class: OpportunityTriggerHandlerTest
**/
public with sharing class OpportunityTriggerHelper {

    /**
        @author: Dylan Chorley
        @date: 26-Sep-2022
        @description: Gets and sets a random sales rep for each opportunity inserted 
        @param: List of new opportunities 
        @return: none 
    **/
    public static void setSaleRep(List<Opportunity> newOpp){
        Schema.DescribeFieldResult fieldR = Opportunity.Sales_Rep__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldR.getPicklistValues();
        for(Opportunity opp: newOpp){
            opp.Sales_Rep__c = ((Schema.PicklistEntry)RandomizationUtils.getRandomElementFromList(ple)).getValue();
        }
    }

    //After Update of Opportunity update accounts and vehicle to match sold vehicles
    public static void stageIsClosed(List<Opportunity> newOpp){
        
        List<Id> updatedVehicles = new List<Id>();
        List<Id> finalSold = new List<Id>();
        List<Id> finalStock = new List<Id>();
        List<Vehicle__c> finalTotal = new List<Vehicle__c>();
        List<List<SObject>> totalIds = new List<List<SObject>>();
        

        for(Opportunity thisOpportunity : newOpp) {
            updatedVehicles.add(thisOpportunity.Vehicle__c);
            
            //Account referencedAcc = accounts.get(thisOpportunity.AccountId);
            Id currentVehicle = thisOpportunity.Vehicle__c;
            if(thisOpportunity.StageName == Constants.STAGE_NAMES.CLOSED_WON){
                //referencedAcc.Number_Of_Purchases__c += 1;
                //accs.add(referencedAcc);
                finalSold.add(currentVehicle);

            }
            else{
                if(thisOpportunity.StageName == Constants.STAGE_NAMES.CLOSED_LOST){
                    finalStock.add(currentVehicle);
                }
            }           
        }
        
        Map<Id, Vehicle__c> vehicles = new Map<Id, Vehicle__c>([SELECT Id, Status__c FROM Vehicle__c WHERE Id IN :updatedVehicles]);
        // add to new accounts map 
        //loop through purchaseHold and make the changes for each account id
        //actual updating
        //actual updating 
        for(Id veh: finalSold){
            Vehicle__c tempSold = vehicles.get(veh);
            tempSold.Status__c = Constants.VEHICLE_STATUSES.SOLD;
            finalTotal.add(tempSold);
        }

        for(Id veh: finalStock){
            Vehicle__c tempStock = vehicles.get(veh);
            tempStock.Status__c = Constants.VEHICLE_STATUSES.IN_STOCK;
            finalTotal.add(tempStock);
        }
        // soql query against the ids 
        // change to sold  here 
        // actualOpportunity.Vehicle__r.Status__c = Constants.VEHICLE_STATUSES.SOLD;
        // also add for adding number of purchases for account + 1
        // push updated list
        if(!finalTotal.isEmpty()){
            update finalTotal;
        }    
    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Add purchases to accounts for list of opportunities
        @param: List of opportunities
        @return: none and updates accounts
    **/
    public static void addPurchases(List<Opportunity> newOpp){
        List<Id> updatedAccs = new List<Id>();
        List<Id> updatedOpps = new List<Id>();
        List<Account> actualAccs = new List<Account>();
        Map<Id, Integer> purchaseHold = new Map<Id,Integer>();
        

        for(Opportunity thisOpportunity : newOpp) {
            if(thisOpportunity.StageName == Constants.STAGE_NAMES.CLOSED_WON){
                updatedAccs.add(thisOpportunity.AccountId);
                updatedOpps.add(thisOpportunity.Id);
                if(purchaseHold.containsKey(thisOpportunity.AccountId)){
                    NotificationTriggerHelper.uponClosedWon(thisOpportunity);
                    purchaseHold.put(thisOpportunity.AccountId, purchaseHold.get(thisOpportunity.AccountId) + 1);                 
                }
                else{
                    purchaseHold.put(thisOpportunity.AccountId, 1);
                }
            }
        }
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Number_Of_Purchases__c FROM Account WHERE Id IN :updatedAccs]);
        for(Id acc: purchaseHold.keySet()){
            Account increasePurch = accounts.get(acc);
            increasePurch.Number_of_Purchases__c = increasePurch.Number_of_Purchases__c + purchaseHold.get(acc);
            actualAccs.add(increasePurch);
                 
            
        }
        if(!actualAccs.isEmpty()){
            //update updatedAccs;
       
            update actualAccs;
        }
    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Checks if vehicle valid to br added to an opportunity
        @param: List of opportunities map of old non updated
        @return: none
    **/
    public static void checkVehicleValid(List<Opportunity> newOpp, Map<Id, Opportunity> oldMap){
        List<Id> newVehicleIds = new List<Id>();
        List<Id> oldVehicleIds = new List<Id>();
        for(Opportunity actualOpportunity : newOpp) {
            Opportunity preEditVehicle = oldMap.get(actualOpportunity.Id);
            if(actualOpportunity.StageName != Constants.STAGE_NAMES.CLOSED_LOST &&  actualOpportunity.Vehicle__c != preEditVehicle.Vehicle__c){
                actualOpportunity.Vehicle__c.addError('The vehicle cannot be changed in an ongoing sale. If the customer would like to switch vehicles, please close this opportunity and create a new one with the updated vehicle.');
            }     
            
            
        }
    }

    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Check opportunity name for list of opportunities to make sure that name has not been changed
        @param: List of opportunities
        @return: none
    **/
    public static void checkOpportunityName(List<Opportunity> newOpp){
        List<Id> vehicleIds = new List<Id>();
        List<Id> accIds = new List<Id>();
        for(Opportunity actualOpportunity : newOpp) {
            vehicleIds.add(actualOpportunity.Vehicle__c);
            accIds.add(actualOpportunity.AccountId);

        }
        Map<Id, Vehicle__c> vehicles = new Map<Id, Vehicle__c>([SELECT Year__c, Vehicle_Full_Name__c FROM Vehicle__c WHERE Id IN :vehicleIds]);
        Map<Id, Account> accs= new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accIds]);
        String correctName = '';
        for(Opportunity thisOpportunity: newOpp){
            if(thisOpportunity.AccountId == null){
                thisOpportunity.Name.addError('Account needs to be populated to proceed');
            }
            else{
                if(thisOpportunity.Vehicle__c == null){
                    thisOpportunity.Name.addError('Vehicle needs to be populated to proceed');
                }
                Vehicle__c referencedVehicle = vehicles.get(thisOpportunity.Vehicle__c);
                Account referencedAccount = accs.get(thisOpportunity.AccountId);
                
                correctName = referencedAccount.Name + ' - ' + referencedVehicle.Year__c + ' ' + referencedVehicle.Vehicle_Full_Name__c;
                if(thisOpportunity.Name != correctName){
                    thisOpportunity.Name = correctName;
                }
            }
        }
    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Converts vehicle information for opportunity changes such as record status to pending
        @param: List of opportunities
        @return: none
    **/
    public static void vehicleToOpportunity(List<Opportunity> newOpp){
        List<Id> updateOpps = new List<Id>();
        List<Vehicle__c> finalVehicles = new List<Vehicle__c>();
        for(Opportunity actualOpportunity : newOpp) {
            updateOpps.add(actualOpportunity.Vehicle__c);
            //When a Vehicle is added to an Opportunity, update the Vehicle record status to ‘Pending’
        }
        Map<Id, Vehicle__c> vehicles = new Map<Id, Vehicle__c>([SELECT Id, Status__c FROM Vehicle__c WHERE Id IN :updateOpps]);
        for(Opportunity thisOpportunity : newOpp) {
            Vehicle__c referencedVehicle = vehicles.get(thisOpportunity.Vehicle__c);
            if(referencedVehicle.Status__c == Constants.VEHICLE_STATUSES.IN_STOCK){
                referencedVehicle.Status__c = Constants.VEHICLE_STATUSES.PENDING;
                //UPDATE VEHICLE PARKING LOCATION
                NotificationTriggerHelper.uponVehStatusPending(thisOpportunity);
                finalVehicles.add(referencedVehicle);
            }
        }
        update finalVehicles;
    }

    /**
        @author: Dylan Chorley
        @date: 08/17/2022
        @description: Whenever OwnerId changes for opportunity, owner should be assigned to the sales queue only if not already in queue
     */
    @Future
    public static void addToQueue(List<Id> newIds){
        List<Opportunity> newOpps = new List<Opportunity>([SELECT Id, OwnerId FROM Opportunity WHERE Id=:newIds]); 

        List<GroupMember> finalSellers = new List<GroupMember>();
        Map<Id, GroupMember> groupMemberByIds = new Map<Id, GroupMember>();
        List<Group> gg = new List<Group>([SELECT Id, Name FROM Group WHERE Name = 'Sales' and Type='Queue']);
        for(GroupMember member:[SELECT UserOrGroupId FROM GroupMember WHERE Group.Name = 'Sales' and Group.Type ='Queue']){
            groupMemberByIds.put(member.Id, member);
        }
        
        //can we currently confirm all items in queue are users and not group ids 
        // query queuemembers 
        //List<User> currentQueue = new List<User>([]);
        for(Opportunity opp:newOpps){
            if(!groupMemberByIds.containsKey(opp.OwnerId)){
                //add opp.ownerId to queue
                GroupMember newMember = new GroupMember();
                //fill groupmember 
                newMember.UserOrGroupId = opp.OwnerId;
                newMember.groupId = gg[0].id;
                groupMemberByIds.put(newMember.UserOrGroupId, newMember);
                // groupMemberByIds add the groupmember 
                finalSellers.add(newMember);
            }
        }
        System.debug(finalSellers.size());
        if(finalSellers.size() >=1){
            insert finalSellers;
        }
        // configure user snippets json to include group too 
        
    }

    /**
        @author: Dylan Chorley
        @date: 01-Sep-2022
        @description: Adds the tax amount for list of opportunities as well as generate formula values based on account
        @param: list of opportunities
        @return: none
    **/
    public static void addTaxAmount(List<Opportunity> opps){
        List<Id> accsIds = oppToIds(opps, 'Account');
        Map<Id, Account> accs = new Map<Id, Account>([SELECT Id, State__c FROM Account WHERE Id IN:accsIds]);
        Map<Id, Vehicle__c> vehics = new Map<Id, Vehicle__c>([SELECT Id, Price__c FROM VEHICLE__C]);
        //get accounts therefore we have states
        //Map<String, Tax_Rate__mdt> taxes = Tax_Rate__mdt.getAll();
        Tax_Rate__mdt taxed = new Tax_Rate__mdt();
        State_Code__mdt states = new State_Code__mdt();
        Account current = new Account();
        String stated = '';
        for(Opportunity thisOpp: opps){
            //get account
            Vehicle__C vex = vehics.get(thisOpp.Vehicle__c);
            try{
                current = accs.get(thisOpp.AccountId);
                if(current.State__c != null){
                    stated = current.State__c;
                }
                else{
                    stated = 'Alabama';
                }
                stated = stated.replace(' ', '_');
                states = State_Code__mdt.getInstance(stated);
                taxed = Tax_Rate__mdt.getInstance(states.Abbreviation__c);
                if(thisOpp.Amount != vex.Price__c){
                    thisOpp.Amount = vex.Price__c;
                }
                thisOpp.Tax_Amount__c = thisOpp.Amount*taxed.State_Tax_Rate__c;
            }
            catch(NullPointerException e){
                thisOpp.AccountId.addError('Please add an account to this opportunity');
            }
            
        }
    }

    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Helper function that converts objects to ids 
        @param: List of opportunities and string id for opportunity or account so far
        @return: List of ids from converted objects
    **/
    public static List<Id> oppToIds(List<Opportunity> newOpp, String whichId){
        if(whichId == 'Opportunity'){
            List<Id> oppIds = new List<Id>();
            for(Opportunity opp: newOpp){
                oppIds.add(opp.Id);
            }
            return oppIds;
        }else{
            List<Id> oppIds = new List<Id>();
            for(Opportunity opp: newOpp){
                oppIds.add(opp.AccountId);
            }
            return oppIds;
        }
        
    }
    /**
        @author: Dylan Chorley
        @date: 19-Sep-2022
        @description: Converts close date if opportunity is converted from a lead
        @param: List of opportunities to be inserted 
        @return: none 
    **/
    public static void convertCloseDate(List<Opportunity> opps){
        for(Opportunity opp: opps){
            if(opp.Converted__c != null){
                opp.CloseDate = opp.Converted__c;
            }
        }
    }

}