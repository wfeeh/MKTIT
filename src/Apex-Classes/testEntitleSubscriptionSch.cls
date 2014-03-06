@istest
class testEntitleSubscriptionSch {  

   static testmethod void test() {
   
      Account testAcc = new Account();
      testAcc.Name = 'test';
      insert testAcc;
      Entitlement testEntitle = new Entitlement();
      testEntitle.AccountId = testAcc.Id;
      testEntitle.Name = 'test';
      date myDate = date.today();
      testEntitle.StartDate = myDate ;
      testEntitle.EndDate = myDate.addDays(1) ;
      insert testEntitle;
      Test.startTest();      
        entitlementSubscriptionGrace obj_entitleGrace = new entitlementSubscriptionGrace();
        obj_entitleGrace.execute(null);
      Test.stopTest();      

   }
}