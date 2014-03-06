@istest
public class QuoteCustomApprovalControllerTest{
     static testmethod void mytest(){
         Account TestAcc1 = new Account(Name='Test Account');
         insert TestAcc1;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
         insert opp;
         
         Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id);
         insert quote;
         
         ApexPages.StandardController con = new ApexPages.StandardController(quote);
         ApexPages.CurrentPage().getParameters().put('id',quote.id);
         Test.StartTest();
         QuoteCustomApprovalController qc = new QuoteCustomApprovalController(con);
         qc.updateApprovalStatus();
         Test.StopTest();
     }
}