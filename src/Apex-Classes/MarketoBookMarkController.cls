public class MarketoBookMarkController {

    public String bookmarkTitle{get;set;}
    public String bookmarkLink{get;set;}
    public String bookmarkString{get;set;}    
    public List<InnerBookMarkCls> BMrkList{get;set;}
    public DateTime curnTime{get{return DateTime.Now();}set;}
    public Boolean currURLExists{get;set;}
    public Boolean currBMPanelDown{get;set;}    
    public String currURL{get;set{currURL = value;}}
    public String currPgTitle{get;set;}    
    public BOOLEAN hideBookMark{get;set;}
    public Boolean showBookMarks{get;set;}
    public BOOLEAN showBookMarksRight{get;set;}     
    public String test{get;set;}    
    
    public class InnerBookMarkCls{
        public String title{get;set;}
        public String url{get;set;}
        public String type{get;set;}        
        public InnerBookMarkCls(String title1,String url1, String type1) {
            this.title = title1;
            this.url = url1;
            this.type= type1;
        }                       
    }    
    
    public MarketoBookMarkController()
    {
        Id userid = Userinfo.getUserId();    
        BMrkList = new List<InnerBookMarkCls>();   
        currURLExists = false;        
        currBMPanelDown = true;
        
        try {
            List<Community_Profile__c> profileList = [select id,Bookmarks__c,Hide_Book_Mark__c,ShowBookmarkRIght__c From Community_Profile__c where User__c = :userid Limit 1];
            If(profileList.size() != 0){
                Community_Profile__c profile = profileList[0];
                profile.ShowBookmarkRIght__c = profile.ShowBookmarkRIght__c == null?true:profile.ShowBookmarkRIght__c;
                bookmarkString = profile.Bookmarks__c;
                BMrkList = parseJson(bookmarkString);            
                hideBookMark = profile.Hide_Book_Mark__c;
                showBookMarksRight = profile.ShowBookmarkRIght__c;
                test = profile.id;
            } else {
        }
        } catch (Exception ex) {
            bookmarkString = '';
            System.Debug('In Catch block');
        }
    }
    
    public List<InnerBookMarkCls> parseJson(String JSONContent)
    {
        List<InnerBookMarkCls> myBMList = new List<InnerBookMarkCls>();        
        if(currURL == null || currURL == '')
        {
            String hostname = ApexPages.currentPage().getHeaders().get('Host');
            String pageUrl = ApexPages.currentPage().getUrl();        
			currURL = 'https://' + hostname + pageUrl;      
            try {
                Map<String,String> headerInfo = new Map<String,String>();
                headerInfo = ApexPages.currentPage().getHeaders();
                if(headerInfo.containsKey('CipherSuite'))
                {
                    system.debug('Test==>'+ApexPages.currentPage().getHeaders().get('CipherSuite'));                             
                    currURL = 'https://' + hostname + pageUrl;                 
                }
                else 
                {
                    system.debug('Test==>'+ApexPages.currentPage().getHeaders());                                         
                    currURL =  'http://' + hostname + pageUrl;                 
                }               
            } catch (Exception ex) {
                system.debug('Test==>'+ApexPages.currentPage().getHeaders());                                                     
            }
        }                   
        currURLExists = false;     
        try
        {
            System.JSONParser parser = JSON.createParser(JSONContent);
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContent);                                        
            List<Object> b = (List<Object>) m.get('bookmarks');
            Boolean found = false;                     
            for(Object c : b){
                String title =''; String url='';String type='';         
                Map<String, Object> d = (Map<String, Object>) c;                              
                for(String key:d.keySet()){
                    if(key =='title')
                    {                            
                        title = (string) d.get(key);                                                                                                                                    
                    }
                    if(key =='url')
                    {                            
                        url = (string) d.get(key);                           
                        System.debug('CurrURL==>' + url + ' ' + currURL);
                        if(url.equalsIgnoreCase(currURL)) {
                            System.debug('CurrURL==>' + url + ' ' + currURL);
                            currURLExists = true;     
                            currPgTitle = title;                   
                        }                         
                    }     
                    if(key =='type')
                    {                            
                        type = (string) d.get(key);                             
                    }                                                                                       
                }
                InnerBookMarkCls myBMC = new InnerBookMarkCls(title,url,type);    
                myBMList.Add(myBMC);                                            
            } 
        }
        catch(Exception ex)
        {
            System.debug('Exception=>'+ex);            
        }        
        return myBMList;                    
    }
    
    public PageReference SaveBookMarkPosition()
    {
        String tmpShowBookRight = ApexPages.currentPage().getParameters().get('currPosStatus'); 
        String userid = UserInfo.getUserId();
        try {
            List<Community_Profile__c> profileList = [select id,ShowBookmarkRIght__c From Community_Profile__c where User__c = :userid Limit 1];
            If (profileList.size() != 0){
                Community_Profile__c profile = profileList[0];
                if(tmpShowBookRight  == 'false'){profile.ShowBookmarkRIght__c = false;showBookMarksRight = false; } 
                else {profile.ShowBookmarkRIght__c = true;showBookMarksRight = true; }            
                update profile;
            } else {
                Community_Profile__c newProfile = new Community_Profile__c(User__c = userid, ShowBookmarkRIght__c = true,Hide_Book_Mark__c = false);
                System.Debug('new profile++++'+newProfile);
                insert newProfile;
            }   
        } catch (Exception ex) {
            System.debug('Exception=>' + ex);
        }           
        return null;      
    }
    public PageReference saveBookmarks()
    {
        String tmpBMStr = ApexPages.currentPage().getParameters().get('tmpBMStr');
        
        String tmpBMSts = ApexPages.currentPage().getParameters().get('tmpBMSts');
        currURL = ApexPages.currentPage().getParameters().get('currURL');
        String userid = UserInfo.getUserId();
        try {
            List<Community_Profile__c> profileList = [select id,Bookmarks__c,ShowBookmarkRIght__c From Community_Profile__c where User__c = :userid Limit 1];
            If (profileList.size() != 0){
                Community_Profile__c profile = profileList[0];
                profile.Bookmarks__c         = tmpBMStr;
                update profile;                
                BMrkList                     = new List<InnerBookMarkCls>();  
                BMrkList                     = parseJson(tmpBMStr);                
                if(tmpBMSts == 'false'){currBMPanelDown = false;} else {currBMPanelDown = true;}
                bookmarkString = tmpBMStr;        
            } else {
                Community_Profile__c newProfile = new Community_Profile__c(User__c = userid, Bookmarks__c = tmpBMStr,ShowBookmarkRIght__c = true,Hide_Book_Mark__c = false);
                insert newProfile;
                System.Debug('newProfile'+newProfile);                
                BMrkList = new List<InnerBookMarkCls>();  
                BMrkList = parseJson(tmpBMStr);                
                if(tmpBMSts == 'false'){currBMPanelDown = false;} else {currBMPanelDown = true;}
                bookmarkString = tmpBMStr;
        }
           
        } catch (Exception ex) {
            System.debug('Exception=>' + ex);
        }            
        return null;    
    }

    
    
    public PageReference rerenderBookmarks()
    {
        currURL = ApexPages.currentPage().getParameters().get('currURL');        
        currBMPanelDown = false; 
        BMrkList = new List<InnerBookMarkCls>();  
        BMrkList = parseJson(bookmarkString);            
        return null;    
    }
        
    public static testMethod void testMarketoBookMarkControllerController() {
        MarketoBookMarkController mtc = new MarketoBookMarkController();
        String jsonString = '{"bookmarks":[{"title":"Item 01","url":"http://Item 01"},{"title":"Item 02","url":"http://Item 02"},{"title":"Item 03","url":"http://Item 03"},{"title":"Item 04","url":"http://Item 04"},{"title":"Item 05","url":"http://Item 05"},{"title":"Item 06","url":"http://Item 06"},{"title":"Item 07","url":"http://Item 07"},{"title":"Item 08","url":"http://Item 08"},{"title":"Item 09","url":"http://Item 09"},{"title":"Item 10","url":"http://Item 10"}]}';
        ApexPages.currentPage().getParameters().put('tmpBMStr', jsonString);
        ApexPages.currentPage().getParameters().put('tmpBMSts', 'false');
        
        
        mtc.bookmarkString = jsonString;
        mtc.rerenderBookmarks();
        mtc.saveBookmarks();
        mtc.BMrkList = mtc.parseJson(jsonString);       
        ApexPages.currentPage().getParameters().put('currPosStatus', 'true');
        mtc.SaveBookMarkPosition();
        ApexPages.currentPage().getParameters().put('currPosStatus', 'false');
        mtc.SaveBookMarkPosition();

    }
}