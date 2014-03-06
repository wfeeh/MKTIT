trigger DTOTriggerLineItem on OpportunityLineItem (after insert, after update, before delete) {
    DTOController DTOCon = new DTOController();
    if(Trigger.isInsert || Trigger.isUpdate){
        if(DTOController.isTriggerExecuted == FALSE){
            
            Set<Id> modifiedLineItemIdSet = new Set<Id>();
            for(OpportunityLineItem oppLineItem :Trigger.new){
                if(Trigger.isInsert){
                    modifiedLineItemIdSet.add(oppLineItem.Id);
                }
                if(Trigger.isUpdate && DTOCon.isLineItemModified(Trigger.oldMap.get(oppLineItem.Id), oppLineItem)){
                    modifiedLineItemIdSet.add(oppLineItem.Id);
                } 
            }
        
            Set<Id> oppLineItemIds = new Set<Id>();
            Set<Id> oppIdSet = new Set<Id>();
            for(OpportunityLineItem oppLineItem :[SELECT Id, OpportunityId FROM OpportunityLineItem WHERE Id in :modifiedLineItemIdSet 
            AND Opportunity.StageName = 'Closed Won' AND Opportunity.Type = 'New Business']){
                oppLineItemIds.add(oppLineItem.Id);
                oppIdSet.add(oppLineItem.OpportunityId);
            }
            
            Set<Id> salesOrderIds = new Set<Id>();
            for(Sales_Order__c so :[SELECT id from Sales_Order__c WHERE Opportunity__c in :oppIdSet]){
                salesOrderIds.add(so.id);
            }
            
            Set<Id> OppLineItemsUpdated = new Set<Id>();
            for(Sales_Order_Item__c soi :[SELECT id, Opp_Product_id__c from Sales_Order_Item__c 
            WHERE Sales_Order__c in :salesOrderIds AND Opp_Product_id__c in :oppLineItemIds]){
                if(soi.Opp_Product_id__c != null && soi.Opp_Product_id__c != '')
                    OppLineItemsUpdated.add(soi.Opp_Product_id__c);
            }
                
            if(OppLineItemsUpdated.size() > 0){
                DTOCon.upsertDTORecords(OppLineItemsUpdated);
            }
        }   
    }
    
    if(Trigger.isDelete){
        Set<Id> oppLineItemIdsForDelete = new Set<Id>();
        for(OpportunityLineItem oppLineItem :[SELECT Id FROM OpportunityLineItem WHERE Id in :Trigger.oldMap.keySet()
        AND Opportunity.StageName = 'Closed Won' AND Opportunity.Type = 'New Business']){
            oppLineItemIdsForDelete.add(oppLineItem.Id);
        }
        
        if(oppLineItemIdsForDelete.size() > 0){
            DTOCon.deleteDTORecords(oppLineItemIdsForDelete);
        }
    }     
}