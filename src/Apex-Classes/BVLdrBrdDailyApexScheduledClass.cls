global class BVLdrBrdDailyApexScheduledClass Implements Schedulable
{    
    global void execute(SchedulableContext sc)
    {
        BadgeVilleWebServiceCalloutBatchable.updateLeaderBoard('Daily'); 
    }         
    @isTest(SeeAllData=true) public static void testBadgeVilleCalls() 
    {
        Test.startTest();
        BVLdrBrdDailyApexScheduledClass mBV= new BVLdrBrdDailyApexScheduledClass();
        String schedule = '0 0 23 * * ?';
        system.schedule('BVLdrBrdDailyApexScheduledClass Run Test', schedule, mBV);
        test.stopTest();                     
    }  
}