public class MarketoDiscussionHomeController extends MarketoBaseController {
   
    public Boolean inRecent {get; set;}
    public Boolean inPopular {get; set;}
    public Boolean inActive {get; set;}
    
    public String tabType{get;set;}
    public Integer pageNum{get;set;}
    public String selectedStatus {get; set;}
    public String selectedCategory {get; set;}
    public Integer discussionPageNum {get; set;}
    public Boolean hasDiscussionNextPage{get;set;}
    public Boolean hasDiscussionPrevPage{get;set;}
    
    public OrgWideEmailAddress OrgWideEmailAddress{get;set;}
    public List<MarketoPost> questions {get; private set;}
    public List<SelectOption> status {get; private set;}
    public List<SelectOption> categories {get; private set;}
    private ApexPages.StandardSetController setCon {get; private set;}  
    
    public STATIC FINAL Integer MAX_RECORDS = 10;
    public static final String communityId = GlobalFunctions.communityId;
    private static String questionSql = 'SELECT Id, Title, numreplies, IsDeleted, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_consultant__c,CreatedBy.Spark__c, CreatedDate, CreatedById, CommunityId,' + 
                            'Body,CreatedBy.Email, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, (select datacategoryname from datacategoryselections), bestreplyid ';
    private static String questionCountSql = 'SELECT count() from Question q  ';
    public Integer totalNoResults{get;set;}
    public List<Integer> paginationList{get;set;}
    Public String discussionPg{get;set;}
    //Public Integer nDiscussionPg{get;set;}
    
   //steffi 16 jan 2013 
   public Integer discussionResultSize {get; set;}
   public static Integer discussionNumResults {get; set;}
   Public Double TotRecords{get;set;}
   Public Integer TotPage{get;set;}
   public Double totalNumOfPages{get;set;}
   public MarketoDiscussionHomeController() {
        //steffi 16 jan
        discussionResultSize = 10;
        String currentPageURL =  ApexPages.currentPage().getUrl();
        if (currentPageURL == null) currentPageURL='';  
        discussionNumResults = currentPageURL.contains('MarketoDiscussionHome')?5:10;
        String discussionPg = ApexPages.currentPage().getParameters().get('discussionPg');
        discussionPageNum   = discussionPg == null ? 1 : Integer.valueOf(discussionPg);
       // system.debug('====discussionPageNum==='+discussionPageNum);
       
        init();
    }
    
    
   public class SetActivityClass {
   }
  
   
    private void init() {
        inRecent = true;
        inPopular = false;
        inActive = false;
        String tType = ApexPages.currentPage().getParameters().get('tabType');
        tabType = tType != null ? tType : 'Recent'  ;
        System.debug('tabType '+ tabType );
        
        discussionPg = ApexPages.currentPage().getParameters().get('discussionPg');
        system.debug('====discussionPg=='+discussionPg);
        if(discussionPg != null){
           if(Integer.valueOf(discussionPg) <= 200){
                discussionPageNum = discussionPg == null ? 1 : Integer.valueOf(discussionPg);
                System.debug('discussionPageNum : '+ discussionPageNum );
            }
            else{
                discussionPageNum = Integer.ValueOf(200);
            }
        }
        categories = new SelectOption[] {new SelectOption('All Categories', 'All Categories')};
        for (DataCategory c : DataCategoryHelper.getHelper('Question').getCategories()) {
            categories.add(new SelectOption(c.getName(), c.getLabel()));
            System.debug('categories'+ categories );
        }
            
        status = new SelectOption[] {new SelectOption('All Statuses', 'All Statuses')};
        
        selectedStatus = ApexPages.currentPage().getParameters().get('DiscussionStatus');
        selectedCategory = ApexPages.currentPage().getParameters().get('DiscussionCategory');
        
        System.debug('selectedCategory=====> '+selectedCategory );
        if (selectedCategory == null || selectedCategory.trim().length() < 1) {
            selectedCategory = 'All Categories';
        }

        getQuestions(true);
    }
    
