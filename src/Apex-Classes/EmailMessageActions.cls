public with sharing class EmailMessageActions {
   
    private static Boolean emailAction = false;    
    public static Boolean isEmailAction() {
        return emailAction;
    }

    public void doAfterInsert(List<EmailMessage> messages) {
        //collect all the caseIds
        //System.debug('Email messages=>' + messages);
        Set<Id> caseIds = new Set<Id>();
        for(EmailMessage emailObj : messages) {            
            if (emailObj.ParentId != null) {
                if(emailObj.Incoming == false){
                    caseIds.add(emailObj.ParentId);
                } else if(emailObj.Subject != null && emailObj.Subject.Contains('ref:_')){
                    caseIds.add(emailObj.ParentId);
                } 
            }            
        }
        Map<Id, Case> cases;
        RecordType recType = [select id, Name, Description from RecordType where sObjectType = 'Case' and Name = 'Support Cases' Limit 1]; 

        cases = new Map<Id, Case>([Select Id,RecordTypeID from Case where Id In :caseIds]);
               
        List<CaseComment> comments = new List<CaseComment>{};
        for(EmailMessage emailObj : messages) {
            if (emailObj.ParentId == null) continue;
            if (cases.containsKey(emailObj.ParentId)) {
                Boolean toPublish = true; Boolean isPortalSupportCase= false;
                if(cases.get(emailObj.ParentId).RecordTypeID == recType.Id) isPortalSupportCase = true;         
                if(cases.get(emailObj.ParentId).RecordTypeID != recType.Id && emailObj.Incoming == true) toPublish = false;                                                                                    
                comments.add(new CaseComment(
                    ParentId = emailObj.ParentId,
                    CommentBody = getEmailBody(emailObj,isPortalSupportCase),
                    IsPublished = toPublish));            
            }
        }
        
        if (comments.size() > 0) {
            //update temporary field to prevent workflow rule from firing
            List<Case> caseList = [SELECT Id,Prevent_Comment_Notifications__c from Case WHERE Id in :caseIds];
            for(Case caseUpdate : caseList) {
                caseUpdate.Prevent_Comment_Notifications__c = true;
            }
            update caseList;
            
            //make email actions true to stop updateCase trigger of comments
            emailAction = true;    
            try {           
                insert comments;                                    
            }
            catch (Exception ex) {
                String msgBody = 'Comment Insert Exception=>' + ex;
                System.debug(msgBody);                
            }
            for(Case caseUpdate : caseList) {
                caseUpdate.Prevent_Comment_Notifications__c = false;
            }
            update caseList;
        }
    }      
    
    
    public String getEmailBody(EmailMessage emailObj,Boolean isPortalSupportCase) {
        //System.debug('emailObj.TextBody==>'+emailObj.TextBody);
        String emailBody = (emailObj.TextBody == null) ? '' : emailObj.TextBody;
        emailBody.replaceAll('(<br>)\\1+','<br>');
        if(emailObj.Incoming == true && isPortalSupportCase)
        {
            if (emailBody.indexOfIgnoreCase('Marketo Customer Support <') > 0) {
                emailBody = emailBody.substring(0,emailBody.indexOfIgnoreCase('Marketo Customer Support <'));
            }
            if (emailBody.lastindexOfIgnoreCase('On') > 0) {
                emailBody =  emailBody.substring(0,emailBody.lastindexOfIgnoreCase('On'));
            }            
            emailBody = ' To: ' + emailObj.ToAddress + '\r\n' + ' From: ' + emailObj.FromAddress + '\r\n \r\n' + emailBody;                               
        }                
        if(emailBody.length() > 3970) 
        {
            emailBody = emailBody.substring(0,3970);
            emailBody += '\r\n<EMAIL TRUNCATED>'; 
        }   
        return emailBody;        
    }      
    
    public static testmethod void testEmailMessageActions() {
        Test.StartTest();
        Case caseObj = new Case(
            Subject = 'Test',
            Description = 'Description Test',
            Status = 'Open'
        );
        insert caseObj;
        
        CaseComment commentObj = new CaseComment(
            ParentId = caseObj.Id,
            CommentBody = 'test test test'
        );
        insert commentObj;
        
        EmailMessage emailObj = new EmailMessage(
            ParentId = caseObj.Id,
            TextBody = 'test test test'
        );
        insert emailObj;
        
        Test.StopTest();
    }    
}