public class getBatchJobStatusExtension
{
    public Account account { get; set; }
    public ID myBatchID{ get;set; } 
    public String myBatchStatus{ get;set; } 
        
    public getBatchJobStatusExtension(ApexPages.StandardController controller) {
        myBatchID = null;
        myBatchStatus = '';
    }
           
    public PageReference getBatchStatus() {
        System.Debug('MyBatchStatus : ' + myBatchID  + myBatchStatus  );
        if(myBatchID != null) 
        {
            AsyncApexJob[] openJobs = [select Status From AsyncApexJob Where Id =: myBatchID limit 1];
            if(openJobs.size()== 1)
            {                
                myBatchStatus = openJobs[0].Status;
                System.Debug('MyBatchStatus : ' + myBatchID  + myBatchStatus  );    
                return null;            
            }
        }
        else 
        {
            myBatchStatus = 'No Job Running';                
            return null;
        }
        return null;        
        //return [select name, title, email, phone from contact where contact.accountid = :getAccount().id];
    }
     @isTest (seeAllData=true)
    public static void testgetBatchJobStatusExtension() {
       
        Account_Scoring_Rule_States__c ruleStates = new Account_Scoring_Rule_States__c();
       
        
        AsyncApexJob[] openJobs = [select Status,Id From AsyncApexJob limit 1];
        getBatchJobStatusExtension controller = new getBatchJobStatusExtension(new ApexPages.StandardController(ruleStates) );
        controller.myBatchID = openJobs[0].ID;
        pageReference p = controller.getBatchStatus();  
    }
    
}