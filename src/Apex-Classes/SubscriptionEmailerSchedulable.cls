/*
 * This class needs to be scheduled in order for it to run.
 *
 * The following code can be executed anonymously via the
 * System Log to schedule this class to run:
 *
 * // Run Monday - Friday at 6AM.
 * System.Schedule('Community Subscription Emailer',  '0 0 6 ? * MON-FRI', new SubscriptionEmailerSchedulable());
 *
 * // Run on demand.
 * SubscriptionEmailerSchedulable schedulable = new SubscriptionEmailerSchedulable();
 * schedulable.execute(null);
 */
global class SubscriptionEmailerSchedulable implements Schedulable {

    global void execute(SchedulableContext context) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String typeCustomer;
        /* 3822 exclude account types ex-partner and ex-customer + unsubcribe */
        List<Community_Subscription__c> subscriptions = [SELECT Id, User__c,User__r.unsubscribe__c, Type__c, user__r.contact.AccountId,Category__c FROM Community_Subscription__c where User__r.unsubscribe__c = false AND Category__c != null AND Idea_Question_Id__c = null AND User__r.Contact.Account.Type NOT IN ('ex-customer','ex-partner')];
        List<Community_Subscription__c> allDiscussionSubscriptions = new List<Community_Subscription__c>();
        List<Community_Subscription__c> allIdeasSubscriptions = new List<Community_Subscription__c>();
        Map<String, List<Community_Subscription__c>> categoryDiscussionSubscriptions = new Map<String, List<Community_Subscription__c>>();
        Map<String, List<Community_Subscription__c>> categoryIdeasSubscriptions = new Map<String, List<Community_Subscription__c>>();

        Set<Id> allDiscussionSubscriptionsSet = new Set<Id>();
        Set<Id> allIdeasSubscriptionsSet = new Set<Id>();
        //Map<String, Set<Id>> categoryDiscussionSubscriptionsSet = new Map<String, Set<Id>>();
        //Map<String, Set<Id>> categoryIdeasSubscriptionsSet = new Map<String, Set<Id>>();          
         
        for (Community_Subscription__c subscription : subscriptions) {                 
            if ('All Categories' == subscription.Category__c) {
                if ('Question' == subscription.Type__c) {
                    if(!allDiscussionSubscriptionsSet.contains(subscription.User__c)){
                        allDiscussionSubscriptions.add(subscription);
                    }
                    allDiscussionSubscriptionsSet.add(subscription.User__c);
                } else if ('Idea' == subscription.Type__c) {
                    if(!allIdeasSubscriptionsSet.contains(subscription.User__c)){
                        allIdeasSubscriptions.add(subscription);
                    }
                    allIdeasSubscriptionsSet.add(subscription.User__c);
                }
            } else {
                if ('Question' == subscription.Type__c) {
                    List<Community_Subscription__c> categorySubscriptions = categoryDiscussionSubscriptions.get(subscription.Category__c);
                    //Bikram
                    //if(!categoryDiscussionSubscriptionsSet.containsKey(subscription.Category__c))                    
                    if (categorySubscriptions == null) {
                        categorySubscriptions = new List<Community_Subscription__c>();
                        categoryDiscussionSubscriptions.put(subscription.Category__c, categorySubscriptions);
                    }                    
                    categorySubscriptions.add(subscription);                    
                    
                } else if ('Idea' == subscription.Type__c) {
                    List<Community_Subscription__c> categorySubscriptions = categoryIdeasSubscriptions.get(subscription.Category__c);
                    if (categorySubscriptions == null) {
                        categorySubscriptions = new List<Community_Subscription__c>();
                        categoryIdeasSubscriptions.put(subscription.Category__c, categorySubscriptions);
                    }                    
                    categorySubscriptions.add(subscription);
                }
            }        
        }
        
        // Calculate since date for new count queries. If today is
        // Monday, go back 3 days (to cover weekend), else 1 day.
        String dayOfWeek = DateTime.now().format('EEEE');
        DateTime sinceDate = DateTime.now().addDays(dayOfWeek == 'Monday' ? -3 : -1);
        
        // Prepare emails.
        emails.addAll(prepareAllDiscussionEmails(allDiscussionSubscriptions, sinceDate));
        emails.addAll(prepareAllIdeasEmails(allIdeasSubscriptions, sinceDate));
        
        for (String category : categoryDiscussionSubscriptions.keySet()) {
            List<Community_Subscription__c> categorySubscriptions = categoryDiscussionSubscriptions.get(category);
            emails.addAll(prepareCategoryDiscussionEmails(category, categorySubscriptions, sinceDate));
        }
        
        for (String category : categoryIdeasSubscriptions.keySet()) {
            List<Community_Subscription__c> categorySubscriptions = categoryIdeasSubscriptions.get(category);
            emails.addAll(prepareCategoryIdeasEmails(category, categorySubscriptions, sinceDate));
        }

        // Send the emails.
        if (emails.isEmpty() == false) {
            Messaging.sendEmail(emails);
        }
    }

    public List<Messaging.SingleEmailMessage> prepareAllDiscussionEmails(List<Community_Subscription__c> subscriptions, DateTime sinceDate) {
        // Skip sending emails if there have not been any new Questions posted.
        List<Question> questions = [select Id from Question where CreatedDate >= :sinceDate limit 1];
        if (questions.isEmpty()) return new List<Messaging.SingleEmailMessage>();

        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_All_Discussion'].Id;

        return GlobalFunctions.createEmails(templateId, null, subscriptions);
    }
    
    public List<Messaging.SingleEmailMessage> prepareAllIdeasEmails(List<Community_Subscription__c> subscriptions, DateTime sinceDate) {
        // Skip sending emails if there have not been any new Ideas posted.
        List<Idea> ideas = [select Id from Idea where CreatedDate >= :sinceDate limit 1];
        if (ideas.isEmpty()) return new List<Messaging.SingleEmailMessage>();

        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_All_Ideas'].Id;

        return GlobalFunctions.createEmails(templateId, null, subscriptions);
    }
    
    public List<Messaging.SingleEmailMessage> prepareCategoryDiscussionEmails(String category, List<Community_Subscription__c> subscriptions, DateTime sinceDate) {
        // Skip sending emails if there have not been any new Questions posted.
        List<Question> questions = (List<Question>) Database.query('select Id from Question where CreatedDate >= ' + sinceDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' with data category Answers__c at ' + category + '__c limit 1');
        if (questions.isEmpty()) return new List<Messaging.SingleEmailMessage>();

        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_Category'].Id;

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Community_Subscription__c subscription : subscriptions) {
            emails.add(GlobalFunctions.createEmail(templateId, subscription.Id, subscription));
        }
        
        return emails;
    }
    
    public List<Messaging.SingleEmailMessage> prepareCategoryIdeasEmails(String category, List<Community_Subscription__c> subscriptions, DateTime sinceDate) {
        // Skip sending emails if there have not been any new Ideas posted.
        List<Idea> ideas = [select Id from Idea where Categories includes (:category) and CreatedDate >= :sinceDate limit 1];
        if (ideas.isEmpty()) return new List<Messaging.SingleEmailMessage>();

        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_Category'].Id;

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Community_Subscription__c subscription : subscriptions) {
            emails.add(GlobalFunctions.createEmail(templateId, subscription.Id, subscription));
        }
        
        return emails;
    }

}