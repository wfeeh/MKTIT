trigger DTOHistoryTrigger on Deal_Transaction_Audit_Log__c (after update, before delete) {
    DTOController DTOCon = new DTOController();
    public Id DTORecordTypeId = [SELECT Id, Name, DeveloperName 
        FROM RecordType 
        WHERE sObjectType = 'Deal_Transaction_Audit_Log__c'
        AND DeveloperName = 'DTO'].Id;
    if(Trigger.isUpdate){
        List<Deal_Transaction_Audit_Log__c> oldDTOList = new List<Deal_Transaction_Audit_Log__c>();
        for(Deal_Transaction_Audit_Log__c DTO :Trigger.old){
            if(DTOCon.isDTOModified(DTO, Trigger.newMap.get(DTO.id)) && DTO.RecordTypeId == DTORecordTypeId){
                oldDTOList.add(DTO);
            }
        }
        
        DTOCon.createDTOHistoryRecords(oldDTOList);
    }
    
    if(Trigger.isDelete){
        List<Deal_Transaction_Audit_Log__c> deletedDTOList = new List<Deal_Transaction_Audit_Log__c>();
        Set<String> dtoIdSet = new Set<String>();
        for(Deal_Transaction_Audit_Log__c dto :Trigger.old){
            if(dto.RecordTypeId == DTORecordTypeId){
                deletedDTOList.add(dto);
                dtoIdSet.add(dto.id);
            }
        }
        DTOCon.createDTOHistoryRecordsForDelete(deletedDTOList, dtoIdSet);
    }     
}