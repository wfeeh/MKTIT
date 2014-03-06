public class MarketoIdeaDetailController extends MarketoBaseController {

    public Idea idea {get; set;}
    public Idea parentId {get; set;}
    public List<MarketoPost> ideaUi {get; set;}
    public Boolean subscribe {get; set;}
    public IdeaComment newIdeaComment {get; set;}
    public String ideaCategories {get; private set;}
    public Community_Subscription__c subscription {get; set;}
    public List<IdeaCommentWrapper> ideaCommentListWrapper {get; private set;}
    public List<Idea> childIdeas{get;set;}
    // Edit Idea
    public Boolean editing {get; private set;}
    public String title {get; set;}
    public String body {get; set;}
    public Boolean ideaSubscribe {get; set;}
    public Community_Subscription__c ideaSubscription {get; set;}
    public DateTime createddate {get; private set;}  
    public String createDate {get; private set;}
    public String selectedCategory{get;set;}    
    // Edit Comment
    public Boolean editingComment {get; private set;}
    public Integer editCommentIndex {get; set;}
    public String commentBody {get; set;}
    public Integer childListSize{get;set;}
    public Boolean mergedIdea{get;set;}
    
    //steffi added 20 mar
    public static Id Idea_Id {get; set;}    
    public Id VoteCommentId {get; set{VoteCommentId = value;}}
    Public Integer maxVoteCount{get;set;}
    Public Id maxVoteCountCommentId{get;set;} 
    Public Integer CommentCount{get;set;}    
    public Map<ID,Integer> myMaxVoteList{get;set;}
    // end   

    //Added by Nishtha on 16th Apr 2013  
    Public String stickyIdeaCommentId{get;set {stickyIdeaCommentId = value;}}
    Public List<IdeaCommentStatusUpdate__c>stickyIdeaCommentIdList{get;set;}
    Public Boolean isStickyCommentMarked{get;set;}
    Public IdeaComment stickyComment{get;set;}
    Public Community_Profile__c stickyCommentProfile{get;set;}
    public String stickyCommentPostDate{get; set;}
    Public String stickyPosterName{get; set;}
    Public List<StickyCommentUserIds__c> StickyCommentUserIdsList{get;set;}
    Public Boolean isStickyCommentUser{get;set;}       
    Public IdeaCommentStatusUpdate__c StickyonComment{get;set;}
    public boolean isStickyonComment {get;set;}
             
    public Idea NextIdforIdea {get;set;} 
    public Idea PrevIdforIdea {get;set;}    
    
    //Added for eric idea detail bug               
    public Set<Id> myVoteToCommentIdsSet = new Set<Id>();
    public Map<Id, Integer> voteCountsPerCommentMap = new Map<Id, Integer>();
 
    public Idea getNextIdea(String Ideaid)
    {
       try {
           return [SELECT Id from Idea where CreatedDate <: Idea.CreatedDate Order By CreatedDate DESC Limit 1];                  
       }
       catch (Exception ex){}
       return null;
    }
    public Idea getPrevIdea(String Ideaid)
    {
        try{    
          return [SELECT Id from Idea where CreatedDate >: Idea.CreatedDate Order By CreatedDate ASC Limit 1];       
                     
       } catch (Exception ex){}
       return null;
    }
    //steffi updated 4 feb----
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
    Public PageReference Submit(){
        Sticky = [Select Name,Comment__c,ID__c, Checked__c, Job_ID__c,type__c ,Date_Time__c  from Sticky_Post__c where Name = 'StickyPost' LIMIT 1 ];    
        GlobalFunctions.allStickyPost(Idea.ID, 'Idea', isStickcomment);
        Sticky.Checked__c           = isSticky;       
        Sticky.Comment__c           = isStickcomment;
        Sticky.ID__c                = Idea.ID;
        Sticky.Date_Time__c         = DateTime.Now();                
        Sticky.Type__c              = 'Idea';
        currStickyId                = Idea.ID; 
        DateTime stkyDT             = System.Now().AddDays(1);
        StickyDay                   = stkyDT.format('dd');       
        second                      = stkyDT.format('ss');
        StickyMinutes               = stkyDT.format('mm');
        StickyMonths                = stkyDT.format('MM');
        Hours                       = stkyDT.format('HH');
        Year                        = stkyDT.format('yyyy');
        StickyfeatureSchedulable  schedulableObject = new StickyfeatureSchedulable();
        String schedulerRunTime = second+ ' ' +StickyMinutes + ' '+Hours+' ' +StickyDay+ ' ' +StickyMonths+ ' ? ' +Year;
        system.debug('====Sticky.Job_ID__c ===='+Sticky.Job_ID__c);
        /*If(Sticky.Comment__c.length() > 64){
            String stckError = 'Sticky Comment length can\'t exceed 64 characters, Please shorten the content';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, stckError));
            Sticky = [Select Name,Comment__c,ID__c,Type__c, Job_ID__c,Checked__c from Sticky_Post__c where  Name = 'StickyPost' LIMIT 1 ];
            isSticky = true;
            isStickyError = true;
            return (doDelete());
            //return null;
        } */
        isStickyError = false;
        if(Sticky.Job_ID__c <> null ){
            List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered,    NextFireTime  FROM CronTrigger where id =:Sticky.Job_ID__c Limit 1];
            if (ct.size() > 0) {
                         System.abortJob(ct[0].Id);
                         Sticky.Job_ID__c = null;
             } 
        }
        if(!Test.IsRunningTest()) {
            JobID = system.schedule('StickyFeatureSchedular',schedulerRunTime ,schedulableObject );
        }
        Sticky.Job_ID__c = JobID;   
        update Sticky;        
        return null;
    }
    
    Public PageReference doDelete(){
        Sticky = [Select Name,Comment__c,ID__c,Type__c, Job_ID__c,Checked__c from Sticky_Post__c where  Name = 'StickyPost' LIMIT 1 ];
        if(Sticky.type__c == 'Idea'){     
            /*if(Sticky.Job_ID__c <> null){
               CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,    NextFireTime  FROM CronTrigger WHERE id = :Sticky.Job_ID__c limit 1];
               System.abortJob(ct.Id);
            }*/
            Sticky.Checked__c     = false;       
            Sticky.Comment__c     = null;
            Sticky.ID__c          = null;
            Sticky.Date_Time__c   = null; 
            //Sticky.Job_ID__c      = null;
            Sticky.Type__c        = null;
            update Sticky;                   
        }     
        return null;
    }
    
    
    //end
    
    Public PageReference saveStickyonComment(){
        PageReference pageRef = null;
        try {
                //deleteStickyOnComment();
                List<IdeaCommentStatusUpdate__c> IdeaCommentStatusUpdateList = [Select id From IdeaCommentStatusUpdate__c where Masterid__c = :idea.id];      
                if(IdeaCommentStatusUpdateList.size() > 0) {
                    For(IdeaCommentStatusUpdate__c IdeaCommentStatusUpdate : IdeaCommentStatusUpdateList){
                        IdeaCommentStatusUpdate.IsChecked__c = False;
                        Update IdeaCommentStatusUpdate;
                        isStickyCommentMarked = false;
                    }
                }
                stickyIdeaCommentId = ApexPages.currentPage().getParameters().get('firstParam');            
                StickyonComment =  new  IdeaCommentStatusUpdate__c(); 
                isStickyonComment = true;
                isStickyCommentMarked = true;
                StickyonComment.IsChecked__c = True;
                StickyonComment.MasterId__c = Idea.id;
                StickyonComment.ParentId__c = stickyIdeaCommentId ;
                insert StickyonComment ; 
                isStickyCommentMarked = True;
                //Init();
            }
            catch(Exception e) {
                ApexPages.addMessages(e);
            }  
            PageReference curPage = Page.MarketoIdeaDetail;
            curPage.getParameters().put('id',idea.Id);
            curPage.setRedirect(true);
            return curPage;
      }
    
      Public PageReference deleteStickyOnComment(){
        List<IdeaCommentStatusUpdate__c> IdeaCommentStatusUpdate = [Select id From IdeaCommentStatusUpdate__c where Masterid__c = :idea.id];
        try {
                if(IdeaCommentStatusUpdate.size() > 0) {
                    delete IdeaCommentStatusUpdate;
                    isStickyCommentMarked = false;
                }
            } 
        catch(Exception e) {
        ApexPages.addMessages(e);
        }
        PageReference curPage = ApexPages.currentPage();
        curPage.setRedirect(true);
        return curPage;          
    }

    Public PageReference GetStickyCommentUserIds(){
        try {
                string StickyCommentUserIds = StickyCommentUserIds__c.getInstance('StickyCommentUserIds').UserId__c;
                isStickyCommentUser = false;
                If(StickyCommentUserIds != Null){
                    isStickyCommentUser = StickyCommentUserIds.contains(userInfo.getuserid());
                }
         }
         catch(Exception e) {
            ApexPages.addMessages(e);
        }  
       return null;
    }

    
    public void init() {
        childIdeas= new List<Idea>();
        idea = GlobalFunctions.getIdea(ApexPages.currentPage().getParameters().get('id'));
        
        //Bikram fix for idea subscription
        selectedCategory = idea.Categories;        
        if (selectedCategory == null || selectedCategory.trim().length() < 1) {
            selectedCategory = 'All Categories';
        }        
                
        //steffi updated 4 feb issue 3212...
        Sticky = [Select Name,Comment__c,ID__c, Job_ID__c,Checked__c,type__c from Sticky_Post__c where Name = 'StickyPost' LIMIT 1 ];
        if(sticky.type__c == 'Idea'){
            currStickyId = Sticky.ID__c;
            if(currStickyId  == Idea.ID){
                isSticky = Sticky.Checked__c;
                isStickcomment = Sticky.Comment__c ;    
            }
        }
        //end

        childIdeas= [Select i.Status, i.ParentIdeaId, i.Categories, i.NumComments,i.CreatedDate, i.IsLocked, i.Id, i.CreatedBy.Name, i.CreatedBy.Id, i.Body, i.title From Idea i where i.ParentIdeaId =:idea.Id ];
        System.debug('childIdeas----> '+childIdeas);
        childListSize = childIdeas.size();
        If(childIdeas.size() > 0){
            mergedIdea = true;
        }
        else{
        mergedIdea = false;
        }
        createddate = (DateTime)Idea.get('CreatedDate');
        createDate = GlobalFunctions.formatDate(createddate);   
        List<IdeaComment> comments = GlobalFunctions.getCommentsForIdea(idea.Id);
        Set<Id> userIds = new Set<Id>();               
        userIds.add(idea.CreatedById);


        //Added for query optimization eric holle bone idea vote bug        
        Set<Id> commentIdList = new Set<Id>();
      
        for (IdeaComment comment : comments) {
            voteCountsPerCommentMap.put(comment.Id,0);
            commentIdList.add(comment.Id);//added for eric                
            userIds.add(comment.CreatedById);
        }        
        Map<Id, Community_Profile__c> userIdToProfileMap = GlobalFunctions.getProfilesForUsers(userIds);
        Map<Id, Boolean> userIdToBVMap = GlobalFunctions.getPartner_Supported_Status_ForUsers(userIds);
        
        //Added for query optimization eric holle bone idea vote bug        
        List<Vote_IdeaComment__c> lstMyVoteToCommentIds = [Select Id, Parent_Id__c, CreatedDate, CreatedById From Vote_IdeaComment__c Where Parent_Id__c in : commentIdList and CreatedById = : Userinfo.getUserID()];
        //Set<Id> setMyVoteToCommentIds = new Set<Id>();
        for(Vote_IdeaComment__c myVotes : lstMyVoteToCommentIds )
        {
            myVoteToCommentIdsSet.add(myVotes.Parent_Id__c);
        }
        List<AggregateResult> voteCountsPerComment = [SELECT Count(Id) totCnt, Parent_Id__c from Vote_IdeaComment__c Where Parent_Id__c in :commentIdList group by Parent_Id__c];              
        for (AggregateResult results : voteCountsPerComment)
        {
            Id tmpId = ''+results.get('Parent_Id__c');
            String tmpCnt = '' + results.get('totCnt');
            voteCountsPerCommentMap.put(tmpId,Integer.valueof(tmpCnt));     
            System.debug('tmpId,tmpCnt=>' + tmpId + '=' + tmpCnt);          
        }
        
        
        
        //Added for certification banner
        Map<Id, Boolean> userIdToCertificationMap = GlobalFunctions.getIsCertifiedUserMap(userIds);


        Community_Profile__c profile = userIdToProfileMap.get(idea.CreatedById);
        ideaUi = new List<MarketoPost>{new MarketoPost(idea, profile,userIdToBVMap.get(idea.CreatedById))};
           
        List<Community_Subscription__c> sub = GlobalFunctions.getSubscription(UserInfo.getUserId(), idea.Id);
        subscription = sub.size() > 0 ? sub[0] : null;
        System.debug('subscription-->'+subscription );
        subscribe = true;
       
        //Added by Nishtha Sood on 8th march 2013
        stickyIdeaCommentIdList = [Select id,IsChecked__c ,ParentId__c,masterid__c from IdeaCommentStatusUpdate__c where MasterId__c =: idea.Id and IsChecked__c = true ];  
        System.debug('*************************' + stickyIdeaCommentIdList);

        newIdeaComment = new IdeaComment();
     
        ideaCommentListWrapper = new List<IdeaCommentWrapper>();
        
        //steffi updated 20 mar 
        maxVoteCount = 0;
        maxVoteCountCommentId = null;
        //end        

        //Added by Nishtha Sood on 09-04-13
        stickyIdeaCommentId  = null;
        stickyComment = new IdeaComment(); 
        stickyCommentProfile = new Community_Profile__c();
          
        if(stickyIdeaCommentIdList.size() > 0){
            isStickyCommentMarked = True;
            stickyIdeaCommentId = stickyIdeaCommentIdList[0].ParentId__c;
        }
        else{
            isStickyCommentMarked = False;
        }
        string StickyCommentUserIds = StickyCommentUserIds__c.getInstance('StickyCommentUserIds').UserId__c;
        isStickyCommentUser = false;
        If(StickyCommentUserIds != Null){
            isStickyCommentUser = StickyCommentUserIds.contains(userInfo.getuserid());
        }
        //END 
        
        System.debug('myVoteToCommentIdsSet=>' + myVoteToCommentIdsSet);
        System.debug('voteCountsPerCommentMap=>' + voteCountsPerCommentMap);
        
        for (IdeaComment comment : comments) {
            profile = userIdToProfileMap.get(comment.CreatedById);
            //added by bikram 20 mar
            //ideaCommentListWrapper.add(new IdeaCommentWrapper(comment, profile));
            
            Boolean isCertified = FALSE;
            if(userIdToCertificationMap.containsKey(comment.CreatedById)) {
                isCertified = userIdToCertificationMap.get(comment.CreatedById);    
            }
            
            
            
            IdeaCommentWrapper commentWrapp = new IdeaCommentWrapper(comment, profile,stickyIdeaCommentIdList,isCertified,myVoteToCommentIdsSet.contains(comment.Id),voteCountsPerCommentMap.get(comment.id));
            ideaCommentListWrapper.add(commentWrapp);
            // steffi updated 20 mar
            if(commentWrapp.myVoteCnt > maxVoteCount){
                maxVoteCount = commentWrapp.myVoteCnt;
                maxVoteCountCommentId  = comment.Id;
                system.debug('===maxVoteCountReplyId=='+maxVoteCountCommentId);
            }      
            
            //Added by Nishtha Sood on 09-04-2013  
            if(stickyIdeaCommentId != null){
                if (stickyIdeaCommentId ==  commentWrapp.comment.id){
                    stickyComment = comment;

                    stickyCommentProfile = profile;
                    stickyPosterName = commentWrapp.posterName;
                    stickyCommentPostDate = stickyComment.CreatedDate.format();
                }
            } 
      
        }
        //getProfileImageName();
        //steffi added line  20 mar
        CommentCount = maxVoteCount; 
    }
    
    public Boolean getIsEditable() {
        return (idea.CreatedById == UserInfo.getUserId());
    }
    
    public boolean getIdeaQuestion(){
        datetime DateNow = DateTime.Now();
        datetime Date2 = idea.CreatedDate ;
        integer secs = Integer.valueOf((DateNow.getTime() - Date2.getTime())/(1000));
        system.debug('===secs===>'+secs);
        return (idea.CreatedById == UserInfo.getUserId() && secs < 900 );
    }
    
    public PageReference deleteIdea() {
        idea ide = [select id from idea where id = :idea.id];
        delete ide;
        PageReference redirectPage = Page.MarketoIdeasHome;
        redirectPage.getParameters().put('tabType', 'Recent');
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
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
        if (ideaSubscription == null) {
            title = idea.Title;
            body = idea.Body;
            try {
                ideaSubscription = [select Id from Community_Subscription__c where Idea_Question_Id__c = :idea.Id and User__c = :UserInfo.getUserId()];
                System.debug('ideaSubscription---> '+ideaSubscription );
            } catch (Exception e) {
                // Do nothing. An exception will be thrown if no record exisits.
            }
            
            ideaSubscribe = (ideaSubscription != null);
            System.debug('ideaSubscribe ---> '+ideaSubscribe );
        }

        return null;
    }
    
    public PageReference saveEdit() {
        List<String> missingFields = new List<String>();

        if (title == null || title.trim() == '') {
            missingFields.add('Title');
        }
        if (idea.Body== null || idea.Body.trim() == '') {
            missingFields.add('Description');
        }
        if (idea.Categories == null) {
            missingFields.add('Categories');
        }
        
        if (missingFields.size() > 0) {
            String message = 'Required fields are missing: ';
            for (Integer i = 0; i < missingFields.size(); i++) {
                message += missingFields[i] + (i < missingFields.size() - 1 ? ', ' : '');
            }
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            return null;
        }

        // Update the Idea if the Title or Body changed.
      if (ideaUI.get(0).title != title || ideaUI.get(0).body != body) {
            // Create update.
            Community_Post_Update__c postUpdate = new Community_Post_Update__c();
            postUpdate.Post_Type__c = 'Idea';
            postUpdate.Post_Id__c = idea.Id;
            postUpdate.Title__c = title;
            /* 14-05-11 vishals@grazitti.com Added to preserve carriage return*/ 
            if(!getIsRichTextRequired())
                idea.Body= preserveCarriageReturn(body);
            postUpdate.Body__c = body;
            insert postUpdate;
        
            // Asynchronously update the Idea from the update object to get around portal permission limitations.
            GlobalFunctions.updatePost(postUpdate.Id);
        }
        
        // Add or remove subscription to Idea if need be.
        if (ideaSubscribe && ideaSubscription == null) {
            ideaSubscription = new Community_Subscription__c();
            ideaSubscription.Idea_Question_Id__c = idea.Id;
            ideaSubscription.User__c = UserInfo.getUserId();
            ideaSubscription.Type__c = 'Idea';
            insert ideaSubscription;
        } else if (!ideaSubscribe && ideaSubscription != null) {
            delete ideaSubscription;
            ideaSubscription = null;
        }
        
        // Update the data being displayed on the detail page.
        ideaUI.get(0).title = title;
        ideaUI.get(0).body = body;

        // Exit edit mode.
        editing = false;

        return null;
    }
    
    public PageReference cancelEdit() {
        // Exit edit mode.
        editing = false;

        return null;
    }
    
    public PageReference editComment() {
        // Enter edit mode.
        editingComment = true;

        newIdeaComment.commentbody = ideaCommentListWrapper.get(editCommentIndex).comment.commentbody;

        return null;
    }
    
    public PageReference saveEditComment() {
        if (newIdeaComment.commentbody== null || newIdeaComment.commentbody.trim() == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Comment is missing'));
            return null;
        }
        //System.debug('=====LENGTH=========>'+commentBody.length());
        //System.debug('=====LENGTH=========>'+commentBody);
        // Update the Comment if it has changed.
        if (!ideaCommentListWrapper.get(editCommentIndex).comment.CommentBody.equals(newIdeaComment.commentbody)) {
            // Create update.
            Community_Post_Update__c postUpdate = new Community_Post_Update__c();
            postUpdate.Post_Type__c = 'Comment';
            postUpdate.Post_Id__c = ideaCommentListWrapper.get(editCommentIndex).comment.Id;
            /* 14-05-11 vishals@grazitti.com Added to preserve carriage return*/ 
            if(!getIsRichTextRequired())
                commentBody = preserveCarriageReturn(newIdeaComment.commentbody);
            postUpdate.Body__c = newIdeaComment.commentbody;
            insert postUpdate;
        
            // Asynchronously update the Comment from the update object to get around portal permission limitations.
            GlobalFunctions.updatePost(postUpdate.Id);
        }

        // Update the data being displayed on the detail page.
        ideaCommentListWrapper.get(editCommentIndex).comment.CommentBody = newIdeaComment.commentbody;

        // Exit edit mode.
        editingComment = false;

        return null;
    }
    
    public PageReference cancelEditComment() {
        // Exit edit mode.
        editingComment = false;

        editCommentIndex = null;
        newIdeaComment.commentbody= null;

        return null;
    }
    
    public PageReference save() {
        if(userInfo.getUserId() != idea.CreatedById) 
        {
            //Give BVille points                         
            BadgeVilleWebServiceCallouts.badgvilleCommentIdea();//idea comment badge
        }
        if ((newIdeaComment.commentbody == null || newIdeaComment.commentbody == '') && (subscription != null && subscribe)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required values are missing: Comment'));
            return null;
        } else if (newIdeaComment.commentbody != null && newIdeaComment.commentbody != '') {
            if (newIdeaComment.commentbody.length() > 4000) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Value cannot exceed 3,000 characters'));
                return null;
            }
        
      /*  if (new List<IdeaComment>([select id from IdeaComment where ideaid = :idea.id and commentbody = :newIdeaComment.commentbody and createdbyid = :UserInfo.getUserId()]).size() > 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Comment already submitted'));
                return null;
        }*/
            
            /* 14-05-11 vishals@grazitti.com Added to preserve carriage return*/ 
            if(!getIsRichTextRequired())
                newIdeaComment.commentbody = preserveCarriageReturn(newIdeaComment.commentbody);

            newIdeaComment.ideaId = idea.id;
            insert newIdeaComment;
        }
        
        if (subscribe && subscription == null) {
            Community_Subscription__c s = new Community_Subscription__c();
            s.idea_question_id__c = idea.id;
            s.user__c = UserInfo.getUserId();
            s.type__c = 'Idea';
            insert s;
        }         
        init();        
        // return null;
        // Redirect back to the page with a GET request so that
        // reloading the page doesn't duplicate the same post.
        PageReference redirectPage = Page.MarketoIdeaDetail;
        redirectPage.getParameters().put('id', Idea.Id);
        redirectPage.setRedirect(true);
        return redirectPage;
    }    
    
    // steffi added on 20 mar
    public Id votedCommentId {get; set{ votedCommentId = value;}}

    public PageReference promoteComment() {
        Vote_IdeaComment__c vote = new Vote_IdeaComment__c();
        vote.Parent_Id__c = votedCommentId;
        vote.External_Id__c = votedCommentId + ',' + UserInfo.getUserID();
        upsert vote;
        BadgeVilleWebServiceCallouts.badgvilleReceivedLikedIdeaComment(votedCommentId);
        BadgeVilleWebServiceCallouts.badgvilleLikedIdeaComment(votedCommentId);   
        init();
        return null;
    }    
    //end
        
    //Bikram added subscription bug fix    
    public Boolean getSubscribedToIdea() {        
        return ([Select count() From Community_Subscription__c Where User__c = :UserInfo.getUserId() and Type__c = 'Idea' and Idea_Question_Id__c = :idea.Id]> 0 );        
    }//end
    
    //Bikram updated 30 may 2013
    public PageReference toggleSubscription() {    
        try {
            // Delete existing subscription if there is one.
            List<Community_Subscription__c> subscriptions = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'Idea' and Idea_Question_Id__c =:Idea.Id and Idea_Question_Id__c != null];
            system.debug('====subscription =========='+subscriptions);
            if(subscriptions.isEmpty() == false) {
                delete subscriptions;            
            } else {
                Community_Subscription__c subscription = new Community_Subscription__c();
                subscription.User__c = UserInfo.getUserId();
                subscription.Type__c = 'Idea';
                subscription.Category__c = selectedCategory ;
                subscription.Idea_Question_Id__c = idea.Id;
                subscription.Category_Label__c = selectedCategory;
                insert subscription;                
            }
        } catch (Exception e) {
            system.debug('===subscription==='+subscription);
        }
        return null;
    }    
    
    public class IdeaCommentWrapper { 
        public IdeaComment comment {get; set;}
        public Community_Profile__c profile {get; set;}
        public String posterName {get; set;}
        public String postDate {get; set;}
        public String badgeImage {get; set;}        
        public String userBadgeValue{get;set;}
        public List<string> badgevalues{get; private set;} 
        
        // steffi added on 20 mar
        public Boolean isBestComment {get; set;}
        //public List<Vote_IdeaComment__c> votesOnComment{get;set;}
        public Integer myVoteCnt {get;set;}
        public Map<Id,Integer> myVotingMap{get; private set;}
        public Map<ID,Integer> myMaxVoteList{get;set;} 
        //end                        
    
        Public List<IdeaCommentStatusUpdate__c >stickyIdeaCommentIdList{get;set;}       
        Public boolean isStickyComment{get;set;}
        Public string stickyCommentId{get;set;}
        Public Boolean isCertifiedUser{get;set;}
        Public String userBadgeValueSecondary{get;set;}
        
        public IdeaCommentWrapper(IdeaComment comment, Community_Profile__c profile,List<IdeaCommentStatusUpdate__c> stickyIdeaCommentIdList, Boolean isCertified, Boolean hasVoted,Integer voteCounts) 
        {
                        
            this.isCertifiedUser = isCertified;
            this.comment = comment;
            this.profile = profile;                        
            this.stickyIdeaCommentIdList = stickyIdeaCommentIdList;                        
            //steffi updated on 20 mar 
            myVotingMap = new Map<Id,Integer>();
            myMaxVoteList = new Map<ID,Integer>();
            this.isBestComment = isBestComment;              
            
            //replaced try catch with this 5 lines.
            myVoteCnt = voteCounts;
            if(comment.createdbyId == userinfo.getuserid() || hasVoted == true)
                myVotingMap.put(comment.Id,1);
            else
                myVotingMap.put(comment.id,0);  
            
             
            /* 
            try {
                myVoteCnt = 0;
                votesOnComment =  [Select Id, Parent_Id__c, CreatedDate, CreatedById From Vote_IdeaComment__c Where Parent_Id__c = : comment.id];                 
                if(votesOnComment.IsEmpty() == false){
                    for(Vote_IdeaComment__c vote : votesOnComment){
                        if(vote.CreatedById ==  UserInfo.getUserID() || comment.CreatedById == UserInfo.getUserID()){
                            myVotingMap.put(vote.Parent_Id__c,1); 
                            break;
                        }
                    }                                                
                } else {
                    if(comment.CreatedBy.Id == UserInfo.getUserID()){
                        myVotingMap.put(comment.id,1);    
                    } else {
                        myVotingMap.put(comment.id,0);   
                    } 
                } 
                myVoteCnt = voteCounts;//votesOnComment.size();   
            } catch(Exception ex) {
                myVoteCnt = 0;
            }// end
            */
            
            

            /* Badge Image Setting */
            userBadgeValue = '';            
            badgevalues = new List<string>();
            Map<String, Boolean> profile_badge_value  = new map<String, Boolean>();
            /*if (comment.CreatedBy.Champion__c) {
                userBadgeValue = 'CHAMPION' ;
            } else if (comment.CreatedBy.Is_Partner__c) {
                userBadgeValue = 'PARTNER' ;
            } else if (comment.CreatedBy.Is_Employee__c) {
                userBadgeValue = 'EMPLOYEE' ;
            } else if (comment.CreatedBy.Is_Consultant__c) {
                userBadgeValue = 'CONSULTANT' ;
            }*/
            
            userBadgeValue  = ''; userBadgeValueSecondary ='';
            if (comment.CreatedBy.Is_Consultant__c) {
                userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                userBadgeValue = 'CONSULTANT' ;
            }
            if (comment.CreatedBy.Is_Employee__c) {
                userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                userBadgeValue = 'EMPLOYEE' ;
            } 
            if (comment.CreatedBy.Is_Partner__c) {
                userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                userBadgeValue = 'PARTNER' ;
            }            
            if (comment.CreatedBy.Champion__c) {
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
                this.posterName = comment.CreatedBy.FirstName + ' ' + comment.CreatedBy.LastName.substring(0, 1);
            }

            this.postDate = comment.CreatedDate.format();
            If (stickyIdeaCommentIdList.size() > 0 && stickyIdeaCommentIdList != NULL){ 
            system.debug('*******STRING*****'+ comment.Id );
               for(IdeaCommentStatusUpdate__c ideaCommentStatusUpdate : stickyIdeaCommentIdList ){        
                    If (ideaCommentStatusUpdate.ParentId__c == comment.Id && ideaCommentStatusUpdate.IsChecked__c == true){
                        isStickyComment =  true;                          
                        stickyCommentId = ideaCommentStatusUpdate.ParentId__c;
                        break;                        
                    } 
                } 
            }
            else
            {
                isStickyComment =  false;           
            }            
        }
        
        public Boolean getIsEditable() {
            //return false;
            return (comment.CreatedById == UserInfo.getUserId());
        }
     }
    
     public static testMethod void testIdeaDetailController() {
        Idea idea = new Idea();
        idea.Title = 'Test';
        idea.communityId = GlobalFunctions.communityId;
        insert idea;
        
        IdeaComment comment = new IdeaComment();
        comment.commentbody = 'Test';
        comment.IdeaId = idea.Id;
        insert comment;
        
        ApexPages.currentPage().getParameters().put('id', idea.Id);
        MarketoIdeaDetailController controller = new MarketoIdeaDetailController();
        controller.init();
        controller.save();
        controller.unsubscribe();
        
        controller.edit();
        controller.saveEdit();
        controller.cancelEdit();
        controller.getIsEditable();
        controller.editCommentIndex = 0;      
        controller.editComment();
        controller.commentBody = 'testttt';
        controller.saveEditComment();
        controller.cancelEditComment();
    }
    
    /* 09-03-11 vishals@grazitti.com Added to increase test coverage */
    public static testMethod void testIdeaDetailController2() {
        Idea idea = new Idea();
        idea.Title = 'Test';
        idea.Body = 'Test';
        idea.Categories = 'All';
        idea.communityId = GlobalFunctions.communityId;
        insert idea;
        
        IdeaComment comment = new IdeaComment();
        comment.commentbody = 'Test';
        comment.IdeaId = idea.Id;
        insert comment;
        
        ApexPages.currentPage().getParameters().put('id', idea.Id);
        MarketoIdeaDetailController controller = new MarketoIdeaDetailController();
        controller.init();
        controller.newIdeaComment.commentbody = 'Test';
        controller.save();
        
        controller.unsubscribe();        
        controller.edit();
        controller.saveEdit();
        controller.cancelEdit();
        controller.getIsEditable();
        controller.editCommentIndex = 0;
        
        List<IdeaComment> idCommList = [Select i.SystemModstamp, i.IsHtml, i.IsDeleted, i.IdeaId, i.Id, i.CreatedDate, i.CreatedBy.FirstName, i.CreatedBy.LastName, i.CreatedBy.Is_Partner__c, i.CreatedBy.Enterprise__c, i.CreatedBy.Professional__c, i.CreatedBy.Spark__c, i.CreatedBy.Champion__c, i.CreatedBy.Is_Employee__c, i.CreatedBy.Is_Consultant__c,  i.CommentBody From IdeaComment i limit 1];
        List<Community_Profile__c> commProfiles = [Select c.Website__c, c.User__c, c.Twitter__c, c.Title__c, c.SystemModstamp, c.Profile_Picture_ID__c, c.Picture_Link__c, c.OwnerId, c.Name, c.Location__c, c.LinkedIn__c, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Facebook__c, c.Display_Name__c, c.Customer_Since__c, c.CreatedDate, c.CreatedById, c.ConnectionSentId, c.ConnectionReceivedId, c.Company_Name__c, c.About_Me__c From Community_Profile__c c limit 1];
        
        List<IdeaCommentStatusUpdate__c> commstickyIdeaCommentId = [Select MasterId__c, Parentid__c, Ischecked__c from IdeaCommentStatusUpdate__c Limit 1];
        if(idCommList.size() > 0 && commProfiles.size() > 0  && commstickyIdeaCommentId.size() > 0){
            
            MarketoIdeaDetailController.IdeaCommentWrapper wrapper = new MarketoIdeaDetailController.IdeaCommentWrapper(idCommList.get(0), commProfiles.get(0),commstickyIdeaCommentId,FALSE,controller.myVoteToCommentIdsSet.contains(comment.Id),controller.voteCountsPerCommentMap.get(comment.id));
            
            
            wrapper.getIsEditable();
        }
    }
     
     /* 14-03-11 vishals@grazitti.com Added to increase test coverage */  
     public static testMethod void testIdeaDetailController3() {
        Idea idea = new Idea();
        idea.Title = 'Test';
        idea.Body = 'Test';
        idea.Categories = 'APIs';
        idea.communityId = GlobalFunctions.communityId;
        insert idea;
        
        IdeaComment comment = new IdeaComment();
        comment.commentbody = 'Test';
        comment.IdeaId = idea.Id;
        insert comment;
        
        ApexPages.currentPage().getParameters().put('id', idea.Id);
        MarketoIdeaDetailController controller = new MarketoIdeaDetailController();
        controller.init();
        controller.title= 'title1';
        controller.body = 'test1';
        controller.ideaSubscribe = true;
        controller.saveEdit();
        
        controller.votedCommentId = comment.Id;
        controller.promoteComment();
        
        controller.getNextIdea(comment.Id);
        controller.getPrevIdea(comment.Id);
        controller.Idea  = idea;
        
        controller.getSubscribedToIdea();
        controller.toggleSubscription();    
        
        controller.isSticky = true;
        controller.isStickcomment = 'test sticky comment';
        controller.Submit();
        
        controller.GetStickyCommentUserIds();
        controller.deleteStickyOnComment();
        controller.saveStickyonComment();     
     }        

}