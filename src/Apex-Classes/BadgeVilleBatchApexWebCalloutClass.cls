global class BadgeVilleBatchApexWebCalloutClass Implements Database.Batchable<User>, Database.AllowsCallouts{
    global ID CampaignId;
    global List<User> usersToTarget;
    global String verb; 
    
    private BadgeVilleBatchApexWebCalloutClass(){}
   
    Global BadgeVilleBatchApexWebCalloutClass(List<Id> cnts, string verb,Id campgnId)
    {               
        //BadgeVilleBatchApexWebCalloutClass();
        usersToTarget = [SELECT Id, Email,ContactId from User Where Isactive=true AND IsPortalEnabled = true AND ContactId in : cnts];        
        CampaignId = campgnId;
        this.verb = verb;
    } 
    
    Global BadgeVilleBatchApexWebCalloutClass(List<Id> cnts, string verb)
    {        
        System.debug('Ids====>'+cnts);       
        usersToTarget = [SELECT Id, Email,ContactId from User Where Isactive=true AND IsPortalEnabled = true AND ContactId in : cnts];        
        if(Test.isRunningTest()) {
            usersToTarget = [SELECT Id, Email,ContactId from User Where Isactive=true AND IsPortalEnabled = true Limit 1];        
        }
        this.verb = verb;
        CampaignId = null;
    } 
    
    global Iterable<User> start(database.batchablecontext BC){
        return (usersToTarget);    
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope){
        for(User portalUser : scope){
            if(verb == 'attended_user_summit' || verb == 'attend_a_user_group_meeting' || verb == 'attended_dream_force' ){
                BadgeVilleWebServiceCallouts.userGroupReward(portalUser.Id,verb, CampaignId);
            } else if (verb == 'synchwithboulderlogic' ){
                  BadgeVilleWebServiceCallouts.giveTriggeredReward(portalUser.Id,verb);              
            }
        }    
    }
    
    global void finish(Database.BatchableContext info){ }//global void finish loop
    
    
}