    public void getQuestions(Boolean requery) {
                List <Question> qsns;

        if (requery) {
            if(tabtype == 'Active'){
            System.debug('tabtype==> '+tabtype );
               System.debug('selectedCategory==> '+selectedCategory);
               System.debug('selectedStatus==> '+selectedStatus);
               System.debug('inPopular==> '+inPopular);
               system.debug('====discussionPageNum==='+discussionPageNum);
               qsns = getActiveQuestions(selectedCategory, selectedStatus, null, inPopular, discussionPageNum);
               paginationList = getPaginationList(discussionPageNum, totalNoResults, MAX_RECORDS);
               hasDiscussionNextPage = discussionPageNum==totalNumOfPages+1?false:true;
               hasDiscussionPrevPage = discussionPageNum > 1?true:false;               

                
                System.debug('__pageNum __'+discussionPageNum );
           }else{
                System.debug('selectedCategory==> '+selectedCategory);
                System.debug('MAX_RECORDS==> '+MAX_RECORDS);
                System.debug('totalNoResults==> '+totalNoResults);
                system.debug('====discussionPageNum==='+discussionPageNum);
                
                qsns = getQuestions(selectedCategory, selectedStatus, null, inPopular, discussionPageNum);
                
                paginationList = getPaginationList(discussionPageNum, totalNoResults, MAX_RECORDS);
                hasDiscussionNextPage = discussionPageNum==totalNumOfPages?false:true;
                hasDiscussionPrevPage = discussionPageNum > 1?true:false;                  
                System.debug('__pageNum __'+discussionPageNum );
                 }
          }
        Set<Id> userIds = new Set<Id>();
        for (Question question : qsns) {
            userIds.add(question.CreatedById);
        }

        Map<Id, Community_Profile__c> userIdToProfileMap = GlobalFunctions.getProfilesForUsers(userIds);
        Map<Id, Boolean> userIdToBVMap = GlobalFunctions.getPartner_Supported_Status_ForUsers(userIds);
        questions = new List<MarketoPost>();
        for (Question question : qsns) {
            Community_Profile__c profile = userIdToProfileMap.get(question.CreatedById);
            questions.add(new MarketoPost(question, profile,userIdToBVMap.get(question.CreatedById)));
        }
        discussionResultSize  = qsns.size();
    }
    
    public PageReference updateCategory() {
        PageReference pageRef = new PageReference('/apex/MarketoDiscussionHome?discussionPg=1&DiscussionCategory='+selectedCategory +'&tabType='+tabType);
        pageRef.setRedirect(true);
        return pageRef;
        getQuestions(true); 
        return null;
    }
    
    public PageReference updateStatus() {
        getQuestions(true);
        return null;
    }
    
    public Boolean getSubscribedToCurrentCategory() {
        return (Database.countQuery('select count() from Community_Subscription__c where User__c = \'' + UserInfo.getUserId() + '\' and Type__c = \'Question\' and Category__c = \'' + String.escapeSingleQuotes(selectedCategory) + '\'') > 0);
    }
    
