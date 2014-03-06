public class MarketoCommunityHomeController extends MarketoBaseController {
        
    public List<MarketoPost> rows {get; set;}
    public GlobalFunctions gF {get;  private set;} 
    public MarketoPost stickyPost{get;set;}
    public string stickyComment{get;set;}
     public STATIC FINAL Integer MAX_RECORDS = 5;
    public STATIC FINAL Integer MAX_HOME_PAGE_RECORDS = 10;
    public static final String communityId = GlobalFunctions.communityId;
    private static String ideaSql = 'SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById,' +
    'LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories,' +
    'Body,CreatedBy.Id, CreatedBy.Email, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = \'' + UserInfo.getUserId() + '\'), ' +
    ' (select id from Comments) FROM Idea i ';
    private static String IdeaCountSql = 'SELECT count() from Idea i ';
    private static String questionSql = 'SELECT Id, Title, numreplies, IsDeleted, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c, CreatedBy.is_consultant__c,CreatedBy.Spark__c, CreatedDate, CreatedById, CommunityId,' +
    'Body,CreatedBy.Email, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, (select datacategoryname from datacategoryselections), bestreplyid ';
    private static String questionCountSql = 'SELECT count() from Question q ';
    public Integer pageNum{get;set;}
    public Integer postPageNum {get; set;}
    public Boolean hasPostNextPage{get;set;}
    public Boolean hasPostPrevPage{get;set;}
    public STATIC FINAL Integer TOTAL_NO_RESULTS = 2100;
    public Integer totalNoResults{get;set;}
    public List<Integer> paginationList{get;set;}
    Public String commHomePg{get;set;}
    public Integer postResultSize {get; set;}
    public static Integer postNumResults {get; set;}
    public Double totalNumOfPages{get;set;}
    public MarketoCommunityHomeController() {
    postResultSize = 10;
    String currentPageURL = ApexPages.currentPage().getUrl();
    if (currentPageURL == null) currentPageURL='';
    postNumResults = currentPageURL.contains('MarketoCommunityHome')?5:10;
    String commHomePg = ApexPages.currentPage().getParameters().get('commHomePg');
    postPageNum = commHomePg == null ? 1 : Integer.valueOf(commHomePg);
    // system.debug('====discussionPageNum==='+postPageNum);
    init();
    }
        
    
    public PageReference init() {
    
        commHomePg = ApexPages.currentPage().getParameters().get('commHomePg');
        system.debug('====commHomePg=='+commHomePg );
        if(commHomePg != null){
            if(Integer.valueOf(commHomePg) <= 200){
            postPageNum = commHomePg == null ? 1 : Integer.valueOf(commHomePg);
            System.debug('postPageNum : '+ postPageNum );
            }
            else{
                postPageNum = Integer.ValueOf(200);
            }
        }
    
         System.debug('test--->' + UserInfo.getUserId());
    
         if (UserInfo.getUserId() == '00550000001gOQBAA2') {
            if (UserInfo.getOrganizationId().indexOf('00DP00000006gh2') == 0) {
              return new PageReference('https://app-qe.marketo.com/homepage/community');
            }
            else {
              return new PageReference('https://app.marketo.com/homepage/community');
            }
        }
        gF = new GlobalFunctions(); 
       // List<Idea> ideas = (List<Idea>) GlobalFunctions.getIdeas(null, null, 'Home', false).getRecords();
       // List<Question> questions = (List<Question>) GlobalFunctions.getQuestions(null, null, 'Home', false).getRecords();
        List<Idea> ideas = getIdeas(postPageNum);
        List<Question> questions = getQuestions(postPageNum);
        totalNoResults = TOTAL_NO_RESULTS;
        paginationList = getPaginationList(postPageNum, totalNoResults , MAX_HOME_PAGE_RECORDS);
        hasPostNextPage = postPageNum==totalNumOfPages?false:true;
        hasPostPrevPage = postPageNum > 1?true:false; 

        /*Sticky Post*/
        Sticky_Post__c stickyPostSetting = [select Id, ID__c, Name, Checked__c, Comment__c, type__c from Sticky_Post__c where name=:'StickyPost' LIMIT 1];
        stickyComment = stickyPostSetting.Comment__c;
        System.Debug('__Fetching data__'+stickyPostSetting );
        
        /*Sticky Post*/
      
        Set<Id> userIds = new Set<Id>();
        for (Idea idea : ideas) {
            userIds.add(idea.CreatedById);
                                                
        }
        for (Question question : questions) {
            userIds.add(question.CreatedById);
            
        }

        Map<Id, Community_Profile__c> userIdToProfileMap = GlobalFunctions.getProfilesForUsers(userIds);
         Map<Id, Boolean> userIdToBVMap = GlobalFunctions.getPartner_Supported_Status_ForUsers(userIds);

        
        List<Long> times = new List<Long>();
        Map<Long, MarketoPost> rowMap = new Map<Long, MarketoPost>();
    
        for (Idea idea : ideas) {
            Community_Profile__c profile = userIdToProfileMap.get(idea.CreatedById);

            times.add(idea.CreatedDate.getTime());
            rowMap.put(idea.CreatedDate.getTime(), new MarketoPost(idea, profile,userIdToBVMap.get(idea.CreatedById)));
            
        }

        for (Question question : questions) {
            Community_Profile__c profile = userIdToProfileMap.get(question.CreatedById);
            
            times.add(question.CreatedDate.getTime());
            rowMap.put(question.CreatedDate.getTime(), new MarketoPost(question, profile,userIdToBVMap.get(question.CreatedById)));
            
        }
        //Sticky Comment 12/Feb/2012 jaimals@grazitti.com
        If(postPageNum == 1){
            If(stickyPostSetting.Type__c == 'Discussion'){
                Question question = GlobalFunctions.getQuestion(stickyPostSetting.Id__c);
                Map<Id, Boolean> userIdToBVQuestionMap = GlobalFunctions.getPartner_Supported_Status_ForUsers(New Set<Id>{question.createdbyId});
                Map<Id, Community_Profile__c> stickyPostUserIdToProfile = GlobalFunctions.getProfilesForUsers(New Set<Id>{question.createdbyId});
                stickypost =  new MarketoPost(question, stickyPostUserIdToProfile.get(question.createdbyId),userIdToBVQuestionMap.get(question.CreatedById));
                System.Debug('__stickypost from discussion__'+stickyPost);
            }else If(stickyPostSetting.Type__c == 'Idea'){
               
                Idea idea = GlobalFunctions.getIdea(stickyPostSetting.Id__c); 
                 Map<Id, Boolean> userIdToBVIdeaMap = GlobalFunctions.getPartner_Supported_Status_ForUsers(New Set<Id>{idea.createdbyId});
                Map<Id, Community_Profile__c> stickyPostUserIdToProfile = GlobalFunctions.getProfilesForUsers(New Set<Id>{idea.createdbyId});
                stickypost  =  new MarketoPost(idea , stickyPostUserIdToProfile.get(idea.createdbyId),userIdToBVIdeaMap.get(idea.CreatedById));
                System.Debug('__stickypost from idea__'+stickyPost);
            }
        }
        //Sticky Comment 12/Feb/2012 jaimals@grazitti.com
       
        times.sort();
        rows = new List<MarketoPost>();
        for (Integer i = times.size() - 1; i >= 0; i--) {
            if (stickyPostSetting.ID__c != rowMap.get(times[i]).Id) {
               rows.add(rowMap.get(times[i]));
            } 
        }
        
        return null;
    }
     public List<Question> getQuestions(Integer discussionPageNum) {
        Integer offset = (discussionPageNum-1) * MAX_RECORDS;
        String sql = questionSql;
        sql += ', (select Id from Replies) from Question q ';
        String whereSql = 'where communityId = \'' + communityId + '\' ';
        System.Debug('COUNTSQL'+questionCountSql+whereSql);
        //totalNoResults = Database.countQuery(questionCountSql+whereSql);
        whereSql += 'ORDER BY CreatedDate desc';
        List<Question> qs = (List<Question>)Database.Query(sql+whereSql+' LIMIT '+MAX_RECORDS+' OFFSET '+offset);
        System.Debug('TOTALRESULTS '+totalNoResults);
        System.Debug('OFFSETSIZE'+qs.size());
        return qs;
    }
    public List<Idea> getIdeas(integer idePageNum) {
        Integer offset = (idePageNum-1) * MAX_RECORDS;
        String sql = ideaSql;
        String whereSql = '';
        string status_string = '';
        whereSql += 'where communityId = \'' + communityId + '\' ';
        whereSql += 'ORDER BY CreatedDate desc';
        List<Idea> ideas = (List<Idea>)Database.Query(sql+whereSql+' LIMIT '+MAX_RECORDS+' OFFSET '+offset);
        return ideas;
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
                    If(curPageNo == totalNumOfPages) {tempNum = 6;}
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
    public MarketoCommunityHomeController getCommHomeControl() {
        return this;
    }
    
    public static testMethod void testHomeController() {
        Idea i = new Idea();
        i.title = 'test';
        i.CommunityId = GlobalFunctions.communityId;
        insert i;
        
        Question q = new Question();
        q.title = 'test';
        q.CommunityId = GlobalFunctions.communityId;
        insert q;
        
        Sticky_Post__c sticky = new  Sticky_Post__c();
        sticky.Name = 'StickyPost';
        sticky.Checked__c = false;
        sticky.Comment__c ='this is test comment';
        insert sticky;
        
        MarketoCommunityHomeController c = new MarketoCommunityHomeController();
        test.starttest();
        c.init();
        c.getPaginationList(6,500,10);
        /* 14-03-11 vishals@grazitti.com Added to increase code coverage */
        // c.getCommHomeControl();
        system.assertEquals(c.rows.size()>=2, true);
        test.stoptest();
    }
    
    /* 14-03-11 vishals@grazitti.com Added to increase code coverage */
    public static testMethod void testHomeController2() {
        Idea i = new Idea();
        i.title = 'test';
        i.CommunityId = GlobalFunctions.communityId;
        insert i;
        
        Question q = new Question();
        q.title = 'test';
        q.CommunityId = GlobalFunctions.communityId;
        insert q;
        User tUser = new User(Id='00550000001gOQBAA2');
        System.runAs(tUser){
            MarketoCommunityHomeController c = new MarketoCommunityHomeController();
            c.init();
        }       
    }
}