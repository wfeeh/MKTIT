@istest
public class test_AssignCSMPerRules{
   static testmethod void mytest(){
       List<UserRole> Ur = [SELECT id from UserRole where Name = 'Customer Success' limit 1];
      List<User> u =[SELECT id from User where UserRoleId =: Ur[0].id and isactive = true limit 1];
       
    
    Assignment_Rule__c arule1=new Assignment_Rule__c(Rule_Name__c = 'Account CSM Assignment', 
           Business_Unit__c='APAC - Channel', Country__c = 'CA', Country_Code__c = 'n/a',
           State__c = 'n/a', State_Code__c = 'NC', Zip5__c = 'n/a', User__c=u[0].Id, Type__c='Customer');
      insert arule1;   
       
       
    Account TestAcc1 = new Account(Name='Test Account', type='Customer');
    insert TestAcc1;
    
    Account TestAcc3 = new Account(Name='Test Account', type='prospect', Business_Unit__c = 'APAC - Channel');
    insert TestAcc3;
    
    TestAcc3.type= 'Customer';
    update TestAcc3;
   }
}