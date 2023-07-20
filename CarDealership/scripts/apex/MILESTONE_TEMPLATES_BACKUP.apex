List<Milestone_Template__c> templatesToUpsert = new List<Milestone_Template__c>();

Id caseMarketPlaceRecordTypeId = CDdSchemaUtils.CASE_RT.marketplaceOnboardingId();

// Deactivate the old Milestone
Milestone_Template__c oldPosMilestone = [SELECT Id, Active__c FROM Milestone_Template__c WHERE Milestone_Type__c = 'Setup POS Integration' AND Parent_Object_Record_Type_ID_18__c = :caseMarketPlaceRecordTypeId LIMIT 1];
oldPosMilestone.Active__c = false;
templatesToUpsert.add(oldPosMilestone);

// ======= CREATE NEW MILESTONE TEMPLATES ======== //
// Store & POS Integration Setup
// Milestone_Template__c storeAndPosSetup = CDdMilestoneTemplate.storeAndPOSIntegrationSetUpMarketplaceOnboarding();
// templatesToUpsert.add(storeAndPosSetup);

// TODO 
// Ingest POS Menu
Milestone_Template__c ingestPosMenu = CDdMilestoneTemplate.ingestPosMenuMarketplaceOnboarding();
templatesToUpsert.add(ingestPosMenu);

// TODO 
// POS Test Method
Milestone_Template__c posTestMethodMarketplaceOnboarding = CDdMilestoneTemplate.posTestMethodMarketplaceOnboarding();
templatesToUpsert.add(posTestMethodMarketplaceOnboarding);
// ======= END CREATE NEW MILESTONE TEMPLATES ======== //

// ======== REORDER EXISTING MARKETPLACE ONBOARDING MILESTONES ========== // 
Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Marketplace_Onboarding').getRecordTypeId();

List<Milestone_Template__c> templatesToReorder = new List<Milestone_Template__c>([SELECT Id, Name, Milestone_Type__c, Default_Sort_Order__c, Stage_Completed_Sort_Order__c 
                                                                                    FROM Milestone_Template__c
                                                                                    WHERE Parent_Object_Record_Type_ID_18__c = :recordTypeId
                                                                                    ORDER BY Default_Sort_Order__c]);

Map<String, Milestone_Template__c> templatesByName = new Map<String, Milestone_Template__c>();

for(Milestone_Template__c thisTemplate : [SELECT Id, Name, Milestone_Type__c, Default_Sort_Order__c, Stage_Completed_Sort_Order__c, Completed_by_Stage__c, Reviewed_by_Stage__c, Stage_Reviewed_Sort_Order__c 
                                                                                    FROM Milestone_Template__c
                                                                                    WHERE Parent_Object_Record_Type_ID_18__c = :recordTypeId]) {
    templatesByName.put(thisTemplate.Name, thisTemplate);
}

// Review & Triage - no changes

// Setup Store - no changes

// Setup Banking
Milestone_Template__c setupBanking = templatesByName.get('Setup Banking');
setupBanking.Default_Sort_Order__c = 3;
setupBanking.Stage_Completed_Sort_Order__c = 2;
setupBanking.Completed_by_Stage__c = 'Store Configuration';
setupBanking.Stage_Reviewed_Sort_Order__c = null;
setupBanking.Reviewed_by_Stage__c = null;
templatesToUpsert.add(setupBanking);

// Setup Custom Delivery Radius
Milestone_Template__c setupDeliveryRadius = templatesByName.get('Setup Custom Delivery Radius');
setupDeliveryRadius.Default_Sort_Order__c = 4;
setupDeliveryRadius.Stage_Completed_Sort_Order__c = 3;
setupDeliveryRadius.Completed_by_Stage__c = 'Menu Configuration';
templatesToUpsert.add(setupDeliveryRadius);

// Setup Business
Milestone_Template__c setupBiz = templatesByName.get('Setup Business');
setupBiz.Default_Sort_Order__c = 5;
setupBiz.Stage_Completed_Sort_Order__c = 2;
setupBiz.Completed_by_Stage__c = 'Store Configuration';
templatesToUpsert.add(setupBiz);

