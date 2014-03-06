@istest
public class test_postToChatter
{
    static testmethod void mytest()
    {
     Account acc=new Account(Name='test Account',Type='Other',ownerid=UserInfo.getUserId() );
     insert acc;
     acc.Type = 'Customer';
     acc.customer_number__c = 12345;
     acc.Date_Became_a_Customer__c = date.today();
     update acc;

     Account acc1=new Account(Name='test Account',Type='Customer',ownerid=UserInfo.getUserId(),
        customer_number__c = 12345,Date_Became_a_Customer__c = date.today());
     insert acc1;
    }
}