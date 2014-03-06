public class MarketoKnowledgeNavigateController  {
    
    public Boolean inRecent {get; set;}
    public Boolean inPopular {get; set;}
    
    public Map<String, Video__kav> urlNameToVideoMap {get;set;}
    public List<Video__kav> videoList {get;set;}    
       
    private transient ApexPages.StandardSetController setCon  {get; private set;} 
    public Integer knowledgeSearchType {get;set;}   
    public List<knowledgeArticleVersion> allKnowledgeResults  {get;set;}
    public Integer knowledgeResultSize {get; set;}
    public Integer knowledgePageNum  {get; set;}
    public Integer knowledgeNumResults {get;set;}
    public Integer pageNum {get; set;}
    public Boolean hasKnowledgeNextPage{get;set;}
    public Boolean hasKnowledgePrevPage{get;set;}    
    public List<Integer>  paginationList{get;set;}
    public List<SearchResult> knowledgeResults  {get;set;}
    public string tabType{get;set;}
    public Double totalNumOfPages{get;set;} 


    public MarketoKnowledgeNavigateController  () {
        knowledgeNumResults = 10;
        knowledgeResultSize  = 0;    
        String knowledgePg = ApexPages.currentPage().getParameters().get('knowledgePg');  
        knowledgePageNum   = knowledgePg == null ? 1 : Integer.valueOf(knowledgePg);
        String tabSelected = ApexPages.currentPage().getParameters().get('tab');
        tabType   = tabSelected == null ? 'recent' : tabSelected;
 
        //getVideos();
        
        searchResults();

    }
    
    public String selectedCategory {
        get {
            if (ApexPages.currentPage().getParameters().get('category2') != null && ApexPages.currentPage().getParameters().get('category2') != '')
                return ApexPages.currentPage().getParameters().get('category2');
            else if (ApexPages.currentPage().getParameters().get('category') != null && ApexPages.currentPage().getParameters().get('category') != '')
                return ApexPages.currentPage().getParameters().get('category');
            else if (ApexPages.currentPage().getParameters().get('topcategory') != null && ApexPages.currentPage().getParameters().get('topcategory') != '')
                return ApexPages.currentPage().getParameters().get('topcategory');
            return '';
        }
    } 

    public PageReference searchResults() {
           
              /* @Algorithm 
                 -> Get Three level of Categories in Request
                 -> For the last category fetch the results below that category
                 -> For the two categories above+all category get the results
                 -> Merge the results in above two steps and sort them by sorting criteria
              */ 
               
              String categoryL1 =  ApexPages.currentPage().getParameters().get('topcategory');
              String categoryL2 =  ApexPages.currentPage().getParameters().get('category');
              String categoryL3 =  ApexPages.currentPage().getParameters().get('category2');
           
              // Fetch results AT for Level1, level2 and level3, All
              List<KnowledgeArticleVersion> kvL1 = new List<KnowledgeArticleVersion>();
              List<KnowledgeArticleVersion> kvL2 = new List<KnowledgeArticleVersion>();
              List<KnowledgeArticleVersion> kvL3 = new List<KnowledgeArticleVersion>();
              List<KnowledgeArticleVersion> kvL4 = new List<KnowledgeArticleversion>();


              if (categoryL1 == 'root') {  
                  if (ApexPages.currentPage().getParameters().get('tab') == 'recent') {
                      kvL1 = Database.query('Select id, ArticleType, knowledgeArticleId , title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus=\'online\' and Language=\'en_US\' and ArticleType in ( \'Article__kav\',\'Hardware_Article__kav\',\'Tutorial__kav\',\'Issue_Solution_Article__kav\',\'Video__kav\',\'MarketoDeepDive__kav\') order by LastModifiedDate desc');
                  } else {
                      LIST<KnowledgeArticleViewStat>  kviews = Database.query('Select k.ParentId From KnowledgeArticleViewStat k where k.channel=\'ALLChannels\'  order by k.NormalizedScore DESC');
                      SET<ID> kvIDs = new SET<ID>();
                      for(KnowledgeArticleViewStat kvst:kviews) {
                          kvIDs.add(kvst.ParentId);
                      }
                      //System.Debug('KVIDS___'+kvIDs);    
                      kvL1 = Database.query('Select id, ArticleType, knowledgeArticleId, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus=\'online\' and Language=\'en_US\' and ArticleType in ( \'Article__kav\',\'Hardware_Article__kav\',\'Tutorial__kav\',\'Issue_Solution_Article__kav\',\'Video__kav\',\'MarketoDeepDive__kav\')  and knowledgeArticleId IN:kvIDs');
                  }
              }/* DEPRECATED
               else {
                  if (categoryL1 != null && categoryL1 != '') {
                      if (categoryL1 != selectedCategory) {
                          kvL1 = Database.query('Select id, ArticleType, knowledgeArticleId, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus=\'online\' and Language=\'en_US\' and ArticleType in ( \'Article__kav\',\'Hardware_Article__kav\',\'Tutorial__kav\',\'Issue_Solution_Article__kav\',\'Video__kav\',\'MarketoDeepDive__kav\')  WITH Data Category Articles__c at '+categoryL1+'__c order by LastModifiedDate desc');
                      } else {
                          kvL1 = Database.query('Select id, ArticleType, knowledgeArticleId, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus=\'online\' and Language=\'en_US\' and ArticleType in ( \'Article__kav\',\'Hardware_Article__kav\',\'Tutorial__kav\',\'Issue_Solution_Article__kav\',\'Video__kav\',\'MarketoDeepDive__kav\')  WITH Data Category Articles__c below '+categoryL1+'__c order by LastModifiedDate desc');
                      }
                  }   
                  if (categoryL2 != null && categoryL2 != '') {
                      if (categoryL2 != selectedCategory) {
                          kvL2 = Database.query('Select id,ArticleType, knowledgeArticleId, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus=\'online\' and Language=\'en_US\' and ArticleType in ( \'Article__kav\',\'Hardware_Article__kav\',\'Tutorial__kav\',\'Issue_Solution_Article__kav\',\'Video__kav\',\'MarketoDeepDive__kav\')  WITH Data Category Articles__c at '+categoryL2+'__c order by LastModifiedDate desc');
                      } else {
                          kvL2 = Database.query('Select id, ArticleType, knowledgeArticleId, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus=\'online\' and Language=\'en_US\' and ArticleType in ( \'Article__kav\',\'Hardware_Article__kav\',\'Tutorial__kav\',\'Issue_Solution_Article__kav\',\'Video__kav\',\'MarketoDeepDive__kav\')  WITH Data Category Articles__c below '+categoryL2+'__c order by LastModifiedDate desc');
                      }
                  }   
                  if (categoryL3 != null && categoryL3 != '') {
                      if (categoryL3 != selectedCategory) {
                          kvL3 = Database.query('Select id, ArticleType, knowledgeArticleId, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus=\'online\' and Language=\'en_US\' and ArticleType in ( \'Article__kav\',\'Hardware_Article__kav\',\'Tutorial__kav\',\'Issue_Solution_Article__kav\',\'Video__kav\',\'MarketoDeepDive__kav\')  WITH Data Category Articles__c at '+categoryL3+'__c order by LastModifiedDate desc');
                      } else {
                          kvL3 = Database.query('Select id, ArticleType, knowledgeArticleId, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus=\'online\' and Language=\'en_US\' and ArticleType in ( \'Article__kav\',\'Hardware_Article__kav\',\'Tutorial__kav\',\'Issue_Solution_Article__kav\',\'Video__kav\',\'MarketoDeepDive__kav\')  WITH Data Category Articles__c below '+categoryL3+'__c order by LastModifiedDate desc');
                      }
                  }                                            
              }*/
              
              List<Article__DataCategorySelection> aDCSList = [Select a.Parent.KnowledgeArticleId, a.DataCategoryName From Article__DataCategorySelection a];
              List<Id> allArtIds = new List<Id>(); // id for articles at ALL category
              for(Article__DataCategorySelection adcs:aDCSList) {
                  if (adcs.DatacategoryName == 'All') {
                      allArtIds.add(adcs.Parent.KnowledgeArticleId);
                      //System.debug('__ALL_ART_IDS__'+allArtIds);
                  }
              }
              // Fetch results under above ids
              String publishStatus = 'Online';
              String language = 'en_US';
              System.debug('__ALL_ART_IDS__'+allArtIds);
               //kvL4 = [Select id,  knowledgeArticleId, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus='Online' and Language='en_US' and  knowledgeArticleId in :allArtIds order by LastModifiedDate desc];
               kvL4 = [Select id, ArticleType, knowledgeArticleId, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion WHERE PublishStatus='Online' and Language='en_US' and ArticleType in ( 'Article__kav','Hardware_Article__kav','Tutorial__kav','Issue_Solution_Article__kav','Video__kav','MarketoDeepDive__kav') and knowledgeArticleId in :allArtIds order by LastModifiedDate desc];

               
              List<KnowledgeArticleVersion> kv = new List<KnowledgeArticleVersion>();

              kv.addAll(kvL3);
              kv.addAll(kvL2);
              kv.addAll(kvL1);
              kv.addAll(kvL4);

              //System.debug('__________art_Search_List________'+kvL1);  
              //System.debug('__________art_Search_List________'+kvL2);  
              //System.debug('__________art_Search_List________'+kvL3);  
              //System.debug('__________art_Search_List________'+kvL4);  
           
              //System.debug('__________art_Search_List________'+kv);  
              List<KnowledgeArticleVersion> sortedkvList = new List<KnowledgeArticleVersion>();
              if (ApexPages.currentPage().getParameters().get('tab') == 'mostviewed'){
                  sortedkvList = sortKnowledgeByViewCount(kv);
              } else {
                  sortedkvList = kv;
              }
              
              setCon = new ApexPages.StandardSetController(sortedkvList);
              setCon.setPageSize(knowledgeNumResults);  
              knowledgeResultSize = setCon.getResultSize();
              //System.debug('__SIZE__'+knowledgeResultSize);
              
              refresh(true);              
              return null;         

   }
   
    public void refresh(Boolean requery) {
        
        if (setCon != null) {
            System.debug('__ResultSize__'+setcon.getResultSize());
            setcon.setpageNumber(knowledgePageNum);
            hasKnowledgeNextPage = setcon.getHasNext();
            hasKnowledgePrevPage = setcon.getHasPrevious();
            knowledgeResults = new List<SearchResult>();
            for (KnowledgeArticleVersion art : (List<KnowledgeArticleVersion>) setCon.getRecords()) {
                  System.debug('__KNIDS__'+art);
                  // Check if its Article or Video or tutorial or Isse/Solution
                  String kCategory = '';
                  String kId = '';
                  Id artId = art.KnowledgeArticleId;
                  String artIdString = artId;
                  if (artIdString.startsWith('kA0')){
                     kCategory = 'article';
                  } else if(artIdString.startsWith('kA2')) {
                     kCategory = 'tutorial';
                  } else if(artIdString.startsWith('kA3')) {
                     kCategory = 'Issue/Solution Article';
                  } else if(artIdString.startsWith('kA4')) {
                     kCategory = 'video';
                     artId = art.Id;
                  } else if(artIdString.startsWith('kA5')) {
                     kCategory = 'MarketoDeepDive';
                     artId = art.Id;
                  }
                  System.debug('__kCategory__ '+kCategory );
                  String aricleId = String.valueOf(art.KnowledgeArticleId);
                  knowledgeResults.add(new SearchResult(artId, art.summary, art.title, kCategory, art.lastmodifieddate!=null?art.lastmodifieddate:art.createddate));
                  System.debug('__ADDED_'+knowledgeResults);
                  paginationList = getPaginationList(knowledgePageNum, setCon.getResultSize(), knowledgeNumResults);
            }
            System.debug('__Results__'+knowledgeResults);
            paginationList = getPaginationList(knowledgePageNum, setcon.getResultSize(), knowledgeNumResults);
        }
    }
    
    public List<Integer> getPaginationList(Integer curPageNo, Integer totalResults, Integer pagesize) {
         try {
            List<Integer> paginationList = new List<Integer>(); 
            totalNumOfPages = math.ceil(Double.valueof(totalResults)/Double.valueof(pagesize));
            System.Debug('totalNumOfPages++++'+totalNumOfPages);
            System.Debug('curPageNo+++'+curPageNo);
            Integer index;
            If(curPageNo < 4 ){
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
                    If(jindex >= totalNumOfPages){
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
                If(curPageNo == totalNumOfPages-3){tempNum = 4;}
                If(curPageNo == totalNumOfPages-2){tempNum = 5;}
                If(curPageNo == totalNumOfPages-1){tempNum = 6;}
                If(curPageNo == totalNumOfPages)  {tempNum = 7;}
                for (index=curPageNo-tempNum;index<curPageNo;index+=1) {
                    if(index<=0) {
                        continue;  
                    }
                    paginationList.add(index);
                }
                paginationList.add(curPageNo);
                Integer jindex;      
                for (jindex=curPageNo+1;jindex<=totalNumOfPages+2;jindex+=1) {
                    if(jindex >= totalNumOfPages){
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
        list<Integer> defaultList = new list<Integer> {1,2,3,4,5};
        return defaultList; 
        }
    }
    public class SearchResult {
      
      public String id {get; set;}
      public String body {get; set;}
      public String formatDt {get; set;}
      public String shortBody {get; set;}
      public String title {get; set;}
      public String categories {get; set;}
      
      public SearchResult(String id, String body, String title, String categories, DateTime dt) {
        
        this.id = id;
        this.body = body;
        this.title = title;
        this.categories = categories;
        this.shortBody = GlobalFunctions.getShortBody(body);
        
            formatDt = dt.date().format() + ' ' +
                (dt.hour() > 12 ? dt.hour()-12 : dt.hour()) + ':' +
                (dt.minute() < 10 ? '0' + String.valueOf(dt.minute()) : String.valueOf(dt.minute())) + ' ' +
                (dt.hour() >= 12 && dt.hour() <= 24 ? ' PM' : ' AM'); 
      }
    }   
   
    public PageReference updateType() {
      return null;
    }
   
    public String categoryName0 {
      get {return DataCategoryHelper.getHelper('KnowledgeArticleVersion').getNameToLabelMap().
            get(ApexPages.currentPage().getParameters().get('topcategory'));}
    }
    /* DEPRECATED
    public String categoryName1 {
      get {return DataCategoryHelper.getHelper('KnowledgeArticleVersion').getNameToLabelMap().
            get(ApexPages.currentPage().getParameters().get('category'));}
    }
   
    public String categoryName2 {
      get {return DataCategoryHelper.getHelper('KnowledgeArticleVersion').getNameToLabelMap().
            get(ApexPages.currentPage().getParameters().get('category2'));}
    }
     */  
    public List<KnowledgeArticleVersion> sortKnowledgeByViewCount(List<KnowledgeArticleVersion> artList) {

        List<Id> knIds = new List<Id>();
        List<Id> sortedIds = new List<Id>();
        
        for(KnowledgeArticleVersion id_itr:artList) {
          knIds.add(id_itr.knowledgeArticleId);  
          sortedIds.add(id_itr.knowledgeArticleId);  
        }   
        List<KnowledgeArticleViewStat> kavs = [Select k.ParentId, k.NormalizedScore From KnowledgeArticleViewStat k where k.ParentId in:knIds and k.channel='AllChannels'];
        //System.debug('__KnowlegdeArtviewStat__'+kavs);
        
        Map<Id,Double> idToView = new Map<Id, Double>();
        for(KnowledgeArticleViewStat kav:kavs) {
            idToView.put(kav.ParentId, kav.NormalizedScore);
        }
        // System.debug('__KnowlegdeArtviewStat__'+idToView);
        //Sort the ids
        Integer iindex = 0;Integer jindex = 0;
  
        for(iindex=0; iindex<sortedIds.size(); iindex++) {
          for(jindex=iindex; jindex<sortedIds.size(); jindex++) {
              //System.debug('1 List size '+sortedIds.size()+' jindex '+jindex);
              if (idToView.get(sortedIds.get(iindex)) <= idToView.get(sortedIds.get(jindex))) {
                  //System.debug('__OLD_ELEMENT__'+sortedids.get(iindex));
                  Id tempId = sortedIds.get(iindex);
                  sortedIds.set(iindex, sortedIds.get(jindex));
                  sortedIds.set(jindex, tempId);
                  //System.debug('__NEW_ELEMENT__'+sortedids.get(iindex));
                  //  System.debug('2 List size '+sortedIds.size()+' jindex '+jindex);
              }
              //System.debug('3 List size '+sortedIds.size()+' jindex '+jindex);
          }
        }   
        List<KnowledgeArticleVersion> sortedKnwList = new List<KnowledgeArticleVersion> ();
           
        for(Id id_itr:sortedIds) {
           for(KnowledgeArticleVersion kav:artList) {
               if(kav.knowledgeArticleId == id_itr) {
                   sortedKnwList.add(kav);
                  // system.debug('kav__'+kav);
                   break;
               }
           }
        }
        /*
       for(KnowledgeArticleVersion kav:artList) {
           System.debug('Unsorted__'+kav);
       }
       
       for (KnowledgeArticleVersion kav:sortedKnwList) {
           System.debug('Sorted__'+kav);
       }*/
       
       return sortedKnwList;             
    } 
     
    public void getVideos(){
      videoList = [select Video_URL__c, UrlName, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus from Video__kav where PublishStatus='online' and Language='en_US' order by Sort_Order__c asc];
      //System.debug('List values '+videoList);
      /*Map<UrlName, Video__kav> IdToVideoMap = new Map<UrlName, Video__kav>([select UrlName, Video_URL__c, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus from Video__kav where PublishStatus='online' order by Sort_Order__c asc]);*/    
      urlNameToVideoMap = new Map<String, Video__kav>();
        for(Video__kav video:videoList){
          urlNameToVideoMap.put(video.UrlName, video);
        }    
      //System.debug('Map values '+urlNameToVideoMap);      
      //System.debug('Title value '+vidtitle);    
    }  
          
       
}