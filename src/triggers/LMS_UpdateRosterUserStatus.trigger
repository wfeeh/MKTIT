trigger LMS_UpdateRosterUserStatus on lmsilt__GoToTraining_Session__c (after insert, after Update,after delete, after undelete) {
    
    Static String ATTENDED = 'Attended';
    Static String NOTATTENDED = 'Not Attended';
    Map<String, String> rosterWithClassMap = new Map<String, String>();
    if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete){
        for(lmsilt__GoToTraining_Session__c rosterSession : Trigger.New){
            if((trigger.isInsert && rosterSession.lmsilt__Status__c != null ) ||(trigger.isUndelete && rosterSession.lmsilt__Status__c != null )|| 
              (trigger.isUpdate && (Trigger.oldMap.get(rosterSession.Id).lmsilt__Status__c == null || !Trigger.oldMap.get(rosterSession.Id).lmsilt__Status__c.equalsIgnoreCase(rosterSession.lmsilt__Status__c)
              || (Trigger.oldMap.get(rosterSession.Id).lmsilt__Class__c != (rosterSession.lmsilt__Class__c))
             ))
             ){
                rosterWithClassMap.put(rosterSession.lmsilt__Roster__c,rosterSession.lmsilt__Class__c);               
             }
        }
    }
    if(trigger.isDelete){
        for(lmsilt__GoToTraining_Session__c rosterSession : Trigger.old){
            if(rosterSession.lmsilt__Status__c != null)
            rosterWithClassMap.put(rosterSession.lmsilt__Roster__c,rosterSession.lmsilt__Class__c);
        }
    }
    if(!rosterWithClassMap.isEmpty()){
    
        List<lmsilt__Roster__c>  rosterTobeUpdated = [select lmsilt__Attended__c,lmsilt__Class__c,lmsilt__Status__c,(select Id,lmsilt__Class__c from  lmsilt__GoToTraining_Sessions__r where lmsilt__Status__c =: ATTENDED and lmsilt__Class__c IN : rosterWithClassMap.values()) from lmsilt__Roster__c where Id IN : rosterWithClassMap.keySet()];
        for(lmsilt__Roster__c roster : rosterTobeUpdated){
            Integer counter = 0;
            for(lmsilt__GoToTraining_Session__c rSession : roster.lmsilt__GoToTraining_Sessions__r){
                if(counter>1) break;
                if( roster.lmsilt__Class__c == rSession.lmsilt__Class__c ){
                    counter++   ; 
                }
            }
            
            if(counter>1){
               roster.lmsilt__Attended__c = true;
               roster.lmsilt__Status__c = ATTENDED;
            }else{
               roster.lmsilt__Attended__c = false;
               roster.lmsilt__Status__c = NOTATTENDED ;
            }
            
        }
        
        try { update rosterTobeUpdated;}catch(Exception e)
        {
           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
           String[] toAddresses = new String[] {'ayub.a@grazitti.com'};
           mail.setToAddresses(toAddresses);
           mail.setSubject('Exception Occures:: ' +e);
           mail.setPlainTextBody('Trigger LMS_UpdateRosterUserStatus have exception'+e);
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        }
    
    }
    

}