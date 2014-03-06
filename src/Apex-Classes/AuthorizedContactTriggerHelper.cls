/**
 *  Description     :   Helper class for Trigger_AuthorizedContact trigger.
 *
 *  Created By      :   
 *
 *  Created Date    :   02/22/2014
 *
 *  Version         :   V_1.0
 *
 *  Revision Logs   :   V_1.0 - Created 
 *
 **/
public without sharing class AuthorizedContactTriggerHelper {
    
    /**
     * @Description  :  This method is used to validate Support Admin contact(field of entitlement) value with the Authorize contact value.
     *
     * @args         :  List<Authorized_Contact__c>, Map<Id,Authorized_Contact__c>
     *
     * @return       :  void
     *
    **/
    public static void validateAContact(List<Authorized_Contact__c> newAContacts, Map<Id, Authorized_Contact__c> mapOldAContacts){
        
        //Set to hold the authorize contact Id
        Set<Id> setAContactsIds = new Set<Id>();
        
        //Loop through Authorize Contact
        for(Authorized_Contact__c ac : newAContacts != null ? newAContacts : mapOldAContacts.values()){
            
            //Check the appropraite condition to fire the trigger
            if(ac.Contact__c != null && ac.Customer_Admin__c == true && ac.Entitlement__c != null && (mapOldAContacts == null 
                            || mapOldAContacts.get(ac.Id).Customer_Admin__c != ac.Customer_Admin__c)){
                
                //Add the value in set
                setAContactsIds.add(ac.Id);                 
            
            } else if(newAContacts == null){
                
                //Add the value in set
                setAContactsIds.add(ac.Id);
            }
        }
        
        //List to hold the entitlement values
        List<Entitlement> entitlements = new List<Entitlement>();
        
        //Loop through Entitlement
        for(Entitlement ent : [Select Id, Support_Admin_Contact__c, (Select Id, Contact__c, Customer_Admin__c,  LastModifiedDate From 
                                            Authorized_Contacts__r Where Contact__c != null AND Customer_Admin__c = true Order By LastModifiedDate DESC LIMIT 1)
                                            from Entitlement Where Id IN : setAContactsIds and Status =: Constants.ASSET_STATUS_ACTIVE]){
            
            //Check the size of authorize contact list
            if(ent.Authorized_Contacts__r.size() > 0){
                
                ent.Support_Admin_Contact__c = ent.Authorized_Contacts__r[0].Contact__c;
            } else{
                
                ent.Support_Admin_Contact__c = null;
            }
            
            //Add the value in list
            entitlements.add(ent);                                      
        }
        
        //check the size of list
        if(entitlements.size() > 0)
            update entitlements;
    }
    /**
     * @Description  :  This method is used sending notification of adding new Authorize Contact.
     *
     * @args         :  List<Authorized_Contact__c>
     *
     * @return       :  void
     *
    **/
    public static void sendingAuthConNotification(List<Authorized_Contact__c> newAContacts){
    
        //List to hold the authorize contact
        List<Authorized_Contact__c> authorizeContacts = new List<Authorized_Contact__c>();
        
        //Loop through authorize contact
        for(Authorized_Contact__c ac : newAContacts){
            
            //Check the appropriate condition to fire trigger
            if(ac.Entitlement__c != null && ac.Customer_Admin__c != true && ac.Contact__c != null){
                
                //Add the value in list
                authorizeContacts.add(ac);
            }
        }
        
        //Check the size of list
        if(authorizeContacts.size() > 0){
            
            //call the email handler class to send the email
            EmailHandler.emailToAuthorizeCon(authorizeContacts);
        }
    }
}