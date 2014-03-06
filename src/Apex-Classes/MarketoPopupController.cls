public virtual  class MarketoPopupController {

    public showpopup__c popupinfo{get;set;}  
    public Newpopup__c popupinfonew{get;set;}    
    public string ispopupdisplayed{get;set;}
    public string ispopupdisplayedNew{get;set;}

    public Pagereference checkPopup(){
        //Added in init function
        ispopupdisplayedNew = '';
        ispopupdisplayed = '';
        String currentUrl = '';
        if(ApexPages.currentPage() != null){
            currentUrl = ApexPages.currentPage().getUrl().toUpperCase();
        }
        
        if(!('Guest'.equalsIgnoreCase(UserInfo.getUserType())) && currentUrl != ''){
            ispopupdisplayedNew = 'false';
            List<Newpopup__c> listnewPopupInfo = [Select np.isdisplayed__c, np.Site_User__c from Newpopup__c np where np.Site_User__c=:UserInfo.getUserId()];
            //System.debug('listPopupInfo--->'+ listPopupInfo);
            if(listnewPopupInfo != null && listnewPopupInfo.size() > 0){
                popupinfonew        = listnewPopupInfo.get(0);
                ispopupdisplayedNew = listnewPopupInfo.get(0).isdisplayed__c;
            }
            if (popupinfonew == null){
                popupinfonew = new Newpopup__c();
                popupinfonew.isdisplayed__c = 'true';
                popupinfonew.Site_User__c   = UserInfo.getUserId();
                popupinfo = new showpopup__c();
                popupinfo.isdisplayed__c = 'true';
                popupinfo.Site_User__c = UserInfo.getUserId();
                insert popupinfo;     
                insert popupinfonew;
                
                           
            }
            
            List<LoginHistory> loggedinUserHistory = [SELECT UserId, LoginTime from LoginHistory where UserId=:UserInfo.getUserId() LIMIT 1];
           
            if (loggedinUserHistory.size() > 1) {
                ispopupdisplayedNew = 'true';    
            }
         
        }        
        if (ispopupdisplayedNew == 'true') { 
            if(!('Guest'.equalsIgnoreCase(UserInfo.getUserType() ) ) && currentUrl != ''){
                ispopupdisplayed = 'false';
                List<showpopup__c> listPopupInfo = [Select sp.isdisplayed__c, sp.Site_User__c from showpopup__c sp where sp.Site_User__c=:UserInfo.getUserId()];
                System.debug('listPopupInfo--->'+ listPopupInfo);
                if(listPopupInfo != null && listPopupInfo.size() > 0){
                    popupinfo = listPopupInfo.get(0);
                    ispopupdisplayed = listPopupInfo.get(0).isdisplayed__c;
                }
                if (popupinfo == null){
                    popupinfo = new showpopup__c();
                    popupinfo.isdisplayed__c = 'true';
                    popupinfo.Site_User__c = UserInfo.getUserId();
                    insert popupinfo;           
                }
            } 
        }
                
       return null;
    }

}