@isTest
private class updateRenewalsOwnerOnAccountTriggerTest{

    static testMethod void testTrigger(){
        
        Account acc = new Account (Name = 'Test Account');
        insert acc;
        
        String recordTypeId = [select id from RecordType where Name = 'Trial' and SObjectType = 'Opportunity'].id;
        
        Opportunity opp = new Opportunity (AccountId = acc.id, Name = 'Test Opportunity', RecordTypeId = recordTypeId, 
                                            StageName = 'Discovery', Type = 'Renewal', CloseDate = System.Today());
        Test.StartTest();
        insert opp;
        Test.StopTest();
       // system.assert([select Renewals_Owner__c from Account where id = :acc.id].Renewals_Owner__c != null);
    }
}