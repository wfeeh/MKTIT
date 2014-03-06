public class MarketoIdeasHomeController extends MarketoBaseController
{  
    public Boolean inRecent  {get; set;}
    public Boolean inPopular {get; set;}
    public Boolean inActive  {get; set;}
    public Boolean inDone    {get; set;}    
    public String tabType {get;set;}
    public String ideaType {get; set;}
    public String selectedStatus {get; set;}
    public Integer ideaPageNum {get; set;}
    public List<String> selectedDoneStatus {get;set;}
    public String selectedCategory {get; set;}
    public List<MarketoPost> ideas {get; private set;}
    public List<SelectOption> status {get; private set;}
    public List<SelectOption> statusDone {get; private set;}
    public List<SelectOption> statusDonePartially {get; private set;}
    public List<SelectOption> categories {get; private set;}
    public static final String communityId = GlobalFunctions.communityId;
    private static String IdeaCountSql = 'SELECT count() from Idea i  ';
    public Boolean hasIdeaNextPage{get;set;}
    public Boolean hasIdeaPrevPage{get;set;}
    
    private static String ideaSql = 'SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById,' +
        'LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories,' + 
        'Body,CreatedBy.Id, CreatedBy.Email, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = \'' + UserInfo.getUserId() + '\'), ' +
        ' (select id from Comments) FROM Idea i ';
    
    public List<Integer> paginationList{get;set;}
    public STATIC FINAL Integer MAX_RECORDS = 10;
    public Integer totalNoResults{get;set;}
    public Integer IdeasResultSize {get; set;}
    public static Integer IdeaNumResults {get; set;}
    Public Integer TotPage{get;set;}
    public Double totalNumOfPages{get;set;}

    
    public MarketoIdeasHomeController() {
        IdeasResultSize = 0;
        String currentPageURL =  ApexPages.currentPage().getUrl();
        if (currentPageURL == null) currentPageURL='';  
        IdeaNumResults = currentPageURL.contains('MarketoIdeasHome')?5:10;
        String IdeaPg = ApexPages.currentPage().getParameters().get('IdeaPg');
        IdeaPageNum   = IdeaPg == null ? 1 : Integer.valueOf(IdeaPg);
        init();
    }
    
    private void init() {
      inRecent  = true;
      inPopular = false;
      inActive  = false;
      inDone    = false;
      String tType = ApexPages.currentPage().getParameters().get('tabType');
      tabType = tType != null ? tType : 'Recent'  ;
      System.debug('tabType '+ tabType );
      
      String ideaPg= ApexPages.currentPage().getParameters().get('ideaPg');
      ideaPageNum = ideaPg== null ? 1 : Integer.valueOf(ideaPg);
      System.debug('ideaPageNum : '+ ideaPageNum );
        
        
        
        categories = new SelectOption[]{new SelectOption('All Categories', 'All Categories')};
        for (Schema.PicklistEntry f : Idea.Categories.getDescribe().getPicklistValues()) {
            categories.add(new SelectOption(f.getLabel(), f.getValue()));
        }       

        status = new SelectOption[]{new SelectOption('All Statuses', 'All Statuses')};
        for (Schema.PicklistEntry f : Idea.Status.getDescribe().getPicklistValues()) {
            status.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        
        statusDone = new SelectOption[]{new SelectOption('All Statuses', 'All Statuses')};
        for (Schema.PicklistEntry g : Idea.Status.getDescribe().getPicklistValues()) {
          if (tabType == 'Popular' && g.getValue() != 'Already Have It' && g.getValue() != 'Already Have It (Partially)' ) {
              if(g.getValue() != 'Done!' && g.getValue() != 'Done (Partially)'){
                  statusDone.add(new SelectOption(g.getLabel(), g.getValue()));
              }
          }
        }
        
        selectedStatus = ApexPages.currentPage().getParameters().get('ideaStatus');
        System.debug('selectedStatus==> '+selectedStatus );
        selectedCategory = ApexPages.currentPage().getParameters().get('ideaCategory');
        
        if (selectedCategory == null || selectedCategory.trim().length() < 1) {
            selectedCategory = 'All Categories';
        }
        if (selectedStatus == null || selectedStatus.trim().length() < 1) {
            selectedStatus = 'All Statuses';
        }
        
        getIdeas(true);
        
    }
    
    public void getIdeas(Boolean requery) {
    System.debug('tabtype '+tabtype );
    List <Idea> idea;
        if (requery) {
            if (tabtype == 'Active') {
                idea = getActiveIdeas(selectedCategory, selectedStatus, null, inPopular, ideaPageNum);
                paginationList  = getPaginationList(IdeaPageNum, totalNoResults, MAX_RECORDS);
                hasIdeaNextPage = IdeaPageNum==totalNumOfPages?false:true;
                hasIdeaPrevPage = ideaPageNum > 1?true:false;
            } else if (tabtype == 'Done') {
                idea = getIdeas(selectedCategory, 'Done!___Done (Partially)', null, inPopular,ideaPageNum);
                paginationList = getPaginationList(IdeaPageNum, totalNoResults, MAX_RECORDS);
                hasIdeaNextPage = IdeaPageNum==totalNumOfPages?false:true;
                hasIdeaPrevPage = ideaPageNum > 1?true:false; 
            } else if (tabtype == 'Popular'){
                inPopular = true;
                idea = getIdeas(selectedCategory, selectedStatus, null, inPopular, ideaPageNum);
                paginationList = getPaginationList(IdeaPageNum, totalNoResults, MAX_RECORDS);
                hasIdeaNextPage = IdeaPageNum==totalNumOfPages?false:true;
                hasIdeaPrevPage = ideaPageNum > 1?true:false; 
            }else {
                idea = getIdeas(selectedCategory, selectedStatus, null, inPopular,ideaPageNum);
                paginationList = getPaginationList(IdeaPageNum, totalNoResults, MAX_RECORDS);
                hasIdeaNextPage = IdeaPageNum==totalNumOfPages?false:true;
                hasIdeaPrevPage = ideaPageNum > 1?true:false; 
            }
            
        }
 
        Set<Id> userIds = new Set<Id>();
        for (Idea ida : idea) {
            //System.debug('__IDEA_COMMENTS__'+idea.Com.Id);
            userIds.add(ida.CreatedById);
        }

        Map<Id, Community_Profile__c> userIdToProfileMap = GlobalFunctions.getProfilesForUsers(userIds);
        Map<Id, Boolean> userIdToBVMap = GlobalFunctions.getPartner_Supported_Status_ForUsers(userIds);
        
        ideas = new List<MarketoPost>();
        for (Idea i : idea) {
            Community_Profile__c profile = userIdToProfileMap.get(i.CreatedById);
            ideas.add(new MarketoPost(i, profile,userIdToBVMap.get(i.CreatedById)));
        }
        IdeasResultSize  = idea.size();
    }
    
    public List<Idea> getIdeas(String category,String status, String section, Boolean inPopular, integer idePageNum) {
        Integer offset = (idePageNum-1) * MAX_RECORDS;
        String sql = ideaSql;
         
        String whereSql = '';  
        string status_string = '';                   
        whereSql += 'where communityId = \'' + communityId + '\' ';
     // whereSql += 'where communityId = \'' + communityId + '\' '+ 'and IsLocked != true ';
        System.Debug('+++CurrentCategory+++'+Category);
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
            whereSql += 'and Status != \'' + 'Done!'+ '\' ' + 'and Status != \'' + 'Done (Partially)'+ '\' ' + 'and Status != \'' + 'Already Have It'+ '\' ' + 'and Status != \'' + 'Already Have It (Partially)'+ '\' ';
        }          
       
        totalNoResults = Database.countQuery(ideaCountSql+whereSql);             
        
        if (inPopular) {
            whereSql += ' ORDER BY VoteTotal desc';
            System.debug('whereSql---> '+ whereSql );
        }          
        if(!inPopular){
            whereSql +=  'ORDER BY  CreatedDate desc';
           
        }
        
        System.debug('testing+++'+sql+whereSql+' LIMIT '+MAX_RECORDS+' OFFSET '+offset);
       
        List<Idea> ideas = (List<Idea>)Database.Query(sql+whereSql+' LIMIT '+MAX_RECORDS+' OFFSET '+offset);
        
        //System.debug('ideaSql--->'+ideaSql+whereSql);
        //System.debug('ideaSql--->'+ideaSql);
        //System.debug('idea--->'+idea);
        //System.Debug('TOTALRESULTS'+totalNoResults);
        //System.Debug('OFFSETSIZE'+ideas.size());
        //system.debug('+++idea+++'+ideas);
        return ideas;
    }
        public List<Idea> getActiveIdeas(String category, String status, String section, Boolean inPopular, integer idePageNum) {
        Integer offset = (IdeaPageNum-1) * MAX_RECORDS;
        // Last week comment count on ideas
        List<AggregateResult> ideaCommentCounts = [Select i.Idea.id, count(Id)  c From IdeaComment i where i.CreatedDate > LAST_WEEK  GROUP BY i.Idea.id ORDER by count(Id) DESC];
        System.debug('__IDEA_COMMENT_COUNTS__'+ideaCommentCounts);
        List<Id> activeIdeas = new List<Id>();
        for(AggregateResult ar:ideaCommentCounts) {
            activeIdeas.add(ar.Id);
            System.debug('activeIdeas====>'+activeIdeas);
        }
        List<Idea> ideas;
        if (category != null && category != 'All Categories') {
            if (status != null && status != 'All Statuses' && status != 'Done!') {
               ideas = [SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById, LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = :UserInfo.getUserId()), (select id from Comments order by CreatedDate desc) FROM Idea i where communityId = :communityId and Id in :activeIdeas and Categories includes (:category) and Status =:status and IsLocked != true order by LastCommentDate desc LIMIT :MAX_RECORDS OFFSET :offset];
               //System.debug('Category++++++++'+ideas);
               totalNoResults = Database.countQuery('SELECT count() from Idea i where communityId = \''+communityId+'\' and Id in :activeIdeas and Categories includes (:category) and Status =:status');
            } else {
               ideas = [SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById, LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = :UserInfo.getUserId()), (select id from Comments) FROM Idea i where communityId = :communityId and Id in :activeIdeas  and Categories includes (:category) and Status =:status and IsLocked != true order by LastCommentDate desc LIMIT :MAX_RECORDS OFFSET :offset];
               totalNoResults = Database.countQuery('SELECT count() from Idea i where communityId = \''+communityId+'\' and Id in :activeIdeas and  Categories includes (:category) and Status =:status');
               //System.debug('Category++++++++'+ideas);
            }
        }
            
         else {
            if (status != null && status != 'All Statuses' ) {
               ideas =  [SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById, LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = :UserInfo.getUserId()), (select id from Comments) FROM Idea i where communityId = :communityId and Id in :activeIdeas  and Status =:status and IsLocked != true order by LastCommentDate desc LIMIT :MAX_RECORDS OFFSET :offset];
               totalNoResults = Database.countQuery('SELECT count() from Idea i where communityId = \''+communityId+'\' and Id in :activeIdeas and  and Status =:status');
               //System.debug('Category++++++++'+ideas);
            } else {
               ideas = [SELECT Id, VoteTotal, VoteScore, Title, Status, ParentIdeaId, NumComments, MarketoId__c, LastModifiedDate, LastModifiedById, LastCommentId, LastCommentDate, IsLocked, IsHtml, IsDeleted, CreatedDate, CreatedById, CommunityId, Categories, Body, CreatedBy.CommunityNickname, CreatedBy.firstname, createdby.lastname, CreatedBy.is_partner__c, CreatedBy.is_customer__c, CreatedBy.is_employee__c, CreatedBy.is_consultant__c,CreatedBy.Champion__c,CreatedBy.Professional__c,CreatedBy.Enterprise__c,CreatedBy.Spark__c, (select id from votes where createdbyid = :UserInfo.getUserId()), (select id from Comments order by SystemModstamp desc) FROM Idea i where communityId = :communityId and Id in :activeIdeas and Status != 'Done!' and Status != 'Done(Partially)' and IsLocked != true order by LastCommentDate desc LIMIT :MAX_RECORDS OFFSET :offset];
               System.Debug('___setcon4__');
              totalNoResults = Database.countQuery('SELECT count() from Idea i where communityId = \''+communityId+'\' and Id in :activeIdeas and Status != \'Done!\' and Status != \'Done(Partially)\'');
              //System.debug('Category++++++++'+ideas);
            }        
        }
        System.debug('+++totalNoResults+++'+totalNoResults);
        return ideas;
    }
