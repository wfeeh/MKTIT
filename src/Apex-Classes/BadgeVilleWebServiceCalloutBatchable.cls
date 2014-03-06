global Class BadgeVilleWebServiceCalloutBatchable
{
    public static String type
    {
        get {
            type = ApexPages.currentPage().getParameters().get('type')== null?'Contest':ApexPages.currentPage().getParameters().get('type');            
            return type;
        }
        set {
            type = ApexPages.currentPage().getParameters().get('type')== null?'Contest':ApexPages.currentPage().getParameters().get('type');
        }
    } 
    class PlayerPos{
        public String player_id;
        public Integer position;
        public Decimal value;  
        public String upDtTime; 
        public String email;
        public String disp_name;
        public String pic_url;                   
        public PlayerPos(String pid, Integer pos,Decimal val,String updtm,String eml,String d_name, String p_url) {
            this.player_id = pid;
            this.position = pos;
            this.value = val;
            this.upDtTime = updtm; 
            this.email = eml;
            this.disp_name= d_name;
            this.pic_url = p_url;
        }                       
    }   
    
    public static void updateLeaderBoard()
    {
        if(type == null || type=='')
        {
            updateLeaderBoard('Daily');             
        }
        else
        {
            updateLeaderBoard(type);             
        }           
    }
    
    @future (callout=true)
    public static void updateLeaderBoard(String lbDataType)
    {
        
        //String badgvilleUrl  = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;//'http://api.v2.badgeville.com/api/berlin/b95839370dca983955e550296450ec03';
        //String badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;//'www.marketo1.com';
        
        String badgvilleUrl  = BadgevilleSettings__c.getInstance('BadgevilleSettings').BadgvilleApiUrl__c;
        String badgvilleSite = BadgevilleSettings__c.getInstance('BadgevilleSettings').BadgvilleSite__c;
        
        
        String badgvilleLBId = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').DailyLeaderBoardID__c;//'4f3536bc3dc64842ce000406';
        if(lbDataType == 'Daily')
        {
            badgvilleLBId = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').DailyLeaderBoardID__c;//'4f3536bc3dc64842ce000406';
        }
        else if(lbDataType == 'Weekly')
        {
            badgvilleLBId = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').WeeklyLeaderBoardID__c;//'50487e08cb2ad40b05002568'
        }
        else if(lbDataType == 'Monthly')
        {
            badgvilleLBId = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').MonthlyLeaderBoardID__c;//'50be700b880af10c4d00bc94';
        }
        else if(lbDataType == 'Contest')
        {
            badgvilleLBId = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').ContestLeaderBoardID__c; //'50b68a2d64b8cb19ef001c8a';                      
        }                
                        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();        
        req.setEndpoint(badgvilleUrl+'/leaderboards/'+badgvilleLBId+'.json?site='+badgvilleSite+'&full_objects=true');                       
        if(lbDataType == 'Contest')
            req.setEndpoint(badgvilleUrl+'/leaderboards/'+badgvilleLBId+'.json?site='+badgvilleSite+'&per_page=20&full_objects=true');
        
        req.setMethod('GET');
        String JSONContent = '';                                
        Boolean playerExists = true;
        List<PlayerPos> myPlayerList = new List<PlayerPos>();
        try 
        { 
            if(test.isRunningTest())
            {
                JSONContent = '{"errors":[{"error":"invalid ObjectId"}]}';                
            }            
            else            
            {            
                res =  http.send(req);           
                System.debug(res.getBody());
                JSONContent = res.getBody();
            }
            {
                if(JSONContent.contains('"error": "invalid ObjectId"'))
                {
                    //No Data Found  
                    System.debug('No Player Data Found'); 
                }
                else
                {    
                    if(test.isRunningTest())
                    {
                        PlayerPos myPos = new PlayerPos('pid',1,1.0,'upDt','email','disp_name','pic_url');                            
                        myPlayerList.Add(myPos);                        
                    }
                    else                    
                    {                                  
                        System.JSONParser parser = JSON.createParser(JSONContent);                    
                        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContent);                                        
                        Map<String, Object> a = (Map<String, Object>) m.get('data');                    
                        List<Object> b = (List<Object>) a.get('positions');                     
                        for (Object c : b){                    
                            System.debug('c==>' + c);
                            Map<String, Object> d = (Map<String, Object>) c;
                            for (String key:d.keySet()){
                                String pid = '';Integer pos = 0;Decimal val = 0.0; String upDt; 
                                String email = ''; String disp_name='';String pic_url = '';
                                Map<String, Object> e = (Map<String, Object>) d.get(key);
                                System.debug('evalue== ' + e);                            
                                pid = (string) e.get('player_id');
                                pos = (integer)e.get('position');
                                val = (decimal)e.get('value');
                                upDt = (string)e.get('updated_at');                                                        
                                Map<String, Object> m2 = (Map<String, Object>)e.get('player');                                                                     
                                System.debug('m2==>' + m2);
                                Map<String, Object> e2 = (Map<String, Object>) m2;                            
                                email = (string)e2.get('email');
                                disp_name = (string)e2.get('display_name');
                                pic_url = (string)e2.get('picture_url');                                                        
                                PlayerPos myPos = new PlayerPos(pid,pos,val,upDt,email,disp_name,pic_url);                            
                                myPlayerList.Add(myPos);                            
                            }                                            
                        } 
                    }                   
                    if(myPlayerList.size() > 0)
                    {
                        BadgeVilleLeaderBoard__c[] doomedRecs = [SELECT Id FROM BadgeVilleLeaderBoard__c WHERE LeaderBoardDataType__c =: lbDataType]; 
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
                                myRec.PlayerEmail__c = myPL.email.split('@').get(0);
                                myRec.display_name__c = myPL.disp_name;
                                myRec.PicURL__c = myPL.pic_url;
                                myRec.LeaderBoardDataType__c = lbDataType;
                                recsList.add(myRec );                                
                            } 
                            insert recsList;                           
                        } 
                        catch (DmlException e) {
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
    public static void getDailyContestPlayerList(String lbDate)
    {        
        //Prod
        //String badgvilleUrl  = 'http://api.v2.badgeville.com/api/berlin/b95839370dca983955e550296450ec03';
        //String badgvilleSite = 'www.marketo1.com';
        //String badgvilleRwrdId = '50b67a21e75768491e001acc';        
        String badgvilleUrl  = BadgevilleSettings__c.getInstance('BadgevilleSettings').BadgvilleApiUrl__c;
        String badgvilleSite = BadgevilleSettings__c.getInstance('BadgevilleSettings').BadgvilleSite__c;

        //String badgvilleRwrdId = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').RewardID__c;
        String badgvilleRwrdId = BadgeVilleLeaderBoards__c.getInstance('MyBadgeVilleLBs').RewardID__c;
                                  
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl+'/rewards.json?site='+badgvilleSite + '&definition_id='+ badgvilleRwrdId +'&include_totals=true');                       
        req.setMethod('GET');
        String JSONContent = '';                        
        
        Boolean playerExists = true;
        try {                         
            if(test.IsRunningTest())
            {                
                JSONContent = '{"data":[{"name":"Contest Entry","created_at":"2012-12-03T15:35:08-08:00","activity_id":"50bd372c3dc6486088003962","id":"50bd372c3dc6486088003964","user_id":"50bd3643297c010d8000063e","site_id":"4f4379a23dc6483f35000789","player_id":"50bd3643297c010d8000063f","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","history":{"toast":{"50bd3643297c010d8000063f":"2012-12-03T23:35:09Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":4,"next_reward_id":null},{"name":"Contest Entry","created_at":"2012-12-03T15:32:39-08:00","activity_id":"50bd36963dc64838de0038ad","id":"50bd36973dc64838de0038b1","user_id":"50bd3643297c010d8000063e","site_id":"4f4379a23dc6483f35000789","player_id":"50bd3643297c010d8000063f","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","history":{"toast":{"50bd3643297c010d8000063f":"2012-12-03T23:32:41Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":4,"next_reward_id":null},{"name":"Contest Entry","created_at":"2012-12-03T15:32:25-08:00","activity_id":"50bd368949f8383f140003f0","id":"50bd368949f8383f140003f2","user_id":"50bd3643297c010d8000063e","site_id":"4f4379a23dc6483f35000789","player_id":"50bd3643297c010d8000063f","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","history":{"toast":{"50bd3643297c010d8000063f":"2012-12-03T23:32:26Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":4,"next_reward_id":null},{"name":"Contest Entry","created_at":"2012-12-03T15:32:11-08:00","activity_id":"50bd367b4dd625388c003dc7","id":"50bd367b4dd625388c003dca","user_id":"50bd3643297c010d8000063e","site_id":"4f4379a23dc6483f35000789","player_id":"50bd3643297c010d8000063f","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","history":{"toast":{"50bd3643297c010d8000063f":"2012-12-03T23:32:13Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":4,"next_reward_id":null},{"name":"Contest Entry","created_at":"2012-12-03T14:43:29-08:00","activity_id":"50bd2b1149f8383f140003a6","id":"50bd2b1149f8383f140003a8","user_id":"50bd2adf3dc64860880038fd","site_id":"4f4379a23dc6483f35000789","player_id":"50bd2adf3dc64860880038fe","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 7 entries, so keep up the good work.","history":{"toast":{"50bd2adf3dc64860880038fe":"2012-12-03T22:43:31Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":6,"next_reward_id":null},{"name":"Contest Entry","created_at":"2012-12-03T14:43:09-08:00","activity_id":"50bd2afd297c010d800005f2","id":"50bd2afd297c010d800005f4","user_id":"50bd2adf3dc64860880038fd","site_id":"4f4379a23dc6483f35000789","player_id":"50bd2adf3dc64860880038fe","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 7 entries, so keep up the good work.","history":{"toast":{"50bd2adf3dc64860880038fe":"2012-12-03T22:43:11Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":6,"next_reward_id":null},{"name":"Contest Entry","created_at":"2012-12-03T14:43:04-08:00","activity_id":"50bd2af7297c0148090061ed","id":"50bd2af8297c0148090061ef","user_id":"50bd2adf3dc64860880038fd","site_id":"4f4379a23dc6483f35000789","player_id":"50bd2adf3dc64860880038fe","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 7 entries, so keep up the good work.","history":{"toast":{"50bd2adf3dc64860880038fe":"2012-12-03T22:43:05Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":6,"next_reward_id":null},{"name":"Contest Entry","created_at":"2012-12-03T14:42:58-08:00","activity_id":"50bd2af249f8383ecb000438","id":"50bd2af249f8383ecb00043d","user_id":"50bd2adf3dc64860880038fd","site_id":"4f4379a23dc6483f35000789","player_id":"50bd2adf3dc64860880038fe","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 7 entries, so keep up the good work.","history":{"toast":{"50bd2adf3dc64860880038fe":"2012-12-03T22:43:00Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":6,"next_reward_id":null},{"name":"Contest Entry","created_at":"2012-12-03T14:42:52-08:00","activity_id":"50bd2aec4dd62551ff0006ee","id":"50bd2aec4dd62551ff0006f1","user_id":"50bd2adf3dc64860880038fd","site_id":"4f4379a23dc6483f35000789","player_id":"50bd2adf3dc64860880038fe","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 7 entries, so keep up the good work.","history":{"toast":{"50bd2adf3dc64860880038fe":"2012-12-03T22:42:54Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":6,"next_reward_id":null},{"name":"Contest Entry","created_at":"2012-12-03T14:42:45-08:00","activity_id":"50bd2ae53dc64860880038ff","id":"50bd2ae53dc6486088003902","user_id":"50bd2adf3dc64860880038fd","site_id":"4f4379a23dc6483f35000789","player_id":"50bd2adf3dc64860880038fe","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 7 entries, so keep up the good work.","history":{"toast":{"50bd2adf3dc64860880038fe":"2012-12-03T22:42:47Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":6,"next_reward_id":null}],"paging":{"current_page":1,"per_page":10,"total_entries":76,"total_pages":8}}';                                            
            } else {                                              
                res =  http.send(req); 
                JSONContent = res.getBody(); 
                System.debug('JSONContent ==>' + JSONContent );         
            }                       
            if(JSONContent.contains('"error": "invalid ObjectId"'))
            {
                //No Data Found  
                System.debug('No Player Data Found'); 
            }
            else
            {                                      
                System.JSONParser parser = JSON.createParser(JSONContent);
                Integer total_entries = 0; 
                if(test.IsRunningTest())
                {
                    total_entries = 10;                       
                } else {
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContent);                                        
                    Map<String, Object> a = (Map<String, Object>) m.get('paging');  
                    total_entries = (INTEGER) a.get('total_entries');
                }                
                BadgeVilleContestDailyWinner__c tEntry = new BadgeVilleContestDailyWinner__c();
                tEntry.Contest_Date__c = Date.today();
                tEntry.Reward_ID__c = badgvilleRwrdId;
                tEntry.Total_Entries__c = total_entries;
                tEntry.Winner_Player_Id__c = '';
                tEntry.Winning_Entry__c = 0;
                Insert tEntry;                                                                                                                                    
            }                                                              
        }
        catch(Exception ex)
        {
            System.Debug('Exception->' + ex);
        }
    }    
    
    @future (callout=true)
    public static void setDailyContestWinner(String lbDate)
    {
        //Prod
        //String badgvilleUrl  = 'http://api.v2.badgeville.com/api/berlin/b95839370dca983955e550296450ec03';
        //String badgvilleSite = 'www.marketo1.com';
        //String badgvilleRwrdId = '50b67a21e75768491e001acc';                       
        //String badgvilleUrl  = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
        //String badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;         
        //String badgvilleRwrdId = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').RewardID__c;                                
        //String badgvilleRwrdId = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').RewardID__c;
        String badgvilleUrl  = BadgevilleSettings__c.getInstance('BadgevilleSettings').BadgvilleApiUrl__c;
        String badgvilleSite = BadgevilleSettings__c.getInstance('BadgevilleSettings').BadgvilleSite__c;
        String badgvilleRwrdId = BadgeVilleLeaderBoards__c.getInstance('MyBadgeVilleLBs').RewardID__c;

        Integer total_count = [SELECT Count() from BadgeVilleContestDailyWinner__c Where Contest_Date__c = : Date.today() LIMIT 1];
        if(total_count == 0){ System.debug('Contest Entry Count=0'); return; }
               
        BadgeVilleContestDailyWinner__c tEntry = new BadgeVilleContestDailyWinner__c();
        tEntry = [SELECT Contest_Date__c,Reward_ID__c, Total_Entries__c,Winner_Player_Id__c,Winning_Entry__c from BadgeVilleContestDailyWinner__c Where Contest_Date__c = : Date.today() LIMIT 1];
        Integer rand_no = Math.floor(Math.random() * tEntry.Total_Entries__c).intValue();
        System.debug('rand_no=>' + rand_no);

        String JSONContent = '';                                
        Boolean playerExists = true;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String myEndpPoint = badgvilleUrl+'/rewards.json?site='+badgvilleSite + '&definition_id='+ badgvilleRwrdId +'&include_totals=true&per_page=1&page='+rand_no;
        //req.setEndpoint(badgvilleUrl+'/rewards.json?site='+badgvilleSite + '&definition_id='+ badgvilleRwrdId +'&include_totals=true&per_page=1&page='+rand_no);                       
        req.setMethod('GET');     
        req.setEndpoint(myEndpPoint);         
        try { 
            if(test.IsRunningTest())
            {
                //JSONContent = '{"data":[{"name":"Contest Entry","created_at":"2012-12-03T15:32:39-08:00","activity_id":"50bd36963dc64838de0038ad","id":"50bd36973dc64838de0038b1","user_id":"50bd3643297c010d8000063e","site_id":"4f4379a23dc6483f35000789","player_id":"50bd3643297c010d8000063f","definition":{"type":"rewarddefinition","name":"Contest Entry","created_at":"2012-11-27T21:57:29-08:00","assignable":true,"allow_duplicates":true,"components":"[{\"command\":\"count\",\"comparator\":1,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":5,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":10,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":15,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}},{\"command\":\"count\",\"comparator\":20,\"where\":{\"verb\":{\"$in\":[\"submit an idea\",\"answer a question\",\"ask a question\"]},\"player_id\":\"%player_id\",\"created_at\":{\"$gt\":{\"$time\":\"11/29/2012 00:00:00\"},\"$lt\":{\"$time\":\"12/07/2012 00:00:00\"}}}}]","reward_template":{"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work."},"tags":"","site_id":"4f4379a23dc6483f35000789","image_url":"//s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","image_file_name":"2nd_bday_badge.png","data":{},"_id":"50b5a7c849f8386864000590","id":"50b5a7c849f8386864000590","active":true,"hint":"Contest Reward","message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","adjustment":{},"active_start_at":null,"active_end_at":null,"time_frame":null,"interval_start":null,"interval_end":null,"performed_by":null,"reward_team_members":false},"image":"http://s3.amazonaws.com/badgeville-production-reward-definitions/images/50b5a7c849f8386864000590/original.png?1354554976","tags":[],"status":null,"message":"Congratulations! You have earned an entry into the Birthday Sweepstakes. You can earn up to 5 entries, so keep up the good work.","history":{"toast":{"50bd3643297c010d8000063f":"2012-12-03T23:32:41Z"},"facebook":null,"twitter":null,"email":null},"reward_counter":4,"next_reward_id":null}],"paging":{"current_page":2,"per_page":1,"total_entries":76,"total_pages":76}}';
                JSONContent = '{"errors":[{"error":"invalid ObjectId"}]}';
            } else {                                                       
                res =  http.send(req); 
                JSONContent = res.getBody();     
                System.debug('JSONContent==>'+JSONContent);    
            }                                    
            
            if(JSONContent.contains('"error": "invalid'))
            {
                //System.JSONParser parser = JSON.createParser(JSONContent);
                //No Data Found  
                System.debug('No Player Data Found'); 
                //playerExists  = false;                                                                                     
            }
            else
            {
                System.JSONParser parser = JSON.createParser(JSONContent);
                //List<PlayerPos> myPlayerList = new List<PlayerPos>();
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContent);                                        
                List<Object> b = (List<Object>) m.get('data');
                Boolean found = false;                     
                for (Object c : b){ 
                    if(!found){                                          
                        Map<String, Object> d = (Map<String, Object>) c;
                        for (String key:d.keySet()){
                            if(key =='player_id')
                            {                            
                                String pid = (string) d.get(key);
                                tEntry.Winner_Player_Id__c = pid; 
                                tEntry.Winning_Entry__c = rand_no;                                      
                                update tEntry;
                                found = true;
                                break;                                                                                             
                            }                            
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
    
    
   
    
    //@future (callout=true)
    public static void manualRewardCallout(String userId,String verb,Id certHistId) {        
        //String BehaviorId = '515534cd88b6161f92000024';
        
        String badgvilleUrl = '';
        String badgvilleSite = '';        

        if(!Test.isRunningTest()) {
            badgvilleUrl = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
            badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;                        
        } 
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl+'/players/info.json?site='+badgvilleSite+'&email='+userId+'@marketo.com');
        req.setMethod('GET');
        String JSONContent = '';
        String plyrID = ''; 
        String plyrNickName;
        Boolean playerExists = true;
        try {   
            if(Test.isRunningTest() == false) {
                res =  http.send(req);           
                System.debug(res.getBody());
                JSONContent = res.getBody();            
            } else {
                JSONContent = '{"data":{"_id":"5177cd4e88b6164eba0035cb","id":"5177cd4e88b6164eba0035cb","name":null,"first_name":null,"last_name":null,"display_name":"Bikki","nick_name":null,"email":"005W0000000yGL6IAM@marketo.com","user_email":"005W0000000yGL6IAM@marketo.com","created_at":"2013-04-24T05:17:18-07:00","user_id":"5177cd4e88b6164eba0035ca","site_id":"4f4379a23dc6483f35000789","site_url":"www.grazitti.com","admin":false,"points_day":0.0,"points_week":130.0,"points_month":130.0,"points_all":130.0,"points_interval":0.0,"facebook_id":null,"facebook_link":null,"twitter_id":null,"twitter_username":null,"twitter_link":null,"email_notifications":true,"custom_picture_url":null,"picture_url":"/resource/1366785192000/Marketo_New_Community/images/global/default_profile.png","preferences":{"email_notifications":true,"hide_notifications":false,"publish_activity":true,"twitter":false},"teams":[],"social_networks":[],"units":{"points_day":0.0,"points_week":130.0,"points_month":130.0,"points_all":130.0,"points_interval":0.0,"followers_all":0,"following_all":0}},"paging":null}';          
            }
                                   
            if(JSONContent.contains('{"errors":[{"error":"invalid player"}]}'))
            {
                //User does not exist in badgeville create one 
                 /*       HttpRequest req2 = new HttpRequest();
                HttpResponse res2 = new HttpResponse();
                Http http2 = new Http(); 
                req2.setEndpoint( badgvilleUrl + '/players.json' );
                req2.setMethod('POST');
                //email=<PLAYER_EMAIL>&site=<SITE_URL>'
                req2.setBody('&site='+badgvilleSite+'&email='+ userId+'@marketo.com');                      
                
                
                try {
                    if(Test.isRunningTest() == false) {
                        res2 = http.send(req2);
                        System.debug('res-->' + res2.toString());
                        String retStatus2 = res2.getStatus();
                        JSONContent = res2.getBody();
                    } else {
                        System.debug('<-TestRunning->');
                    }        
            
               } catch(System.CalloutException e) {
                    System.debug('Callout error: '+ e);            
               }
                  
               System.debug('Player error invalid player'); 
               playerExists  = true; */  
               System.debug('Player error invalid player'); 
               playerExists  = false;                                                                                     
            }
           
                JSONParser parser =    JSON.createParser(JSONContent);
                while (parser.nextToken() != null) {
                    System.debug('Current token: ' +  parser.getCurrentToken());
                    // Advance to the next value.                        
                    parser.nextValue();
                    // Get the field name for the current value.                        
                    String fieldName = parser.getCurrentName();
                    if(fieldName == '_id')
                    {
                        // Get the textual representation of the value.   
                        System.debug('fieldName ==_id');                       
                        plyrID  = parser.getText();
                        playerExists = true;
                        break;
                    }
                }
                if((plyrID != '') && (playerExists  == true))
                {   
                    system.debug('[player_id]====>'+ plyrID );                     
                    HttpRequest req1 = new HttpRequest();
                    HttpResponse res1 = new HttpResponse();
                    Http http1 = new Http(); 
                    req1.setEndpoint( badgvilleUrl + '/rewards.json' );
                    req1.setMethod('POST');
                    req1.setBody(verb + '&site='+badgvilleSite+'&user='+ userId+'@marketo.com');
                    //req1.setBody('reward[site_id]=4f4379a23dc6483f35000789&reward[player_id]='+ plyrID + '&reward[definition_id]='+verb+'');  
                    req1.setBody('reward[site_id]=503c588b1dcf7d3fc200094c&reward[player_id]='+ plyrID + '&reward[definition_id]='+verb+'');                      
                    
                    System.debug('manualRewardCallout=>' + verb + userId);
                    try {
                        if(Test.isRunningTest() == false) {
                            res1 = http.send(req1);
                            System.debug('res-->' + res.toString());
                            String retStatus = res.getStatus();
                        } else {
                            System.debug('<-TestRunning->');
                        }         
                        List<Certification_History__c> certifiedHistRec = [SELECT Id,BadgeVilleReward_Status__c from Certification_History__c Where id =:certHistId Limit 1];
                        if(certifiedHistRec.isEmpty() == false) {                            
                            certifiedHistRec[0].BadgeVilleReward_Status__c = true;
                            update certifiedHistRec;                        
                        }           
                    } catch(System.CalloutException e) {
                        System.debug('Callout error: '+ e);            
                    }
                } 
                     
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);            
        }           
    }   
    
    //@future (callout=true)
    public static void deleteRewardCallout(String userId,String verb,Id certHistId) {        
        //String BehaviorId = '515534cd88b6161f92000024';
        
        String badgvilleUrl = '';
        String badgvilleSite = '';        

        if(!Test.isRunningTest()) {
            badgvilleUrl = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
            badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;                        
        } 
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setEndpoint(badgvilleUrl+'/players/info.json?site='+badgvilleSite+'&email='+userId+'@marketo.com');
        req.setMethod('GET');
        String JSONContent = '';
        String plyrID = ''; 
        String rewardID = '';
        String plyrNickName;
        Boolean playerExists = true;
        try {   
            if(Test.isRunningTest() == false) {
                res =  http.send(req);           
                System.debug(res.getBody());
                JSONContent = res.getBody();            
            } else {
                JSONContent = '{"data":{"_id":"5177cd4e88b6164eba0035cb","id":"5177cd4e88b6164eba0035cb","name":null,"first_name":null,"last_name":null,"display_name":"Bikki","nick_name":null,"email":"005W0000000yGL6IAM@marketo.com","user_email":"005W0000000yGL6IAM@marketo.com","created_at":"2013-04-24T05:17:18-07:00","user_id":"5177cd4e88b6164eba0035ca","site_id":"4f4379a23dc6483f35000789","site_url":"www.grazitti.com","admin":false,"points_day":0.0,"points_week":130.0,"points_month":130.0,"points_all":130.0,"points_interval":0.0,"facebook_id":null,"facebook_link":null,"twitter_id":null,"twitter_username":null,"twitter_link":null,"email_notifications":true,"custom_picture_url":null,"picture_url":"/resource/1366785192000/Marketo_New_Community/images/global/default_profile.png","preferences":{"email_notifications":true,"hide_notifications":false,"publish_activity":true,"twitter":false},"teams":[],"social_networks":[],"units":{"points_day":0.0,"points_week":130.0,"points_month":130.0,"points_all":130.0,"points_interval":0.0,"followers_all":0,"following_all":0}},"paging":null}';          
            }
                                   
            if(JSONContent.contains('{"errors":[{"error":"invalid player"}]}'))
            {
                //User does not exist in badgeville create one   
                System.debug('Player error invalid player'); 
                playerExists  = false;                                                                                     
            }
            else
            {
                JSONParser parser =    JSON.createParser(JSONContent);
                while (parser.nextToken() != null) {
                    System.debug('Current token: ' +  parser.getCurrentToken());
                    // Advance to the next value.                        
                    parser.nextValue();
                    // Get the field name for the current value.                        
                    String fieldName = parser.getCurrentName();
                    if(fieldName == '_id')
                    {
                        // Get the textual representation of the value.   
                        System.debug('fieldName ==_id');                       
                        plyrID  = parser.getText();
                        playerExists = true;
                        break;
                    }
                }
                if((plyrID != '') && (playerExists  == true))
                {   
                    system.debug('[player_idexists]====>'+ plyrID );   
                    system.debug('[definition_id]====>'+ verb);                     
                    HttpRequest req2 = new HttpRequest();
                    HttpResponse res2 = new HttpResponse();
                    Http http2 = new Http(); 
                    
                    req2.setEndpoint(badgvilleUrl+'/rewards.json?player_id='+plyrID+'&definition_id='+verb);
                    req2.setMethod('GET');                   
                    if(Test.isRunningTest() == false) {
                        res2 =  http2.send(req2);           
                        System.debug(res2.getBody());
                        JSONContent = res2.getBody();
                   } 
                    JSONParser parser1 =    JSON.createParser(JSONContent);
                    while (parser1.nextToken() != null) {
                        System.debug('Current token: ' +  parser1.getCurrentToken());
                        // Advance to the next value.                        
                        parser1.nextValue();
                        // Get the field name for the current value.                        
                        String fieldName = parser1.getCurrentName();
                        System.debug('fieldName ==id'+fieldName );   
                        if(fieldName == 'id')
                        {
                            // Get the textual representation of the value.   
                                                
                            rewardID  = parser1.getText(); 
                            system.debug('[rewardID]====>'+ rewardID);                          
                            break;
                        }                    
                    
                    }
                    
                    if (rewardID != ''){                    
                        HttpRequest req3 = new HttpRequest();
                        HttpResponse res3 = new HttpResponse();
                        Http http3 = new Http();                     
                        req3.setEndpoint(badgvilleUrl+'/rewards/'+rewardID+'.json');
                        req3.setMethod('DELETE');                        
                         if(Test.isRunningTest() == false) {
                            res3 = http3.send(req3);
                            System.debug('res3-->' + res3.toString());
                            String retStatus = res3.getStatus();
                        } else {
                            System.debug('<-TestRunning->');
                        }       
                    
                    }
                    
                    
                   try {
                       /* if(Test.isRunningTest() == false) {
                            res1 = http.send(req1);
                            System.debug('res-->' + res.toString());
                            String retStatus = res.getStatus();
                        } else {
                            System.debug('<-TestRunning->');
                        }*/        
                        List<Certification_History__c> certifiedHistRec = [SELECT Id,BadgeVilleReward_Status__c from Certification_History__c Where id =:certHistId Limit 1];
                        if(certifiedHistRec.isEmpty() == false) {                            
                            certifiedHistRec[0].BadgeVilleReward_Status__c = false;
                            update certifiedHistRec;                        
                        }           
                    } catch(System.CalloutException e) {
                        System.debug('Callout error: '+ e);            
                    }
                } 
            }          
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);            
        }           
    }   
    
    
    
    
    
    @isTest(SeeAllData=true)
    public static void testBadgeVilleCalls() {
        PlayerPos myPos = new PlayerPos('pid',1,1.0,'upDt','email','disp_name','pic_url'); 
        Test.starttest();
        BadgeVilleWebServiceCalloutBatchable.updateLeaderBoard();        
        BadgeVilleWebServiceCalloutBatchable.updateLeaderBoard('Weekly'); 
        BadgeVilleWebServiceCalloutBatchable.updateLeaderBoard('Monthly'); 
        BadgeVilleWebServiceCalloutBatchable.updateLeaderBoard('Contest'); 
        BadgeVilleWebServiceCalloutBatchable.getDailyContestPlayerList('Test');    
        
        BadgeVilleContestDailyWinner__c tEntry = new BadgeVilleContestDailyWinner__c();
        tEntry.Contest_Date__c = Date.today();
        tEntry.Reward_ID__c = 'asdfsa';
        tEntry.Total_Entries__c = 10;
        tEntry.Winner_Player_Id__c = '';
        tEntry.Winning_Entry__c = 0;
        Insert tEntry;                  
        BadgeVilleWebServiceCalloutBatchable.setDailyContestWinner('Test');
    
        //test case manual rewards    
        Map<Id,User> supprtdUserMap = new Map<Id,User>([SELECT Id,Email,ContactId, FirstName From User Where isPortalEnabled = true AND Munchkin_ID__c != null Limit 10]);
        
        Set<Id> supprtdUserIds = new Set<Id>();
        supprtdUserIds.AddAll(supprtdUserMap.keySet());          
        Map<Id,Boolean> validUserIdsMap = new Map<Id,Boolean>();
        validUserIdsMap = GlobalFunctions.getPartner_Supported_Status_ForUsers(supprtdUserIds);
        
        if(validUserIdsMap.isEmpty() == false)    
        {
            for(Id tmpId : validUserIdsMap.keySet())
            {
                if(validUserIdsMap.get(tmpId)==true) {                
                    Certification_History__c certiUser = new Certification_History__c();
                    certiUser.Certification_Contact__c = supprtdUserMap.get(tmpId).ContactId;
                    certiUser.Personal_Email_Address__c = supprtdUserMap.get(tmpId).Email; 
                    certiUser.Business_Email_Address__c = supprtdUserMap.get(tmpId).Email; 
                    certiUser.Exam_Result__c = 'Pass'; 
                    certiUser.Certification_level__c = 'Marketo Certified Expert';
                    certiUser.Date_Exam_Taken__c = Date.Today(); 
                    insert certiUser;
                                        
                    break;
                }
            }
        }    
        Test.stoptest();
    }  
    
}