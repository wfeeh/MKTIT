@isTest
private class GlobalFunctions_Test {
    
    static testMethod void getShortBodyTest() {
        System.assertEquals(null, GlobalFunctions.getShortBody(null));
        System.assertEquals('test bold, italic, and underline.', GlobalFunctions.getShortBody('test <b>bold</b>, <i>italic</i>, and <u>underline</u>.'));
        /*System.assertEquals('test hyperlink with newline', GlobalFunctions.getShortBody('test <a href="">hyperlink</a> with\nnewline'));
        System.assertEquals('test <br/> <br/>  break tags', GlobalFunctions.getShortBody('test <br>\n<br/>\n break tags'));
        System.assertEquals('test paragraph<br/><br/> tags', GlobalFunctions.getShortBody('test <p>paragraph</p> tags'));
        */
        GlobalFunctions.MAX_SHORT_BODY_LENGTH = 10;
        System.assertEquals('test long  ...', GlobalFunctions.getShortBody('test long body'));
        /* 09-03-11 vishals@grazitti.com Added to increase code coverage */
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
        //question.categories = 'Marketing_Activities';
        question.CommunityId = GlobalFunctions.communityId;
        insert question;
        
        Reply myReply = new Reply(QuestionId = question.Id);
        myReply.Body = ' answer 2';
        insert myReply;
            
        List<Community_Post_Update__c> listCommPosts = new List<Community_Post_Update__c>();
        Community_Post_Update__c postUpdate1 = new Community_Post_Update__c();
        postUpdate1.Body__c = 'test';
        postUpdate1.post_Id__c = idea.Id;
        postUpdate1.Title__c = 'test';
        postUpdate1.post_Type__c = 'Idea';
        listCommPosts.add(postUpdate1);
        Community_Post_Update__c postUpdate2 = new Community_Post_Update__c();
        postUpdate2.Body__c = 'test';
        postUpdate2.post_Id__c = comment.Id;
        postUpdate2.Title__c = 'test';
        postUpdate2.post_Type__c = 'Comment';
        listCommPosts.add(postUpdate2);
        Community_Post_Update__c postUpdate3 = new Community_Post_Update__c();
        postUpdate3.Body__c = 'test';
        postUpdate3.post_Id__c = myReply.Id;
        postUpdate3.Title__c = 'test';
        postUpdate3.post_Type__c = 'Reply';
        listCommPosts.add(postUpdate3);
        Community_Post_Update__c postUpdate4 = new Community_Post_Update__c();
        postUpdate4.Body__c = 'test';
        postUpdate4.post_Id__c = question.Id;
        postUpdate4.Title__c = 'test';
        postUpdate4.post_Type__c = 'Question';
        listCommPosts.add(postUpdate4);
        insert listCommPosts;
        
        List<EmailTemplate> listEmTemplates = [select Id from EmailTemplate limit 1];
        
        List<Community_Subscription__c> subscriptions = new List<Community_Subscription__c>();
        Community_Subscription__c commSub = new Community_Subscription__c();
        commSub.idea_question_id__c = idea.id;
        commSub.user__c = UserInfo.getUserId();
        commSub.type__c = 'Idea';
        //insert commSub;
        subscriptions.add(commSub);
        Community_Subscription__c commSub1 = new Community_Subscription__c();
        commSub1.idea_question_id__c = idea.id;
        commSub1.user__c = UserInfo.getUserId();
        commSub1.type__c = 'Comment';
        //insert commSub1;
        subscriptions.add(commSub1);
        insert subscriptions;
        
        GlobalFunctions controller = new GlobalFunctions();
        GlobalFunctions.getIdea(String.valueOf(idea.id));
        GlobalFunctions.getIdeas('test','test','test',false);
        GlobalFunctions.getQuestion(String.valueOf(question.id));
        GlobalFunctions.getQuestions('Marketing_Activities','Solved','test',false);
        GlobalFunctions.getVotes();
        GlobalFunctions.formatDate(Date.today());
        GlobalFunctions.getIdeasForProfile(UserInfo.getUserId(),0,20);
        GlobalFunctions.getQuestionsForProfile(UserInfo.getUserId(),0,20);
        GlobalFunctions.getRepliesForProfile(UserInfo.getUserId(),0,20);
        Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};
        GlobalFunctions.getProfilesForUsers(userIds);
        GlobalFunctions.getSubscription(UserInfo.getUserId(), question.Id);
        GlobalFunctions.getCommentsForProfile(UserInfo.getUserId(),0,20);
        GlobalFunctions.getCommentsForIdea(idea.Id);
        GlobalFunctions.getReplies();
        GlobalFunctions.getRepliesForQuestion(question.Id);
        GlobalFunctions.updatePost(postUpdate1.Id);
        GlobalFunctions.updatePost(postUpdate2.Id);
        GlobalFunctions.updatePost(postUpdate3.Id);
        GlobalFunctions.updatePost(postUpdate4.Id);
        if(listEmTemplates.size() > 0){
            GlobalFunctions.createEmails(listEmTemplates.get(0).Id, null, subscriptions);
            GlobalFunctions.createEmail(listEmTemplates.get(0).Id, commSub.Id, commSub);
        }
        
        GlobalFunctions.sendStatusUpdatedNotifications(new set<Id>{idea.id});
        //DateTime dt = DateTime.newInstance(pInteger, pInteger, pInteger, pInteger, pInteger, pInteger);
        //GlobalFunctions.formatDate(dt);
    }
    
}