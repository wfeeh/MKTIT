public class SaveSalesSurveyInClarizenProject {
    public clzV5__Clarizen_Project__c proj {get;set;}
    public boolean isReattendingSurvey {get;set;}
    public boolean isSurveyCompleted {get;set;}
    clzV5__Clarizen_Project__c helperProj;
    
    public SaveSalesSurveyInClarizenProject(ApexPages.StandardController controller){
        this.proj = (clzV5__Clarizen_Project__c)controller.getRecord();
        if(ApexPages.currentPage().getParameters().get('Id')!=null){
            helperProj = new clzV5__Clarizen_Project__c();
            helperProj = [select Sales_Survey_Status__c,clzV5__CLZ_SYSID__c from clzV5__Clarizen_Project__c where Id =:ApexPages.currentPage().getParameters().get('Id')];
            if(helperProj.Sales_Survey_Status__c == Label.SalesSurveyStatus)
            isReattendingSurvey = true;
            if(helperProj.clzV5__CLZ_SYSID__c != null)
            this.proj.Clarizen_Email_Address__c = helperProj.clzV5__CLZ_SYSID__c+Label.ClarizenMailDomain;
        }
        this.proj.Survey_Response_Date__c = Date.Today();
        this.proj.Sales_Survey_Status__c = Label.SalesSurveyStatus;
        
    }
    
    public pagereference save(){
        if(proj.Id != null){
            
            /**new added code**/      
            try{
               update proj;
               isSurveyCompleted = true;
            }catch(exception e){system.debug(e);}
            return null; 
        }
        return null;
    }
}