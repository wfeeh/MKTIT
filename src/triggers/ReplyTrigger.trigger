trigger ReplyTrigger on Reply (after insert) {

    List <ReplyIdeaSchedulerLog__c> myRepSchdlr = new List<ReplyIdeaSchedulerLog__c>();    
    if (Trigger.isInsert && Trigger.isAfter) {
        //Set<Id> ids = new Set<Id>();
        for (Reply reply : Trigger.new) {
            //ids.add(reply.Id);
            myRepSchdlr.add(new ReplyIdeaSchedulerLog__c(Reply_Idea_Id__c = reply.Id, SentStatus__c = false, Type__c='ReplyPosted')); 
        }        
        System.Debug('sendReplyNotifications==>' + myRepSchdlr );        
        if(myRepSchdlr.isEmpty() == false) 
        {    
            insert myRepSchdlr ;
        }
    }
    
}