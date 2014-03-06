trigger OpportunityAutoProvisioning on Opportunity(before update) {

    // Instantiate class with list of inserted opportunities
    Integer count = 0;
    List < Opportunity > opp_of_interest = new List < Opportunity > ();
    system.debug('OpportunityAutoProvisioning.prerequisite_record_type_value' + OpportunityAutoProvisioning.prerequisite_record_type_value);

    system.debug('Initial :OpportunityAutoProvisioning.isFirstRun' + OpportunityAutoProvisioning.isFirstRun);

    if (OpportunityAutoProvisioning.isFirstRun == true) {
        OpportunityAutoProvisioning.isFirstRun = false;
        system.debug('After :OpportunityAutoProvisioning.isFirstRun' + OpportunityAutoProvisioning.isFirstRun);
        System.debug('debug_stm: walk through object list, numbers: ');
        // only onsider opportunities that are in OpportunityAutoProvisioning.prerequisite_record_type_value
        // List<Opportunity> opps = [ Select o.Id From Opportunity o  WHERE o.RecordType.Name = :OpportunityAutoProvisioning.prerequisite_record_type_value And o.Id in :trigger.oldMap.keySet() ];
        //List<Opportunity> opps = [ Select o.Id From Opportunity o  WHERE o.RecordType.Name = :OpportunityAutoProvisioning.prerequisite_record_type_value And o.Id in :trigger.newMap.keySet() ];
        List < RecordType > Rc = [Select id from RecordType WHERE sObjectType = 'Opportunity'
            and Name = : OpportunityAutoProvisioning.prerequisite_record_type_value limit 1
        ];

        // Changed code to accomdate the new process of opp closed won and stage done at teh same time.
        //for (Id id : trigger.oldMap.keySet()){
        if (trigger.isbefore && trigger.isUpdate) {
            
                for (Opportunity opp: trigger.new) {
                        if (opp.Processed__c != true) {
                    system.debug('opp.RecordTypeId' + opp.RecordTypeId);

                    system.debug('OpportunityAutoProvisioning.changed_state_value' + OpportunityAutoProvisioning.changed_state_value);

                    if (Rc.size() > 0 && opp.RecordTypeId == Rc[0].id && trigger.oldMap.get(opp.id).RecordTypeId != Rc[0].id) {
                        Id id = opp.Id;
                        // Opportunity new_obj = trigger.newMap.get(id);
                        // Opportunity old_obj = trigger.oldMap.get(id);
                        if (opp.stagename == OpportunityAutoProvisioning.changed_state_value && opp.Type == 'New Business')
                            opp_of_interest.add(opp);
                        opp.processed__c = true;
                        // System.debug('debug_stm: checking obj name: ' + old_obj.Name);
                        //System.debug('this is new Stagename '+new_obj.StageName);
                        /// System.debug('this is old Stagename '+old_obj.StageName);
                        // System.debug('this is class stage '+OpportunityAutoProvisioning.changed_state_value);

                        /*  if ((new_obj.StageName == OpportunityAutoProvisioning.changed_state_value) &&
                    (old_obj.StageName != OpportunityAutoProvisioning.changed_state_value)){
                        System.debug('debug_stm: selected obj name: ' + new_obj.Name);
                        opp_of_interest.add(new_obj);       
                }*/
                    }
                    system.debug('opp_of_interest' + opp_of_interest);
                    system.debug('opp_of_interest size' + opp_of_interest.size());
                }
            }
        }
        if (!opp_of_interest.isEmpty()) {
            OpportunityAutoProvisioning.processOpportunities(opp_of_interest);
        }
        //
    }
}