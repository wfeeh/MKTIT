public class MarketoDiscussionDetailController extends MarketoBaseController {

    public Reply reply {get; set;}
    public Question question {get; set;}
    public List<MarketoPost> questionUi {get; set;}
    public Id bestReplyId {get; set;}
    public Id selectedReplyId {get; set;}
    public Boolean subscribe {get; set;}
    public List<ReplyWrapper> replies {get; set;}
    public Community_Subscription__c subscription {get; set;}
    public String CommunityId='';
    public String selectedCategory{get;set;}
   
    // Edit Question
    public Boolean editing {get; private set;}
    public String title {get; set;}
    public String body {get; set;}
    private QuestionDataCategorySelection questionDataCategorySelection;
    public String selectedDataCategory {get; set;}
    public List<SelectOption> questionCategoryOptions {get; private set;}
    public Boolean questionSubscribe {get; set;}
    public Community_Subscription__c questionSubscription {get; set;}


    // Edit Reply
    public Boolean editingReply {get; private set;}
    public Integer editReplyIndex {get; set;}
    public String replyBody {get; set;}


//steffi added 2 jan
    public static Id DiscussionId {get; set;}    
    public Id VoteReplyId {get; set{VoteReplyId = value;}}
    Public Integer maxVoteCount{get;set;}
    Public Id maxVoteCountReplyId{get;set;} 
    Public Integer ReplyCount{get;set;}
    public Map<ID,Integer> myMaxVoteList{get;set;}
    // end   
    
    //Refernce to 4658
     public Set<Id> myVoteToReplyIdsSet = new Set<Id>();
     public Map<Id, Integer> voteCountsPerReplyMap = new Map<Id, Integer>();

    //steffi updated 2 feb 2013... //This Submit method is used for sticky feature issue 3212
    Public Sticky_Post__c Sticky{get;set;}
    public boolean isSticky {get;set;}
    public boolean isStickyError{get;set;}
    Public String isStickcomment{get;set;}
    public String currStickyId{get;set;}
    Public ID JobID;
    Public String StickyMinutes;
    Public String StickyMonths;
    Public String StickyDay;
    Public String Hours; 
    Public String Year; 
    Public string second;
    Public Boolean pagerefresh{get;set;} 

    public Boolean getIsColorBookContestRunning() {
        if(Test.isRunningTest() == FALSE) {
            Datetime ColorContestStartDate = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').Start_Date__c;
            Datetime ColorContestEndDate   = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').End_Date__c;
            Boolean IsContestRunning = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').IsActive__c;
            Datetime currentDate = DateTime.Now();      
            if(IsContestRunning == True && currentDate >= ColorContestStartDate && currentDate <= ColorContestEndDate){
                return true;
            } else {
                return false;
            }            
        } else {
            return false;
        }        
    }
    
    public String getColorBookDiscussionId() {
        if(Test.isRunningTest() == FALSE) {
            return ColorBookContestSettings__c.getInstance('ColorBookContestDetails').DiscussionId__c;
        } else {
            return '';
        }          
    } 

    Public PageReference Submit(){
        Sticky = [Select Name,Comment__c,ID__c, Checked__c, Job_ID__c,type__c ,Date_Time__c, Available_For_Days__c   from Sticky_Post__c where Name = 'StickyPost' LIMIT 1 ];    
        GlobalFunctions.allStickyPost(question.ID, 'Discussion', isStickcomment);
        Sticky.Checked__c           = isSticky;       
        Sticky.Comment__c           = isStickcomment;
        Sticky.ID__c                = question.ID;
        Sticky.Date_Time__c         = DateTime.Now();                
        Sticky.Type__c              = 'Discussion';
        currStickyId                = question.ID; 
        DateTime stkyDT             = System.Now().AddDays(1);
       if(Sticky.Available_For_Days__c != null && Sticky.Available_For_Days__c >=1)        
            stkyDT             = System.Now().AddDays(Integer.valueof(Sticky.Available_For_Days__c));     
        
       StickyDay                   = stkyDT.format('dd');
        second                      = stkyDT.format('ss');
        StickyMinutes               = stkyDT.format('mm');
        StickyMonths                = stkyDT.format('MM');
        Hours                       = stkyDT.format('HH');
        Year                        =  stkyDT.format('yyyy');
        StickyfeatureSchedulable  schedulerObject = new StickyfeatureSchedulable();
        String schedulerRunTime = second+ ' '+StickyMinutes+ ' '+Hours+' ' +StickyDay+ ' ' +StickyMonths+ ' ? ' +Year;
        //String schedulerRunTime = 59+ ' '+StickyMinutes+ ' '+Hours+' ' +StickyDay+ ' ' +StickyMonths+ ' ? ' +Year;
        //system.debug('====Sticky.Job_ID__c ===='+Sticky.Job_ID__c);
        system.debug('===Comment length==='+Sticky.Comment__c.length());
        /*If(Sticky.Comment__c.length() > 500){
            String stckError = 'Sticky Comment length can\'t exceed 64 characters, Please shorten the content';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, stckError));
            
            isSticky = true;
            isStickyError = true;
            return (doDelete());
            //return null;
        }*/
       isStickyError = false; 
       if(Sticky.Job_ID__c <> null ){
            List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime  FROM CronTrigger where id =:Sticky.Job_ID__c Limit 1];
            if (ct.size() > 0) {
                         System.abortJob(ct[0].Id);
                         Sticky.Job_ID__c = null;
             }            
        }
        if(!Test.isRunningTest()) 
        { 
            JobID = system.schedule('StickyFeatureSchedular',schedulerRunTime ,schedulerObject );
            Sticky.Job_ID__c = JobID; 
            update Sticky;
        }
        return null;
    }
    
    Public PageReference doDelete(){
        Sticky = [Select Name,Comment__c,ID__c,Type__c, Job_ID__c,Checked__c from Sticky_Post__c where  Name = 'StickyPost' LIMIT 1 ];
        if(Sticky.type__c == 'Discussion'){     
            /*if(Sticky.Job_ID__c <> null){
                CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,    NextFireTime  FROM CronTrigger WHERE id = :Sticky.Job_ID__c limit 1];
                System.abortJob(ct.Id);
            }*/
            Sticky.Checked__c = false;       
            Sticky.Comment__c = null;
            Sticky.ID__c= null;
            Sticky.Date_Time__c = null; 
            //Sticky.Job_ID__c = null;
            Sticky.Type__c = null;
            update Sticky;                   
        }     
        return null;
    }
    //end
    
    public void init() {  
        pagerefresh = false; 
        question = GlobalFunctions.getQuestion(ApexPages.currentPage().getParameters().get('id'));
        Sticky = [Select Name,Comment__c,ID__c, Job_ID__c,Checked__c,type__c from Sticky_Post__c where Name = 'StickyPost' LIMIT 1 ];
        if(sticky.type__c == 'Discussion'){
            currStickyId = Sticky.ID__c;
            if(currStickyId  == question.ID){
                isSticky = Sticky.Checked__c;
                isStickcomment = Sticky.Comment__c ;    
            }
        }
        QuestionDataCategorySelection  DataCategorySelection = [Select q.DataCategoryName From QuestionDataCategorySelection q where q.parentid= :question.Id];        
        System.debug('-----DataCategorySelection ---->'+DataCategorySelection );
        System.debug('question----'+question.CreatedDate);
        selectedCategory = DataCategorySelection.DataCategoryName;
        
        if (selectedCategory == null || selectedCategory.trim().length() < 1) {
            selectedCategory = 'All Categories';
        }
        CommunityId = question.Id;
        List<Reply> questionReplies = GlobalFunctions.getRepliesForQuestion(question.Id);
        Set<Id> userIds = new Set<Id>();
        userIds.add(question.CreatedById);
        
         //Added for 4658   
         Set<Id> replyIdList = new Set<Id>();
        
        for (Reply reply : questionReplies) {
            voteCountsPerReplyMap.put(reply.Id,0); //added 4648
            replyIdList.add(reply.Id);//added for 4658   
            userIds.add(reply.CreatedById);
        }
        Map<Id, Community_Profile__c> userIdToProfileMap = GlobalFunctions.getProfilesForUsers(userIds);
        
        //Added for 4658 
            

        List<Vote> lstMyVoteToReplyIds = [Select Id, Type, ParentId, CreatedById From Vote Where Parent.Type = 'Reply' AND ParentId In :replyIdList and CreatedById = : Userinfo.getUserID() ];
        for(Vote myVotes : lstMyVoteToReplyIds )
        {
            myVoteToReplyIdsSet.add(myVotes.ParentId);
        }
        List<AggregateResult> voteCountsPerReply = [SELECT Count(Id) totCnt, ParentId from Vote  Where Parent.Type='Reply' and ParentId in :replyIdList group by ParentId];              

        for (AggregateResult results : voteCountsPerReply )
        {
            Id tmpId = ''+results.get('ParentId');
            String tmpCnt = '' + results.get('totCnt');
            voteCountsPerReplyMap.put(tmpId,Integer.valueof(tmpCnt));               
        }
        
               
        Community_Profile__c profile = userIdToProfileMap.get(question.CreatedById);
        Map<Id, Boolean> userIdToBVMap = GlobalFunctions.getPartner_Supported_Status_ForUsers(userIds);
        Map<Id, Boolean> userIdToCertificationMap = GlobalFunctions.getIsCertifiedUserMap(userIds); //certified user added
        questionUi = new List<MarketoPost>{new MarketoPost(question, profile,userIdToBVMap.get(question.CreatedById))};
               
        List<Community_Subscription__c> subscriptions = GlobalFunctions.getSubscription(UserInfo.getUserId(), question.Id);
        subscription = subscriptions.size() > 0 ? subscriptions[0] : null;
        subscribe = true;
            
        reply = new Reply();
        
        replies = new List<ReplyWrapper>();


        //steffi updated 2 jan 
        maxVoteCount = 0;
        maxVoteCountReplyId = null;
        //end
        
        for (Reply reply : questionReplies) {
            profile = userIdToProfileMap.get(reply.CreatedById);
            System.debug('profile--> '+profile );
            Boolean isCertified = FALSE;
            if(userIdToCertificationMap.containsKey(reply.CreatedById)) {
                isCertified = userIdToCertificationMap.get(reply.CreatedById);    
            }
            ReplyWrapper replyWrapp = new ReplyWrapper(reply, question.BestReplyId == reply.Id ? true : false, profile,isCertified,myVoteToReplyIdsSet.contains(reply.Id),voteCountsPerReplyMap.get(reply.id));
            replies.add(replyWrapp);
            // steffi updated 2 jan
            if(replyWrapp.myVoteCnt > maxVoteCount){
                maxVoteCount = replyWrapp.myVoteCnt;
                maxVoteCountReplyId  = reply.Id;
                system.debug('===maxVoteCountReplyId=='+maxVoteCountReplyId);
            } 
        }
      //steffi added line  94 on 2 jan
        ReplyCount = maxVoteCount; 
    }
    
    //Bikram update on 16 may this function to replace promoteidea()
    public PageReference promoteReply() {
        List<Vote> myVoter = [Select Id, ParentID,CreatedById  From Vote Where ParentID = : reply.id and CreatedById = : Userinfo.getUserID() Limit 1]; 
        if(myVoter.isEmpty()== true){
            Vote vote = new Vote();
            vote.ParentId = VoteReplyId;
            vote.Type = 'Up';
            insert vote;            
            if(Test.isRunningTest() == false) {          
                   BadgeVilleWebServiceCallouts.badgvilleLikedComment(VoteReplyId);                
                   BadgeVilleWebServiceCallouts.badgvilleReceivedLikedComment(VoteReplyId);         
            }         
        }       
        init();
        return null;
    }//end

    //steffi update on 2jan to be deprecated
    public PageReference promoteIdea() {
        List<Vote> myVoter = [Select Id, ParentID,CreatedById  From Vote Where ParentID = : reply.id and CreatedById = : Userinfo.getUserID() Limit 1]; 
        if(myVoter.isEmpty()== true){
            Vote vote = new Vote();
            vote.ParentId = VoteReplyId;
            vote.Type = 'Up';
            insert vote;
            if(Test.isRunningTest() == false) {          
                BadgeVilleWebServiceCallouts.badgvilleLikedComment(VoteReplyId);                
                BadgeVilleWebServiceCallouts.badgvilleReceivedLikedComment(VoteReplyId);         
            }
        }       
        init();
        return null;
    }//end

    
    
    public Boolean getIsEditable() {
        return (question.CreatedById == UserInfo.getUserId());
    }
    public boolean getDeleteQuestion(){
        datetime DateNow = DateTime.Now();
        datetime Date2 = question.CreatedDate ;
        integer secs = Integer.valueOf((DateNow.getTime() - Date2.getTime())/(1000));
        system.debug('===secs===>'+secs);
        return (question.CreatedById == UserInfo.getUserId() && secs < 900 );
    }
    public PageReference deleteQuestion() {
        Question ques = [select id from question where id = :question.id];
        delete ques;
        PageReference redirectPage = Page.MarketoDiscussionHome;
        redirectPage.getParameters().put('tabType', 'Recent');
        redirectPage.setRedirect(true);
        return redirectPage;
    }


    public PageReference saveBestReply() {
     
            List<Reply> questionReplies = [SELECT CreatedById from Reply Where questionid = :question.Id and Id =: bestReplyId];
            /* badgeville bikram23/4/2012 */  
            if(question.BestReplyId == NULL)
            {
            for(Reply replies :questionReplies ){
                if(replies.CreatedById != question.CreatedById){ 

                BadgeVilleWebServiceCallouts.badgvilleSelectAnswer();  

                BadgeVilleWebServiceCallouts.badgvilleReceiveBestAnswer(bestReplyId);

                System.debug('question----'+question.CreatedById);
                System.debug('reply----'+replies.CreatedById);
                //badgeville bikram 23/4/2012 
                }
            }
            }

            question.BestReplyId = bestReplyId;
            update question;
            
            init();
            return null;
    }
    //steffi updated 22 oct 2012
    public PageReference toggleSubscription() {
        try {
            // Delete existing subscription if there is one.
            List<Community_Subscription__c> subscriptions = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'Question' and Category__c = :selectedCategory and Idea_Question_Id__c =:question.Id and Idea_Question_Id__c != null];
            system.debug('====subscription =========='+subscriptions);
            if(subscriptions.isEmpty() == false) {
                delete subscriptions;            
            } else {
                Community_Subscription__c subscription = new Community_Subscription__c();
                subscription.User__c = UserInfo.getUserId();
                subscription.Type__c = 'Question';
                subscription.Category__c = selectedCategory ;
                subscription.Idea_Question_Id__c = question.Id;
                subscription.Category_Label__c = DataCategoryHelper.getHelper('Question').getLabel(selectedCategory);
                insert subscription;                
            }
        } catch (Exception e) {
            system.debug('===subscription==='+subscription);
        }
        return null;
    }
    /*
    public PageReference toggleSubscriptionLink() {
        try {
            // Delete existing subscription if there is one.
            Community_Subscription__c subscription = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'Question' and Category__c = :selectedCategory and Idea_Question_Id__c = :question.Id];
            delete subscription;
        } catch (Exception e) {
            // An exception is thrown if no subscription exists yet.
            // Setup subscription.
            Community_Subscription__c subscription = new Community_Subscription__c();
            subscription.User__c = UserInfo.getUserId();
            subscription.Type__c = 'Question';
            subscription.Category__c = selectedCategory;
            subscription.Category_Label__c = DataCategoryHelper.getHelper('Question').getLabel(selectedCategory);
             insert subscription;
        }
         pageReference pr= new pageReference('/apex/MarketoCommunityProfileEditSubscriptions');
            pr.setRedirect(true);
            return pr;
    }
    */
    public PageReference unsubscribe() {
        if (subscription != null) {
            delete subscription;
        }
        
        init();
        ApexPages.currentPage().getParameters().remove('unsubscribe');
    
        return null;
    }
    
    public PageReference edit() {
        // Enter edit mode.
        editing = true;

        // Load up everything for editing if this is the first time into edit mode.
        if (questionCategoryOptions == null) {
            title = question.Title;
            body = question.Body;
            
            questionDataCategorySelection = [select Id, DataCategoryName from QuestionDataCategorySelection where ParentId = :question.Id];
            selectedDataCategory = questionDataCategorySelection.DataCategoryName;
            
            questionCategoryOptions = new List<SelectOption>();

            for (DataCategory category : DataCategoryHelper.getHelper(new String[]{'Question'}).getCategories()) {
                questionCategoryOptions.add(new SelectOption(category.getName(), category.getLabel()));
            }
            
            try {
                questionSubscription = [select Id from Community_Subscription__c where Idea_Question_Id__c = :question.Id and User__c = :UserInfo.getUserId()];
            } catch (Exception e) {
                // Do nothing. An exception will be thrown if no record exisits.
            }
            
            questionSubscribe = (questionSubscription != null);
        }  

        return null;
    }
    
    public PageReference saveEdit() {

        List<String> missingFields = new List<String>();


        if (title == null || title.trim() == '') {
            missingFields.add('Title');
        }
        if (body == null || body.trim() == '') {
            missingFields.add('Description');
        }
        
        if (missingFields.size() > 0) {
            String message = 'Required fields are missing: ';
            for (Integer i = 0; i < missingFields.size(); i++) {
                message += missingFields[i] + (i < missingFields.size() - 1 ? ', ' : '');
            }
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;
        }

        
        // Update the Question if the Title or Body changed.
        if (questionUI.get(0).title != title || questionUI.get(0).body != body ) {
            // Create update.
            Community_Post_Update__c postUpdate = new Community_Post_Update__c();
            postUpdate.Post_Type__c = 'Question';
            postUpdate.Post_Id__c = question.Id;
            postUpdate.Title__c = title;
            /* 14-05-11 vishals@grazitti.com Added to preserve carriage return*/ 
            if(!getIsRichTextRequired())
                body = preserveCarriageReturn(body);
            postUpdate.Body__c = body ;
            insert postUpdate;
        
            // Asynchronously update the Question from the update object to get around portal permission limitations.
            GlobalFunctions.updatePost(postUpdate.Id);
        }
        
        // Remove existing Data Category and create new one if it was changed.
        // You can't update an existing record.
        if (selectedDataCategory != questionDataCategorySelection.DataCategoryName) {
            delete questionDataCategorySelection;
        
            questionDataCategorySelection = new QuestionDataCategorySelection();
            questionDataCategorySelection.ParentId = question.Id;
            questionDataCategorySelection.DataCategoryGroupName = 'Answers';
            questionDataCategorySelection.DataCategoryName = selectedDataCategory;
            insert questionDataCategorySelection;
        }
        

        // Add or remove subscription to Question if need be.
        if (questionSubscribe && questionSubscription == null) {
            questionSubscription = new Community_Subscription__c();
            questionSubscription.Idea_Question_Id__c = question.Id;
            questionSubscription.User__c = UserInfo.getUserId();
            questionSubscription.Type__c = 'Question';

            insert questionSubscription;
        } else if (!questionSubscribe && questionSubscription != null) {
            delete questionSubscription;
            questionSubscription = null;
        }
        
        // Update the data being displayed on the detail page.
        questionUI.get(0).title = title;
        questionUI.get(0).body = body ;
        
        // Exit edit mode.
        editing = false;

        return null;
    }
    
    public PageReference cancelEdit() {
        // Exit edit mode.
        editing = false;

        return null;
    }
    
    public PageReference editReply() {
        // Enter edit mode.
        editingReply = true;

        reply.Body= replies.get(editReplyIndex).reply.Body;

        return null;
    }

    //steffi updated    
    public Boolean getSubscribedToCurrentCategory() {
       return (Database.countQuery('select count() from Community_Subscription__c  where User__c = \'' + UserInfo.getUserId() + '\' and Type__c = \'Question\' and Category__c = \'' + String.escapeSingleQuotes(selectedCategory) + '\'') > 0);
    }//end
    
    //steffi updated    
    public Boolean getSubscribedToQuestion() {
        return (Database.countQuery('select count() from Community_Subscription__c  where User__c = \'' + UserInfo.getUserId() + '\' and Type__c = \'Question\' and Idea_Question_Id__c = \'' + String.escapeSingleQuotes(question.Id) + '\'') > 0);
    }//end
    


    
    public PageReference saveEditReply() {
        if (reply.Body== null || reply.Body.trim() == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Reply is missing'));
            return null;
        }

        // Update the Reply if it has changed.
        if (!replies.get(editReplyIndex).reply.Body.equals(reply.Body)) {
            // Create update.
            Community_Post_Update__c postUpdate = new Community_Post_Update__c();
            postUpdate.Post_Type__c = 'Reply';
            postUpdate.Post_Id__c = replies.get(editReplyIndex).reply.Id;
            /* 14-05-11 vishals@grazitti.com Added to preserve carriage return*/ 
            if(!getIsRichTextRequired())
                replyBody = preserveCarriageReturn(replyBody);
            postUpdate.Body__c = reply.Body;
            insert postUpdate;
        
            // Asynchronously update the Reply from the update object to get around portal permission limitations.
            GlobalFunctions.updatePost(postUpdate.Id);
        }

        // Update the data being displayed on the detail page.
        replies.get(editReplyIndex).reply.Body = reply.Body;
        // Exit edit mode.
        editingReply = false;
       reply.Body = null;
        return null;
        
    }
    
    public PageReference cancelEditReply() {
        // Exit edit mode.
        editingReply = false;

        editReplyIndex = null;
        reply.Body= null;

        return null;
    }
    
    public PageReference save() {         

        if(GetAlreadyRepliedForContest())  
        {
         // Redirect back to the page with a GET request so that
         // reloading the page doesn't duplicate the same post.
         PageReference redirectPage = Page.MarketoDiscussionDetail;
         redirectPage.getParameters().put('id', question.Id);
         redirectPage.setRedirect(true);
         return redirectPage;
        }
        if ((reply.Body == null || reply.Body == '') && (subscription != null && subscribe)) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required values are missing: Reply'));
            return null;
        } 
        else if (reply.Body != null && reply.Body != '') 
        {
            if (reply.Body.length() > 32000) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Value cannot exceed 32,000 characters'));
                return null;
            }
            Integer countReply = 0;
            for (Reply existingReply : [select Body from Reply where QuestionId = :question.Id and CreatedById = :UserInfo.getUserId()]) {
                if (reply.Body == existingReply.Body) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Reply already submitted'));
                    return null;

                }
                if(reply.CreatedById != question.CreatedById)    countReply++; //bikram badgeville 25/4/12
            }            

            /* badgeville bikramt@grazitti.com 25-04-2012 */
            if(userInfo.getUserId() != question.CreatedById) 
            {                                   
             BadgeVilleWebServiceCallouts.badgvilleAnswerQuestion();  
            }            
            System.debug('badgvilleAskQuestionStartsDiscussion ' + countReply);
             /* badgeville bikramt@grazitti.com 25-04-2012*/            
            if(countReply == 3) 
            {                         
                 BadgeVilleWebServiceCallouts.badgvilleAskQuestionStartsDiscussion(question.Id);  
            }                        
            /* 14-05-11 vishals@grazitti.com Added to preserve carriage return*/ 
            if(!getIsRichTextRequired())
                reply.Body = preserveCarriageReturn(reply.Body);
            reply.QuestionId = question.Id;
            insert reply;
        }        

        if (subscribe && subscription == null) {
            subscription = new Community_Subscription__c();
            subscription.Idea_Question_Id__c = question.Id;
            subscription.User__c = UserInfo.getUserId();
            subscription.Type__c = 'Question';

            insert subscription;
        } 
                
        init();
        
        // Redirect back to the page with a GET request so that
        // reloading the page doesn't duplicate the same post.
        PageReference redirectPage = Page.MarketoDiscussionDetail;
        redirectPage.getParameters().put('id', question.Id);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
     //Added by Nishtha Sood on 30-05-2013 for ticket 4482
     public Boolean GetAlreadyRepliedForContest() {
        boolean isAlreadyReplied = False;
        //question = GlobalFunctions.getQuestion(ApexPages.currentPage().getParameters().get('id'));
        String ColorContestDiscussionId = '90650000000PcqPAAS'; //dummy for test cases only
        Boolean IsContestRunning = FALSE;                
        DateTime    ColorContestStartDate = DateTime.Now(); //Dummy for test cases
        DateTime    ColorContestEndDate = DateTime.Now(); //Dummy for test cases.
        DateTime currentDate = Datetime.now(); 
        if(Test.isRunningTest() == FALSE)
        {
            IsContestRunning = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').IsActive__c;
            ColorContestDiscussionId = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').DiscussionId__c;
            ColorContestStartDate = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').Start_Date__c;
            ColorContestEndDate = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').End_Date__c;
        }
        If(IsContestRunning && ColorContestDiscussionId != null && ColorContestDiscussionId == question.id && currentDate >= ColorContestStartDate && currentDate <= ColorContestEndDate) {
             List<Reply> replyRecordForContest = [SELECT ID from Reply where CreatedById =: UserInfo.getUserId() and QuestionId =:ColorContestDiscussionId  LIMIT 1];
                if(replyRecordForContest.isEmpty() == false)  return true;                                
       }
       return false;
    }
    //END


    
    public class ReplyWrapper {
        public Reply reply {get; set;}
        public Community_Profile__c profile {get; set;}
        public Boolean isBestReply {get; set;}
        public String posterName {get; set;}
        public String createdDate {get; set;}
        public String badgeImage {get; set;}
        public String userBadgeValue{get;set;}
        public List<string> badgevalues{get; private set;} 
    
        public Boolean isCertifiedUser{get;set;}
        public String userBadgeValueSecondary{get;set;}

        // steffi added
        public List<Vote> votesOnReply {get;set;}
        public Integer myVoteCnt {get;set;}
        public Map<Id,Integer> myVotingMap{get; private set;}
        public Map<ID,Integer> myMaxVoteList{get;set;} 
        //end
        public ReplyWrapper(Reply reply, Boolean isBestReply, Community_Profile__c profile,Boolean isCertified,Boolean hasVoted,Integer voteCounts) {
            this.reply = reply;
            this.profile = profile;
            this.isCertifiedUser = isCertified;
            //steffi updated on 2 jan 
            myVotingMap = new Map<Id,Integer>();
            myMaxVoteList = new Map<ID,Integer>();
            myVotingMap.put(reply.id,0);  
            this.isBestReply = isBestReply;
            
            //replaced try catch with this 5 lines.
            myVoteCnt = voteCounts;
            if(reply.createdbyId == userinfo.getuserid() || hasVoted == true)
                myVotingMap.put(reply.Id,1);
            else
                myVotingMap.put(reply.id,0);  
              /*  
            try 
            {
                votesOnReply = [Select Id, IsDeleted, ParentId, Type, CreatedDate, CreatedById, SystemModstamp From Vote Where ParentID = : reply.id];                 
                if(votesOnReply.IsEmpty() == false) {
                    for(Vote vot :votesOnReply){
                        if(vot.CreatedById ==  UserInfo.getUserID() || reply.CreatedById == UserInfo.getUserID()){
                            myVotingMap.put(vot.ParentId,1); 
                            break;
                        }
                    }                                                  
                } else {
                    if(reply.CreatedBy.Id == UserInfo.getUserID()){
                        myVotingMap.put(reply.id,1);    
                    } else {
                        myVotingMap.put(reply.id,0);   
                    } 
                } 
                myVoteCnt = votesOnReply.size();   
            } catch(Exception ex) {
                myVoteCnt = 0;
            }// end    
            */
            /* Badge Image Setting */
            userBadgeValue = '';
            badgevalues = new List<string>();
            Map<String, Boolean> profile_badge_value  = new map<String, Boolean>();
            /*
            if (reply.CreatedBy.Champion__c) {
                userBadgeValue = 'CHAMPION' ;
            } else if (reply.CreatedBy.Is_Partner__c) {
                userBadgeValue = 'PARTNER' ;
            } else if (reply.CreatedBy.Is_Employee__c) {
                userBadgeValue = 'EMPLOYEE' ;
            } else if (reply.CreatedBy.Is_Consultant__c) {
                userBadgeValue = 'CONSULTANT' ;
            }
            */                       
            userBadgeValue  = ''; userBadgeValueSecondary ='';
            if (reply.CreatedBy.Is_Consultant__c) {
                userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                userBadgeValue = 'CONSULTANT' ;
            }
            if (reply.CreatedBy.Is_Employee__c) {
                userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                userBadgeValue = 'EMPLOYEE' ;
            } 
            if (reply.CreatedBy.Is_Partner__c) {
                userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                userBadgeValue = 'PARTNER' ;
            }            
            if (reply.CreatedBy.Champion__c) {
                userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                userBadgeValue = 'CHAMPION' ;                        
            }                  
            if(userBadgeValueSecondary.trim() != '')
            {
                userBadgeValueSecondary = userBadgeValueSecondary.capitalize() ; 
            }                  
            if (profile != null && profile.Display_Name__c != null && profile.Display_Name__c.trim().length() > 0) {
                this.posterName = profile.Display_Name__c;
            } else {
                this.posterName = reply.CreatedBy.FirstName + ' ' + reply.CreatedBy.LastName.substring(0, 1);
            }                
            this.createdDate = GlobalFunctions.formatDate(reply.CreatedDate);
        }   
        
        public Boolean getUserVoted() {
            return (reply.CreatedById == UserInfo.getUserId() || (reply.Votes != null && reply.Votes.size() > 0)) ? true : false;
        }
        
        public Boolean getIsEditable() {
            return (reply.CreatedById == UserInfo.getUserId());
        }
    }
    
    public static testMethod void testController() {
        Question question = new Question();
        question.Title = 'Test';
        question.Body = 'Test';
        question.CommunityId = '09a50000000PNNr';//GlobalFunctions.communityId;
        insert question;
        
        QuestionDataCategorySelection category = new QuestionDataCategorySelection();
        category.ParentId = question.Id;
        category.DataCategoryGroupName = 'Answers';
        category.DataCategoryName = DataCategoryHelper.getHelper(new String[]{'Question'}).getCategories()[0].getName();
        insert category;
        
        ApexPages.currentPage().getParameters().put('id', question.Id);
        
        MarketoDiscussionDetailController controller = new MarketoDiscussionDetailController();
        controller.init();
         /* 14-03-11 vishals@grazitti.com Added below method to increase code coverage */       
        controller.edit();
        controller.title = 'title1';
        controller.body = 'test1';
        controller.selectedDataCategory = 'Marketing_Activities';
        controller.questionSubscribe = true;
        controller.questionSubscription = null;
        controller.saveEdit();
        controller.cancelEdit();
        
        Reply reply = new Reply();
        reply.Body = 'Test';
        controller.reply = reply;
        controller.save();
        
        controller.editReplyIndex = 0;
        controller.editReply();
        controller.replyBody = 'test test';
        controller.saveEditReply();
        controller.cancelEditReply();
        
        controller.bestReplyId = reply.Id;
        controller.saveBestReply();
        
        controller.selectedReplyId = reply.Id;
        controller.unsubscribe();
        
        Reply reply1 = new Reply();
        reply1.Body = '';
        controller.reply = reply1;
        controller.save();
               
        List<Reply> replies = [SELECT Id from Reply Where CreatedById != :UserInfo.getUserId() limit 10];
        if(replies.size() > 0) {
         controller.voteReplyId = replies[0].Id;
         controller.promoteReply(); 
         if(replies.size() > 2) {
          controller.voteReplyId = replies[1].Id;
          controller.promoteIdea(); } 
        }


        /*User u = [select Id from User where IsActive = true and id != :UserInfo.getUserId() and ProfileId = :[select Id from Profile where Name = 'System Administrator'].Id limit 1];
        System.runAs(u) {
            controller.voteReplyId = reply.Id;
            controller.promoteReply();
        }*/
    }
    
     /* 14-03-11 vishals@grazitti.com Added below method to increase code coverage */
    public static testMethod void testController1() {
        Question question = new Question();
        question.Title = 'Test';
        question.Body = 'Test';
        question.CommunityId ='09a50000000PNNr';// GlobalFunctions.communityId;
        insert question;
        
        QuestionDataCategorySelection category = new QuestionDataCategorySelection();
        category.ParentId = question.Id;
        category.DataCategoryGroupName = 'Answers';
        category.DataCategoryName = DataCategoryHelper.getHelper(new String[]{'Question'}).getCategories()[0].getName();
        insert category;
        
        ApexPages.currentPage().getParameters().put('id', question.Id);
        
        MarketoDiscussionDetailController controller = new MarketoDiscussionDetailController();
        controller.init();
        
        controller.edit();
        controller.title = null;
        controller.body = null;
        controller.saveEdit();
        controller.isStickcomment = 'test';
        controller.submit();
        controller.doDelete();

        controller.cancelEdit();
        controller.getIsEditable();
        controller.toggleSubscription();
        //controller.toggleSubscriptionLink();
        controller.getSubscribedToCurrentCategory();
        controller.getSubscribedToQuestion();
        controller.getIsEditable();
    }
    
}