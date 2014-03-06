/*===========================================================================+

   DATE       DEVELOPER      DESCRIPTION
   ====       =========      ===========
05/08/2013  Pankaj Verma   A common trigger for Entitlement Object 
                           

+===========================================================================*/
trigger ClearSubscriptionEndDate on Entitlement(before update,before insert) {

if (Trigger.isBefore && Trigger.isInsert) {
         for (Entitlement entl_obj: Trigger.New){
            entl_obj.Subscription_End_Date__c=entl_obj.EndDate;
            //entl_obj.Processed_For_grace__c=false;

            

        }

    }
        
        if (Trigger.isBefore && Trigger.isUpdate) {

            for (Entitlement entl_obj: Trigger.New) {

                
                if (entl_obj.Processed_For_grace__c  == TRUE )
                {
                    trigger.NewMap.get(entl_obj.Id).Subscription_End_Date__c=trigger.OldMap.get(entl_obj.Id).Enddate;  
                                        
                } 
                else 
                {
                    entl_obj.Subscription_End_Date__c=entl_obj.EndDate;
                }
               // entl_obj.Processed_For_grace__c  =False;
                //renewal scenario
                     if(trigger.OldMap.get(entl_obj.Id).Processed_For_grace__c  ==TRUE){
                     if(entl_obj.Enddate!=trigger.OldMap.get(entl_obj.Id).Enddate){
                     
                         entl_obj.Processed_For_grace__c  =FALSE;
                         entl_obj.Subscription_End_Date__c=entl_obj.EndDate;
                     
                         }
                     
                     } 
              
             }

    }    
}