trigger AutoCloseMilestone on CaseComment (after insert) {
    
    Set<Id> caseIds = new Set<Id>();    
    Set<Id> CrtdByUsrIds = new Set<Id>();//List of createdby user
    for(CaseComment cc :trigger.new) {
        System.debug('CreatedById'+cc.createdbyid);
        CrtdByUsrIds.Add(cc.CreatedById);
    }   
    //getlist of non portal users.
    MAP<ID,User> nonPortalUser = new Map<Id,User>([SELECT ID, IsPortalEnabled, ContactId FROM USER WHERE IsPortalEnabled = FALSE AND ID IN:CrtdByUsrIds]);
    for(CaseComment cc :trigger.new) {        
        if(cc.IsPublished && (nonPortalUser.containsKey(cc.CreatedById)) && !(cc.createdbyid =='005500000014AByAAM' || cc.createdbyid == '00550000001y4AfAAI'))
        {
            caseIds.add(cc.ParentId);
        }
    }      
    if(caseIds != null) {
        MilestoneUtils.completeMilestone(caseIds, 'First Response', System.now());
    }
}