/**
 *	Description		:	This class is to handle email services
 *
 *	Create By		:	
 *
 *	Created Date	:	02/05/2014
 *
 *	Revision Logs	:	V_1.0 - Created
 *
**/

public with sharing class EmailHandler {
	
	/**
	 *	@Description	:	Method is used for sending single mail message with these 3 arguments.
	 *
	 *		1.	String toAddress	:	This is mail id of recipients. 
	 *
	 *		2.	String subject		:	This is subject of mail.
	 *
	 *		3.	String body			:	This is mail body.
	 *
	 *	Example: 	String toAddress = 'test@test.com';
	 *				String subject = 'Example mail';
	 *				String body = 'This is your creation have great time forever';
	 *				EmailHandler.sendEmail(toAddress, subject, body);
	 *
	 * @args			:	String, String, String
	 *
	 * @return			:	void
	 *
	 **/ 
    public static void sendEmail(String toAddress, String subject, String body) {

       //Instance of SingleEmailMessage 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
       //Email address of the salesforce email service
       String[] toAddresses = new String[] {toAddress};
       mail.setToAddresses(toAddresses);
       mail.setSubject(subject);
       mail.setPlainTextBody(body);
       
       //Send email
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
	/**
	  *	@Description	:	Method to sent email about case status according to there related contact's language
	  *
	  *	@args			:	Map<String, List<Case>>
	  *
	  *	@return			:	void
	  *
	  **/	
	public static void sendEmail(Map<String, List<case>> mapConLangAndCases) {
	 	
		//Query through EmailTemplate
	 	List<EmailTemplate> eTemplates = [Select Id, Name From EmailTemplate Where Name IN : Constants.MAP_LANGUAGE_AND_ETemp_NAME.values()];
	 	
	 	//Query through OrgWideEmailAddress
	 	List<OrgWideEmailAddress> orgWideEmailAddress = [Select Id, DisplayName, Address From OrgWideEmailAddress 
	 														where DisplayName =: Constants.ORGWIDEEMAILADDRESS_NAME_MARKETO_SUPPORT_FEEDBACK LIMIT 1];
	 	
	 	//List of Messaging.Singleemailmessage 
        List<Messaging.SingleEmailMessage> singleEMessages = new List<Messaging.SingleEmailMessage>();
        
        //List of cases for update
        List<Case> cases = new List<Case>();
        
        //Loop through map key set
        for(String cL : mapConLangAndCases.keySet()) {
        	
        	//Loop through Case
        	for(Case cse : mapConLangAndCases.get(cL)) {
        		
        		//Instance of Messaging.SingleEmailMessage
        		Messaging.SingleEmailMessage mail  = new Messaging.SingleEmailMessage();
        		
        		//Assign values in email
        		mail.setTargetObjectId(cse.contactId);
        		mail.setWhatId(cse.Id);
        		mail.setSaveAsActivity(false);
        		
        		//Check for list size
        		if(orgWideEmailAddress.size() > 0) {
        			
        			//Set Org Wide Email Address Id 
        			mail.setOrgWideEmailAddressId(orgWideEmailAddress[0].Id);
        			
        			//Loop through Email Templete
        			for(EmailTemplate eT : eTemplates) {
        				
        				//Check Language name in map
        				if(Constants.MAP_LANGUAGE_AND_ETemp_NAME.containsKey(cL) && eT.Name == Constants.MAP_LANGUAGE_AND_ETemp_NAME.get(cL)) {
        				
        					//Set EmailTemplate Id
        					mail.setTemplateId(eT.Id);
        					
        					//Add Email in list
        					singleEMessages.add(mail);
        					
        					//Update Case records
        					cse.SurveyLinkEmailerSent__c = true;
        					
        					//Add in list for update
        					cases.add(cse);
        				}
        			}
        		}
        	}
        }
        

        //Check for list size
        if(singleEMessages.size() > 0) {
        	
        	//Sent email notification
        	List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(singleEMessages, false);
        	
        	//Check for case list size
        	if(cases.size() > 0)
        		update cases;
        }
	 }
	 
	 /**
	  *	@Description	:	Method to sent email about duplicate user name
	  *
	  *	@args			:	string TargetObjectId ,List<String> emaliAddresses ,String emailTemplateId
	  *
	  *	@return			:	void
	  *
	  **/
	public static void emailNotification (String targetObjectId, List<String> toAddresses, String emailTemplateId){
	  	
		//Instance of MMessaging.SingleEmailMessage
		Messaging.SingleEmailMessage notificationEmail = new Messaging.SingleEmailMessage();
	
		//check the size of string set the values to send mail
		if(toAddresses.size() > 0) {
		
			//add the value for sending mail
	    	notificationEmail.setToAddresses(toAddresses);
			notificationEmail.setTemplateId(emailTemplateId);
			notificationEmail.setTargetObjectId(targetObjectId);
			notificationEmail.saveAsActivity = false;
		
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { notificationEmail });
		}
	}
	
	/**
	 *	@description	:	Method to send email notification to User.
	 *
	 *	@args			:	List<EmailTemplate>, Map<Id, List<Community_Subscription__c>>
	 *
	 *	@return			:	void
	 *
	 **/
	public static void sendEmail(List<EmailTemplate> eT, Map<Id, List<Community_Subscription__c>> mapIdeaIdsAndCS) {
		
		//Query through 
		List<OrgWideEmailAddress> oWEA = [select Id From OrgWideEmailAddress where DisplayName =: Label.ORGWIDEEMAILADDRESS_MARKETO_OMMUNITY]; 
		
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		
		//Check for email Templete
		if(eT.size() > 0 && oWEA.size() > 0) {
			
			//Loop through  map key set
			for(Id ideaId : mapIdeaIdsAndCS.keySet()) {
				
					
				//Lop through Community_Subscription__c
				for(Community_Subscription__c cS : mapIdeaIdsAndCS.get(ideaId)) {
					
					//Instance of Email Messsage
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					
					//Set email Templete variables
					mail.setTemplateId(eT[0].Id);
					mail.setTargetObjectId(cS.User__c);
					mail.setWhatId(ideaId);
					mail.setSaveAsActivity(false);
					mail.setOrgWideEmailAddressId(oWEA[0].Id);
					
					//add in List
					emails.add(mail);
				}
			}
		}
		//Check for list size
		if(emails.size() > 0) {
			Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);

		}
	}
	
	/**
	 *	@description	:	Method to send email notification to User on creaion of IdeaComment.
	 *
	 *	@args			:	List<EmailTemplate>, Map<Id, List<Community_Subscription__c>>
	 *
	 *	@return			:	void
	 *
	 **/
	public static void sendEmail(List<EmailTemplate> eT, Map<Id, List<Contact>> mapIdsAndCons) {
		
		//Query through 
		List<OrgWideEmailAddress> oWEA = [select Id From OrgWideEmailAddress where DisplayName =: Label.ORGWIDEEMAILADDRESS_MARKETO_OMMUNITY]; 
		
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		
		//Check for email Templete
		if(eT.size() > 0 && oWEA.size() > 0) {
			
			//Loop through  map key set
			for(Id ideaId : mapIdsAndCons.keySet()) {
				
					
				//Lop through Community_Subscription__c
				for(Contact cS : mapIdsAndCons.get(ideaId)) {
					
					//Instance of Email Messsage
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					
					//Set email Templete variables
					mail.setTemplateId(eT[0].Id);
					mail.setTargetObjectId(cS.Id);
					mail.setWhatId(ideaId);
					mail.setSaveAsActivity(false);
					mail.setOrgWideEmailAddressId(oWEA[0].Id);
					
					//add in List
					emails.add(mail);
				}
			}
		}
		//Check for list size
		if(emails.size() > 0) {
			Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);

		}
	}
	/**
	 *	@description	:	Method to send email notification to Authorize Contact.
	 *
	 *	@args			:	List<Authorized_Contact__c>
	 *
	 *	@return			:	void
	 *
	 **/
	 public static void emailToAuthorizeCon(List<Authorized_Contact__c> authContacts){
	 	
		//Query throug email Template
	 	List<EmailTemplate> emailTemp = [Select Id From EmailTemplate Where DeveloperName =: Label.ET_SUPPORT_AUTHORIZED_CONTACT_ADDED_NOTIFICATION	LIMIT 1];   
        
        //Query through OrgEmailAddress   
		List<OrgWideEmailAddress> orgEmailAdd = [Select Id From OrgWideEmailAddress Where DisplayName =: Label.ORGWIDEEMAILADDRESS_MARKETO_CUSTOMER_SUPPORT];
		
		//List to hold the sending emails
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		
		//Check the size of email Template list and orgEmailAddress list size
		if(emailTemp.size() > 0 && orgEmailAdd.size() > 0){
			
			//Loop through Authorize Contact
			for(Authorized_Contact__c ac : authContacts){
				
				//Instance of Email Messsage
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				
				//Populate the values
                email.setTemplateId(emailTemp[0].Id);
                email.setTargetObjectId(ac.Contact__c);
                email.setWhatId(ac.Id);
                email.setSaveAsActivity(false);
               	email.setOrgWideEmailAddressId(orgEmailAdd[0].Id);
               	
               	//add the value in list                                                        
                emails.add(email);
			}
		}
		
		//check the size of List
		if(emails.size() > 0){
			Messaging.sendEmail(emails);
		}
	 }
}