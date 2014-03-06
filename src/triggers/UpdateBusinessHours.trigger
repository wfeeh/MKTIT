trigger UpdateBusinessHours on Case (before insert, before update) { 

    if(CaseTriggerUtility.UpdateBusinessHoursisBeforeUpdate == true) return;     
    CaseTriggerUtility.UpdateBusinessHoursisBeforeUpdate = true;



    List<Case> myCaseList = new List<Case>();
    Set<Id> myP1CaseIds = new Set<Id>();
    Map<Id,Id> myNonP1CaseToEntIdMap = new Map<Id,Id>();
    Map<Id,Entitlement> myEntmntMap = new Map<Id,Entitlement>();
    List<Businesshours> myBsHrs = new List<Businesshours>(); 
    
    for(Case c :trigger.new) 
    {
        //before trigger ran
        if(c.Priority == 'P1') {
             myP1CaseIds.Add(c.Id);                  
        } 
        else if(c.EntitlementId != null) {
            //system.debug('c.EntitlementId==>' + c.EntitlementId);
            myNonP1CaseToEntIdMap.put(c.Id,c.EntitlementId);
        }        
    } 
 
    if(myP1CaseIds.IsEmpty() == FALSE)
        myBsHrs = [SELECT Id,Name FROM Businesshours WHERE Name = 'P1 Issues' Limit 1] ;                
    
    if(myNonP1CaseToEntIdMap.IsEmpty() == FALSE)
        myEntmntMap  = new Map<ID,Entitlement>([SELECT e.Id, e.BusinessHoursId From Entitlement e Where e.Id =: myNonP1CaseToEntIdMap.values() Limit 1]);

    for(Case c :trigger.new) 
    {
        if(c.Priority == 'P1') {
            if(myBsHrs.isEmpty() == FALSE){
                c.BusinessHoursId = myBsHrs[0].Id;                
            }
        } 
        else if((c.EntitlementId != null) && (myEntmntMap != null) && (myEntmntMap.containsKey(c.EntitlementId))) {
            c.BusinessHoursId = myEntmntMap.get(c.EntitlementId).BusinessHoursId;
            //system.debug('c.BusinessHoursId==>'+c.BusinessHoursId);
        }        
    }
    //if(!myCaseList.isEmpty()){if(!UpdateBusinessHoursHelper.b){UpdateBusinessHoursHelper.recursiveUpdater(true,myCaseList);}}    
    
}