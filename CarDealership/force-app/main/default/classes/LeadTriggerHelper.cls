/**
    @author: Dylan Chorley
    @date: 16-Sep-2022
    @group: Trigger Helper Function
    @description: The helper function for the lead trigger
    @test class: leadtriggerhandlertest
**/
public with sharing class LeadTriggerHelper {
    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Checks that status of lead is converted 
        @param: List of leads to be checked and added to converted list
        @return: List of results from converting the leads 
    **/
    public static List<Database.LeadConvertResult> checkStatusConvert(List<Lead> possibles){
        List<Lead> converted = new List<Lead>();
        for(Lead current:possibles){
            if((current.Status == Constants.Lead_Statuses.APPLICATION_STARTED || current.Status == Constants.Lead_Statuses.TEST_DRIVE_SCHEDULED) && !current.IsConverted){
                converted.add(current);
            }
        }
        return convertingLeads(converted);
    }
    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Converts leads 
        @param: List of leads to be converted
        @return: result from converting leads
    **/
    public static List<Database.LeadConvertResult> convertingLeads(List<Lead> leading){
        List<Database.LeadConvertResult> allConverted = new List<Database.LeadConvertResult>();
        for(Lead ls: leading){
            Database.LeadConvert temp = new Database.LeadConvert();
            temp.setLeadId(ls.Id);
            temp.setConvertedStatus(ls.Status);
            System.debug(ls.Vehicle__r.Status__c);
            Database.LeadConvertResult res = Database.convertLead(temp);
            allConverted.add(res);
            //ls.IsConverted = true;
        }
        return allConverted;
    }

    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Fills calculated date field from picklist date field choice by user
        @param: list of leads to be checked
        @return: none
    **/
    public static List<Lead> fillDateOnLead(List<Lead> leading){
        for(Lead ls: leading){
            if(ls.Planned_Purchase_Time__c=='1-2 Weeks'){
                ls.Calculated_Purchase_Date__c = Date.today()+14;
            }
            else{
                if(ls.Planned_Purchase_Time__c=='1-2 Months'){
                    ls.Calculated_Purchase_Date__c = Date.today()+60;
                }
                else{
                    ls.Calculated_Purchase_Date__c = Date.today()+90;
                }
            }
        }
        return leading;
    }
    /**
        @author: Dylan Chorley
        @date: 10-Oct-2022
        @description: Set the company for a lead equal to first name_last name
        @param: list of leads to set company to 
        @return: none
    **/
    public static List<Lead> setCompany(List<Lead> leads){
        for(Lead current:leads){
            current.Company = current.FirstName + '_' + current.LastName;
        }
        return leads;
    }

    public static List<Lead> checkVehicle(List<Lead> leads){
        for(Lead current: leads){
            if(current.Vehicle__r.Status__c != Constants.VEHICLE_STATUSES.IN_STOCK){
                current.addError('Vehicle is not in  stock');
            }
        }
        return leads;
    }
}