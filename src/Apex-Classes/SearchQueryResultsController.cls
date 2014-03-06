global class SearchQueryResultsController implements Schedulable{
    public String relevancy{get;set;}
    public String createdDays{get;set;}
    public DateTime currentDate;
    public Date myDate;
    public Integer numberDays {get;set;}
    public List<searchQuery__c> searchQueryResults;
    public SearchQueryResultsController (){
       searchQueryResults = new List<searchQuery__c>();
        searchQueryResults = [SELECT Name, relevancy__c, searchString__c, createddate from searchQuery__c WHERE relevancy__c <=10];
        System.debug('searchQueryResults --->'+searchQueryResults );
        
    }
    global void execute(SchedulableContext ctx) {
    /* for(searchQuery__c sq:searchQueryResults){
            delete sq;
        }*/
         delete searchQueryResults ;
    }
}