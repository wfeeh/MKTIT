trigger clone_OpportunityBasedOnCriteria on Opportunity(after update) {

    List < opportunity > opp_List = new List < opportunity > ();
    Map<Id,Opportunity> TriggerNewMap_NewBusiness= new Map<Id,Opportunity>();
     Map<Id,Opportunity> TriggerNewMap_Renewal= new Map<Id,Opportunity>();
    string dealtypes = Label.Deal_types;
    for (Opportunity o: Trigger.new) {
        if (o.stagename =='Closed Won' && Trigger.oldmap.get(o.id).Stagename != o.stagename &&
            Trigger.oldmap.get(o.id).recordtypeID != o.recordtypeID && o.type == 'New Business') {

            TriggerNewMap_NewBusiness.put(o.id, o);



        }

        if (o.stagename =='Closed Won' && Trigger.oldmap.get(o.id).Stagename != o.stagename &&
            Trigger.oldmap.get(o.id).recordtypeID != o.recordtypeID && o.type == 'Renewal') {

            TriggerNewMap_Renewal.put(o.id, o);




        }

    }
    if (!TriggerNewMap_NewBusiness.keyset().Isempty()) {

        if (!updateOpportunityBasedOnCriteria.isFromTriggerCloneOppBasedonCriteria) {
            updateOpportunityBasedOnCriteria.isFromTriggerCloneOppBasedonCriteria = true;
            updateOpportunityBasedOnCriteria.updateOpportunity_NewBusiness(TriggerNewMap_NewBusiness);

        }


    }


    if (!TriggerNewMap_Renewal.keyset().IsEmpty()) {

        if (!updateOpportunityBasedOnCriteriaRenewal.isFromTriggerCloneOppBasedonCriteriaRenewal) {
            updateOpportunityBasedOnCriteriaRenewal.isFromTriggerCloneOppBasedonCriteriaRenewal = true;
            updateOpportunityBasedOnCriteriaRenewal.updateOpportunity_Renewal(TriggerNewMap_Renewal);

        }


    }

}