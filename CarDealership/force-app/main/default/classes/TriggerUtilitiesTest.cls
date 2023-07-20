/**
    @author: Dan Thoreson
    @date: 19-Aug-2022
    @description: Test class for TriggerUtilities
**/
@IsTest
private class TriggerUtilitiesTest {

    @IsTest static void testIsBypassed() {
        Boolean nonExistentRecordResult = TriggerUtilities.isBypassed('xcvsdgasdg');
        Boolean fakeTestTriggerBypassed = TriggerUtilities.isBypassed('UnitTest');
        Boolean fakeTestTriggerDisabledBypass = TriggerUtilities.isBypassed('UnitTestOff');
        Boolean bypassForFakeObjectAndFakeUser = TriggerUtilities.isBypassed('UnitTestUser');

        System.assert(!nonExistentRecordResult);
        System.assert(fakeTestTriggerBypassed);
        System.assert(!fakeTestTriggerDisabledBypass);
        System.assert(!bypassForFakeObjectAndFakeUser);
    }

    @IsTest
    static void testWrapper() {
        TriggerUtilities.TriggerBypassWrapper wrapper = new TriggerUtilities.TriggerBypassWrapper(getBypassByObjectName('UnitTest'));

        System.assert(wrapper.isActive());
        System.assert(wrapper.isValid('UnitTest'));
        System.assert(wrapper.appliesToCurrentUser() || wrapper.appliesToAllUsers());
    }

    @IsTest
    static void testWrapperForUserAndProfile() {
        // User tests
        TriggerUtilities.TriggerBypassWrapper wrapper = new TriggerUtilities.TriggerBypassWrapper(new Trigger_Bypass__mdt(SObject_Name__c='UnitTest',
                                                                                                                            User_Ids__c=UserInfo.getUserId()));
        System.assert(wrapper.appliesToCurrentUser());
        System.assert(!wrapper.appliesToAllUsers());

        // Profile tests
        wrapper = new TriggerUtilities.TriggerBypassWrapper(new Trigger_Bypass__mdt(SObject_Name__c='UnitTest', Profile_Ids__c=UserInfo.getProfileId()));
        System.assert(wrapper.appliesToCurrentUser());
    }    
    private static Trigger_Bypass__mdt getBypassByObjectName(String thisName) {
        return [SELECT Id, Active__c, SObject_Name__c, Profile_Ids__c, User_Ids__c 
                    FROM Trigger_Bypass__mdt
                    WHERE Sobject_Name__c = :thisName
                    LIMIT 1];
    }
}