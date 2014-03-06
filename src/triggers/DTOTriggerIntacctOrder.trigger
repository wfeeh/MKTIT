trigger DTOTriggerIntacctOrder on Sales_Order__c (before delete) {
    Set<Id> oppLineItemIds = new Set<Id>();
    
    for(Sales_Order_Item__c soi :[SELECT Id, Opp_Product_id__c FROM Sales_Order_Item__c WHERE Sales_Order__c in :Trigger.oldMap.keySet()]){
        if(soi.Opp_Product_id__c != null && soi.Opp_Product_id__c != '')
            oppLineItemIds.add(soi.Opp_Product_id__c);
    }
    
    if(oppLineItemIds.size() > 0){
        DTOController DTOCon = new DTOController();
        DTOCon.deleteDTORecords(oppLineItemIds);
    }    
}