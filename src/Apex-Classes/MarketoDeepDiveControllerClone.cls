global class MarketoDeepDiveControllerClone  {

    // Deep Dive article wrapper
    public class DeepDiveArticle {
        public String id                      {get;set;}
        public String knowledgeArticleId      {get;set;}
        public String title                   {get;set;}
        public String summary                 {get;set;}
        public String body                    {get;set;}
        public String category                {get;set;}
        public Map <String, String> subCategoryTreeMap {get;set;}
        
        // constructors
        public DeepDiveArticle(){}
        public DeepDiveArticle (String id, String title, String summary, String Parentid) {
            this.knowledgeArticleId = id; this.title = title; this.body = summary; this.id = Parentid;
        }    
    }

    // Articles to be listed on page
    global class LinkedArticle implements Comparable {
        public String knowledgeArticleId{get;set;}
        public String title{get;set;}
        public String articleType{get;set;}
        public Integer sortOrder{get;set;}
        public LinkedArticle(){}
        public LinkedArticle(String knowledgeArticleId, String title, String articleType, String sortOrder){
         this.knowledgeArticleId = knowledgeArticleId;
         this.title              = title;
         this.articleType        = articleType;
         System.Debug('KNBID__'+knowledgeArticleId);
         try {
             this.sortOrder          = (sortOrder != null) && sortOrder.trim().length() > 0 ? integer.valueOf(sortOrder.trim()):5000;
         }Catch(Exception Ex) {
             this.sortOrder = 5000;
         }
        }

        global Integer compareTo(Object compareToItem) {
            LinkedArticle compareToArt = (LinkedArticle)compareToItem;
            //System.Debug('COMPAREDTO'+compareToArt.knowledgeArticleId);
            //System.Debug('COMPARED'+this.knowledgeArticleId);
            if (sortOrder == compareToArt.sortOrder) {
                return title.toLowerCase().compareTo(compareToArt.title.toLowerCase());
            }else if (sortOrder > compareToArt.sortOrder) {
                 return 1;
            } else {
                return -1;                    
            }
        }        
                
    }
    global class SubCategoryKey implements Comparable {
        public String title {get;set;}

        global Integer compareTo(Object compareToItem) {
            SubCategoryKey compareToKey = (SubCategoryKey)compareToItem;
            //System.Debug('COMPAREDTO'+compareToArt.knowledgeArticleId);
            //System.Debug('COMPARED'+this.knowledgeArticleId);
            // ALN_2012, ALN_2013, ALN_Archive
            if (compareToKey.title.replace('ALN_','').isNumeric() && title.replace('ALN_','').isNumeric()) {
                Integer compareToKeyNum = integer.valueOf(compareToKey.title.replace('ALN_',''));
                Integer comparedKeyNum  = integer.valueOf(title.replace('ALN_',''));
                
                if (compareToKeyNum >= comparedKeyNum  ) {
                    return 1;
                } else {
                    return -1;
                }
            } else if(compareToKey.title.replace('ALN_','').isNumeric()) {
                return 1;
            } else if (title.replace('ALN_','').isNumeric()) {
                return -1;
            } else {
                return compareToKey.title.compareTo(title);
            } 
        }         
    }

    public class SubCategoriesArticlesListWrapper{
        public list<LinkedArticle> linkedArticles{get;set;}
        public Integer getSize(){
            return this.linkedArticles.size();
        }
        
        public SubCategoriesArticlesListWrapper() {
            this.linkedArticles = new List<LinkedArticle>();
        }
        
    }

    public DeepDiveArticle deepDiveArticle{get;set;}
    public List<LinkedArticle>                 howToPlusTopCategoryArticles {get;set;}                
    public List<LinkedArticle>                 bestPracticesPlusTopCategoryArticles{get;set;}         
    public List<LinkedArticle>                 tutorialPlusTopCategoryArticles  {get;set;}            
    public Map <String, SubCategoriesArticlesListWrapper>   howToPlusSubCategoryToArticleMap {get;set;}
    
    public List<String> errorMessages {get;set;}
    public boolean moreBestPracticesAvaiable {get;set;}
    public List<SubCategoryKey> howToPlusSubCategorySortedKeyList {get;set;} 
             
    public MarketoDeepDiveControllerClone(ApexPages.StandardController stdController) {
    
        howToPlusTopCategoryArticles               = new List<LinkedArticle>();     
        bestPracticesPlusTopCategoryArticles       = new List<LinkedArticle>();    
        tutorialPlusTopCategoryArticles            = new List<LinkedArticle>();     
        howToPlusSubCategoryToArticleMap           = new Map <String, SubCategoriesArticlesListWrapper>();
        errorMessages                              = new List<String>();
        howToPlusSubCategorySortedKeyList          = new List<SubCategoryKey>(); 
        
        deepDiveArticle                         = new DeepDiveArticle();
        deepdiveArticle.knowledgeArticleId      = ApexPages.currentPage().getParameters().get('Id');
        MarketoDeepDive__Kav deepDiveCurArticle = [SELECT ID, KnowledgeArticleId,title,article_text__c from MarketoDeepDive__Kav Where PublishStatus = 'online' and  KnowledgeArticleId =:deepdiveArticle.knowledgeArticleId limit 1];
        deepDiveArticle.id                      = deepDiveCurArticle.Id;
        deepDiveArticle.title                   = deepDiveCurArticle.title;
        deepDiveArticle.body                    = deepDiveCurArticle.article_text__c;        
        
        // Fetch Datacategory assigned to this article, there should be only one so, We'll take the first one from list
        List<MarketoDeepDive__DataCategorySelection> tempDataCategs = [Select a.ParentId, a.Id, a.DataCategoryName, a.DataCategoryGroupName From MarketoDeepDive__DataCategorySelection a  Where a.ParentId =:deepdiveArticle.id];        
        for(MarketoDeepDive__DataCategorySelection tempDataCateg : tempDataCategs) {
            deepDiveArticle.category = tempDataCateg.DataCategoryName;
        }
        System.Debug('Top Category'+deepDiveArticle.category);
         
        deepDiveArticle.subCategoryTreeMap = getSubCategoryTreeMap(deepDiveArticle.category);
        //System.Debug('subCategoryTreeMap+++'+deepDiveArticle.subCategoryTreeMap.keyset());
        
        addToMainDataStructure('Article__kav'); // Add list of all articles to be shown
        addToMainDataStructure('Tutorial__kav'); // Add list of all tiiutorials to be shown
        
        // Sort the linkedArticles to be listed
        if (howToPlusTopCategoryArticles.size() > 0)         {howToPlusTopCategoryArticles.sort();}  
        if (bestPracticesPlusTopCategoryArticles.size() > 0) {bestPracticesPlusTopCategoryArticles.sort();}   
        if (tutorialPlusTopCategoryArticles.size() > 0)      {tutorialPlusTopCategoryArticles.sort();}       
        if (deepDiveArticle.subCategoryTreeMap.size() > 0) {
            for (String str : deepDiveArticle.subCategoryTreeMap.keyset()) {
                if (howToPlusSubCategoryToArticleMap.get(str).linkedArticles.size()>0) {
                    howToPlusSubCategoryToArticleMap.get(str).linkedArticles.sort(); 
                }
            }
        }
       // System.Debug('__SORTED_KEYS__'+howToPlusSubCategorySortedKeyList);
        howToPlusSubCategorySortedKeyList.sort();
       // System.Debug('__SORTED_KEYS__'+howToPlusSubCategorySortedKeyList);
        System.Debug('howToPlusTopCategoryArticles DATA'+howToPlusTopCategoryArticles);
        System.Debug('bestPracticesPlusTopCategoryArticles DATA'+bestPracticesPlusTopCategoryArticles);
        System.Debug('tutorialPlusTopCategoryArticles DATA'+tutorialPlusTopCategoryArticles);
        System.Debug('howToPlusSubCategoryToArticleMap DATA'+howToPlusSubCategoryToArticleMap);

        
        
        // Check for error conditions
        // 1. Not categorized in any How to 
        if  (    
                (howToPlusTopCategoryArticles.size() == 0)         &&
                (bestPracticesPlusTopCategoryArticles.size() == 0) &&
                (tutorialPlusTopCategoryArticles.size() == 0)      
            ) {
                errorMessages.add('Oops, No such article in this category!');
        }
        
    }
    
    public void addToMainDataStructure(String articleType){
        // Fetch all articles at How To, Tutorial, Best Practices 
              
        Map<Id, sObject> desiredArticles = new Map<Id, sObject>(); 
        
        if (articleType == 'Article__kav') {
            desiredArticles = new Map<Id, sObject>([SELECT ID, KnowledgeArticleId, title, sort_order__c FROM Article__Kav WHERE PublishStatus='Online' and Language='en_US' WITH DATA CATEGORY Articles__c AT (How_to__c, Tutorial__c, Best_Practice__c)]); 
        } else if (articleType == 'Tutorial__kav') {
            desiredArticles = new Map<Id, sObject>([SELECT ID, KnowledgeArticleId, title, ReCategSortOrder__c FROM Tutorial__Kav WHERE PublishStatus='Online' and Language='en_US' WITH DATA CATEGORY Articles__c AT (How_to__c, Tutorial__c, Best_Practice__c)]); 
        }

        //System.Debug('Desired Articles'+desiredArticles);
            
        // Find the category of all articles under scanner
        //Article__DataCategorySelection
        List<sObject> dataCategories = new List<sObject>();
        if (articleType == 'Article__kav') {
            dataCategories = [Select a.ParentId, a.Id, a.DataCategoryName, a.DataCategoryGroupName From Article__DataCategorySelection a  Where a.ParentId in:desiredArticles.keySet()];                                
        } else if (articleType == 'Tutorial__kav') {
            dataCategories = [Select a.ParentId, a.Id, a.DataCategoryName, a.DataCategoryGroupName From Tutorial__DataCategorySelection a  Where a.ParentId in:desiredArticles.keySet()];                                
        }
        //System.Debug('dataCategories'+dataCategories);
        
        Map<Id, Set<String>> idToCategories = new Map<Id, Set<String>>();
        for (sObject tempCategObj:dataCategories) {
            String parentIdOfCategory = '';
            String categoryName       = '';            
            if (articleType == 'Article__kav') {
                Article__DataCategorySelection tempArtCategSelecObj  =  (Article__DataCategorySelection)tempCategObj;
                categoryName        =  tempArtCategSelecObj.DataCategoryName;
                parentIdOfCategory  =  tempArtCategSelecObj.ParentId;                
            } else if (articleType == 'Tutorial__kav') {
                Tutorial__DataCategorySelection tempArtCategSelecObj  =  (Tutorial__DataCategorySelection)tempCategObj;
                categoryName        =  tempArtCategSelecObj.DataCategoryName;
                parentIdOfCategory  =  tempArtCategSelecObj.ParentId;   
            }

            if(idToCategories.containsKey(parentIdOfCategory)) {
                if (idToCategories.get(parentIdOfCategory) == null) {
                    Set<String> categories = new Set<String>();
                    categories.add(categoryName);
                    idToCategories.put(parentIdOfCategory, categories);
                } else {
                    idToCategories.get(parentIdOfCategory).add(categoryName);
                }
            } else {
                Set<String> categories = new Set<String>();
                categories.add(categoryName);
                idToCategories.put(parentIdOfCategory, categories);
            }
        }
        
        System.Debug('IdTocategories'+idToCategories);
        
        // Loop through the articles and segment them based on their categories
        for (Id tempId: idToCategories.keySet()) {
            LinkedArticle linkedArt;
            if (articleType == 'Article__kav') {
                Article__kav tempArticle   = (Article__kav) desiredArticles.get(tempId);
                linkedArt = new LinkedArticle(tempArticle.KnowledgeArticleId, tempArticle.title, articleType, tempArticle.sort_order__c );                
            } else if (articleType == 'Tutorial__kav') {
                Tutorial__kav tempTutorial = (Tutorial__kav) desiredArticles.get(tempId);
                linkedArt = new LinkedArticle(tempTutorial.KnowledgeArticleId, tempTutorial.title, articleType, tempTutorial.ReCategSortOrder__c);                
            }

            if (idToCategories.get(tempId).contains('How_to') && idToCategories.get(tempId).contains(deepDiveArticle.category)) {
                howToPlusTopCategoryArticles.add(linkedArt);
            } else if (idToCategories.get(tempId).contains('Tutorial') && idToCategories.get(tempId).contains(deepDiveArticle.category)) {
                tutorialPlusTopCategoryArticles.add(linkedArt);
            } else if (idToCategories.get(tempId).contains('Best_Practice') && idToCategories.get(tempId).contains(deepDiveArticle.category)) {
                if (bestPracticesPlusTopCategoryArticles.size()<6) {
                    bestPracticesPlusTopCategoryArticles.add(linkedArt);
                } else {
                    moreBestPracticesAvaiable = true;
                    continue;
                }
            }
            
            // SubCategoriesArticlesListWrapper subCategoryArticleWrapper = new SubCategoriesArticlesListWrapper();
            for(String str : deepDiveArticle.subCategoryTreeMap.keyset()) {
              if (!howToPlusSubCategoryToArticleMap.containsKey(str)){
                  howToPlusSubCategoryToArticleMap.put(str,new SubCategoriesArticlesListWrapper());
                  SubCategoryKey howToPlusSubCategKey = new SubCategoryKey();
                  howToPlusSubCategKey.title          = str;
                  howToPlusSubCategorySortedKeyList.add(howToPlusSubCategKey);                  
              }
              if (idToCategories.get(tempId).contains('How_to') && idToCategories.get(tempId).contains(str)) {
                  howToPlusSubCategoryToArticleMap.get(str).linkedArticles.add(linkedArt);
              }
              if (idToCategories.get(tempId).contains('Best_Practice') && idToCategories.get(tempId).contains(str)){ // Check if subcategory article belongs to best_practices also
                  bestPracticesPlusTopCategoryArticles.add(linkedArt);
              }
            }
        }    
    }     
    
    public Map<String, String> getSubCategoryTreeMap(String topCategory) {
        List<Datacategory> childCategories = DataCategoryHelper.getHelper('knowledgeArticleVersion').getChildCategoryCustom(topCategory);
        Map<String, String> subCategoryTreeMap = new Map<String, String>();
        
        for(Datacategory childCat : childCategories){
            subCategoryTreeMap.put(childCat.getName(),childCat.getName());
        }        
        return subCategoryTreeMap;
    }   
    
    public String getSubCategoriesSearchFilterString() {
        String mainCategoryPlaceHolder = '__MAINCATEGORYPLACEHOLDER__';
        List<String> subCategoriesSearchFilterString = new List<String>();
        if (deepDiveArticle.subCategoryTreeMap.values().size() > 0) {
            for (String tempcateg:deepDiveArticle.subCategoryTreeMap.values()) {
                subCategoriesSearchFilterString.add('('+mainCategoryPlaceHolder+' AND '+tempcateg+')');
            }
        }
        if (subCategoriesSearchFilterString.size() > 0) {
            return '( ('+mainCategoryPlaceHolder+' AND '+deepDiveArticle.category+') OR '+String.join(subCategoriesSearchFilterString,' OR ')+')';
        }
        
        return '( ('+mainCategoryPlaceHolder+' AND '+deepDiveArticle.category+') )';
    }
    
    @isTest(SeeAllData=true)
    public static void testMarketoDeepDiveController() { 
        MarketoDeepDive__kav MarketoDeepDiveObject = new MarketoDeepDive__kav(); 
        MarketoDeepDiveObject.title ='testtitle';
        MarketoDeepDiveObject.UrlName ='testurl'; 
        MarketoDeepDiveObject.IsVisibleInPkb = true;
        MarketoDeepDiveObject.Article_Text__c ='this is test <a href="http://community.marketo.com/MarketoArticle?id=123&test=12">test</a> article';
        insert MarketoDeepDiveObject ;
        
        MarketoDeepDive__kav Article1 = [Select  Id, Article_Text__c, UrlName, Title, KnowledgeArticleId, IsVisibleInPkb From MarketoDeepDive__kav where PublishStatus ='Draft' and  Id =:MarketoDeepDiveObject.Id ];
        KbManagement.PublishingService.publishArticle(Article1.knowledgearticleid, true);
        MarketoDeepDive__kav Article2 = [Select  Id,Article_Text__c, UrlName, IsVisibleInPkb, Title, knowledgeArticleId, Language, LastPublishedDate From MarketoDeepDive__kav where PublishStatus ='Online' and KnowledgeArticleId =:Article1.knowledgearticleid];
        
        MarketoDeepDive__DataCategorySelection datacategory = new MarketoDeepDive__DataCategorySelection();
        datacategory.DataCategoryGroupName = 'Articles';
        datacategory.DataCategoryName = 'Landing_Pages';
        datacategory.ParentId = Article2.Id;
        insert datacategory ;          
        
        MarketoDeepDiveObject = [select Id, knowledgeArticleId,Title,UrlName, IsVisibleInPkb ,Article_Text__c,(select DataCategoryGroupName, DataCategoryName From DataCategorySelections) from MarketoDeepDive__kav where publishstatus='Online' and Language='en_US' and KnowledgeArticleId =:Article2.knowledgearticleid limit 1];
        PageReference pageRef = Page.MarketoDeepDive;     
        pageRef.getParameters().put('Id', MarketoDeepDiveObject.knowledgeArticleId);
        Test.setCurrentPage(pageRef);
        MarketoDeepDiveControllerClone controller1 = new MarketoDeepDiveControllerClone(new ApexPages.StandardController(MarketoDeepDiveObject));        
    }
    
}