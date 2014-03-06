global class BadgeVilleLeaderboardApexScheduledClass Implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        updateLeaderboard();
    }
    @future (callout=true)
    public static void updateLeaderboard()
    {
        BadgeVilleWebServiceCallout myCall = new BadgeVilleWebServiceCallout();
        myCall.updateLeaderBoard();
       
    }    
}