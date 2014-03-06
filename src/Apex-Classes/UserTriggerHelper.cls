/**
 *  Description		:	Helper class for Trigger_User trigger.
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
public without sharing class UserTriggerHelper {
	
	//Boolean variable to control CampaignMember trigger execution
	public static Boolean Execute_User_Trigger = true;
	
    /**
     * @Description  : This method is to send notificatio to a particular user on adding duplicate user name.
     *
     * @args         :  List<User>, Map<Id,User>
     *
     * @return       :  void
     *
     **/
     public static void duplicateUserNameNotification(List<User> newUsers, Map<Id, User> mapOldUsers){
     	
     	//Set to hold the user Id
     	Set<Id> setUserIds = new Set<Id>();
     	
     	//Set to hold a label userIds
     	Set<Id> setUserIdsInLabel = new Set<Id>();
     	
     	//variable to hold the email addresses
     	List<String> toAddresses = new List<String>();
     	
     	//variable string to hold the targetObjectId
     	String targetObjectId = '';
     	
     	//Map to get CustomMilestoneSettings__c(custom setting) Data
		Map<String, Quote_Approvers__c> mapQuoteApproverCustomSetting = Constants.QUOTE_APPROVERS_CUSTOM_SETTING;
		
     	//Loop through User
     	for(User usr : newUsers){
 
     		//Check the appropriate condition to fire trigger
     		if(usr.FirstName != null && usr.LastName != null &&(mapOldUsers == null ||
     				 (usr.FirstName != mapOldUsers.get(usr.id).FirstName || usr.LastName != mapOldUsers.get(usr.id).LastName))){
     			 		
     			//string to hold the Full name of trigger
     			String usrfullName =  usr.FirstName + ' ' + usr.LastName;
     			
     			//check the value in map
     			if(mapQuoteApproverCustomSetting.containsKey(usrfullName)){
     				
     				//Add the values in set
     				setUserIds.add(usr.Id);
     			}
     		}
     	}
     	//Populate the ur Id in helper class set to send Duplicate user list 
     	DuplicateUserNameNotificationController.userIDSet.addAll(setUserIds );
     	
     	//Check the size of UserId set
     	if(DuplicateUserNameNotificationController.userIDSet.size() > 0){
     		
     		//Loop through  custom label
     		for(String usrId :Label.UsersToBeNotified.deleteWhitespace().split(',')){
            	
            	//add the value in set
            	setUserIdsInLabel.add(usrId);
                targetObjectId= usrId;
        	}
        	
        	//Remove the usr from the set
     		setUserIdsInLabel.remove(targetObjectId);
     		
     		//Loop through User
     		for(User usr :[Select id, Email from User where Id IN : setUserIdsInLabel AND Email != null]){
     			
     			//Add the value in variable
            	toAddresses.add(usr.Email);
        	}
        	
        	//Query through email template
        	String emailTemplateId = [Select Id from EmailTemplate Where DeveloperName =: Constants.DEVELOPER_NAME_DUPLICATEUSERNOTIFICATIONTEMPLATE].Id;
        	
        	//Check the size of string and also the length of targetObjectId
            if(toAddresses.size() > 0 || (targetObjectId != '' && targetObjectId.length() > 0)){
          
            	//call the email helper class to send emails
            	EmailHandler.emailNotification(targetObjectId, toAddresses, emailTemplateId);
        	}
     	}
	}
		
    /**
     * @Description  :  Thi method to set the user Id that pass to the customUserCreate(method) .
     *
     * @args         :  List<User>
     *
     * @return       :  void
     *
     **/
     public static void validateConsumerUser(List<User> newUsers){
     	
     	//Set to hold the user Id
     	Set<Id> setUsrIds = new Set<Id>();
     	
     	//Loop through User
     	for(User usr : newUsers){
     		
     		//check the appropraite condition  to fire trigger
     		if(usr.lmscons__Cornerstone_ID__c == null && (usr.UserType.toLowerCase().contains(Constants.USER_TYPE_CUSTOMER) || usr.IsPortalEnabled)){
     			
     			//add the value in set
     			setUsrIds.add(usr.Id);
     		}
		}
		
		//Check for user set size
		if(setUsrIds.size() > 0 && setUsrIds.size() <=5) {
			
			//Call future method
			UserTriggerHelper.customUserCreate(setUsrIds);
		}
	}
	/**
     * @Description  :  This method call's manage package(lmscons) class ConsumerUserWebservice's method ConsumerUsers_Create to 
     *					create Consumer user
     *
     * @args         :  List<User>
     *
     * @return       :  void
     *
     **/
     @future(callout=true)
     public static void customUserCreate(set<Id> setUserIds){
     	
     	//Check for test run to avoid callout through test method
     	if (!Test.isRunningTest()){
     		
			lmscons.ConsumerUserWebservice.ConsumerUsers_Create([Select Id, Name From User Where Id IN : setUserIds]);
		}
     }
     
      
     /**
      * @Description  :  Method to validate PortalEnable User's Contact Munchkin ID with User Munchkin ID if it change
      *
      * @args         :  List<User>, Map<Id, User>
      *
      * @return       :  void
      *
      **/
	public static void validateContactMunchkinAndTimeZone(List<User> users, Map<Id, User> mapOldUsers) {
		
		//Map to hold Contact Id and Munchkin Id
		Map<Id, String> mapConIdsAndMunchkinIds = new Map<Id, String>();
		
		//Map to hold contact Id and User Time zone
		Map<Id, String> mapConIdsAndTimeZone = new Map<Id, String>();
		
		//Loop through User
		for(User usr : users) {
			
			//Check for Contact Id and Munchkin ID to fire trigger
			if(usr.ContactId != null && usr.IsPortalEnabled == true) {
			
				//Check for Munchkin Id
				if(mapOldUsers == null || (usr.Munchkin_ID__c != mapOldUsers.get(usr.Id).Munchkin_ID__c)) {
						
					//Populate map with values
					mapConIdsAndMunchkinIds.put(usr.ContactId, usr.Munchkin_ID__c);
				}
			
				//Check for time zone
				if(mapOldUsers == null || (usr.TimeZoneSidKey != mapOldUsers.get(usr.ID).TimeZoneSidKey)) {
					
					//Populate map with values
					mapConIdsAndTimeZone.put(usr.ContactId, usr.TimeZoneSidKey);
				}
			}
		}
 		
 		//Check for map size
 		if(mapConIdsAndMunchkinIds.size() > 0 || mapConIdsAndTimeZone.size() > 0) {
	 		//Call future method to update contact related to user
	 		updateContactMunchkinAndTimeZone(mapConIdsAndMunchkinIds, mapConIdsAndTimeZone);
 		}
 	}
	
	/**
      * @Description  :  Method to update PortalEnable User's Contact Munchkin ID with User Munchkin ID if it change
      *
      * @args         :  Map<Id, String>, Map<Id, String>
      *
      * @return       :  void
      *
      **/
    @future
	public static void updateContactMunchkinAndTimeZone(Map<Id, String> mapConIdsAndMunchkinIds, Map<Id, String> mapConIdsAndTimeZone) {
		
		//List of contact
		List<Contact> contacts = new List<Contact>();
		
		//Set to hold Contact
		Set<Contact> setContacts = new Set<Contact>();
		
		//Map to hold Time Zone Custom setting
		Map<String, UserTimeZoneUpdate__c> mapUserTimeZoneUpdate = Constants.USERTIMEZONEUPDATE_CUSTOM_SETTING;
		
		//Query through contact to update Munchkin ID
		for(Contact con : [Select Id, Munchkin_ID__c, Time_Zone__c, Customer_Portal_User__c, Is_Authorized_Contact__c, AccountId, Account.Type 
							From Contact Where Id IN : mapConIdsAndMunchkinIds.keySet() OR Id IN : mapConIdsAndTimeZone.keySet()]) {
			
			//Check for condition
			if(mapConIdsAndMunchkinIds.containsKey(con.Id) && con.Munchkin_ID__c != mapConIdsAndMunchkinIds.get(con.Id)
				|| (mapUserTimeZoneUpdate.containsKey(Constants.USER_TIME_ZONE_SETTING)
					&& mapUserTimeZoneUpdate.get(Constants.USER_TIME_ZONE_SETTING).ActivateTimeZoneTrigger__c == true
					&& con.Customer_Portal_User__c == true && con.AccountId != null && con.Account.Type != Constants.CASE_ACCOUNT_TYPE_EX_CUSTOMER
					&& con.Is_Authorized_Contact__c == Constants.CONTACT_IS_AUTHORIZED_CONTACT && mapConIdsAndTimeZone.containsKey(con.Id)
					&& con.Time_Zone__c != mapConIdsAndTimeZone.get(con.Id))) {
			
				//Check contact Id in map
				if(mapConIdsAndMunchkinIds.containsKey(con.Id) && con.Munchkin_ID__c != mapConIdsAndMunchkinIds.get(con.Id)) {
					
					//Update Munchkin ID
					con.Munchkin_ID__c = mapConIdsAndMunchkinIds.get(con.Id);
				}
				
				//Check values in map
				if(mapUserTimeZoneUpdate.containsKey(Constants.USER_TIME_ZONE_SETTING)
					&& mapUserTimeZoneUpdate.get(Constants.USER_TIME_ZONE_SETTING).ActivateTimeZoneTrigger__c == true
					&& con.Customer_Portal_User__c == true && con.AccountId != null && con.Account.Type != Constants.CASE_ACCOUNT_TYPE_EX_CUSTOMER
						&& con.Is_Authorized_Contact__c == Constants.CONTACT_IS_AUTHORIZED_CONTACT && mapConIdsAndTimeZone.containsKey(con.Id)
						&& con.Time_Zone__c != mapConIdsAndTimeZone.get(con.Id)) {
				
					//Update contact time zone
					con.Time_Zone__c = mapConIdsAndTimeZone.get(con.Id);
				}
			
				//Add in list
				contacts.add(con);
			}
		}
		
		//Check for list size
		if(contacts.size() > 0) {
			
			//Set contact trigger flag to false
			ContactTriggerHelper.Execute_Contact_Trigger = false;
			
			//Update				
			update contacts;
		}
	}
}