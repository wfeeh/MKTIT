global class entitlementSubscriptionGrace implements Schedulable{
   global void execute(SchedulableContext SC) {    
     List<Entitlement> entitle = [SELECT Id,Processed_for_grace__c,Subscription_End_Date__c, EndDate FROM Entitlement WHERE EndDate = TOMORROW];
     if(entitle.size() == 0) return;
     for (Entitlement entitleGrace : entitle ){  
     if(entitleGrace.Processed_for_grace__c==false){  
         entitleGrace.Subscription_End_Date__c = entitleGrace.EndDate;
         entitleGrace.EndDate                  = entitleGrace.EndDate.addDays(60);
         entitleGrace.Processed_for_grace__c=true;
         }
     }
     update entitle;
  }
}


/*global class entitlementSubscriptionGrace implements Schedulable{
   global void execute(SchedulableContext SC) {    
     List<Entitlement> entitle = [SELECT Id, EndDate FROM Entitlement WHERE EndDate = TOMORROW AND Subscription_End_Date__c = NULL];
     if(entitle.size() == 0) return;
     for (Entitlement entitleGrace : entitle ){         
         entitleGrace.Subscription_End_Date__c = entitleGrace.EndDate;
         entitleGrace.EndDate                  = entitleGrace.EndDate.addDays(60);
     }
     update entitle;
  }
}*/