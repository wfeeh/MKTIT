trigger CustomMilestoneOnCases on Case (after update, after insert) {
     /*
    @Algorithm
        After Insert
            If Case.Origin != Phone
                Create Case Update Milestone 
                    CaseUpdateMilestone.Case           = CaseID 
                    CaseUpdateMilestone.Owner          = CaseOwnerID 
                    CaseUpdateMilestone.Milestone Type = “First Response”
                    CaseUpdateMilestone.Start Date     = Now()
                    CaseUpdateMilestone.Target Date    = (Initial Response on the Support Level & Priority of the Case see Matrix attached)
                    CaseUpdateMilestone.Duration       = (Initial Response on the Support Level & Priority of the Case see Matrix attached)
            else{
                 Create Case Update Milestone 
                    CaseUpdateMilestone.Case           = CaseID 
                    CaseUpdateMilestone.Owner          = CaseOwnerID(IF OWNER OF THE RECORD IS CHANGED SIMULTANEOUSLY UPDATE IT WITH NEW OWNER)  
                    CaseUpdateMilestone.Milestone Type = “First Response”
                    CaseUpdateMilestone.Start Date     = Now()
                    CaseUpdateMilestone.Completed      = true
            }
        After Update
            CaseUpdateMilestone =
            If Status is Not Closed
                If Owner Changes And Owner Is not Queue 
                        For Open Case Update Milestone
                            Set OwnerOfCaseUpdateMilestone = Owner of the parent case Changed    
                If Priority Changes
                    If StandardMilestone Exists
                        If First Response Milestone Is Not completed
                            Case.NextupdateDueFrmCum = target Date of First Response Milestone
                        Else If CaseUpdateMilestone Exists And CaseUpdateMilestone.Completed != true
                            If Priority INCREASES(EX: P3 TO P2)
                                Update The Existing Milestone
                                    CaseUpdateMilestone.CompletionDate = Now()
                                    CaseUpdateMilestone.Completed      = TRUE
                                    CaseUpdateMilestone.Violation      = False
                                    CaseUpdateMilestone.AutoComplete   = TRUE
                                And Create a new Case Update Milestone Record
                                    CaseUpdateMilestone.Case           = CaseID 
                                    CaseUpdateMilestone.Owner          = CaseOwnerID(IF OWNER OF THE RECORD IS CHANGED SIMULTANEOUSLY UPDATE IT WITH NEW OWNER)  
                                    CaseUpdateMilestone.Milestone Type = “Case Update”
                                    CaseUpdateMilestone.Start Date     = Now()
                                    CaseUpdateMilestone.Target Date    = (Initial Response on the Support Level & Priority of the Case see Matrix attached)
                                    CaseUpdateMilestone.Duration       = (Initial Response on the Support Level & Priority of the Case see Matrix attached)
                        Else If Priority DECREASES((EX: P2 TO P3))
                            Do Nothing
                If Status is changed to Closed from any other status
                    On Existing Milestone object, do the following:  
                        completiondate = Now()
                        completed      = true
                        If Completion Date > Target Date set Violation = TRUE
                        AutoComplete = FALSE
                If Status IsChanged to one of the ignoreCaseStatus List
                    If CaseUpdateMilestone EXISTS
                        Update the Milestone
                            Completed = true;
                            completionDate = now();
                    If CaseUpdateMilestone DO NOT EXIST
                        Do Nothing
                If Status IsChanged to Non-IgnoreCase Status
                    If Create a New CaseUpdateMilestone
                        CaseUpdateMilestone.Case           = CaseID 
                        CaseUpdateMilestone.Owner          = CaseOwnerID(IF OWNER OF THE RECORD IS CHANGED SIMULTANEOUSLY UPDATE IT WITH NEW OWNER)  
                        CaseUpdateMilestone.Milestone Type = “Case Update”
                        CaseUpdateMilestone.Start Date     = Now()
                        CaseUpdateMilestone.Target Date    = (CaseUpdate Response on the Support Level & Priority of the Case see Matrix attached)
                        CaseUpdateMilestone.Duration       = (CaseUpdate Response on the Support Level & Priority of the Case see Matrix attached)    
    */
    Map<String,CustomMilestoneSettings__c> myMap = new Map<String,CustomMilestoneSettings__c>();
    myMap = CustomMilestoneSettings__c.getAll();
    System.Debug('CustomMilestoneTest.firstRun+++'+CustomMilestoneTest.firstRun);
    if(myMap.size() == 0 || myMap.get('Custom Milestone').Custom_Milestone_Active__c != true) return;
    
    //if(CustomMilestoneTest.firstRun == false ) {return;}
    //CustomMilestoneTest.firstRun = false; 
    public List<SLA__c> slas =  [Select Support_Level__c, First_Response_NOM__c, Case_Update_Milestone_NOM__c, Priority__c, Resolution_NOM__c from SLA__c]; 
        List<RecordType> listOfSituationManagRecordIds = [Select Id From RecordType where SobjectType='Case' and (Name='Situation Management - Services' OR Name='Situation Management - Support' OR Name='Situation Management - Support Feedback')]; 
        Set<Id> recordTypeIdsforSituationManagement = new Set<Id>();
        
        //RecordIdsOfSituationManagementCases
        for(RecordType temp :listOfSituationManagRecordIds){
            recordTypeIdsforSituationManagement.add(temp.Id);
        }
     
        system.debug('rcdType'+recordTypeIdsforSituationManagement );
            try{
                if (Trigger.isInsert && Trigger.isAfter ) { 
                        List <Id> contactIds                     = new List<Id>();
                        List<Id> allTheCasesTobeInserted         = new List<Id>();
                        List<Authorized_Contact__c> authContacts = new List<Authorized_Contact__c>();          
                        List <Case> casesToBeUpdatedAfterInsert  = new List<Case>();
                        Map<Id, Id> contactIdToEntitlementType   = new Map<Id, Id>();
                        
                        // Related to Issue numner 4939                 
                        List <Id> caseBusinessIds = new List<Id>(); 
                        List<Case_Update_Milestones__c> newlyCreatedMilestones = new List<Case_Update_Milestones__c>();
                                        
                        for (Case casesToBeInserted: Trigger.new) {
                            If (!recordTypeIdsforSituationManagement.contains(casesToBeInserted.RecordTypeId)){
                                contactIds.add(casesToBeInserted.ContactID); 
                                caseBusinessIds.add(casesToBeInserted.Id);//4939
                            }
                        }
                        authContacts   = [Select Entitlement__r.Type, Entitlement__c, Contact__r.Id,Entitlement__r.BusinessHoursId, Contact__c From Authorized_Contact__c where Contact__c in:contactIds];
                               
                        for (Authorized_Contact__c authContact : authContacts) {
                            contactIdToEntitlementType.put(authContact.Contact__r.Id, authContact.Entitlement__r.BusinessHoursId);
                            System.Debug('contactIdToEntitlementType++++'+contactIdToEntitlementType); 
                        }
                       
                        for(Case currCaseToBeInserted: Trigger.new){
                            System.Debug('currCaseToBeInserted.RecordTypeId+++++'+currCaseToBeInserted.RecordTypeId);
                            System.debug('currCaseToBeInserted.Support_level__c++++'+currCaseToBeInserted.Support_level__c);
                            System.debug('currCaseToBeInserted.RecordTypeId++++'+currCaseToBeInserted.RecordTypeId);
                            If (currCaseToBeInserted.Support_level__c != null && ! recordTypeIdsforSituationManagement.contains(currCaseToBeInserted.RecordTypeId)) {
                               System.Debug('UpdateCode Doesnt run 1');
                               Integer numOfMinutes = getSlaHours('First_Response_NOM__c',currCaseToBeInserted.Priority,currCaseToBeInserted.Support_level__c).First_Response_NOM__c.intValue();
                               System.Debug('++numOfMinutes++'+numOfMinutes);
                               System.Debug('++currCaseToBeInserted++'+currCaseToBeInserted.ContactID);
                                if(numOfMinutes >0){
                                    Datetime updatetime = contactIdToEntitlementType.containsKey(currCaseToBeInserted.ContactID)?BusinessHours.addGmt(contactIdToEntitlementType.get(currCaseToBeInserted.ContactID), currCaseToBeInserted.createdDate, numOfMinutes*60000):null;
                                    Case tempCase = new Case(id=currCaseToBeInserted.id);
                                    tempCase.NextUpdateDueFrmCUM__c = updateTime;
                                    If(Test.isRunningTest()){
                                        tempCase.Priority = 'P1';
                                    }
                                    casesToBeUpdatedAfterInsert.add(tempCase); 
                                }
                                                    //Added by Bikram 4939 starts     
                            Map<Id,Case> CaseIdToBusinessId = new Map<Id,Case>([Select Entitlement.BusinessHoursId from Case where Id In : caseBusinessIds]);              
                            System.Debug('CaseIdToBusinessId+++'+CaseIdToBusinessId);
                            If(CaseIdToBusinessId.containsKey(currCaseToBeInserted.Id)){
                                newlyCreatedMilestones.add(firstResponseMilestone(currCaseToBeInserted,CaseIdToBusinessId,numOfMinutes));    
                            }
                        }
                    }                
                    //4939
                    if(newlyCreatedMilestones.isEmpty() == FALSE) { insert newlyCreatedMilestones; }                
              
                        update casesToBeUpdatedAfterInsert;
                        }
                }catch(Exception ex){System.Debug('Exception is::'+ex);}
        try{
            //CustomMilestoneTest.firstRun = false;
            if(Trigger.isUpdate && Trigger.isAfter ) {// After update trigger 
                System.Debug('COunt+++++++++++++'+CustomMilestoneTest.firstRun);
                System.Debug('CustomMilestoneTest.firstRun'+CustomMilestoneTest.firstRun);
                //System.Debug('CustomMilestoneTest.firstRunFromCaseInsert'+CustomMilestoneTest.firstRunFromCaseInsert);
                List<Case_Update_Milestones__c> milestoneToBeUpdated   = new List<Case_Update_Milestones__c>(); 
                List<Case_Update_Milestones__c> newlyCreatedMilestones = new List<Case_Update_Milestones__c>();//Used when Priority is changed.....
                //All the Status's of case to be considered 
                /*set<String> ignoreCaseSet      = new set<String>{'Service Request Pending - Operations','Service Request Pending - Engineering','Awaiting Customer Input'};    
                set<String> nonIgnoreCaseSet    = new set<String>{'New','Working','Routed to Tier 2', 'Engineering Escalated', 'Needs Reply', 'Reopened'};    
                */
                
                //Fetch Ignore and non ignore case Status values from Custom Settings
                Map<String,Case_Statuses__c> CustomSettingMap = new Map<String,Case_Statuses__c>();
                CustomSettingMap = Case_Statuses__c.getAll();
                
                list<String> ignoreCaselist = CustomSettingMap.get('Case Status').Ignore_Case_Status_Values__c.split(',');
                set<String> ignoreCaseSet = new set<String>();
                ignoreCaseSet.addAll(ignoreCaselist);
            
                list<String> nonIgnoreCaselist = CustomSettingMap.get('Case Status').Non_Ignore_Case_Status_Values__c.split(',');
                set<String> nonignoreCaseSet = new set<String>();
                nonignoreCaseSet.addAll(nonIgnoreCaselist);
                //Fetch Ignore and non ignore case Status values from Custom Settings
                
                set<ID> allParentCaseIds     = new set<ID>();
                List<Case> casesToBeUpdated  = new List<Case>();
                
                for (Case currentParentCase : Trigger.new){
                    If (! recordTypeIdsforSituationManagement.contains(currentParentCase.RecordTypeId))
                        allParentCaseIds.Add(currentParentCase.Id);
                }
                List<CaseMilestone> caseMile                 = new List<CaseMilestone>([SELECT IsCompleted, TargetDate from CaseMilestone Where CaseId IN : allParentCaseIds AND MilestoneTypeId = '55750000000PAvR' And IsCompleted = false ]);
                Map<Id, CaseMilestone> caseIdToCaseMilestone = new Map<Id, CaseMilestone>();
                //Populate Map caseIdToCaseMilestone with relation of CaseId-->CaseMilestone
                for (CaseMilestone cMilestone : [SELECT CaseId,IsCompleted, TargetDate,StartDate from CaseMilestone Where CaseId IN : allParentCaseIds AND MilestoneTypeId = '55750000000PAvR' And IsCompleted = false]) {
                    caseIdToCaseMilestone.put(cMilestone.CaseId,cMilestone ); 
                }            
                
                List<Case_Update_Milestones__c> caseUpdateMile = new List<Case_Update_Milestones__c>([SELECT OwnerId,Case__c,Start_Date__c,Target_Date__c, Milestone_Type__c from Case_Update_Milestones__c where Case__c IN : allParentCaseIds And Completed__c = false]);
                Map<Id,Case_Update_Milestones__c> caseToCaseUpdateMilestone = new Map<Id,Case_Update_Milestones__c>();        
                for(Case_Update_Milestones__c tmpCaseUpDtMlStone : caseUpdateMile) {
                    caseToCaseUpdateMilestone.put(tmpCaseUpDtMlStone.Case__c,tmpCaseUpDtMlStone);            
                }
                System.Debug('allParentCaseIds++++'+allParentCaseIds);
                Map<Id,Case> CaseIdToBusinessId = new Map<Id,Case>([Select Entitlement.BusinessHoursId from Case where Id In : allParentCaseIds]);
                //List<User>
                for (Case caseUpdate : Trigger.new) {
                    try{    
                        System.debug('caseUpdate.Assign_To__c+++++'+caseUpdate.Assign_To__c);
                        If (caseUpdate.status != 'Closed' && !recordTypeIdsforSituationManagement.contains(caseUpdate.RecordTypeId)) {
                            System.Debug('caseUpdate.status___'+caseUpdate.status);
                            String ownerIdAfterInsert = Trigger.newMap.get(caseUpdate.Id).OwnerId;
                            String ownerIdBeforeInsert = Trigger.oldMap.get(caseUpdate.Id).OwnerId;
                            System.Debug('ownerIdAfterInsert+++'+ownerIdAfterInsert);
                            System.Debug('ownerIdBeforeInsert++++'+ownerIdBeforeInsert);
                            If(Trigger.newMap.get(caseUpdate.Id).OwnerId != Trigger.oldMap.get(caseUpdate.Id).OwnerId && !ownerIdAfterInsert.startsWith('00G')){
                            System.debug('Trigger.newMap.get(caseUpdate.Id).OwnerId+++'+Trigger.newMap.get(caseUpdate.Id).OwnerId);
                            System.debug('Trigger.oldMap.get(caseUpdate.Id).OwnerId+++'+Trigger.oldMap.get(caseUpdate.Id).OwnerId);
                                If(caseToCaseUpdateMilestone.containsKey(caseUpdate.Id)){//Check the existence of caseupdatemilestone on case
                                    System.Debug('ownerIdAfterInsert11111'+ownerIdAfterInsert);
                                    caseToCaseUpdateMilestone.get(caseUpdate.Id).OwnerId = ownerIdAfterInsert;//If Owner is changed from User to Queue case update milestone should save Queue in Owner field.
                                    System.Debug('ownerIdAfterInsert11111'+caseToCaseUpdateMilestone);
                                    milestoneToBeUpdated.add(caseToCaseUpdateMilestone.get(caseUpdate.Id));
                                    }
                            }   
                            System.Debug('caseUpdate.status___'+caseUpdate.status);
                            String priorityBeforeInsert        = Trigger.oldMap.get(caseUpdate.Id).Priority ;
                            String priorityAfterInsert         = Trigger.newMap.get(caseUpdate.Id).Priority ;
                            String CurrentPriority             = caseUpdate.Priority;
                            Integer priorityLevelAfterInsert   = Integer.valueof(priorityAfterInsert.substringAfter('P'));
                            Integer priorityLevelBeforeInsert  = Integer.valueof(priorityBeforeInsert.substringAfter('P'));
                            String statusAfterUpdate           = Trigger.newMap.get(caseUpdate.Id).Status ;
                            String statusBeforeUpdate          = Trigger.oldMap.get(caseUpdate.Id).Status;
                            String OwnerId                     = caseUpdate.OwnerId; 
                            System.Debug('OwnerId+++'+OwnerId);
                            System.Debug('statusAfterUpdate'+statusAfterUpdate);
                            System.Debug('statusBeforeUpdate'+statusBeforeUpdate);
                            System.Debug('priorityLevelAfterInsert'+priorityLevelAfterInsert);
                            System.Debug('priorityLevelBeforeInsert'+priorityLevelBeforeInsert);
                            System.Debug('ignoreCaseSet.contains(statusAfterUpdate)+++'+ignoreCaseSet.contains(statusAfterUpdate));
                            System.Debug('nonIgnoreCaseSet.contains(statusAfterUpdate)+++'+nonIgnoreCaseSet.contains(statusAfterUpdate));
                            Boolean statusInIgnoreCaseStatus   = ignoreCaseSet.contains(caseUpdate.status)?true:false;
                            System.Debug('statusInIgnoreCaseStatus'+statusInIgnoreCaseStatus);
                            /*if(priorityLevelAfterInsert      != priorityLevelBeforeInsert && !caseToCaseUpdateMilestone.containsKey(caseUpdate.Id)){
                                Case tempcasesToBeUpdated                               = new Case(id=caseUpdate.Id);
                                Integer numOfMinutes = getSlaHours('First_Response_NOM__c',caseUpdate.priority,caseUpdate.Support_Level__c).First_Response_NOM__c.intValue();
                                tempcasesToBeUpdated.NextUpdateDueFrmCUM__c             = caseUpdate.priority == 'P1'?caseUpdate.createdDate.addMinutes(numOfMinutes):BusinessHours.addGmt(CaseIdToBusinessId.get(CaseUpdate.Id).Entitlement.BusinessHoursId, caseUpdate.createdDate, numOfMinutes*60000);
                                casesToBeUpdated.add(tempcasesToBeUpdated);
                            }*/
                            String milestoneType;
                            If(caseUpdateMile.size() >0){milestoneType = caseToCaseUpdateMilestone.get(caseUpdate.Id).Milestone_Type__c;}
                            If((priorityLevelAfterInsert < priorityLevelBeforeInsert || statusBeforeUpdate != statusAfterUpdate) ){
                            System.Debug('Status Has been changed');
                                //If Priority of Case having Queue is changed No change in Case Update Update Milestone
                                IF(!ownerIdAfterInsert.startsWith('00G') || !ownerIdBeforeInsert.startsWith('00G')){
                                    If(nonIgnoreCaseSet.contains(statusBeforeUpdate) && ignoreCaseSet.contains(statusAfterUpdate) || priorityLevelAfterInsert < priorityLevelBeforeInsert && caseToCaseUpdateMilestone.containsKey(caseUpdate.Id)){
                                        System.Debug('Status Changed from non ignore to Ignore');
                                        //Update existing CaseUpdateMilestone on this case
                                        If(milestoneType == 'Case Update'){
                                            caseToCaseUpdateMilestone.get(caseUpdate.Id).Completion_Date__c   = System.now();
                                            caseToCaseUpdateMilestone.get(caseUpdate.Id).Completed__c         = true;
                                            caseToCaseUpdateMilestone.get(caseUpdate.Id).AutoComplete__c      = true;
                                            caseToCaseUpdateMilestone.get(caseUpdate.Id).Violation__c         = false;
                                            caseToCaseUpdateMilestone.get(caseUpdate.Id).update__c            = true;
                                        }else If(milestoneType == 'First Response'){
                                            Integer numOfMinutes = getSlaHours('First_Response_NOM__c',caseUpdate.Priority,caseUpdate.Support_Level__c).First_Response_NOM__c.intValue();
                                            caseToCaseUpdateMilestone.get(caseUpdate.Id).Duration__c          = numOfMinutes!= null?numOfMinutes+'':null;
                                            caseToCaseUpdateMilestone.get(caseUpdate.Id).Target_Date__c       = numOfMinutes!= null && Integer.valueof(CurrentPriority.substringAfter('P')) != 1?BusinessHours.addGmt(CaseIdToBusinessId.get(CaseUpdate.Id).Entitlement.BusinessHoursId, System.now(), numOfMinutes*60000) : caseToCaseUpdateMilestone.get(caseUpdate.Id).Start_Date__c.addMinutes(numOfMinutes);
                                            //caseToCaseUpdateMilestone.get(caseUpdate.Id).Target_Date__c       =  System.now().addMinutes(numOfMinutes);
                                            caseToCaseUpdateMilestone.get(caseUpdate.Id).update__c            = true;
                                        }
                                        milestoneToBeUpdated.add(caseToCaseUpdateMilestone.get(caseUpdate.Id));
                                        //Create a new milstone
                                    }System.Debug(' !ignoreCaseSet.contains(caseUpdate.Status)'+ !ignoreCaseSet.contains(caseUpdate.Status));
                                    if(ignoreCaseSet.Contains(statusBeforeUpdate) && nonIgnoreCaseSet.contains(statusAfterUpdate) || priorityLevelAfterInsert < priorityLevelBeforeInsert && !ignoreCaseSet.contains(caseUpdate.Status) && caseToCaseUpdateMilestone.containsKey(caseUpdate.Id) && milestoneType != 'First Response'){
                                        System.Debug('Status changed from ignore to nonIgnoreCaseStatus');
                                        Integer numOfMinutes;
                                        If(priorityLevelAfterInsert != priorityLevelBeforeInsert){
                                            numOfMinutes = getSlaHours('First_Response_NOM__c',priorityAfterInsert,caseUpdate.Support_Level__c).First_Response_NOM__c.intValue();
                                        }else If(statusBeforeUpdate != statusAfterUpdate){
                                            numOfMinutes = getSlaHours('Case_Update_Milestone_NOM__c',priorityAfterInsert,caseUpdate.Support_Level__c).Case_Update_Milestone_NOM__c.intValue();
                                        } 
                                        Case_Update_Milestones__c newCaseUpdateMilestone        = new Case_Update_Milestones__c();
                                        newCaseUpdateMilestone.Case__c                          = caseUpdate.id;
                                        newCaseUpdateMilestone.Milestone_Type__c                = 'Case Update';
                                        newCaseUpdateMilestone.Start_Date__c                    = System.now();
                                        newCaseUpdateMilestone.OwnerId                          = caseUpdate.OwnerId;
                                        newCaseUpdateMilestone.Target_Date__c                   = numOfMinutes!= null && priorityLevelAfterInsert != 1?BusinessHours.addGmt(CaseIdToBusinessId.get(CaseUpdate.Id).Entitlement.BusinessHoursId, System.now(), numOfMinutes*60000) : System.now().addMinutes(numOfMinutes); // __FIX_ME_LATER_FOR_NULL_CASES+_AND_+Check__Target_Date__c value at back end
                                        newCaseUpdateMilestone.Duration__c                      = numOfMinutes!= null?numOfMinutes+'':null;// __FIX_ME_LATER_FOR_NULL_CASES__And also check the value of Duration at back end
                                        newlyCreatedMilestones.add(newCaseUpdateMilestone);
                                        Case tempcasesToBeUpdated                               = new Case(id=caseUpdate.Id);
                                        tempcasesToBeUpdated.NextUpdateDueFrmCUM__c             = newCaseUpdateMilestone.Target_Date__c;
                                        casesToBeUpdated.add(tempcasesToBeUpdated);
                                   }
                                }
                            }
                        }
                        If (caseUpdate.status == 'Closed' &&  ! recordTypeIdsforSituationManagement.contains(caseUpdate.RecordTypeId)) { // If Case is closed 
                            If (caseToCaseUpdateMilestone.containsKey(caseUpdate.Id)){
                                
                                caseToCaseUpdateMilestone.get(caseUpdate.Id).Completion_Date__c = System.now();
                                caseToCaseUpdateMilestone.get(caseUpdate.Id).Completed__c       = true;
                                caseToCaseUpdateMilestone.get(caseUpdate.Id).Violation__c       = caseToCaseUpdateMilestone.get(caseUpdate.Id).Completion_Date__c > caseToCaseUpdateMilestone.get(caseUpdate.Id).Target_Date__c?true:false;
                                caseToCaseUpdateMilestone.get(caseUpdate.Id).AutoComplete__c    = false;
                                System.Debug('caseToCaseUpdateMilestone.get(caseUpdate.Id)++++++'+caseToCaseUpdateMilestone.get(caseUpdate.Id));
                                System.Debug('caseToCaseUpdateMilestone.get(caseUpdate.Id)++++++'+caseToCaseUpdateMilestone.get(caseUpdate.Id).Target_Date__c);
                                Boolean temp = caseToCaseUpdateMilestone.get(caseUpdate.Id).Completion_Date__c < caseToCaseUpdateMilestone.get(caseUpdate.Id).Target_Date__c?true:false;
                                System.Debug('temp+++'+temp);
                                milestoneToBeUpdated.add(caseToCaseUpdateMilestone.get(caseUpdate.Id));                  
                            }
                        }
                        System.debug('caseUpdate.status'+caseUpdate.status);
                        System.Debug('caseUpdate.Owner+++'+caseUpdate.Owner);
                        System.Debug('recordTypeIdsforSituationManagement.contains(caseUpdate.RecordTypeId)'+recordTypeIdsforSituationManagement.contains(caseUpdate.RecordTypeId));
                        System.Debug('caseToCaseUpdateMilestone.containsKey(caseUpdate.Id)+++'+caseToCaseUpdateMilestone.containsKey(caseUpdate.Id));
                    }Catch(Exception Ex){
                        System.debug('Exception Is thrown'+Ex);
                    }
                }
                System.Debug('milestoneToBeUpdated+++++'+milestoneToBeUpdated);
                update milestoneToBeUpdated;
                insert newlyCreatedMilestones;
                update casesToBeUpdated;
            }
        }
        catch(Exception ex){
            /*OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'community@marketo.com'];
            Messaging.SingleEmailMessage milestoneBreakDownErrorEmail  = new Messaging.SingleEmailMessage();
            String[] emailRecipient = new String[]{'jaimals@grazitti.com'};
            milestoneBreakDownErrorEmail.setToAddresses(emailRecipient);
            milestoneBreakDownErrorEmail.setOrgWideEmailAddressId(owea.get(0).Id);
            milestoneBreakDownErrorEmail.setReplyTo('jaimals@grazitti.com');
            milestoneBreakDownErrorEmail.setSubject('Milestone Is Down Fix it as soon as possible');
            milestoneBreakDownErrorEmail.setHtmlBody('Dear Administrator, Milestone is down<br /><br /> Thanks<br />Grazitti Interactive');
            Messaging.sendEmail(new Messaging.Email[] { milestoneBreakDownErrorEmail });
            */
            System.Debug('Exception In CustomMilestoneOnCases Is::'+ex);
        }

        Public Case_Update_Milestones__c firstResponseMilestone(Case caseCreated, Map<Id,Case> caseIdToBussinessId, Integer numOfMinutes){
        Case_Update_Milestones__c newCaseUpdateMilestone = new Case_Update_Milestones__c();
        CaseAdmin__c adminId = [Select Name,CaseAdminId__c from CaseAdmin__c where Name='BILL'];
        List<RecordType> listOfRecordTypes = [Select Id From RecordType where SobjectType='Case' and (Name='Support Customer Portal Case' OR Name='Support Email')]; 
        Set<Id> recordIds = new Set<Id>();
        recordIds.add(listOfRecordTypes[0].Id);
        Integer PriorityLevel = Integer.valueof(caseCreated.Priority.substringAfter('P'));                        
        If(caseCreated.Origin != 'phone'){
            newCaseUpdateMilestone.Case__c                          = caseCreated.id;
            newCaseUpdateMilestone.Milestone_Type__c                = 'First Response';
            newCaseUpdateMilestone.Start_Date__c                    = System.now();
            newCaseUpdateMilestone.Target_Date__c                   = numOfMinutes!= null && priorityLevel != 1?BusinessHours.addGmt(caseIdToBussinessId.get(caseCreated.Id).Entitlement.BusinessHoursId, System.now(), numOfMinutes*60000) : System.now().addMinutes(numOfMinutes); 
            newCaseUpdateMilestone.Duration__c                      = numOfMinutes!= null?numOfMinutes+'':null;
            newCaseUpdateMilestone.OwnerId                          = recordIds.contains(caseCreated.RecordTypeId)?adminId.CaseAdminId__c:caseCreated.OwnerId;
        } else{
            newCaseUpdateMilestone.Case__c                          = caseCreated.id;
            newCaseUpdateMilestone.Milestone_Type__c                = 'First Response';
            newCaseUpdateMilestone.Start_Date__c                    = System.now();
            newCaseUpdateMilestone.OwnerId                          = caseCreated.OwnerId;
            newCaseUpdateMilestone.Completed__c                     = true;
            newCaseUpdateMilestone.Completion_Date__c               = System.now();      
        }
    return newCaseUpdateMilestone;       
    }

    Public SLA__c getSlaHours(String MilestoneType, String priority, String Supportlevel) {
            for (SLA__c sla : slas) {
                If (sla.priority__c == priority && sla.Support_Level__c == Supportlevel) {
                    System.Debug('Entered the loop');
                    if (MilestoneType == 'First_Response_NOM__c') {
                        return sla;
                    }
                    else if (MilestoneType == 'Case_Update_Milestone_NOM__c') {
                        return sla;
                    }
                    else if (MilestoneType == 'Resolution_NOM__c') {
                        return sla;
                    }
                    break;
                }
            }
        return null;
    }
}