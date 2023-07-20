SELECT Id, Name FROM Make__c
SELECT Id, Name, VehicleMake__r.Name, VehicleType__c FROM Model__c
SELECT Id, Model__r.Name, Year__c, VIN_Number__c, Pre_Owned__c FROM Vehicle__c