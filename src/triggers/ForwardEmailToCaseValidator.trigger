Trigger ForwardEmailToCaseValidator on EmailMessage (before insert) {
    
    Map<Id, RecordType> caseRecordTypes = new Map<Id, RecordType>([Select r.Id, r.Name From RecordType r where  r.SobjectType='case' limit 10]); 
    
    Id smSupportId;
    Id smFeedbackId;
    List <Id> parentIds = new List<Id>();
    // Fetch all parent cases for email-messages in trigger
    for (EmailMessage em:Trigger.new) {
        parentIds.add(em.parentid);
    }    
    Map<Id, Case> cases = new Map<Id, Case>([Select r.Id, r.AccountId, r.ContactId, r.recordTypeId From case r where  r.Id in :parentIds]);
    
    for (Id recTypeKey:caseRecordTypes.keySet()) {
        if (caseRecordTypes.get(recTypeKey).Name == 'Situation Management - Support') {
           smSupportId = recTypeKey;
        }
        if (caseRecordTypes.get(recTypeKey).Name == 'Situation Management - Support Feedback') {
           smFeedbackId = recTypeKey;
        }        
    }
    
    System.Debug('smSupportId'+smSupportId);
    System.Debug('smFeedbackId'+smFeedbackId);
    System.Debug('caseRecordTypes'+caseRecordTypes);
    
    List<String> queueNames = new String[]{'Support Escalations Queue','Support Feedback Queue'};
    //Queue for escalated cases 00G50000001R8aa
    //Select c.OwnerId, c.Origin, c.Id From Case c where id='500W0000001HYCxIAO'
    List<QueueSobject> myQueuelist =  new List<QueueSobject>();
    myQueuelist =  [Select Id, QueueId,q.Queue.Name from QueueSobject q where q.Queue.Name in:queueNames];
    Map <String,Id> myQueueMap = new Map<String,Id>();
    for(QueueSobject qs : myQueuelist)
    {        
        if(qs.Queue.Name.equals('Support Feedback Queue')) {
            myQueueMap.put('supportfeedback',qs.QueueId);
        } else if(qs.Queue.Name.equals('Support Escalations Queue')) {
            myQueueMap.put('supportescalations',qs.QueueId);        
        }
    }  
    
    List<Case> newCases = new List<Case>();
    for (EmailMessage em:Trigger.new) {            
        //System.Debug ('EmailMessageToAddress'+em.ToAddress);
        //System.Debug ('EmailMessageSubject'+em.subject);
        //System.Debug ('EmailMessageParentRecordTypeId'+em.Parentid+'Account'+em.Parent.AccountId);
        //System.Debug('EmailMessageRecordType'+caseRecordTypes.get(em.Parent.RecordTypeId).Name);        
        if (em.Subject != null &&  em.Subject.contains('Case #')) { // If email on existing case
            if ((em.ToAddress == 'supportescalations@marketo.com') && !(caseRecordTypes.get(cases.get(em.Parentid).RecordTypeId).Name.contains('Situation Management - Support'))) {                
                // Create New SM - Support record
                Case cs = new Case(Situation_Account__c=cases.get(em.Parentid).AccountId, Situation_Contact__c=cases.get(em.Parentid).ContactId, Subject=em.Subject, Description=em.TextBody, RecordTypeId=smSupportId,ParentId = em.ParentId,OwnerId=myQueueMap.get('supportescalations'));
                newCases.add(cs);
                System.Debug('In supportescalations');
                // em.addError('To address changed. New Record of respective type will be created');                
            } else if ((em.ToAddress == 'supportfeedback@marketo.com') && !(caseRecordTypes.get(cases.get(em.Parentid).RecordTypeId).Name.contains('Situation Management - Support Feedback'))) {
                // Create New SM - Feedback record
                Case cs = new Case(Situation_Account__c=cases.get(em.Parentid).AccountId, Situation_Contact__c=cases.get(em.Parentid).ContactId, Subject=em.Subject, Description=em.TextBody, RecordTypeId=smFeedbackId,ParentID = em.ParentId, OwnerId=myQueueMap.get('supportescalations'));
                System.Debug('In supportfeedback');
                // em.subject = 'Subject replaced';
                newCases.add(cs);                
                // em.addError('To address changed. New Record of respective type will be created');                
            }                
        }        
    }    
    if (newCases.size() > 0) {
        insert newCases;
    }
}