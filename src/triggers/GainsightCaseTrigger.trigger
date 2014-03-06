trigger GainsightCaseTrigger on Case (after insert, before update, before delete) 
{
    try
    {
        set<id> AccountIDSet = new set<id>();
        map<string, JBCXM__Alert__c> AlertMap = new map<string, JBCXM__Alert__c>();
        List<Case> CaseList = (Trigger.isDelete) ? Trigger.Old : Trigger.New;
        Set<Id> CaseIds = (Trigger.isDelete) ? Trigger.oldMap.keySet() : Trigger.newMap.keySet();

        for (JBCXM__Alert__c A : [SELECT Id,JBCXM__AssociatedObjectRecordID__c FROM JBCXM__Alert__c WHERE JBCXM__AssociatedObjectRecordID__c IN :CaseIds])
        {
            AlertMap.put(A.JBCXM__AssociatedObjectRecordID__c, A);
        }

        for(case c : CaseList)
        {
            AccountIDSet.add(c.AccountId);
        } 

        map<string, JBCXM__CustomerInfo__c> CustInfoMap = new map<string, JBCXM__CustomerInfo__c>();

        for (JBCXM__CustomerInfo__c CI : [SELECT Id,JBCXM__ASV__c,JBCXM__MRR__c,JBCXM__Account__c FROM JBCXM__CustomerInfo__c WHERE JBCXM__Account__c in :AccountIDSet ])
        {
            CustInfoMap.put(CI.JBCXM__Account__c, CI);

        }

        list<JBCXM__Alert__c> AlertsToInsert = new list<JBCXM__Alert__c>();
        list<JBCXM__Alert__c> AlertsToDelete = new list<JBCXM__Alert__c>();

        for(case c : CaseList)
        {
            if (trigger.isinsert)
            {
                if(c.accountid != null && c.priority == 'P1')
                {
                    if(CustInfoMap.containskey (c.AccountId))
                    {   

                        JBCXM__CustomerInfo__c CI = CustInfoMap.get(c.AccountId);

                        JBCXM__Alert__c alert       = new JBCXM__Alert__c();
                        alert.Name                  = 'New P1 Case has been logged';    
                        alert.JBCXM__Account__c     = c.AccountId;
                        alert.JBCXM__ASV__c         = ((CI.JBCXM__ASV__c) != null ? CI.JBCXM__ASV__c : 0);
                        alert.JBCXM__Comment__c     = 'An open P1 case has been logged and needs to be reviewed.<br><br><a target="_blank" href="' + URL.getSalesforceBaseUrl().toExternalForm().replace('-api','') + '/' + C.Id + '">Case ' + C.CaseNumber + '</a>';
                        alert.JBCXM__Date__c        = Date.today();
                        alert.JBCXM__MRR__c         = ((CI.JBCXM__MRR__c) != null ? CI.JBCXM__MRR__c : 0);
                        alert.JBCXM__Severity__c    = GainsightDAL.GetAlertSeverityBySystemName('alertseverity1').Id;
                        alert.JBCXM__Status__c      = GainsightDAL.GetAlertStatusBySystemName('ID').Id;
                        alert.JBCXM__Type__c        = GainsightDAL.GetAlertTypeBySystemName('Customer Concern').Id;
                        alert.JBCXM__Reason__c      = (GainsightDAL.GetAlertReasonBySystemName('OpenCase') != null) ? GainsightDAL.GetAlertReasonBySystemName('OpenCase').Id : '';
                        alert.JBCXM__AssociatedObjectRecordID__c = C.Id;

                        AlertsToInsert.add (alert);
                
                    }
                }
            } 
            else if (trigger.isupdate)
            {
                if (Trigger.oldMap.get(c.Id).Priority == 'P1'  && trigger.oldmap.get(c.id).priority != c.priority)
                {
                    if(AlertMap.containsKey(C.Id))
                    {
                        AlertsToDelete.add(AlertMap.get(C.Id));
                    }
                }
                else if(Trigger.oldMap.get(c.Id).Priority != 'P1'  && C.priority == 'P1' && C.accountid != null)
                {
                    
                    if(CustInfoMap.containskey(c.AccountId))
                    {   

                        JBCXM__CustomerInfo__c CI = CustInfoMap.get(c.AccountId);

                        JBCXM__Alert__c alert       = new JBCXM__Alert__c();
                        alert.Name                  = 'New P1 Case has been logged';    
                        alert.JBCXM__Account__c     = c.AccountId;
                        alert.JBCXM__ASV__c         = ((CI.JBCXM__ASV__c) != null ? CI.JBCXM__ASV__c : 0);
                        alert.JBCXM__Comment__c     = 'An open P1 case has been logged and needs to be reviewed.<br><br><a target="_blank" href="' + URL.getSalesforceBaseUrl().toExternalForm().replace('-api','') + '/' + C.Id + '">Case ' + C.CaseNumber + '</a>';
                        alert.JBCXM__Date__c        = Date.today();
                        alert.JBCXM__MRR__c         = ((CI.JBCXM__MRR__c) != null ? CI.JBCXM__MRR__c : 0);
                        alert.JBCXM__Severity__c    = GainsightDAL.GetAlertSeverityBySystemName('alertseverity2').Id;
                        alert.JBCXM__Status__c      = GainsightDAL.GetAlertStatusBySystemName('ID').Id;
                        alert.JBCXM__Type__c        = GainsightDAL.GetAlertTypeBySystemName('Customer Concern').Id;
                        alert.JBCXM__Reason__c      = (GainsightDAL.GetAlertReasonBySystemName('OpenCase') != null) ? GainsightDAL.GetAlertReasonBySystemName('OpenCase').Id : '';
                        alert.JBCXM__AssociatedObjectRecordID__c = C.Id;

                        AlertsToInsert.add (alert);
                    }
                }
            }
            else if(Trigger.isDelete)
            {
                if(AlertMap.containsKey(C.Id))
                {
                    AlertsToDelete.add(AlertMap.get(C.Id));
                }   
            }
        }

        if(AlertsToInsert.size() > 0) insert AlertsToInsert;
        if(AlertsToDelete.size() > 0) delete AlertsToDelete;

    }
    catch (Exception e) {
        JBCXM__Log__c errorLog = New JBCXM__Log__c(JBCXM__ExceptionDescription__c   = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber()+' while running the Trigger to create alerts from P1 Cases',
                                                   JBCXM__LogDateTime__c            = datetime.now(),
                                                   JBCXM__SourceData__c             = e.getMessage(),
                                                   JBCXM__SourceObject__c           = 'Case',
                                                   JBCXM__Type__c                   = 'GainsightCaseTrigger Trigger');
        insert errorLog;
        system.Debug(errorLog.JBCXM__ExceptionDescription__c);
        system.Debug(errorLog.JBCXM__SourceData__c);
    }
}