//Issue #3302 by jaimals@grazitti.com
    //Changes on demand from Carina regarding pagination 
    public List<Integer> getPaginationList (Integer curPageNo,Integer totalResults, Integer pagesize) {
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
    //Issue #3302 by jaimals@grazitti.com 

    public PageReference updateCategory() {
        PageReference pageRef = new PageReference('/apex/MarketoIdeasHome?ideaPg=1&tabType='+tabType+'&ideaCategory=' + selectedCategory + '&ideaStatus='+ selectedStatus);
        pageRef.setRedirect(true);
        return pageRef;
         getIdeas(true);
        return null;
    }
    
    public PageReference updateStatus() {
        PageReference pageRef = new PageReference('/apex/MarketoIdeasHome?ideaPg=1&tabType='+tabType+ '&ideaCategory='+selectedCategory + '&ideaStatus='+ selectedStatus);
        pageRef.setRedirect(true);
        return pageRef;
        getIdeas(true);
        return null;
    }
    
    public Boolean getSubscribedToCurrentCategory() {
        return (Database.countQuery('select count() from Community_Subscription__c where User__c = \'' + UserInfo.getUserId() + '\' and Type__c = \'Idea\' and Category__c = \'' + String.escapeSingleQuotes(selectedCategory) + '\'') > 0);
    }
    
    public PageReference toggleSubscription() {
        try {
            // Delete existing subscription if there is one.
            Community_Subscription__c subscription = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'Idea' and Category__c = :selectedCategory];
            delete subscription;
        } catch (Exception e) {
            // An exception is thrown if no subscription exists yet.
            
            // Setup subscription.
            Community_Subscription__c subscription = new Community_Subscription__c();
            subscription.User__c = UserInfo.getUserId();
            subscription.Type__c = 'Idea';
            subscription.Category__c = selectedCategory;
            subscription.Category_Label__c = selectedCategory;
            insert subscription;
        }

        return null;
    }
    
    public PageReference updateType() {
        getIdeas(true);
        return null;
    }
   
    public MarketoIdeasHomeController getIdeasHomeControl() {
        return this;
    }
    
    public static testMethod void testIdeasHomeController() {
        Idea i = new Idea();

        User u = [select Id from User where IsActive = true and Id != :UserInfo.getUserId() and ProfileId = :[select Id from Profile where Name = 'System Administrator'].Id limit 1];

        System.runAs(u) {
            i.Title = 'Test';
            i.communityId = GlobalFunctions.communityId;
            insert i;
        }

        MarketoIdeasHomeController c = new MarketoIdeasHomeController();
       // c.init();
        c.tabtype = 'Active';
        c.getIdeas(true);
        c.tabtype = 'Done';
        c.getIdeas(true);
        c.tabtype = 'Popular';
        c.getIdeas(true);
        c.updateStatus();
        c.updateCategory();
        c.updateType();

       // c.getHasNextPage();
       // c.getHasPrevPage();
       // c.prevPage();
       // c.nextPage();

        c.toggleSubscription();
        c.toggleSubscription();
        c.getSubscribedToCurrentCategory();
    }

}