global class StickyfeatureSchedulable implements Schedulable{
    global void execute(SchedulableContext SC) {       
        List<Sticky_Post__c>  StickyList  = new List<Sticky_Post__c>();  
        StickyList  = [Select Name,Comment__c,ID__c, Checked__c, Date_Time__c,Job_ID__c  from Sticky_Post__c where Name =: 'StickyPost'];
        system.debug('===StickyList==='+StickyList);
        for(Sticky_Post__c st :StickyList){
           st.ID__c = null;
           st.Comment__c = null;
           st.Checked__c = false;
           st.Date_Time__c = null;
           //st.Job_ID__c = null;
           st.type__c = null;
        }
        update StickyList;
    }    
    
    @isTest(SeeAllData=true) public static void testCalls() 
    {
        Test.startTest();
        StickyfeatureSchedulable mBV= new StickyfeatureSchedulable();
        String schedule = '0 0 23 * * ?';
        system.schedule('StickyPost', schedule, mBV);
        test.stopTest();                     
    }   
    
    
}