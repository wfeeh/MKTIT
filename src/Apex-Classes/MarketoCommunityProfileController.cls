public class MarketoCommunityProfileController extends MarketoBaseController {
 
    public String profileUserId{get;set;} 
    public User currentLoggedUser{get;set;} 
    public User isEmployeeUser  {get;set;} 
    public User sfdcUserProfile{get;set;} 
    public Community_Profile__c userProfile {get; private set;}
    public String  GrpLeaderLabel{get;set;}   
    public Boolean hasNextPage{get;set;}  
    public Boolean hasPrevPage{get;set;}
    public Integer totalTestRecords{get;set;}
    
    // Badgeville variables
    public BOOLEAN other_partner_supported_instnce{get;set;}
    public BOOLEAN isPastContestWinner{get;private set;}    
    public BOOLEAN isContestRunning{get;private set;}

    // Activity variables
    public String  currentActivityFilter{get;set;}
    public Integer currentPageNum{get;set;}
    public Final Integer MAX_NO_OF_RECORDS_PER_PAGE = 10;
    public Final String  DEFAULT_ACTIVITY_FILTER    = 'Subscription';
    public Map<String, ActivityConfigurationWrapper> filterToActConfWrpprMap{get;set;}
    public List <Activity> activities {get;set;}
    public List <Integer>  paginationList{get;set;}
    public Date currentDate{get;set;}
    
    public MarketoCommunityProfileController ()
    {
        settingbadgeVilleStatusForLogdUser();
        
    }
    public PageReference init() {
        
        currentDate = Date.Today();                
        profileUserId            = ApexPages.currentPage().getParameters().get('id');        
        other_partner_supported_instnce =  GlobalFunctions.getPartner_Supported_Status(profileUserId);
        isContestRunning                = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').IsContestRuning__c;
        isPastContestWinner             = isPastContestWinner(profileUserId);
       
        try {
           userProfile = [select Id, Display_Name__c, Company_Name__c, Title__c, Location__c, Website__c,CRM__c,
                    Customer_Since__c,About_Me__c, Date_I_Started_Using_Marketo__c,Date_I_became_customer__c,Facebook__c, LinkedIn__c, Twitter__c, Profile_Picture_ID__c,Member_of_user_group__c,Expertise_in_Marketo__c,What_I_want_to_learn_more_about__c,Who_I_am_marketing_to__c,User__r.Contact.Preferred_Language__c  from Community_Profile__c where User__c = :profileUserId];
           // Fix the socialmedia URLS
           userProfile.Facebook__c = fixUrl(userProfile.Facebook__c);
           userProfile.Twitter__c  = fixUrl(userProfile.Twitter__c);
           userProfile.LinkedIn__c = fixUrl(userProfile.LinkedIn__c);
           userProfile.Website__c  = fixUrl(userProfile.Website__c);
         }catch(Exception ex){
            userProfile = new Community_Profile__c();
         } 
         
         //profile =  userProfile;
         sfdcUserProfile = [select Id, Name, AccountId, ContactId, FirstName, LastName, Is_Consultant__c, Is_Customer__c, Is_Employee__c, Is_Partner__c, Is_Leader__c,
                   Champion__c, Professional__c, Enterprise__c, Spark__c from User
                   where Id = : profileUserId LIMIT 1];
        
         if(sfdcUserProfile.Is_Leader__c == true) {
             GrpLeaderLabel = ' Leader ';     
         } else {
             GrpLeaderLabel = ' Member ';     
         }  
         
         // Get current logged in user            
         currentLoggedUser = [select Id,TimezoneSidKey, Country__c ,City, State from User where Id = :ApexPages.currentPage().getParameters().get('id')];                       
        
         isEmployeeUser  =   [Select Id, Is_Employee__c from  User where id=:UserInfo.getUserId()];        
         // If Empty display name in Profile custom object add it from User table
         if (userProfile.Display_Name__c == null || userProfile.Display_Name__c.trim().length() < 1) {
             userProfile.Display_Name__c = sfdcUserProfile.FirstName + ' ' + sfdcUserProfile.LastName.substring(0, 1);
         }
      
         try{
           // Credit user for Profile points in Bville if mandatory fields are filled
           if(userProfile.Display_Name__c != Null && userProfile.Company_Name__c!= Null && userProfile.Title__c!= Null
           && userProfile.Profile_Picture_ID__c != Null && userProfile.Website__c != Null && userProfile.CRM__c != Null && userProfile.Member_of_user_group__c != Null
           && userProfile.Date_I_became_customer__c != Null && userProfile.Location__c != Null &&  userProfile.Expertise_in_Marketo__c != Null &&  userProfile.What_I_want_to_learn_more_about__c != Null){
                //BadgeVilleWebServiceCallout bville = new BadgeVilleWebServiceCallout();bville.badgvilleFillProfile();
                BadgeVilleWebServiceCallouts.badgvilleFillProfile(); 
               
           }
         }catch (Exception e) {
            
         }
         
         // Initialize activities configuration wrapper object
         filterToActConfWrpprMap = new Map<string, ActivityConfigurationWrapper>();
         filterToActConfWrpprMap.put ('Idea',          new ActivityConfigurationWrapper('Idea', 'My Ideas Created', GlobalFunctions.getTotalsObjectsByCreatedById('Idea', profileUserId)));
         filterToActConfWrpprMap.put ('Subscription',  new ActivityConfigurationWrapper('Subscription', 'Subscribed discussion',getTotalsObjectsByCreatedById('Subscription', profileUserId)));// __WILL_FIX_THIS_LATER__
         filterToActConfWrpprMap.put ('Reply',         new ActivityConfigurationWrapper('Reply', 'My Question Replies', GlobalFunctions.getTotalsObjectsByCreatedById('Reply', profileUserId)));
         filterToActConfWrpprMap.put ('Vote',          new ActivityConfigurationWrapper('Vote', 'My Idea Votes', getTotalsObjectsByCreatedById('Vote', profileUserId)));// __WILL_FIX_THIS_LATER__
         filterToActConfWrpprMap.put ('IdeaComment',   new ActivityConfigurationWrapper('IdeaComment', 'My Idea Comments', GlobalFunctions.getTotalsObjectsByCreatedById('IdeaComment', profileUserId)));
         filterToActConfWrpprMap.put ('Question',      new ActivityConfigurationWrapper('Question', 'My Questions',     GlobalFunctions.getTotalsObjectsByCreatedById('Question', profileUserId)));


         currentActivityFilter = DEFAULT_ACTIVITY_FILTER;
         currentPageNum        = 1;
         // Load Default filter activities
         activities     = loadActivities (DEFAULT_ACTIVITY_FILTER, currentPageNum, MAX_NO_OF_RECORDS_PER_PAGE, profileUserId);
         paginationList = createPaginationList(filterToActConfWrpprMap.get(currentActivityFilter).totalNumberOfRecords, currentPageNum, MAX_NO_OF_RECORDS_PER_PAGE);        
        
         return null;
         
    }
    
    public Map<String, List<String>> getTagFieldMap(){
        profileUserId            = ApexPages.currentPage().getParameters().get('id');  
        Map<String, List<String>> tagFieldMap = new Map<String, List<String>>();
        list<Community_Profile__c>   userProfile = [Select id, Who_I_am_marketing_to__c, Expertise_in_Marketo__c,What_I_want_to_learn_more_about__c from Community_Profile__c where User__c = :profileUserId limit 1];
        system.debug('userProfile --<'+userProfile);
        if(userProfile.size() > 0){
           String expertiseInMarketo = userProfile[0].Expertise_in_Marketo__c;
            if(expertiseInMarketo != null && expertiseInMarketo !=''){
                list<String> expertiseInMarketoList = expertiseInMarketo.split(' ## ');
                tagFieldMap.put('Expertise in Marketo',expertiseInMarketoList );
            }
            String whoIAmMarket = userProfile[0].Who_I_am_marketing_to__c;
            if(whoIAmMarket != null && whoIAmMarket !=''){
                List<String> whoIAmMarketList = whoIAmMarket.split(' ## ');
                tagFieldMap.put('Who I Market To',whoIAmMarketList);
            }
            String whatIWantToLearn = userProfile[0].What_I_want_to_learn_more_about__c;
            if(whatIWantToLearn != null && whatIWantToLearn !=''){
                List<String> whatIWantToLearnList = whatIWantToLearn.split(' ## ');
                tagFieldMap.put('What I want to learn more about',whatIWantToLearnList );
            }
            system.debug('tagFieldMap-->'+tagFieldMap);
            
            return tagFieldMap;
        }else{
            return tagFieldMap;
        }
    }
    
    public List<Activity> loadActivities(String filter, Integer pageNum, Integer numberOfRecords, String createdById) {
        Integer offset = (pageNum-1) * numberOfRecords;
        List <Activity> activities = new List<Activity>();
        currentPageNum = pageNum;
        System.Debug('++filter++'+filter);
        
        // Load activities based upon the type requested
        if (filter == 'Idea') {
            List<Idea> test = new List<Idea>();
            test = GlobalFunctions.getIdeasForProfile(createdById, offset, numberOfRecords);
            System.Debug('test.size()+++++++'+test.size());
            for (Idea idea : GlobalFunctions.getIdeasForProfile(createdById, offset, numberOfRecords)) {
                Long createdDateTime = idea.CreatedDate.getTime();
                Activity activity = new Activity('Idea',null, idea.Id, idea.Title, GlobalFunctions.getShortBody(idea.Body), idea.CreatedDate);
                activities.add(activity);
            }
        } else if (filter == 'IdeaComment') {
            for (IdeaComment ideaComment : GlobalFunctions.getCommentsForProfile(createdById, offset, numberOfRecords)) {
                Long createdDateTime = ideaComment.CreatedDate.getTime();
                Activity activity = new Activity('Comment',null, ideaComment.Idea.Id, ideaComment.Idea.Title, GlobalFunctions.getShortBody(ideaComment.CommentBody), ideaComment.CreatedDate);    
                activities.add(activity);
            }
        } else if (filter == 'Question') {
            for (Question question : GlobalFunctions.getQuestionsForProfile(createdById, offset, numberOfRecords)) {
                Long createdDateTime = question.CreatedDate.getTime();
                Activity activity    = new Activity('Question',null, question.Id, question.Title, GlobalFunctions.getShortBody(question.Body), question.CreatedDate);
                activities.add(activity);
            }
        } else if (filter == 'Reply') {
            for (Reply reply : GlobalFunctions.getRepliesForProfile(createdById, offset, numberOfRecords)) {
                Long createdDateTime = reply.CreatedDate.getTime();
                Activity activity = new Activity('Reply',null, reply.Question.Id, reply.Question.Title, GlobalFunctions.getShortBody(reply.Body), reply.CreatedDate);
                activities.add(activity);
            }
        }
        else if (filter == 'Vote') {
            System.Debug('VoteForProfile(createdById, offset,numberOfRecords)++++'+VoteForProfile(createdById, offset,numberOfRecords));
            List<Activity> test1 = VoteForProfile(createdById, offset,numberOfRecords); 
            System.debug('test1.size()+++++'+test1.size());
            return  VoteForProfile(createdById, offset,numberOfRecords);   
            }
        else if (filter == 'Subscription') {
            System.Debug('SubscribeForProfile(createdById, offset,numberOfRecords)++++'+SubscribeForProfile(createdById, offset,numberOfRecords));
            List<Activity> test2 = SubscribeForProfile(createdById, offset,numberOfRecords);
            System.Debug('SubscribeForProfile(createdById, offset,numberOfRecords)++++'+test2.size());
            return  SubscribeForProfile(createdById, offset,numberOfRecords);   
            }
        return activities;                
    }

   

    public List<Activity> VoteForProfile(Id createdById, Integer offset,Integer numberOfRecords) {
        List<Id> ideaIds = new List<Id>();
        List<Activity> tempIdeaActivities = new List<Activity>();  
        Map<Id,Idea> myIdeas = new Map<Id,Idea>([SELECT ID from Idea where createdbyId =: createdById]); 
        List<Vote> ideaVotes = [select Id, ParentId, CreatedDate from Vote where parentId not in: myIdeas.keyset() AND CreatedById = : createdById and Parent.Type = 'Idea' ORDER BY CreatedDate desc limit 10  OFFSET : offset];
        for (Vote vote : ideaVotes) {
            ideaIds.add(vote.ParentId);
        }
        Map<Id, Idea> ideas = new Map<Id, Idea>([select Id, Title, Body, CreatedDate from Idea where Id in :ideaIds]);
        for (Vote vote : ideaVotes) {
            Idea idea = ideas.get(vote.ParentId);    
            // Exclude the Vote that is automatically created when a new Idea is created.               
            if (vote.CreatedDate == idea.CreatedDate) continue;    
            Long createdDateTime = vote.CreatedDate.getTime();
            Activity activity = new Activity('Vote', 'Idea', idea.Id, idea.Title, GlobalFunctions.getShortBody(idea.Body), vote.CreatedDate);    
            tempIdeaActivities.add(activity);
        }
        return tempIdeaActivities; 
    }
    public List<Activity> SubscribeForProfile(Id createdById, Integer offset,Integer numberOfRecords) {
        Set<ID> QuestionSet = new Set<ID>();
        List<Activity> tempActivities = new List<Activity>(); 
        List<Community_Subscription__c> CommSubscriptions = [Select id,Idea_Question_Id__c from Community_Subscription__c 
        where Type__c =: 'Question' and User__c =:createdById ];
        for(Community_Subscription__c SubList :CommSubscriptions){
            QuestionSet.add(SubList.Idea_Question_Id__c);
        }
        List<Question> queslist = [Select Id,CreatedDate,Title,Body from Question where id IN :QuestionSet ORDER BY CreatedDate desc limit 10  OFFSET : offset]; 
        System.Debug('queslist.size()+++'+queslist.size());
        for(Question question: queslist){
            Activity activity = new Activity('Question', null,question.Id, question.Title, GlobalFunctions.getShortBody(question.Body), question.CreatedDate);
            tempActivities.add(activity);
        }
        return tempActivities;
    }  

    public PageReference refreshActivities() {
         System.Debug('currentActivityFilter'+currentActivityFilter);
         System.Debug('currentPageNum'+currentPageNum);
         System.Debug('profileUserId'+profileUserId);
  
         activities     = loadActivities (currentActivityFilter, currentPageNum, MAX_NO_OF_RECORDS_PER_PAGE, profileUserId);
         paginationList = createPaginationList(filterToActConfWrpprMap.get(currentActivityFilter).totalNumberOfRecords, currentPageNum, MAX_NO_OF_RECORDS_PER_PAGE);
         return null;    
    }
    public PageReference changeFilter() {
         System.Debug('currentActivityFilter'+currentActivityFilter);
         System.Debug('currentPageNum'+currentPageNum);
         System.Debug('profileUserId'+profileUserId);
  
         activities     = loadActivities (currentActivityFilter, 1, MAX_NO_OF_RECORDS_PER_PAGE, profileUserId);
         System.Debug('totalNumberOfRecords++++'+filterToActConfWrpprMap.get(currentActivityFilter).totalNumberOfRecords);
         paginationList = createPaginationList(filterToActConfWrpprMap.get(currentActivityFilter).totalNumberOfRecords, 1, MAX_NO_OF_RECORDS_PER_PAGE);        
         return null;    
    }    
    public String getUserProfileBadges(){
        Map<String, Boolean> profile_badge_value  = new map<String, Boolean>();        
        
        profile_badge_value.put('champion',   sfdcUserProfile.Champion__c);
        profile_badge_value.put('user group leader', sfdcUserProfile.Is_Leader__c);
        profile_badge_value.put('partner',    sfdcUserProfile.Is_Partner__c);        
        profile_badge_value.put('consultant', sfdcUserProfile.Is_Consultant__c);
        profile_badge_value.put('employee',   sfdcUserProfile.Is_Employee__c);        
        
        String userBadgeValue  = '';        
        for(String profile_badge_val : profile_badge_value.keySet()) {
            if (profile_badge_value.get(profile_badge_val) == true) {
               userBadgeValue += profile_badge_val + ', ';
            }
        } 
        if(GlobalFunctions.getIsCertifiedUserMap(new set<id>{currentLoggedUser.Id}).get(currentLoggedUser.Id))
        {
            userBadgeValue += 'Marketo Certified Expert, ';        
        }    
        if(userBadgeValue.endsWith(', ')){
            userBadgeValue = userBadgeValue.substring(0,userBadgeValue.length()-2);
        }
        
        return userBadgeValue;      
    }
    
    private String fixUrl(String url) {
        if (url != null && url.trim().length() > 0 &&
            (!url.trim().toLowerCase().startsWith('http://') &&
             !url.trim().toLowerCase().startsWith('https://'))) {
            return 'http://' + url;
        } else {
            return url;
        }
    }
    
    public Boolean getIsEditable() {
        return (sfdcUserProfile.Id == UserInfo.getUserId());
    }
    
    public Boolean isPastContestWinner(String prfUsrId)
    {
        Integer winnerCnt = [SELECT Count() from BadgeVilleContestWinner__c WHERE Community_User_Id__c =: prfUsrID];
        if(winnerCnt > 0) return true; 
        return false;        
    }

    public class Activity {
        public String activityType {get; set;}
        public Id id {get; set;}
        public String title {get; set;}
        public String summary {get; set;}
        public DateTime createdDate {get; set;}
        public String voteType {get; set;} 
        
        public Activity(String activityType, String voteType, Id id, String title, String summary, DateTime createdDate) {
            this.activityType = activityType;
            this.voteType     = voteType;
            this.id           = id;
            this.title        = title;
            this.summary      = summary;
            this.createdDate  = createdDate;
        }
        
        public String getFormattedCreatedDate() {
            return GlobalFunctions.formatDate(createdDate);
        }
    }
    
    public class ActivityConfigurationWrapper{
        public String      sObjectType{get;set;}  
        public String      filter{get;set;}
        public Integer     totalNumberOfRecords{get;set;}
   
        public ActivityConfigurationWrapper(String sObjectType, String filter, Integer totalNumberOfRecords) {
            this.sObjectType          = sObjectType;
            this.filter               = filter;
            this.totalNumberOfRecords = totalNumberOfRecords;
        }
    }
    
    public List<SelectOption> getFilterOptions() {
        List<SelectOption> filterOptions = new List<SelectOption>();
        
        for(String filterKey:filterToActConfWrpprMap.keySet()) {
            filterOptions.add(new SelectOption(filterKey,filterToActConfWrpprMap.get(filterKey).filter));
        }
        return filterOptions;
    }
    
    public Integer getTotalsObjectsByCreatedById(String sObjectType, String createdById){
        Integer numberOfsObjectForProfile;
        Set<ID> QuestionSet = new Set<ID>();
        try{
            If (sObjectType == 'Vote') {
                Map<Id,Idea> myIdeas = new Map<Id,Idea>([SELECT ID from Idea where createdbyId =: profileUserId]); 
                numberOfsObjectForProfile = [Select count() from Vote where parentId not in: myIdeas.keyset() AND CreatedById = : createdById and Parent.Type = 'Idea'];
            } else If (sObjectType == 'Subscription') {
                List<Community_Subscription__c> CommSubscriptions = [Select id,Idea_Question_Id__c from Community_Subscription__c where Type__c =: 'Question' and User__c =: createdById]; 
                for (Community_Subscription__c SubList :CommSubscriptions) {
                    QuestionSet.add(SubList.Idea_Question_Id__c);
                }
                numberOfsObjectForProfile = [Select count() from Question where id IN :QuestionSet]; 
            }
            return numberOfsObjectForProfile;
        } catch (Exception ex){
        
        }  return null;   
    }

    public List<Integer> createPaginationList (Integer totalNoOfResults, Integer curPageNo,Integer pagesize) {
        List<Integer> paginationList = new List<Integer>(); 
        Double totalNumOfPages = math.ceil(Double.valueof(totalNoOfResults)/Double.valueof(pagesize));
        hasNextPage = curPageNo==totalNumOfPages ?false:true; 
        hasPrevPage = curPageNo > 1?true:false;
        totalTestRecords = totalNoOfResults; 
        Integer index;
        If(curPageNo <= 4 ){
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
        System.DEbug('here is the bug');
        System.Debug('totalNumOfPages++++'+totalNumOfPages);
            for (index=curPageNo-3;index<curPageNo;index+=1) {
                    if(index<=0) {
                        continue;  
                    }
                paginationList.add(index);
                }
            paginationList.add(curPageNo);
            Integer jindex;      
                for (jindex=curPageNo+1;jindex<=curPageNo+3;jindex+=1) {
                    if(jindex > totalNoOfResults/pageSize){
                        break;
                    }
                paginationList.add(jindex);
                }
            }
        else {//Enter Here for last 3 pages
            System.Debug('Entered here for last three numbers'+curPageNo);
            Integer tempNum;//Number of digits before last three digits to keep the list count(7) for last three digits
            System.Debug('totalNumOfPages++++'+totalNumOfPages);
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
    @isTest(SeeAllData=true)
    public static void testController() {
        PageReference pageRef = Page.MarketoCommunityProfile;
        Idea idea = new Idea();
        idea.Title = 'Test';
        idea.Body = 'Test';
        idea.CommunityId = GlobalFunctions.communityId;
        insert idea;
        
        Question question = new Question();
        question.Title = 'Test';
        question.Body = 'Test';
        question.CommunityId = GlobalFunctions.communityId;
        insert question;
        
        Reply myReply = new Reply(QuestionId = question.Id);
        myReply.Body = ' answer 2';
        insert myReply;
        
        Account acc= new Account(Name = 'Test Account');
        insert acc;
       
        List<Contact> ContactList = new List<Contact>();
        Contact Cont = new Contact( AccountID = acc.id, FirstName = 'Test', LastName = 'User', 
        email = 'test-user@fakeemail.com' );
        insert Cont;
        
        
        PageReference testPage = Page.MarketoCommunityProfile;
        testPage.getParameters().put('oid', '12345');
        User userInfo =[select id,AccountId,ContactID from User where IsPortalEnabled = true and isActive = true limit 1 ];
        Test.setCurrentPage(testPage);
        Test.StartTest();
        MarketoCommunityProfileController controller = new MarketoCommunityProfileController();
        PageReference pageRef1 = Page.MarketoCommunityProfile;        
        pageRef1.getParameters().put('Id',userInfo.Id );
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('id', '00550000001m9SEAAY'); // NEED_TO_FIX_THIS
        controller.init();
        controller.currentActivityFilter = 'Vote'; 
        controller.refreshActivities();
        controller.currentActivityFilter = 'Reply';
        controller.refreshActivities();
        controller.currentActivityFilter = 'IdeaComment';
        controller.refreshActivities();
        controller.currentActivityFilter = 'Question';
        controller.refreshActivities();
        controller.currentActivityFilter = 'Idea';
        controller.getUserProfileBadges();
      }
}