// Notice that this is a test class but is marked as public - we will need to use it 
// from other test classes. It also does not have any IsTest methods; it's not testing
// anything. It still need to be denoted as @IsTest at the class level for two reasons:
//      1. So it cannot be called from non-test code
//      2. So we do not have to test and get coverage for this class and its methods
@IsTest
/**
    @author: Dylan Chorley
    @date: 20-Sep-2022
    @group: Test Factories
    @description: User test factory
    @test class: none
**/
public class TestUserFactory {

    public static List<User> createUsersForProfile(Integer numberOfUsers) {
        List<User> usersToBeCreated = createUsers(numberOfUsers, null, true);
        return usersToBeCreated;
    }

    // Pass whatever profile ID in here - admin will work, or Standard User
    public static List<User> createUsersForProfile(Integer numberOfUsers, Id profileId) {
        List<User> usersToBeCreated = createUsers(numberOfUsers, profileId, true);
        return usersToBeCreated;
    }    
  
    /**
        @author: Dylan Chorley
        @date: 20-Sep-2022
        @description: Creates list of users
        @param: numberOfUsers to insert, doDml checks whether to insert or not, userProfile id is the pid of use
        @return: List of users 
    **/
    public static List<User> createUsers(Integer numberOfUsers, Id userProfileId, Boolean doDml) {
        List<User> usersToBeCreated = new List<User>();

        if(userProfileId == null) {
            userProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        }
  
        for(Integer i = 0; i < numberOfUsers; i++) {
            User u = new User(
                ProfileId = userProfileId,
                LastName = 'TestUser' + i,
                Email = 'testUserFactoryTesting' + i + '@test.com',
                Username = 'testUserFactoryTesting' + i + '@test.com' + System.currentTimeMillis(),
                CompanyName = 'Test',
                Title = 'TestTitle',
                Alias = 'alias' + i,
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );

            usersToBeCreated.add(u);
        }

        if(doDml && !usersToBeCreated.isEmpty()) {
            insert usersToBeCreated;
        }

        return usersToBeCreated;
    }
}