// Setup Menu
Milestone_Template__c setupMenu = templatesByName.get('Setup Menu');
setupMenu.Stage_Completed_Sort_Order__c = 3;
setupMenu.Default_Sort_Order__c = 6;
setupMenu.Completed_by_Stage__c = 'Menu Configuration';
templatesToUpsert.add(setupMenu);

// Setup Catalog
Milestone_Template__c setupCatalog = templatesByName.get('Setup Catalog');
setupCatalog.Stage_Completed_Sort_Order__c = 3;
setupCatalog.Default_Sort_Order__c = 7;
setupCatalog.Completed_by_Stage__c = 'Menu Configuration';
templatesToUpsert.add(setupCatalog);

// Grant Portal Access - no changes
Milestone_Template__c grantPortal = templatesByName.get('Grant Portal Access');
grantPortal.Default_Sort_Order__c = 8;
grantPortal.Stage_Completed_Sort_Order__c = 2;
grantPortal.Completed_by_Stage__c = 'Store Configuration';
grantPortal.Stage_Reviewed_Sort_Order__c = 3;
grantPortal.Reviewed_by_Stage__c = 'Menu Configuration';
templatesToUpsert.add(grantPortal);

// Store & POS Integration Setup - no changes - handled by CDdMilestoneTemplate
Milestone_Template__c storeAndPosSetup = new Milestone_Template__c(
    Name = 'Store & POS Integration Setup',
    Milestone_Type__c = 'Store & POS Integration Setup',
    Milestone_Record_Type_ID_18__c = milestoneRecordTypesByDevName.get('General_POS'), // TODO 
    Parent_Object_API_Name__c = 'Case',
    Parent_Object_Record_Type_ID_18__c = caseMarketPlaceRecordTypeId, // TODO - 
    Milestone_Creation_Type__c = 'Conditional',
    Default_Milestone_Status_on_Creation__c = 'Not Started',
    Default_Owner_on_Creation_18__c = milestoneOwnerId, // TODO - 
    Default_Sort_Order__c = 10,
    Active__c = true,
    Completed_by_Stage__c = 'POS Store Configuration',
    Reviewed_by_Stage__c = null,
    Stage_Completed_Sort_Order__c = 4,
    Stage_Reviewed_Sort_Order__c = null
);
templatesToUpsert.add(storeAndPosSetup);

// Ingest POS Menu - no changes - handled by CDdMilestoneTemplate

// Deliver Tablet
Milestone_Template__c deliverTablet = templatesByName.get('Deliver Tablet');
deliverTablet.Default_Sort_Order__c = 9;
deliverTablet.Stage_Completed_Sort_Order__c = 6;
deliverTablet.Completed_by_Stage__c = 'Onboarding Quality Check';
templatesToUpsert.add(deliverTablet);

// Activations Checklist
Milestone_Template__c activationsChecklist = templatesByName.get('Activations Checklist');
activationsChecklist.Default_Sort_Order__c = 13;
activationsChecklist.Completed_by_Stage__c = 'Onboarding Quality Check';
activationsChecklist.Stage_Completed_Sort_Order__c = 6;
templatesToUpsert.add(activationsChecklist);

// POS Test Method - handled by CDdMilestoneTemplate

// Activation Outreach
Milestone_Template__c activationOutreach = templatesByName.get('Activation Outreach');
activationOutreach.Default_Sort_Order__c = 14;
activationOutreach.Stage_Completed_Sort_Order__c = 7;
activationOutreach.Completed_by_Stage__c = 'Contacting Mx';
templatesToUpsert.add(activationOutreach);

// 14 - Activate Store
Milestone_Template__c activateStore = templatesByName.get('Activate Store');
activateStore.Default_Sort_Order__c = 15;
activateStore.Stage_Completed_Sort_Order__c = 8;
activateStore.Completed_by_Stage__c = 'Ready for Activation';
templatesToUpsert.add(activateStore);

// ======== END REORDER EXISTING MARKETPLACE ONBOARDING MILESTONES ========== // 


Database.upsert(templatesToUpsert);