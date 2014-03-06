trigger AutoCloseMilestoneOnCaseClose on Case (before insert, after insert, before update, after update) {
    
    if(trigger.isBefore) {

        if(CaseTriggerUtility.AutoCloseMilestoneOnCaseCloseisBeforeUpdate == true)  { return; }
        CaseTriggerUtility.AutoCloseMilestoneOnCaseCloseisBeforeUpdate = true;

        System.debug('Entering before trigger');
        String userType = UserInfo.getUserType();
        System.Debug('Size: #### ' + Trigger.Size);
        System.Debug('Contact : #### ' + Trigger.new[0].ContactId);
        
        //if (userType != 'Standard')
        Contact caseContact = new Contact();
        if (Trigger.Size == 1){
            
            Boolean isEmailOrigin = false;
            Boolean isStandardUser = false;
            Set<String> emailSet = new Set<String>();
            Id attachedContactID = null;
            for(Case c :trigger.new) {
                emailSet.add(c.SuppliedEmail);
                
                if(c.Origin != null && c.Origin.equals('Email')) {
                    isEmailOrigin = true;
                }
                //Added by bikram 4088
                if(c.ContactId != null) {
                    try {
                    caseContact = [SELECT Id,Email,Redirect_To_Case_Create__c from Contact WHERE Id = :c.ContactId LIMIT 1];
                    emailSet.add(caseContact.Email);
                    attachedcontactId = caseContact.Id;
                    }catch(Exception ex) {caseContact = null; system.debug('Exception==>' + ex); }
                }
                
                if(userType == 'Standard') {
                    /*
                    //Commented by bikram 4088                    
                    if(c.ContactId != null) {
                        Contact caseContact = [SELECT Id,Email from Contact WHERE Id = :c.ContactId LIMIT 1];
                        emailSet.add(caseContact.Email);
                    }    
                    //Commented by bikram 4088                    
                    */
                    isStandardUser = true;
                }
            }
            
            List<Authorized_Contact__c> authConList = [Select a.Email__c, a.Contact__c, a.Entitlement__c From Authorized_Contact__c a where Email__c in :emailSet AND a.Email__c != null];
            Set<String> authEmailSet = new Set<String>();
            Set<id> authConIds = new Set<Id>();
            Set<id> authEntIds = new Set<Id>();
            
            for(Authorized_Contact__c ac :authConList) {
                authEmailSet.add(ac.Email__c);
                authConIds.add(ac.Contact__c);
                authEntIds.add(ac.Entitlement__c);
            }
            
            //Added for asset entitlement bug fix major change temp only email to case
            if(trigger.isInsert && isEmailOrigin && isStandardUser && attachedcontactId != null && (authConList.isEmpty() == TRUE)) {
                System.debug('<=Entering Insert Trigger=>');                    
                List<User> emailUserList = [select id, Email, Munchkin_ID__c from User where ContactId =: attachedcontactId  AND Munchkin_ID__c != null and isActive = true];
                if(emailUserList.isEmpty() == FALSE ) {
                    List<Entitlement> entlList = [Select id, e.Asset.Munchkin_ID__c, e.AssetId, of_Active_Authorized_Contacts_Available__c From Entitlement e 
                    where Asset.Munchkin_ID__c = :emailUserList[0].Munchkin_ID__c  and Status = 'Active' limit 1];  
                    if(entlList.isEmpty() == FALSE) {
                        trigger.new[0].Count_AuthContact_Available__c = entlList[0].of_Active_Authorized_Contacts_Available__c;                                             
                        if(caseContact != null && caseContact.Redirect_To_Case_Create__c != true) {
                            system.debug('Count found==>' + entlList[0].of_Active_Authorized_Contacts_Available__c);
                            try{ 
                                caseContact.Redirect_To_Case_Create__c = true;
                                update caseContact;
                            } catch (Exception ex){system.debug('Exception==>' + ex);}
                        }
                    } else {
                        system.debug('Count not found==>' + emailUserList[0].Munchkin_ID__c);                    
                    }                                                                 
                }    
            }    
            //Added Code section ends
            
            String currUserMunchkinId;
                
            if(!isEmailOrigin && !isStandardUser) {
                List<User> userList = [select id, Munchkin_ID__c from User where id = :UserInfo.getUserId()];
                
                if(userList != null && userList.size() > 0) {
                    currUserMunchkinId = userList[0].Munchkin_ID__c;
                }
            }           
            
            
            if(isEmailOrigin) {
                List<User> emailUserList = [select id, Email, Munchkin_ID__c from User where ContactId in :authConIds AND Munchkin_ID__c != null];                
                if(emailUserList != null && emailUserList.size() > 0) {
                    currUserMunchkinId = emailUserList[0].Munchkin_ID__c;
                }
            }
            
            List<Entitlement> entlList = [Select id, e.Asset.Munchkin_ID__c, e.AssetId From Entitlement e 
            where Asset.Munchkin_ID__c = :currUserMunchkinId and Asset.Munchkin_ID__c != null and Status = 'Active' limit 1];
                        
            List<Asset> assetList = [Select id, Munchkin_ID__c from Asset a where Munchkin_ID__c = :currUserMunchkinId limit 1];
            
            // List of entitlements for when case is created by a standard user
            List<Entitlement> standardEntList = [Select id, e.Asset.Munchkin_ID__c, e.AssetId From Entitlement e 
            where Id in :authEntIds AND Status = 'Active' limit 1];          
                        
            for(Case c :trigger.new) {
                
                //Added by bikram 4088
                if(authConList.isEmpty() == false) {
                    if(c.Origin == 'Email' && authEmailSet != null && authEmailSet.contains(c.SuppliedEmail) && entlList != null && entlList.size() > 0) {
                        System.debug('Adding Entitlement');
                        c.EntitlementId = entlList[0].id;
                    }
                }
                
                //Added by bikram 4088
                if(authConList.isEmpty() == false) {
                    if(entlList != null && entlList.size() > 0 && assetList != null && assetList.size() > 0) {
                        System.debug('Adding Entitlement');
                        c.EntitlementId = entlList[0].id;
                        System.debug('Adding Asset');
                        c.AssetId = assetList[0].id;
                    }
                }

                //Added by bikram 4088
                if(authConList.isEmpty() == false) {               
                    if(isStandardUser && !isEmailOrigin) {
                        System.debug('Adding entitlement as standard user');
                        if(authConList != null && standardEntList != null && standardEntList.size() > 0) {
                            c.EntitlementId = standardEntList[0].id;
                            System.debug('Adding asset as standard user');
                            c.AssetId = standardEntList[0].AssetId;//Added by bikram  4149
                        }
                    }
                }
            }
        }
    }
    
    if(trigger.isAfter) {
    
        if(CaseTriggerUtility.AutoCloseMilestoneOnCaseCloseisAfterUpdate== true) return;
        CaseTriggerUtility.AutoCloseMilestoneOnCaseCloseisAfterUpdate = true;
    
        Set<Id> caseIds = new Set<Id>();
        for(Case c :trigger.new) {
            if(trigger.isInsert) {
                if(c.Origin != null && c.Origin.equals('Phone'))
                    caseIds.add(c.id);
            } else if(trigger.isUpdate) {
                Case caseOld = System.trigger.oldMap.get(c.id);
                if(!caseOld.isClosed && c.isClosed) {
                    caseIds.add(c.id);
                }
            }
        }
        
        if(caseIds != null) {
            if(trigger.isInsert) {
                MilestoneUtils.completeMilestoneFuture(caseIds, 'First Response', System.now());
            } else if(trigger.isUpdate) {
                MilestoneUtils.completeMilestone(caseIds, 'Resolution', System.now());
            }
        }
    }
}