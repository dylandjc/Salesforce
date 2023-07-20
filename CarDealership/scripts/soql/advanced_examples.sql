// Groupings
SELECT COUNT(Id), State FROM Lead GROUP BY State

// Sub-queries
SELECT Id, Name, (SELECT FirstName, LastName, Phone, Email FROM Contacts) FROM Account

// Offset (pagination) - retrieve records 11-20
SELECT Id, Name FROM Account ORDER BY Name LIMIT 10 OFFSET 10

// Reverse sort order - highest values first
SELECT Id, Name FROM Account ORDER BY AnnualRevenue DESC
SELECT LastName, FirstName FROM User ORDER BY LastName DESC

// Multiple text values - good for picklists
SELECT Id, Name, Phone FROM Lead WHERE LeadSource IN ('Web', 'Phone Inquiry', 'Other')
SELECT Id, Name, Phone FROM Lead WHERE Status NOT IN ('Closed - Converted', 'Closed - Not Converted')

// Filter by substring values
SELECT FirstName, LastName FROM Contact WHERE FirstName LIKE 'Jo%' // Returns "Jon", "John", "Joanna" but not "Jason"
SELECT FirstName, LastName FROM User WHERE LastName LIKE '%o%' // Returns everyone with an "o" in their last name

// Setup objects
SELECT Id, DeveloperName, SObjectType FROM RecordType ORDER BY SObjectType, DeveloperName
SELECT Id, Name, Status, LengthWithoutComments FROM ApexClass ORDER BY Name





