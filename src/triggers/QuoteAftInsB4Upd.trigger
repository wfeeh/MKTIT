trigger QuoteAftInsB4Upd on Quote (after insert, after update) {
   List <RecordType> RtIDs = [SELECT Id FROM RecordType where sobjectType = 'Opportunity' and Name = 'Closed Won'];
   set <ID> oppIDs = new set<Id>();
   for (Quote q1 : trigger.new){
      oppIDs.add (q1.OpportunityID);
   }
   List <Opportunity> oppListToUpd = new List <Opportunity>();
   List <Opportunity> oppList = [select Owner_Role_Mapping__c, OwnerID from Opportunity where ID in :oppIDs and RecordTypeId not in : RtIDs and StageName <> 'Closed Lost'];
   for (Opportunity op1 : oppList){
      if (op1.Owner_Role_Mapping__c <> op1.OwnerID){
         op1.Owner_Role_Mapping__c = op1.OwnerID;
         oppListToUpd.add(op1);
      }
   }
   update oppListToUpd;
}