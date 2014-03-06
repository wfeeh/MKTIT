public class MarketoSearchController extends MarketoBaseController {

	public string debugVar {get;set;} 
	public Integer pageNum {get; set;}
	public String searchType {get; set;}
    public Boolean inRecent {get; set;}
    public Boolean inPopular {get; set;}
    public String selectedCategory {get; set;}
    public static Integer numResults {get; set;}
    public List<SearchResult> results {get; set;}
    private ApexPages.StandardSetController setCon {get; private set;} 
    public List<Map <String,String>> blogResults{get;set;}  
    public Map<String, Video__kav> urlNameToVideoMap {get;set;}
    public List<Video__kav> videoList{get;set;}      
    
    public Integer resultSize {get {return (results==null || results.size()==0)?0:results.size();} set;}
    
    public String searchText {get {
    	 return ApexPages.currentPage().getParameters().get('searchText') != null ? 
    	 		ApexPages.currentPage().getParameters().get('searchText') : '';} set;}
    
    public MarketoSearchController() {
    	numResults = 10;
    	String pg = ApexPages.currentPage().getParameters().get('pg');
   		pageNum = pg == null ? 1 : Integer.valueOf(pg);
   		searchType = ApexPages.currentPage().getParameters().get('searchType');
   		getVideos();
    }
    
    public PageReference newPage() {
    	pageNum += 1;
    	return null;
    }
    
    public PageReference doSearch() {
    
    	pageNum = 1;
    	PageReference p = Page.MarketoSearchResults;
    	p.getParameters().put('searchText', searchText);
    	p.getParameters().put('searchType', searchType);
    	return p;
    }
    
    public void refresh(Boolean requery) {
    	   
        results = new List<SearchResult>();
        
        if (setCon != null) {
        	
	        if (searchType == 'Ideas') {
	        	for (Idea i : (List<Idea>) setCon.getRecords()) {
	        		results.add(new SearchResult(i.id,i.body,i.title,i.categories,
	        					i.lastmodifieddate!=null?i.lastmodifieddate:i.createddate));
	        	}
	        }
	        
	        else if (searchType == 'Discussion') {
	        	for (Question q2 : (List<Question>) setCon.getRecords()) {
	        		results.add(new SearchResult(q2.id,q2.body,q2.title,null,
	        			q2.lastmodifieddate!=null?q2.lastmodifieddate:q2.createddate));
	        	}
	        }
        }
    }
    
    public PageReference searchResults() {
   		
    	if (searchType == null) {
    		String sType = ApexPages.currentPage().getParameters().get('searchType');
    		searchType = sType != null ? sType : 'Discussion';
    	}
    	
    	searchText = ApexPages.currentPage().getParameters().get('searchText');
   		debugVar = 'Search type '+ApexPages.currentPage().getParameters().get('searchType');
    	if (searchText == null) {
    		
    		if (!context.inSearch) {
    			searchText = 'Search '  + MarketoUserContext.getContext().currentSection + '...';
    		}
    		else {
    			searchText = 'Refine Your Search...';
    		}
    	}
    
    	results = new List<SearchResult>();
    
		if (searchType == 'Ideas') {
        	Id[] similarIds = Ideas.findSimilar(new Idea(title=searchText, Body=searchText));
        	if (similarIds != null && similarIds.size() > 0) {
        		
        		setCon = new ApexPages.StandardSetController([select id, title, body, categories, createddate, lastmodifieddate from 
        							idea where id in :similarIds order by lastModifieddate desc]);
        							
        		setCon.setPageSize(numResults);
        	}
		}
		else if (searchType == 'Discussion') {
			
			Question q = new Question();
        	Id[] similarIds = Answers.findSimilar(new Question(title=searchText, Body=searchText));
        	if (similarIds != null && similarIds.size() > 0) {
        		
        		setCon = new ApexPages.StandardSetController([select id, title, body, createddate, lastmodifieddate from 
        							question where id in :similarIds order by lastModifieddate desc]);
        							
        		setCon.setPageSize(numResults);	
        	}
		}
		
		
		refresh(true);
		
		return null;
    }
    
	public String currentSection { get { return MarketoUserContext.getContext().currentSection; } }
    
    public PageReference prevPage() {
		if (setCon != null) {
        	setCon.previous();
        	refresh(false);
     	}
        return null;
    }
    
    public PageReference nextPage() {
    	if (setCon != null) {
        	setCon.next();
        	refresh(false);
    	}
        return null;
    }
    
    public Boolean getHasPrevPage() {
    	if (setCon != null) {
    		return setCon.getHasPrevious();
    	}
        return false;
    }
    
    public Boolean getHasNextPage() {
    	if (setCon != null) {
        	return setCon.getHasNext();
    	}
    	return false;
    }
    
    public class SearchResult {
    	
    	public String id {get; set;}
    	public String body {get; set;}
    	public String formatDt {get; set;}
    	public String shortBody {get; set;}
    	public String title {get; set;}
    	public String categories {get; set;}
    	
    	public SearchResult(String id, String body, String title, String categories, DateTime dt) {
    		
    		this.id = id;
    		this.body = body;
    		this.title = title;
    		this.categories = categories;
    		this.shortBody = GlobalFunctions.getShortBody(body);
    		
            formatDt = dt.date().format() + ' ' +
                (dt.hour() > 12 ? dt.hour()-12 : dt.hour()) + ':' +
                (dt.minute() < 10 ? '0' + String.valueOf(dt.minute()) : String.valueOf(dt.minute())) + ' ' +
                (dt.hour() >= 12 && dt.hour() <= 24 ? ' PM' : ' AM'); 
		}
    }
    
    public static testMethod void testSearchController() {
    	
    	Idea i = new Idea();
    	Question q = new Question();
    	
       	User u = [select id from user where isactive=true and id != :UserInfo.getUserId() and profileid = :[select id from Profile where name = 'System Administrator'].Id limit 1];	
    	
    	system.runAs (u) {
    		q.title = 'test';
    		q.body = 'test';
    		q.communityId = GlobalFunctions.communityId;
    		insert q;
    		
    		i.title = 'test';
    		i.body = 'test';
    		i.communityId = GlobalFunctions.communityId;
    		insert i;
    	}
    	
    	MarketoSearchController c = new MarketoSearchController();
    	ApexPages.currentPage().getParameters().put('searchType', 'Ideas');
    	ApexPages.currentPage().getParameters().put('searchText', 'test');
    	c.searchResults();	
    	
    	ApexPages.currentPage().getParameters().put('searchType', 'Discussion');
    	c.searchResults();
    	/* 09-03-11 vishals@grazitti.com Added to increase code coverage */
    	c.prevPage();
    	c.nextPage();
    	c.getHasPrevPage();
    	c.getHasNextPage();
    	ApexPages.currentPage().getParameters().put('searchText', null);
    	c.searchResults();
    	
    	c.doSearch();
    	c.newPage();
    }
    
	public void getVideos(){
		videoList = [select Video_URL__c, UrlName, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus from Video__kav where PublishStatus='online' order by Sort_Order__c asc];
		//System.debug('List values '+videoList);
		/*Map<UrlName, Video__kav> IdToVideoMap = new Map<UrlName, Video__kav>([select UrlName, Video_URL__c, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus from Video__kav where PublishStatus='online' order by Sort_Order__c asc]);*/		
		urlNameToVideoMap = new Map<String, Video__kav>();
        for(Video__kav video:videoList){
        	urlNameToVideoMap.put(video.UrlName, video);
        }		
		//System.debug('Map values '+urlNameToVideoMap);      
		//System.debug('Title value '+vidtitle);		
	}
	 public List<Map<String,String>> blogResults(string seachText){
        blogResults = new List<Map <String,String>>();
        HttpRequest req = new HttpRequest();
        req.setEndPoint('http://blog.marketo.com/index.php?s='+seachText);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        string blog_results_html = res.getBody();
        string HTML_TAG_PATTERN = '<h2><a href="(.*?)">(.*?)</a></h2>';
        //System.debug(res.getBody());
        // compile the pattern     
        Pattern myPattern = Pattern.compile(HTML_TAG_PATTERN);
        // get your matcher instance
        Matcher myMatcher = myPattern.matcher(res.getBody());       
        while (myMatcher.find()) {
            Map<String, String> result = new  Map<String, String>();
            // Get the matching string
            String link  =  myMatcher.group(1);
            String title =  myMatcher.group(2);            
            System.debug(title);
            result.put('link', link);
            result.put('title', title);            
            System.debug(result);
            blogResults.add(result);  
        }
        System.debug(blogResults);
        return blogResults;
        
        //blogResults
    }    
}