    public PageReference toggleSubscription() {
        try {
            // Delete existing subscription if there is one.
            List<Community_Subscription__c> subscriptions = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'Question' and Category__c = :selectedCategory and Idea_Question_Id__c = null];
            if(subscriptions.isEmpty() == false){
                delete subscriptions;
            } else {
                // An exception is thrown if no subscription exists yet.
                // Setup subscription.
                Community_Subscription__c subscription = new Community_Subscription__c();
                subscription.User__c = UserInfo.getUserId();
                subscription.Type__c = 'Question';
                subscription.Category__c = selectedCategory;
                subscription.Category_Label__c = DataCategoryHelper.getHelper('Question').getLabel(selectedCategory);
                insert subscription;
            }    
        } catch (Exception e) {
            System.debug('Exception Subscription Toggle==>' + e);
        }
        return null;
    }
    /* for subscription link on community sidebar by kanupriyag@grazitti.com*/
     public PageReference toggleSubscriptionLink() {
        try {
            // Delete existing subscription if there is one.
            Community_Subscription__c subscription = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'Question' and Category__c = :selectedCategory];
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
     
        public List<Question> getQuestions(String category, String status, String section, Boolean inPopular, Integer discussionPageNum) {
            Integer offset = (discussionPageNum-1) * MAX_RECORDS;
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
            System.Debug('COUNTSQL'+questionCountSql+whereSql);
            totalNoResults = Database.countQuery(questionCountSql+whereSql);        
            whereSql += 'ORDER BY CreatedDate desc';
            List<Question> qs = (List<Question>)Database.Query(sql+whereSql+' LIMIT '+MAX_RECORDS+' OFFSET '+offset);
            System.Debug('TOTALRESULTS '+totalNoResults);
        
           System.Debug('OFFSETSIZE'+qs.size());
        return qs;
    }

    public List<Question> getActiveQuestions(String category, String status, String section, Boolean inPopular, Integer discussionPageNum) {

        Integer offset = (discussionPageNum-1) * MAX_RECORDS;

        // Last week comment count on ideas
        List<AggregateResult> qsnCommentCounts = [Select r.QuestionId Id, count(r.Id) c From Reply r where r.CreatedDate > LAST_WEEK  GROUP BY r.QuestionId ORDER by count(r.Id) DESC];
        Set<Id> activeQuestions = new Set<Id>();
        String activeQuestionsIdsString;
        for(AggregateResult ar:qsnCommentCounts) {
            activeQuestions.add(ar.Id);
            activeQuestionsIdsString = '\''+ar.Id+'\',';
        }
        List<Question> qs;
        if (category != null && category != 'All Categories') {
            String categ = category + '__c ';
            if(activeQuestionsIdsString != '') {
                  activeQuestionsIdsString = activeQuestionsIdsString.substring(0,activeQuestionsIdsString.length()-1);
                  activeQuestionsIdsString = '('+activeQuestionsIdsString+')';
            }
            qs = Database.Query('SELECT Id, Title, numreplies, IsDeleted, CreatedBy.Email,CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_consultant__c,CreatedBy.Spark__c, CreatedDate, CreatedById, CommunityId, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, (select datacategoryname from datacategoryselections), bestreplyid , (select Id from Replies) from Question q where communityId = \''+communityId+'\' and Id in :activeQuestions WITH DATA CATEGORY Answers__c at '+categ+' ORDER BY CreatedDate desc LIMIT '+MAX_RECORDS+' OFFSET '+offset);
            totalNoResults = Database.countQuery('SELECT count() from Question q where communityId = \''+communityId+'\' and Id in :activeQuestions WITH DATA CATEGORY Answers__c at '+categ+' ');  
            System.Debug('OFFSETSIZE'+totalNoResults);      
          } else {
            qs = [SELECT Id, Title, numreplies, IsDeleted, CreatedBy.Email,CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_consultant__c,CreatedBy.Spark__c, CreatedDate, CreatedById, CommunityId, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, (select datacategoryname from datacategoryselections), bestreplyid , (select Id from Replies) from Question q where communityId = :communityId and Id in :activeQuestions ORDER BY LastReplyDate desc LIMIT :MAX_RECORDS OFFSET :offset];
            totalNoResults = Database.countQuery('Select count() from Question q where communityId = \''+communityId+'\' and Id in :activeQuestions');
            System.Debug('OFFSETSIZE'+totalNoResults);
        }
        System.Debug('===totalSize=='+qs.size()); 
        return qs;  
     
    }
    
        public List<Integer> getPaginationList (Integer curPageNo,Integer totalResults, Integer pagesize) {
         try {
            List<Integer> paginationList = new List<Integer>(); 
            totalNumOfPages = math.ceil(Double.valueof(totalResults)/Double.valueof(pagesize));
            Integer index;
            If(curPageNo <= 4 ){
                System.Debug('++++Less than 4');
                for (index=curPageNo-3;index<curPageNo;index+=1) {//Enter Here for first 3 pages
                    if(index<=0) {
                        continue;  
                    }
                paginationList.add(index);
                }
            paginationList.add(curPageNo);
            Integer jindex;      
                for (jindex=curPageNo+1;jindex<=7;jindex+=1) {
                    If(jindex >= totalNumOfPages+1){
                        break;
                    }
                    paginationList.add(jindex);
                }
            }else If(curPageNo >= 4 && curPageNo < totalNumOfPages-3){//Enter here for Pages In Between
                for (index=curPageNo-3;index<curPageNo;index+=1) {
                        if(index<=0) {
                            continue;  
                        }
                    paginationList.add(index);
                    }
                paginationList.add(curPageNo);
                Integer jindex;      
                    for (jindex=curPageNo+1;jindex<=curPageNo+3;jindex+=1) {
                        if(jindex > totalResults/pageSize){
                            break;
                        }
                    paginationList.add(jindex);
                    }
                }
            else {//Enter Here for last 3 pages
                System.Debug('Entered here for last three numbers'+curPageNo);
                Integer tempNum;//Number of digits before last three digits to keep the list count(7) for last three digits
                System.Debug(''+totalNumOfPages);
                If(curPageNo == totalNumOfPages-3){tempNum = 3;}
                If(curPageNo == totalNumOfPages-2){tempNum = 4;}
                If(curPageNo == totalNumOfPages-1){tempNum = 5;}
                If(curPageNo == totalNumOfPages)  {tempNum = 6;}
                for (index=curPageNo-tempNum;index<curPageNo;index+=1) {
                    if(index<=0) {
                        continue;  
                    }
                    paginationList.add(index);
                }
                paginationList.add(curPageNo);
                Integer jindex;      
                for (jindex=curPageNo+1;jindex<=totalNumOfPages+2;jindex+=1) {
                    if(jindex > totalNumOfPages){
                    break;
                    }
                    paginationList.add(jindex);
                }
            }
            System.Debug('++paginationList++'+paginationList);
        return paginationList;
        }
        catch(Exception ex){
        System.Debug('Exception'+ex);
        list<Integer> defaultList = new list<Integer> {1,2,3,4,5,6,7};
        return defaultList; 
        }
    }  

    public PageReference updateType() {
        getQuestions(true);
        return null;
    }
    
 /*   public PageReference prevPage() {
        if (setCon != null) {
         setCon.previous();
         getQuestions(false);
        }
        return null;
    }
    
    public PageReference nextPage() {
        if (setCon != null) {
           setCon.next();
            getQuestions(false);
        }
        return null;
    }
    
    public Boolean getHasPrevPage() {
        if (setCon != null) {
            return setCon.getHasPrevious();
        }
        return false;
    }
    
    public Boolean getHasNextPage() {
        if (setCon != null) {
            return setCon.getHasNext();
        }
        return false;
    }*/
    
     

    public static testMethod void testDiscListController() {
    
        Question q = new Question();
    
        User u = [select Id from User where IsActive=true and Id != :UserInfo.getUserId() and ProfileId = :[select id from Profile where Name = 'System Administrator'].Id limit 1];
        
        System.runAs(u) {
            q.Title = 'Test';
            q.communityId =GlobalFunctions.communityId;  //'09a50000000PNNr';
            insert q;
        }
        pageReference pg = page.MarketoDiscussionHome;
        pg.getParameters().put('ideastatus','All Statuses');
        pg.getParameters().put('ideaCategory','All Categories');
        Test.setCurrentPage(pg);
        MarketoDiscussionHomeController c = new MarketoDiscussionHomeController();
        c.init();
       // c.getQuestions(false);
        c.updateStatus();
        c.updateType();
        c.updateCategory();
        c.toggleSubscription();
        c.toggleSubscription();
        c.getSubscribedToCurrentCategory();
        c.toggleSubscriptionLink();
    }
}