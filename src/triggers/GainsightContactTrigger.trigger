trigger GainsightContactTrigger on Contact (before update) 
{
    try
    {
        List<JBCXM__Milestone__c> MilestonesToInsert = new List<JBCXM__Milestone__c>();
        
        //Create a Map of all the Contacts Accounts
        Set<Id> AccountSet = new Set<Id>();

        for(Contact C : Trigger.New)
        {
            AccountSet.add(C.AccountId);
        }

        //Create a Map of all the Accounts
        Map<Id,Account> AccountMap = new Map<Id,Account>();

        for(Account A : [SELECT Id,JBCXM__CustomerInfo__c,JBCXM__CustomerInfo__r.JBCXM__ASV__c,JBCXM__CustomerInfo__r.JBCXM__MRR__c FROM Account WHERE Id IN :AccountSet])
        {
            AccountMap.put(A.Id,A); 
        }

        //Create a Map of all the Milestone types
        Map<String,JBCXM__PickList__c> MilestonePicklistMap = new Map<String,JBCXM__PickList__c>();

        for(JBCXM__PickList__c PL : [SELECT Id,JBCXM__SystemName__c FROM JBCXM__PickList__c WHERE JBCXM__Category__c='Milestones' AND JBCXM__Active__c=true])
        {
            MilestonePicklistMap.put(PL.JBCXM__SystemName__c,PL);   
        }

        for(Contact C : Trigger.New)
        {
            //Check if Contact has an Account and is still with the company
            if(C.AccountId != null && C.No_Longer_with_Company__c == FALSE)
            {
                //Make sure the Contact has an Account and associated Customer Info record
                if(AccountMap.get(C.AccountId).JBCXM__CustomerInfo__c != null)
                {
                    //Check if Foundation Classroom was attended
                    if(Trigger.oldMap.get(C.ID).EDU_Foundation_Classroom_Attended__c != C.EDU_Foundation_Classroom_Attended__c && C.EDU_Foundation_Classroom_Attended__c != null)
                    {
                        //If results found, make Milestone
                        if(MilestonePicklistMap.containsKey('Foundation Classroom'))
                        {
                            JBCXM__Milestone__c Milestone = new JBCXM__Milestone__c(JBCXM__Account__c=C.AccountId,
                                                                                    JBCXM__Milestone__c=MilestonePicklistMap.get('Foundation Classroom').Id,
                                                                                    JBCXM__Date__c=DateTime.newInstance(C.EDU_Foundation_Classroom_Attended__c.Year(), C.EDU_Foundation_Classroom_Attended__c.Month(), C.EDU_Foundation_Classroom_Attended__c.Day()),
                                                                                    JBCXM__Comment__c=C.FirstName + ' ' + C.LastName + ' attended the Foundation Training.');
                                                                                    
                            MilestonesToInsert.add(Milestone);
                        }                       
                    }

                    //Check if Foundation Virtual was attended
                    if(Trigger.oldMap.get(C.ID).EDU_Foundation_Virtual_Attended__c != C.EDU_Foundation_Virtual_Attended__c && C.EDU_Foundation_Virtual_Attended__c != null)
                    {
                        //If results found, make Milestone
                        if(MilestonePicklistMap.containsKey('Foundation Virtual'))
                        {
                            JBCXM__Milestone__c Milestone = new JBCXM__Milestone__c(JBCXM__Account__c=C.AccountId,
                                                                                    JBCXM__Milestone__c=MilestonePicklistMap.get('Foundation Virtual').Id,
                                                                                    JBCXM__Date__c=DateTime.newInstance(C.EDU_Foundation_Virtual_Attended__c.Year(), C.EDU_Foundation_Virtual_Attended__c.Month(), C.EDU_Foundation_Virtual_Attended__c.Day()),
                                                                                    JBCXM__Comment__c=C.FirstName + ' ' + C.LastName + ' attended the Foundation Training.');
                                                                                    
                            MilestonesToInsert.add(Milestone);
                        }                       
                    }   
                }
            }
        }

        insert MilestonesToInsert;
    }
    catch (Exception e) {
        JBCXM__Log__c errorLog = New JBCXM__Log__c(JBCXM__ExceptionDescription__c   = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber()+' while running the Trigger to create Milestones from Contacts',
                                                   JBCXM__LogDateTime__c            = datetime.now(),
                                                   JBCXM__SourceData__c             = e.getMessage(),
                                                   JBCXM__SourceObject__c           = 'Contact',
                                                   JBCXM__Type__c                   = 'GainsightContactTrigger Trigger');
        insert errorLog;
        system.Debug(errorLog.JBCXM__ExceptionDescription__c);
        system.Debug(errorLog.JBCXM__SourceData__c);
    }
}