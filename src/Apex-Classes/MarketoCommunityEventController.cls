Global class MarketoCommunityEventController{
  
    public  Integer totalNumberOfEvents{get;set;}
    public  boolean next {get;set;}
    public  Final Integer PAGESIZE = 5;
    public  Integer curPageNum        {get;set;}
    public  String communityEventsJson{get;set;}

    public MarketoCommunityEventController(){
        totalNumberOfEvents = [Select  count() From CommunityEvent__c where DateAndTime__c >= : datetime.now() and IsPublish__c = true ];//todays check
        curPageNum = -1;
        updateCommunityEvents(); 
    }
    
    public void updateCommunityEvents() {
        List<ComparableCommEvent> communityEvents = new List<ComparableCommEvent>();
        curPageNum++;
        Integer offset = curPageNum * PAGESIZE;
        if(curPageNum * PAGESIZE > 0){
            if ( curPageNum * PAGESIZE + math.mod(totalNumberOfEvents, curPageNum * PAGESIZE) < totalNumberOfEvents){
                next = false;
            }
            else next = true;
        }else if(PAGESIZE >= totalNumberOfEvents){
            next = true;
        }else{
            next = false;
        }
        try{
            List<CommunityEvent__c> commEventList = [SELECT Id, URL__c, Type__c, NumberOfClicks__c,DateAndTime__c ,Location__c, EventName__c, CreatedDate  From CommunityEvent__c where IsPublish__c = true and DateAndTime__c >= : datetime.now() ORDER BY DateAndTime__c ASC LIMIT : PAGESIZE OFFSET :offset];
            for(CommunityEvent__c tempEvent :commEventList){
                ComparableCommEvent tmpWrapper = new ComparableCommEvent();
                tmpWrapper.commEvntInstnc       = tempEvent;
                tmpWrapper.correctDateFormat   =  tempEvent.DateAndTime__c.format('EEE' + ' - ' + 'MM/dd/YYYY' + ' ' + 'h:mma, z');
               // tmpWrapper.correctTimeFormat   =  tempEvent.DateAndTime__c.format('hh:mma, z');
                communityEvents.add(tmpWrapper);
                }
            communityEvents.sort();
            communityEventsJson = JSON.serialize(communityEvents);
            communityEventsJson = string.escapeSingleQuotes(communityEventsJson);
        }
        catch(Exception e){
           ApexPages.addMessages(e);
        } 
    }
    public void numberOfClicks(){
        String idOfEvent = Apexpages.currentPage().getParameters().get('idOfEvent');
        if(idOfEvent != null){
            try{
                Id i = Id.valueOf(idOfEvent);
                CommunityEvent__c coomEvent = new  CommunityEvent__c();
                coomEvent = [Select Id, NumberOfClicks__c  From CommunityEvent__c where Id =: i];
               // system.debug('coomEvent.NumberOfClicks__c123345556'+coomEvent.NumberOfClicks__c); 
                coomEvent.id = i;
                if(coomEvent.NumberOfClicks__c != null){
                    coomEvent.NumberOfClicks__c = coomEvent.NumberOfClicks__c + 1;
                }else{
                  coomEvent.NumberOfClicks__c = 1;  
                }
               // system.debug('coomEvent.NumberOfClicks__c--->'+coomEvent.NumberOfClicks__c);
                update coomEvent;
            }
            catch(Exception e){
               ApexPages.addMessages(e);
            } 
        }
        system.debug('idOfEvent--->'+idOfEvent);
        
    }
    global class ComparableCommEvent implements Comparable {
        public CommunityEvent__c commEvntInstnc {get;set;}
        public string correctDateFormat         {get;set;}
       // public string correctTimeFormat         {get;set;}
       
        
        global Integer compareTo(Object compareToItem) {
            ComparableCommEvent compareToKey = (ComparableCommEvent)compareToItem;
            if(compareToKey.commEvntInstnc.DateAndTime__c >= commEvntInstnc.DateAndTime__c ){
                return -1;
            }else{
                return 1;
            }
        }  
    } 
}