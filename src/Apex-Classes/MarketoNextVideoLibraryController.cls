public with sharing class MarketoNextVideoLibraryController {
    
    //public static string MARKETO_HOME_TUTORIALS_CATEGORY = 'Setup_the_Program_or_Event';
    //public List<Video__kav> videoList{get;set;}
    //public List<Integer> sortedVideoListOrder{get;set;}
    //public List<Video__kav> sortedVideoList{get;set;}     
    public String videoSelUrl{get;set;}
    public String videoSelId{get;set;}  
    public Video__kav defaultVideo{get;set;}
    
    public List<Video__kav> MLMVideosList {get;set;}
    public List<Video__kav> RCAVideosList  {get;set;}
    
    public MarketoNextVideoLibraryController(){
        MLMVideosList  = [select Video_URL__c, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus, (select DataCategoryGroupName, DataCategoryName From DataCategorySelections) from Video__kav where PublishStatus='online'  with data category Articles__c Below Lead_Management__c  order by Sort_Order__c asc];
        RCAVideosList  = [select Video_URL__c, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus, (select DataCategoryGroupName, DataCategoryName From DataCategorySelections) from Video__kav where PublishStatus='online'  with data category Articles__c Below Revenue_Cycle_Analytics__c order by Sort_Order__c asc];

        MLMVideosList  = sortVideos(MLMVideosList);
        RCAVideosList  = sortVideos(RCAVideosList);
    }
    
    public List<Video__kav> sortVideos(List<Video__kav> videoList) {

        List<Integer> sortedVideoListOrder = new List<Integer>();
        List<Video__kav> sortedVideoList      = new List<Video__kav>();     
        Map<integer, Video__kav> OrderToVideoMap = new Map<integer, Video__kav>();

        for(Video__kav video:videoList){
            sortedVideoListOrder.add(Integer.valueOf(video.Sort_Order__c));
            OrderToVideoMap.put(Integer.valueOf(video.Sort_Order__c), video);
        }

        // sorting list of strings(sort orders)
        sortedVideoListOrder.sort();       
        for(integer i = 0 ; i < sortedVideoListOrder.size() ; i++ ){
            sortedVideoList.add(OrderToVideoMap.get(sortedVideoListOrder.get(i)));
        }
        
        // Set the video selected
        if (ApexPages.CurrentPage().getParameters().get('id') != null) {
            Video__kav selVideo = [select Video_URL__c, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus from Video__kav where PublishStatus='online' and Id=:ApexPages.CurrentPage().getParameters().get('id')];
            videoSelUrl = selVideo.Video_URL__c;//ApexPages.CurrentPage().getParameters().get('url');
            videoSelId  = ApexPages.CurrentPage().getParameters().get('id');
        } else {
            for (Video__kav video:videoList) {
                if (video.Sort_Order__c == '1') {
                    videoSelUrl = video.Video_URL__c;
                    videoSelId  = video.id;
                }
            }
        }
        
        return sortedVideoList;     
    }   

    public static testMethod void myUnitTest() {
      PageReference pg = Page.marketovideolibrary; 
  
      Test.setCurrentPage(pg);
      
      MarketoNextVideoLibraryController c = new MarketoNextVideoLibraryController();      
      //c.searchResults();  
       
    }     
/*  
    public  MarketoNextVideoLibraryControllerOld(){

        videoList = [select Video_URL__c, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus, (select DataCategoryGroupName, DataCategoryName From DataCategorySelections) from Video__kav where PublishStatus='online' order by Sort_Order__c asc];
        //Article__DataCategorySelection  vdc = videoList.DataCategorySelections;
        sortedVideoListOrder = new List<Integer>();
        sortedVideoList = new List<Video__kav>();       
        Map<integer, Video__kav> OrderToVideoMap = new Map<integer, Video__kav>();
        for(Video__kav video:videoList){
            sortedVideoListOrder.add(Integer.valueOf(video.Sort_Order__c));
            OrderToVideoMap.put(Integer.valueOf(video.Sort_Order__c), video);
        }

        // sorting list of strings(sort orders)
        sortedVideoListOrder.sort();       
        
        for(integer i = 0 ; i < sortedVideoListOrder.size() ; i++ ){
            sortedVideoList.add(OrderToVideoMap.get(sortedVideoListOrder.get(i)));
        }
        
        // Set the video selected
        if (ApexPages.CurrentPage().getParameters().get('id') != null) {
            Video__kav selVideo = [select Video_URL__c, Title, sub_title__c, Thumbnail_picture__c, Sort_Order__c, id, PublishStatus from Video__kav where PublishStatus='online' and Id=:ApexPages.CurrentPage().getParameters().get('id')];
            videoSelUrl = selVideo.Video_URL__c;//ApexPages.CurrentPage().getParameters().get('url');
            videoSelId  = ApexPages.CurrentPage().getParameters().get('id');
        } else {
            for (Video__kav video:videoList) {
                if (video.Sort_Order__c == '1') {
                    videoSelUrl = video.Video_URL__c;
                    videoSelId  = video.id;
                }
            }
        }
    }   
*/  
    
}