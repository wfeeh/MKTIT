public class AdvanceMarketoSearchController extends MarketoBaseController {

    public string  debugVar {get;set;} 

    public Boolean inRecent {get; set;}
    public Boolean inPopular {get; set;}
    public String selectedCategory {get; set;}
    public User sfdcUserProfile{get;set;} 
    
    
    public XMLDom xmlResult;
    
    private transient ApexPages.StandardSetController setCon  {get; private set;} 
    private transient ApexPages.StandardSetController setCon1 {get; private set;} 
    private transient SetActivityClass setprofilecon{get;set;}     
    private transient ApexPages.StandardSetController setCon2 {get; private set;} 
   
    public Map<String, Video__kav> urlNameToVideoMap {get;set;}
    public List<Video__kav> videoList {get;set;}     

    public List<String> searchTypes {get; set;}
    public Integer ideaSearchType {get;set;}
    public Integer discussionSearchType {get;set;}
    public Integer knowledgeSearchType {get;set;}  
    public Integer blogSearchType{get;set;}      
    public Integer profileSearchType{get;set;}    

    public List<SearchResult> allIdeaResults       {get;set;}
    public List<SearchResult> allDiscussionResults {get;set;}
    public List<knowledgeArticleVersion> allKnowledgeResults  {get;set;}
    public List<Community_Profile__c> allProfileResults  {get;set;}
   public List<UserProfiles> profilesUsers {get;set;}
 
    public List<SearchResult> ideaResults       {get;set;}
    public List<SearchResult> discussionResults {get;set;}
    public List<SearchResult> knowledgeResults  {get;set;}
    public List<SearchResult> blogSearchResults {get;set;}
    public List<SearchResult> profileResults {get;set;}
    //public List<Profiles> profiles {get;set;}
   
    /*public Integer pageSize{get;set;}
    public Integer noOfPages{get;set;}
    public Integer pageNumber{get;set;}
    private String baseQuery = '';
    private Integer totalNoOfProfileRecs;*/
    
    public static Integer ideaNumResults {get; set;}
    public static Integer discussionNumResults {get; set;}
    public static Integer knowledgeNumResults {get; set;}
    public static Integer blogNumResults {get; set;}
    public static Integer profileNumResults {get; set;}
   
                
    public Integer ideaResultSize {get; set;}
    public Integer discussionResultSize {get; set;}
    public Integer knowledgeResultSize {get; set;}
    public Integer blogResultSize {get; set;}

    public Integer profileResultSize {get; set;}    
  
    
    //public Integer profileNum{get;set;}
    public Integer pageNum {get; set;}
    public Integer ideaPageNum {get; set;}
    public Integer discussionPageNum {get; set;}
    public Integer knowledgePageNum  {get; set;}
    public Integer blogPageNum  {get; set;}
    public Integer profilePageNum  {get; set;}

    
    public List<RssFeed> blogXmlList{get;set;}       
    public String  searchText {get {return ApexPages.currentPage().getParameters().get('searchText') != null ?ApexPages.currentPage().getParameters().get('searchText') : '';} set;}

    public String searchTypesString {get;set;}
    
    public Boolean hasProfileNextPage{get;set;}
    public Boolean hasProfilePrevPage{get;set;}
    public Boolean hasIdeaNextPage{get;set;}
    public Boolean hasIdeaPrevPage{get;set;} 
    public Boolean hasDiscussionNextPage{get;set;}
    public Boolean hasDiscussionPrevPage{get;set;}
    public Boolean hasKnowledgeNextPage{get;set;}
    public Boolean hasKnowledgePrevPage{get;set;}    
    public Boolean hasBlogNextPage{get;set;}
    public Boolean hasBlogPrevPage{get;set;}    
    public List<Integer>  paginationList{get;set;}
    // public List<Map <String,String>> blogResults{get;set;} 
    public List<RssFeed> blogResults{get;set;}
     
    public boolean testExecution;
    public boolean gettestExecution(){return this.testExecution;}
   
    public Map<ID, String> srchIdTOChampMap {get;set;}
    public List <ID> myCommunityProfileIDS {get;set;}
   

    public void settestExecution(){
        this.testExecution = true;
    }     
           
    public AdvanceMarketoSearchController() {
      testExecution = false;
      searchTypesString = ApexPages.currentPage().getParameters().get('searchType');
      //System.debug('__SEARCH_TYPES_STRING__'+searchTypesString);      
      if (searchTypesString == ''){searchTypesString = 'Ideas__Knowledge__Discussion__Blogs__Profiles';}
      
      searchTypes = new List<String>();
      //System.debug('__SEARCH_TYPES_STRING__'+searchTypesString);
      if(searchTypesString != null){
          searchTypes = searchTypesString.split('__');
      }

      String currentPageURL =  ApexPages.currentPage().getUrl();
      if (currentPageURL == null) currentPageURL=''; 
      ideaNumResults       = currentPageURL.contains('AdvanceMarketoSearchResults')?5:10;
      discussionNumResults = currentPageURL.contains('AdvanceMarketoSearchResults')?5:10;
      knowledgeNumResults  = currentPageURL.contains('AdvanceMarketoSearchResults')?5:10;
      blogNumResults       = currentPageURL.contains('AdvanceMarketoSearchResults')?5:10;
      profileNumResults    = currentPageURL.contains('AdvanceMarketoSearchResults')?5:10;

      //system.debug('blogNumResults--->'+blogNumResults);     
      ideaResultSize = 0;
      discussionResultSize = 0;
      knowledgeResultSize  = 0;      
      blogResultSize  = 0;   
      profileResultSize  = 0;   

      String ideaPg = ApexPages.currentPage().getParameters().get('ideaPg');
      ideaPageNum   = ideaPg == null ? 1 : Integer.valueOf(ideaPg);
       
      String discussionPg = ApexPages.currentPage().getParameters().get('discussionPg');
      discussionPageNum   = discussionPg == null ? 1 : Integer.valueOf(discussionPg);

      String knowledgePg = ApexPages.currentPage().getParameters().get('knowledgePg');
      knowledgePageNum   = knowledgePg == null ? 1 : Integer.valueOf(knowledgePg);  
      
      String blogPg = ApexPages.currentPage().getParameters().get('blogPg');
      blogPageNum   = blogPg== null ? 1 : Integer.valueOf(blogPg);
      
      String profilePg = ApexPages.currentPage().getParameters().get('profilePg');
      profilePageNum   = profilePg == null ? 1 : Integer.valueOf(profilePg);        
     
  
      // system.debug('blogPageNum--->'+blogPageNum);              
      //searchType = ApexPages.currentPage().getParameters().get('searchType');
      searchText = ApexPages.currentPage().getParameters().get('searchText');
      
      getVideos();
     // blogResults = blogResults(searchText);
    }
    
    
        //Code for usertype at the profile page By jaimal
    public void getUserProfileBadges(List<ID> myIDS)
    {        
        List<User> myUsrPrfBadgList = new List<User>();        
        myUsrPrfBadgList  = [SELECT Is_Partner__c, Champion__c, Is_Employee__c, Is_Consultant__c,Is_Customer__c,Is_Leader__c FROM USER WHERE ID IN :myIDS ];         
        srchIdTOChampMap = new Map<Id,String>();        
        for(User sfdcUserProfile : myUsrPrfBadgList)        
        {
            System.debug('sfdcUserProfile =>' + sfdcUserProfile);        
            Map<String, Boolean> profile_badge_value  = new map<String, Boolean>();
            profile_badge_value.put('partner',    sfdcUserProfile.Is_Partner__c);
            profile_badge_value.put('champion',   sfdcUserProfile.Champion__c);
            profile_badge_value.put('employee',   sfdcUserProfile.Is_Employee__c);
            profile_badge_value.put('consultant', sfdcUserProfile.Is_Consultant__c);
            profile_badge_value.put('leader', sfdcUserProfile.Is_Leader__c);
            String userBadgeValue  = '';            
            for(String profile_badge_val : profile_badge_value.keySet()) {
                System.debug('profile_badge_val=>' + profile_badge_val);
                if (profile_badge_value.get(profile_badge_val) == true) {
                   userBadgeValue += profile_badge_val + ', ';
                }
            } 
            if(userBadgeValue.endsWith(', ')){
                userBadgeValue = userBadgeValue.substring(0,userBadgeValue.length()-2);                
            }                         
            System.debug('srchIdTOChampMap=>' + srchIdTOChampMap + sfdcUserProfile.ID);

            srchIdTOChampMap.put(sfdcUserProfile.ID,userBadgeValue);                                              
        }
        
        //return userBadgeValue;      
    }
    
    //Code for usertype at the profilesearch By jaimal
    
    

    
    
    
    public List<RssFeed> getXmlContent(string searchText){
    
        blogResults = new List<RssFeed>();
        blogXmlList = new List<RssFeed>();
        
        String username = 'marketo';
        String password = 'thoughtleadership';
        String blog_results_html ='';
        
        HttpRequest req = new HttpRequest();
        req.setEndPoint(System.Label.marketoBlogUrl+'/page/'+ blogPageNum +'?feed=rss2&s='+searchText);
        req.setMethod('GET');
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        HttpResponse res = null;
        Http http = new Http();
        
        if(testExecution) {  // Code for Testexecution from test code
            xmlResult = new XMLDom();
        }else{
            res = http.send(req);
            
            if(res.getBody()!=null) {
                blog_results_html = res.getBody();
                //System.debug('blog_results_html -->'+blog_results_html );
            }else{
                return blogXmlList;
            }
            xmlResult = new XMLDom(blog_results_html );
            //System.debug('dom-->'+xmlResult );
        }
        
        for( xmldom.element e: xmlResult.getElementsByTagName('item')){
            RssFeed rf=new RssFeed();
            rf.description=e.getValue('description');
            rf.title =e.getValue('title');
            rf.link = e.getvalue('link');
            rf.pubDate = e.getvalue('pubDate');
            rf.creator= e.getvalue('creator');
            blogXmlList.add(rf);
        }   
        //System.debug('xml-->'+blogXmlList);
        //System.debug('xml-->'+blogXmlList.get(0).title);
        return blogXmlList;
    }

    public class RssFeed {
        public String title {get; set;}
        public String description{get; set;}
        public string link{get;set;}
        public String pubDate{get;set;}
        public String creator{get;set;}
    }
 
    public void refresh(Boolean requery) {
        blogSearchResults = new List<SearchResult>();
        datetime myDateTime = datetime.now();
        
        if (blogSearchType == 1) { //For Blog Results
            List<RssFeed> blogpageResults = new List<RssFeed>();
            for( Integer index=0;index < blogResults.size(); index++) {
                blogpageResults.add(blogResults.get(index));
                if((ApexPages.currentPage().getUrl().contains('AdvanceMarketoSearchResults')) && (index==4)){
                    break;
                }
            }
            blogResultSize = blogResults.size();
            if(blogResults.size() >0){
               hasBlogNextPage = true;
            } 
            If(blogpagenum !=1){
               hasBlogPrevPage = true;
            }
            for(RssFeed rf: blogpageResults){
               String publishDate = rf.pubDate.substring(0, 17);
               blogSearchResults.add(new SearchResult(rf.link,rf.description,rf.title,rf.creator,publishDate,myDateTime ));
            } 
            //paginationList = getPaginationList(blogPageNum, blogResults.size(), blogNumResults);
            //System.debug('paginationList -->'+paginationList );  
            //System.debug('blogNumResults-->'+blogNumResults); 
        }
        
        if (setCon != null) {  // For Idea Results
            if (ideaSearchType == 1) {
            //System.debug('__ResultSize__'+setcon.getResultSize());
            setcon.setpageNumber(ideaPageNum);
            hasIdeaNextPage = setcon.getHasNext();
            hasIdeaPrevPage = setcon.getHasPrevious();
            ideaResults = new List<SearchResult>();
                for (Idea i : (List<Idea>) setCon.getRecords()) {
                   ideaResults.add(new SearchResult(i.id, i.body, i.title,i.categories,'', i.lastmodifieddate!=null?i.lastmodifieddate:i.createddate));
                } 
            }
            paginationList = getPaginationList(ideaPageNum, setcon.getResultSize(), ideaNumResults);
            //System.debug('paginationList -->'+paginationList );  
        }
        
        if(setcon1 != null) {
            if (discussionSearchType == 1) {
                setcon1.setpageNumber(discussionPageNum);
                hasDiscussionNextPage = setcon1.getHasNext();
                hasDiscussionPrevPage = setcon1.getHasPrevious();
                discussionResults = new List<SearchResult>();
                for (Question q2 : (List<Question>) setCon1.getRecords()) {
                    discussionResults.add(new SearchResult(q2.id, q2.body, q2.title,null,'', q2.lastmodifieddate!=null?q2.lastmodifieddate:q2.createddate));
                }
            }
            paginationList = getPaginationList(discussionPageNum, setcon1.getResultSize(), discussionNumResults);

        }
               List <ID> myIDS = new List<ID>();

       if(setprofilecon != null) {
            
            if (profileSearchType == 1) {
                //setconprofile.setpageNumber(profilePageNum);
                hasProfileNextPage = setprofilecon.gethasnext();
                hasProfilePrevPage = setprofilecon.getHasPrevious();
                profileResults = new List<SearchResult>();
                System.Debug('============='+setprofilecon.sobjectList1.size());
                for (UserProfiles p2 : setprofilecon.getRecords()) {
                    System.Debug('============='+p2.userId);
                    myIDS.Add(p2.userId);
                    System.debug('myIDS=>' + myIDS);
                    //System.debug('=========Is_Employee__c====='+p2.User__r.Is_Employee__c);
                    profileResults.add(new SearchResult(p2.firstname,p2.company,p2.commNickname,p2.website,p2.profilePic,p2.userId,p2.comProfileId,p2.userType,p2.isActive));
                }
            }
            paginationList = getPaginationList(profilePageNum, setprofilecon.getResultSize(), profileNumResults);
            getUserProfileBadges(myIDS);
        }

        /*
        if(allKnowledgeResults != null) {
            if (knowledgeSearchType == 1) {
                List<knowledgeArticleVersion> pageResults = new List<knowledgeArticleVersion>();
                Integer beg_index = (knowledgePageNum-1)*knowledgeNumResults;
                Integer index;
                for(index=beg_index;index<beg_index+knowledgeNumResults; index++) {
                    if(index<allKnowledgeResults.size()){
                        pageResults.add(allKnowledgeResults.get(index));
                    } 
                }

                knowledgeResults = new List<SearchResult>();
                hasKnowledgeNextPage = index<allKnowledgeResults.size()?true:false;
                hasKnowledgePrevPage = index==1?false:true;
                for (KnowledgeArticleVersion art : pageResults) {
                  // Check if its Article or Video or tutorial
                  String kCategory = '';
                  String kId = '';
                  Id artId = art.id;
                  String artIdString = artId;
                  if (artIdString.startsWith('ka0')){
                     kCategory = 'article';
                  } else if(artIdString.startsWith('ka2')) {
                     kCategory = 'tutorial';
                  } else if(artIdString.startsWith('ka4')) {
                     kCategory = 'video';
                  }
                  knowledgeResults.add(new SearchResult(art.knowledgeArticleId, art.summary, art.title, kCategory,'', art.lastmodifieddate!=null?art.lastmodifieddate:art.createddate));
                  paginationList = getPaginationList(knowledgePageNum, allKnowledgeResults.size(), knowledgeNumResults);
                }
            }
        } 
        */       
              
    }
    
    public PageReference searchResults() {
      
      ideaSearchType       = 0;
      discussionSearchType = 0;
      knowledgeSearchType  = 0;
      blogSearchType       = 0;
      profileSearchType    = 0;

      
      for(string stype:searchTypes){
          if(stype == 'Ideas'){
              ideaSearchType = 1;
          }
          if(stype == 'Discussion') {
              discussionSearchType = 1;
          }
          if(stype == 'Knowledge') {
              knowledgeSearchType = 1;
          }
          if(stype == 'Blogs'){
              blogSearchType = 1;
          }
           if(stype == 'Profiles'){
              profileSearchType = 1;
          }
          if (stype == 'all') {
             ideaSearchType = 1;discussionSearchType = 1;knowledgeSearchType = 1;blogSearchType = 1;profileSearchType = 1;
             searchTypesString = 'Ideas__Knowledge__Discussion__Blogs__Profiles';
          }
      }
      
      if(blogSearchType == 1){
          blogResults = getXmlContent(searchText);
          //System.debug('blogResults --->'+blogResults );
          blogResultSize = blogResults.size();
          //System.debug('blogResultSize--->'+blogResultSize );
      }

      String trimSearchType = searchText.Trim();

      if (searchText.length() > 1) {
          // Check if Search Query already exists in Query DBase
          List<searchQuery__c> sQList = [SELECT Id, searchString__c, relevancy__c  FROM searchQuery__c WHERE searchString__c = :trimSearchType ];
          //System.debug('__QUERIES_LIST__'+sQList);  
          //System.debug('__QUERIES_LIST__SIZE__'+sQList.size()); 
      
          if (sQList.size() >= 1) {  // If Search Query Already Exists, just increment the relevancy counter and  the object
              searchQuery__c sQuery = sQList.get(0); 
              sQuery.relevancy__c += 1;
              update  sQuery;
              //System.debug('__updated_query_object__'+sQuery);  
          } else {
              searchQuery__c searchQuery;  
              searchQuery = new searchQuery__c();
              searchQuery.searchString__c = searchText;
              //System.debug('__NewSearchQueryObject__'+searchQuery.searchString__c);
              //System.debug('__searchText__'+searchText);
              searchQuery.relevancy__c = 1;
              insert searchQuery; 
              //System.debug('__NewSearchQueryObject__'+searchQuery);
          }        
         
          if(ideaSearchType == 1) {
             
              // New code
              //System.debug('__SEARCH_TEXT__'+searchText);
              string searchQuery = 'FIND {'+searchText+'} IN ALL FIELDS RETURNING Idea(Id, title, body, categories, createddate, lastmodifieddate)';
              //System.debug('__SEARCH_QUERY__'+searchQuery);
              List<List<SObject>> searchList = search.query(searchQuery);                  
              //List<List<SObject>> searchList = [FIND :searchText IN ALL FIELDS RETURNING Idea(Id)];
              Idea [] ideasList = ((List<Idea>)searchList[0]);
              Idea [] sortedIdeasList = new List<Idea>();
              //sortedIdeasList = sortIdeaByRelevancy(ideasList); NEED TO FIX LATER
              sortedIdeasList = ideasList;
 
              if (sortedIdeasList != null && sortedIdeasList.size() > 0) {            
                //setCon = new ApexPages.StandardSetController([select id, title, body, categories, createddate, lastmodifieddate from idea where id in :similarIds order by lastModifieddate desc]);  
                setCon = new ApexPages.StandardSetController(sortedIdeasList);                   
                setCon.setPageSize(ideaNumResults);
                ideaResultSize = setCon.getResultSize();
             
              }
          }
                    if(profileSearchType == 1) {
 //Jaimal October 18 2012
              List<String> AA = new List<String>();
              AA.add('PowerCustomerSuccess');
              AA.add('CustomerSuccess');
              AA.add('CSPLitePortal');
              //string finalQuery='FIND {'+searchtext+'} IN ALL FIELDS RETURNING User(Name,ID,CompanyName,CommunityNickname,Is_Employee__c  WHERE UserType in:AA),Community_Profile__c(Id,Company_Name__c,User__r.Is_Employee__c,Profile_Picture_ID__c,User__c,Website__c,Display_name__c)';
              string finalQuery='FIND {'+searchtext+'} IN ALL FIELDS RETURNING Community_Profile__c(Id,Company_Name__c,User__r.Is_Employee__c,Profile_Picture_ID__c,User__c,Website__c,Display_name__c,User__r.IsActive,User__r.LastLogindate)';
              System.debug('--finalQuery--'+finalQuery);
              List<List<SObject>> searchList = search.query(finalQuery);
              System.debug('U_P_SOBJECT'+searchList);
              List<UserProfiles> profilesUsers = new List<UserProfiles>();
              Map<Id,UserProfiles> profilesUsersMap = new Map<Id,UserProfiles>();
              List<Id> userLoginList = new list<Id>();
               for(List<SObject> st:searchList){
                  for(SObject stinner:st){
                        UserProfiles profile = new UserProfiles();                        
                        if (stinner instanceof Community_profile__c){
                            Community_profile__c comm_profile = (Community_profile__c)stinner;
                            profile.firstName     = ' ';
                            profile.company       = comm_profile.Company_Name__c;
                            profile.commNickname  = comm_profile.Display_name__c;
                            System.debug('+++profile.commNickname+++'+profile.commNickname);
                            profile.website       = comm_profile.Website__c;
                            profile.profilePic    = comm_profile.Profile_Picture_ID__c;
                            profile.userId        = comm_profile.User__c;
                             System.debug('+++profile.userId+++'+profile.userId);
                            profile.comProfileId  = comm_profile.Id;
                            profile.isEmployee    = comm_profile.User__r.Is_Employee__c;
                            profile.isActive      = comm_profile.User__r.IsActive;
                            //User u = new User();
                            //u = [SELECT LastLoginDate from User WHERE ID =: profile.userId];
                            //profile.lastLoginDate = u.LastLoginDate;
                            System.Debug('value of Last Login date'+profile.lastLoginDate);
                            //System.Debug('value of Last Login date'+profile.lastLoginDate);
                            if(profile.isActive == true){                            
                                userLoginList.Add(profile.userId);
                                profilesUsersMap.put(profile.userID,profile);

                            /*    Integer i;
                                Date dateTimetoDate;
                                Date currentDate;
                                currentDate = System.today();
                                dateTimetoDate = (profile.lastLoginDate).date();
                                System.debug('DIfference'+ dateTimetoDate.daysBetween(currentDate));
                                i = dateTimetoDate.daysBetween(currentDate);
                                System.Debug('Value of i'+i);
                                if(i<=180){
                                    userLoginList.Add(profile.userId);
                                    profilesUsersMap.put(profile.userID,profile);
                                }*/
                            }                                                                                  
                        }
                        //profilesUsers.add(profile);                       
                    }
               }                                              
               DateTime currTime = DateTime.Now();
               currTime = currTime - 180;
               List<User> form = [SELECT ID, LastLoginDate FROM User WHERE Id in :userLoginList AND LastLoginDate > :currTime ORDER BY LastLoginDate DESC];
               System.Debug('!!!!form!!!!'+form);                                                                                                                          
               for(User fieldName : form){
                   System.debug('fieldName.LastLoginDate=>' + fieldName.Id + fieldName.LastLoginDate);                                                        
                   profilesUsers.Add(profilesUsersMap.get(fieldName.Id));
               }               
               //profilesUsers = profilesUsersMap.values();                                                           
               List<UserProfiles> sortedProfileList = new List<UserProfiles>();
               //sortedProfileList =  sortProfileByRelevancy(profilesUsers);                                    
               System.Debug('===profilesUsers==='+sortedProfileList );
               //setprofilecon = ApexPages.StandardSetController(profilesUsers);
               setprofilecon = new SetActivityClass(profilesUsers,profilePageNum,profileNumResults); 
               System.debug('------setprofilecon ----' + setprofilecon );
               //setprofilecon.setPageSize(ProfileNumResults);  
               ProfileResultSize = setprofilecon.getResultSize();
               System.debug('====ProfileResultSize===='+ProfileResultSize );
          }
    
  //Jaimal October 18 2012

          if(discussionSearchType == 1) {
              Question q = new Question();
         
              // New code
              string searchQuery = 'FIND {'+searchText+'} IN ALL FIELDS RETURNING Question(Id, title, body, createddate, lastmodifieddate)';
              //System.debug('__SEARCH_QUERY__'+searchQuery);
              List<List<SObject>> searchList = search.query(searchQuery);              
              Question [] qsnsList = ((List<Question>)searchList[0]);
              Question [] sortedQsnList = new List<Question>();
              //sortedQsnList = sortQsnByRelevancy(qsnsList);  NEED TO FIX  LATER
              sortedQsnList = qsnsList;           
              //System.debug('__________Qsns_Search_List________'+qsnsList);  

              if (sortedQsnList != null && sortedQsnList.size() > 0) {            
                //setCon1 = new ApexPages.StandardSetController([select id, title, body, createddate, lastmodifieddate from        question where id in :similarIds order by lastModifieddate desc]);                      
                setCon1 = new ApexPages.StandardSetController(sortedQsnList);
                setCon1.setPageSize(discussionNumResults);  
                discussionResultSize = setCon1.getResultSize();
                
              }
              //System.debug('Search Discussion results '+similarIds);     
      
          }
          /*
          if(knowledgeSearchType == 1){
           
              string searchQuery = 'FIND {"'+searchText+'"} IN ALL FIELDS RETURNING KnowledgeArticleVersion (id, knowledgeArticleId, title, summary, createddate, lastmodifieddate  WHERE PublishStatus=\'online\' order by LastModifiedDate desc)';
              System.debug('__SEARCH_QUERY__'+searchQuery);
              List<List<SObject>> searchList = search.query(searchQuery);
              KnowledgeArticleVersion [] artList = ((List<KnowledgeArticleVersion>)searchList[0]);
              //System.debug('__________art_Search_List________'+artList);  

          
              //List<KnowledgeArticleVersion> knwList       = [select id, title, summary, createddate, lastmodifieddate from KnowledgeArticleVersion where id in :similarIds ];
              List<KnowledgeArticleVersion> sortedKnwList = new List<KnowledgeArticleVersion> ();
              //sortedKnwList = sortKnowledgeMapByRelevancy(artList); // Default sort by relevancy
              sortedKnwList = artList;
              //sortKnowledgeByViewCount(artList);
              if (ApexPages.currentPage().getParameters().get('sortby') == 'relevancy') {
                  sortedKnwList = sortKnowledgeMapByRelevancy(artList);
              }
              if (ApexPages.currentPage().getParameters().get('sortby') == 'viewcount') {
                  sortedKnwList = sortKnowledgeByViewCount(artList);
              }
              
              if(sortedKnwList.size()==0) { // In-case Complete phrase search does not return anything
                  searchList = [FIND :searchText IN ALL FIELDS RETURNING KnowledgeArticleVersion (id, knowledgeArticleId, title, summary, createddate, lastmodifieddate  WHERE PublishStatus='Online' order by LastModifiedDate desc)];
                  artList = ((List<KnowledgeArticleVersion>)searchList[0]);
                  sortedKnwList = artList;                              
              }
              
              if (sortedKnwList != null && sortedKnwList.size() > 0) {            
                //setCon2 = new ApexPages.StandardSetController(sortedKnwList);                      
                //setCon2.setPageSize(knowledgeNumResults);
                allKnowledgeResults = sortedKnwList;
                //knowledgeResultSize = setCon2.getResultSize(); 
                knowledgeResultSize = sortedKnwList.size();
              }
          }
          */
                    
      }

      refresh(true);
      return null;      
    }
    
    public List<Idea> sortIdeaByRelevancy(List<Idea> ideaList) {
      Map<Id, Integer>  IdToFrequency = new Map<Id, Integer>();
      List<Id> sortedIds = new List<Id>();
      
      for(Idea id_itr:ideaList) {
                           
          // Count pattern match  
          pattern myPattern = pattern.compile(searchText);
          matcher myMatcher = myPattern.matcher(id_itr.Title+' '+id_itr.body);
          Integer frequency = 0;
          while (myMatcher.find()) {
              //System.debug('__PATTERN_MATCH__'+myMatcher);
              frequency++;                  
          }
          IdToFrequency.put(id_itr.Id, frequency);
          sortedIds.add(id_itr.Id);
      }
      //System.debug('__idToFrequency__'+idToFrequency); 

      //Sort the ids
      Integer iindex = 0;Integer jindex = 0;
      for(iindex=0; iindex<sortedIds.size(); iindex++) {
          for(jindex=iindex; jindex<sortedIds.size(); jindex++) {
              if (idtoFrequency.get(sortedIds.get(iindex)) < idToFrequency.get(sortedIds.get(jindex))) {
                  Id tempId;
                  tempId = sortedIds.get(iindex);
                  sortedIds.set(iindex, sortedIds.get(jindex));
                  sortedIds.set(jindex, tempId);
                  //  System.debug('__NEW_ELEMENT__'+sortedids.get(iindex));
                  //  System.debug('2 List size '+sortedIds.size()+' jindex '+jindex);
              }
              //System.debug('3 List size '+sortedIds.size()+' jindex '+jindex);
          }
       } 

       List<Idea> sortedIdeaList = new List<Idea> ();
           
       for(Id id_itr:sortedIds) {
           for(Idea idea:ideaList) {
               if(idea.Id == id_itr) {
                   sortedIdeaList.add(idea);
                   //system.debug('kav__'+idea);
                   break;
               }
           }
       }
       
       return sortedIdeaList;             
    }
        
    public List<Question> sortQsnByRelevancy(List<Question> qsnList) {
      Map<Id, Integer>  IdToFrequency = new Map<Id, Integer>();
      List<Id> sortedIds = new List<Id>();
      
      for(Question id_itr:qsnList) {
                           
          // Count pattern match  
          pattern myPattern = pattern.compile(searchText);
          matcher myMatcher = myPattern.matcher(id_itr.Title+' '+id_itr.body);
          Integer frequency = 0;
          while (myMatcher.find()) {
              //System.debug('__PATTERN_MATCH__'+myMatcher);
              frequency++;                  
          }
          IdToFrequency.put(id_itr.Id, frequency);
          sortedIds.add(id_itr.Id);
      }
      //System.debug('__idToFrequency__'+idToFrequency); 

      //Sort the ids
      Integer iindex = 0;Integer jindex = 0;
    
      for(iindex=0; iindex<sortedIds.size(); iindex++) {
          for(jindex=iindex; jindex<sortedIds.size(); jindex++) {
              //System.debug('1 List size '+sortedIds.size()+' jindex '+jindex);
              if (idtoFrequency.get(sortedIds.get(iindex)) < idToFrequency.get(sortedIds.get(jindex))) {
                  //System.debug('__OLD_ELEMENT__'+sortedids.get(iindex));
                  Id tempId;
                  tempId = sortedIds.get(iindex);
                  sortedIds.set(iindex, sortedIds.get(jindex));
                  sortedIds.set(jindex, tempId);
              }
              //System.debug('3 List size '+sortedIds.size()+' jindex '+jindex);
          }
       } 

       List<Question> sortedQsnList = new List<Question> ();
           
       for(Id id_itr:sortedIds) {
           for(Question qsn:qsnList) {
               if(qsn.Id == id_itr) {
                   sortedQsnList.add(qsn);
                   //system.debug('kav__'+qsn);
                   break;
               }
           }
       }
       
       return sortedQsnList;             
    } 
             
    /* 
    public String currentSection { get { return MarketoUserContext.getContext().currentSection; } }
    */
        public class UserProfiles{
            public string firstname;
            public string company;
            public string commNickname;
            public string website;
            public string profilePic;
            public string userId;
            public string comProfileId;
            public boolean isEmployee;
            public string userType;
            public boolean isActive;
            public DateTime LastLoginDate;                 
    }
    
    
        public class SetActivityClass {
        public integer pagenumber{get;set;}
        public integer totalpages{get;set;}
        public integer pagesize{get;set;}
        public list<UserProfiles> sobjectList1{get;set;}
        public integer profilePageNum1 {get;set;}
        public integer profileSize1 {get;set;} 
        public integer profileNumResults1 {get;set;}
          public SetActivityClass(List<UserProfiles> sobjectList,Integer profilePageNum,Integer profileNumResult){
             pagenumber           = profilePageNum  ;
             pagesize             = profileNumResult ;
             sobjectList1         = sobjectList ;
             System.Debug('===sobjectList==='+sobjectList.size());
             totalpages           = Integer.valueof(math.ceil((double)sobjectList1.size()/(double)pagesize ));
             System.Debug('--------------'+totalpages) ;
             }
             public SetActivityClass(){                
             }
             public boolean gethasprevious(){
                return (pagenumber != 1);
             }
             public boolean gethasnext(){
                return (pagenumber != totalpages);
             }
             public pagereference Previous(){
                if(gethasprevious())
                    pagenumber --;
                    return null;
             }
             public pagereference next(){
                if(gethasnext())
                    pagenumber ++;
                    return null;
             }
             public list<UserProfiles> getRecords(){
                list<UserProfiles> Sactivity = new list<UserProfiles>();
                 System.Debug('===sobjectList==='+sobjectList1.size());      
                for(integer counter2=(pagenumber-1)*pagesize;counter2<(math.min(pagenumber*pagesize,sobjectList1.size()));counter2++){
                    Sactivity.add(sobjectList1.get(counter2));
                }
            return Sactivity;
            }
            public integer getResultSize(){
                 integer profileSize1 = this.sobjectList1.size();
                 return profileSize1; 
             }
        /*
          public void setpageNumber(Integer profilePageNum){
          this.profilePageNum1 = profilePageNum;  
         }
         
         public void setPageSize(integer profileNumResult){
            this.profileNumResults1 = profileNumResult;
         }*/
    }

    
    
    

    public class SearchResult {
            public String Web{get; set;}

      public String id {get; set;}
      public String body {get; set;}
      public String formatDt {get; set;}
      public String shortBody {get; set;}
      public String title {get; set;}
      public String categories {get; set;}
      public String pubDate{get; set;}
      public String firstname{get; set;}
      public String company{get; set;}
      public String commNickname{get; set;}
      public String website{get; set;}
      public String profilePic{get; set;}
      public String userId{get; set;}
      public String comProfileId{get; set;}
      public String userType{get; set;}
      public Boolean isActive{get; set;}

      
      public SearchResult(String id, String body, String title, String categories,String pubDate, DateTime dt) {
        
        this.id = id;
        this.body = body;
        this.title = title;
        this.categories = categories;
        this.pubDate= pubDate;
        this.shortBody = GlobalFunctions.getShortBody(body);
        
            formatDt = dt.date().format() + ' ' +
                (dt.hour() > 12 ? dt.hour()-12 : dt.hour()) + ':' +
                (dt.minute() < 10 ? '0' + String.valueOf(dt.minute()) : String.valueOf(dt.minute())) + ' ' +
                (dt.hour() >= 12 && dt.hour() <= 24 ? ' PM' : ' AM'); 
      }
     public SearchResult(String id,String Web, String body, String title, String categories,String pubDate, DateTime dt) {
        
        this.id = id;
        this.body = body;
        this.title = title;
        this.categories = categories;
        this.pubDate= pubDate;
        this.Web=Web;
        this.shortBody = GlobalFunctions.getShortBody(body);
        
            formatDt = dt.date().format() + ' ' +
                (dt.hour() > 12 ? dt.hour()-12 : dt.hour()) + ':' +
                (dt.minute() < 10 ? '0' + String.valueOf(dt.minute()) : String.valueOf(dt.minute())) + ' ' +
                (dt.hour() >= 12 && dt.hour() <= 24 ? ' PM' : ' AM'); 
      }
      public SearchResult(String firstname,String company,String commNickname,String website,String profilePic,String userId,String comProfileId,String userType,Boolean isActive) {
          this.firstname    = firstname;
          this.company      = company;
          this.commNickname = commNickname; 
          this.website      = website;
          this.profilePic   = profilePic;
          this.userId       = userId;
          this.comProfileId = comProfileId;
          this.userType     = userType;
          this.isActive     = isActive;    
        }

    }
    
    public List<Integer> getPaginationList(Integer curPageNum, Integer totalRecords, Integer pagesize) {
        List<Integer> pagination_list = new List<Integer>();
        //System.debug('TotalRecords '+totalRecords+' pageSize'+pagesize);
        
        Double lastPage  = math.ceil(Double.valueof(totalRecords)/Double.valueof(pagesize));
        for (Integer pgno=curPageNum-3; pgno<curPageNum; pgno++) {
           if (pgno >=1) {
             pagination_list.add(pgno);
           } 
        }
        pagination_list.add(curPageNum);
        for (Integer pgno=curPageNum+1; pgno<curPageNum+3; pgno++) {
           if (pgno <= lastPage) {
             pagination_list.add(pgno);
           } 
        }      
        //System.debug('__PAGINATION__'+curPageNum+' '+totalRecords+' '+lastPage+' ==== '+pagination_list);
        pagination_list.sort();
        return  pagination_list; 
            
    }
    
    public void getVideos(){
      videoList = [select Video_URL__c, UrlName, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus from Video__kav where PublishStatus='online' order by Sort_Order__c asc];
      urlNameToVideoMap = new Map<String, Video__kav>();
        for(Video__kav video:videoList){
          urlNameToVideoMap.put(video.UrlName, video);
        }    
    }    
    
    public static testMethod void myUnitTest() {
      PageReference pg = Page.AdvanceMarketoSearchResults; 
      pg.getParameters().put('searchType', 'Discussion__Ideas__Knowledge__Blogs__Profiles');
      pg.getParameters().put('searchText', 'marketo');
      pg.getParameters().put('sortby', 'relevancy');
      

      Id [] fixedSearchResults= new Id[11];
      fixedSearchResults[0] = 'ka0P000000004gFIAQ'; // ISSUE WITH SFDC :) http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_testing_SOSL.htm
      fixedSearchResults[1] = 'ka0P000000004gPIAQ';
      fixedSearchResults[2] = 'ka2P000000000GnIAI';
      fixedSearchResults[3] = 'ka4P000000000L0IAI';
      fixedSearchResults[4] = '906P000000000iQIAQ';
      fixedSearchResults[5] = '087P0000000CeyCIAS';

      fixedSearchResults[6]  = '08750000000HnpbAAC';
      fixedSearchResults[7]  = '90650000000PKj2AAG';
      fixedSearchResults[8]  = 'ka050000000L6T2AAK';
      fixedSearchResults[9]  = 'ka250000000Kzc2AAC';
      fixedSearchResults[10] = 'ka4500000008PbnAAE';
      
      Test.setFixedSearchResults(fixedSearchResults);     
      Test.setCurrentPage(pg);

      pg.getParameters().put('searchType', 'all');
      pg.getParameters().put('searchText', 'marketo');
      pg.getParameters().put('sortby', 'relevancy');
      
      AdvanceMarketoSearchController c = new AdvanceMarketoSearchController();  
      AdvanceMarketoSearchController.SetActivityClass c1 = new AdvanceMarketoSearchController.SetActivityClass();  
      AdvanceMarketoSearchController.RssFeed c2 = new AdvanceMarketoSearchController.RssFeed();  
      
      c.setTestExecution();    
      c.searchResults();  
 
      Test.setFixedSearchResults(fixedSearchResults);     
      Test.setCurrentPage(pg);

      pg.getParameters().put('searchType', 'all');
      pg.getParameters().put('searchText', 'marketo');
      pg.getParameters().put('sortby', 'relevancy');
      
      
      c.setTestExecution();    
      c.searchResults();  
      
       
    }    
    

}