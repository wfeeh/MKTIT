public class MarketoDiscussionNewController extends MarketoBaseController {

    public Boolean subscribe {get; set;}
    public String[] categories {get; set;}
    public String selectedQuestionCategory {get;set;}
    public List<selectOption> quesCategoryOptions {get; private set;}
    public Question ques {get; set;}
    private Boolean searchSimilar = false;
    public Boolean showSimilarArticles {get; set;}
    private transient Question[] searchResult;
    public Community_Subscription__c sub {get; set;}
    public String defaultTitle {get; set;}
    public  Boolean isDisabled = false;
    public User UserId {get; private set;}
    public Boolean hasPM_User{get;set;}
     public Boolean isRichText{get;set;}
    Public Boolean EmployeeActive;
    public MarketoDiscussionNewController() {        
        init();
    }
    
    public PageReference toggleTextArea() {
        String socialPoll = ApexPages.currentPage().getParameters().get('poll');
        try {
            
            if(socialPoll == '1'){
                isRichText = false;
            }
            else{
                isRichText = true;
            }
            
        }
        catch (Exception e) {
            System.debug('Exception Subscription Toggle==>' + e);
        }
    
        return null;
        
            
    }
    private void init() {
       hasPM_User = False;
        List<User> hasPM_Users = [Select id, PM_User__c from user where id =:UserInfo.getUserId()]; 
        if(hasPM_Users!= null && hasPM_Users.size() > 0){
            hasPM_User = hasPM_Users.get(0).PM_User__c;
            System.debug('hasPM_User---->'+hasPM_User);
        }
        
        If(hasPM_User ==false){
            isRichText = True;
        }
        else{
            String socialPoll = ApexPages.currentPage().getParameters().get('poll');
            system.debug('socialPoll ==>'+socialPoll);
            if(socialPoll != null && socialPoll == '1'){
                isRichText = false;
            }
            else{
                isRichText = True;
            }
        }
        
        gF = new GlobalFunctions();         
        // Default to University Training if specified to do so on query string.
        if ('training'.equalsIgnoreCase(ApexPages.currentPage().getParameters().get('cat'))) {
            selectedQuestionCategory = 'University_Training';
        }
        String tabType =ApexPages.currentPage().getParameters().get('tabType');
        if(tabType != null && tabType=='Job Opportunities'){
            system.debug('=======abc ===='+tabType);
            selectedQuestionCategory = 'Job_Opportunities';
        }
        UserId = [select Username,Email,ID,Is_Employee__c from User where Id = :UserInfo.getUserId()];
        system.debug('=======UserId ===='+UserId );
        EmployeeActive = UserId.Is_Employee__c; 
        
        quesCategoryOptions = new List<selectOption>();
        quesCategoryOptions.add(new SelectOption('', '--None--'));
        
        for (DataCategory c : DataCategoryHelper.getHelper(new String[]{'Question'}).getCategories()) {
            if(EmployeeActive != true &&  c.getName() == 'Announcements'){
                continue;
            }
            quesCategoryOptions.add(new SelectOption(c.getName(), c.getLabel()));
        }
        System.debug('quesCategoryOptions-->'+quesCategoryOptions); 
        ques = new Question();
        subscribe = true;
        sub = new Community_Subscription__c();
        
        showSimilarArticles = false;
    }   
    
    public PageReference save() {
        this.isDisabled = true;
        PageReference retVal = Page.MarketoDiscussionHome;
        if(selectedQuestionCategory != null && selectedQuestionCategory == 'Job_Opportunities') {
            retVal.getParameters().put('DiscussionCategory',selectedQuestionCategory);
            retVal.getParameters().put('discussionPg','1');
            retVal.getParameters().put('tabType','Recent');
        }
        System.Debug('Discussion is going to be Posted'+ques.body);
        List<String> msg = new List<String>();
        if (ques.title == null) {
            msg.add('Title');
        }
        if (ques.body == null || ques.body.replace('&nbsp;',' ').trim() == '') {
            msg.add('Description');
        }
        if (selectedQuestionCategory == null) {
            msg.add('Categories');
        }
        
        if (msg.size() > 0) {
            String msg2 = 'Required fields are missing: ';
            for (Integer i=0; i<msg.size(); i++) {
                msg2 +=  msg[i] + (i<msg.size()-1 ? ', ' : '');
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg2));
            return null;
        }
        /* badgeville kanupriyag@grazitti.com 16-04-2012 */
            BadgeVilleWebServiceCallouts.badgvilleAskQuestion();    
        /* badgeville kanupriyag@grazitti.com 16-04-2012 */
         
         /* 14-05-11 vishals@grazitti.com Added to preserve carriage return*/ 
        if(!getIsRichTextRequired())
            ques.body = preserveCarriageReturn(ques.body);
        ques.communityId = '09a50000000PNNr';//GlobalFunctions.communityId;
        upsert ques;
            
        QuestionDataCategorySelection q = new QuestionDataCategorySelection();
        q.parentid = ques.id;
        q.datacategorygroupname = 'Answers';
        q.datacategoryname = selectedQuestionCategory;
        insert q;
        
        if (subscribe) {
            Community_Subscription__c s = new Community_Subscription__c();
            s.idea_question_id__c = ques.id;
            s.user__c = UserInfo.getUserId();
            s.type__c = 'Question';
            s.Category__c = selectedQuestionCategory;
            insert s;
        }
        retVal.setRedirect(true);
       
        return retVal;
    }
    public Boolean getIsDisabled(){
        return this.isDisabled;  
    }
    public PageReference loadSimilar() {
        Id[] similarIds = Answers.findSimilar(ques);

        if (similarIds == null || similarIds.size() == 0) {
            searchSimilar = true;
            showSimilarArticles = false;
           
            return null;
        } else {
            searchResult = [select title from question where id in :similarIds];

            List<List<SObject>> searchResultsList = Search.query('FIND \'' + String.escapeSingleQuotes(ques.title) + '\' IN ALL FIELDs Returning Article__kav(ID, Title WHERE PublishStatus = \'Online\' AND Language=\'en_US\') limit 5');    
            similarArticles = (List<Article__kav>) searchResultsList[0];
            if(similarArticles.size() == 0) {
                showSimilarArticles = false;
            } else {
                showSimilarArticles = true;
            }
        }
       return null;
    }

    public Integer getHasSimilarQuestions() {
        if ( searchResult != null && searchResult.size() > 0 ) {
           return 1;
        } else if (searchSimilar && (searchResult == null || searchResult.size() == 0 )) {
            return 0;
        }
        return -1;
    }
    
    public Question[] similarQuestions {
        get { return searchResult; }
    }
    
    public Article__kav[] similarArticles { get; private set; }
   
   
    public static testMethod void testDiscNewController() {
        MarketoDiscussionNewController c = new MarketoDiscussionNewController();
        c.init();
        
        //c.save();
        
        c.ques.title = 'Test';
        c.ques.body = 'Test';
        c.selectedQuestionCategory = 'Administration';
        c.save();
        c.getIsDisabled();
        c.loadSimilar();
        c.getHasSimilarQuestions();
        
    }    
}