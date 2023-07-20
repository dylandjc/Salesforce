// Leads owned by running user
List<Lead> leadsOwnedByMe = new List<Lead>([SELECT Id, Name FROM Lead WHERE OwnerId = :UserInfo.getUserId()]);

// Alternate list instantiation
List<Account> lastTenAccounts = new List<Account>();
lastTenAccounts = [SELECT Id, Name, AnnualRevenue FROM Account ORDER BY CreatedDate DESC LIMIT 10];

List<User> allAdmins = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator'];

Integer numberOfContacts = [SELECT COUNT() FROM Contact];

// Bind variables
List<Contact> contacts = new List<Contact>([SELECT Id, Name FROM Contact WHERE AccountId = :thisAccount.Id]);

Date threeDaysAgo = System.today().addDays(-3);
List<Case> newCases = new List<Case>([SELECT Id, Status FROM Case WHERE CreatedDate > :threeDaysAgo]);