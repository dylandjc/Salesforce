/**
    @author: Dan Thoreson
    @date: 05-Aug-2022
    @description: Supports trigger-related functionality, such as bypassing triggers.
    @test class: TriggerUtilitiesTest
**/
public class TriggerUtilities {

    private static List<TriggerUtilities.TriggerBypassWrapper> BYPASSES = getTriggerBypasses();

    // Method to check for Active status, appies to all users, or specific Profile/User Id for a given sObject using
    // custom metadata. Used by triggers to determine whether they should proceed or not.
    public static Boolean isBypassed(String sObjectName) {

        for(TriggerBypassWrapper bypass : getTriggerBypassByObjectName(sObjectName)) {

            if(bypass.isActive()) {
                // Check to see if the Bypass should apply to all users
                if(bypass.appliesToAllUsers()) return true;

                // Check to see if the Bypass applies to the current user
                if(bypass.appliesToCurrentUser()) return true;
            
            }
        }

        return false;
    }

    /**
        @author: Dan Thoreson
        @date: 05-Aug-2022
        @description: Gets applicable Bypass record(s) for an inputted object name. 
    **/    
    private static List<TriggerUtilities.TriggerBypassWrapper> getTriggerBypassByObjectName(String objName) { 
        List<TriggerUtilities.triggerBypassWrapper> returnList = new List<TriggerUtilities.TriggerBypassWrapper>();
        for(TriggerUtilities.TriggerBypassWrapper thisBypass : BYPASSES) {
            if(thisBypass.isValid(objName)) {
                returnList.add(thisBypass);
            }
        }

        return returnList;
    }

    /**
        @author: Dan Thoreson
        @date: 05-Aug-2022
        @description: Retrieves the Trigger Bypass records and converts them to  TriggerBypassWrapper objects
    **/
    private static List<TriggerUtilities.TriggerBypassWrapper> getTriggerBypasses() {
        List<TriggerUtilities.TriggerBypassWrapper> triggerBypassWrappers = new List<TriggerUtilities.TriggerBypassWrapper>();

        for (Trigger_Bypass__mdt triggerBypass : [SELECT Id, Active__c, SObject_Name__c, Profile_Ids__c, User_Ids__c FROM Trigger_Bypass__mdt]) {
            triggerBypassWrappers.add(new TriggerUtilities.TriggerBypassWrapper(triggerBypass));
        }

        return triggerBypassWrappers;
    }

    /**
        @author: Dan Thoreson
        @date: 05-Aug-2022
        @description: A nested class to hold the logic associated with the associated Trigger Bypass
    **/
    public class TriggerBypassWrapper {
        private final String SOBJECT_ALL = 'ALL';
        private Trigger_Bypass__mdt triggerBypass;

        public TriggerBypassWrapper(Trigger_Bypass__mdt triggerBypass) {
            this.triggerBypass = triggerBypass;
        }

        /**
            @author: Dan Thoreson
            @date: 05-Aug-2022
            @description: Bypass records can be deactivated as well; if Active__c == false then the triggers will continue to run.
        **/         
        public Boolean isActive() {
            return this.triggerBypass.Active__c;
        }

        /**
            @author: Dan Thoreson
            @date: 05-Aug-2022
            @description: Returns true if the Bypass record applies to the object whose trigger is executing. This will be the case
                          if either the SObject Name matches, or the Bypass SObject Name is "All". 
        **/        
        public Boolean isValid(String sObjectName) {
            return this.triggerBypass.SObject_Name__c.equalsIgnoreCase(sObjectName) || this.triggerBypass.SObject_Name__c.equalsIgnoreCase(SOBJECT_ALL); 
        }

        /**
            @author: Dan Thoreson
            @date: 05-Aug-2022
            @description: Bypasses will apply to all users if Profile Ids and User Ids are blank. Otherwise, they will disable
                          triggers only for the specified user(s) and user(s) with the specified Profiles.

                          This should be done if, for example, there is an issue with the trigger and it needs to be bypassed for everyone. 
        **/         
        public Boolean appliesToAllUsers() { 
            return String.isBlank(this.triggerBypass.Profile_Ids__c) && String.isBlank(this.triggerBypass.User_Ids__c);
        }

        /**
            @author: Dan Thoreson
            @date: 05-Aug-2022
            @description: True if triggers should only be disabled for the specified user(s) and user(s) with the specified Profiles.

                          This should be done if, for example, a user has to do a large data load for which the trigger should be disabled.
                          The Bypass won't apply to regular users who are currently working in the system.
        **/          
        public Boolean appliesToCurrentUser() {
            return appliesToCurrentUsersProfileId() || appliesToCurrentUsersUserId();
        }

        /**
            @author: Dan Thoreson
            @date: 05-Aug-2022
            @description: If Profile_Ids__c are entered, determine if this Bypass record applies to the running user. 
        **/
        private Boolean appliesToCurrentUsersProfileId() {
            if (this.triggerBypass.Profile_Ids__c != null) {
                String profileIdsWithoutWhitespace = this.triggerBypass.Profile_Ids__c.replaceAll(' ', '');
                Set<String> profIds = new Set<String>(profileIdsWithoutWhitespace.split(','));
                
                if (profIds.contains(UserInfo.getProfileId()) || profIds.contains(String.valueOf(UserInfo.getProfileId()).substring(0, 15))) {
                    return true;
                }
            }

            return false;
        }

        /**
            @author: Dan Thoreson
            @date: 05-Aug-2022
            @description: If User_Id__c are entered, determine if this Bypass record applies to the running user. 
        **/        
        private Boolean appliesToCurrentUsersUserId() {
            if (this.triggerBypass.User_Ids__c != null) {
                String userIdsWithoutWhitespace = this.triggerBypass.User_Ids__c.replaceAll(' ', '');
                Set<String> userIds = new Set<String>(userIdsWithoutWhitespace.split(','));
                
                if (userIds.contains(UserInfo.getUserId()) || userIds.contains(String.valueOf(UserInfo.getUserId()).substring(0, 15))) {
                    return true;
                }
            }

            return false;
        }
    }
}