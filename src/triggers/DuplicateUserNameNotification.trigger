trigger DuplicateUserNameNotification on User (after insert, after update) {
    Map<String, Quote_Approvers__c> quoteApproversMap = Quote_Approvers__c.getAll();
    
    // **** New User Creation ****
    if(Trigger.isInsert){
        for(User u :Trigger.new){
            string userFullName = u.FirstName + ' ' + u.LastName;
            if(quoteApproversMap.get(userFullName) != null){
                system.debug('user found---'+userFullName);
                DuplicateUserNameNotificationController.userIDSet.add(u.id);
            }
        }
    }
    
    // **** Existing User Name is Updated ****
    if(Trigger.isUpdate){
        for(User u :Trigger.new){
            if(u.FirstName != Trigger.oldMap.get(u.id).FirstName || u.LastName != Trigger.oldMap.get(u.id).LastName){
                string userFullName = u.FirstName + ' ' + u.LastName;
                if(quoteApproversMap.get(userFullName) != null){
                    system.debug('user found---'+userFullName);
                    DuplicateUserNameNotificationController.userIDSet.add(u.id);
                }
            }
        }
    }
    
    // **** If any duplicate user found, send an email alert to Admin ****
    if(DuplicateUserNameNotificationController.userIDSet.size() > 0){
        List<String> emailAddresses = new List<String>();
        Set<String> userIdSet = new Set<String>();
        string targetObjectId = '';
        for(String userId :Label.UsersToBeNotified.deleteWhitespace().split(',')){
            userIdSet.add(userId);
            targetObjectId = userId;
        }
        
        userIdSet.remove(targetObjectId);
        
        for(User u :[Select id, Email from User where Id in :userIdSet]){
            emailAddresses.add(u.Email);
        }
        
        string emailTemplateId = [select Id from EmailTemplate where DeveloperName = 'DuplicateUserNotificationTemplate'].Id;
        
        if(emailAddresses.size() > 0 || (targetObjectId != '' && targetObjectId.length() > 0)){
            Messaging.SingleEmailMessage notificationEmail = new Messaging.SingleEmailMessage();
            if(emailAddresses.size() > 0)
                notificationEmail.setToAddresses(emailAddresses);
            notificationEmail.setTemplateId(emailTemplateId);
            notificationEmail.setTargetObjectId(targetObjectId);
            notificationEmail.saveAsActivity = FALSE;
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { notificationEmail });
        }
    }
}