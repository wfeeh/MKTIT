trigger SendSurveyOnCaseClose on Case (After update, After Insert) {
    
    /* 
    @Algorithm        
        If Case.Contact == AUTHORIZED && Case.Contact.Account.Asset.Purpose == Production && case IS Closed && Case.RecordType == SupportCases
            If Case.Contact.PortalUserProfile.SurveyFrequencyPreference != NEVER && !SurveyFeedbackExists(ContactId, CaseId)
                If Case.Contact.PortalUserProfile.SurveyFrequencyPreference == ALWAYS
                     Add Contact to survey invitation list
                Else If Case.Contact.PortalUserProfile.SurveyFrequencyPreference == ONCE A MONTH
                     If !SurveyFeedbackExistsForMonth(ContactId) && ThisMonthTargetContactsList.Contains(ContactId)
                         Add Contact to survey invitation list
                         Add ContactId to ThisMonthTargetContactsList
    */       
    
    Map<String,CSatSurveySettings__c> myMap = new Map<String,CSatSurveySettings__c>();
    myMap = CSatSurveySettings__c.getAll();
    //.get('IsCSatSurveyActive').Survey_Active__c;
    if(myMap.size() == 0 || myMap.get('IsCSatSurveyActive').Survey_Active__c != true) return; 
    
    /*
    if(CSatSurveySettings__c.getValues('IsCSatSurveyActive').Survey_Active__c != true) { //Return if the survey is not active
        return;
    }
    */
                         
    if (CSatSurvey.executionFlag == true) { // Return if the trigger already executed in the context 
        return;
    }   

    CSatSurvey.executionFlag = true;
     
    // CONSTANTS

    // Survey preferences
    Map <String, String> LanguageToSurveyTemplatenameMap = new Map<String, String>();
    final String ENGLISH      = 'English';
    final String FRENCH       = 'French';
    final String GERMAN       = 'German'; 
    final string SPANISH      = 'Spanish';
    final string PORTUGUESE   = 'Portuguese';
    final string NEVER        = 'Never';
    
    final string ONCE_A_MONTH = 'Once a month';
    final string ALWAYS       = 'All';  
       
    LanguageToSurveyTemplatenameMap.put(ENGLISH, 'CSatSurveyEnglish');
    LanguageToSurveyTemplatenameMap.put(FRENCH,  'CSatSurveyFrench');
    LanguageToSurveyTemplatenameMap.put(GERMAN,  'CSatSurveyGerman');
    LanguageToSurveyTemplatenameMap.put(SPANISH,  'CSatSurveySpanish');
    LanguageToSurveyTemplatenameMap.put(PORTUGUESE,  'CSatSurveyPortuguese');

    // Default Survey preferences
    String defUserLangPref         = ENGLISH;
    String defUserSurveyFreqPref   = ALWAYS;
    //Set<String> validRecordTypeNames     = new Set<String>{'Support Cases'};
    Set<String> validCaseCloseReasons    = new Set<String>{'Resolved','Referred to KB','Referred to Ideas','Referred to Other Group','No Response from Customer'};
    Map<Id,RecordType> caseRecordTypeId  = new Map<Id,RecordType>([Select Id, SobjectType, Name From RecordType where SobjectType='Case' and Name='Support Cases']);
     
    
    List <Id> caseClosedIds         = new List<Id>();
    List <Id> caseClosedContactIds  = new List<Id>();
    for (Case tempCase :trigger.new) { 
        //String tempCaseRcrdTpNm = caseRecordTypeId.get(tempCase.RecordTypeId).name;
        if(
        (tempCase.isClosed == true) && (trigger.oldMap.get(tempCase.id).isClosed == false)
         && caseRecordTypeId.containskey(tempCase.RecordTypeId)
         && validCaseCloseReasons.contains(tempCase.Close_Reason__c)
         && !((tempCase.Problem_Type__c == 'Configuration/Set Up') && (tempCase.Category__c == 'Configuration Outreach'))
         ) {
            caseClosedIds.add(tempCase.id);
            caseClosedContactIds.add(tempCase.contactId);
            System.debug('Close Reason is===='+tempCase.Close_Reason__c);
        }
    }
    System.debug('caseClosedIds======='+caseClosedIds.size());
    // If no case closed return from here only
    if(caseClosedIds.size() == 0) return;    

    // fetch users with portalenabled info for above contacts
    List <User> portalUsersForContactsList = new List<User>([Select u.IsPortalEnabled, u.contactid From User u where contactid in:caseClosedContactIds and IsPortalEnabled=true]);
    Set  <Id> enabledPortalUsersSet        = new Set<Id>();
    for (User usr:portalUsersForContactsList) {
        enabledPortalUsersSet.add(usr.contactid);
    }

    // Create surveyEligibility map for contacts under the processing
    Map <Id,Boolean> contactsToSurveyEligibilityMap = CSatSurvey.getContactsToSurveyEligibilityMap(caseClosedContactIds);
    
    
   
    // Fetch the portal users for the above contacts of the closed cases
    List<Community_Profile__c> portalUserProfiles = [Select c.User__r.ContactId, c.CSatSurveyPreferences__c From Community_Profile__c c where c.User__r.ContactId in:caseClosedContactIds];
    Map<Id,Contact> relatedContactsMap = new Map<Id,Contact>([Select ID,Preferred_Language__c From Contact c where c.Id in:caseClosedContactIds]);
    
    System.debug('Preferred Language==?' +relatedContactsMap);
    
    // create contactidToPortalUserMap
    Map<Id, Community_Profile__c> contactIdToportalUserProfilesMap = new Map<Id, Community_Profile__c>();
    for (Community_Profile__c tempUserProfile: portalUserProfiles) {
        contactIdToportalUserProfilesMap.put(tempUserProfile.User__r.contactId, tempUserProfile); 
        System.debug('=======tempUserProfile=======?' +contactIdToportalUserProfilesMap);
    }
   
    // Create a list of surveys in past by contact and case 
    List<CSatSurveyFeedback__c>      cSatFeedbacks       = [Select Id, case__C, lastmodifieddate, contact__c from CSatSurveyFeedback__c where contact__C in:caseClosedContactIds]; 
    Map  <Id, CSatSurveyFeedback__c> caseIdToFeedbackMap = new Map <Id, CSatSurveyFeedback__c>();
    Set <Id> thisMonthFeedbackContacts                   = new Set<Id>();
    Date currentDate                                     = Date.today();
    System.debug('=======caseIdToFeedbackMap=======?' +  caseIdToFeedbackMap);
    for (CSatSurveyFeedback__c cSatFeedback:cSatFeedbacks) {
        caseIdToFeedbackMap.put(cSatFeedback.case__C, cSatFeedback);
        if (cSatFeedback.lastmodifieddate.month() == currentDate.month()) {
            thisMonthFeedbackContacts.add(cSatFeedback.contact__c);
            System.debug('=======thisMonthFeedbackContacts=======?' +  thisMonthFeedbackContacts);
        } 
    }
    
    Map<String, List<String>> languageToCaseIdMap = new Map<String, List<String>>();
    Set<ID> targetContactsForSurvey = new Set<Id>();
    Set<Id> closedCaseIdsSet = new Set<Id>();
    closedCaseIdsSet.addAll(caseClosedIds); 
    for (Case tempCase :trigger.new) {                        
        Boolean isRltdCntctElgblForSurvey = false;
        String caseOwnerId                = tempCase.ownerId;
        if (contactsToSurveyEligibilityMap.containsKey(tempCase.contactid)) {
            isRltdCntctElgblForSurvey = contactsToSurveyEligibilityMap.get(tempCase.contactid); 
            System.debug('=======isRltdCntctElgblForSurvey=======?' +  isRltdCntctElgblForSurvey );
        }
        //System.Debug('contactsToSurveyEligibilityMap'+contactsToSurveyEligibilityMap);
        //System.Debug('isRltdCntctElgblForSurvey '+isRltdCntctElgblForSurvey+' closedCaseIdsSet '+closedCaseIdsSet);
        Set<String> supportedLang= new Set<String>{ENGLISH,GERMAN,FRENCH,SPANISH,PORTUGUESE};
        
        boolean result           = false;
        if((tempCase.contactId != null) && (relatedContactsMap.containsKey(tempCase.contactId))  && (relatedContactsMap.get(tempCase.contactId).Preferred_Language__c != null))
            result = supportedLang.contains(relatedContactsMap.get(tempCase.contactId).Preferred_Language__c);
        
        System.Debug('======Pref Result ======='+result);
        if(closedCaseIdsSet.contains(tempCase.Id) && (isRltdCntctElgblForSurvey == true) && (!caseOwnerId.startsWith('00G'))) { // __NEED_TO_FIX_THIS_FOR_SUPPORT_CASE_TYPE_ONLY__
            String conPrefLang = result != false?relatedContactsMap.get(tempCase.contactId).Preferred_Language__c:defUserLangPref; 
            System.Debug('======Pref Language======='+conPrefLang);
            Community_Profile__c relatedPortalUser = new Community_Profile__c(CSatSurveyPreferences__c  = defUserSurveyFreqPref);
            if (contactIdToportalUserProfilesMap.containsKey(tempCase.contactId)) {
                relatedPortalUser = contactIdToportalUserProfilesMap.get(tempCase.contactId);
                System.Debug('===============relatedPortalUser=============='+relatedPortalUser);
                relatedPortalUser.CSatSurveyPreferences__c = relatedPortalUser.CSatSurveyPreferences__c != null?relatedPortalUser.CSatSurveyPreferences__c:defUserSurveyFreqPref;
                //relatedPortalUser.Language__c              = relatedPortalUser.Language__c != null?relatedPortalUser.Language__c:defUserLangPref;
            }
            if (!enabledPortalUsersSet.contains(tempCase.contactId)) { //FIX on 01_03_13 as per Patricia's request
                relatedPortalUser.CSatSurveyPreferences__c  = NEVER;  
            }
            System.Debug('relatedPortalUser'+relatedPortalUser);
            if ((relatedPortalUser.CSatSurveyPreferences__c != NEVER) && !caseIdToFeedbackMap.containsKey(tempCase.Id)) {
                if (relatedPortalUser.CSatSurveyPreferences__c == ALWAYS) {
                    if(!languageToCaseIdMap.containsKey(conPrefLang)) {
                        List<String> tempCaseList = new List<String>();
                        tempCaseList.add(tempCase.Id);
                        languageToCaseIdMap.put(conPrefLang, tempCaseList);
                    } else {
                        languageToCaseIdMap.get(conPrefLang).add(tempCase.Id);
                    }
                } else if (relatedPortalUser.CSatSurveyPreferences__c == ONCE_A_MONTH) {
                    // __WILL_DO_IT_LATER__
                    // Check if contact has already not attended a survey in this month && contact is not in the target Contacts list
                    if(!thisMonthFeedbackContacts.contains(tempCase.contactId) && !targetContactsForSurvey.contains(tempCase.contactId)) {
                        // Survey not already attended by the user for this month and neither any added in this request
                        targetContactsForSurvey.add(tempCase.contactId);
                    }
                }
            }
        }       
                                                        
    }
    
    //System.Debug('LANGTOCASEMAP'+languageToCaseMap);
    for(String language:languageToCaseIdMap.keySet()) {
        system.debug('=====Email====='+ language);
        CSatSurvey.sendSurveyEmails(LanguageToSurveyTemplatenameMap.get(language), languageToCaseIdMap.get(language));
    }  
    
}