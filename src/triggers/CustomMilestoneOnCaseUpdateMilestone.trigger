trigger CustomMilestoneOnCaseUpdateMilestone on Case_Update_Milestones__c (after Update) {
    /*
    @Algorithm After Update
        IF CaseUpdateMilestone Updated
            If Completed == true && AutoComplete == true && MilestoneType = "Case Update"
                Create New Milestone With Following Values
                    Case             = Parent Case ID
                    Owner            = Case Owner ID
                    Milestone Type   = "Case Update"
                    StartDate        = Now
                    TargetDate       = (Dependant on the Support Level & Priority of the Case see Matrix attached)
                    Duration         = (Dependant on the Support Level & Priority of the Case see Matrix attached) 
            Insert CasUpdateMilestone;
            Case.Next_Update_Date__c = TargetDate
            Update Case 
    */
    Map<String,CustomMilestoneSettings__c> myMap = new Map<String,CustomMilestoneSettings__c>();
    myMap = CustomMilestoneSettings__c.getAll();
    System.Debug('CustomMilestoneTest.firstRun+++'+CustomMilestoneTest.firstRun);
    if(myMap.size() == 0 || myMap.get('Custom Milestone').Custom_Milestone_Active__c != true) return; 
    If(CustomMilestoneTest.firstRunInCaseCustomMileTrigger == false){return;}
    CustomMilestoneTest.firstRunInCaseCustomMileTrigger = false;
    public List<SLA__c> slas = [Select Support_Level__c, First_Response_NOM__c, Case_Update_Milestone_NOM__c, Priority__c, Resolution_NOM__c from SLA__c];
        List<Id> caseIds = new List<Id>();// LIst to add all the case Ids
        List<Case_Update_Milestones__c> finalUpdateList = new List<Case_Update_Milestones__c>();//List of CaseUpdateMilestone handling Mass update outside the for loop at line 33
        List<Id> parentCaseIds = new List<Id>();
        List<Case> casesToBeUpdated = new List<Case>();
        Map<Id,Case> parentCases                   = new Map<Id,Case>();
        
        for(Case_Update_Milestones__c currentCaseUpdateMile : Trigger.New){
            parentCaseIds.add(CurrentCaseUpdateMile.Case__c);
        }
        System.Debug('parentCaseIds.size()++++'+parentCases.size());
        parentCases = new Map<ID,Case>([Select Id, Priority, Support_Level__c, IsClosed, ownerid, NextUpdateDueFrmCUM__c,status,Entitlement.BusinessHoursId  from case where id in:parentCaseIds]);
        for(Case_Update_Milestones__c Cum : Trigger.new){//Add those case Id's for which this trigger is fired
            caseIds.add(Cum.Case__c);
        }
        //Map<Id,case> parentCases = new Map<Id,case>([Select Id, Support_Level__c,Priority,OwnerId from Case where Id IN: caseIds]);
        If(Trigger.isAfter && Trigger.isUpdate ){//fired after update
            try{
                for(Case_Update_Milestones__c currentCaseUpdateMile : Trigger.New){
                    If(currentCaseUpdateMile.Completed__c == true && currentCaseUpdateMile.AutoComplete__c == true && currentCaseUpdateMile.update__c == false && currentCaseUpdateMile.Milestone_Type__c != 'First Response'){
                        Case_Update_Milestones__c customMileTobeInserted     = new Case_Update_Milestones__c();
                        customMileTobeInserted.Case__c                       = currentCaseUpdateMile.Case__c;
                        //customMileTobeInserted.Ownerid                       = parentCases.get(currentCaseUpdateMile.Case__c).ownerid;
                        customMileTobeInserted.Milestone_Type__c             = 'Case Update';
                        customMileTobeInserted.Start_Date__c                 = System.now();
                        System.Debug('Priority+++'+parentCases.get(currentCaseUpdateMile.Case__c).priority+'SupportLevel'+parentCases.get(currentCaseUpdateMile.Case__c).Support_Level__c);
                        Integer numOfMinutes                                  = getSlaHours('Case_Update_Milestone_NOM__c',parentCases.get(currentCaseUpdateMile.Case__c).priority,parentCases.get(currentCaseUpdateMile.Case__c).Support_Level__c);
                        System.debug('numOfMinutes++++'+numOfMinutes);
                        //customMileTobeInserted.Target_Date__c                = numOfMinutes!= null?System.now().addHours(numOfMinutes):null; // __FIX_ME_LATER_FOR_NULL_CASES+_AND_+Check__Target_Date__c value at back end
                        customMileTobeInserted.Target_Date__c                = numOfMinutes!= null && parentCases.get(currentCaseUpdateMile.Case__c).Priority != 'P1'?BusinessHours.addGmt(parentCases.get(currentCaseUpdateMile.Case__c).Entitlement.BusinessHoursId, System.now(), numOfMinutes*60000):System.Now().addMinutes(numOfMinutes); // __FIX_ME_LATER_FOR_NULL_CASES+_AND_+Check__Target_Date__c value at back end
                        customMileTobeInserted.Duration__c                   = numOfMinutes!= null?numOfMinutes+'':null;// __FIX_ME_LATER_FOR_NULL_CASES__And also check the value of Duration at back end
                        finalUpdateList.add(customMileTobeInserted);
                    }        
                }
                System.Debug('finalUpdateList++++'+finalUpdateList);
                insert finalUpdateList;
                update casesToBeUpdated;
            }catch(Exception ex){
                /*OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'community@marketo.com'];
                Messaging.SingleEmailMessage milestoneBreakDownErrorEmail  = new Messaging.SingleEmailMessage();
                String[] emailRecipient = new String[]{'jaimals@grazitti.com'};
                milestoneBreakDownErrorEmail.setToAddresses(emailRecipient);
                milestoneBreakDownErrorEmail.setOrgWideEmailAddressId(owea.get(0).Id);
                milestoneBreakDownErrorEmail.setReplyTo('jaimals@grazitti.com');
                milestoneBreakDownErrorEmail.setSubject('Milestone Is Down Fix it as soon as possible');
                milestoneBreakDownErrorEmail.setHtmlBody('Dear Administrator, Milestone is down<br /><br /> Thanks<br />Grazitti Interactive');
                Messaging.sendEmail(new Messaging.Email[] { milestoneBreakDownErrorEmail });
                System.Debug('Exception In CustomMilestoneOnCaseUpdateMilestone Is::'+ex);*/
            }
        }
    Public Integer getSlaHours(String MilestoneType, String priority, String Supportlevel) {
            for (SLA__c sla : slas) {
                If (sla.priority__c == priority && sla.Support_Level__c == Supportlevel) {
                    if (MilestoneType == 'First_Response_NOM__c') {
                        return sla.First_Response_NOM__c.intValue();
                    }
                    else if (MilestoneType == 'Case_Update_Milestone_NOM__c') {
                        return sla.Case_Update_Milestone_NOM__c.intValue();
                    }
                    else if (MilestoneType == 'Resolution_NOM__c') {
                        return sla.Resolution_NOM__c.intValue();
                    }
                    break;
                }
            }
        return 0;
    }  
}