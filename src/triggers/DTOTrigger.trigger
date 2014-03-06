trigger DTOTrigger on Opportunity (after update, before delete) {
    DTOController DTOCon = new DTOController();
    
    //**** Update Opportunity to Create DTO****
    if(Trigger.isUpdate){
        if(DTOController.isTriggerExecuted == FALSE){
            set<Id> opportunitIds = new Set<Id>();
            
            for(Opportunity opp :Trigger.new){
                if(opp.Type == 'New Business' && opp.StageName != Trigger.oldMap.get(opp.id).StageName && opp.StageName == 'Closed Won'){
                    opportunitIds.add(opp.Id);
                }
            }
            
            Set<Id> salesOrderIds = new Set<Id>();
            for(Sales_Order__c so :[SELECT id from Sales_Order__c WHERE Opportunity__c in :opportunitIds]){
                salesOrderIds.add(so.id);
            }
            
            Set<Id> OppLineItemIds = new Set<Id>();
            for(Sales_Order_Item__c soi :[SELECT id, Opp_Product_id__c from Sales_Order_Item__c WHERE Sales_Order__c in :salesOrderIds]){
                if(soi.Opp_Product_id__c != null && soi.Opp_Product_id__c != '')
                    OppLineItemIds.add(soi.Opp_Product_id__c);
            }
            
            if(OppLineItemIds.size() > 0){
                DTOCon.upsertDTORecords(OppLineItemIds);
            }  
        }
    }
    
    
    //**** Update Opportunity to Delete DTO ****
    if(Trigger.isUpdate){
        Set<Id> oppIdSetForDel = new Set<Id>();
        for(Opportunity opp :Trigger.new){
            if(opp.Type == 'New Business' && opp.StageName != Trigger.oldMap.get(opp.id).StageName && Trigger.oldMap.get(opp.id).StageName == 'Closed Won'){
                oppIdSetForDel.add(opp.Id);
            }    
        }
        
        Set<Id> oppLineItemIdSetforDel = new Set<Id>();
        for(OpportunityLineItem oppLineItem :[Select Id from OpportunityLineItem where OpportunityId in :oppIdSetForDel]){
            oppLineItemIdSetforDel.add(oppLineItem.Id);
        }
        
        if(oppLineItemIdSetforDel.size() > 0){
            DTOCon.deleteDTORecords(oppLineItemIdSetforDel);
        }
    } 
    
    
    // **** Opportunity is Deleted, Need to Delete DTO ****
    if(Trigger.isDelete){
        Set<Id> oppIdSetForDel = new Set<Id>();
        for(Opportunity opp :Trigger.old){
            if(opp.Type == 'New Business' && opp.StageName == 'Closed Won'){
                oppIdSetForDel.add(opp.Id);
            }
        }
        
        Set<Id> oppLineItemIdSetforDel = new Set<Id>();
        for(OpportunityLineItem oppLineItem :[Select Id from OpportunityLineItem where OpportunityId in :oppIdSetForDel]){
            oppLineItemIdSetforDel.add(oppLineItem.Id);
        }
        
        if(oppLineItemIdSetforDel.size() > 0){
            DTOCon.deleteDTORecords(oppLineItemIdSetforDel);
        }
    } 
}