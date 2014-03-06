trigger ApprovalRequestB4InsB4Upd on Apttus_Approval__Approval_Request__c  (before insert, before update) {
   for (Apttus_Approval__Approval_Request__c  ar : trigger.new){
      if (ar.Apttus_Approval__Object_Type__c == 'Quote'){
         ar.Related_Quote__c = ar.Apttus_Approval__Object_Id__c;
      }
   }
}