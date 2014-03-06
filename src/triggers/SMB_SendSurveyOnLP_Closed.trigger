trigger SMB_SendSurveyOnLP_Closed on clzV5__Clarizen_Project__c (After update) {
    
    private static final String COMPLETED = 'Completed';
    private static final String AMERSB = 'AMER-SB';
    private static final String AMERMM = 'AMER-MM';
    private static final String PROJECTFAMILY = 'MLMLP';
    
    List<clzV5__Clarizen_Project__c> launchPackRecs = new List<clzV5__Clarizen_Project__c>();
    List<SMB_SheduledJobInfo__c> sheduleProjects = new List<SMB_SheduledJobInfo__c>();
    List<SMB_SheduledJobInfo__c> sheduleProjToDelete = new List<SMB_SheduledJobInfo__c>();
    Set<String> projectIdToDel = new Set<String>();
    
    /*****Code starts for sending mail on closing Launch Pack Project*****/
    if(SMB_Survey_Util.runOnce()){
        for(clzV5__Clarizen_Project__c project : Trigger.new){
          if(!project.IsSurveyEmailSent__c){
                if( project.clzV5__CLZ_State__c != null && project.clzV5__CLZ_State__c != ''&&
                    project.CLZ_C_BusinessUnit__c != null && project.CLZ_C_BusinessUnit__c != ''&& 
                    project.CLZ_C_ProjectFamily__c != null && project.CLZ_C_ProjectFamily__c != ''&& 
                    !Trigger.oldMap.get(project.Id).clzV5__CLZ_State__c.equalsIgnoreCase(COMPLETED)&&
                    project.clzV5__CLZ_State__c.equalsIgnoreCase(COMPLETED) && 
                    ((project.CLZ_C_BusinessUnit__c.deleteWhitespace()).equalsIgnoreCase(AMERSB) || (project.CLZ_C_BusinessUnit__c.deleteWhitespace()).equalsIgnoreCase(AMERMM)) && 
                    project.CLZ_C_ProjectFamily__c.containsIgnoreCase(PROJECTFAMILY)){
                       launchPackRecs.add(project);
                 } else if(project.clzV5__CLZ_State__c != null && project.clzV5__CLZ_State__c != '' && (Trigger.oldMap.get(project.Id).clzV5__CLZ_State__c).equalsIgnoreCase(COMPLETED) && project.clzV5__CLZ_State__c != COMPLETED ){
                    projectIdToDel.add(project.Id);
                 }
            }
        }
        if(projectIdToDel.isempty() == false){
            sheduleProjToDelete = [select name from SMB_SheduledJobInfo__c where ProjectId__c in :projectIdToDel];
            if(sheduleProjToDelete.size()!= null && sheduleProjToDelete.size()>0){
                try{delete sheduleProjToDelete;}catch(Exception e){}
            }
        }
        
        if(launchPackRecs.isempty() == false){
            SMB_ScheduledSurveyMail sheduleMail = new SMB_ScheduledSurveyMail(); 
            Datetime timeToSendMail = System.now();
            timeToSendMail = timeToSendMail.addHours(24);
           // timeToSendMail = timeToSendMail.addseconds(6);
            String sch = '' + timeToSendMail.second() + ' ' + timeToSendMail.minute() + ' ' + timeToSendMail.hour() + ' ' + timeToSendMail.day() + ' ' + timeToSendMail.month() + ' ? ' + timeToSendMail.year();
            
            String sheduledJobId = System.schedule('SendSurveyOfLaunchPack-'+timeToSendMail, sch, sheduleMail);
            system.debug(sheduledJobId+'id+++');
            for(clzV5__Clarizen_Project__c proj : launchPackRecs){
                SMB_SheduledJobInfo__c sheduleProjectRec = new SMB_SheduledJobInfo__c();
                sheduleProjectRec.ProjectId__c = proj.Id;
                sheduleProjectRec.SheduledJobId__c = sheduledJobId;
                sheduleProjects.add(sheduleProjectRec);
            }
            if(sheduleProjects.isempty() == false){
                try{insert sheduleProjects;}catch(Exception e){}
            }
        } 
    }
    
}