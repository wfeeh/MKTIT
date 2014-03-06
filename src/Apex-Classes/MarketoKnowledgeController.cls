global class MarketoKnowledgeController  {
  
    Public List<MarketoDeepDive__kav> MarketoDeepDiveList = new List<MarketoDeepDive__kav>();
    Public List<DeepDiveArticlesList> deepDiveCategoryToArticlesList{get;set;} 
    Public List<DeepDiveArticlesList> deepDiveCat {get;set;}
    public Boolean authorizedUser {get; set;}
    //public Map<String,Integer> caseStatusToNumberOfCases{get;set;}
    private String currUserMunchkinId{get;set;}    
    private Id accId{get;set;}
    private String usrEntitlemntId{get;set;}
    private Id userContactId{get;set;}
    public String userType{get;set;}
    public String entitlementName{get;set;}
    public String contactEmail{get;set;}    
    public List<String> SortedDeepDiveCat {get; set;}
    public list<Article__kav> StartedArticle{get;set;}
    public String preferredLanguage{get;set;}
    public boolean selectDropDown {get;set;}
    public  Map<Integer, List<String>> deepDiveColumnKeysToBePainted{get;set;}
   
    Public Map<String,String> languageKeyToLabel = new Map<String,String>{'en_US'=>'English','fr'=>'French','de'=>'German','pt_BR'=>'Portuguese','es'=>'Spanish'};
   
    public MarketoKnowledgeController(){    
        SortedDeepDiveCat = new List<String>();
        deepDiveColumnKeysToBePainted = new Map<Integer, List<String>>();
        getLangToArticleMap();
        preferredLangOfCurrentUser();
        getpreferredLanguageOfArticle();
        getDeepdiveArticlesMap();
      
    } 
    
    public void preferredLangOfCurrentUser(){
        list<Community_Profile__c > con = [select id , user__r.contact.Preferred_Language__c, user__c from Community_Profile__c where user__c=:UserInfo.getUserId() limit 1];
        if(con.isEmpty()){
            preferredLanguage = 'English';
        }else{
            Map<String ,list<Article__kav>> langToArticleMap = getLangToArticleMap();
            Set<String> langUniqueName = langToArticleMap.keyset();
            if(langUniqueName.size() > 1){
                user usr = [select id, contactid from user where id=:UserInfo.getUserId()];
                list<Contact> cont = [select id , Preferred_Language__c from contact where id=:usr.contactid limit 1];
                if(langUniqueName.contains(cont[0].Preferred_Language__c)){
                    preferredLanguage = cont[0].Preferred_Language__c;
                }else{
                  preferredLanguage = 'English';  
                }
            }else{
                preferredLanguage = 'English'; 
            } 
        }
    }
    
    public void init(){
        system.debug('preferredLanguage-->'+preferredLanguage);
        user usr = [select id, contactid, contact.Preferred_Language__c from user where id=:UserInfo.getUserId()];
        contact contant = [select id, Preferred_Language__c from contact where id=:usr.contactid];
        list<Community_Profile__c > con = [select id , user__r.contact.Preferred_Language__c, user__c from Community_Profile__c where user__c=:UserInfo.getUserId() limit 1];
          if(con.isEmpty()){
             Community_Profile__c cmmPrf = new  Community_Profile__c();
               cmmPrf.user__c  =  UserInfo.getUserId();
               insert cmmPrf ;
          }
          contant.Preferred_Language__c = preferredLanguage;
          update contant; 
       
          /*
        if(con.size() > 0){
           cmmPrf.user__c  =  usr.id;
           cmmPrf.user__r.contactid = usr.contactid;
           cmmPrf.user__r.contact.Preferred_Language__c = preferredLanguage;
           upsert cmmPrf usr.id;
             
            con[0].Preferred_Language__c = preferredLanguage;
            update con;
        }*/
        
    }
    
    
     public List<SelectOption> getpreferredLanguageOfArticle(){
        selectDropDown  = false; 
        List<SelectOption> langOfArticle = new List<SelectOption>();
        Map<String ,list<Article__kav>> langToArticleMap = getLangToArticleMap();
        Set<String> langUniqueName = langToArticleMap.keyset();
        list<String> langUniqueNamelist = new  list<String>();
        langUniqueNamelist.sort();
        for(String temp : langUniqueName){
            langUniqueNamelist.add(temp);
        }
        langUniqueNamelist.sort();
        system.debug('langUniqueNamelist-->'+langUniqueNamelist.size());
        for(String langList: langUniqueNamelist ){
            langOfArticle.add(new SelectOption(langList, langList));  
        }
        if(langUniqueNamelist.size()> 1){
        selectDropDown  = true;
        }
        
        return langOfArticle; 
    }
    
    public Map<String ,list<Article__kav>> getLangToArticleMap(){
        set<string> knowledgearticleIds = new set<string>();
        Map<String , list<Article__kav>> langToArticleMap = new  Map<String , list<Article__kav>>();
        list<Get_Started_KnowledgeArticleId__c> startedid = [ select id,GetStartedKnowledgeArticleId__c from Get_Started_KnowledgeArticleId__c ];
        system.debug('startedid--->'+startedid.size());
        for(Get_Started_KnowledgeArticleId__c temp :startedid){
            knowledgearticleIds.add(temp.GetStartedKnowledgeArticleId__c); 
              
        }
        list<Article__kav> StartedArticle =  [select id, KnowledgeArticleId,Language,Sort_Order__c,Timer__c, title from Article__kav where knowledgeArticleId IN : knowledgearticleIds and publishstatus = 'Online' order by Sort_Order__c ASC]; 
        system.debug('StartedArticle--->'+StartedArticle.size());
        for(Article__kav temp :  StartedArticle ){
        if( langToArticleMap.containsKey(languageKeyToLabel.get(temp.Language))){
               langToArticleMap.get(languageKeyToLabel.get(temp.Language)).add(temp);
           }else{
              list<Article__kav> temp1 = new list<Article__kav>();
              temp1.add(temp);
              langToArticleMap.put(languageKeyToLabel.get(temp.Language),temp1);
           }
        }
       
        system.debug('langToArticleMap-->'+langToArticleMap.size());
        //langToArticleMap.put('English', StartedArticle);
       
        return langToArticleMap;
    }
    
    
    Public Map<String,List<DeepDiveArticlesList>> getDeepdiveArticlesMap(){   
        
        Map<String,List<MarketoDeepDive__kav>> deepDiveCategoryToArticlesMap = new Map<String,List<MarketoDeepDive__kav>>();
        Map<String,List<DeepDiveArticlesList>> deepDiveCategoryToArticlesSortedMap = new Map<String,List<DeepDiveArticlesList>>();       
        marketoDeepDiveList = [Select Id, KnowledgeArticleId, DeepDiveCategory__c, Title, Timer__c , ArticleNumber, Article_Text__c, SubTitle__c, sort_order__C from MarketoDeepDive__kav  where Language = 'en_US' and publishstatus='Online' and DeepDiveCategory__c != null  LIMIT 200];       
        
        deepDiveColumnKeysToBePainted = new Map<Integer, List<String>>();
        
        for(MarketoDeepDive__kav marketoDeepDiveArticle: marketoDeepDiveList){
            if (deepDiveCategoryToArticlesMap.containsKey(marketoDeepDiveArticle.DeepDiveCategory__c)) {
                deepDiveCategoryToArticlesMap.get(marketoDeepDiveArticle.DeepDiveCategory__c).add(marketoDeepDiveArticle);
            } else {
                List<MarketoDeepDive__kav> tempArtList = new List<MarketoDeepDive__kav>();
                tempArtList.add(marketoDeepDiveArticle);
                deepDiveCategoryToArticlesMap.put(marketoDeepDiveArticle.DeepDiveCategory__c, tempArtList);
            }        
        }
       // system.debug('===deepDiveCategoryToArticlesMap=='+deepDiveCategoryToArticlesMap);  
        
        Set<String> tmpDeepDiveArtKeys = deepDiveCategoryToArticlesMap.keySet();         
        System.debug('List======>'+tmpDeepDiveArtKeys);              
               
        for(String tmpDeepDiveArtKey : tmpDeepDiveArtKeys)
        {          
             List<MarketoDeepDive__kav> deepDiveCategoryToArticleValues = deepDiveCategoryToArticlesMap.get(tmpDeepDiveArtKey);
             deepDiveCategoryToArticlesList = new List<DeepDiveArticlesList>();
             if (deepDiveCategoryToArticleValues .size() > 0){
                 system.debug('===========================nishtha====================' + deepDiveCategoryToArticleValues );
                 List<DeepDiveArticlesList> tempArticleList = new List<DeepDiveArticlesList>(); 
                 for(MarketoDeepDive__kav deepDiveCategoryToArticleValue : deepDiveCategoryToArticleValues){ 
                     string sortOrder; 
                               
                     DeepDiveArticlesList tempCategoryToArticles = new DeepDiveArticlesList();
                     tempCategoryToArticles.id                   = deepDiveCategoryToArticleValue.id;
                     tempCategoryToArticles.knowledgeArticleId   = deepDiveCategoryToArticleValue.KnowledgeArticleId; 
                     tempCategoryToArticles.title                = deepDiveCategoryToArticleValue.title; 
                     tempCategoryToArticles.DeepDiveCategory     = deepDiveCategoryToArticleValue.DeepDiveCategory__c; 
                     sortOrder                                   =  deepDiveCategoryToArticleValue.sort_order__C;                     
                     tempCategoryToArticles.sortOrder            = (sortOrder != null) && sortOrder.trim().length() > 0 ? integer.valueOf(sortOrder.trim()):5;                     
                     tempCategoryToArticles.Timer                = deepDiveCategoryToArticleValue.Timer__c; 
                     tempCategoryToArticles.ArticleNumber        = deepDiveCategoryToArticleValue.ArticleNumber; 
                     tempCategoryToArticles.Article_Text         = deepDiveCategoryToArticleValue.Article_Text__C; 
                     tempCategoryToArticles.SubTitle             = deepDiveCategoryToArticleValue.SubTitle__c;                
                     if (tempCategoryToArticles != null){      
                         tempArticleList.add(tempCategoryToArticles);                            
                     }                   
              
                  }                           
                          
                if (tempArticleList.size() > 0 ){
                      deepDiveCategoryToArticlesList.addall(tempArticleList);                     
                } 
             
             } 
            deepDiveCategoryToArticlesList.sort();
              system.debug('==============sorted list================'+deepDiveCategoryToArticlesList); 
          deepDiveCategoryToArticlesSortedMap.Put(tmpDeepDiveArtKey ,deepDiveCategoryToArticlesList);
        } 
        
        getCheckAuthorizedUser();
        Integer numberOfCols  = 3; 
        Integer columnCounter = 0;
        // Initialize clumns to be painted
        deepDiveColumnKeysToBePainted.put(0,new List<String>());
        deepDiveColumnKeysToBePainted.put(1,new List<String>());
        deepDiveColumnKeysToBePainted.put(2,new List<String>());
        
        for(Schema.PicklistEntry temp :MarketoDeepDive__kav.DeepDiveCategory__c.getDescribe().getPicklistValues()) {
            if(deepDiveCategoryToArticlesSortedMap.containsKey(temp.getValue())){
                sortedDeepDiveCat.add(temp.getValue());
               // deepDiveColumnKeysToBePainted.get(Math.mod(columnCounter,numberOfCols)).add(temp.getValue()); 
                //System.Debug('COLUMN__'+Math.mod(columnCounter,numberOfCols));
                deepDiveColumnKeysToBePainted.get(Math.round(columnCounter/numberOfCols)).add(temp.getValue()); 
                System.Debug('COLUMN__'+Math.round(columnCounter/numberOfCols));
            }
            //columnCounter = columnCounter<2?++columnCounter:0;    
            ++columnCounter; // = columnCounter<2?++columnCounter:0;    
            System.Debug('COLUMN_COUNTER__'+columnCounter);
        }     
            
        return deepDiveCategoryToArticlesSortedMap ;
        
    }
    public void getCheckAuthorizedUser() {
        if (userType != 'Standard' || test.isRunningTest()) {
            authorizedUser = true;
            List<User> usrList = [Select u.Username, u.UserType, u.LanguageLocaleKey, u.UserRole.Name, u.UserRoleId, u.Name, u.Contact.Name, u.Contact.FirstName, 
                u.Contact.LastName, u.Contact.AccountId, u.Contact.Is_Authorized_Contact__c, u.ContactId, u.AccountId
                From User u where Id =: UserInfo.getUserId()];
            Id userId = UserInfo.getUserId();
            accId = usrList[0].Contact.AccountId;
            userContactId = usrList[0].ContactId;
            List<User> userList = [select id, Munchkin_ID__c from User where id = :UserInfo.getUserId()];
            if(userList != null && userList.size() > 0) {
                currUserMunchkinId = userList[0].Munchkin_ID__c;               
            }
            List<Entitlement> entList = [Select id, Status, AssetId, AccountId, Type From Entitlement where AccountId = :accId AND Asset.Munchkin_ID__c = :currUserMunchkinId and Status = 'Active' and (Asset.Munchkin_ID__c != null OR Asset.Munchkin_ID__c != '') limit 1];
            if(UserInfo.getUserId() != null && UserInfo.getUserId() != ''){
                List<User>    currentUser = [Select id, ContactId from User Where Id =: UserInfo.getUserId()];
                List<Contact> userContact = [Select email, id from Contact Where Id =: currentUser[0].ContactId];
                if(userContact.isempty() == false)
                    contactEmail              = userContact[0].email;
            }
            if(!entList.isEmpty()) {     
                usrEntitlemntId = entList[0].Id;
                System.debug('usrEntitlemntId==>' + usrEntitlemntId);
                entitlementName = entList[0].Type != '' && entList[0].Type != null?entList[0].Type:'';    
            } 
            if(usrList != null && usrList.size() > 0) {
                Id userContactId = usrList[0].ContactId;
                if(usrList[0].Contact.Is_Authorized_Contact__c != null && usrList[0].Contact.Is_Authorized_Contact__c.equals('No')) {
                    authorizedUser = false;
                }
            }
        }
        //return authorizedUser;
    }
    
    
    global class DeepDiveArticlesList implements Comparable {
        public String knowledgeArticleId{get;set;}
        public String title{get;set;}
        public string DeepDiveCategory{get;set;}
        public Integer sortOrder{get;set;}
        Public String Timer{get;set;}         
        Public String ArticleNumber{get;set;}
        Public String Article_Text{get;set;}
        Public String SubTitle {get;set;}
        Public Id id{get;set;}
        
           public DeepDiveArticlesList (){}
        public DeepDiveArticlesList (Id id,String knowledgeArticleId, String title, String sortOrder,string Timer, string ArticleNumber, string Article_Text, string SubTitle,string DeepDiveCategory){
         this.knowledgeArticleId = knowledgeArticleId;
         this.title              = title;
         this.articleNumber      = articleNumber;
         this.sortOrder          = (sortOrder != null) && sortOrder.trim().length() > 0 ? integer.valueOf(sortOrder.trim()):5000;
         this.Article_Text       = Article_Text;
         this.SubTitle           = SubTitle;
         this.Timer              = Timer;
         this.DeepDiveCategory   = DeepDiveCategory;
         this.id                 = id;
        }

        global Integer compareTo(Object compareToItem) {
            DeepDiveArticlesList compareToDeepDiveList = (DeepDiveArticlesList )compareToItem;
            
            if (sortOrder == compareToDeepDiveList.sortOrder) {
                return title.toLowerCase().compareTo(compareToDeepDiveList.title.toLowerCase());
            }else if (sortOrder > compareToDeepDiveList.sortOrder) {
                 return 1;
            } else {
                return -1;                    
            }
        }      
    }  
       
    @isTest(SeeAllData=true)
    public static void testMarketoKnowledgeController  () {
        //Tutorial__kav MarketoTutorialControllerObject = new Tutorial__kav();
        //MarketoKnowledgeController  = [select Id, knowledgeArticleId,Title,UrlName, IsVisibleInPkb , Tutorial_Article_Text__c,(select DataCategoryGroupName, DataCategoryName From DataCategorySelections) from Tutorial__kav where publishstatus='Online' and Language='en_US' limit 1];
        Test.startTest();
        List<User> logUsr = [SELECT Id,contactId from user Where isportalenabled =true limit 1];
        System.RunAs(logUsr[0])
        {
        PageReference pageRef = Page.MarketoKnowledgeHome;     
        //pageRef.getParameters().put('Id', MarketoTutorialControllerObject.knowledgeArticleId);
        Test.setCurrentPage(pageRef);
        MarketoKnowledgeController controller1 = new MarketoKnowledgeController(); 
        controller1.getDeepdiveArticlesMap(); 
        //pageRef.getParameters().put('Id', MarketoTutorialControllerObject.knowledgeArticleId);
        }
        Test.stopTest();        
    }    

}