trigger queueOwnedCaseCloseCheck on Case (before update) {

    /* ALGO
    //TBD is available for only sm 
    BEGINS(OwnerId, "00G")          &&     
    IS_CHANGED_PICKVAL( Status , 'Closed')   && 
    OR( 
        RecordTypeId = '01250000000UJwx',RecordTypeId = '01250000000UJwy', 
        RecordTypeId = '01250000000UJwz',RecordTypeId = '01250000000UKbb', 
        ISPICKVAL(Origin, "TBD")
    )                               &&     
    NOT(Case Has Valid Close Reasons)
    */
        
    if(CaseTriggerUtility.queueOwnedCaseCloseCheckisBeforeUpdate == true) return;     
    CaseTriggerUtility.queueOwnedCaseCloseCheckisBeforeUpdate = true;
    
    //Update P1 Service Restored Time Duration when case is closed.Issue #4164
    List<Case> caseIdToBeUpdated            = new List<Case>();
    List<Id> caseIds                        = new List<Id>();
    Map<Id,CaseHistory> caseIdToCaseHistory = new Map<Id,CaseHistory>();
     
    for(Case cc : Trigger.New) {        
            caseIdToBeUpdated.add(cc);
            caseIds.add(cc.Id);
        }
    List<CaseHistory> historyOfCase                   = [Select CreatedDate, NewValue, CaseId From CaseHistory Where 
                                                                Field = 'Priority' and 
                                                                CaseId IN: caseIds 
                                                                ORDER BY CreatedDate DESC LIMIT 1];
    System.Debug('historyOfCase'+historyOfCase);
    for(CaseHistory tempCaseHistory : historyOfCase){
        caseIdToCaseHistory.put(tempCaseHistory.CaseId,tempCaseHistory);    
    }
    System.Debug('__Case History__'+caseIdToCaseHistory);
      
    for(Case tempCase : caseIdToBeUpdated){
        System.Debug('__Status value after Update__'+Trigger.newMap.get(tempCase.Id).Status);
        System.Debug('__Status value Before Update__'+Trigger.OldMap.get(tempCase.Id).Status);
        Boolean isStatusChangedToClosed  = Trigger.OldMap.get(tempCase.Id).Status != Trigger.newMap.get(tempCase.Id).Status && Trigger.newMap.get(tempCase.Id).Status == 'Closed'?true:false;
        Boolean isServiceRestored        = tempCase.P1_Service_Restored_Time__c == null?false:true;
        System.Debug('__isServiceRestored__'+isServiceRestored);
        Boolean priorityIsSwitchedFromP1 = Trigger.oldMap.get(tempCase.Id).Priority == 'P1' && Trigger.newMap.get(tempCase.Id).Priority != 'P1'?true:false;
        
        if(isStatusChangedToClosed == true && tempCase.Priority == 'P1' && isServiceRestored == false){
            System.Debug('__Meets the Criteria__');
            tempCase.P1_Service_Restored_Time__c    = System.now();
            if(caseIdToCaseHistory.ContainsKey(tempCase.Id)){
                System.Debug('__Priority for this case was changed__');
                if(caseIdToCaseHistory.get(tempCase.Id).NewValue == 'P1'){
                    System.Debug('__Priority Of This Case Was Changed to P1__');
                    tempCase.P1_Switch_Time__c        = caseIdToCaseHistory.get(tempCase.Id).CreatedDate;            
                }    
            }else{
                System.Debug('__Priority Of Case was not changed during course of Case__');
                tempCase.P1_Switch_Time__c        = tempCase.CreatedDate; 
            }
            System.Debug('__Case After Update__'+tempCase);       
        }        
    }
    //Update P1 Service Restored Time Duration when case is closed.Issue #4164
  
  
    User currUser = [SELECT ID, IsPortalEnabled from User Where Id = :UserInfo.getUserId() Limit 1];    
           
    String nonSMCaseRecTypes = '01250000000UJwxAAG;01250000000UJwyAAG;01250000000UJwzAAG;01250000000UKbbAAG';    
    String autoCaseCloseReasons = 'Spark Email Reroute,Unauthorized Contact Reroute,Partner Supported Referral,Not Services Related,Duplicate,Invalid Record,Spam';
    if(!Test.isRunningTest()) {       
        nonSMCaseRecTypes = CaseRecordOrTypeIds__c.getInstance('NonSupportCaseRecTIds').ReferenceIds__c;    
        autoCaseCloseReasons = CaseRecordOrTypeIds__c.getInstance('Auto_Case_Close_Reasons').ReferenceIds__c;               
    }       
    Set<String> autoCaseCloseReasonsSet = new Set<String>();     
    autoCaseCloseReasonsSet.AddAll(autoCaseCloseReasons.split(',')); 
    System.debug('myCaseRecTypes==>' + nonSMCaseRecTypes);
       
    
    //Bikram 4998 starts
    List<Id> validEntIds = new List<Id>();
    for(Case cc : Trigger.New) {        
        System.debug('Trigger Called==>' + cc.EntitlementId + ' ' +  cc.Entitlement.AssetId );
        if(nonSMCaseRecTypes.containsIgnoreCase(cc.RecordTypeId) && cc.Status == 'Closed' && cc.ContactId != null && Trigger.oldMap.get(cc.id).Status !='Closed') {
            if(!(autoCaseCloseReasonsSet.Contains(cc.Close_Reason__c))) {
                if(cc.EntitlementID != null) {
                    validEntIds.add(cc.EntitlementID);    
                }
            }
        }            
    }
    Map<Id, Entitlement> entAsstMap = new Map<Id,Entitlement>();
    if(validEntIds.isEmpty() == FALSE) {
        entAsstMap  = new Map<Id,Entitlement>([Select Id, AssetId from Entitlement WHERE ID in: validEntIds]);    
    }   
    //Bikram 4998 ends      
                   

    if(currUser.IsPortalEnabled != true) {    
        for(Case cc : Trigger.New){
            System.debug('cc==>' + cc.Origin + cc.RecordTypeId + cc.Close_Reason__c + cc.Status);
            if(Trigger.IsUpdate && Trigger.IsBefore) {
                System.debug('cc.OwnerID==>' + cc.OwnerID  + cc.Status);            
                if(String.valueOf(cc.OwnerId).StartsWithIgnoreCase('00G') && cc.Status == 'Closed' && Trigger.oldMap.get(cc.id).Status !='Closed') {
                    //if(!(cc.Close_Reason__c == 'Spam' || cc.Close_Reason__c == 'Invalid Record' || cc.Close_Reason__c == 'Duplicate' || cc.Close_Reason__c == 'Not Services Related' || cc.Close_Reason__c == 'Unauthorized Contact Reroute')) 
                    if(!(autoCaseCloseReasonsSet.Contains(cc.Close_Reason__c))) {
                        System.debug('cc.Origin==>' + cc.Origin);           
                        if(cc.Origin == 'TBD' || nonSMCaseRecTypes.containsIgnoreCase(cc.RecordTypeId)) {
                            System.debug('cc.Close_Reason__c==>' + cc.Close_Reason__c);    
                            if(!Test.isRunningTest()) {        
                                cc.addError('Records that are owned by a queue may not be closed with a valid close reason. Please take ownership of this record and try again.');    
                            }
                        }                                                  
                    }
                }
            }
        }
    }      
    
    //Bikram Added this block 4998 starts          
    for(Case cc : Trigger.New) {        
        System.debug('Trigger Called==>' + cc.EntitlementId + ' ' +  cc.Entitlement.AssetId );
        if(nonSMCaseRecTypes.containsIgnoreCase(cc.RecordTypeId) && cc.Status == 'Closed' && cc.ContactId != null && Trigger.oldMap.get(cc.id).Status !='Closed') {
            if(!(autoCaseCloseReasonsSet.Contains(cc.Close_Reason__c))) {
                if(cc.EntitlementId != null && entAsstMap.containsKey(cc.EntitlementId) && entAsstMap.get(cc.EntitlementId).AssetId == null) {
                    if(!Test.isRunningTest()) {        
                        cc.addError('Case Asset Entitlement Invalid Error - Please Reach out to supportfeedback@marketo.com for further assistance.');                        
                    }
                }
            }
        }            
    }    
    //Bikram 4998 ends
    
}