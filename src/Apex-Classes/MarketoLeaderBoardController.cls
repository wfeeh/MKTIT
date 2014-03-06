public class MarketoLeaderBoardController{
    public Boolean upDtLB{get;set;}
    public String selectedLBType {get;set;}
    public String chosenEntry {get;set;}
    public Boolean isContestLBUp{get;set;}
    public Boolean isContestRunning{get;set;}        
    public MarketoLeaderBoardController()
    {
        isContestRunning = BadgeVilleLeaderBoards__c.getAll().get('MyBadgeVilleLBs').IsContestRuning__c;
        selectedLBType = getUserSelectedLBType();    
        upDtLB = false;        
    }
    public String leaderboardLastUpdated{get;set;}    
    public List<BadgeVilleLeaderBoard__c> getBadgevilleLeaderboard(){
        selectedLBType = getUserSelectedLBType();
        try
        {
            List<BadgeVilleLeaderBoard__c> bvplayers =  [Select Id, PicURL__c,display_name__c,PlayerEmail__c,PlayerID__c,Position__c,Value__c,Updated_DateTime__c from BadgeVilleLeaderBoard__c Where LeaderBoardDataType__c = :selectedLBType order by Position__c LIMIT :10];
            /* __NEED_FIX_AFTER_BVILLE_DATA_FORMAT_CHANGE__  vishals@grazitti.com 20_03_13 
            //System.Debug('LBPLAYERS'+bvplayers); 2012-09-17T11:29:00Z
            String BvilleLastUpdatedDateTimeString = bvplayers.get(0).Updated_DateTime__c;
            //Datetime dt         = DateTime.parse('09/17/2012 05:00 AM'); 
            List<String> bVilleLastUodatedDateArray =  BvilleLastUpdatedDateTimeString.split('T')[0].split('-');
            List<String> bVilleLastUpdatedTimeArray =  BvilleLastUpdatedDateTimeString.split('T')[1].split(':');
            String am_pm = integer.valueof(bVilleLastUpdatedTimeArray[0])>=12?'PM':'AM';
            Integer hrs = integer.valueof(bVilleLastUpdatedTimeArray[0])>=12?(integer.valueof(bVilleLastUpdatedTimeArray[0])-12):integer.valueof(bVilleLastUpdatedTimeArray[0]);
            Datetime bVilleLastUpDate = DateTime.parse(bVilleLastUodatedDateArray[1]+'/'+bVilleLastUodatedDateArray[2]+'/'+bVilleLastUodatedDateArray[0]+' '+hrs+':'+bVilleLastUpdatedTimeArray[1]+' '+am_pm); 
            
            Datetime currentDateTimeLocal = Datetime.now();
            Datetime currentDateTimeGMT   = DateTime.parse(currentDateTimeLocal.formatGmt('MM/dd/yyyy hh:mm a')); 
            
            Long differenceInMilis = currentDateTimeGMT.getTime()-bVilleLastUpDate.getTime();//String.valueof((differenceInMilis/1000)/60);
            leaderboardLastUpdated = String.valueof((differenceInMilis/1000)/60);//String.valueof(currentDateTimeGMT.getTime())+'__'+String.valueof(bVilleLastUpDate.getTime())+'ACTUALDATES_'+currentDateTimeGMT.format()+'___'+bVilleLastUpDate.format();
            Long minDelay = getMinutesBetween(bVilleLastUpDate,currentDateTimeGMT);
            Long hrsDelay = getHoursBetween(bVilleLastUpDate,currentDateTimeGMT);                
            if(hrsDelay>1) {leaderboardLastUpdated = String.valueof(hrsDelay) + ' hours ago'; }        
            else if(hrsDelay == 1) {leaderboardLastUpdated = String.valueof(hrsDelay) + ' hour ago'; }
            else 
            {
                if(minDelay>1){leaderboardLastUpdated = ' ' + String.valueof(minDelay) + ' minutes ago';}
                else if(minDelay == 1 ){leaderboardLastUpdated = '' + String.valueof(minDelay) + ' minute ago'; }
                else {leaderboardLastUpdated = 'less than a minute ago';}
            } */
            leaderboardLastUpdated = 'less than a minute ago';
            return bvplayers;             
        
        }
        catch (Exception ex)
        {
            System.Debug('Exception===>' + ex);
        }
        //String.valueof((differenceInMilis/1000)/60);//bVilleLastUpDate.format()+'___'+currentDateTime.formatGmt('dd/MM/yyyy hh:mm:ss a'); //bvplayers.get(0).Updated_DateTime__c;//myDateTime.formatGmt('dd/MM/yyyy hh:mm:ss a');//bvplayers.get(0).Updated_DateTime__c;//String.valueof(millis);
        return null;
    }
    
    public Long getSecondsBetween(Datetime dt1, Datetime dt2)
    {
        Long secondsBetween = dt2.getTime() - dt1.getTime();
        return Math.abs(secondsBetween);
    } 
    
    // Given the number of seconds between two date/times, 
    // calculate the number of minutes. Fractional minutes are dropped.
    public Long getMinutesBetween(Datetime dt1, Datetime dt2)
    {
        return (getSecondsBetween(dt1, dt2) / 60000L);
    }
    // Calculate the number of hours. Fractional hours are dropped.
    public Long getHoursBetween(Datetime dt1, Datetime dt2)
    {
        return (getSecondsBetween(dt1, dt2) / (60000L * 60L));
    }
    
    public String getUserSelectedLBType()
    {        
        try {
            String tmpstr;
            Community_Profile__c profile = [select Id, DefaultLeaderboardType__c,ContestLeaderBoardUp__c from Community_Profile__c where User__c = :UserInfo.getUserId() LIMIT 1];
            if(profile.ContestLeaderBoardUp__c == null) {isContestLBUp = false;} else {isContestLBUp = profile.ContestLeaderBoardUp__c;}      
            if(profile.DefaultLeaderboardType__c == null) {tmpstr = 'Weekly';} else {tmpstr = profile.DefaultLeaderboardType__c;}      
            return tmpStr;                    
        } catch (Exception e) {           
            // An exception will be thrown if no record exists yet.            
        }
        return 'Weekly';        
    }
    
    public List<SelectOption> getLeaderboardtypes()
    {
       List<SelectOption> options = new List<SelectOption>();            
       Schema.DescribeFieldResult fieldResult =  Community_Profile__c.DefaultLeaderboardType__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    
    public PageReference saveContestLBContext() {
        Boolean saveContext = false;       
        String contextData = Apexpages.currentPage().getParameters().get('chosenEntry');      
        System.debug('contextData  =>' + contextData );
        if(contextData == '1') saveContext = true;                                          
        try { 
            Integer prfCount = [select Count() from Community_Profile__c where User__c = :UserInfo.getUserId() LIMIT 1];
            if(prfCount >0)         
            {           
                Community_Profile__c profile = [select Id, ContestLeaderBoardUp__c from Community_Profile__c where User__c = :UserInfo.getUserId() LIMIT 1];
                profile.ContestLeaderBoardUp__c = saveContext;            
                update profile;                                        
            }
            else
            {
                User profileUser = [select Id,ContactId, FirstName, LastName from User where Id = :UserInfo.getUserId()];
                Community_Profile__c profile = new Community_Profile__c();
                profile.User__c = UserInfo.getUserId();
                profile.Display_Name__c = profileUser.FirstName + ' ' + profileUser.LastName.substring(0, 1);
                profile.ContestLeaderBoardUp__c = saveContext; 
                upsert profile;                                            
            }            
        } catch (Exception e) {           
            // An exception will be thrown if no record exists yet. 
            System.Debug('Exception e===>' + e);           
        }                       
        return null;       
    }  
        
    public PageReference setOption() {       
        selectedLBType = Apexpages.currentPage().getParameters().get('chosenEntry');      
        chosenEntry = selectedLBType;                                          
        try {   
            Integer prfCount = [select Count() from Community_Profile__c where User__c = :UserInfo.getUserId() LIMIT 1];
            if(prfCount > 0)         
            {
                Community_Profile__c profile = [select Id, DefaultLeaderboardType__c from Community_Profile__c where User__c = :UserInfo.getUserId() LIMIT 1];
                profile.DefaultLeaderboardType__c = selectedLBType;  
                profile.ContestLeaderBoardUp__c = false;                        
                update profile;                        
            }
            else
            {
                User profileUser = [select Id,ContactId, FirstName, LastName from User where Id = :UserInfo.getUserId()];
                Community_Profile__c profile = new Community_Profile__c();
                profile.User__c = UserInfo.getUserId();
                profile.Display_Name__c = profileUser.FirstName + ' ' + profileUser.LastName.substring(0, 1);
                profile.DefaultLeaderboardType__c = selectedLBType;  
                profile.ContestLeaderBoardUp__c = false;    
                upsert profile;                                                       
            }
        } catch (Exception e) {
            // An exception will be thrown if no record exists yet. 
            System.Debug('Exception e===>' + e);           
        }                       
        return null;       
    }  
    
    public String leaderboardContestLastUpdated{get;set;}    
    public List<BadgeVilleLeaderBoard__c> getBadgevilleContestLeaderboard(){
        String selectedLBTypeC = 'Contest';
        try
        { 
            
            List<BadgeVilleLeaderBoard__c> bvplayers =  [Select Id, PicURL__c,display_name__c,PlayerEmail__c,PlayerID__c,Position__c,Value__c,Updated_DateTime__c,LastModifiedDate  from BadgeVilleLeaderBoard__c Where LeaderBoardDataType__c = :selectedLBTypeC order by Position__c LIMIT 20];
            /*String BvilleLastUpdatedDateTimeString = bvplayers.get(0).Updated_DateTime__c;
            List<String> bVilleLastUodatedDateArray =  BvilleLastUpdatedDateTimeString.split('T')[0].split('-');
            List<String> bVilleLastUpdatedTimeArray =  BvilleLastUpdatedDateTimeString.split('T')[1].split(':');
            String am_pm = integer.valueof(bVilleLastUpdatedTimeArray[0])>=12?'PM':'AM';
            Integer hrs = integer.valueof(bVilleLastUpdatedTimeArray[0])>=12?(integer.valueof(bVilleLastUpdatedTimeArray[0])-12):integer.valueof(bVilleLastUpdatedTimeArray[0]);
            Datetime bVilleLastUpDate = DateTime.parse(bVilleLastUodatedDateArray[1]+'/'+bVilleLastUodatedDateArray[2]+'/'+bVilleLastUodatedDateArray[0]+' '+hrs+':'+bVilleLastUpdatedTimeArray[1]+' '+am_pm); 
            Datetime currentDateTimeLocal = Datetime.now();
            Datetime currentDateTimeGMT   = DateTime.parse(currentDateTimeLocal.formatGmt('MM/dd/yyyy hh:mm a')); 
            Long differenceInMilis = currentDateTimeGMT.getTime()-bVilleLastUpDate.getTime();//String.valueof((differenceInMilis/1000)/60);
            leaderboardContestLastUpdated = String.valueof((differenceInMilis/1000)/60);//String.valueof(currentDateTimeGMT.getTime())+'__'+String.valueof(bVilleLastUpDate.getTime())+'ACTUALDATES_'+currentDateTimeGMT.format()+'___'+bVilleLastUpDate.format();
            Long minDelay = getMinutesBetween(bVilleLastUpDate,currentDateTimeGMT);
            Long hrsDelay = getHoursBetween(bVilleLastUpDate,currentDateTimeGMT);                
            if(hrsDelay>1) {leaderboardContestLastUpdated = String.valueof(hrsDelay) + ' hours ago'; }        
            else if(hrsDelay == 1) {leaderboardContestLastUpdated = String.valueof(hrsDelay) + ' hour ago'; }
            else 
            {
                if(minDelay>1){leaderboardContestLastUpdated = ' ' + String.valueof(minDelay) + ' minutes ago';}
                else if(minDelay == 1 ){leaderboardContestLastUpdated = '' + String.valueof(minDelay) + ' minute ago'; }
                else {leaderboardContestLastUpdated = 'less than a minute ago';}
            }  */
            leaderboardContestLastUpdated = 'an hour ago';
            return bvplayers;                     
        }
        catch (Exception ex)
        {
            System.Debug('Exception===>' + ex);
        }
        return null;
    }
    
    @isTest(SeeAllData=true)
    public static void testMarketoLeaderBoardController() {
        test.starttest();
        MarketoLeaderBoardController mbc = new MarketoLeaderBoardController();
        mbc.getBadgevilleLeaderboard();   
        mbc.getBadgevilleContestLeaderboard();  
        mbc.setOption() ;
        mbc.saveContestLBContext();
        
        Apexpages.currentPage().getParameters().put('chosenEntry','1');   
        mbc.getLeaderboardtypes();
        Apexpages.currentPage().getParameters().put('chosenEntry','Daily');
        mbc.setOption() ;
        mbc.saveContestLBContext();
        test.stoptest();
    }
}