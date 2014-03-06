@istest
public class test_AssignNBAEPerRules
{
   static testmethod void mytest()
   {
      set <id> accids = new set <id>();
      AssignNBAEPerRules.ANFirstPass = True;
      map <id, account> accmap = new map <id, account>();

      Account acc=new Account(Name='test Account1',ownerid=UserInfo.getUserId());
      insert acc;
      accids.add(acc.id);
      Opportunity opp=new Opportunity(Name='test Opportunity1',AccountId=acc.id,type='New Business',
           CloseDate=date.today(),StageName='Closed Won',ownerid=UserInfo.getUserId());
      insert opp;

      List <account> acclist1 = [select id,type from account where id in :accids];
      for (Account acc1 : accList1){
         acc1.type = 'Customer';
      }

      AssignNBAEPerRules.ANFirstPass = False;
      update accList1;

      List <account> acclist2 = [select New_Business_Account_Executive__c from account where id in :accids];
      for (Account acc2 : accList2){
         system.assertequals(UserInfo.getUserId(),acc2.New_Business_Account_Executive__c);
      }
   }
}