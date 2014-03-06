public with sharing class MarketoNextHomeController {
	// Variables	
	public List<Video__kav> videoList{get;set;}
	public Video__kav defaultVideo{get;set;}
	
	/**
	 * Constructor
	 */
	public MarketoNextHomeController(){
		// Fetch featured videos from the custom setting  
        Map<String, MarketoNextHomeSetting__c> videoMap = MarketoNextHomeSetting__c.getAll();
        Set<Id> videoIds = new Set<Id>();
        Map<String, String> orderToVideoId = new Map<String, String>();
        
        // Iterating over results of custom setting and fill the map of order vs video ids
        for(String st : videoMap.keyset()){
        	videoIds.add(videoMap.get(st).video_Id__c);
        	orderToVideoId.put(st, videoMap.get(st).video_Id__c);
        }
        
        // Map of sort order vs Videos
        Map<integer, Video__kav> OrderToVideoMap = new Map<integer, Video__kav>();
        Map<Id, Video__kav> mapVideos = new Map<Id,Video__kav>();
        // Querying featured videos
        for(Video__kav vid : [select Video_URL__c, knowledgeArticleId, Title, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus from Video__kav where PublishStatus='online' and knowledgeArticleId IN:videoIds order by Sort_Order__c asc LIMIT 5]){
        	mapVideos.put(vid.knowledgeArticleId, vid);
        }
        List<Integer> listToSOrt = new List<Integer>();
        System.debug('========before sorting===orderToVideoId========'+orderToVideoId);
        System.debug('========before sorting===mapVideos========'+mapVideos);
        
        // Iterating over map to prepare a list of strings(sort order is stored as string) for sorting purpose 
        for(String s : orderToVideoId.keyset()){
        	listToSort.add(Integer.valueOf(s));
        	// order to video map
        	OrderToVideoMap.put(Integer.valueOf(s), mapVideos.get(orderToVideoId.get(s)));
        }
        System.debug('========after sorting===listToSort========'+listToSort);
        System.debug('========after sorting===OrderToVideoMap========'+OrderToVideoMap);
        // sorting list of strings(sort orders)
        listToSort.sort();
        videoList = new List<Video__kav>();
        // iterating list of keys to make a sorted list
        for(integer i = 1 ; i <= listTOSOrt.size() ; i++ ){
        	
        	 // If video_id mentioned in url, set default_video as that id
        	if (ApexPages.CurrentPage().getParameters().get('vid') != null) {
        		if (OrderToVideoMap.get(i).knowledgeArticleId == ApexPages.CurrentPage().getParameters().get('vid')) {
					defaultVideo = OrderToVideoMap.get(i);
        		}         		
        	} else {
        		if (i==1) {
        			defaultVideo = OrderToVideoMap.get(i);
        		}
        	}

        	videoList.add(OrderToVideoMap.get(i));
        }
        

        
        System.debug('===========sorted list of videos'+videoList);
	}
}