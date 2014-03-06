trigger UpdateTimeZoneOnContact on User (after update, after insert) {
/*-------------------------------------------------------------------
     Requirement
     Update Timezone field On Contact Asscoiated with Authorized User
-------------------------------------------------------------------
     Pseudo Code
     Fetch contact associated with this user
     Fetch Time Zone from User 
     Update this time zone to contact field
-------------------------------------------------------------------     
    Algorithm
    if (Trigger.isInsert && Trigger.isAfter ) {
        for(User currUserToBeInserted: Trigger.new){
            If (User.oldTimeZone != User.newTimeZone){
                List<User> authorizedUser = Select Id,contactId From User where Contact.Customer_Portal_User__c = true and Contact.Is_Authorized_Contact__c = 'Yes'
                Map<UserId,ContactId> userIdToContactId
                List<ContactId> ContactIds 
                for(User tempUser : authorizedUser){
                    contactId.add(tempUser.ContactId);
                    userIdToContactId.add(tempUser.id,tempUser.ContactId);
                }
                List<Contact> contactsToBeUpdated;
                Map<ContactId,Contact> contactIdToContact = [Select Id, Time_Zone__c from Contact where Id IN contactId];
                userIdToContactId.get(currUserToBeInserted.Id);
                Contact tempContact  = contactIdToContact.get(userIdToContactId.get(currUserToBeInserted.Id));
                tempContact.timeZone = currUserToBeInserted.timeZoneSidKey
                contactsToBeUpdated.add(tempContact);
            }
        }
     } 
      update contactsToBeUpdated     
---------------------------------------------------------------------------*/
    Map<String,UserTimeZoneUpdate__c> myMap = new Map<String,UserTimeZoneUpdate__c>();
    myMap = UserTimeZoneUpdate__c.getAll();
    if(myMap.size() == 0 || myMap.get('Setting').ActivateTimeZoneTrigger__c != true) return; 
    If(ContactTimeZone.oneTimeUpdate == false){return;}
    ContactTimeZone.oneTimeUpdate = false;
    Set<Id> userIdsTobeUpdated    = new Set<Id>();
    List<Id> contactIdsToBeUpdated = new List<Id>();
    for(User currUpdatedUser: Trigger.new){
        If(Trigger.IsUpdate){
            if(Trigger.newMap.get(currUpdatedUser.Id).TimeZoneSidKey != Trigger.oldMap.get(currUpdatedUser.Id).TimeZoneSidKey){   
                userIdsTobeUpdated.add(currUpdatedUser.id); 
                contactIdsToBeUpdated.add(currUpdatedUser.contactid); 
            }
        }else{
            userIdsTobeUpdated.add(currUpdatedUser.id); 
            contactIdsToBeUpdated.add(currUpdatedUser.contactid);     
        }
    }  
    List<User> authorizedUsers = [Select Id, contactId, TimeZoneSidKey From User where 
                                                        Contact.Customer_Portal_User__c = true and
                                                        Contact.Is_Authorized_Contact__c = 'Yes' and 
                                                        Contact.Account.Type != 'Ex-Customer' and
                                                        id in:userIdsTobeUpdated];
    
    Map <Id, contact> contactIdToContact = new Map<id, contact>([Select Id, Time_Zone__c from Contact where Id IN : contactIdsToBeUpdated]);
    Map <Id, contact> userIDToContact = new Map <Id, contact>();
    for (User usr:authorizedUsers ) {
        userIDToContact.put(usr.id, contactIdToContact.get(usr.contactid)); 
    }

    List<Contact> contactsToBeUpdated = new List<Contact>();
    Map<Id,String> contactIdToTimeZone = new Map<Id,String>();
    
    for (User usr:authorizedUsers) {
        userIDToContact.get(usr.id).Time_Zone__c = usr.TimeZoneSidKey;
        contactsToBeUpdated.add(userIDToContact.get(usr.id)); 
        contactIdToTimeZone.put(usr.ContactId, usr.TimeZoneSidKey);
    }
    If(Trigger.IsUpdate)
        update contactsToBeUpdated;
    If(Trigger.IsInsert)
        ContactTimeZone.UpdateTimeZone(contactIdsToBeUpdated,contactIdToTimeZone);
}