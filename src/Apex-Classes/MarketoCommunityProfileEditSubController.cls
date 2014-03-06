public class MarketoCommunityProfileEditSubController extends MarketoBaseController {

    public Community_Profile__c profile {get; private set;}

    public List<Subscription> subscriptions {get; private set;}
    public Id subscriptionId {get; set;}

    public PageReference init() {
        User profileUser = [select Id, FirstName, LastName from User where Id = :UserInfo.getUserId()];
        
        try {
            profile = [select Id, Display_Name__c, Company_Name__c, Title__c, Location__c, Website__c,
                              About_Me__c, Facebook__c, LinkedIn__c, Twitter__c, Profile_Picture_ID__c
                       from Community_Profile__c
                       where User__c = :UserInfo.getUserId()];
        } catch (Exception e) {
            // An exception will be thrown if no record exists yet.
            profile = new Community_Profile__c();
            profile.User__c = UserInfo.getUserId();
            profile.Display_Name__c = profileUser.FirstName + ' ' + profileUser.LastName.substring(0, 1);
        }
        
        subscriptions = new List<Subscription>();

        List<Community_Subscription__c> categorySubscriptions = [select Id, Type__c, Category__c from Community_Subscription__c where User__c = :UserInfo.getUserId() and ((Category__c != null AND Idea_Question_Id__c = null) OR Type__c ='News and Alerts')];

        if (categorySubscriptions.isEmpty() == false) {
            Map<String, String> ideaCategories = new Map<String, String>();
            for (Schema.PicklistEntry entry : Idea.Categories.getDescribe().getPicklistValues()) {
                ideaCategories.put(entry.getLabel(), entry.getValue());
            }

            Map<String, String> questionCategories = DataCategoryHelper.getHelper('Question').getNameToLabelMap();

            for (Community_Subscription__c categorySubscription : categorySubscriptions) {
                if ('Idea' == categorySubscription.Type__c) {
                    if ('All Categories' == categorySubscription.Category__c) {
                        subscriptions.add(new Subscription(categorySubscription.Id, 'Ideas: All'));
                    } else {
                        String label = ideaCategories.get(categorySubscription.Category__c);
                        if (label != null) {
                            subscriptions.add(new Subscription(categorySubscription.Id, 'Ideas: ' + label));
                        }
                    }
                } else if ('Question' == categorySubscription.Type__c) {
                    if ('All Categories' == categorySubscription.Category__c) {
                        subscriptions.add(new Subscription(categorySubscription.Id, 'Discussion: All'));
                    } else {
                        String label = questionCategories.get(categorySubscription.Category__c);
                        if (label != null) {
                            subscriptions.add(new Subscription(categorySubscription.Id, 'Discussion: ' + label));
                        }
                    }
                }else if(categorySubscription.Type__c == 'News and Alerts'){
                    subscriptions.add(new Subscription(categorySubscription.Id, 'News and Alerts: All')); 
                    system.debug('===subscriptions==='+subscriptions);   
                }
            }
        }

        return null;
    }

    public Boolean getHasSubscriptions() {
        return (subscriptions != null && subscriptions.size() > 0);
    }

    public PageReference subscribeAll() {
        Community_Subscription__c subscription = new Community_Subscription__c();
        subscription.User__c = UserInfo.getUserId();
        subscription.Type__c = 'Question';
        subscription.Category__c = 'All Categories';
        insert subscription;

        return init();
    }

    public PageReference cancelSubscription() {
        delete [select Id from Community_Subscription__c where Id = :subscriptionId];
        
        return init();
    }
    
    public class Subscription {
        public Id id {get; set;}
        public String title {get; set;}
        
        public Subscription(Id id, String title) {
            this.id = id;
            this.title = title;
        }
    }

    public static testMethod void testController() {
        /* 14-03-11 vishals@grazitti.com Added to increase code coverage */
        Idea idea = new Idea();
        idea.Title = 'Test';
        idea.Body = 'Test';
        idea.CommunityId = GlobalFunctions.communityId;
        insert idea;
        
        IdeaComment comment = new IdeaComment();
        comment.IdeaId = idea.Id;
        comment.CommentBody = 'Test';
        insert comment;
        
        Question question = new Question();
        question.Title = 'Test';
        question.Body = 'Test';
        question.CommunityId = GlobalFunctions.communityId;
        insert question;
        
        Reply myReply = new Reply(QuestionId = question.Id);
        myReply.Body = ' answer 2';
        insert myReply;
        
        List<Community_Subscription__c> subscriptions = new List<Community_Subscription__c>();
        Community_Subscription__c commSub = new Community_Subscription__c();
        commSub.idea_question_id__c = idea.id;
        commSub.user__c = UserInfo.getUserId();
        commSub.type__c = 'Idea';
        commSub.Category__c = 'All Categories';
        subscriptions.add(commSub);
        
        Community_Subscription__c commSub1 = new Community_Subscription__c();
        commSub1.idea_question_id__c = idea.id;
        commSub1.user__c = UserInfo.getUserId();
        commSub1.type__c = 'Comment';
        commSub1.Category__c = 'All Categories';
        subscriptions.add(commSub1);
        
        Community_Subscription__c commSub3 = new Community_Subscription__c();
        commSub3.idea_question_id__c = idea.id;
        commSub3.user__c = UserInfo.getUserId();
        commSub3.type__c = 'Idea';
        commSub3.Category__c = 'All';
        subscriptions.add(commSub3);
        
        Community_Subscription__c commSub4 = new Community_Subscription__c();
        commSub4.idea_question_id__c = idea.id;
        commSub4.user__c = UserInfo.getUserId();
        commSub4.type__c = 'Comment';
        commSub4.Category__c = 'All';
        subscriptions.add(commSub4);
        
        insert subscriptions;
        
        PageReference pageRef = Page.MarketoCommunityProfileEditSubscriptions;
        Test.setCurrentPage(pageRef);
        
        MarketoCommunityProfileEditSubController controller = new MarketoCommunityProfileEditSubController();
        controller.init();
        controller.cancelSubscription();
        controller.getHasSubscriptions();
        controller.subscribeAll();
    }

}