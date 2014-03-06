trigger MKT_AddPaymentTrigger on Opportunity (after insert, after update) {

    List<MKT_Payment__c> PaymentList = new List<MKT_Payment__c>();

    if (Trigger.isInsert) {
        /*for (Opportunity newOpportunity : trigger.new) {
            if (newOpportunity.StageName == 'Closed Won' && newOpportunity.SFDC_Oppty_Recordtype__c == 'Closed_Won' && newOpportunity.Product__c != NULL) {
                MKT_Payment__c payment = new MKT_Payment__c();
                payment.Product__c = newOpportunity.Product__c;
                payment.User__c = newOpportunity.User__c;
                payment.Account__c = newOpportunity.AccountId;
                payment.Total_Seats__c = newOpportunity.TotalOpportunityQuantity;
                PaymentList.Add(payment);

            }
        }*/
    }
    if (Trigger.isUpdate) {
        Set<Id> oldOpportunitySet = new Set<Id>();
        Set<Id> paidOpportunitySet = new Set<Id>();
        Map<Id, OpportunityLineItem> launchPackIdOpportunityLPMap = new Map<Id, OpportunityLineItem>();
        for (Opportunity oldOpportunity : trigger.old) {
            if (oldOpportunity.StageName != 'Closed Won') {
                oldOpportunitySet.Add(oldOpportunity.Id);
            }
        }
        for (Opportunity newOpportunity : trigger.new) {
            if (newOpportunity.StageName == 'Closed Won' && newOpportunity.SFDC_Oppty_Recordtype__c == 'Closed_Won' && oldOpportunitySet.Contains(newOpportunity.Id) && newOpportunity.Forecast_Category__c == 'Closed Won') {
                paidOpportunitySet.Add(newOpportunity.Id);
            }
        }
        for (OpportunityLineItem opportunityLItem :[SELECT Id, OpportunityId, Quantity, Opportunity.MKT_User__c, Opportunity.AccountId, Opportunity.MKT_Transaction__c, Opportunity.Name, Opportunity.CreatedById, PricebookEntry.ProductCode, PricebookEntry.Name, PricebookEntry.Product2Id FROM OpportunityLineItem WHERE OpportunityId IN :paidOpportunitySet]) {
            launchPackIdOpportunityLPMap.put(opportunityLItem.PricebookEntry.Product2Id, opportunityLItem);
        }

        Set<Id> ProcessOpportunityLineItemIds = new Set<Id>();
        for (MKT_TranslationTable__c launchPackProductItem :[SELECT ChildProduct__c, ParentProduct__c, Total_Seats__c FROM MKT_TranslationTable__c WHERE ParentProduct__c IN :launchPackIdOpportunityLPMap.keySet()]) {
            OpportunityLineItem opportunityLPItem = (OpportunityLineItem)launchPackIdOpportunityLPMap.get(launchPackProductItem.ParentProduct__c);
            if (opportunityLPItem.Opportunity.MKT_Transaction__c == NULL) {
                MKT_Payment__c payment = new MKT_Payment__c();
                payment.Product__c = launchPackProductItem.ChildProduct__c;
                payment.User__c = (opportunityLPItem.Opportunity.MKT_User__c == NULL) ? opportunityLPItem.Opportunity.CreatedById : opportunityLPItem.Opportunity.MKT_User__c;
                payment.Account__c = opportunityLPItem.Opportunity.AccountId;
                payment.Total_Seats__c = opportunityLPItem.Quantity * launchPackProductItem.Total_Seats__c;
                payment.MKT_Opportunity__c = opportunityLPItem.OpportunityId;
                PaymentList.Add(payment);
                ProcessOpportunityLineItemIds.Add(opportunityLPItem.Id);
            }

        }
        for (OpportunityLineItem SingleProductOpportunityLineItem : launchPackIdOpportunityLPMap.values()) {
            if (!ProcessOpportunityLineItemIds.contains(SingleProductOpportunityLineItem.Id)) {
                MKT_Payment__c payment = new MKT_Payment__c();
                payment.Product__c = SingleProductOpportunityLineItem.PricebookEntry.Product2Id;
                payment.User__c = (SingleProductOpportunityLineItem.Opportunity.MKT_User__c == NULL) ? SingleProductOpportunityLineItem.Opportunity.CreatedById : SingleProductOpportunityLineItem.Opportunity.MKT_User__c;
                payment.Account__c = SingleProductOpportunityLineItem.Opportunity.AccountId;
                payment.Total_Seats__c = SingleProductOpportunityLineItem.Quantity;
                payment.MKT_Opportunity__c = SingleProductOpportunityLineItem.OpportunityId;
                PaymentList.Add(payment);
            }
        }

    }
    if (PaymentList.Size() > 0) {
        insert PaymentList;
    }
}