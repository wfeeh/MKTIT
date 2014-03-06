trigger ParseEmail on Case (before insert, before update) {
    
    Id caseId = null;
    Case oldCaseInfo = null;
    for (Case caseInfo : trigger.new) {
        if(caseInfo.Id != null) {
            oldCaseInfo = Trigger.oldMap.get(caseInfo.Id);
        }
        
        if (Utils.hasChanges('Email_List__c', oldCaseInfo, caseInfo)) {
            if (caseInfo.Email_List__c != null && caseInfo.Email_List__c.length() > 0) {
                String emailAddress = caseInfo.Email_List__c.replaceAll(';',',');
                List<String> emailAddressList = emailAddress.split(',');
                Integer i=1;
                SObject sobCase = null;
                String fieldName ='CC_Email_';
                while(i <= 10) {
                    fieldName ='CC_Email_';
                    if (i > 9) {
                        fieldName = fieldName+'0'+i+'a__c';
                    } else {
                        fieldName =fieldName+'00'+i+'a__c';
                    }
                    sobCase = (SObject)caseInfo;
                    sobCase.put(fieldName, '');
                    i++;
                }
                i=1;
                sobCase = null;
                for(String email : emailAddressList) {
                    fieldName ='CC_Email_';
                    if (i > 10) {
                        break;
                    }
                    if (i > 9) {
                        fieldName = fieldName+'0'+i+'a__c';
                    } else {
                        fieldName =fieldName+'00'+i+'a__c';
                    }
                    sobCase = (SObject)caseInfo;
                    sobCase.put(fieldName, email);
                    i++;
                }
            } else {
                Integer i=1;
                SObject sobCase = null;
                String fieldName ='CC_Email_';
                while(i <= 10) {
                    fieldName ='CC_Email_';
                    if (i > 9) {
                        fieldName = fieldName+'0'+i+'a__c';
                    } else {
                        fieldName =fieldName+'00'+i+'a__c';
                    }
                    sobCase = (SObject)caseInfo;
                    sobCase.put(fieldName, '');
                    i++;
                }
            }
        }
    }

}