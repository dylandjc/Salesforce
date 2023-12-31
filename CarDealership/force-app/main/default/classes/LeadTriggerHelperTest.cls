@IsTest
public with sharing class LeadTriggerHelperTest {
    @TestSetup
    static void makeData(){
        TestFactory.createTestParkingLot();
        TestFactory.createTestVehicle(true, 10, true);
    }
    @IsTest
    static void testFillDate(){
        List<Lead> leads = TestFactory.createTestLeadList(false, true, 4);
        List<Lead> updatedLeads = LeadTriggerHelper.fillDateOnLead(leads);
        Test.startTest();
        for(Lead ls: updatedLeads){
            System.assertEquals(true, ls.Calculated_Purchase_Date__c != null, 'purchase date should be filled');
        }
        List<Lead> ls1 = TestFactory.createTestLeadList(false, true, 1);
        ls1[0].Planned_Purchase_Time__c = '1-2 Months';
        List<Lead> ls2 = TestFactory.createTestLeadList(false, true, 1);
        ls2[0].Planned_Purchase_Time__c = '1-2 Weeks';
        List<Lead> updatedLeads1 = LeadTriggerHelper.fillDateOnLead(ls1);
        List<Lead> updatedLeads2 = LeadTriggerHelper.fillDateOnLead(ls2);
        for(Lead ls: updatedLeads1){
            System.assertEquals(true, ls.Calculated_Purchase_Date__c == Date.today()+60, 'purchase date should be filled');
        }
        for(Lead ls: updatedLeads2){
            System.assertEquals(true, ls.Calculated_Purchase_Date__c == Date.today()+14, 'purchase date should be filled');
        }
        Test.stopTest();
        
    }
    @IsTest
    static void testSetCompany(){
        List<Lead> ls1 = TestFactory.createTestLeadList(false, true, 5);
        List<Lead> updatedCompany = LeadTriggerHelper.setCompany(ls1);
        for(Lead newComp: updatedCompany){
            System.assertEquals(newComp.FirstName + '_' + newComp.LastName, newComp.Company, 'company value autogenerated');
        }        
    }

     /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Checks the lead conversion ability is handled correctly
        @param: none
        @return: System.assert statements 
    **/
    @IsTest
    public static void handleLeadConversion(){
        Lead ls = TestFactory.createTestLead(false, true);
        Lead ls2 = TestFactory.createTestLead(false, true);
        System.debug([SELECT COUNT(ID) FROM Vehicle__c WHERE Status__c=:'In Stock']);
        insert ls;
        insert ls2;
        Lead test1 = [SELECT Id, Status FROM LEAD LIMIT 1];
        test1.Status = Constants.LEAD_STATUSES.TEST_DRIVE_SCHEDULED;
        update test1;
        Integer count = [SELECT COUNT() FROM Opportunity];
        String st = [SELECT State__c FROM LEAD LIMIT 1].State__c;
        System.assert(count == 1, 'The lead should be converted now');
        System.assertEquals(1, [SELECT Id, IsConverted FROM LEAD WHERE IsConverted=false].size(), 'The lead should not be converted if not the correct status');
        System.assert(st == 'Alabama', 'The state should have been filled out by a default');
        //test if lead is converted after updating the status 
    }
    /**
        @author: Dylan Chorley
        @date: 16-Sep-2022
        @description: Checks that the helper function also works in converting a lead separate from the trigger
        @param: none
        @return: calls to test factory and the helper function checked by assert statements 
    **/
    @IsTest
    public static void checkHelperConvert(){
        List<Lead> leadsToConvert = new List<Lead>();
        Lead ls = TestFactory.createTestLead(false, true);
        Lead ls2 = TestFactory.createTestLead(false, true);
        insert ls;
        insert ls2;
        ls.Status = Constants.LEAD_STATUSES.TEST_DRIVE_SCHEDULED;
        leadsToConvert.add(ls);
        leadsToConvert.add(ls2);
        Test.startTest();
        List<Database.LeadConvertResult> results = LeadTriggerHelper.checkStatusConvert(leadsToConvert);
        Test.stopTest();
        for(Database.LeadConvertResult res: results){
            System.assertEquals(res.isSuccess(), true, 'All leads that should be converted were converted successfully');
        }
    }
}