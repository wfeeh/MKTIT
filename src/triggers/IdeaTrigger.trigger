trigger IdeaTrigger on Idea (after update) {

    if (Trigger.isUpdate && Trigger.isAfter) {

        Set<Id> commentAddedIds = new Set<Id>();
        Set<Id> statusUpdatedIds = new Set<Id>();
        
        /* Badgeville idea becomes product*/
        Set<Id> ideaBecomesProductIds = new Set<Id>();
        
        //Added as temp fix
        List <ReplyIdeaSchedulerLog__c> myIdeaSchdlr = new List <ReplyIdeaSchedulerLog__c>();
        
        for (Idea newIdea : Trigger.new) {
            Idea oldIdea = Trigger.oldMap.get(newIdea.Id);

            System.debug ('Record==>' + newIdea.Status + oldIdea.Status); 
           
            // 07-04-11 vishals@grazitti.com Modified for issue of sending email while a comment is deleted
            //if (newIdea.LastCommentDate != oldIdea.LastCommentDate) {
            if (newIdea.LastCommentDate > oldIdea.LastCommentDate) {
                //commentAddedIds.add(newIdea.Id);
                myIdeaSchdlr.add(new ReplyIdeaSchedulerLog__c(Reply_Idea_Id__c = newIdea.Id, SentStatus__c = false, Type__c='CommentAdded'));
            }
            if (newIdea.Status != oldIdea.Status) {
                system.debug('<==Idea Status Changed==>');
                //statusUpdatedIds.add(newIdea.Id);
                myIdeaSchdlr.add(new ReplyIdeaSchedulerLog__c(Reply_Idea_Id__c = newIdea.Id, SentStatus__c = false, Type__c='StatusUpdated'));
            }
            /* Badgeville idea becomes product*/
            if ((newIdea.Status == 'Done!' || newIdea.Status == 'Done (Partially)') && (oldIdea.Status != 'Done!' && oldIdea.Status != 'Done (Partially)')) 
            {
                //ideaBecomesProductIds.add(newIdea.Id);                
                myIdeaSchdlr.add(new ReplyIdeaSchedulerLog__c(Reply_Idea_Id__c = newIdea.Id, SentStatus__c = false, Type__c='IdeaBecomesProduct'));
            }            
        }
        
        /*
        System.debug('====='+commentAddedIds);
        if (commentAddedIds.isEmpty() == false) {
            //GlobalFunctions.sendCommentAddedNotifications(commentAddedIds);
        }        
        if (statusUpdatedIds.isEmpty() == false) {
            //GlobalFunctions.sendStatusUpdatedNotifications(statusUpdatedIds);
        }        
        //Badgeville Idea becomes product
        System.debug('badgvilleIdeaBecomesProduct' + ideaBecomesProductIds);
        if (ideaBecomesProductIds.isEmpty() == false) {            
            for(Id mID : ideaBecomesProductIds){
                //System.debug('badgvilleIdeaBecomesProductID' + mID);                
                //BadgeVilleWebServiceCallout.badgvilleIdeaBecomesProduct(mID);
            }
        } 
        */
        
        if(myIdeaSchdlr.size() > 0) { insert myIdeaSchdlr ;} 
   
    }
}