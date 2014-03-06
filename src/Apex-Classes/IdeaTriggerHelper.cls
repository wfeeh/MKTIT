/**
 *  Description		:	Helper class for Trigger_Idea trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :	02/12/2014
 *
 *  Version         :	V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class IdeaTriggerHelper {
	
	//Boolean variable for Idea trigger execution
    public static Boolean Execute_Idea_Trigger = true;
	
	/**
     * @Description  :  This method is used to send the email to community subscription user and call the futrure method
     *
     * @args         :  List<Idea>, Map<Id,Idea>
     *
     * @return       :  void
     *
     **/
	public static void validateIdeaStatus(List<Idea> newIdeas ,Map<Id ,Idea> mapOldIdeas){
		
		//Set to hold the idea's id
		Set<Id> setIdeIds = new Set<Id>();
		
		//Set to hold Idea Id
		Set<Id> setIdeaIds = new Set<Id>();
		
		//Set to hold the parentId of Idea
		Set<Id> setChildIdeaIds = new Set<Id>();
		
		//Loop throug Idea
		for(Idea ide : newIdeas){
			
			//Check the appropriate condition to fire the trigger
			if(ide.Status != mapOldIdeas.get(ide.Id).Status){
				
				//add the value in set
				setIdeIds.add(ide.Id);
			}
			
			// 
			if((ide.Status == Constants.IDEA_STATUS_DONE || ide.Status == Constants.IDEA_STATUS_DONE_PARTIALLY)
				 			&& (mapOldIdeas.get(ide.Id).Status != Constants.IDEA_STATUS_DONE 
				 			&& mapOldIdeas.get(ide.Id).Status != Constants.IDEA_STATUS_DONE_PARTIALLY)){
								
				//Add the value in set
				setIdeaIds.add(ide.Id);
			}
		}
		
		//Loop through Idea
		for(Idea idea: [Select Id, Status, ParentIdeaId, Categories, NumComments, CreatedDate, CreatedBy.Name, CreatedBy.Id ,Body, Title 
						From Idea Where ParentIdeaId IN : setIdeIds] ){
						
			//add the values in set
			setChildIdeaIds.add(idea.Id);
		}
		
		//Add Idea Ids in one Set
		setIdeIds.addAll(setChildIdeaIds);
		
		//Map to hold the Id as key corresponding to the List of commuity subsciption
		Map<Id, List<Community_Subscription__c>> mapIdeaComSubcription = new Map<Id, List<Community_Subscription__c>>();
		
		//Loop through Commnuity Subcription
		for(Community_Subscription__c cS : [Select Id, User__c, User__r.Email, Idea_Question_Id__c from Community_Subscription__c
												 Where Idea_Question_Id__c IN : setIdeIds AND User__c != null AND User__r.ContactId != null
												  AND User__r.Contact.Account.Type NOT IN : Constants.SET_ACCOUNT_TYPE_FOR_IDEA]){
							
			//Check for idea Id in map
			if(mapIdeaComSubcription.containsKey(cS.Idea_Question_Id__c)) {
				
				//Add Community_Subscription__c record in map
				mapIdeaComSubcription.get(cS.Idea_Question_Id__c).add(cS);
			} else {
				
				//Populate Map with values
				mapIdeaComSubcription.put(cS.Idea_Question_Id__c, new List<Community_Subscription__c>{cS});
			}				  	
		}
		
		//check the size of Map
		if(mapIdeaComSubcription.size() > 0){
			
			//query through EmailTemplate
			List<EmailTemplate> emailTemplate = [Select Id From EmailTemplate Where DeveloperName =: Label.EMAILTEMPLATE_MARKETO_COMMUNITY_IDEA_STATUS LIMIT 1];
			
			//Call the email handelr class method
			EmailHandler.sendEmail(emailTemplate , mapIdeaComSubcription);
		}
		
		//check the size of set
		if(setIdeaIds.size() <= 10){
			
			 	
			 //Loop through Id's
			for(Id id :setIdeaIds){
			 	
			 	 //call the future method class
			 	BadgeVilleWebServiceCallout.badgvilleIdeaBecomesProduct(id);
			 	
			}
		}
	}
	
	/**
     * @Description  :  This method is used validate Community Activity
     *
     * @args         :  List<Idea>, Map<Id,Idea>
     *
     * @return       :  void
     *
     **/
     public static void validateCommunityActivity(Map<Id, Idea> mapNewIdeas , Map<Id, Idea> mapOldIdeas){
     	
     	//List to insert the communtiy Activity
     	List<Community_Activity__c> comActivities = new List<Community_Activity__c>();
     	
     	//Loop through Idea
     	for(Idea  ide : [Select Id, CreatedById ,CreatedBy.ContactId, LastCommentId, Title,(Select Id, CreatedById, CreatedBy.ContactId From 
     							Comments Where CreatedBy.ContactId != null LIMIT 1) From Idea Where Id IN : mapNewIdeas.keySet()]){
     		
     		//Check the appropraite condition to fire trigger
     		if((mapOldIdeas == null && ide.CreatedBy.ContactId != null) || (mapOldIdeas != null && ide.LastCommentId != null 
     			&& ide.LastCommentId != mapOldIdeas.get(ide.Id).LastCommentId && ide.Comments.size() > 0)) {
     			
				//Instance of Community Actitvity
     			Community_Activity__c comActitvity = new Community_Activity__c();
     		
     			//Populate the values
 				comActitvity.Posted_date__c = System.now();
            	comActitvity.Title__c = ide.Title;
            	comActitvity.Link__c = Constants.IDEA_LINK_VALUE + ide.Id;
                
     			//Check for Insert case
     			if(mapOldIdeas == null && ide.CreatedBy.ContactId != null) { 
     				
     				//populate the values in case of insert
     				comActitvity.Contact__c = ide.createdBy.ContactId;
            		comActitvity.Activity_Id__c = ide.id;
            		comActitvity.Type__c = Constants.IDEA_TYPE_IDEA;
     			
     			//Check the case update
				} else if(mapOldIdeas != null && ide.LastCommentId != null && ide.LastCommentId != mapOldIdeas.get(ide.Id).LastCommentId && ide.Comments.size() > 0){
                	
                	comActitvity.Contact__c = ide.Comments[0].createdBy.ContactId;
                	comActitvity.Activity_Id__c = ide.LastCommentId;
                	comActitvity.Type__c = Constants.IDEA_TYPE_IDEA_COMMENT;
                }
                
                //Add the value in list
                comActivities.add(comActitvity);
     		}					
     	}
     	
     	//Check the size of list
     	if(comActivities.size( )> 0)
     		insert comActivities;
     	
     }
}