public class BadgeVilleWebServiceCallout extends MarketoBaseController
{
    public User profileUser {get; private set;}
    public Reply reply {get; set;}
    public Question question {get;set;}
    public String bestReplyUser{get;set;}
    public Community_Profile__c profile {get; private set;}
    public String badgvilleUrl;  
    public String badgvilleSite;
    public String badgvillePrvApiKey;
    //public String badgvilleUrl;
    public ID LoggedInUserID {get;set;}
    Map<String, BadgvilleUrls__c> badgvilleSettings;  
    
    
    public BadgeVilleWebServiceCallout(){
        badgvilleUrl = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
        badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;
        //badgvillePrvApiKey = BadgvilleUrls__c.getAll().get('badgvillePrvtApiKey').BadgvilleApiPrivateKey__c;
        LoggedInUserID = UserInfo.getUserId();
        // getProfileUser();
    }

    class PlayerPos{
        public String player_id;
        public Integer position;
        public Decimal value;  
        public String upDtTime;             
        public PlayerPos(String pid, Integer pos,Decimal val,String updtm) {
            this.player_id = pid;
            this.position = pos;
            this.value = val;
            this.upDtTime = updtm; 
        }       
    }    

    public void updateLeaderBoard1()
    {
        updateLeaderBoard();
    }
    
