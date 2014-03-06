global class MarketoReplyIdeaNotificationScheduler Implements Schedulable
{
    global void execute(SchedulableContext sc)
    {             
        List <ReplyIdeaSchedulerLog__c> myRepSchdlr = [SELECT Reply_Idea_Id__c, SentStatus__c, Type__c from ReplyIdeaSchedulerLog__c WHERE SentStatus__c = false];
        Set<String> repIds = new Set<String>();
        Set<String> ideaCmntIds = new Set<String>();
        Set<String> ideaStatusIds = new Set<String>();
        Set<String> ideaProductIds = new Set<String>();
        
        if(myRepSchdlr != null) {
            for(ReplyIdeaSchedulerLog__c tmpRepSchdlr : myRepSchdlr)
            {
                if(tmpRepSchdlr.Type__c == 'ReplyPosted')            
                    repIds.add(tmpRepSchdlr.Reply_Idea_Id__c);
                if(tmpRepSchdlr.Type__c == 'CommentAdded')            
                    ideaCmntIds.add(tmpRepSchdlr.Reply_Idea_Id__c);
                if(tmpRepSchdlr.Type__c == 'StatusUpdated')            
                    ideaStatusIds.add(tmpRepSchdlr.Reply_Idea_Id__c);
                if(tmpRepSchdlr.Type__c == 'IdeaBecomesProduct')            
                    ideaProductIds.add(tmpRepSchdlr.Reply_Idea_Id__c);
                tmpRepSchdlr.sentstatus__c = true;
            } 
        }        
            
        if(myRepSchdlr != null) 
        {
            if(myRepSchdlr.isEmpty() == FALSE)
            {
                update  myRepSchdlr;
    
                Map<Id,Reply> myRepIds = new MAP<Id,Reply>([SELECT ID from Reply Where Id IN : repIds]);
                if(myRepIds.isEmpty() == false) GlobalFunctions.sendReplyNotifications(myRepIds.keySet());
    
                Map<Id,Idea> myIdeaCmntIds = new MAP<Id,Idea>([SELECT ID from Idea Where Id IN : ideaCmntIds]);
                if(myIdeaCmntIds.isEmpty() == false) GlobalFunctions.sendCommentAddedNotifications(myIdeaCmntIds.keySet());
    
                Map<Id,Idea> myIdeaStatusIds = new MAP<Id,Idea>([SELECT ID from Idea Where Id IN : ideaStatusIds]);
                if(myIdeaStatusIds.isEmpty() == false) GlobalFunctions.sendStatusUpdatedNotifications(myIdeaStatusIds.keySet());
    
                Map<Id,Idea> myIdeaProductIds = new MAP<Id,Idea>([SELECT ID from Idea Where Id IN : ideaProductIds]);
                for(ID mID : myIdeaProductIds.keyset()) {
                    //System.debug('badgvilleIdeaBecomesProductID' + mID);                
                    BadgeVilleWebServiceCallout.badgvilleIdeaBecomesProduct(mID);
                }
            }    
        }        
    }    
    
    @isTest(SeeAllData=true) public static void testTriggerCalls() 
    {
        Test.startTest();        
        List<Question> curQues = [SELECT Id from Question Where NumReplies > 0 AND CreatedbyId != :Userinfo.getUserID() LIMIT 1];
        if(curQues.isEmpty() == FALSE)
        {
            Reply Rep1 = new Reply();
            Rep1.QuestionId = curQues[0].Id;        
            Rep1.Body = 'Reply1';
            insert Rep1;
        }
        List<Idea> curIdea = [SELECT Id from Idea Where CreatedbyId != :Userinfo.getUserID() and status != 'Done (Partially)' and status != 'Done' LIMIT 1];
        if(curQues.isEmpty() == FALSE)
        {
            IdeaComment comm1 = new IdeaComment();
            Comm1.IdeaId = curIdea[0].Id;        
            Comm1.CommentBody  = 'CommentTest';
            insert Comm1;            
            curIdea[0].status = 'Done';
            update curIdea[0];
        } 
        
        
        MarketoReplyIdeaNotificationScheduler mBV= new MarketoReplyIdeaNotificationScheduler();
        String schedule = '0 0 23 * * ?';
        system.schedule('MarketoReplyIdeaNotificationScheduler Run Test', schedule, mBV);
        test.stopTest();                     
    }   
}