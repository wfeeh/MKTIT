trigger UpdateQuoteNotesForSMB on Quote (before insert, before update) {
    Id SMBRecTypeId = [select id from RecordType where SObjectType = 'Quote' AND Name = 'SMB'].Id;
    
    for(Quote qt :Trigger.new){
        if(qt.RecordTypeId == SMBRecTypeId){
            qt.Quote_Notes__c = '';
            if(qt.Discount_Deal_Size__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Discount_Deal_Size__c + '<br/>';
            if(qt.Competition__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Competition__c + '<br/>';
            if(qt.Competitive_Reason_1__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Competitive_Reason_1__c + '<br/>';
            if(qt.Competitive_Reason_2__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Competitive_Reason_2__c + '<br/>';
            if(qt.Why_Marketo_Reason_1__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Why_Marketo_Reason_1__c + '<br/>';
            if(qt.Why_Marketo_Reason_2__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Why_Marketo_Reason_2__c + '<br/>';
            if(qt.Terms__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Terms__c + '<br/>';
            if(qt.When__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.When__c;
        }
    }
}