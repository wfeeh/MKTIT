/**
 *  Description     :   This is future Handler class for trigger on Case .
 *
 *  Created By      :   
 *
 *  Created Date    :   02/03/2013   
 * 
 *  Revision Logs   :   V1.0 - Created
 *
**/ 
public with sharing class CaseNotificationFutureHandler {
	
	@future(callout=true)
	public Static void caseNotificationHandler(Set<Id> setCaseId) {			

		//String
		String baseURL = 'http://community.marketo.com/';

		//List of Case Related article
		List<Case_Related_Article_List__c> artList = new List<Case_Related_Article_List__c>();

		//Loop through case records
		for(Case cse : [Select Id, SuppliedEmail, RecordType.Name, Account.Type, ContactId,Entitlement.Status, Entitlement.SlaProcessId, 
							Entitlement.SlaProcess.Name, Entitlement.SocialMarketing_Only__c ,Contact.Is_Authorized_Contact__c from Case Where
							Id IN : setCaseId]) {
		
			//List of resultElement
			List<resultElement> helpArticleList = SolrImplementationForRelevantArticles.getRelevantLinksFromSolr(cse.Subject);

			//Instance of Case_Related_Article_List__c
			Case_Related_Article_List__c ArticleToBeAdded = new Case_Related_Article_List__c();
		
			//Assigining values to Case_Related_Article_List__c fields
			ArticleToBeAdded.Case__c = cse.Id;  
			ArticleToBeAdded.Contact_Email__c = cse.Contact.Email; 
			
			//Loop through list of resultElement
			for( resultElement helpArticleParser : helpArticleList) {
	   
				//String
				String helpArticleLink = '';
			
				//Check for Id
				if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA0')) {
					helpArticleLink = baseURL + 'marketoArticle?id=' + helpArticleParser.Id;
				} 
				
				//Check for Id
				else if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA2')) { 
					helpArticleLink = baseURL + 'marketoTutorial?id=' + helpArticleParser.Id;
				}	
				
				//Check for Id
				else if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA3')) {
					helpArticleLink = baseURL + 'marketoissueSolution?id=' + helpArticleParser.Id;
				}
				
				//Check for Id
				else if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA4')) { 
					helpArticleLink = baseURL + 'marketoVideoLibrary?id=' + helpArticleParser.id + '&title=' + helpArticleParser.title;
				}
				
				//Check for Id
				else if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA5')) { 
					helpArticleLink = baseURL + 'marketoDeepDive?id=' + helpArticleParser.id + '&title=' + helpArticleParser.title;                    
				}
				
				//Integer Count
				Integer Count = 1;
	  
				//Check if not Empty
				if(helpArticleLink != '') {                      
				
					if(Count == 1){                    
						ArticleToBeAdded.Article_Title1__c = helpArticleParser.title;
						ArticleToBeAdded.Article_Link1__c  = helpArticleLink;                        
					
					} else if(Count == 2){                    
						ArticleToBeAdded.Article_Title2__c = helpArticleParser.title;
						ArticleToBeAdded.Article_Link2__c  = helpArticleLink;                        
					
					} else if(Count == 3){                    
						ArticleToBeAdded.Article_Title3__c = helpArticleParser.title;
						ArticleToBeAdded.Article_Link3__c  = helpArticleLink;                        
					
					} else if(Count == 4){                    
						ArticleToBeAdded.Article_Title4__c = helpArticleParser.title;
						ArticleToBeAdded.Article_Link4__c  = helpArticleLink;                        
					
					} else if(Count == 5){                    
						ArticleToBeAdded.Article_Title5__c = helpArticleParser.title;
						ArticleToBeAdded.Article_Link5__c  = helpArticleLink;                        
					}
				}
				count++;                                        
			
				//Check if Case_Related_Article_List__c not 
				if(ArticleToBeAdded.Case__c != NULL)
				artList.add(ArticleToBeAdded);            
			}
			
			//check the size of list
			if( artList.size() > 0 )
			insert artList;
		}
	}
}