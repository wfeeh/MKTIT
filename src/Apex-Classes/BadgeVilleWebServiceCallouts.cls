public class BadgeVilleWebServiceCallouts
{    
    //Added for static functioning
    Public Static BadgevilleSettings__c currBadgevilleSettings 
    {
        get
        {
            if(currBadgevilleSettings  == null) {
                currBadgevilleSettings  =  BadgevilleSettings__c.getInstance('BadgevilleSettings');
            } 
            return currBadgevilleSettings;
        }       
        set;    
    }
        
    public List<SelectOption> getviewOptions()
    {
        List<SelectOption> viewOptions = new List<SelectOption>();
        viewOptions.add(new SelectOption('Present','Presented at Event Webinar'));
        viewOptions.add(new SelectOption('Complete','Completed Social Media Request'));
        viewOptions.add(new SelectOption('Referred','Referred Lead who Became Customer')); 
        return viewOptions;              
    }            
        
    public BadgeVilleWebServiceCallouts()
    {
        //Behaviour = 'Presented at Event / Webinar';        
    }    
                 
    @future (callout=true) 
    public static void badgvilleAskQuestion()
    {
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }  
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;
        String LoggedInUserID = UserInfo.getUserID();        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=ask a question&site='+badgvilleSite+'&user='+LoggedInUserID+'@marketo.com');
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }        
    }
    
    //User Profile filled
    @future (callout=true)
    public static void badgvilleFillProfile()
    {
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }   
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;
        String LoggedInUserID = UserInfo.getUserID();        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=fill in profile&activity[userid]='+LoggedInUserID+'&site='+badgvilleSite+'&user='+LoggedInUserID+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }
    }
    
    @future (callout=true)
    public static void badgvilleSubmitIdea(){
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }   
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;
        String LoggedInUserID = UserInfo.getUserID();        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=submit an idea&site='+badgvilleSite+'&user='+LoggedInUserID+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }
    }
   
    
    //sahil        
    @future (callout=true)               
    public static void badgvilleVoteOnIdea(){
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;
        String LoggedInUserID = UserInfo.getUserID();          
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=vote on idea&site='+badgvilleSite+'&user='+LoggedInUserID+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        } 
    }
    //end

    @future (callout=true)               
    public static void badgvilleAnswerQuestion(){
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;
        String LoggedInUserID = UserInfo.getUserID();          
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=answer a question&site='+badgvilleSite+'&user='+LoggedInUserID+'@marketo.com');
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }
    }

    @future (callout=true) 
    public static void badgvilleSelectAnswer(){
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;
        String LoggedInUserID = UserInfo.getUserID();        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=select best answer&site='+badgvilleSite+'&user='+LoggedInUserID+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }
    }
               
    @future (callout=true)               
    public static void badgvilleGiveAFeedback(Id articleID){
        String badgvilleUrl = '';
        String badgvilleSite = '';
        if(Test.isRunningTest() == false) {
            badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
            badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }
        String LoggedInUserID = UserInfo.getUserID();        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=giveafeedback&activity[articleid]='+ articleID +'&site='+badgvilleSite+'&user='+LoggedInUserID+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }
    }    
    
    @future (callout=true)               
    public static void badgvilleCommentIdea(){
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;
        String LoggedInUserID = UserInfo.getUserID();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();     
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=comment on idea&site='+badgvilleSite+'&user='+LoggedInUserID+'@marketo.com');
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }
    }
    
    @future (callout=true)
    public static void badgvilleReceiveBestAnswer(ID repID) {
    
        Reply reply = GlobalFunctions.getReplyCreatorDetails(repID);
        System.debug(reply);
        
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(reply.CreatedById)) return; 
        }
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;
        //String LoggedInUserID = UserInfo.getUserID();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=receive best answer&site='+badgvilleSite+'&user='+ reply.CreatedById+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }
    }  
    
    //Bikram 25/4/12 badgeville
    @future (callout=true)
    public static void badgvilleAskQuestionStartsDiscussion(Id questionID){           
        Question question = GlobalFunctions.getQuestion(questionID);    
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(question.CreatedById)) return; 
        }
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;            
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();     
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=ask question that starts discussion&activity[questionid]='+questionID+'&site='+badgvilleSite+'&user='+ question.CreatedById+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        } 
    }  
    
    @future (callout=true)
    public static void badgvillePointsOnAnIdea(Id IdeaID){       
 
        //Idea anIdea = GlobalFunctions.getIdea(IdeaID);
        Idea anIdea = [SELECT Id,CreatedById from IDea Where Id = :ideaID];
        
        if(Test.isRunningTest() == false){         
            if(!GlobalFunctions.getPartner_Supported_Status(anIdea.CreatedById)) return; 
        }           
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;            
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=points on an idea&site='+badgvilleSite+'&user='+anIdea.CreatedById+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }
    }       
    
    //Bikram 24 july 2012 Idea becomes a product
    @future (callout=true)
    public static void badgvilleIdeaBecomesProduct(ID ideaID){
        //Idea myIdea = GlobalFunctions.getIdea(ideaID);
        Idea myIdea = [SELECT Id,CreatedById from IDea Where Id = :ideaID];
        
        System.debug(myIdea);
        Id myIdeaUser = myIdea.CreatedById; 
        if(Test.isRunningTest() == false){         
            if(!GlobalFunctions.getPartner_Supported_Status(myIdea.CreatedById)) return; 
        }           

        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;            
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=submitideathatbecomeproduct&activity[ideaid]=' + ideaID + '&site='+badgvilleSite+'&user='+myIdea.CreatedById+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        } 
    }
    
    //Bikram badgeville liked Reply to Discussion
    @future (callout=true)
    public static void badgvilleLikedComment(Id commentID) {        
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;            
        String LoggedInUserID = UserInfo.getUserID();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=liked_comment&activity[commentid]='+commentID+'&site='+badgvilleSite+'&user='+ LoggedInUserID+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        } 
    }
    
    //Bikram 08/Mar/2013 badgeville give reward to comment poster for replies on discussion
    @future (callout=true)
    public static void badgvilleReceivedLikedComment(Id replyID) {        
        List<Reply> myReply = [Select Id, QuestionId, CreatedById From Reply Where ID = : replyID Limit 1]; 
        if(myReply.size() == 0) return;           
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(myReply[0].CreatedById)) return; 
        }
        //Unique key identifier for comment liked by a voter
        String commentParentId = myReply[0].QuestionId;
        String commentVoterID = replyId + UserInfo.getUserID();              
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c; 
        //Added By Nishtha for issue 4482
        
        Boolean IsContestRunning = false; 
        String ColorContestDiscussionId;          
        DateTime myColorContestStartDate = datetime.now();
        DateTime myColorContestEndDate = datetime.now();
        
        if(Test.IsRunningTest() == FALSE) {
            IsContestRunning = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').IsActive__c;        
            ColorContestDiscussionId = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').DiscussionId__c;
            myColorContestStartDate = ColorBookContestSettings__c.getInstance('ColorBookContestDetails').Start_Date__c;
            myColorContestEndDate =  ColorBookContestSettings__c.getInstance('ColorBookContestDetails').End_Date__c;
        } else {
            IsContestRunning = FAlSE;        
            ColorContestDiscussionId = '90650000000PcqPAAS';
            myColorContestStartDate = Date.Today();
            myColorContestEndDate = Date.Today();
        }           
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        If (IsContestRunning  == TRUE && ColorContestDiscussionId  != null && commentParentId == ColorContestDiscussionId &&  Date.Today() >= myColorContestStartDate && Date.Today()<= myColorContestEndDate){  
            req.setBody('activity[verb]=received_liked_comment&activity[discussion_id]='+ commentParentId +'&activity[commentvoterid]='+commentVoterID+'&site='+badgvilleSite+'&user='+ myReply[0].CreatedById+'@marketo.com' );
        }
        else {
            req.setBody('activity[verb]=received_liked_comment&activity[commentvoterid]='+commentVoterID+'&site='+badgvilleSite+'&user='+ myReply[0].CreatedById+'@marketo.com' );
        }
        //req.setBody('activity[verb]=received_liked_comment&site='+badgvilleSite+'&user='+ profileUser.ID+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        } 
    }    
                 
    //Bikram 22/Mar/2013 badgeville liked Reply to Idea Comment
    @future (callout=true)
    public static void badgvilleLikedIdeaComment(Id commentID) {    
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(UserInfo.getUserID())) return; 
        }                
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;            
        String LoggedInUserID = UserInfo.getUserID();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=liked_comment&activity[commentid]='+commentID+'&site='+badgvilleSite+'&user='+ LoggedInUserID+'@marketo.com' );                
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }  
    } 
    
    
    //Bikram 22/Mar/2013 badgeville give reward to Ideacomment poster
    @future (callout=true)
    public static void badgvilleReceivedLikedIdeaComment(Id commentID) {        
        List<IdeaComment> myComment = [Select Id, CreatedById From IdeaComment Where ID = : commentID Limit 1]; 
        if(myComment.isEmpty()) return;                    
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(myComment[0].CreatedById)) return; 
        }
        //Unique key identifier for comment liked by a voter
        String commentVoterID = commentID + UserInfo.getUserID();    
            
        String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;            
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=received_liked_comment&activity[commentvoterid]='+commentVoterID+'&site='+badgvilleSite+'&user='+ myComment[0].CreatedById+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        } 
    }
    
    @future (callout=true)
    public static void attendASummitReward(Id userId,string verb, String campaignId){
        userGroupReward(userId,verb,campaignId);        
    }
   
    
    
    //@future (callout=true)
    public static void userGroupReward(Id userId, string verb, String campaignId){
        
        if(Test.isRunningTest() == false){         
            if(!GlobalFunctions.getPartner_Supported_Status(userId)) return; 
        }                  
        //String badgvilleUrl = currBadgevilleSettings.BadgvilleApiUrl__c;
        //String badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;                    
        String badgvilleUrl = 'sandbox.v2.badgeville.com'; //currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = 'www.grazitti.com'; //currBadgevilleSettings.BadgvilleSite__c;      
        if(Test.isRunningTest() == false) {
            badgvilleUrl =  currBadgevilleSettings.BadgvilleApiUrl__c;
            badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;              
        }
        
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]='+verb+'&activity[userid]=' + userId+ '&activity[campaignid]='+campaignId+'&site='+badgvilleSite+'&user='+userId+'@marketo.com' );
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        } 
    }
    
    
    //@future (callout=true)
    public static void giveTriggeredReward(Id userID, String verb) {    
        if(Test.isRunningTest() == false) {
            if(!GlobalFunctions.getPartner_Supported_Status(userID)) return; 
        }                
        String badgvilleUrl = 'sandbox.v2.badgeville.com'; //currBadgevilleSettings.BadgvilleApiUrl__c;
        String badgvilleSite = 'www.grazitti.com'; //currBadgevilleSettings.BadgvilleSite__c;      
        if(Test.isRunningTest() == false) {
            badgvilleUrl =  currBadgevilleSettings.BadgvilleApiUrl__c;
            badgvilleSite = currBadgevilleSettings.BadgvilleSite__c;              
        }
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]='+verb+'&activity[userid]='+userID+'&site='+badgvilleSite+'&user='+userID+'@marketo.com' );                
        try {
            if(Test.isRunningTest() == false)  { 
                res = http.send(req); System.debug('res-->' + res.toString());
            }
        } catch(System.CalloutException e) {
            System.debug('Callout error: ' + e + ' ' + res.toString());
        } catch(Exception e) {
            System.debug('Callout error: ' + e);
        }  
    } 
    
    @isTest(SeeAllData=true)
    public static void testLikedComment()
    {
        List<Reply> testComment = [SELECT ID, CreatedById from Reply Limit 1];
        if(testComment.isEmpty() == false)
            badgvilleLikedComment(testComment[0].Id);
    }  
       
    @isTest(SeeAllData=true)
    public static void testSubmitIdea() {
        badgvilleSubmitIdea();
    }
    
    @isTest(SeeAllData=true)
    public static void testVoteOnIdea() {
        //sahil
        badgvilleVoteOnIdea();
        //end
    }
    
    @isTest(SeeAllData=true)
    public static void testAnswerQuestion() {        
        badgvilleAnswerQuestion();        
    }
      
    @isTest(SeeAllData=true) 
    public static void testAskQuestion() {
        badgvilleAskQuestion();
    }
    
    @isTest(SeeAllData=true)  
    public static void testCommentIdea() {
        badgvilleCommentIdea();
    }  
    
    @isTest(SeeAllData=true)
    public static void testSelectAnswer() {        
        badgvilleSelectAnswer();        
    }
    
    @isTest(SeeAllData=true)
    public static void testGiveAFeedback() {
        badgvilleGiveAFeedback('kA250000000KzX3');
    }
    
    @isTest(SeeAllData=true)
    public static void testFillProfile() {
        badgvilleFillProfile();
    }
       
    @isTest(SeeAllData=true)
    public static void testReceiveBestAnswer() {            
        Reply reply = new Reply();
        Id repId = '90750000000PD3nAAG';//;reply.ID;
        badgvilleReceiveBestAnswer(repId);                           
    }    
    
    @isTest(SeeAllData=true)
    public static void testReceivedLikedComment() {                    
        Id repId = '90750000000PD3nAAG';//;reply.ID;
        badgvilleReceivedLikedComment(repId);                           
    }
    
    @isTest(SeeAllData=true)
    public static void testLikedIdeaComment() {                    
        List<IdeaComment> myComment = [Select Id, CreatedById From IdeaComment Limit 1];
        if(myComment.isEmpty()) return;             
        badgvilleLikedIdeaComment(myComment[0].Id);                           
    }
    
    @isTest(SeeAllData=true)
    public static void testReceivedLikedIdeaComment() {                    
        List<IdeaComment> myComment = [Select Id, CreatedById From IdeaComment Limit 1];
        if(myComment.isEmpty()) return;             
        badgvilleReceivedLikedIdeaComment(myComment[0].Id);    
    }
    
    
    @isTest(SeeAllData=true)
    public static void testAskQuestionStartsDiscussion() {
        Question question = new Question();
        question.Title = 'testQuestion1';            
        question.Body = 'asdfasdkfjlas lasadfkjlkas f';
        question.CommunityId = '09a50000000PNNr';
        insert question;
        ApexPages.currentPage().getParameters().put('id', question.Id);        
        Id quesID = '90650000000PEjaAAG';
        badgvilleAskQuestionStartsDiscussion(quesID);       
        System.debug('GotHere');
    }
    
    @isTest(SeeAllData=true)
    public static void testbadgvilleIdeaBecomesProduct() {
        Idea ideas = new Idea();
        ideas.Title = 'testQuestion1';            
        ideas.Body = 'asdfasdkfjlas lasadfkjlkas f';
        ideas.CommunityId = '09a50000000PNNr';
        insert ideas;
        ApexPages.currentPage().getParameters().put('id', ideas.Id);        
        Id ideaID = '08750000000I03Q';
        badgvilleIdeaBecomesProduct(ideaID );       
        System.debug('GotHere');
    }
        
    @isTest(SeeAllData=true)
    public static void testPointsOnAnIdea() {
        Idea ideas = new Idea();
        ideas.Title = 'testQuestion1';            
        ideas.Body = 'asdfasdkfjlas lasadfkjlkas f';
        ideas.CommunityId = '09a50000000PNNr';
        insert ideas;
        ApexPages.currentPage().getParameters().put('id', ideas.Id);        
        Id ideaID = '08750000000I03Q';
        badgvillePointsOnAnIdea(ideaID );
        System.debug('GotHere');
    }
    
     @isTest(SeeAllData=true)
    public static void testattendASummitReward() {              
        Campaign c = new Campaign(Name = 'User Group Attendees',  Type = 'Blog', StartDate =  Date.Today(),EndDate = Date.Today().addDays(30), Status = 'New');
        insert c;         
        BadgeVilleWebServiceCallouts.attendASummitReward(Userinfo.getUserId(),'attended_user_summit',c.Id);       
    }        
    @isTest(SeeAllData=true)
    public static void testUserGroupReward() {
        Campaign c = new Campaign(Name = 'User Group Attendees',  Type = 'Blog', StartDate =  Date.Today(),EndDate = Date.Today().addDays(30), Status = 'New');
        insert c;         
        BadgeVilleWebServiceCallouts.UserGroupReward(Userinfo.getUserId(),'attend_a_user_group_meeting',c.Id );
    }    
    @isTest(SeeAllData=true)
    public static void testGiveTriggeredReward() {                
        BadgeVilleWebServiceCallouts.giveTriggeredReward(Userinfo.getUserId(),'synchwithboulderlogic');
    } 
}