    public void updateLeaderBoard()
    {
        String badgvilleUrl  = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
        String badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;   
        String badgvilleLBId = BadgvilleUrls__c.getAll().get('BadgvilleApiLeaderBoard').Badgville_Urls__c; 
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();        
        req.setEndpoint(badgvilleUrl+'/leaderboards/'+badgvilleLBId+'.json?site='+badgvilleSite);        
        //Prod LB id = 50487e08cb2ad40b05002568
        //sandbox LB id = 5046251a49f8381c25001a60
        //String badgvilleUrl = 'http://api.v2.badgeville.com/api/berlin/b95839370dca983955e550296450ec03';//BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
        //String badgvilleSite = 'www.marketo1.com';//BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;   
        //badgvilleLBId = '50487e08cb2ad40b05002568';
        
        req.setMethod('GET');
        String JSONContent = '';
        String plyrID = '';         
        String plyrPosition;
        String plyrValue;
        Boolean playerExists = true;
        try {             
            res =  http.send(req);           
            System.debug(res.getBody());
            JSONContent = res.getBody();
            {
                if(JSONContent.contains('"error": "invalid ObjectId"'))
                {
                    //User does not exist in badgeville create one   
                    System.debug('Player error invalid player'); 
                    playerExists  = false;                                                                                     
                }
                else
                {                                      
                    System.JSONParser parser = JSON.createParser(JSONContent);
                    List<PlayerPos> myPlayerList = new List<PlayerPos>();
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContent);                                        
                    Map<String, Object> a = (Map<String, Object>) m.get('data');                    
                    List<Object> b = (List<Object>) a.get('positions');                     
                    for (Object c : b){                    
                        //System.debug('c==>' + c);
                        Map<String, Object> d = (Map<String, Object>) c;
                        for (String key:d.keySet()) {
                            String pid = '';Integer pos = 0;Decimal val = 0.0; String upDt; 
                            Map<String, Object> e = (Map<String, Object>) d.get(key);
                            System.debug('evalue== ' + e);                            
                            pid = (string) e.get('player_id');
                            pos = (integer)e.get('position');
                            val = (decimal)e.get('value');
                            upDt = (string)e.get('updated_at');
                            PlayerPos myPos = new PlayerPos(pid,pos,val,upDt);
                            myPlayerList.Add(myPos);                            
                        }                                            
                    }                    
                    if(myPlayerList.size() > 0)
                    {
                        BadgeVilleLeaderBoard__c[] doomedRecs = [SELECT Id FROM BadgeVilleLeaderBoard__c]; 
                        try {
                            if(!doomedRecs.isEmpty())
                            delete doomedRecs;
                            List<BadgeVilleLeaderBoard__c> recsList = new List<BadgeVilleLeaderBoard__c>();   
                            for(PlayerPos  myPL : myPlayerList)
                            {
                                BadgeVilleLeaderBoard__c myRec = new BadgeVilleLeaderBoard__c();
                                myRec.PlayerID__c = myPL.player_id;
                                myRec.Position__c = myPL.position;
                                myRec.Value__c    = myPL.value;
                                myRec.Updated_DateTime__c = myPL.upDtTime ;
                                recsList.add(myRec );
                                // Get other information of player
                                getBadgevillePlayerInfo(myPL.player_id, myPL.position, myPL.value,myPL.upDtTime);
                            }                            
                        } catch (DmlException e) {
                             System.debug('DmlException ' + e);                           
                        }                    
                    }                                                                
                }                               
            }        
        }
        catch(Exception ex)
        {
            System.Debug('Exception->' + ex);
        }
    }
    
    @future (callout=true)
    public static void getBadgevillePlayerInfo(String PlayerId, Integer position, Decimal value, String upDateTime) {
        String badgvilleUrl  = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
        String badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;                     
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl + '/players/'+PlayerId+'.json');
        req.setMethod('GET');
        String JSONContent = '';
        String plyrID = ''; 
        String plyrNickName;
        Boolean playerExists = true;
        String picUrl='';
        try {             
            res =  http.send(req);           
            System.debug('MYBODY'+res.getBody()); 
            JSONContent = res.getBody();
            {
                if(JSONContent.contains('{"errors":[{"error":"not found"}]}'))
                {
                    //User does not exist in badgeville create one   
                    System.debug('Player error invalid player'); 
                    playerExists  = false;                                                                                     
                }
                else
                {
                    JSONParser parser =    JSON.createParser(JSONContent);
                    BadgeVilleLeaderBoard__c myRec = new BadgeVilleLeaderBoard__c();
                    while (parser.nextToken() != null) {
                        //System.debug('Current token: ' +  parser.getCurrentToken());
                        // Advance to the next value.                        
                        parser.nextValue();
                        // Get the field name for the current value.                        
                        String fieldName = parser.getCurrentName();                          
                        if(fieldName == 'email')
                        {
                            myRec.PlayerEmail__c  = parser.getText().split('@').get(0);
                        }
                        if(fieldName == 'display_name')
                        {
                            myRec.display_name__c  = parser.getText();
                        }  
                        if(fieldName == 'picture_url')
                        {
                           myRec.PicURL__c  = parser.getText();
                        }                                        
                    }   
                    myRec.PlayerID__c     =  PlayerId;
                    myRec.Position__c     =  position;
                    myRec.Value__c        =  value;
                    myRec.Updated_DateTime__c = upDateTime;                    
                    insert myRec;                                   
                }                               
            }               
        }catch(Exception ex){
            System.debug('exception->' + ex);        
        }
    }        
                 
    public void badgvilleAskQuestion(){
        //if(partner_supported_instnce != true) return;
        profileUser = [select Username,Email,ID from User where Id = :LoggedInUserID];
        if(!GlobalFunctions.getPartner_Supported_Status(profileUser.Id)){ return;  }
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=ask a question&site='+badgvilleSite+'&user='+profileUser.ID+'@marketo.com');
        try {
            http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
        
    }
    
    public void badgvilleFillProfile(){
     
        //if(partner_supported_instnce != true) return ;
        profileUser = [select Username,Email,ID from User where Id = :LoggedInUserID];
        if(!GlobalFunctions.getPartner_Supported_Status(profileUser.Id)){ return;  }
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=fill in profile&activity[userid]='+LoggedInUserID+'&site='+badgvilleSite+'&user='+profileUser.ID+'@marketo.com' );
        try {
            http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
    }
    public void badgvilleSubmitIdea(){
        //if(partner_supported_instnce != true) return ;
        profileUser = [select Username,Email  from User where Id = :LoggedInUserID];
        if(!GlobalFunctions.getPartner_Supported_Status(profileUser.Id)){ return;  }
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=submit an idea&site='+badgvilleSite+'&user='+profileUser.ID+'@marketo.com' );
        try {
            res = http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
    }

    public void badgvilleVoteOnIdea(){        
        //if(partner_supported_instnce != true) return;
        profileUser = [select Username,Email  from User where Id = :LoggedInUserID];
        if(!GlobalFunctions.getPartner_Supported_Status(profileUser.Id)){ return;  }
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http(); 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=vote on idea&site='+badgvilleSite+'&user='+profileUser.ID+'@marketo.com' );
        try {
            res = http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
    }

    public void badgvilleAnswerQuestion(){
        //if(partner_supported_instnce != true) return;
        profileUser = [select Username,Email  from User where Id = :LoggedInUserID];
        if(!GlobalFunctions.getPartner_Supported_Status(profileUser.Id)){ return;  }
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=answer a question&site='+badgvilleSite+'&user='+profileUser.ID+'@marketo.com' );
        try {
            res = http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
    }

     public void badgvilleSelectAnswer(){
        //if(partner_supported_instnce != true) return;
        profileUser = [select Username,Email  from User where Id = :LoggedInUserID];
        if(!GlobalFunctions.getPartner_Supported_Status(profileUser.Id)){ return;  }
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=select best answer&site='+badgvilleSite+'&user='+profileUser.ID+'@marketo.com' );
        try {
            http.send(req);
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
    }
               
    @future (callout=true)               
    public static void badgvilleGiveAFeedback(Id articleID){
        //if(partner_supported_instnce != true) return;
        User profileUser = [select Username,Email  from User where Id = :UserInfo.getUserID()];
        if(!GlobalFunctions.getPartner_Supported_Status(profileUser.Id)){ return;  }
        System.debug('profileUser.Name-->'+profileUser.Username);  
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String badgvilleUrl  = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
        String badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c; 
 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=giveafeedback&activity[articleid]='+ articleID +'&site='+badgvilleSite+'&user='+profileUser.ID+'@marketo.com' );
        try {
            http.send(req);
            System.debug('res-->');
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        } 
    }
    
    public void badgvilleCommentIdea(){
            //if(partner_supported_instnce != true) return;
            profileUser = [select Username,Email,ID  from User where Id = :LoggedInUserID];
            if(!GlobalFunctions.getPartner_Supported_Status(profileUser.Id)){ return;  }
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
     
            req.setEndpoint(badgvilleUrl +'/activities.json');
            req.setMethod('GET');
            req.setBody('activity[verb]=comment on idea&site='+badgvilleSite+'&user='+profileUser.ID+'@marketo.com');
            try {
                http.send(req);
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug(res.toString());
            } 
    }
    
    public void badgvilleReceiveBestAnswer(ID repID){    
            reply = GlobalFunctions.getReplyCreatorDetails(repID);
            System.debug(reply);
            bestReplyUser = reply.CreatedById;
            if(!GlobalFunctions.getPartner_Supported_Status(reply.CreatedById)) return;       
          
            profileUser = [select Username,Email from User where Id = :bestReplyUser];
            System.debug('profileUser.Name-->'+profileUser.Username);  
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
     
            req.setEndpoint(badgvilleUrl +'/activities.json');
            req.setMethod('GET');
            req.setBody('activity[verb]=receive best answer&site='+badgvilleSite+'&user='+ profileUser.ID+'@marketo.com' );
            try {
                http.send(req);
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug(res.toString());
            } 
    }  
    
    //Bikram 25/4/12 badgeville
     public void badgvilleAskQuestionStartsDiscussion(Id questionID){           
            question = GlobalFunctions.getQuestion(questionID);
            System.debug('kpppppp-->'+question);
            String questionOwner = question.CreatedById;            
            if(!GlobalFunctions.getPartner_Supported_Status(question.CreatedById)) return;            
            profileUser = [select Username,Email from User where Id = :questionOwner ];
            System.debug('profileUser.Name-->'+profileUser.Username + profileUser.ID+'@marketo.com' );  
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();     
            req.setEndpoint(badgvilleUrl +'/activities.json');
            req.setMethod('GET');
            req.setBody('activity[verb]=ask question that starts discussion&activity[questionid]={!questionID}&site='+badgvilleSite+'&user='+ profileUser.ID+'@marketo.com' );
            try {
                http.send(req);
            } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);
                System.debug(res.toString());
            } 
    }  
    
    @future (callout=true)
    public static void badgvillePointsOnAnIdea(Id IdeaID){
       
        String badgvilleUrl = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
        String badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;
 
        Idea anIdea = GlobalFunctions.getIdea(IdeaID);
        String ideaOwner = anIdea.CreatedById;    
        if(!Test.isRunningTest()){         
        if(!GlobalFunctions.getPartner_Supported_Status(anIdea.CreatedById)) return; }
        
        User profileUser = [select Username,Email from User where Id = :ideaOwner];    
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=points on an idea&site='+badgvilleSite+'&user='+profileUser.ID+'@marketo.com' );
        try {
            http.send(req);
            System.debug('res-->');
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
    }
    
    
    
    //Bikram 24 july 2012 Idea becomes a product
    @future (callout=true)
    public static void badgvilleIdeaBecomesProduct(ID ideaID){
        String badgvilleUrl = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
        String badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;
          
        Idea myIdea = GlobalFunctions.getIdea(ideaID);
        User profileUser = [select Username,Email,ID from User where Id = :myIdea.CreatedBy.Id];  
        System.debug(myIdea);
        Id myIdeaUser = myIdea.CreatedById; 
        if(!Test.isRunningTest()){         
        if(!GlobalFunctions.getPartner_Supported_Status(myIdea.CreatedById)) return; }           
        profileUser = [select Username,Email from User where Id =: myIdeaUser];
        System.debug('profileUser.Name-->'+profileUser.Username);  
        System.debug('profileUser.Name-->'+profileUser.ID+'@marketo.com'); 
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        req.setEndpoint(badgvilleUrl +'/activities.json');
        req.setMethod('GET');
        req.setBody('activity[verb]=submitideathatbecomeproduct&activity[ideaid]={!ideaID}&site='+badgvilleSite+'&user='+ profileUser.ID+'@marketo.com' );
        try {
            http.send(req);
            System.debug('res-->' + res.toString());
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        } 
    }  
    
    
    @isTest(SeeAllData=true)
    public static void testUpdateLeaderboard(){
        PlayerPos mypos = new PlayerPos('a',1,2.0,'2012-09-14T13:39:50Z');
        test.starttest();
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        bv.updateLeaderBoard();
        test.stoptest();        
    }
    
    @isTest(SeeAllData=true)
    public static void testGetBadgevillePlayerInfo(){
        //PlayerPos mypos = new PlayerPos('a',1,2.0);
        test.starttest();
        BadgeVilleWebServiceCallout.getBadgevillePlayerInfo('a',1,2.0,'2012-09-14T13:39:50Z');
        test.stoptest();        
    }
    
    
    @isTest(SeeAllData=true)
    public static void testSubmitIdea() {
        test.starttest();
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        bv.badgvilleSubmitIdea();
        test.stoptest();
    }
    @isTest(SeeAllData=true)
    public static void testVoteOnIdea() {
    test.starttest();
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        bv.badgvilleVoteOnIdea();
        test.stoptest();
    }
    @isTest(SeeAllData=true)
    public static void testAnswerQuestion() {
        test.starttest();
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        bv.badgvilleAnswerQuestion();
        test.stoptest();
    }  
    @isTest(SeeAllData=true) 
    public static void testAskQuestion() {
        test.starttest();
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        bv.badgvilleAskQuestion();
        test.stoptest();
    }
    @isTest(SeeAllData=true)  
    public static void testCommentIdea() {
        test.starttest();
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        bv.badgvilleCommentIdea();
        test.stoptest();
    }  
    @isTest(SeeAllData=true)
    public static void testSelectAnswer() {
        test.starttest();
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        bv.badgvilleSelectAnswer();
        test.stoptest();
    }
    @isTest(SeeAllData=true)
    public static void testGiveAFeedback() {
        test.starttest();
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        BadgeVilleWebServiceCallout.badgvilleGiveAFeedback('kA250000000KzX3');
        test.stoptest();
    }
    @isTest(SeeAllData=true)
    public static void testFillProfile() {
        test.starttest();
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        bv.badgvilleFillProfile();
        test.stoptest();
    }
    
    
    @isTest(SeeAllData=true)
     public static void testReceiveBestAnswer() {            
            
            BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
            //bv.partner_supported_instnce = true;
            Reply reply = new Reply();
            Id repId = '90750000000PD3nAAG';//;reply.ID;
            reply = GlobalFunctions.getReplyCreatorDetails(repId);
            bv.bestReplyUser= reply.CreatedById;
            bv.badgvilleReceiveBestAnswer(repId);       
        
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
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        bv.badgvilleAskQuestionStartsDiscussion(quesID);       
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
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        
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
        BadgeVilleWebServiceCallout bv = new BadgeVilleWebServiceCallout();
        //bv.partner_supported_instnce = true;
        badgvillePointsOnAnIdea(ideaID );
        System.debug('GotHere');
    }
}