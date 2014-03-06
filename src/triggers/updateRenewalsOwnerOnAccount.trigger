trigger updateRenewalsOwnerOnAccount on Opportunity (before insert, before update) {
    Set<Id> accountIds = new Set<Id>();
    for(Opportunity opp :Trigger.new){
        if(opp.AccountId != null && opp.Type == 'Renewal' && (opp.OwnerId != opp.Renewals_Owner_Id__c)){
            accountIds.add(opp.AccountId);
        }
    }
    
    List<Account> accountsToBeUpdated = new List<Account>();
    accountsToBeUpdated = [select id, Renewals_Owner__c from Account where id in :accountIds];
      
    for(Opportunity opp :Trigger.new){
        if(opp.AccountId != null && opp.Type == 'Renewal' && (opp.OwnerId != opp.Renewals_Owner_Id__c)){
            for(Account acc :accountsToBeUpdated){
                if(opp.AccountId == acc.Id){
                    acc.Renewals_Owner__c = opp.OwnerId;
                }                
            }           
        }        
    }
    
    try{    
        if(accountsToBeUpdated.size()>0){
            update accountsToBeUpdated;
        }
    }
    catch(exception e){
        for(Opportunity opp :Trigger.new){
            opp.addError(e.getMessage());
        } 
    }      
}