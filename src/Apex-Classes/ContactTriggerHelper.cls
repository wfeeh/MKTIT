/**
 *  Description    :   Helper class for Trigger_Contact trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   01/20/2014
 *
 *  Version         :  V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class ContactTriggerHelper {
  
  	//Boolean variable to control CampaignMember trigger execution
	public static Boolean Execute_Contact_Trigger = true;
    
    /**
     * @Description  :  Method to validate the GS_4Weekly_Usage_Data__c filds value in GS_4Weekly_Usage_Data_Contact__c     
     *
     * @args         :  List<Contact>, Map<Id,Contact>
     *
     * @return       :  void
     *
     **/
    public static void validateGSDataOnAccountToCreateGSContact(List<Contact> newContacts, Map<Id,Contact> mapOldContacts){
            
        //Set to hold account ids
        Set<Id> setAccountIds = new Set<Id>();
            
        //Set to hold contact ids
        Set<Id> setContactIds =new Set<Id>();
            
        //String variable 
        String gsQueryString ='';
            
        //List of GS_4Weekly_Usage_Data_Contact__c to upsert
        List<GS_4Weekly_Usage_Data_Contact__c> gSWeeklyContacts = new List<GS_4Weekly_Usage_Data_Contact__c>();
            
        //Loop through contact
        for(Contact con : newContacts){
                
            //Check the condition of User type Admin,User Type System Admin ,Is Authorized Contact and Marketo Usage Report opt
            if(con.AccountId != null && ((con.User_Type_Admin__c == true || con.User_Type_System_Admin__c == true 
                || con.Is_Authorized_Contact__c == Constants.CONTACT_IS_AUTHORIZED_CONTACT || con.Marketo_Usage_Report_Opt_In__c == true)
                && (mapOldContacts == null 
                ||((con.User_Type_Admin__c == true && mapOldContacts.get(con.id).User_Type_Admin__c != con.User_Type_Admin__c)
                || (con.User_Type_System_Admin__c == true && mapOldContacts.get(con.id).User_Type_System_Admin__c != con.User_Type_System_Admin__c) 
                || (con.Is_Authorized_Contact__c == Constants.CONTACT_IS_AUTHORIZED_CONTACT && mapOldContacts.get(con.id).Is_Authorized_Contact__c != con.Is_Authorized_Contact__c) 
                || (con.Marketo_Usage_Report_Opt_In__c == true && mapOldContacts.get(con.id).Marketo_Usage_Report_Opt_In__c != con.Marketo_Usage_Report_Opt_In__c))))){
                    
                //Add the contact's accountId  in contactList
                setAccountIds.add(con.AccountId);
                    
                //Add the contact's Id
                setContactIds.add(con.Id);
            }
        }
            
        //Map to hold GS_4Weekly_Usage_Data__c corrsponding to account Ids
        Map<Id,List<GS_4Weekly_Usage_Data__c>> mapAccIdGsWeeklyUsageData = new Map<Id,List<GS_4Weekly_Usage_Data__c>>();
          
        //Map to hold List of GS_4Weekly_Usage_Data_Contact__c corresponding to contact Ids
        Map<String,List<GS_4Weekly_Usage_Data_Contact__c>> mapConIdUDKeyWithGSWConId = new Map<String,List<GS_4Weekly_Usage_Data_Contact__c>>();
        
        //Use getDescribe method to get all field GS_4Weekly_Usage_Data__c
        for(String gsField : GS_4Weekly_Usage_Data__c.getSobjectType().getDescribe().fields.getMap().KeySet()) {
            
            //Add field in string to pass in dunamic SOQL
            gsQueryString += gsField + ',';
        }
        String SOQL = 'Select ' + gsQueryString.removeEnd(',') + ' From GS_4Weekly_Usage_Data__c Where Account__c IN : setAccountIds';
        
        //Loop through GS_4Weekly_Usage_Data__c
        for(GS_4Weekly_Usage_Data__c gS4WUData : DataBase.query(SOQL)){
            
            //Check if map contains account Id if yes  than add GS_4Weekly_Usage_Data__c in map corrsponding to account id
            if(mapAccIdGsWeeklyUsageData.containsKey(gS4WUData.Account__c)) {
                
                //Add record in map
                mapAccIdGsWeeklyUsageData.get(gS4WUData.Account__c).add(gS4WUData);
            } else {
                //Populate map with account id and  
                mapAccIdGsWeeklyUsageData.put(gS4WUData.Account__c, new List<GS_4Weekly_Usage_Data__c>{gS4WUData});
            } 
        }
        
        //Loop throug GS_4Weekly_Usage_Data_Contact__c
        for(GS_4Weekly_Usage_Data_Contact__c uDC: [SELECT Id, Usage_Data_Key__c, Contact__c, Account__c 
                                                                    FROM GS_4Weekly_Usage_Data_Contact__c WHERE Contact__c IN : setContactIds
                                                                    AND Usage_Data_Key__c != null]){
            
            //check the Usage_Data_Key__c(field) not null
            if(mapConIdUDKeyWithGSWConId.containsKey(uDC.Contact__c))
                mapConIdUDKeyWithGSWConId.get(uDC.Contact__c).add(uDC); 
            else
            	mapConIdUDKeyWithGSWConId.put(uDC.Contact__c, new List<GS_4Weekly_Usage_Data_Contact__c>{uDC});
        }
        
        //Loop through contact  
        for(Contact con : [Select Id, AccountId From Contact Where Id IN : setContactIds]){
   
            //Check the map contains AccountId
            if(mapAccIdGsWeeklyUsageData.containsKey(con.AccountId)){
            
                //Loop through GS_4Weekly_Usage_Data__c
                for(GS_4Weekly_Usage_Data__c gSWSD : mapAccIdGsWeeklyUsageData.get(con.AccountId)) {
                    
                    //Check for Usage_Data_Key__c
                    if(gSWSD.Usage_Data_Key__c == null || gSWSD.Usage_Data_Key__c == '')
                    	continue;
                    	
                    //Call Utility class method to create new GS_4Weekly_Usage_Data_Contact__c record
                    GS_4Weekly_Usage_Data_Contact__c gSWeeklyContact = Utility.createGSWeeklyContact(gSWSD);
                    
                    //Check for conntact Id in map
                    if(mapConIdUDKeyWithGSWConId.containsKey(con.Id)) {
                    	
                    	//Integer variable to get list index
                    	Integer i = 0;
                    	
                    	//Loop through map values
                    	for(GS_4Weekly_Usage_Data_Contact__c uDC : mapConIdUDKeyWithGSWConId.get(con.Id)) {
                    		
                    		//Check for GS_4Weekly_Usage_Data__c's Usage_Data_Key__c
                    		if(uDC.Usage_Data_Key__c != null && uDC.Usage_Data_Key__c == gSWSD.Usage_Data_Key__c) {
                    			
                    			//Assign Contact data Id in new Instance
                    			gSWeeklyContact.Id = uDC.Id;
                    			
                    			//Remove that contact Data from map
                    			mapConIdUDKeyWithGSWConId.get(con.Id).remove(i);
                    			
                    			//Use break statement
                    			break;
                    		}
                    		i++;
                    	}	
                    }	
                	
                	//Assign to contact
                    gSWeeklyContact.Contact__c = con.Id;
                   
                    //Add in list
                    gSWeeklyContacts.add(gSWeeklyContact);
                }
            }
        }
        
        //Check for list size and upsert the list
        if(gSWeeklyContacts.size() > 0)
            upsert gSWeeklyContacts;
    }
    
    /**
     * @Description  :  Method to populate the values in JBCXM__Milestone__c
     *
     * @args         :  List<Contact>, Map<Id,Contact>
     *
     * @return       :  void
     *
     **/
     public static void createMilestones(List<Contact> newContacts, Map<Id,Contact> mapOldContacts){
        
        //List to hold Milestone object
        List<JBCXM__Milestone__c> jBCXMilestones = new List<JBCXM__Milestone__c>();
        
        //set to hold contact's accountId
        Set<Id> setAccountIds = new Set<Id>();
        
        //Loop through contact
        for(Contact con : newContacts){
            
            if(con.AccountId != null && con.No_Longer_with_Company__c == false && (con.EDU_Foundation_Classroom_Attended__c != null 
                || con.EDU_Foundation_Virtual_Attended__c != null) 
                && (mapOldContacts.get(con.Id).EDU_Foundation_Classroom_Attended__c != con.EDU_Foundation_Classroom_Attended__c
                    || mapOldContacts.get(con.Id).EDU_Foundation_Virtual_Attended__c!= con.EDU_Foundation_Virtual_Attended__c)){
                
                //add the contact's accountId               
                setAccountIds.add(con.AccountId);
            }
        }
        
        //Create a Map of all the Accounts
        Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id,JBCXM__CustomerInfo__c,
                                    JBCXM__CustomerInfo__r.JBCXM__ASV__c,JBCXM__CustomerInfo__r.JBCXM__MRR__c FROM Account WHERE Id IN : setAccountIds]);
        
        //Create a Map of all the Milestone 
        Map<String,JBCXM__PickList__c> mapJBCXMs = new Map<String,JBCXM__PickList__c>();
        
        //Lopp through JBCXM__PickList__c
        for(JBCXM__PickList__c picklist : [SELECT Id,JBCXM__SystemName__c FROM JBCXM__PickList__c WHERE JBCXM__Active__c = true AND
                                                        JBCXM__Category__c =: Constants.CONTACT_JBCXM_CATEGORY_MILESTONE 
                                                        AND (JBCXM__SystemName__c =: Constants.CONTACT_JBCXM_SYSTEMNAME_CLASS_FOUNDATION_CLASSROOM
                                                             OR JBCXM__SystemName__c =: Constants.CONTACT_JBCXM_SYSTEMNAME_CLASS_FOUNDATION_VIRTUAL)]){
            
            //populate map with values
            mapJBCXMs.put(picklist.JBCXM__SystemName__c, picklist); 
        }
        
        
        //Loop through contact
        for(Contact contact : newContacts){
            
            //Check if map contains contact.accountId
            if(mapAccounts.containsKey(contact.AccountId)) {
                            
                //Make sure the Contact has an Account and associated Customer Info record
                if(mapAccounts.get(contact.AccountId).JBCXM__CustomerInfo__c != null){
                
                    //Check for EDU_Foundation_Classroom_Attended__c field on contact
                    if(contact.No_Longer_with_Company__c == false && contact.EDU_Foundation_Classroom_Attended__c != null
                        && mapOldContacts.get(contact.Id).EDU_Foundation_Classroom_Attended__c != contact.EDU_Foundation_Classroom_Attended__c){
                        
                        //Check for picklist field JBCXM System Name field
                        if(mapJBCXMs.containsKey(Constants.CONTACT_JBCXM_SYSTEMNAME_CLASS_FOUNDATION_CLASSROOM)){
                            
                            //Instance of JBCXM Milestone
                            JBCXM__Milestone__c milestone = new JBCXM__Milestone__c();
                            
                            //Populate field with values
                            milestone.JBCXM__Account__c = contact.AccountId;
                            milestone.JBCXM__Milestone__c = mapJBCXMs.get(Constants.CONTACT_JBCXM_SYSTEMNAME_CLASS_FOUNDATION_CLASSROOM).Id;
                            milestone.JBCXM__Date__c = DateTime.newInstance(contact.EDU_Foundation_Classroom_Attended__c.Year(), 
                                                                            contact.EDU_Foundation_Classroom_Attended__c.Month(),
                                                                            contact.EDU_Foundation_Classroom_Attended__c.Day());
                            milestone.JBCXM__Comment__c = contact.FirstName + ' ' + contact.LastName + ' attended the Foundation Training.';
                            
                            //Add in list
                            jBCXMilestones.add(milestone);
                        }
                    }
                
                    //Check for EDU_Foundation_Virtual_Attended__c
                    if(contact.No_Longer_with_Company__c == false && contact.EDU_Foundation_Virtual_Attended__c != null
                        && mapOldContacts.get(contact.Id).EDU_Foundation_Virtual_Attended__c != contact.EDU_Foundation_Virtual_Attended__c) {
                    
                        //Check for picklist field JBCXM System Name field
                        if(mapJBCXMs.containsKey(Constants.CONTACT_JBCXM_SYSTEMNAME_CLASS_FOUNDATION_VIRTUAL)) {
                            
                            //Instance of JBCXM Milestone
                            JBCXM__Milestone__c milestone1 = new JBCXM__Milestone__c();
                
                            //Populate field with values
                            milestone1.JBCXM__Account__c = contact.AccountId;
                            milestone1.JBCXM__Milestone__c = mapJBCXMs.get(Constants.CONTACT_JBCXM_SYSTEMNAME_CLASS_FOUNDATION_VIRTUAL).Id;
                            milestone1.JBCXM__Date__c = DateTime.newInstance(contact.EDU_Foundation_Virtual_Attended__c.Year(), 
                                                                            contact.EDU_Foundation_Virtual_Attended__c.Month(),
                                                                            contact.EDU_Foundation_Virtual_Attended__c.Day());
                            milestone1.JBCXM__Comment__c = contact.FirstName + ' ' + contact.LastName + ' attended the Foundation Training.';
                            
                            //Add in list
                            jBCXMilestones.add(milestone1);
                        }   
                    }
                }
            }
        }
        
        //try-Catch block
        try {
            
            //Check for list size
            if(jBCXMilestones.size() > 0)
                insert jBCXMilestones;
        } catch (Exception e) {
            
            //Create Log record in case of error
            JBCXM__Log__c errorLog = New JBCXM__Log__c();
            
            //Populate field with values
            errorLog.JBCXM__ExceptionDescription__c = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber() 
                                                       +' while running the Trigger to create Milestones from Contacts';
            errorLog.JBCXM__LogDateTime__c = datetime.now();
            errorLog.JBCXM__SourceData__c = e.getMessage();
            errorLog.JBCXM__SourceObject__c = 'Contact';
            errorLog.JBCXM__Type__c = 'GainsightContactTrigger Trigger';
            
            //Insert
            insert errorLog;
        }
    }
    /**
     * @Description  :  Method to process portal users related to Contact   
     *
     * @args         :  List<Contact>, Map<Id,Contact>
     *
     * @return       :  void
     *
     **/
     public static void synchWithBoulderLogic(List<Contact> newContacts, Map<Id,Contact> mapOldContacts){
        
        //Set to hold contact id
        List<Id> contactIds = new List<Id>();
         
        //Loop throug contact
        for(Contact con : newContacts){
            
            //Check the condition 
            if (con.BL__SynchWithBoulderLogic__c == true && mapOldContacts.get(con.Id).BL__SynchWithBoulderLogic__c != true){
                
                //add contact Id's 
                contactIds.add(con.Id);
            }
         }
         
         //Map to hold the contact
         List<User> users = [SELECT Id, Email,ContactId from User Where isActive = true AND IsPortalEnabled = true AND ContactId IN : contactIds ];
         
         //Check the of user list
         if(users.size()>0){
             
             //Call the batch class(BadgeVilleBatchApexWebCalloutClass)and pass the arguments
             BadgeVilleBatchApexWebCalloutClass batchClass = new BadgeVilleBatchApexWebCalloutClass(contactIds,Constants.CONTACT_STRING_SYNCHWITHBOULDERLOGIC);
             database.executebatch(batchClass,1);
         }
     }
}