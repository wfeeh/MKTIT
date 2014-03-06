trigger accountB4InsertB4Update on Account (before insert, before update) {

   List<Id> AccNBAEIds = new List<Id>();
   List<Account> AccCSMUpdt = new List<Account>();
   Map<Id,Id> AcctCSMMap = new Map<Id,Id>();
   Map<Id,Id> AcctNBAEMap = new Map<Id,Id>();
   Integer i =0;
   for (Account a: trigger.new) {
      
      //NBAE Assignment Section
      if (a.type == 'Customer' || a.type == 'Customer of Reseller Partner' || a.type == 'Customer & Partner'){
         if (trigger.isupdate){
            if (trigger.old[i].type <> 'Customer' && trigger.old[i].type <> 'Customer of Reseller Partner' && 
            trigger.old[i].type <> 'Customer & Partner') {
               AccNBAEIds.add(a.id); //accounts for which New Business Account Executive needs to be updated
            }
         } else
         
         if (trigger.isinsert){
            AccNBAEIds.add(a.id); //accounts for which New Business Account Executive needs to be updated
         }
      }
      
      
      //CSM Assignment Section
      
      
      //CSM Assignment when an Account is Inserted
      if(Trigger.isInsert){
          if(a.type == 'Customer' || a.type == 'Customer of Reseller Partner' || a.type == 'Customer & Partner' || a.type == 'Customer of Agency'){
               AccCSMUpdt.add(a);
          }
      }    
      
      
      //CSM Assignment when an Account is Updated
      if(Trigger.isUpdate){
          if(a.type == 'Customer' || a.type == 'Customer of Reseller Partner' || a.type == 'Customer & Partner' || a.type == 'Customer of Agency'){
              
              //First Time Assignment
              if(trigger.old[i].type <> 'Customer' && trigger.old[i].type <> 'Customer of Reseller Partner' && 
              trigger.old[i].type <> 'Customer & Partner' && trigger.old[i].type <> 'Customer of Agency'){
                  if(a.Marketo_Elite__c == TRUE || a.Marketo_Key__c == TRUE){
                      AccCSMUpdt.add(a);
                  }
                  else
                  if(a.Marketo_Elite__c == FALSE && a.Marketo_Key__c == FALSE && a.Business_Unit__c.contains('SB') && 
                  (a.Temperature__c == 'Green' || a.Temperature__c == 'Unknown' || a.Temperature__c == 'Engaging' || a.Temperature__c == 'In Enablement' || a.Temperature__c == '' || a.Temperature__c == null)
                  ){
                      AccCSMUpdt.add(a);
                  }
                  else
                  if(a.Marketo_Elite__c == FALSE && a.Marketo_Key__c == FALSE && !a.Business_Unit__c.contains('SB')){
                      AccCSMUpdt.add(a);
                  }         
              }
              
              //Non Key AND Non Elite for SB and Temperature is Changed
              if(a.Marketo_Elite__c == FALSE && a.Marketo_Key__c == FALSE && a.Business_Unit__c.contains('SB') &&
              ((trigger.old[i].Temperature__c == 'Red' || trigger.old[i].Temperature__c == 'Yellow') && a.Temperature__c == 'Green')
              ){
                  AccCSMUpdt.add(a);
              }
              
              //CSM is Blank
              if(a.Customer_Success_Manager__c == null){
                  if(a.Marketo_Elite__c == TRUE || a.Marketo_Key__c == TRUE){
                      AccCSMUpdt.add(a);
                  }
                  else
                  if(a.Marketo_Elite__c == FALSE && a.Marketo_Key__c == FALSE && a.Business_Unit__c.contains('SB') && 
                  (a.Temperature__c == 'Green' || a.Temperature__c == 'Unknown' || a.Temperature__c == 'Engaging' || a.Temperature__c == 'In Enablement' || a.Temperature__c == '' || a.Temperature__c == null)
                  ){
                      AccCSMUpdt.add(a);
                  }
                  else
                  if(a.Marketo_Elite__c == FALSE && a.Marketo_Key__c == FALSE && !a.Business_Unit__c.contains('SB')){
                      AccCSMUpdt.add(a);
                  }
              }
              
          }
      }
      
      i++;
   }
   //********************************************** CSM Update BEGIN **********************************************//
   // If any, pass the list of accounts to the class and receive a map of Account-to-CSM ID
   // Check to ensure the Apex call is performed once per trigger execution
   if (!AssignCSMToAccountAsPerRule.ARFirstPass){
      if (AccCSMUpdt.size() > 0) {
         AcctCSMMap = AssignCSMToAccountAsPerRule.getAccountCSM(AccCSMUpdt);
      }
      AssignCSMToAccountAsPerRule.ARFirstPass = True;
   }
   // If a new CSM value is available, update CSM field in trigger.new
   integer x=0;
   for (Account a1: trigger.new){
      if (AcctCSMMap.get(a1.Id) <> null){
        a1.Customer_Success_Manager__c = AcctCSMMap.get(a1.Id);
      }
      
      x++;
   }
   //********************************************** CSM Update END **********************************************//


   //******************************************* New Business AE Update BEGIN *******************************************//
   // If any, pass the list of accounts Ids to the class and receive a map of Account-to-New Business Account Executive ID
   // Check to ensure the Apex call is performed once per trigger execution
   if (!AssignNBAEPerRules.ANFirstPass){
      if (AccNBAEIds.size() > 0) {
         AcctNBAEMap = AssignNBAEPerRules.getAccountNBAE(AccNBAEIds);
         AssignNBAEPerRules.ANFirstPass = True;
      }
   }
   // If a new NBAE value is available, update NBAE field in trigger.new
   for (Account a2: trigger.new){
      if (AcctNBAEMap.get(a2.Id) <> null){
        a2.New_Business_Account_Executive__c = AcctNBAEMap.get(a2.Id);
      }
   }
   //******************************************* New Business AE Update END *******************************************//
}