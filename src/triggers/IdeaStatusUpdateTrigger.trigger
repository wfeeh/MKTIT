trigger IdeaStatusUpdateTrigger on Idea (after update) {
    Set<Id> statusUpdatedIds      = new Set<Id>();
    Set<Id> ideaBecomesProductIds = new Set<Id>();
    for (Idea newIdea : Trigger.new) {  
        Idea oldIdea = Trigger.oldMap.get(newIdea.Id);    
        if (newIdea.Status != oldIdea.Status) {
            statusUpdatedIds.add(newIdea.Id);
        }  
        if ((newIdea.Status == 'Done!' || newIdea.Status == 'Done (Partially)') && (oldIdea.Status != 'Done!' && oldIdea.Status != 'Done (Partially)')) 
        {
            ideaBecomesProductIds.add(newIdea.Id);                
        }                   
    }
    GlobalFunctions.sendStatusUpdatedNotifications(statusUpdatedIds);
    if (ideaBecomesProductIds.isEmpty() == false) {            
        for(Id mID : ideaBecomesProductIds){
            BadgeVilleWebServiceCallout.badgvilleIdeaBecomesProduct(mID);
        }
    } 
}