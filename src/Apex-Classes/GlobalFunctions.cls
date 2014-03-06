public class GlobalFunctions {

    //private static Id FROM_EMAIL_ID = [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Community'].Id;
    private static Id FROM_EMAIL_ID {
        get {
            if(FROM_EMAIL_ID == null ){
                Id tmpID =  [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Community'].Id;
                FROM_EMAIL_ID = tmpID ;
            }
            return FROM_EMAIL_ID;
        }
    } 
    
    /* 19-03-13 3822 bikramt Added ExcludeAccountTypes */
    public static List<String> ExcludeAccountTypes {
        get{return new List<String>{'ex-customer','ex-partner'};}
        set;
    }                   
    
    public static Integer MAX_SHORT_BODY_LENGTH = 250;

    private static String ideaSql = 'SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById,' +
                            'LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories,' + 
                            'Body,CreatedBy.Id, CreatedBy.Email, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = \'' + UserInfo.getUserId() + '\'), ' +
                            ' (select id from Comments) FROM Idea i ';
      
    private static String questionSql = 'SELECT Id, Title, numreplies, IsDeleted, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_consultant__c,CreatedBy.Spark__c, CreatedDate, CreatedById, CommunityId,' + 
                            'Body,CreatedBy.Email, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, (select datacategoryname from datacategoryselections), bestreplyid ';
     
    private static String articleSql = 'select a.title, a.createddate, a.lastpublisheddate, a.IsVisibleInCsp, a.publishstatus, a.summary, a.lastmodifieddate, a.Article_Text__c, ' + 
                            '(select DataCategoryGroupName, DataCategoryName From DataCategorySelections) from Article__kav a where ' +
                            'publishstatus = \'Online\' and ';
        
    private static String commentSql = 'SELECT idea.title, ideaId, commentbody, createddate, createdby.id, createdby.communitynickname, createdby.firstname, createdby.lastname, createdby.is_partner__c, CreatedBy.is_customer__c,CreatedBy.Spark__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c from IdeaComment ';
    
    private static String replySql = 'SELECT name, question.title, body, createddate, createdby.id, createdby.Email,createdby.firstname, createdby.lastname, createdby.communitynickname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c,CreatedBy.Spark__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_consultant__c from Reply ';
    
    private MarketoCommunityContentController mcce;
    public MarketoCommunityContent__c mcc {get; private set;} 
    public static final String communityId = '09a50000000PNNr';//MarketoCommunitySettings__c.getInstance().Community_Id__c;

    public STATIC final String MAX_RECORDS = '100';
   
    public GlobalFunctions() {
        init();
    }
    
    public void init() {
      //  mcce = new MarketoCommunityContentController();
      //  mcc = mcce.getMarketoCommunityContent();
    }
        
    public static Idea getIdea(String id) {
        return ((List<Idea>) Database.query(ideaSql + 'where id = \'' + id + '\' '))[0];
    }   
    
                                
    public static ApexPages.StandardSetController getIdeas(String category,String status, String section, Boolean inPopular) {
        String whereSql = '';  
        string status_string = '';                   
        whereSql += 'where communityId = \'' + communityId + '\' ';
     // whereSql += 'where communityId = \'' + communityId + '\' '+ 'and IsLocked != true ';

        if (category != null && category != 'All Categories') {
            whereSql += 'and Categories includes (\'' + category + '\') ';
        }
        if (status != null && status != 'All Statuses' ) {
            if (status.lastIndexOf('___') != -1) { // Case for the call where we want ideas for more than one status separated by ___
                List<String> statuses = status.split('___');
                
                for(String st:statuses) {
                    status_string += '\''+st+'\',';
                }
                status_string = status_string.replaceFirst(',$','');
                System.debug('status_string ======>'+status_string );
                whereSql += 'and Status in ('+status_string+') ';
            } else {
                 status_string = status.replace('\'','\\\'');
                   whereSql += 'and Status = \'' + status_string + '\' ';
                   System.debug('whereSql======>'+whereSql);
            }
        }
                      
        if (inPopular) {        
            whereSql += 'and Status != \'' + 'Done!'+ '\' ' + 'and Status != \'' + 'Done (Partially)'+ '\' '+ 'ORDER BY VoteTotal desc';
            System.debug('whereSql---> '+ whereSql );
        } 
        else {
           whereSql +=  'ORDER BY  CreatedDate desc';
           System.debug('whereSql---> '+ whereSql );
        }   
            
        //ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(ideaSql+whereSql)); Added LIMIT as per Paul's suggestions
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(ideaSql+whereSql+' LIMIT '+MAX_RECORDS));

        System.debug('ideaSql--->'+ideaSql+whereSql);
        System.debug('ideaSql--->'+ideaSql);
        System.debug('setCon--->'+setCon.getResultSize());
        setCon.setPageSize('Home' == section ? 5 : 10);
        return setCon;
    }

    public static Question getQuestion(String id) {
        return ((List<Question>) Database.query(questionSql + ' from Question where Id = \'' + id + '\' '))[0];
    }    

    public static ApexPages.StandardSetController getQuestions(String category, String status, String section, Boolean inPopular) {
        String sql = questionSql;
            
        sql += ', (select Id from Replies) from Question q ';    
        
        String whereSql = 'where communityId = \'' + communityId + '\' ';
        
        if (status == 'Solved') {
            whereSql += 'and BestReplyId != null ';
        }
        else if (status == 'Unsolved') {
            whereSql += 'and BestReplyId = null ';
        }
            
        if (category != null && category != 'All Categories') {
            whereSql += 'WITH DATA CATEGORY Answers__c at ' + category + '__c ';
        }
        
        whereSql += 'ORDER BY CreatedDate desc';
              
        //ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(sql+whereSql)); Added LIMIT as per Paul Suggestions
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(sql+whereSql+' LIMIT '+MAX_RECORDS));
        
        setCon.setPageSize('Home' == section? 5 : 10);
        return setCon;
    }
    
   public static ApexPages.StandardSetController getActiveQuestions(String category, String status, String section, Boolean inPopular) {

        // Last week comment count on ideas
        List<AggregateResult> qsnCommentCounts = [Select r.QuestionId Id, count(r.Id) c From Reply r where r.CreatedDate > LAST_WEEK  GROUP BY r.QuestionId ORDER by count(r.Id) DESC];
        System.debug('__QUESTION_COMMENT_COUNTS__'+qsnCommentCounts);
        Set<Id> activeQuestions = new Set<Id>();
        String activeQuestionsIdsString;
        for(AggregateResult ar:qsnCommentCounts) {
            activeQuestions.add(ar.Id);
            
            activeQuestionsIdsString = '\''+ar.Id+'\',';
        }
        System.debug('__ActiveQuestions__'+activeQuestions);
        System.debug('activeQuestionsIdsString ===>'+activeQuestionsIdsString );
        ApexPages.StandardSetController setCon;
        if (category != null && category != 'All Categories') {
            String categ = category + '__c ';
            System.debug('categ ===>'+categ );
            if(activeQuestionsIdsString != '') {
                  activeQuestionsIdsString = activeQuestionsIdsString.substring(0,activeQuestionsIdsString.length()-1);
                  
                  activeQuestionsIdsString = '('+activeQuestionsIdsString+')';
            }
            System.debug('activeQuestionsIdsString ===>'+activeQuestionsIdsString );
            System.Debug('__KILLER_SQL__ SELECT Id, Title, numreplies, IsDeleted, CreatedBy.Email,CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_consultant__c,CreatedBy.Spark__c, CreatedDate, CreatedById, CommunityId, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, (select datacategoryname,ParentId from datacategoryselections), bestreplyid , (select Id from Replies) from Question q where communityId = \''+communityId+'\' and Id in '+activeQuestionsIdsString+' WITH DATA CATEGORY Answers__c at '+categ+' ORDER BY CreatedDate desc');
            setCon = new ApexPages.StandardSetController(Database.Query('SELECT Id, Title, numreplies, IsDeleted, CreatedBy.Email,CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_consultant__c,CreatedBy.Spark__c, CreatedDate, CreatedById, CommunityId, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, (select datacategoryname from datacategoryselections), bestreplyid , (select Id from Replies) from Question q where communityId = \''+communityId+'\' and Id in :activeQuestions WITH DATA CATEGORY Answers__c at '+categ+' ORDER BY CreatedDate desc'));
          } else {
            setCon = new ApexPages.StandardSetController([SELECT Id, Title, numreplies, IsDeleted, CreatedBy.Email,CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_consultant__c,CreatedBy.Spark__c, CreatedDate, CreatedById, CommunityId, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, (select datacategoryname from datacategoryselections), bestreplyid , (select Id from Replies) from Question q where communityId = :communityId and Id in :activeQuestions ORDER BY LastReplyDate desc]);
        } 
       setCon.setPageSize('Home' == section? 5 : 10);
       return setCon;  
     
    } 
    
     public static ApexPages.StandardSetController getActiveIdeas(String category, String status, String section, Boolean inPopular) {

        // Last week comment count on ideas
        List<AggregateResult> ideaCommentCounts = [Select i.Idea.id, count(Id)  c From IdeaComment i where i.CreatedDate > LAST_WEEK  GROUP BY i.Idea.id ORDER by count(Id) DESC];
        System.debug('__IDEA_COMMENT_COUNTS__'+ideaCommentCounts);
        List<Id> activeIdeas = new List<Id>();
        for(AggregateResult ar:ideaCommentCounts) {
            activeIdeas.add(ar.Id);
            System.debug('activeIdeas====>'+activeIdeas);
        }
        
        ApexPages.StandardSetController setCon;
        if (category != null && category != 'All Categories') {
            if (status != null && status != 'All Statuses' && status != 'Done!') {
                 setCon = new ApexPages.StandardSetController([SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById, LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = :UserInfo.getUserId()), (select id from Comments order by CreatedDate desc) FROM Idea i where communityId = :communityId and Id in :activeIdeas and Categories includes (:category) and Status =:status and IsLocked != true order by LastCommentDate desc]);
                  System.Debug('___setcon1__');
            } else {
                 setCon = new ApexPages.StandardSetController([SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById, LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = :UserInfo.getUserId()), (select id from Comments) FROM Idea i where communityId = :communityId and Id in :activeIdeas  and Categories includes (:category) and Status =:status and IsLocked != true order by LastCommentDate desc]);
                 // System.Debug('___setcon2__');
            }
        } else {
            if (status != null && status != 'All Statuses' ) {
                 setCon = new ApexPages.StandardSetController([SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById, LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = :UserInfo.getUserId()), (select id from Comments) FROM Idea i where communityId = :communityId and Id in :activeIdeas  and Status =:status and IsLocked != true order by LastCommentDate desc]);
                //  System.Debug('___setcon3__');
            } else {
                 setCon = new ApexPages.StandardSetController([SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById, LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = :UserInfo.getUserId()), (select id from Comments order by SystemModstamp desc) FROM Idea i where communityId = :communityId and Id in :activeIdeas and Status != 'Done!' and Status != 'Done(Partially)' and IsLocked != true order by LastCommentDate desc]);
                 System.Debug('___setcon4__');
            }        
        }               
   
        System.debug('ideaSql--->'+ideaSql);
        System.debug('setCon--->'+setCon);
        setCon.setPageSize('Home' == section ? 5 : 10);
        return setCon;
    }  
                       
    public static ApexPages.StandardSetController getVotes() {
        for (Idea i : [SELECT Id, (select Id, CreatedById from Votes) from Idea where LastCommentDate < today order by CreatedDate desc limit 10]) {
        }

        return null;
    }
    
    public static SObject getArticle(String id) {
        List<SObject> articles = Database.query(articleSql + ' KnowledgeArticleId = \'' + id + '\'');       
        return articles.size() > 0 ? articles[0] : null;
    }
    
    public static List<Idea> getIdeasForProfile(String createById, Integer offset, Integer numberOfRecords) {
        String sql = ideaSql + 'where createdbyid = \'' + createById + '\' order by CreatedDate desc limit '+numberOfRecords+' OFFSET '+offset;  
        return (List<Idea>) Database.query(sql);
    }
    
    public static List<Question> getQuestionsForProfile(String createById, Integer offset, Integer numberOfRecords) {
        String sql = questionSql + 'from Question where CreatedById = \'' + createById + '\' ORDER BY CreatedDate desc limit '+numberOfRecords+' OFFSET '+offset; 
        return (List<Question>) Database.query(sql);
    }
    
    public static List<Reply> getRepliesForProfile(String createById, Integer offset, Integer numberOfRecords) {
        String sql = replySql + ' where CreatedById = \'' + createById + '\'order by CreatedDate desc limit '+numberOfRecords+' OFFSET '+offset;  
        return (List<Reply>) Database.query(sql);
    }
    
    public static List<IdeaComment> getCommentsForProfile(String createById, Integer offset, Integer numberOfRecords) {
        String sql = commentSql + ' where CreatedById = \'' + createById + '\'ORDER BY CreatedDate desc limit '+numberOfRecords+' OFFSET '+offset;     
        return (List<IdeaComment>) Database.query(sql);
    }
    
    public static Map<Id, Community_Profile__c> getProfilesForUsers(Set<Id> userIds) {
        List<Community_Profile__c> profiles = [select Id, User__c, Display_Name__c, Profile_Picture_ID__c, Member_of_user_group__c from Community_Profile__c where User__c in :userIds];
        
        Map<Id, Community_Profile__c> userIdToProfileMap = new Map<Id, Community_Profile__c>();
        for (Community_Profile__c profile : profiles) {
            userIdToProfileMap.put(profile.User__c, profile);
        }        
        return userIdToProfileMap;
    }

    public static List<Community_Subscription__c> getSubscription(Id userId, Id quesId) {
        return new List<Community_Subscription__c>([select id,Idea_Question_Id__c,User__r.Email from Community_Subscription__c where user__c = :userId and idea_question_id__c = :quesId]);
    }
     
    
    
    public static List<IdeaComment> getCommentsForIdea(Id id) {
        String sql = commentSql + ' where IdeaId = \'' + id + '\' order by CreatedDate asc';  
        return (List<IdeaComment>) Database.query(sql);
    }

    public static ApexPages.StandardSetController getReplies() {
        String sql = replySql + 'ORDER BY CreatedDate desc limit 10';  
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(Database.getQueryLocator(sql));
        return setCon;
    }
    
    public static List<Reply> getRepliesForQuestion(Id quesId) {
        String sql = replySql + ' where questionid = \'' + quesId + '\'' + 'order by createddate asc';  
        return (List<Reply>) Database.query(sql);
    }
    
    public static Reply getReplyCreatorDetails(Id replyId) {
        String sql = replySql + ' where Id = \'' + replyId + '\'' + ' limit 1 ';  
        System.debug('sql---->'+sql);
        return Database.query(sql);
    }
    
    public static Integer getTotalsObjectsByCreatedById(String sObjectType, String createdById) {
        String sObjectCountSql = 'SELECT count() FROM '+sObjectType+' where createdById =\''+createdById+'\'';
        return Database.countQuery(sObjectCountSql);
    }
    
    
    public static void sendEmailDebug(List<Messaging.SingleEmailMessage> emails) {    
        try{
           System.debug('============'+emails);
           Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);
           /* 09-03-11 vishals@grazitti.com Fixed Array Index of bound exception*/
           LIST<Messaging.SendEmailError> emailErrors ;//
           if(resultMail != null && resultMail.size() > 0)
                emailErrors = resultMail[0].getErrors();
           String response;
           
           if(resultMail != null && resultMail.size() > 0 && resultMail[0].isSuccess()) {
               response = 'ok sent!';
           }
           else{
               if(resultMail != null && resultMail.size() > 0)
                    response = resultMail[0].getErrors().get(0).getMessage();
           }
           System.debug('Email response = ' + response);
           

        }
        catch(System.EmailException ex){
          system.debug('============== email exception caught!!!=============');
          System.debug('Email response = ' + ex.getMessage());
        } 
    }
    
    //steffi updated for Issue 3785
    @future 
    public static void allStickyPost(Id QuesIdeaIds, string Type, String stickyComment) {
        try{
             List<StickyPost__c> myStickypost = new List<StickyPost__c>();
               StickyPost__c mySticky = new StickyPost__c();
               mySticky.Date_Time__c = DateTime.Now(); 
               mySticky.Discussion_IdeaID__c = QuesIdeaIds;
               mySticky.Type__c = Type;
               mySticky.Name = stickyComment;
               myStickypost.add(mySticky);  
               insert myStickypost;
          }catch (Exception e) {
          }       
        
    }
    
    //@future
    public static void sendCommentNotifications(Set<Id> commentIds) {
        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_Idea_Comment'].Id;
        List<IdeaComment> comments = [select Id, IdeaId, CreatedById from IdeaComment where Id in :commentIds];
        Set<Id> ideaIds = new Set<Id>();
        for (IdeaComment comment : comments) {
            ideaIds.add(comment.IdeaId);
        }
        Map<Id, List<Community_Subscription__c>> ideaIdToSubscriptionsMap = new Map<Id, List<Community_Subscription__c>>();
        List<Community_Subscription__c> subscriptions = [select User__c,User__r.Email,Idea_Question_Id__c from Community_Subscription__c where Idea_Question_Id__c in :ideaIds AND User__r.Contact.Account.Type NOT IN: ExcludeAccountTypes];
        for (Community_Subscription__c subscription : subscriptions) {
            List<Community_Subscription__c> ideaSubscriptions = ideaIdToSubscriptionsMap.get(subscription.Idea_Question_Id__c);
            if (ideaSubscriptions == null) {
                ideaSubscriptions = new List<Community_Subscription__c>();
                ideaIdToSubscriptionsMap.put(subscription.Idea_Question_Id__c, ideaSubscriptions);
            }         
            ideaSubscriptions.add(subscription);
        }
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (IdeaComment comment : comments) {
            List<Community_Subscription__c> ideaSubscriptions = ideaIdToSubscriptionsMap.get(comment.IdeaId);
            List<Community_Subscription__c> ideaSubscriptionsNew = new List<Community_Subscription__c> ();
            if(ideaSubscriptions != null) {
                for(Community_Subscription__c commSubscriptns : ideaSubscriptions ) {
                    if(commSubscriptns.User__c != comment.createdbyId)
                        ideaSubscriptionsNew.add(commSubscriptns);
                }            
                if (ideaSubscriptionsNew != null) {
                    emails.addAll(createEmails(templateId, comment.IdeaId, ideaSubscriptionsNew)); //ideaSubscriptions));
                }
            }
        }
        //Messaging.sendEmail(emails);
        sendEmailDebug(emails);
    }
        
    //@future
    public static void sendReplyNotifications(Set<Id> replyIds) {
        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_Question_Reply'].Id;

        List<Reply> replies = [select Id, QuestionId, CreatedById from Reply where Id in :replyIds];

        Set<Id> questionIds = new Set<Id>();
        /* 07-04-11 vishals@grazitti.com added to exculde the user which has just replied on a question*/
        Set<String> exceptUsers = new Set<String>(); 
        for (Reply reply : replies) {
            questionIds.add(reply.QuestionId);
            exceptUsers.add(reply.CreatedById);
        }
        /* 07-04-11 vishals@grazitti.com added to exculde the user which has just replied on a question*/
        /* 19-03-13 bikram added ExcludeAccountTypes*/
        Map<Id, List<Community_Subscription__c>> questionIdToSubscriptionsMap = new Map<Id, List<Community_Subscription__c>>();
        
        List<Community_Subscription__c> subscriptions = [select User__c,User__r.Email,Idea_Question_Id__c from Community_Subscription__c where Idea_Question_Id__c in :questionIds and User__c not in : exceptUsers AND User__r.Contact.Account.Type NOT IN: ExcludeAccountTypes];
        for (Community_Subscription__c subscription : subscriptions) {
            List<Community_Subscription__c> questionSubscriptions = questionIdToSubscriptionsMap.get(subscription.Idea_Question_Id__c);
            if (questionSubscriptions == null) {
                questionSubscriptions = new List<Community_Subscription__c>();
                questionIdToSubscriptionsMap.put(subscription.Idea_Question_Id__c, questionSubscriptions);
            }
            
            questionSubscriptions.add(subscription);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Reply reply : replies) {
            List<Community_Subscription__c> questionSubscriptions = questionIdToSubscriptionsMap.get(reply.QuestionId);
            if (questionSubscriptions != null) {
                emails.addAll(createEmails(templateId, reply.Id, questionSubscriptions));
            }
        }

        //Messaging.sendEmail(emails);
        sendEmailDebug(emails);
    }
    
    //@future
    public static void sendArticleFeedbackNotifications(Set<Id> feedbackIds) {
        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_Article_Feedback'].Id;

        List<Article_FeedBack__c> feedbacks = [select Id, Article_Id__c, CreatedById from Article_FeedBack__c where Id in :feedbackIds]; //__WILL_FIX_IT_LATER__

        Set<Id> articleIds = new Set<Id>();
        Set<String> exceptUsers = new Set<String>(); 
        for (Article_FeedBack__c feedback : feedbacks) {
            articleIds.add(feedback.Article_Id__c);
            exceptUsers.add(feedback.CreatedById);
        }
        Map<Id, List<Community_Subscription__c>> articleIdToSubscriptionsMap = new Map<Id, List<Community_Subscription__c>>();
        System.Debug('articleIds'+articleIds);
        System.Debug('exceptUsers'+exceptUsers);
        List<Community_Subscription__c> subscriptions = [select User__c,User__r.Email,Idea_Question_Id__c from Community_Subscription__c where Idea_Question_Id__c in :articleIds and User__c not in : exceptUsers AND User__r.Contact.Account.Type NOT IN: ExcludeAccountTypes];
        for (Community_Subscription__c subscription : subscriptions) {
            List<Community_Subscription__c> articleSubscriptions = articleIdToSubscriptionsMap.get(subscription.Idea_Question_Id__c);
            if (articleSubscriptions == null) {
                articleSubscriptions = new List<Community_Subscription__c>();
                articleIdToSubscriptionsMap.put(subscription.Idea_Question_Id__c, articleSubscriptions);
            }
            
            articleSubscriptions.add(subscription);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Article_FeedBack__c feedback : feedbacks) {
            List<Community_Subscription__c> articleSubscriptions = articleIdToSubscriptionsMap.get(feedback.Article_Id__c);
            if (articleSubscriptions != null) {
                emails.addAll(createEmails(templateId, feedback.Id, articleSubscriptions));
            }
        }

        //Messaging.sendEmail(emails);
        sendEmailDebug(emails);
    }
    
    public static void sendCommentAddedNotifications(Set<Id> ideaIds) {
        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_Idea_Comment'].Id;

        sendIdeaNotifications(templateId, ideaIds, false);
    }
    
    public static void sendStatusUpdatedNotifications(Set<Id> ideaIds) {
        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_Idea_Status'].Id;

        sendIdeaNotifications(templateId, ideaIds, true);
    }
    
    public static void sendIdeaNotifications(Id templateId, Set<Id> ideaIds, Boolean isStatusMail) {
        Map<Id, List<Community_Subscription__c>> ideaIdToSubscriptionsMap = new Map<Id, List<Community_Subscription__c>>();
        Set<String> commentIds = new Set<String>(); 
        Set<String> exceptUsers = new Set<String>(); 
        List<Community_Subscription__c> subscriptions;
        System.debug('ideaIds-->'+ideaIds);
        List<Idea> childIdeas = new List<Idea>();
        
        //Bikram 7/Mar temp bug fix for Idea IsLocked bug due to api version to be fixed as soon as possible         
        //childIdeas= [Select i.Status, i.ParentIdeaId, i.Categories, i.NumComments,i.CreatedDate, i.IsLocked, i.Id, i.CreatedBy.Name, i.CreatedBy.Id, i.Body, i.title From Idea i where i.ParentIdeaId =:ideaIds ];
        childIdeas= [Select i.Status, i.ParentIdeaId, i.Categories, i.NumComments,i.CreatedDate, i.Id, i.CreatedBy.Name, i.CreatedBy.Id, i.Body, i.title From Idea i where i.ParentIdeaId =:ideaIds ];
        
        
        System.debug('childIdeas----> '+childIdeas);
        set<Id> parentIdeaId = new set<Id>();
        for(Idea Ids:childIdeas){
        parentIdeaId.add(Ids.Id);
        }
        System.debug('parentIdeaId---->'+parentIdeaId);
        /* 07-04-11 vishals@grazitti.com added to exculde the user which has just commented on a Idea*/
        if(isStatusMail != null && !isStatusMail){
            for(Idea ide :[select Id, status, CreatedById, LastCommentId from Idea where Id in :ideaIds]){
                commentIds.add(ide.LastCommentId);
                System.debug('commentIds--->'+commentIds);
            }
            
            List<IdeaComment> comments = [select Id,CreatedById from IdeaComment where Id in: commentIds];
            /* 07-04-11 vishals@grazitti.com added to exculde the user which has just commented on a Idea*/
            
            for (IdeaComment comm : comments) {
                exceptUsers.add(comm.CreatedById);
            }
            /* 07-04-11 vishals@grazitti.com added to exculde the user which has just commented on a Idea*/
            
            subscriptions = [select User__c,User__r.Email, Idea_Question_Id__c from Community_Subscription__c where (Idea_Question_Id__c in :ideaIds OR Idea_Question_Id__c in :parentIdeaId) and User__c not in:exceptUsers AND User__r.Contact.Account.Type NOT IN: ExcludeAccountTypes];
            System.debug('subscriptions--->'+subscriptions );
        }else{
             subscriptions = [select User__c,User__r.Email, Idea_Question_Id__c from Community_Subscription__c where (Idea_Question_Id__c in :ideaIds OR Idea_Question_Id__c in :parentIdeaId) AND User__r.Contact.Account.Type NOT IN: ExcludeAccountTypes];
            System.debug('subscriptions--->'+subscriptions );
        }
        
        for (Community_Subscription__c subscription : subscriptions) {
            List<Community_Subscription__c> ideaSubscriptions = ideaIdToSubscriptionsMap.get(subscription.Idea_Question_Id__c);
            if (ideaSubscriptions == null) {
                ideaSubscriptions = new List<Community_Subscription__c>();
                ideaIdToSubscriptionsMap.put(subscription.Idea_Question_Id__c, ideaSubscriptions);
            }
            
            ideaSubscriptions.add(subscription);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Id ideaId : ideaIds) {
            List<Community_Subscription__c> ideaSubscriptions = ideaIdToSubscriptionsMap.get(ideaId);
            if (ideaSubscriptions != null) {
                emails.addAll(createEmails(templateId, ideaId, ideaSubscriptions));
            }
        }

        //Messaging.sendEmail(emails);
        sendEmailDebug(emails);
    }

    public static List<Messaging.SingleEmailMessage> createEmails(Id templateId, Id whatId, List<Community_Subscription__c> subscriptions) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Community_Subscription__c subscription : subscriptions) {
            emails.add(createEmail(templateId, whatId, subscription));
        }

        return emails;
    }
    
    public static Messaging.SingleEmailMessage createEmail(Id templateId, Id whatId, Community_Subscription__c subscription) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(templateId);
        //email.setReplyTo('community@marketo.com');
        email.setTargetObjectId(subscription.User__c);
        email.setWhatId(whatId);
        email.setSaveAsActivity(false);
        email.setOrgWideEmailAddressId(FROM_EMAIL_ID);

        return email;
    }
    
    public static String formatDate(DateTime dt) {
        return dt.date().format() + ' ' +
                (dt.hour() > 12 ? dt.hour()-12 : dt.hour()) + ':' +
                (dt.minute() < 10 ? '0' + String.valueOf(dt.minute()) : String.valueOf(dt.minute())) + ' ' +
                (dt.hour() >= 12 && dt.hour() <= 24 ? ' PM' : ' AM'); 
    }

    public static String getShortBody(String body) {
    
        return getShortBody(body, MAX_SHORT_BODY_LENGTH);
    }
    
    public static String getShortBody(String body, Integer maxCharacters) {
        if (body == null) return null;        
        integer indexOfStartTag = 0;
        integer indexOfEndTag = 0;
        string strStartTag = '<a';
        string strEndTag = '</a>';
        String shortBody = body;
        String linkBody = '';      
        if (shortBody.contains(strStartTag)) {
            indexOfStartTag = shortBody.indexOf(strStartTag);
            system.debug('*******indexOfStartTag *********' + indexOfStartTag );
        }
        if (shortBody.contains(strEndTag)) {
            indexOfEndTag = shortBody.indexOf(strEndTag);
            system.debug('*******indexOfEndTag *********' + indexOfEndTag );
        }              
        if(indexOfStartTag > -1 && indexOfEndTag > -1)
        {           
            if (indexOfStartTag < indexOfEndTag){          
                linkBody = shortBody.substring(indexOfStartTag , (indexOfEndTag + 4));
                if(linkBody.contains('<img')){
                    system.debug('imagestart');
                    linkbody = '<br>' + '<span style="float:left;padding-top:10px;">'+linkBody+'</span>';
                }
            }           
        }        
        
        shortBody = shortBody.replaceAll('[\r\n]+', ' ');
        shortBody = shortBody.replaceAll('<\\s*br[^>]*[/]?>', '\n'); // Temporarily convert <br> to newline character.
        shortBody = shortBody.replaceAll('</p>', '\n\n'); // Temporarily convert </p> to newline character.
        shortBody = shortBody.replaceAll('<[^>]*>?', '');
        if (shortBody.length() > maxCharacters) {
            shortBody = shortBody.substring(0, maxCharacters) + ' ...';
            
        }        
        if (linkBody.length() > 0) {
            shortBody += '...' + linkBody;
        }
        // Convert newline character back to <br/>.
        shortBody = shortBody.replaceAll('\n', '<br/>');
        return shortBody;
    }

    @future
    public static void updatePost(Id postUpdateId) {
        Community_Post_Update__c postUpdate = [select Post_Type__c, Post_Id__c, Title__c, Body__c from Community_Post_Update__c where Id = :postUpdateId];

        if ('Idea' == postUpdate.Post_Type__c) {
            Idea idea = new Idea(Id=postUpdate.Post_Id__c);
            idea.Title = postUpdate.Title__c;
            idea.Body = postUpdate.Body__c;
            update idea;
        } else if ('Comment' == postUpdate.Post_Type__c) {
            IdeaComment comment = new IdeaComment(Id=postUpdate.Post_Id__c);
            comment.CommentBody = postUpdate.Body__c;
            update comment;
        } else if ('Question' == postUpdate.Post_Type__c) {
            Question question = new Question(Id=postUpdate.Post_Id__c);
            question.Title = postUpdate.Title__c;
            question.Body = postUpdate.Body__c;
            update question;
        } else if ('Reply' == postUpdate.Post_Type__c) {
            Reply reply = new Reply(Id=postUpdate.Post_Id__c);
            reply.Body = postUpdate.Body__c;
            update reply;
        }
        
        delete postUpdate;
    }

    public static boolean getPartner_Supported_Status(ID userID)
    {        
        String userType = '';       
        String currUserMunchkinId;                
        List<User> userList = [select id, Munchkin_ID__c, UserType, Is_Consultant__c, Is_Employee__c from User where id = :userID];
        if(userList != null && userList.size() > 0) {
            if(userList[0].Is_Consultant__c == true || userList[0].Is_Employee__c == true)
                return true; 
            userType = userList[0].UserType ;
            currUserMunchkinId = userList[0].Munchkin_ID__c;
        }                
        if(userType != 'Standard' && userType != '') {
            List<Asset> assetList = [Select id, Partner_Supported__c, Purpose__c,Supported_Instance__c From Asset a 
            where Munchkin_ID__c = :currUserMunchkinId and Purpose__c = 'Production' and Munchkin_ID__c != null limit 1];
            if(assetList.size()  > 0) {                               
                if((assetList[0].Supported_Instance__c == true) || (assetList[0].Partner_Supported__c == true) )
                {                    
                    return true;                                                           
                }                  
            }                        
        }
        return false;        
    }   

   /* public static Map<Id, Boolean> getPartner_Supported_Status_ForUsers(Set<Id> userIds) 
    {
        Map<Id, Boolean> userIdToStatusMap = new Map<Id, Boolean>();
        List<String> myIds = new List<String>();
        Map<String,Id> userMunKId  = new Map<String,Id>();        
        for (Id usrid : userIds) {
            userIdToStatusMap.put(usrid, FALSE);
        }             
        List<User> userList = [select Id, Munchkin_ID__c, UserType from User where 
        (userType != 'Standard' OR userType != '') AND Munchkin_ID__c != null and id in :userIds];       
        for (User usr : userList ) {                            
            userMunKId.put(usr.Munchkin_ID__c,usr.Id);  
            myIds.add(usr.Munchkin_ID__c);                                            
        }
        if(myIds.size()>0)
        {
            List<Asset> assetList = [Select id, Munchkin_ID__c From Asset a 
            where (Supported_Instance__c = true or Partner_Supported__c = true) and Purpose__c = 'Production' and 
            Munchkin_ID__c in :myIds];
            for(Asset Asst : assetList) {
                userIdToStatusMap.put(userMunKId.get(Asst.Munchkin_ID__c),TRUE);                               
            }                         
        }                       
        return userIdToStatusMap ;
    }*/
    
    
     public static Map<Id, Boolean> getPartner_Supported_Status_ForUsers(Set<Id> userIds) 
    {
        Map<Id, Boolean> userIdToStatusMap = new Map<Id, Boolean>();
        List<String> myIds = new List<String>();
        Map<String,List<Id>> userMunKIds  = new Map<String,List<Id>>();        
        for(Id usrid : userIds) {
            userIdToStatusMap.put(usrid, FALSE);
        }             
        List<User> userList = [select Id, Munchkin_ID__c, UserType, Is_Consultant__c, Is_Employee__c from User where  id in :userIds];       
 
        for (User usr : userList) {
            if(usr.Is_Consultant__c == true || usr.Is_Employee__c == true)
                userIdToStatusMap.put(usr.Id, TRUE);
            else if(usr.userType != 'Standard' && usr.userType != '') {                                          
                if(userMunKIds.containsKey(usr.Munchkin_ID__c)) {
                   userMunKIds.get(usr.Munchkin_ID__c).add(usr.Id); 
                } else {
                    userMunKIds.put(usr.Munchkin_ID__c, new List<Id>{usr.id});
                }  
                myIds.add(usr.Munchkin_ID__c);                                            
            }
        }
        system.debug('TESTING'+myIds);
        if(myIds.size()>0)
        {
            List<Asset> assetList = [Select id, Munchkin_ID__c From Asset a where (Supported_Instance__c = true or Partner_Supported__c = true) and Purpose__c = 'Production' and Munchkin_ID__c != null and Munchkin_ID__c in :myIds];            
 
 
            for(Asset Asst : assetList) {
                if(userMunKIds.containsKey(Asst.Munchkin_ID__c)){
                    system.debug('=>' + userMunkids);
                    for(Id usrId : userMunKIds.get(Asst.Munchkin_ID__c))
                        userIdToStatusMap.put(usrId,TRUE);                                               
                }
            }                         
        }                       
        return userIdToStatusMap ;
    }
   public static Map<Id, boolean> getIsCertifiedUserMap(Set<Id> userIds) 
    {
        Map<Id, Boolean> userIdToCertificationMap = new Map<Id, Boolean>();
        for (Id usrid : userIds) {
            userIdToCertificationMap.put(usrid, FALSE);
        }   
             
        Map<Id,User> selectedUserContactMap =  new Map<Id,User>([SELECT Id, Email, ContactId FROM User WHERE IsPortalEnabled = true and isActive = true and Id IN :userIds]);
        if(selectedUserContactMap.isEmpty() == false){
            
            Set<Id> selectedUserContactList = new Set<Id>();
            Map<Id,Id> selectedContactToUserMap = new Map<Id,Id>();
            
            for(Id tmpKey : selectedUserContactMap.keySet()) {
                selectedUserContactList.Add(selectedUserContactMap.get(tmpKey).ContactId); 
                selectedContactToUserMap.put(selectedUserContactMap.get(tmpKey).ContactId,tmpKey);
            }                      
            List<Certification_History__c> certificationList = [Select Certification_Level__c,Business_Email_Address__c, Certification_Contact__c From Certification_History__c where Exam_Result__c = 'Pass' AND Certification_Contact__c in :selectedUserContactList ];
            Set<Id> certifiedSet = new Set<Id>(); 
            for (Certification_History__c  certHistRec: certificationList) {
                if(selectedContactToUserMap.containsKey(certHistRec.Certification_Contact__c)) {                
                    if(userIdToCertificationMap.containsKey(selectedContactToUserMap.get(certHistRec.Certification_Contact__c))){                
                        userIdToCertificationMap.put(selectedContactToUserMap.get(certHistRec.Certification_Contact__c), TRUE);
                    }
                }
            }
            /*
            if(certifiedSet.isEmpty() ==false){                
                for (Id usrid : selectedUserContactMap.KeySet()) {
                    if(certifiedSet.contains(selectedUserContactMap.get(usrid).ContactId))
                        userIdToCertificationMap.put(usrid, TRUE);                
                }
            }*/                                                    
        }                                                
        return userIdToCertificationMap ;    
    }
    
    public static Map<Id, String> getUserGroupNameMap(Set<Id> userIds) 
    {
        Map<Id, String> userIdToGroupMap = new Map<Id, String>();
        for (Id usrid : userIds) {
            userIdToGroupMap.put(usrid, '');
        } 
        List<Community_Profile__c> userProfile = [select Id, Member_of_user_group__c from Community_Profile__c where Member_of_user_group__c <>NULL AND User__c in :userIds];
        for(Community_Profile__c usrPrf : userProfile) {
            userIdToGroupMap.put(usrPrf.Id,usrPrf.Member_of_user_group__c);            
        }
        return  userIdToGroupMap;    
    }
}