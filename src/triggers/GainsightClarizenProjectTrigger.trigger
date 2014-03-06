trigger GainsightClarizenProjectTrigger on clzV5__Clarizen_Project__c (after insert, after update) 
{
    try
    {
        List<JBCXM__Milestone__c> MilestonesToInsert = new List<JBCXM__Milestone__c>();

        //Create a Map of all the Projects Accounts
        Set<Id> AccountSet = new Set<Id>();

        for(clzV5__Clarizen_Project__c CP : Trigger.New)
        {
            AccountSet.add(CP.clzV5__CLZ_Customer__c);
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

        for(clzV5__Clarizen_Project__c CP : Trigger.New)
        {
            if(CP.clzV5__CLZ_Customer__c != null)
            {
                //Make sure the Account is a Customer of Gainsight and proper Project Family
                if(AccountMap.get(CP.clzV5__CLZ_Customer__c).JBCXM__CustomerInfo__c != null && CP.CLZ_C_ProjectFamily__c == 'MLMLP')
                {
                    if(Trigger.isInsert)
                    {
                        //Make sure Start Date is filled
                        if(CP.clzV5__CLZ_StartDate__c != null)
                        {
                            //If results found, make Milestone
                            if(MilestonePicklistMap.containsKey('Proj Start'))
                            {
                                JBCXM__Milestone__c Milestone = new JBCXM__Milestone__c(JBCXM__Account__c=CP.clzV5__CLZ_Customer__c,
                                                                                        JBCXM__Milestone__c=MilestonePicklistMap.get('Proj Start').Id,
                                                                                        JBCXM__Date__c=CP.clzV5__CLZ_StartDate__c,
                                                                                        JBCXM__Comment__c=CP.Project_Type_Name__c);
                                                                                        
                                MilestonesToInsert.add(Milestone);
                            }   
                        }
    
                        //Make sure Due Date is filled
                        if(CP.clzV5__CLZ_DueDate__c  != null)
                        {
                            //If results found, make Milestone
                            if(MilestonePicklistMap.containsKey('Proj Due'))
                            {
                                JBCXM__Milestone__c Milestone = new JBCXM__Milestone__c(JBCXM__Account__c=CP.clzV5__CLZ_Customer__c,
                                                                                        JBCXM__Milestone__c=MilestonePicklistMap.get('Proj Due').Id,
                                                                                        JBCXM__Date__c=CP.clzV5__CLZ_DueDate__c,
                                                                                        JBCXM__Comment__c=CP.Project_Type_Name__c);
                                                                                        
                                MilestonesToInsert.add(Milestone);
                            }
                        }               
                    }
                    else if(Trigger.isUpdate)
                    {
                        //Make sure Project End Date is filled -- and was not previously
                        if(Trigger.oldMap.get(CP.ID).CLZ_C_ProjectEndDate__c != CP.CLZ_C_ProjectEndDate__c && CP.CLZ_C_ProjectEndDate__c != null)
                        {
                            //If results found, make Milestone
                            if(MilestonePicklistMap.containsKey('Proj Compl'))
                            {
                                JBCXM__Milestone__c Milestone = new JBCXM__Milestone__c(JBCXM__Account__c=CP.clzV5__CLZ_Customer__c,
                                                                                        JBCXM__Milestone__c=MilestonePicklistMap.get('Proj Compl').Id,
                                                                                        JBCXM__Date__c=CP.CLZ_C_ProjectEndDate__c,
                                                                                        JBCXM__Comment__c=CP.Project_Type_Name__c);
                                                                                        
                                MilestonesToInsert.add(Milestone);
                            }   
                        }   
                    }
                }
            }
        }

        insert MilestonesToInsert;  
    }
    catch (Exception e) {
        JBCXM__Log__c errorLog = new JBCXM__Log__c(JBCXM__ExceptionDescription__c   = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber()+' while running the Trigger to create Milestones from Clarizen Projects',
                                                   JBCXM__LogDateTime__c            = datetime.now(),
                                                   JBCXM__SourceData__c             = e.getMessage(),
                                                   JBCXM__SourceObject__c           = 'clzV5__Clarizen_Project__c',
                                                   JBCXM__Type__c                   = 'GainsightClarizenProjectTrigger Trigger');
        insert errorLog;
        system.Debug(errorLog.JBCXM__ExceptionDescription__c);
        system.Debug(errorLog.JBCXM__SourceData__c);
    }
}