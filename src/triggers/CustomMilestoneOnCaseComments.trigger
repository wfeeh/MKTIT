trigger CustomMilestoneOnCaseComments on CaseComment (after insert, after update){ 
    /*
    @Algorithm
        If  Status not in ignoreCaseStatus List(Service Request Pending - Operations','Service Request Pending - Engineering','Awaiting Customer Input)    
            If AND(IsPublished == True , Case status <> Closed, not generated from Incoming Email to Comment)
                If NoOfCaseUpdateMilestones == 0 
                    On Existing Milestone object, do the following:  
                        completiondate = Now
                        completed      = true
                        If Completion Date > Target Date set Violation = TRUE
                        AutoComplete = FALSE
                Create New CaseUpdateilestone with following values
                    Case           = Parent Case ID
                    Owner          = Case Owner ID
                    Milestone Type = "Case Update"
                    StartDate      = Now
                    TargetDate     = (Dependant on the Support Level & Priority of the Case see Matrix attached)
                    Duration       = (Dependant on the Support Level & Priority of the Case see Matrix attached)  
                Set Case.NextUpdateDue = TargetDate                 
    */
    // User Ids which can post comment on case via mail, these are to be excluded from abillity to create custom milestone object on case
    Map<String,CustomMilestoneSettings__c> myMap = new Map<String,CustomMilestoneSettings__c>();
    myMap = CustomMilestoneSettings__c.getAll();
    System.Debug('CustomMilestoneTest.firstRun+++'+CustomMilestoneTest.firstRun);
    if(myMap.size() == 0 || myMap.get('Custom Milestone').Custom_Milestone_Active__c != true) return; 
    if(CustomMilestoneTest.firstRunInCaseCommentTrigger == false ) {return;}
    CustomMilestoneTest.firstRunInCaseCommentTrigger = false;
    public List<SLA__c> slas =  [Select Support_Level__c, First_Response_NOM__c, Case_Update_Milestone_NOM__c, Priority__c, Resolution_NOM__c from SLA__c];
    CustomMilestoneSettings__c isCustomMilestoneActive = [Select Custom_Milestone_Active__c from CustomMilestoneSettings__c Where Name = 'Custom Milestone'];
    If(isCustomMilestoneActive.Custom_Milestone_Active__c == true){
            If(Trigger.isInsert && Trigger.isAfter || Trigger.isUpdate && Trigger.isAfter){
                try{
                    List<CaseAdmin__c> caseAdminIdsList = [Select CaseAdminId__c from CaseAdmin__c];
                    Set<String> caseAdminIdsSet       = new Set<String>();
                    for(CaseAdmin__c tempCaseAdmin : caseAdminIdsList){
                        caseAdminIdsSet.add(tempCaseAdmin.CaseAdminId__c);
                    }
                    
                    //Fetch Ignore and non ignore case Status values from Custom Settings
                    Map<String,Case_Statuses__c> CustomSettingMap = new Map<String,Case_Statuses__c>();
                    CustomSettingMap = Case_Statuses__c.getAll();
                    
                    list<String> ignoreCaselist = CustomSettingMap.get('Case Status').Ignore_Case_Status_Values__c.split(',');
                    set<String> ignoreCaseSet = new set<String>();
                    ignoreCaseSet.addAll(ignoreCaselist);
                    //Fetch Ignore and non ignore case Status values from Custom Settings
                    
                    // Set of User which can post comment on case via mail, these are to be excluded from abillity to create custom milestone object on case 
                    set<Id> parentCaseIds = new Set<Id>();
                    List<Case_Update_Milestones__c> milestones = new List<Case_Update_Milestones__c>();
                    Map<Id,Case> parentCases                   = new Map<Id,Case>();
                    
                    List<Id>    commentCreatedByIds                           = new List<Id>();
                    for (CaseComment commentOnCase : Trigger.new){
                         parentCaseIds.add(commentOnCase.ParentId);
                         commentCreatedByIds.add(commentOnCase.CreatedById);
                    }
                
                    System.Debug('parentCaseIds++++'+parentCaseIds);
                    Map<Id,User> idToUser                      = new Map<Id,User>([Select IsPortalEnabled from User where Id IN :commentCreatedByIds]);
                    parentCases = new Map<ID,Case>([Select Id, Priority, Support_Level__c, IsClosed, ownerid, NextUpdateDueFrmCUM__c,status,Entitlement.BusinessHoursId  from case where id in:parentCaseIds]);
                    milestones  = [Select Id, Case__c,Target_Date__c from Case_Update_Milestones__c where Case__c in:parentCaseIds and Completed__c=false];
                    Map<Id,List<Case_Update_Milestones__c>> caseToMilestone = new Map<Id,List<Case_Update_Milestones__c>>();
                    for (Case_Update_Milestones__c milestone:milestones) {
                        if (caseToMilestone.containsKey(milestone.Case__c)) {
                            caseToMilestone.get(milestone.Case__c).add(milestone);
                        } else {
                            //Case_Update_Milestones__c
                            List<Case_Update_Milestones__c> cmilestones = new List<Case_Update_Milestones__c>();
                            cmilestones.add(milestone);
                            caseToMilestone.put(milestone.Case__c, cmilestones);
                        }        
                    }
                    List <Case_Update_Milestones__c> milestonesToBeUpdated  = new List<Case_Update_Milestones__c>();
                    List <Case_Update_Milestones__c> newlyCreatedMilestones = new List<Case_Update_Milestones__c>();
                    List <Case> updatedCases = new List<Case>();
                    // Actual flow of records in trigger
                    for (CaseComment commentOnCase : Trigger.new){
                        System.Debug('SupportLevel++++'+parentCases.get(commentOnCase.parentId).Support_Level__c);
                        If(parentCases.get(commentOnCase.parentId).Support_Level__c != null){
                            System.Debug('___isPublished___'+commentOnCase.isPublished);
                            System.Debug('+++commentOnCase+++'+commentOnCase.CreatedById);
                            System.Debug('+++status+++'+parentCases.get(commentOnCase.ParentId).status);
                            System.Debug('SlaIgnoreStatus++++'+getsla('Case_Update_Milestone_NOM__c',parentCases.get(commentOnCase.parentId).priority,parentCases.get(commentOnCase.parentId).Support_Level__c));
                            //Below is the code Commented for Ignore vase status.......
                            if ((commentOnCase.isPublished == true) && (!parentCases.get(commentOnCase.ParentId).IsClosed) && !idToUser.get(commentOnCase.CreatedById).IsPortalEnabled && !caseAdminIdsset.contains(commentOnCase.CreatedById)) { 
                                if (caseToMilestone.containsKey(commentOnCase.parentid)  && (caseToMilestone.get(commentOnCase.parentid).Isempty() == false) ) {
                                    // Update existing milestone
                                    Case_Update_Milestones__c existingMilestone = caseToMilestone.get(commentOnCase.parentid).get(0);
                                    existingMilestone.Completion_Date__c = System.now();
                                    existingMilestone.Completed__c       = true;
                                    System.Debug('existingMilestone.Completion_Date__c+++'+existingMilestone.Completion_Date__c);
                                    System.Debug('existingMilestone.Target_Date__c+++'+existingMilestone.Target_Date__c);
                                    existingMilestone.Violation__c       = existingMilestone.Completion_Date__c > existingMilestone.Target_Date__c?true:false;
                                    existingMilestone.AutoComplete__c    = false;
                                    existingMilestone.update__c          = true;
                                    milestonesToBeUpdated.add(existingMilestone);
                                    //update existingMilestone;
                                }                               
                                // Create new Milestone 
                                //Reminder when priority is changed from portal owner if the new caseupdate milestone is set to protal user please verify
                                //If Milestone is created with status in Ignore Case Status Complete the new milestone created.
                                If(!ignoreCaseSet.Contains(parentCases.get(commentOnCase.parentId).Status)){
                                    Case_Update_Milestones__c newCaseUpdateMilestone    = new Case_Update_Milestones__c();
                                    newCaseUpdateMilestone.Case__c                      = commentOnCase.parentid;
                                    newCaseUpdateMilestone.Milestone_Type__c            = 'Case Update';
                                    newCaseUpdateMilestone.OwnerId                      = parentCases.get(commentOnCase.parentId).OwnerId;
                                    newCaseUpdateMilestone.Start_Date__c                = System.now();
                                    Integer numOfMinutes                                = getSla('Case_Update_Milestone_NOM__c',parentCases.get(commentOnCase.parentId).priority,parentCases.get(commentOnCase.parentId).Support_Level__c).Case_Update_Milestone_NOM__c.intValue();
                                    System.Debug('parentCases.get(commentOnCase.parentId).Entitlement.BusinessHoursId'+parentCases.get(commentOnCase.parentId).Entitlement.BusinessHoursId);
                                    newCaseUpdateMilestone.Target_Date__c               = numOfMinutes!= null && parentCases.get(commentOnCase.parentId).Priority != 'P1'?BusinessHours.addGmt(parentCases.get(commentOnCase.parentId).Entitlement.BusinessHoursId, System.now(), numOfMinutes*60000):System.Now().addMinutes(numOfMinutes); // __FIX_ME_LATER_FOR_NULL_CASES+_AND_+Check__Target_Date__c value at back end
                                    newCaseUpdateMilestone.Duration__c                  = numOfMinutes!= null?numOfMinutes+'':null;// __FIX_ME_LATER_FOR_NULL_CASES__And also check the value of Duration at back end
                                    System.Debug('Entitlement Id Of Case+++'+parentCases.get(commentOnCase.parentId).Entitlement.BusinessHoursId);
                                    System.Debug('newCaseUpdateMilestone.Duration__c++++'+newCaseUpdateMilestone.Duration__c);
                                    System.Debug('Priority of parent case'+parentCases.get(commentOnCase.parentId).priority);
                                    System.Debug('Support level of parent case'+parentCases.get(commentOnCase.parentId).Support_Level__c);
                                    newlyCreatedMilestones.add(newCaseUpdateMilestone);
                                    parentCases.get(commentOnCase.parentId).NextUpdateDueFrmCUM__c = newCaseUpdateMilestone.Target_Date__c;
                                    updatedCases.add(parentCases.get(commentOnCase.parentId));
                                }
                            }
                        }
                    }
                    System.Debug('newlyCreatedMilestones++++'+newlyCreatedMilestones);    
                    System.Debug('newlyCreatedMilestones++++'+newlyCreatedMilestones.size());
                    insert newlyCreatedMilestones;
                    update milestonesToBeUpdated; 
                    System.Debug('milestonesToBeUpdated+++'+milestonesToBeUpdated);
                    update updatedCases;
                }catch(Exception ex){
                    /*OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'community@marketo.com'];
                    Messaging.SingleEmailMessage milestoneBreakDownErrorEmail  = new Messaging.SingleEmailMessage();
                    String[] emailRecipient = new String[]{'jaimals@grazitti.com'};
                    milestoneBreakDownErrorEmail.setToAddresses(emailRecipient);
                    milestoneBreakDownErrorEmail.setOrgWideEmailAddressId(owea.get(0).Id);
                    milestoneBreakDownErrorEmail.setReplyTo('jaimals@grazitti.com');
                    milestoneBreakDownErrorEmail.setSubject('Milestone Is Down Fix it as soon as possible');
                    milestoneBreakDownErrorEmail.setHtmlBody('Dear Administrator, Milestone is down<br /><br /> Thanks<br />Grazitti Interactive');
                    Messaging.sendEmail(new Messaging.Email[] { milestoneBreakDownErrorEmail });*/
                    System.Debug('Exception In CustomMilestoneOnCaseComments Is::'+ex);
                }
            }
    }
    Public SLA__c getSla(String MilestoneType, String priority, String Supportlevel) {
        for (SLA__c sla : slas) {
            If (sla.priority__c == priority && sla.Support_Level__c == Supportlevel) {
                System.Debug('Entered the loop');
                if (MilestoneType == 'First_Response_NOM__c') {
                    return sla;
                }
                 else if (MilestoneType == 'Resolution_NOM__c') {
                    return sla;
                }
                else if (MilestoneType == 'Case_Update_Milestone_NOM__c') {
                    return sla;
                }
                break;
            }
        }
        return null;
    }
}