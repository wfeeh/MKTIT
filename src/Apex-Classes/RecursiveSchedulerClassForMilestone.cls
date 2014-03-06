global class RecursiveSchedulerClassForMilestone implements Schedulable{
    global void execute(SchedulableContext SC) {
        List<Case_Update_Milestones__c> allMilestonesToBeUpdated = new List<Case_Update_Milestones__c>();       
        List<Case_Update_Milestones__c> milestonesToBeVerified   = new List<Case_Update_Milestones__c>([Select Id,case__c,Target_Date__c,Completed__c from Case_Update_Milestones__c Where Completed__c = false and case__c != null and Milestone_Type__c != 'First Response']);  
        for(Case_Update_Milestones__c currentMilestone : milestonesToBeVerified){
            If(System.now() >= currentMilestone.Target_Date__c && currentMilestone.Completed__c == false){
                Case_Update_Milestones__c milestoneToBeUpdated = new Case_Update_Milestones__c(id = currentMilestone.id);
                milestoneToBeUpdated.Completion_Date__c    = System.Now();
                milestoneToBeUpdated.Completed__c          = TRUE;
                milestoneToBeUpdated.Violation__c          = TRUE;
                milestoneToBeUpdated.AutoComplete__c       = TRUE;
                allMilestonesToBeUpdated.add(milestoneToBeUpdated);
           }
        }
        System.Debug('allMilestonesToBeUpdated++++'+allMilestonesToBeUpdated);
        update allMilestonesToBeUpdated;
    }
    @isTest(SeeAllData=True)
    Public Static void testRecursiveSchedulerClass(){
        test.startTest();
        RecursiveSchedulerClassForMilestone testObject = new RecursiveSchedulerClassForMilestone();
        String schedule =  '0 0 23 * * ?';
        system.schedule('RecursiveSchedulerClassForMilestone Run Test', schedule, testObject);
        test.stopTest();
    }
}