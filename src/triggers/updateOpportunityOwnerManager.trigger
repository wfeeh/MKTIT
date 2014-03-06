trigger updateOpportunityOwnerManager on Quote (after insert, before update) {
    if(Trigger.isInsert){
        Map<Id,Id> OpportunityManagerMap = new Map<Id,Id>();
        List<Quote> quoteList = new List<Quote>();
        quoteList = [select Id, Opportunity_Owner_Manager__c, Opportunity.Owner.ManagerId from Quote where id in :Trigger.newMap.keySet()];
        for(Quote quote :quoteList){
            OpportunityManagerMap.put(quote.Id, quote.Opportunity.Owner.ManagerId);
        }
        
        for(Quote quote :quoteList){
            if(OpportunityManagerMap.get(quote.Id) != null)
                quote.Opportunity_Owner_Manager__c = OpportunityManagerMap.get(quote.ID);
        }
        update quoteList;
    }
    
    if(Trigger.isUpdate){    
        Map<Id,Id> OpportunityManagerMap = new Map<Id,Id>();
        for(Quote quote :[select Id, Opportunity.Owner.ManagerId from Quote where id in :Trigger.newMap.keySet()]){
            OpportunityManagerMap.put(quote.Id, quote.Opportunity.Owner.ManagerId);
        }
        
        for(Quote quote :Trigger.new){
            if(OpportunityManagerMap.get(quote.Id) != null)
                quote.Opportunity_Owner_Manager__c = OpportunityManagerMap.get(quote.ID);
        }
    }    
}