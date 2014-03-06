trigger CaseReceivedNotificationEmail on Case (After insert) {

    //List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
    List<Id> caseIds = new List<Id>();

    if(Trigger.isInsert && Trigger.isAfter && Trigger.size == 1) { 
        //((Case: Case Originnot equal toPhone,Voicemail) and (Entitlement: Entitlement Processnot equal tonull) and ((Entitlement: Entitlement Processdoes not contain Basic) or (Entitlement: Entitlement Name equals CopperEgg Corporation Basic)) and (Entitlement: Social Marketing Only not equal toTrue) and (Case: Web Emailnot equal to jordan@easyemailsolutions.com,jackie@jackiewalts.com,support@marketo.com) and (Case: Case Record TypeequalsSupport Cases,Support Customer Portal Case,Support Email to Case) and (Account: Typenot equal toEx-Customer,Ex-Partner))
        List<Id> caseContactId = new List<Id>();
        //Case size will always be 1
        for(Case tempCase: trigger.new) {  //Size is always 1
            system.debug('case record type id==>' + tempCase.recordtypeId);        
            caseContactId.add(tempCase.ContactId);    
        }        
        
        //Is contact authorized contact and is entitlement valid for case notification. 
        List<Contact> caseContact = [SELECT ID, Is_Authorized_Contact__c from Contact Where Id IN :caseContactId AND Is_Authorized_Contact__c = 'Yes'];
        List<Entitlement> caseEntitlement = [SELECT ID, Name,Type,SlaProcessId,Asset.munchkin_Id__c,SocialMarketing_Only__c from Entitlement WHERE Status = 'active' AND Id = :trigger.new[0].EntitlementId];
               
        System.Debug('caseContact ++++' + caseContact);
        System.Debug('caseEntitlement ++++' + caseEntitlement);
        
        for( Case tempCase: trigger.new ) { //size == 1
            System.Debug('tempCase.ContactId+++++'+tempCase.SuppliedEmail);
            Boolean Cond1 = tempCase.Origin == 'Email';//?true:false;
            Boolean Cond2 = FALSE;
            Boolean Cond3 = FALSE;
            Boolean Cond5 = FALSE;
            Boolean Cond10 = FALSE;
            Boolean Cond4 = !caseContact.isEmpty();//?false:true;
            If(caseEntitlement.isEmpty() == FALSE) {
                Cond2 = (caseEntitlement[0].SlaProcessId != null)?true:false;
                Cond3 = System.Label.email2Case_Blocked_SLAs.contains(caseEntitlement[0].SlaProcessId)?false:true;
                Cond5 = caseEntitlement[0].SocialMarketing_Only__c  != true?true:false;
                Cond10 = (caseEntitlement[0].Name == System.Label.CopperEgg_Entlmnt_Name)?true:false;
            } 
            Set<String> blockedEmails = new Set<String>();
            blockedEmails.addAll(System.Label.email2Case_Blocked_Emails.split(','));    
            System.debug('blockedEmails=>Supplied=>' + blockedEmails + ' ' + tempCase.SuppliedEmail);        
            Boolean Cond6 =  !blockedEmails.contains(tempCase.SuppliedEmail);                 
            //Boolean Cond6 = (tempCase.SuppliedEmail != 'jordan@easyemailsolutions.com' && tempCase.SuppliedEmail !='jackie@jackiewalts.com' && tempCase.SuppliedEmail !='support@marketo.com')?true:false;
            Boolean Cond7 =  tempCase.SuppliedEmail != null?(tempCase.SuppliedEmail.Contains('@marketo.com')):false;
            Boolean Cond8 =  tempCase.RecordTypeId == System.Label.email2Case_RecordType?true:false;
            Boolean Cond9 =  (tempCase.Account.Type != 'Ex-Customer' && tempCase.Account.Type != 'Ex-Partner')?true:false;
            Boolean Cond11 = (tempCase.SuppliedEmail != null)?true:false;
            
            System.debug('Cond1=>' + Cond1 + ' Cond2=>' + Cond2 + ' Cond3=>' + Cond3 + ' Cond4=>' + Cond4 + ' Cond5=>' + Cond5);
            System.debug('Cond6=>' + Cond6 + ' Cond7=>' + Cond7 + ' Cond8=>' + Cond8 + ' Cond9=>' + Cond9 + ' Cond10=>' + Cond10 + ' Cond11=>' + Cond11);    
            
            System.Debug('Result+++'+((cond1 && Cond2  && (Cond3 || Cond10) && Cond4 && Cond5 && Cond6 && Cond8 && Cond9 && Cond11) || (Cond1 && Cond6 && Cond7 && Cond8 && Cond9 && Cond11)));
            if((cond1 && Cond2  && (Cond3 || Cond10) && Cond4 && Cond5 && Cond6 && Cond8 && Cond9 && Cond11) || (Cond1 && Cond6 && Cond7 && Cond8 && Cond9 && Cond11)){
                caseIds.add(tempCase.Id);
            }
        }
        if(!caseIds.isEmpty()) {                
            CaseUtils.sendCaseNotificationWithArticleList(caseIds);                 
        }    
    }
}