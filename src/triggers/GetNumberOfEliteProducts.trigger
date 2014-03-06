trigger GetNumberOfEliteProducts on Opportunity (before update) {
    List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
    oppLineItems = [select id, OpportunityId, PriceBookEntry.ProductCode from OpportunityLineItem where OpportunityId in :Trigger.newMap.keySet()];
    
    Map<String, List_of_Elite_Products__c> EliteProductsMap = List_of_Elite_Products__c.getAll();
    
    Map<Id, List<OpportunityLineItem>> lineItemMap = new Map<Id, List<OpportunityLineItem>>();
    
    for(OpportunityLineItem oppLineItem :oppLineItems){
        if(lineItemMap.get(oppLineItem.OpportunityId) != null){
            lineItemMap.get(oppLineItem.OpportunityId).add(oppLineItem);
        }
        else{
            List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
            oppLineItemList.add(oppLineItem);
            lineItemMap.put(oppLineItem.OpportunityId, oppLineItemList);
        }
    }
    
    for(Opportunity opp :Trigger.new){
        Integer numberOfEliteProds = 0;
        if(lineItemMap.get(opp.Id) != null){
            for(OpportunityLineItem oppLineItem :lineItemMap.get(opp.Id)){
                if(EliteProductsMap.get(oppLineItem.PriceBookEntry.ProductCode) != null){
                    numberOfEliteProds = numberOfEliteProds + 1;
                }
            }
        }    
        opp.Number_of_Elite_Products__c = numberOfEliteProds;
    }
}