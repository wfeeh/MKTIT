trigger articleFeedbackNotification on Article_FeedBack__c (after insert) {
    if (Trigger.isInsert && Trigger.isAfter) {
        Set<Id> ids = new Set<Id>();
        for (Article_FeedBack__c feedback : Trigger.new) {
            ids.add(feedback.Id);
        }
        GlobalFunctions.sendArticleFeedbackNotifications(ids);
    }
}