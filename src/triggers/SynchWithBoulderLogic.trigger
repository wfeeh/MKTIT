trigger SynchWithBoulderLogic on Contact (after insert, after update) {    
    List<Id> portalUserIds = new List<Id>();
    List<Id> contactIds = new List<Id>();

    for(Contact contact : Trigger.new){        
        if(Trigger.isInsert){
            if (contact.BL__SynchWithBoulderLogic__c == true){
                contactIds.add(contact.id);                               
            }
        }
        if(Trigger.isUpdate){
            Contact oldContact = Trigger.oldMap.get(contact.Id);
            if (oldContact.BL__SynchWithBoulderLogic__c != true && contact.BL__SynchWithBoulderLogic__c  == true){
                contactIds.add(contact.id);                                
            }     
        }
    }
    
    if(contactIds.isEmpty() == TRUE) return;
    system.debug('contactIds==>' + contactIds);
    Map<Id,User> portalUsers = new Map<Id,User>([SELECT Id, Email,ContactId from User Where isActive = true AND IsPortalEnabled = true AND ContactId in : contactIds ]);
    if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == FALSE) return;

    system.debug('portalUsers==>' + portalUsers);
    BadgeVilleBatchApexWebCalloutClass bv = new BadgeVilleBatchApexWebCalloutClass(contactIds,'synchwithboulderlogic');
    database.executebatch(bv,1);  
    
}