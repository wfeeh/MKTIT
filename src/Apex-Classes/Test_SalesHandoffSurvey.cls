@isTest(SeeAllData=true)
public class Test_SalesHandoffSurvey{
    
    static testMethod void testSaveSalesSurveyInClarizenProject() {
            Account acc= new account();
            acc.name='Test Account';
            acc.CurrencyIsoCode='USD';
            acc.Business_Unit__c = 'AMER - MM';
            insert acc;
            
            Opportunity opp = new opportunity();
            opp.Name='Test Name';
            opp.CRM_System__c='Microsoft CRM 2011';
            opp.AccountId=acc.id ;
            opp.CloseDate=Date.today();
            opp.stagename='Discovery';
            opp.Deal_Type__c='Services';
            opp.NextStep='abc';
            opp.Forecast_Category__c='Commit';
            opp.LeadSource='Additional User';
            opp.type='New Business';
            
            opp.Quarterly_Renewal__c='123';
            insert opp;
            
            clzV5__Clarizen_Project__c proj = new clzV5__Clarizen_Project__c();
            proj.Sales_Survey_Status__c = 'Sent';
            proj.Name = 'test clarizen';
            proj.clzV5__Opportunity__c = opp.Id;
            proj.clzV5__CLZ_Customer__c = acc.Id;
            insert proj;
            
            PageReference pageRef = Page.SalesHandoffSurvey;
            pageRef.getParameters().put('id', String.valueOf(proj.Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(proj);
            SaveSalesSurveyInClarizenProject survey = new SaveSalesSurveyInClarizenProject (sc);
            survey.save();
            Test.StartTest();
            SendReminderToOpportunityOwner reminder = new SendReminderToOpportunityOwner(String.valueOf(proj.Id));
            reminder.execute(null);
            Test.stopTest();
    }
    static testMethod void testSendReminderToOpportunityOwner() {
        Test.StartTest();
        SendReminderToOpportunityOwner reminder = new SendReminderToOpportunityOwner();
        reminder.execute(null);
        Test.stopTest();
    }
    
}