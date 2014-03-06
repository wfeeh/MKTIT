public class MarketoEventController {
     private final CommunityEvent__c communityEvent;
    
    public MarketoEventController(ApexPages.StandardController controller) {
        this.communityEvent = (CommunityEvent__c )controller.getRecord();
    }
    /*
    public pagereference save(){
        try{
        String gmtTime = communityEvent.TimeZone__c.substringBetween('(',')').substringAfter('GMT').trim();
        list<string> gmtHrMin = gmtTime.split(':',2);
        system.debug('gmtHrMin-->'+gmtHrMin );
        String myDate = communityEvent.DateOfEvent__c;
        system.debug('myDate-->'+myDate);
        list<string> dateTimeSplit = myDate.split(' ', 2);
        list<string> dateSplit = dateTimeSplit[0].split('-',3);
        list<string> timeSplit = dateTimeSplit[1].split(':',2);
        list<integer> intDateSplit = new list<integer>();
        list<integer> intTimeSplit= new list<integer>();
        for(string temp : dateSplit){
            intDateSplit.add(integer.valueOf(temp));
        }
        for(string temp : timeSplit){
            intTimeSplit.add(integer.valueOf(temp));
        }
        Datetime GMTDate1 =  Datetime.newInstanceGmt(intDateSplit[0],intDateSplit[1],intDateSplit[2],intTimeSplit[0],intTimeSplit[1],0);
        if(gmtHrMin[0].contains('+')){
            Integer i =  Integer.valueOf(gmtHrMin[0]);
            i = math.abs(i);
            GMTDate1 = GMTDate1.addHours(-i);
            Integer minInt = Integer.valueOf(gmtHrMin[1]);
            minInt = math.abs(minInt);
            GMTDate1 = GMTDate1.addMinutes(-minInt);
        }else{
            Integer i =  Integer.valueOf(gmtHrMin[0]);
            i = math.abs(i);
            GMTDate1 = GMTDate1.addHours(+i);
            Integer minInt = Integer.valueOf(gmtHrMin[1]);
            minInt = math.abs(minInt);
            GMTDate1 = GMTDate1.addMinutes(+minInt);
        }
        communityEvent.DateAndTimeGmt__c = GMTDate1;
        upsert communityEvent communityEvent.id; 
        PageReference acctPage = new ApexPages.StandardController(communityEvent).view();
        acctPage.setRedirect(true);
        return acctPage;
        }catch(Exception e){
           ApexPages.addMessages(e);
           return null;
        }         
    }*/
}