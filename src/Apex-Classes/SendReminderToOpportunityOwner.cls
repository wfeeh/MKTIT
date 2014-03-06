public class SendReminderToOpportunityOwner implements Schedulable{
    Static final String AMER = 'AMER%';
    Static final String EMEA = 'EMEA%';
    Static final String ANZ  = 'ANZ%';
    Static final String STATUSSENT = Label.SalesSurveySentStatus;
    
    List<clzV5__Clarizen_Project__c> targetedProjects ;
    static final String EMAILTEMPLATE = 'Send_Reminder_Mail_to_OppOwner_Template'; 
    OrgWideEmailAddress owa = [select id, DisplayName , Address from OrgWideEmailAddress where DisplayName =:'Success Team'];
    EmailTemplate mailTemplate  = [Select id, DeveloperName from EmailTemplate where DeveloperName =:EMAILTEMPLATE];
    
    public SendReminderToOpportunityOwner (String projId){
         targetedProjects = new List<clzV5__Clarizen_Project__c>();
         clzV5__Clarizen_Project__c proj = [select clzV5__Opportunity__r.OwnerId,clzV5__Opportunity__r.Owner.firstName,clzV5__CLZ_Customer__r.Name, clzV5__Opportunity__r.Owner.Email from clzV5__Clarizen_Project__c where id =: projId];
         if(proj.Id != null){
             targetedProjects.add(proj);
         }
    }
    public SendReminderToOpportunityOwner (){
         targetedProjects = new List<clzV5__Clarizen_Project__c>();
         for(clzV5__Clarizen_Project__c proj : [SELECT clzV5__Opportunity__r.Owner.firstName,clzV5__Opportunity__r.Owner.Email,clzV5__CLZ_Customer__r.Name,Sales_Survey_Status__c, CLZ_C_BusinessUnit__c,CLZ_C_ProjectFamily__c,clzV5__CLZ_ProjectType__c, CreatedDate FROM clzV5__Clarizen_Project__c 
                                          WHERE (CLZ_C_ProjectFamily__c IN : ProjectFamilyForSalesSurvey__c.getall().keySet() 
                                          OR clzV5__CLZ_ProjectType__c IN : ProjectTypeForSalesSurvey__c.getall().keySet() ) AND ( CLZ_C_BusinessUnit__c LIKE : AMER OR  CLZ_C_BusinessUnit__c LIKE : EMEA OR CLZ_C_BusinessUnit__c LIKE : ANZ)
                                          AND Sales_Survey_Status__c = : STATUSSENT
                                          ]
                                          )
             {
                 if(proj.CreatedDate.date().daysBetween(Date.Today()) == 3){
                     targetedProjects.add(proj);
                 }              
             }
          
    }
    
    /**system.schedule('SendReminderToOpportunityOwner'+Date.Today(), '0 0 13 * * ?', new SendReminderToOpportunityOwner());**/
    
    public void execute(SchedulableContext sc) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for(clzV5__Clarizen_Project__c proj : targetedProjects){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(proj.clzV5__Opportunity__r.OwnerId);
            mail.setOrgWideEmailAddressId(owa.id);
            mail.setTemplateID(mailTemplate.Id); 
            mail.setWhatId(Proj.Id);
            mail.setSaveAsActivity(false);
            mailList.add(mail);
        }   
        
        List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(mailList, false);                                  
                                          
      
   }

}