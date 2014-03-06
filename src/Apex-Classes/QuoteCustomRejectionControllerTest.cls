@istest
public class QuoteCustomRejectionControllerTest{
     static testmethod void mytest(){
         Account TestAcc1 = new Account(Name='Test Account');
         insert TestAcc1;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
         insert opp;
         
         Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id);
         insert quote;

         ApexPages.CurrentPage().getParameters().put('quoteid',quote.id);
         Test.StartTest();
         QuoteCustomRejectionController qc = new QuoteCustomRejectionController();
         PageReference pf = qc.rejectRequest();
         Test.StopTest();
     }
}