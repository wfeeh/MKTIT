global class BVLdrBrdWeeklyApexScheduledClass Implements Schedulable
{
    global void execute(SchedulableContext sc)
    {    
        BadgeVilleWebServiceCalloutBatchable.updateLeaderBoard('Weekly');        
    }    
    @isTest(SeeAllData=true) public static void testBadgeVilleCalls() 
    {
        Test.startTest();
        BVLdrBrdWeeklyApexScheduledClass mBV= new BVLdrBrdWeeklyApexScheduledClass();
        String schedule = '0 0 23 * * ?';
        system.schedule('BVLdrBrdWeeklyApexScheduledClass Run Test', schedule, mBV);
        test.stopTest();                     
    }   
}