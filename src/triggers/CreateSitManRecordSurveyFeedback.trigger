trigger CreateSitManRecordSurveyFeedback on CSatSurveyFeedback__c (after insert) {
    Map<Id,Id> surveyFeedbackIdToCaseId = new Map<Id,Id>();

    if(Trigger.isInsert) {
    
        Set<Id> caseIds = new Set<Id>();  
        Set<Id> OwnerUsrIds = new Set<Id>();//List of case owners    
    
        //Owner queue for support feedback        
        /*
        List<String> queueNames = new String[]{'Support Feedback Queue'};
        Map <String,String> myQueueMap = new Map<String,String>();
        myQueueMap.put('supportfeedback','');        
        List<QueueSobject> myQueuelist =  new List<QueueSobject>();
        myQueuelist =  [Select Id, QueueId,q.Queue.Name from QueueSobject q where q.Queue.Name in:queueNames];
        for(QueueSobject qs : myQueuelist)
        {        
            if(qs.Queue.Name.equals('Support Feedback Queue')) {
                myQueueMap.put('supportfeedback',qs.QueueId);
            } 
        }*/        

        Id smSupportId;
        Map<Id, RecordType> caseRecordTypes = new Map<Id, RecordType>([Select r.Id, r.Name From RecordType r where  r.SobjectType='case' AND Name = 'Situation Management - Support' limit 1]);    
        for (Id recTypeKey:caseRecordTypes.keySet()) {
            if (caseRecordTypes.get(recTypeKey).Name == 'Situation Management - Support') {
               smSupportId = recTypeKey;
            }
        }
        
        for (CSatSurveyFeedback__c newSurvyFeedbck : Trigger.new ) {
            surveyFeedbackIdToCaseId.put(newSurvyFeedbck.Id,newSurvyFeedbck.Case__c);            
            caseIds.add(newSurvyFeedbck.Case__c);
        }
        
        Map<Id,Case> myCasesMap = new Map<Id,Case>([SELECT ID,ParentID,CaseNumber,OwnerId from Case Where Id in:caseIds]);
        
        for(Id myCaseK : myCasesMap.keySet()) {
            if(myCasesMap.get(myCaseK).OwnerId != null && !(myCasesMap.get(myCaseK).OwnerId+'').startsWith('00G'))
                OwnerUsrIds.Add(myCasesMap.get(myCaseK).OwnerId);                    
        }
        
        //Case owners if not be queue for surveyed case        
        MAP<ID,User> nonQueueUsrs = new Map<Id,User>([SELECT ID, ManagerId FROM USER WHERE ID In :OwnerUsrIds AND ManagerId != NULL]);          
        Set<ID> managerIds = new Set<Id>();
        for(User tmpUser : nonQueueUsrs.values()) { managerIds.add(tmpUser.ManagerId); }
        MAP<ID,User> smOwnerManagerUsrs = new Map<Id,User>([SELECT ID FROM USER WHERE isActive = true and ID In :managerIds]);
        
                                      
        List<Case> newCases = new List<Case>();
        for ( CSatSurveyFeedback__c newSurvyFeedbck : Trigger.new ) {
            if( (newSurvyFeedbck.Question_1__c == '1' || newSurvyFeedbck.Question_1__c == '2') ) //If not satisfied
            {
                if(myCasesMap.ContainsKey(newSurvyFeedbck.Case__c)) { //Check for map key failure
                    String smSub = 'Dissatisfied Survey Response on Case # ' + myCasesMap.get(newSurvyFeedbck.Case__c).CaseNumber;                            
                    String smDesc = newSurvyFeedbck.Question_7__c;
                    String smParentId = myCasesMap.get(newSurvyFeedbck.Case__c).Id;         
                    //String smManagerId = myQueueMap.get('supportfeedback');                    
                    //Get current case owner's manager id as new sm case owner id for non queue owners
                    if(nonQueueUsrs.containsKey(myCasesMap.get(newSurvyFeedbck.Case__c).OwnerId) && nonQueueUsrs.get(myCasesMap.get(newSurvyFeedbck.Case__c).OwnerId).ManagerId != null)
                    {
                        if(smOwnerManagerUsrs.containsKey(nonQueueUsrs.get(myCasesMap.get(newSurvyFeedbck.Case__c).OwnerId).ManagerId)) {
                            String smManagerId = nonQueueUsrs.get(myCasesMap.get(newSurvyFeedbck.Case__c).OwnerId).ManagerId;                                          
                            Case cs = new Case(Situation_Account__c=newSurvyFeedbck.Account__c,Situation_Contact__c=newSurvyFeedbck.Contact__c, Subject=smSub, Description=smDesc, Problem_Type__c = 'Survey Follow-up', RecordTypeId=smSupportId, ParentId = smParentId, OwnerId=smManagerId);
                            newCases.add(cs);            
                        }
                    }
                }
            }
        }    
        if(newCases.size() > 0) {
            insert newCases;
        }   
    }
    
    if(surveyFeedbackIdToCaseId.isEmpty() == false)
    {
        CSatSurvey.updateCSatOwners(surveyFeedbackIdToCaseId);
    }      

}