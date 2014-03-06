/**
 *  Description     :	Helper class for Trigger_ArticleFeedBack trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :	01/20/2014
 *
 *  Version         :	V_1.0
 *
 *  Revision Logs   :	V_1.0 - Created 
 *
 **/
public without sharing class ArticleFeedbackTriggerHelper {
	
	//Boolean variable for article feedback trigger execution
    public static Boolean execute_ArticleFeedBack_Trigger = true;
    
	/**
	 * @Description  :  Method to send Email notification to Article FeedBack User  related to Community_Subscription__c
     *
     * @args         :  List<Article_FeedBack__c>
     *
     * @return       :  void
     *
	**/
	public static void articleFeedbackNotification(List<Article_FeedBack__c> newArticleFeedbacks){
		
		//Set to hold the id's of Article feedback
		Set<Id> setArtFeedArticleIds = new Set<Id>();
		
		//set to hold the createdby Id
		Set<Id> setArtFeedCreatedById = new Set<Id>();
		
		//Loop through Articl FeedBack
		for(Article_FeedBack__c aF : newArticleFeedbacks){
			
			//Check the appropriate value to fire trigger
			if(aF.Article_Id__c != null){
				
				//Add the value in set
				setArtFeedArticleIds.add(aF.Article_Id__c);
				
				setArtFeedCreatedById.add(aF.CreatedById);
			}
		}
		
		//Map to hold the community subscrition Id corresponding to the List of community subscrition
		Map<Id, List<Community_Subscription__c>> mapArticleIdAndSubscriptions = new Map<Id, List<Community_Subscription__c>>();
		
		//Loop through commumity subscription
		for(Community_Subscription__c cS : [Select User__c,User__r.Email,Idea_Question_Id__c from Community_Subscription__c Where 
														Idea_Question_Id__c IN : setArtFeedArticleIds and User__c NOT IN : setArtFeedCreatedById AND 
														User__c != null AND User__r.ContactId != null AND User__r.Contact.Account.Type NOT IN: Constants.SET_ACCOUNT_TYPE_FOR_IDEA]){
															
			//Check value in map
			if(mapArticleIdAndSubscriptions.containsKey(cS.Idea_Question_Id__c)){
				
				//Add Community_Subscription__c record in map
				mapArticleIdAndSubscriptions.get(cS.Idea_Question_Id__c).add(cS);
			
			} else{
				
				//Populate Map with values
				mapArticleIdAndSubscriptions.put(cS.Idea_Question_Id__c, new List<Community_Subscription__c>{cS});
			}										
		}
		
		//Map to hold Article_FeedBack__c Id as key and Community_Subscription__c as value
		Map<Id, List<Community_Subscription__c>> mapAFIdAndCSs = new Map<Id, List<Community_Subscription__c>>();
		
		//Loop through Articl FeedBack
		for(Article_FeedBack__c aF : newArticleFeedbacks){
			
			//Check the appropriate value to fire trigger
			if(aF.Article_Id__c != null && mapArticleIdAndSubscriptions.containsKey(aF.Article_Id__c)){
				
				//Populate map with value
				mapAFIdAndCSs.put(aF.Id, mapArticleIdAndSubscriptions.get(aF.Article_Id__c));
			}
		}
		//check the size o map
		if(mapAFIdAndCSs.size() > 0){
			
			//query through EmailTemplate
			List<EmailTemplate> emailTemplate = [Select Id From EmailTemplate Where DeveloperName =: Label.ET_MARKETO_COMMUNITY_ARTICLE_FEEDBACK LIMIT 1];
			
			//Call the email handelr class method
			EmailHandler.sendEmail(emailTemplate , mapAFIdAndCSs);
			
		}
	}
}