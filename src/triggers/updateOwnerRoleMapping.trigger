trigger updateOwnerRoleMapping on Opportunity (before update) {
    for(Opportunity opp :Trigger.new){
        if(opp.IsClosed != Trigger.oldMap.get(opp.id).IsClosed && opp.IsClosed == TRUE){
            opp.Owner_Role_Mapping__c = opp.OwnerId;
        }
    }
}