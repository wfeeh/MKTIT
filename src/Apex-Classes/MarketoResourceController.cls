global class MarketoResourceController {
    public Resources__kav             currentArticle        {get;set;}
    public Boolean                    showArticleViewCount  {get;set;}
    public Integer                    articleViewsCount     {get;set;}
    public String                     body                  {get;set;}
    public Boolean                    errorMsg              {get;set;}

    public MarketoResourceController (ApexPages.StandardController stdController) {
         
         showArticleViewCount = false;
         errorMsg             = false;
         articleViewsCount    = 0;    
         currentArticle       = new Resources__kav();
         currentArticle       = [select knowledgeArticleId, Allow_Comments__c,LastPublishedDate ,Attachment1__Name__s,Attachment2__Name__s,Attachment3__Name__s,Attachment4__Name__s,Attachment5__Name__s, title, Article_Text__c from Resources__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online' and Language='en_US' limit 1];
         try {
             User loggedUser =  new User();
             loggedUser  = [Select id, IsPortalEnabled, name from User where  Id=:UserInfo.getUserId() limit 1];
             if(loggedUser  != null){
                 if(loggedUser.IsPortalEnabled == false){
                     showArticleViewCount = true;
                 }
                 // Fetch the article view count
                 List<KnowledgeArticleViewStat> KnowledgeArticleViewStatList = [SELECT Id,ParentId,Channel,ViewCount FROM KnowledgeArticleViewStat where ParentId =:ApexPages.currentPage().getParameters().get('Id') LIMIT 5];
                 //system.debug('====KnowledgeArticle==='+KnowledgeArticle); 
                 for(KnowledgeArticleViewStat knbArtViewStat : KnowledgeArticleViewStatList){
                    if(knbArtViewStat.Channel == 'App') {  
                        articleViewsCount += knbArtViewStat.ViewCount;
                        //system.debug('==Internalcount=='+Internalcount);
                    }
                    if(knbArtViewStat.Channel == 'Csp'){
                        articleViewsCount += knbArtViewStat.ViewCount;
                        //system.debug('==Customercount =='+Customercount );   
                    }
                 }    
             }
          }catch(Exception ex) {
        
         }    
         
    }
    
    public PageReference toggleSubscription() {
        String knbID      = '' + currentArticle.knowledgeArticleId;
        try {
            // Delete existing subscription if there is one.
            List<Community_Subscription__c> subscriptions = [select Id from Community_Subscription__c where User__c = :UserInfo.getUserId() and Type__c = 'Resource' and Idea_Question_Id__c =:knbID];
            system.debug('====subscription =========='+subscriptions);
            if(subscriptions.isEmpty() == false) {
                delete subscriptions;            
            } else {
                Community_Subscription__c subscription = new Community_Subscription__c();
                subscription.User__c = UserInfo.getUserId();
                subscription.Type__c = 'Resource';
                subscription.Idea_Question_Id__c = knbID;
                insert subscription;                
            }
        } catch (Exception e) {
            system.debug('===subscription===');
        }
        return null;
    }
    
    public Boolean getSubscribedToQuestion() {
        String knbID      = '' + currentArticle.knowledgeArticleId;
        return (Database.countQuery('select count() from Community_Subscription__c  where User__c = \'' + UserInfo.getUserId() + '\' and Type__c = \'Resource\' and Idea_Question_Id__c = \'' + knbID + '\'') > 0);
    }
    
    public pageReference saveComments(){
         errorMsg = false;
         Article_FeedBack__c myFeedbackDetails = new Article_FeedBack__c();
         
         if(body == ''){
             errorMsg = true;
             return null;
         }else{
              try{
                  String knbID    = '' + currentArticle.knowledgeArticleId;
                  myFeedbackDetails.Comment_On_Article__c = body; 
                  myFeedbackDetails.Article_Id__c         = knbID;
                  myFeedbackDetails.Article_Url__c        = 'http://community.marketo.com/MarketoResource?id='+ApexPages.currentPage().getParameters().get('Id');
                  myFeedbackDetails.Article_Name__c       = currentArticle.title; 
                  insert myFeedbackDetails;
                 
              }catch(Exception e) { 
              
              }
         }
         PageReference redirectPage = Page.MarketoResource;
         redirectPage.getParameters().put('id', ApexPages.currentPage().getParameters().get('Id'));
         redirectPage.setRedirect(true);
         return redirectPage;
    }
    
    public Map<String,MarketoDeepDive__kav> getdeepDiveCatgsOfArt(){
        Map<String,MarketoDeepDive__kav> deepDiveCatgsOfArt = new Map<String,MarketoDeepDive__kav>();
        Boolean refresh = true;
        MarketoUserContext context = MarketoUserContext.getContext();
              
        DataCategoryHelper helper = DataCategoryHelper.getHelper('KnowledgeArticleVersion');
        List<MarketoDeepDive__kav> deepDiveArticles = [select KnowledgeArticleId, Title from MarketoDeepDive__kav where Language = 'en_US' and publishstatus='Online' and DeepDiveCategory__c != null];
        
        System.Debug('ApexPages.currentPage().getParameters().get(Id)+++++'+ ApexPages.currentPage().getParameters().get('Id'));
        Resources__kav  currArticleSoql = [select Id, IsVisibleInPkb, Title, knowledgeArticleId, Language, LastPublishedDate from Resources__kav where knowledgeArticleId=:ApexPages.currentPage().getParameters().get('Id') and publishstatus='Online' and Language='en_US' limit 1];
        List<Resources__DataCategorySelection> currentArtDataCatList = [Select ParentId, Id, DataCategoryName, DataCategoryGroupName From Resources__DataCategorySelection Where ParentId =:currArticleSoql.Id];
        System.Debug('currentArtDataCatList1+++++'+currentArtDataCatList);
        Map<String,MarketoDeepDive__kav> deepDiveTitlesToLinks     = new Map<String,MarketoDeepDive__kav>();
        
        for(MarketoDeepDive__kav tempdeepDiveObj : deepDiveArticles ){
            deepDiveTitlesToLinks.put(tempdeepDiveObj.title,tempdeepDiveObj);
        }
       
        deepDiveCatgsOfArt = new Map<String,MarketoDeepDive__kav>();
        
        List <DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
        
        DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
        pair1.setSobject('KnowledgeArticleVersion');
        pair1.setDataCategoryGroupName('Articles');
        
        pairs.add(pair1);
        
        List<Schema.DescribeDataCategoryGroupStructureResult> results = Schema.describeDataCategoryGroupStructures(pairs, false);       
        DataCategory[] topCategs = results.get(0).getTopCategories().get(0).getChildCategories();

        
        for (Resources__DataCategorySelection tempCatgry : currentArtDataCatList){
            String catgLabel = helper.getNameToLabelMap().get(tempCatgry.DataCategoryName);
            System.Debug('MYPARENT '+tempCatgry.DataCategoryName+' '+helper.getTopCategory(topCategs, tempCatgry.DataCategoryName, 'All'));
            String parentCateg = helper.getTopCategory(topCategs, tempCatgry.DataCategoryName, 'All');
            If (deepDiveTitlesToLinks.containsKey(catgLabel)){
                deepDiveCatgsOfArt.put(catgLabel, deepDiveTitlesToLinks.get(catgLabel)); 
            }
            if (deepDiveTitlesToLinks.containsKey(parentCateg)) {
                deepDiveCatgsOfArt.put(catgLabel, deepDiveTitlesToLinks.get(parentCateg)); 
            }
            
        }
        System.Debug('Size==========='+deepDiveCatgsOfArt.size());
        System.Debug('currentArtDataCatList===='+currentArtDataCatList);
        If (deepDiveCatgsOfArt.size()== 0){
          String categLabel = '';
          if (currentArtDataCatList.size() > 0) {
              categLabel = helper.getNameToLabelMap().get(currentArtDataCatList.get(0).DataCategoryName);
              //category = categLabel == null?currentArtDataCatList.get(0).DataCategoryName:categLabel;
          }
        }
        return deepDiveCatgsOfArt;
    }
    
    public List<CommentWrapper> getdisplay_list(){
        Set<Id> userids                     = new set<Id>(); 
        String userBadgeValue               ='';
        String userBadgeValueSecondary      = '';  
        List<CommentWrapper> display_list   = new  List<CommentWrapper>();
        Map<Id,Article_FeedBack__c> articleFeedbackMap = new Map<Id, Article_FeedBack__c>([Select id, Comment_On_Article__c, CreatedBy.FirstName, CreatedBy.LastName, CreatedById,  Article_Id__c, createdDate From Article_FeedBack__c a where Article_Id__c =: currentArticle.knowledgeArticleId order by createddate]); 
        for(Article_FeedBack__c temp: articleFeedbackMap.values()){
            userids.add(temp.CreatedById);
        }
        
        //Added for certification banner
        Map<Id, Boolean> userIdToCertificationMap = GlobalFunctions.getIsCertifiedUserMap(userIds);
        
        Map<Id,User> userList = new Map<Id,User>([Select id, Champion__c, Is_Partner__c, Is_Leader__c, Is_Employee__c, Is_Customer__c, Is_Consultant__c From User u  where id IN : userids]);
        
        Map<Id, Community_Profile__c> userIdToProfileMap = GlobalFunctions.getProfilesForUsers(userIds);
        
        
        for(Article_FeedBack__c temp: articleFeedbackMap.values()){
            string createdDate = GlobalFunctions.formatDate(temp.createdDate);   

            if(userList.containsKey(temp.createdbyId)) {
                user usr = userList.get(temp.createdbyId); 
                userBadgeValue  = ''; userBadgeValueSecondary ='';
                if (usr.Is_Consultant__c) {
                    userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                    userBadgeValue = 'CONSULTANT' ;
                }
                if (usr.Is_Employee__c) {
                    userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                    userBadgeValue = 'EMPLOYEE' ;
                } 
                if (usr.Is_Partner__c) {
                    userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                    userBadgeValue = 'PARTNER' ;
                }            
                if (usr.Champion__c) {
                    userBadgeValueSecondary = userBadgeValue.toLowerCase() ; 
                    userBadgeValue = 'CHAMPION' ;                        
                }
                if(userBadgeValueSecondary.trim() != '') {
                    userBadgeValueSecondary = userBadgeValueSecondary.capitalize() ; 
                }
            }
            Boolean isCertified = FALSE;
            if(userIdToCertificationMap.containsKey(temp.CreatedById)) {
                isCertified = userIdToCertificationMap.get(temp.CreatedById);    
            }
            
            Community_Profile__c profileTemp = new Community_Profile__c();//
            if(userIdToProfileMap.containsKey(temp.CreatedById)){
                profileTemp = userIdToProfileMap.get(temp.CreatedById);
            }
            
            display_list.add(new CommentWrapper(profileTemp,temp,createdDate,userBadgeValue,userBadgeValueSecondary, isCertified));                
            userBadgeValue = ''; userBadgeValueSecondary  = ''; 
        }
        display_list.sort();
        return display_list;
     
    }
    
    global class CommentWrapper implements Comparable {
        public Community_Profile__c  profile                   {get;set;}
        public Article_FeedBack__c   articleFeedback           {get;set;}
        public String                postDate                  {get;set;} 
        public String                posterName                {get;set;}
        public String                userBadgeValue            {get;set;}
        public String                userBadgeValueSecondary   {get;set;}
        public Boolean               isCertifiedUser           {get;set;}
        
        public CommentWrapper(Community_Profile__c profile,Article_FeedBack__c articleFeedback, String postDate,String userBadgeValue,String userBadgeValueSecondary, Boolean isCertified) {
            this.profile                 = profile; 
            this.articleFeedback         = articleFeedback;
            this.postDate                = postDate; 
            this.userBadgeValue          = userBadgeValue;         
            this.userBadgeValueSecondary = userBadgeValueSecondary;                       
            this.isCertifiedUser         = isCertified ;
            
            if (profile != null && profile.Display_Name__c != null && profile.Display_Name__c.trim().length() > 0) {
                this.posterName = profile.Display_Name__c;
            } else {
                this.posterName =  articleFeedback.CreatedBy.FirstName + ' ' +  articleFeedback.CreatedBy.LastName.substring(0, 1);
            }
            
        }
        
        global Integer compareTo(Object compareToItem) {
            CommentWrapper compareToPost = (CommentWrapper) compareToItem;
        
            if (this.articleFeedback.createddate > compareToPost.articleFeedback.createddate) {
                return 1;
            } else {
                return -1;                    
            }
        }                    
        
    }
    
}