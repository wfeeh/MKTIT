public class EmailPostController {

    private static String SELECT_CLAUSE = 'select Id, Title, Body, CreatedById, CreatedBy.FirstName, CreatedBy.LastName, CreatedDate';

    public String postType {get; set;}
    public String postGroup {get; set;}
    public String postCategory {get; set;}
    public Integer postCount {get; set;}
    Public String newsalertstype{get;set;}
    //Public Integer count;
    private List<EmailPost> posts;

    public List<EmailPost> getPosts() {
        System.Debug('---POSTTYPE--'+postType);
        System.Debug('--posts--- '+posts );
        if (posts == null) {
            if ('Idea' == postType) {
                posts = getIdeaPosts();
            }else if('News' == postType){
              posts = getNewsPosts();
            }
            else{
                Posts = getQuestionPosts();
            }
        }
        return posts;
    }
    
    //steffi update this for issue 2598
    // this is for insertion and updated mail send only 
    
    public List<EmailPost> getNewsPosts() {        
        
        List<EmailPost> posts = new List<EmailPost>();
        Set<Id> NewsandAlerts = SupportNewsTriggerHelper.setSNIds;
        List<Marketo_News__c> News = [select Id,Description__c,Type__c,Publish_Date__c,Name from Marketo_News__c 
                      where Id IN: NewsandAlerts AND active__c = true AND (Type__c = 'News' OR Type__c ='Alert')]; 
        System.debug('News==>' + News);
        for(Marketo_News__c newsmar : News){
            System.debug('newsmar==>' + newsmar);
            EmailPost post = new EmailPost();
            post.id = newsmar .Id;
            post.title = newsmar.Name;
            post.body = newsmar.Description__c;
            post.Publishdate = newsmar.Publish_Date__c;
            post.type = newsmar.Type__c; 
            newsalertstype =  post.type;   
            posts.add(post);
        }
        return posts;  
    }
    
    public Integer getPostsCount() {
        return getPosts().size();
    }

    public List<EmailPost> getIdeaPosts() {
        /* 08-04-11 vishals@grazitti.com Added to query only yesterday's records*/
        // Calculate since date for new count queries. If today is
        // Monday, go back 3 days (to cover weekend), else 1 day.
        String dayOfWeek = DateTime.now().format('EEEE');
        DateTime sinceDate = DateTime.now().addDays(dayOfWeek == 'Monday' ? -3 : -1);
        
        String query = SELECT_CLAUSE + ' from Idea ';
        if (postCategory != null && postCategory != 'All') {
            /* 08-04-11 vishals@grazitti.com Added to query only yesterday's records*/
            query += 'where Categories includes (\'' + postCategory + '\') ' + ' and CreatedDate >= ' + sinceDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
            //query += 'where Categories includes (\'' + postCategory + '\') '; 
        }
        query += ' order by CreatedDate desc limit ' + postCount;

        List<Idea> newIdeas = (List<Idea>) Database.query(query);
        
        List<Idea> ideas = newIdeas;
        if ('Popular' == postGroup) {
            List<String> newIdeaIds = new List<String>();
            for (Idea idea : newIdeas) {
                newIdeaIds.add(idea.Id);
            }

            // Calculate since date for comment count query. If today is
            // Monday, go back 3 days (to cover weekend), else 1 day.
            //String dayOfWeek = DateTime.now().format('EEEE');
            //DateTime sinceDate = DateTime.now().addDays(dayOfWeek == 'Monday' ? -3 : -1);

            // Find comments posted since the since date.
            String commentQuery = 'select IdeaId from IdeaComment ';            
            commentQuery += 'where IdeaId not in (\'' + join(newIdeaIds, '\',\'') + '\') ';
            commentQuery += 'and CreatedDate >= ' + sinceDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            if (postCategory != null && postCategory != 'All') {
                commentQuery += 'and Idea.Categories includes (\'' + postCategory + '\') '; 
            }
            System.debug('====commentQuery=======>'+commentQuery);
            List<IdeaComment> comments = Database.query(commentQuery);

            // Prepare list of popular Idea ids based on those Ideas having more than one comment.
            Map<String, Integer> ideaCommentCounts = new Map<String, Integer>();
            Set<String> popularIdeaIds = new Set<String>();
             System.debug('====comments=======>'+comments);
            for (IdeaComment comment : comments) {
                Integer count = ideaCommentCounts.get(comment.IdeaId);
                if (count == null) {
                    ideaCommentCounts.put(comment.IdeaId, 1);
                } else {
                    ideaCommentCounts.put(comment.IdeaId, count + 1);

                    // Idea is considered popular if it has 2 or more comments.                 
                    popularIdeaIds.add(comment.IdeaId);
                }
            }

            // If there are no popular Ideas, exit early.
            if (popularIdeaIds.isEmpty()) {
                return new List<EmailPost>();
            }

            query = SELECT_CLAUSE + ' from Idea ';
            query += 'where Id in (\'' + join(popularIdeaIds, '\',\'') + '\') ';
            query += 'order by NumComments desc, CreatedDate desc ';
            query += 'limit ' + postCount;

            ideas = (List<Idea>) Database.query(query);
        }
        
        Set<Id> userIds = new Set<Id>();
        for (Idea idea : ideas) {
            userIds.add(idea.CreatedById);
        }
        
        Map<Id, Community_Profile__c> userIdToProfileMap = GlobalFunctions.getProfilesForUsers(userIds);
        
        List<EmailPost> posts = new List<EmailPost>();
        for (Idea idea : ideas) {
            Community_Profile__c profile = userIdToProfileMap.get(idea.CreatedById);
            
            EmailPost post = new EmailPost();
            post.id = idea.Id;
            post.title = idea.Title;
            post.body = idea.Body;
            post.posterId = idea.CreatedById;
            post.posterName = getPosterName(profile, idea.CreatedBy.FirstName, idea.CreatedBy.LastName);
            post.createdDate = idea.CreatedDate;
            
            posts.add(post);
        }
        
        return posts;
    }
    
    public List<EmailPost> getQuestionPosts() {
        /* 08-04-11 vishals@grazitti.com Added to query only yesterday's records*/
        // Calculate since date for new count queries. If today is
        // Monday, go back 3 days (to cover weekend), else 1 day.
        String dayOfWeek = DateTime.now().format('EEEE');
        DateTime sinceDate = DateTime.now().addDays(dayOfWeek == 'Monday' ? -3 : -1);
        
        String query = SELECT_CLAUSE + ' from Question ';
        if (postCategory != null && postCategory != 'All') {
            /* 08-04-11 vishals@grazitti.com Added to query only yesterday's records*/
            query += 'where CreatedDate >= ' + sinceDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' with data category Answers__c at ' + postCategory + '__c ';
            //query += 'with data category Answers__c at ' + postCategory + '__c '; 
        }
        query += 'order by CreatedDate desc limit ' + postCount;
        
        List<Question> newQuestions = (List<Question>) Database.query(query);
        
        List<Question> questions = newQuestions;
        if ('Popular' == postGroup) {
            List<String> newQuestionIds = new List<String>();
            for (Question question : newQuestions) {
                newQuestionIds.add(question.Id);
            }

            // Calculate since date for reply count query. If today is
            // Monday, go back 3 days (to cover weekend), else 1 day.
            //String dayOfWeek = DateTime.now().format('EEEE');
            //DateTime sinceDate = DateTime.now().addDays(dayOfWeek == 'Monday' ? -3 : -1);

            // Find replies posted since the since date.
            String replyQuery = 'select QuestionId from Reply ';
            replyQuery += 'where QuestionId not in (\'' + join(newQuestionIds, '\',\'') + '\') ';
            replyQuery += 'and CreatedDate >= ' + sinceDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            System.debug('====replyQuery=======>'+replyQuery);
            List<Reply> replies = Database.query(replyQuery);

            // Prepare list of popular Question ids based on those Questions having more than one reply.
            Map<String, Integer> questionReplyCounts = new Map<String, Integer>();
            Set<String> popularQuestionIds = new Set<String>();
            for (Reply reply : replies) {
                Integer count = questionReplyCounts.get(reply.QuestionId);
                if (count == null) {
                    questionReplyCounts.put(reply.QuestionId, 1);
                } else {
                    questionReplyCounts.put(reply.QuestionId, count + 1);

                    // Question is considered popular if it has 2 or more replies.                  
                    popularQuestionIds.add(reply.QuestionId);
                }
            }

            // If there are no popular Questions, exit early.
            if (popularQuestionIds.isEmpty()) {
                return new List<EmailPost>();
            }

            query = SELECT_CLAUSE + ' from Question ';
            query += 'where Id in (\'' + join(popularQuestionIds, '\',\'') + '\') ';
            if (postCategory != null && postCategory != 'All') {
                query += 'with data category Answers__c at ' + postCategory + '__c '; 
            }
            query += 'order by NumReplies desc, CreatedDate desc ';
            query += 'limit ' + postCount;

            questions = (List<Question>) Database.query(query);
        }
        
        Set<Id> userIds = new Set<Id>();
        for (Question question : questions) {
            userIds.add(question.CreatedById);
        }
        
        Map<Id, Community_Profile__c> userIdToProfileMap = GlobalFunctions.getProfilesForUsers(userIds);
        
        List<EmailPost> posts = new List<EmailPost>();
        for (Question question : questions) {
            Community_Profile__c profile = userIdToProfileMap.get(question.CreatedById);
            
            EmailPost post = new EmailPost();
            post.id = question.Id;
            post.title = question.Title;
            post.body = question.Body;
            post.posterId = question.CreatedById;
            post.posterName = getPosterName(profile, question.CreatedBy.FirstName, question.CreatedBy.LastName);
            post.createdDate = question.CreatedDate;
            
            posts.add(post);
        }
        
        return posts;
    }

    public String getPosterName(Community_Profile__c profile, String firstName, String lastName) {
        if (profile != null && profile.Display_Name__c != null && profile.Display_Name__c.trim().length() > 0) {
            return profile.Display_Name__c;
        } else {
            return firstName + ' ' + lastName.substring(0, 1);
        }
    }

    public static String join(List<String> values, String separator) {
        if (values == null || values.size() < 1) return null;
        
        String joined = '';

        Iterator<String> iterator = values.iterator();
        if (iterator.hasNext()) {
            joined += iterator.next();
            while (iterator.hasNext()) {
                joined += separator + iterator.next();
            }
        }

        return joined;
    }

    public static String join(Set<String> values, String separator) {
        List<String> valuesList;

        if (values != null) {
            valuesList = new List<String>();
            valuesList.addAll(values);
        }

        return join(valuesList, separator);
    }

    public class EmailPost {
        public Id id {get; set;}
        public String title {get; set;}
        public String body {get; set;}
        public Id posterId {get; set;}
        public String posterName {get; set;}
        public DateTime createdDate {get; set;}
        Public Date Publishdate{get; set;}
        Public String type{get;set;}
        public String getShortBody() {
            if(type!= null && (type == 'Alert' || type == 'News'))
                return GlobalFunctions.getShortBody(body, 350);
            else 
                return GlobalFunctions.getShortBody(body, 170);
        }
    }
    
    public static testMethod void testController() {
        /* 17-03-11 vishals@grazitti.com Added to increase code coverage */
        EmailPostController email = new EmailPostController();
        Idea idea1 = new Idea();
        idea1.Title = 'Test11';
        idea1.Body = 'Test1111';
        idea1.Categories = 'Administration';
        idea1.CommunityId = GlobalFunctions.communityId;
        insert idea1;
        
        IdeaComment comment = new IdeaComment();
        comment.IdeaId = idea1.Id;
        comment.CommentBody = 'Test11';
        insert comment;
        
        IdeaComment comment1 = new IdeaComment();
        comment1.IdeaId = idea1.Id;
        comment1.CommentBody = 'Test1';
        insert comment1;
        
        IdeaComment comment2 = new IdeaComment();
        comment2.IdeaId = idea1.Id;
        comment2.CommentBody = 'Test2';
        insert comment2;
        
        email.postCount = 1;
        email.postGroup = 'Popular';
        email.getQuestionPosts();
        email.getIdeaPosts();
        email.postType ='Idea';      
        email.getPosts();
        email.postType ='Question';
        email.getPosts();

        Community_Profile__c commu = new Community_Profile__c(Display_Name__c= 'testname');      
        email.getPosterName(commu,'hello', 'World');
        Marketo_News__c MarketoNews = new Marketo_News__c();
        MarketoNews.Type__c = 'News';
        MarketoNews.Description__c = 'Test News';
        MarketoNews.active__c = true;
        insert MarketoNews;
        email.postType ='News'; 
        email.getNewsPosts();
        Set<String> tempid = new Set<String>{'test'};
        EmailPostController.join(tempid ,'-');   
        
        MarketoNews = new Marketo_News__c();
        MarketoNews.Type__c = 'Alert';
        MarketoNews.Description__c = 'Test Alert';
        MarketoNews.active__c = true;
        insert MarketoNews;
        email.postType ='News'; 
        email.getPosts();
        tempid = new Set<String>{'test'};
        EmailPostController.join(tempid ,'-');   
        
      }            
}