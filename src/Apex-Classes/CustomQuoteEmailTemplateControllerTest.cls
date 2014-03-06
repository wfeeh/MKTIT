@istest
public class CustomQuoteEmailTemplateControllerTest{
     static testmethod void mytest(){
         Account TestAcc1 = new Account(Name='Test Account');
         insert TestAcc1;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
         insert opp;
         
         Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id);
         insert quote;

         CustomQuoteEmailTemplateController cq = new CustomQuoteEmailTemplateController();
         cq.quote = quote;
         
         Apttus_Approval__Approval_Request__c aa = cq.getApprovalRequest();
         
         List<Apttus_Approval__Approval_Request__c> aaList = cq.getApprovalDetails();
     }
}