public class CustomMilestoneTest{
    //Variable to prevent CustomMilestone stuck in recursion. 
    public static Boolean firstRun = true;
    public static Boolean firstRunInCaseCommentTrigger = true;
    public static Boolean firstRunInCaseCustomMileTrigger = true;
    @isTest(SeeAllData=true)
    public static void insertCaseUpdateMilestoneTrigger() { 
        Entitlement  demoEntitlement               = [Select id from Entitlement where Name = 'Marketo Demo 17 Internal'];
        List<Contact> tempContact                  = [Select Id, AccountId From Contact where Customer_Portal_User__c = true and Is_Authorized_Contact__c = 'Yes' Limit 1];
        System.Debug('tempContact++++'+tempContact[0].Id);
        List<User> testUser = [Select Id from User Where IsActive = true Limit 1];
        Case tempCase = new case(OwnerId = testUser[0].Id,ContactId = tempContact[0].Id, AccountId = tempContact[0].AccountId, subject='Test Case',description='asd',Problem_Type__c='Community',Category__c='General Questions',Priority='P3',Status = 'Awaiting Customer Input',EntitlementId = demoEntitlement.Id);        System.Debug('Case at time of creation'+tempCase);
        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;
        CustomMilestoneTest.firstRun = true;
        tempCase.Priority = 'P2';
        tempCase.Status   = 'New';
        update tempCase;
        CustomMilestoneTest.firstRun = true;
    }
    @isTest(SeeAllData=true)
    public static void insertCommentOnCase() { 
        Entitlement  demoEntitlement               = [Select id from Entitlement where Name = 'Marketo Demo 17 Internal'];
        List<Contact> tempContact                  = [Select Id, AccountId From Contact where Customer_Portal_User__c = true and Is_Authorized_Contact__c = 'Yes' Limit 1];
        List<User> testUser = [Select Id from User Where IsActive = true Limit 1];
        Case tempCase = new case(OwnerId = testUser[0].Id,ContactId = tempContact[0].Id, AccountId = tempContact[0].AccountId, subject='Test Case',description='asd',Priority='P3',Problem_Type__c='Community',Category__c='General Questions',Status = 'Awaiting Customer Input',EntitlementId = demoEntitlement.Id);        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;
        CaseComment tempCaseComment = new CaseComment(ParentId = tempCase.Id,IsPublished = true,CommentBody ='comment from console');
        insert tempCaseComment;
    }
    
    @isTest(SeeAllData=true)
    public static void updateCustomMilestone() { 
        Entitlement  demoEntitlement               = [Select id from Entitlement where Name = 'Marketo Demo 17 Internal'];
        System.Debug('demoEntitlement++++'+demoEntitlement);
        List<Contact> tempContact                  = [Select Id, AccountId From Contact where Customer_Portal_User__c = false and Is_Authorized_Contact__c = 'No' Limit 1];
        System.Debug('tempContact++++'+tempContact[0].Id);
        List<User> testUser = [Select Id from User Where IsActive = true Limit 1];
        Case tempCase = new Case(OwnerId = testUser[0].Id,ContactId = tempContact[0].Id, AccountId = tempContact[0].AccountId, subject='Test Case',description='asd',Problem_Type__c='Community',Category__c='General Questions',Priority='P3',Status = 'Working',EntitlementId = demoEntitlement.Id);        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;
        Case_Update_Milestones__c newCaseUpdateMilestone        = new Case_Update_Milestones__c();
        newCaseUpdateMilestone.Case__c                          = tempCase.Id;
        newCaseUpdateMilestone.Completed__c                     = false; 
        newCaseUpdateMilestone.AutoComplete__c                  = false;
        newCaseUpdateMilestone.Milestone_Type__c                = 'FirstResponse';
        insert newCaseUpdateMilestone;
        newCaseUpdateMilestone.Completed__c                     = true; 
        newCaseUpdateMilestone.AutoComplete__c                  = true;
        newCaseUpdateMilestone.Milestone_Type__c                = 'CaseUpdate';
        update newCaseUpdateMilestone;
    }
}