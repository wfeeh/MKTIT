trigger sendAuthorizedContactAddedEmail on Authorized_Contact__c (after insert) {

    // Authroized Contact Entitlement => AdminContactId Map
    List<Id> entitlementLst = new List<ID>();
    Map<Id, Id> authEntl_AdminContMap = new Map<Id,Id>();        
    for(Authorized_Contact__c AuthCnt : Trigger.New) {        
        if(Trigger.IsInsert){ 
            if(AuthCnt.Entitlement__c != null && AuthCnt.Customer_Admin__c != true && AuthCnt.Contact__c != null) {     
                entitlementLst.add(AuthCnt.Entitlement__c);        
            }
        }
    }
    if(entitlementLst.isEmpty() == FALSE){
        List<Authorized_Contact__c> authAdminContactLst = new List<Authorized_Contact__c>();    
        authAdminContactLst = [SELECT Id, Contact__c, Entitlement__c from Authorized_Contact__c Where Entitlement__c in :entitlementLst   AND Customer_Admin__c = true];        
        if(authAdminContactLst.isEmpty() == FALSE) {
            for(Authorized_Contact__c authdmin : authAdminContactLst) {                
                authEntl_AdminContMap.put(authdmin.Entitlement__c ,authdmin.Contact__c);     
            }        
            Id templateId = [SELECT ID from EmailTemplate Where DeveloperName = 'Support_Authorized_Contact_Added_Notification' Limit 1].Id;   
            Id FROM_EMAIL_ID = [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Customer Support'].Id;                  
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            for(Authorized_Contact__c AuthCnt : Trigger.New) {        
                if(Trigger.IsInsert){ 
                    if(AuthCnt.Entitlement__c != null && AuthCnt.Customer_Admin__c != true && AuthCnt.Contact__c != null) {
                        if(authEntl_AdminContMap.containsKey(AuthCnt.Entitlement__c)) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTemplateId(templateId);
                        email.setTargetObjectId(authEntl_AdminContMap.get(AuthCnt.Entitlement__c));
                        system.debug('@@@@@@@@@@'+authEntl_AdminContMap.get(AuthCnt.Entitlement__c));
                        email.setWhatId(AuthCnt.Id);
                        email.setSaveAsActivity(false);
                        email.setOrgWideEmailAddressId(FROM_EMAIL_ID);                                                        
                        emails.add(email);
                        }
                    }
                }
            }                       
            if(emails.isEmpty() == FALSE) { 
                 Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);                   
            }
        }    
    }    
}