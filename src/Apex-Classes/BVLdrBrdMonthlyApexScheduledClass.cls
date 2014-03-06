global class BVLdrBrdMonthlyApexScheduledClass Implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
         BadgeVilleWebServiceCalloutBatchable.updateLeaderBoard('Monthly');
    }    
    @isTest(SeeAllData=true) public static void testBadgeVilleCalls() 
    {
        Test.startTest();
        BVLdrBrdMonthlyApexScheduledClass mBV= new BVLdrBrdMonthlyApexScheduledClass();
        String schedule = '0 0 23 * * ?';
        system.schedule('BVLdrBrdMonthlyApexScheduledClass Run Test', schedule, mBV);
        test.stopTest();                     
    }   
}