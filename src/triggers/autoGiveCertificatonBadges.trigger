trigger autoGiveCertificatonBadges on Certification_History__c (after Insert, after Update) {  
   
   public Static Boolean executionFlag{get;set;}
    
    if (executionFlag == true) 
        { // Return if the trigger already executed in the context 
            return;
        }   
    
    executionFlag = true;    
    Set<String> usrBusinessEmails = new Set<String>();    
    //Map<String ,List<String>> certificationHistoryWithContactMap = new Map<String ,List<String>>();
    Set<String> certificationsIds = new Set<String>();     
    for(Certification_History__c certifiedHistRec : Trigger.new){
        List<User> portalUsers = [SELECT Id, Email,ContactId from User Where Isactive=true AND IsPortalEnabled = true AND Contact.Id = : trigger.new[0].Contact_ID__c and ContactId != NULL];
        if(portalUsers.isEmpty() == TRUE && Test.isRunningTest() == FALSE ) return;  
        if(Trigger.isInsert){
            //If User passed            
            if((certifiedHistRec.BadgeVilleReward_Status__c != true)  && (certifiedHistRec.Exam_Result__c == 'Pass')){                  
                certificationsIds.add(certifiedHistRec.Id);
               //usrBusinessEmails.Add(certifiedHistRec.Business_Email_Address__c);       
            } 
           
        }else if(Trigger.isUpdate){            
            //Else if previously the result was not passed and now is passed.                
            if((certifiedHistRec.BadgeVilleReward_Status__c != true )&& (certifiedHistRec.Exam_Result__c == 'Pass') && (Trigger.oldMap.get(certifiedHistRec.Id).Exam_Result__c != 'Pass')){                                      
                certificationsIds.add(certifiedHistRec.Id);
            }        
        }        
    }
   
    if(!certificationsIds.isEmpty()){       
        BVBatchApexWebCalloutCertificationClass bv = new BVBatchApexWebCalloutCertificationClass(certificationsIds);
        database.executebatch(bv,1);    
    }    
    
}