global class BVLdrBrdContestApexScheduledClass Implements Schedulable
{
    global void execute(SchedulableContext sc)
    {        
        BadgeVilleWebServiceCalloutBatchable.updateLeaderBoard('Contest');        
    } 
    @isTest(SeeAllData=true) public static void testBadgeVilleCalls() 
    {
        Test.startTest();
        BVLdrBrdContestApexScheduledClass mBV= new BVLdrBrdContestApexScheduledClass();
        String schedule = '0 0 23 * * ?';
        system.schedule('BVLdrBrdContestApexScheduledClass Run Test', schedule, mBV);
        test.stopTest();                     
    }      
}