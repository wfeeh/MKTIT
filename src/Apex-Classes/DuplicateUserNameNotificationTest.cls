@istest
public class DuplicateUserNameNotificationTest{
    static testmethod void mytest(){
        Quote_Approvers__c qApp = new Quote_Approvers__c(Name = 'Test First Name Test Last Name');
        insert qApp;
        Quote_Approvers__c qApp2 = new Quote_Approvers__c(Name = 'Test First Name Changed Test Last Name');
        insert qApp2;
        Profile prof = [select id from Profile where Name = 'System Administrator'];
        User testUser = new User (
            FirstName = 'Test First Name',
            LastName = 'Test Last Name',
            ProfileId = prof.Id,
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            Username = 'testUserName@TestUser.com',
            CommunityNickname = 'testUser123',
            Alias = 'Test1',
            Email = 'testUserName@TestUser.com',
            IsActive = true
        );
        Test.StartTest();
        insert testUser;
        testUser.FirstName = 'Test First Name Changed';
        update testUser;
        Test.StopTest();
    }
}