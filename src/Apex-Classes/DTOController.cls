public class DTOController{
    public static boolean isTriggerExecuted = FALSE;
    public Id DTORecordTypeId;
    public Id DTOHistoryRecordTypeId;
    
    public DTOController(){
        for(RecordType rt :[SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType = 'Deal_Transaction_Audit_Log__c']){
            if(rt.DeveloperName == 'DTO'){
                DTORecordTypeId = rt.Id;
            }
            else
            if(rt.DeveloperName == 'DTO_History'){
                DTOHistoryRecordTypeId = rt.Id;
            }
        }
    }
    
    // **** Upsert DTO Records ****
    public void upsertDTORecords(Set<Id> oppLineItemIds){
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        oppLineItemList = getOpportunityLineItems(oppLineItemIds);
        
        Map<Id, Deal_Transaction_Audit_Log__c> opportunityTransactionMapExisting = new Map<Id, Deal_Transaction_Audit_Log__c>();
        opportunityTransactionMapExisting = getExistingOppTransactionRecords(oppLineItemIds);
        
        Map<Id, Deal_Transaction__c> dealTransactionMapExisting = new Map<Id, Deal_Transaction__c>();
        dealTransactionMapExisting = getExistingDealTransactionRecords(oppLineItemIds);
        
        List<Deal_Transaction_Audit_Log__c> opportunityTransactionListToUpsert = new List<Deal_Transaction_Audit_Log__c>();
        
        List<Deal_Transaction__c> dealTransactionListToUpsert = new List<Deal_Transaction__c>();
        
        for(OpportunityLineItem oppLineItem :oppLineItemList){
            String DTOUniqueId = oppLineItem.OpportunityId + '_' + oppLineItem.Id + '_' + 
                oppLineItem.Prior_Opportunity_Id__c + '_' + oppLineItem.OLI_ID__c;
                
            Deal_Transaction_Audit_Log__c opportunityTransaction = new Deal_Transaction_Audit_Log__c(
                RecordTypeId = DTORecordTypeId,
                Opportunity_Line_Item_Id__c = oppLineItem.id,
                Account__c = oppLineItem.Opportunity.AccountId,
                Opportunity__c = oppLineItem.OpportunityId,
                Opportunity_Type__c = oppLineItem.Opportunity.Type,
                Purchased_ARR__c = oppLineItem.ARR__c, 
                Purchased_Close_Date__c = oppLineItem.Opportunity.CloseDate, 
                Purchased_Database_Size__c = oppLineItem.Opportunity.Contact_Database_Size__c, 
                Purchased_Discount__c = oppLineItem.Discount, 
                Purchased_Edition__c = oppLineItem.Product_Edition__c, 
                Purchased_End_Date__c = oppLineItem.ServiceEndDate__c, 
                Purchased_List_Price__c = oppLineItem.ListPrice, 
                Purchased_Product__c = oppLineItem.PricebookEntry.Product2Id, 
                Purchased_Quantity__c = oppLineItem.Quantity, 
                Purchased_Sales_Price__c = oppLineItem.UnitPrice, 
                Purchased_Start_Date__c = oppLineItem.Product_Start_Date__c, 
                Purchased_Term__c = oppLineItem.Months__c, 
                Purchased_Total_Price__c = oppLineItem.TotalPrice, 
                Purchased_Users__c = oppLineItem.Users__c, 
                Upgrade_Sub_Type__c = oppLineItem.Upgrade_Type__c,
                DTO_Unique_Id__c = DTOUniqueId,
                Effective_Start_Date__c = System.Now(),
                Effective_End_Date__c = datetime.newInstance(2099, 12, 31)
            );
            
            Deal_Transaction__c dealTransaction = new Deal_Transaction__c(
                Opportunity_Line_Item_Id__c = oppLineItem.id,
                Account__c = oppLineItem.Opportunity.AccountId,
                Opportunity__c = oppLineItem.OpportunityId,
                Opportunity_Type__c = oppLineItem.Opportunity.Type,
                Purchased_ARR__c = oppLineItem.ARR__c, 
                Purchased_Close_Date__c = oppLineItem.Opportunity.CloseDate, 
                Purchased_Database_Size__c = oppLineItem.Opportunity.Contact_Database_Size__c, 
                Purchased_Discount__c = oppLineItem.Discount, 
                Purchased_Edition__c = oppLineItem.Product_Edition__c, 
                Purchased_End_Date__c = oppLineItem.ServiceEndDate__c, 
                Purchased_List_Price__c = oppLineItem.ListPrice, 
                Purchased_Product__c = oppLineItem.PricebookEntry.Product2Id, 
                Purchased_Quantity__c = oppLineItem.Quantity, 
                Purchased_Sales_Price__c = oppLineItem.UnitPrice, 
                Purchased_Start_Date__c = oppLineItem.Product_Start_Date__c, 
                Purchased_Term__c = oppLineItem.Months__c, 
                Purchased_Total_Price__c = oppLineItem.TotalPrice, 
                Purchased_Users__c = oppLineItem.Users__c, 
                Upgrade_Sub_Type__c = oppLineItem.Upgrade_Type__c,
                DTO_Unique_Id__c = DTOUniqueId
            );
            
            if(opportunityTransactionMapExisting.get(oppLineItem.Id) != null){
                opportunityTransaction.Id = opportunityTransactionMapExisting.get(oppLineItem.Id).Id;
            }
            
            if(dealTransactionMapExisting.get(oppLineItem.Id) != null){
                dealTransaction.Id = dealTransactionMapExisting.get(oppLineItem.Id).Id;
            }
            
            opportunityTransactionListToUpsert.add(opportunityTransaction);
            
            dealTransactionListToUpsert.add(dealTransaction);
        }
        if(opportunityTransactionListToUpsert.size() > 0 || dealTransactionListToUpsert.size() > 0){
            try{
                isTriggerExecuted = TRUE;
                upsert opportunityTransactionListToUpsert;
                upsert dealTransactionListToUpsert;
            }
            catch(exception e){
                for(OpportunityLineItem oppLineItem :oppLineItemList){
                    oppLineItem.addError(e.getMessage());
                }
            }    
        }    
    }
    
    
    // **** Get Opportunity Line Items ****
    public List<OpportunityLineItem> getOpportunityLineItems(Set<Id> oppLineItemIds){
        return [SELECT Id, OpportunityId, Opportunity.AccountId, Opportunity.Type, ARR__c, Opportunity.CloseDate, 
            Opportunity.Contact_Database_Size__c, Discount, Product_Edition__c, ServiceEndDate__c, ListPrice, 
            PricebookEntry.Product2Id, Quantity, UnitPrice, Product_Start_Date__c, Months__c, TotalPrice, 
            Users__c, Upgrade_Type__c, Prior_Opportunity_Id__c, OLI_ID__c
            FROM OpportunityLineItem 
            WHERE Id in :oppLineItemIds];
    }
    
    
    // **** Get Existing DTO Records ****
    public Map<Id, Deal_Transaction_Audit_Log__c> getExistingOppTransactionRecords(Set<Id> oppLineItemIds){
        Map<Id, Deal_Transaction_Audit_Log__c> existingOppTransRecMap = new Map<Id, Deal_Transaction_Audit_Log__c>();
        for(Deal_Transaction_Audit_Log__c oppTran :[SELECT Id, Name, Opportunity_Line_Item_Id__c 
        FROM Deal_Transaction_Audit_Log__c WHERE  Opportunity_Line_Item_Id__c in :oppLineItemIds AND RecordTypeId = :DTORecordTypeId]){
            if(existingOppTransRecMap.get(oppTran.Opportunity_Line_Item_Id__c) == null){
                existingOppTransRecMap.put(oppTran.Opportunity_Line_Item_Id__c, oppTran);
            }
        }
        return existingOppTransRecMap;
    }
    
    
     // **** Get Existing DTO Records ****
    public Map<Id, Deal_Transaction__c> getExistingDealTransactionRecords(Set<Id> oppLineItemIds){
        Map<Id, Deal_Transaction__c> existingDealTransRecMap = new Map<Id, Deal_Transaction__c>();
        for(Deal_Transaction__c dealTran :[SELECT Id, Name, Opportunity_Line_Item_Id__c 
        FROM Deal_Transaction__c WHERE  Opportunity_Line_Item_Id__c in :oppLineItemIds]){
            if(existingDealTransRecMap.get(dealTran.Opportunity_Line_Item_Id__c) == null){
                existingDealTransRecMap.put(dealTran.Opportunity_Line_Item_Id__c, dealTran);
            }
        }
        return existingDealTransRecMap;
    }
    
    // **** Insert DTO History ****
    public void createDTOHistoryRecords(List<Deal_Transaction_Audit_Log__c> oppTransactionList){
        List<Deal_Transaction_Audit_Log__c> oppTransactionHistoryToInsert = new List<Deal_Transaction_Audit_Log__c>();
        for(Deal_Transaction_Audit_Log__c oppTran :oppTransactionList){
            Deal_Transaction_Audit_Log__c oppTranHist = new Deal_Transaction_Audit_Log__c(
                RecordTypeId = DTOHistoryRecordTypeId,
                Active__c = oppTran.Active__c,
                Account__c = oppTran.Account__c,
                Opportunity__c = oppTran.Opportunity__c,
                Opportunity_Type__c = oppTran.Opportunity_Type__c,
                Previous_ARR__c = oppTran.Previous_ARR__c,
                Opportunity_Line_Item_Id__c = oppTran.Opportunity_Line_Item_Id__c,
                Previous_Close_Date__c = oppTran.Previous_Close_Date__c,
                Previous_Database_Size__c = oppTran.Previous_Database_Size__c,
                Previous_Discount__c = oppTran.Previous_Discount__c,
                Previous_Edition__c = oppTran.Previous_Edition__c,
                Previous_End_Date__c = oppTran.Previous_End_Date__c,
                Previous_List_Price__c = oppTran.Previous_List_Price__c,
                Previous_Quantity__c = oppTran.Previous_Quantity__c,
                Previous_Sales_Price__c = oppTran.Previous_Sales_Price__c,
                Previous_Start_Date__c = oppTran.Previous_Start_Date__c,
                Previous_Term__c = oppTran.Previous_Term__c,
                Previous_Total_Price__c = oppTran.Previous_Total_Price__c,
                Previous_Users__c = oppTran.Previous_Users__c,
                Purchased_ARR__c = oppTran.Purchased_ARR__c,
                Purchased_Close_Date__c = oppTran.Purchased_Close_Date__c,
                Purchased_Database_Size__c = oppTran.Purchased_Database_Size__c,
                Purchased_Discount__c = oppTran.Purchased_Discount__c,
                Purchased_Edition__c = oppTran.Purchased_Edition__c,
                Purchased_End_Date__c = oppTran.Purchased_End_Date__c,
                Purchased_List_Price__c = oppTran.Purchased_List_Price__c,
                Purchased_Quantity__c = oppTran.Purchased_Quantity__c,
                Purchased_Sales_Price__c = oppTran.Purchased_Sales_Price__c,
                Purchased_Start_Date__c = oppTran.Purchased_Start_Date__c,
                Purchased_Term__c = oppTran.Purchased_Term__c,
                Purchased_Total_Price__c = oppTran.Purchased_Total_Price__c,
                Purchased_Users__c = oppTran.Purchased_Users__c,
                Support_Type__c = oppTran.Support_Type__c,
                Technical_Product__c = oppTran.Technical_Product__c,
                Transaction_Type__c = oppTran.Transaction_Type__c,
                Upgrade_Sub_Type__c = oppTran.Upgrade_Sub_Type__c,
                DTO_Unique_Id__c = oppTran.DTO_Unique_Id__c,
                Previous_Product__c = oppTran.Previous_Product__c,
                Purchased_Product__c = oppTran.Purchased_Product__c,
                Parent_DTO_Id__c = oppTran.Id,
                Effective_Start_Date__c = oppTran.Effective_Start_Date__c,
                Effective_End_Date__c = System.Now()
            );
            
            oppTransactionHistoryToInsert.add(oppTranHist);
        }
        if(oppTransactionHistoryToInsert.size() > 0){
            try{
                insert oppTransactionHistoryToInsert;
            }
            catch(exception e){
                for(Deal_Transaction_Audit_Log__c oppTran :oppTransactionList){
                    oppTran.addError(e.getMessage());
                }
            }    
        }
    }
    
    
    // **** Check if DTO is Modified ****
    public boolean isDTOModified(Deal_Transaction_Audit_Log__c oldDTO, Deal_Transaction_Audit_Log__c newDTO){
        boolean isModified = FALSE;
        if(
            oldDTO.Opportunity_Type__c != newDTO.Opportunity_Type__c || 
            oldDTO.Previous_ARR__c != newDTO.Previous_ARR__c || 
            oldDTO.Previous_Close_Date__c != newDTO.Previous_Close_Date__c || 
            oldDTO.Previous_Database_Size__c != newDTO.Previous_Database_Size__c || 
            oldDTO.Previous_Discount__c != newDTO.Previous_Discount__c || 
            oldDTO.Previous_Edition__c != newDTO.Previous_Edition__c || 
            oldDTO.Previous_End_Date__c != newDTO.Previous_End_Date__c || 
            oldDTO.Previous_List_Price__c != newDTO.Previous_List_Price__c || 
            oldDTO.Previous_Quantity__c != newDTO.Previous_Quantity__c || 
            oldDTO.Previous_Sales_Price__c != newDTO.Previous_Sales_Price__c || 
            oldDTO.Previous_Start_Date__c != newDTO.Previous_Start_Date__c || 
            oldDTO.Previous_Term__c != newDTO.Previous_Term__c || 
            oldDTO.Previous_Total_Price__c != newDTO.Previous_Total_Price__c || 
            oldDTO.Previous_Users__c != newDTO.Previous_Users__c || 
            oldDTO.Purchased_ARR__c != newDTO.Purchased_ARR__c || 
            oldDTO.Purchased_Close_Date__c != newDTO.Purchased_Close_Date__c || 
            oldDTO.Purchased_Database_Size__c != newDTO.Purchased_Database_Size__c || 
            oldDTO.Purchased_Discount__c != newDTO.Purchased_Discount__c || 
            oldDTO.Purchased_Edition__c != newDTO.Purchased_Edition__c || 
            oldDTO.Purchased_End_Date__c != newDTO.Purchased_End_Date__c || 
            oldDTO.Purchased_List_Price__c != newDTO.Purchased_List_Price__c || 
            oldDTO.Purchased_Quantity__c != newDTO.Purchased_Quantity__c || 
            oldDTO.Purchased_Sales_Price__c != newDTO.Purchased_Sales_Price__c || 
            oldDTO.Purchased_Start_Date__c != newDTO.Purchased_Start_Date__c || 
            oldDTO.Purchased_Term__c != newDTO.Purchased_Term__c || 
            oldDTO.Purchased_Total_Price__c != newDTO.Purchased_Total_Price__c || 
            oldDTO.Purchased_Users__c != newDTO.Purchased_Users__c || 
            oldDTO.Support_Type__c != newDTO.Support_Type__c || 
            oldDTO.Technical_Product__c != newDTO.Technical_Product__c || 
            oldDTO.Transaction_Type__c != newDTO.Transaction_Type__c || 
            oldDTO.Upgrade_Sub_Type__c != newDTO.Upgrade_Sub_Type__c ||  
            oldDTO.Previous_Product__c != newDTO.Previous_Product__c || 
            oldDTO.Purchased_Product__c != newDTO.Purchased_Product__c
        ){
            isModified = TRUE;
        }    
        return isModified;
    }
    
    
    //**** Check if Line Item is Modified ****
    public boolean isLineItemModified(OpportunityLineItem oldLineItem, OpportunityLineItem newLineItem){
        boolean isModified = FALSE;
        if(
            oldLineItem.ARR__c   != newLineItem.ARR__c   || 
            oldLineItem.Discount != newLineItem.Discount || 
            oldLineItem.Product_Edition__c  != newLineItem.Product_Edition__c  || 
            oldLineItem.ServiceEndDate__c != newLineItem.ServiceEndDate__c || 
            oldLineItem.ListPrice   != newLineItem.ListPrice   || 
            oldLineItem.Quantity  != newLineItem.Quantity  || 
            oldLineItem.UnitPrice  != newLineItem.UnitPrice  || 
            oldLineItem.Product_Start_Date__c  != newLineItem.Product_Start_Date__c  || 
            oldLineItem.Months__c != newLineItem.Months__c || 
            oldLineItem.TotalPrice  != newLineItem.TotalPrice  || 
            oldLineItem.Users__c  != newLineItem.Users__c  || 
            oldLineItem.Upgrade_Type__c != newLineItem.Upgrade_Type__c
        ){
            isModified = TRUE;
        }
        return isModified;
    }
    
    
    // **** Delete DTO Records ****
    public void deleteDTORecords(Set<Id> oppLineItemIdSet){
        List<Deal_Transaction_Audit_Log__c> DTOList = new List<Deal_Transaction_Audit_Log__c>();
        DTOList = getDTOList(oppLineItemIdSet);
        
        List<Deal_Transaction__c> dealTranList = new List<Deal_Transaction__c>();
        dealTranList = [SELECT Id from Deal_Transaction__c WHERE Opportunity_Line_Item_Id__c in :oppLineItemIdSet];
        
        if(DTOList.size() > 0){
            try{
                delete DTOList;
                delete dealTranList;
            }
            catch(exception e){
                for(Deal_Transaction_Audit_Log__c dto :DTOList){
                    dto.addError(e.getMessage());
                }
            }    
        }
    }
    
    
    // **** Get DTO List ****
    public List<Deal_Transaction_Audit_Log__c> getDTOList(Set<Id> oppLineItemIdSet){
        return [SELECT id, Active__c, Account__c, Opportunity__c, Opportunity_Type__c, 
            Previous_ARR__c, Previous_Close_Date__c, Previous_Database_Size__c, Previous_Discount__c, 
            Previous_Edition__c, Previous_End_Date__c, Previous_List_Price__c, Previous_Quantity__c, 
            Previous_Sales_Price__c, Previous_Start_Date__c, Previous_Term__c, 
            Previous_Total_Price__c, Previous_Users__c, Purchased_ARR__c, 
            Purchased_Close_Date__c, Purchased_Database_Size__c, Purchased_Discount__c, Purchased_Edition__c, 
            Purchased_End_Date__c, Purchased_List_Price__c, Purchased_Quantity__c, Purchased_Sales_Price__c, 
            Purchased_Start_Date__c, Purchased_Term__c, Purchased_Total_Price__c, Purchased_Users__c, 
            Support_Type__c, Technical_Product__c, Transaction_Type__c, Upgrade_Sub_Type__c, DTO_Unique_Id__c, 
            Previous_Product__c, Purchased_Product__c 
            FROM Deal_Transaction_Audit_Log__c 
            WHERE Opportunity_Line_Item_Id__c in :oppLineItemIdSet
            AND RecordTypeId = :DTORecordTypeId];
    }
    
    
    // **** Insert DTO History when DTO is Deleted ****
    public void createDTOHistoryRecordsForDelete(List<Deal_Transaction_Audit_Log__c> oppTransactionList, Set<String> dtoIdSet){
        List<Deal_Transaction_Audit_Log__c> oppTransactionHistoryToUpsert = new List<Deal_Transaction_Audit_Log__c>();
        
        for(Deal_Transaction_Audit_Log__c oppTranHist :[Select Id, Is_DTO_Deleted__c 
        FROM Deal_Transaction_Audit_Log__c WHERE Parent_DTO_Id__c in :dtoIdSet AND RecordTypeId = :DTOHistoryRecordTypeId]){
            oppTranHist.Is_DTO_Deleted__c = TRUE;
            oppTransactionHistoryToUpsert.add(oppTranHist);
        }
        
        for(Deal_Transaction_Audit_Log__c oppTran :oppTransactionList){
            Deal_Transaction_Audit_Log__c oppTranHist = new Deal_Transaction_Audit_Log__c(
                RecordTypeId = DTOHistoryRecordTypeId,
                Active__c = oppTran.Active__c,
                Account__c = oppTran.Account__c,
                Opportunity__c = oppTran.Opportunity__c,
                Opportunity_Type__c = oppTran.Opportunity_Type__c,
                Previous_ARR__c = oppTran.Previous_ARR__c,
                Opportunity_Line_Item_Id__c = oppTran.Opportunity_Line_Item_Id__c,
                Previous_Close_Date__c = oppTran.Previous_Close_Date__c,
                Previous_Database_Size__c = oppTran.Previous_Database_Size__c,
                Previous_Discount__c = oppTran.Previous_Discount__c,
                Previous_Edition__c = oppTran.Previous_Edition__c,
                Previous_End_Date__c = oppTran.Previous_End_Date__c,
                Previous_List_Price__c = oppTran.Previous_List_Price__c,
                Previous_Quantity__c = oppTran.Previous_Quantity__c,
                Previous_Sales_Price__c = oppTran.Previous_Sales_Price__c,
                Previous_Start_Date__c = oppTran.Previous_Start_Date__c,
                Previous_Term__c = oppTran.Previous_Term__c,
                Previous_Total_Price__c = oppTran.Previous_Total_Price__c,
                Previous_Users__c = oppTran.Previous_Users__c,
                Purchased_ARR__c = oppTran.Purchased_ARR__c,
                Purchased_Close_Date__c = oppTran.Purchased_Close_Date__c,
                Purchased_Database_Size__c = oppTran.Purchased_Database_Size__c,
                Purchased_Discount__c = oppTran.Purchased_Discount__c,
                Purchased_Edition__c = oppTran.Purchased_Edition__c,
                Purchased_End_Date__c = oppTran.Purchased_End_Date__c,
                Purchased_List_Price__c = oppTran.Purchased_List_Price__c,
                Purchased_Quantity__c = oppTran.Purchased_Quantity__c,
                Purchased_Sales_Price__c = oppTran.Purchased_Sales_Price__c,
                Purchased_Start_Date__c = oppTran.Purchased_Start_Date__c,
                Purchased_Term__c = oppTran.Purchased_Term__c,
                Purchased_Total_Price__c = oppTran.Purchased_Total_Price__c,
                Purchased_Users__c = oppTran.Purchased_Users__c,
                Support_Type__c = oppTran.Support_Type__c,
                Technical_Product__c = oppTran.Technical_Product__c,
                Transaction_Type__c = oppTran.Transaction_Type__c,
                Upgrade_Sub_Type__c = oppTran.Upgrade_Sub_Type__c,
                DTO_Unique_Id__c = oppTran.DTO_Unique_Id__c,
                Previous_Product__c = oppTran.Previous_Product__c,
                Purchased_Product__c = oppTran.Purchased_Product__c,
                Parent_DTO_Id__c = oppTran.Id,
                Effective_Start_Date__c = oppTran.Effective_Start_Date__c,
                Effective_End_Date__c = System.Now(),
                Is_DTO_Deleted__c = TRUE
            );
            
            oppTransactionHistoryToUpsert.add(oppTranHist);
        }
        if(oppTransactionHistoryToUpsert.size() > 0){
            try{
                upsert oppTransactionHistoryToUpsert;
            }
            catch(exception e){
                for(Deal_Transaction_Audit_Log__c oppTran :oppTransactionList){
                    oppTran.addError(e.getMessage());
                }
            }    
        }
    }
}