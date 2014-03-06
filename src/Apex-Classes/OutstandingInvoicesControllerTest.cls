@istest
public class OutstandingInvoicesControllerTest{
    static testmethod void mytest(){
         Account TestAcc1 = new Account(Name='Test Account');
         insert TestAcc1;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', CloseDate=System.Today());
         insert opp;
         
         Date yestDay = System.Today() - 1;
         
         
         Sales_Invoice__c salesInvoice = new Sales_Invoice__c(Account__c = TestAcc1.Id, Payment_Due_Date__c = yestDay, Amount_Due__c = 100);
         insert salesInvoice;
         
         Sales_Invoice_Item__c salesInvoiceItem = new Sales_Invoice_Item__c(Name = 'Test Item', Sales_Invoice__c = salesInvoice.Id);
         insert salesInvoiceItem;
         
         Test.StartTest();
         ApexPages.StandardController con = new ApexPages.StandardController(TestAcc1);
         ApexPages.CurrentPage().getParameters().put('id',TestAcc1.id);
         OutstandingInvoicesController oic = new OutstandingInvoicesController(con);
         Test.StopTest();
    }     
}