/****************************************************
Class Name: WelcomeController
Author: ClearTeask
Created Date: 5/18/2012
Usage: This class is used show company details in left component. 
*****************************************************/
public with sharing class WelcomeController{
    
    public User userDetails{get;set;}
    public Account acc{get;set;}
    public Boolean isAuthorized {get; set;}
    public Boolean authorizedUser {get; set;}
    public String passCode {get; set;}
    public String authContactName {get; set;}
    public String slaProcess {get; set;}
    Public String SurveyPreference{get;set;}
    Public String Phone{get;set;}
    Public String Language{get;set;}
    //Public  User userDetailsNew{get;set;}
    public String SuccessTeam {get;set;}
    public String SuccessTeamPageURL {get;set;}
    public WelcomeController(){
        userDetails = new User();
        acc = new Account();
          
        List<User> usrList = [Select u.Username, u.UserType, u.LanguageLocaleKey, u.UserRole.Name, u.UserRoleId, u.Name, u.Contact.Name, u.Contact.FirstName, 
                               u.Contact.LastName, u.Contact.AccountId, u.ContactId, u.AccountId, u.Contact.Number_of_admins__c, u.Contact.Is_Authorized_Contact__c 
                               ,u.Contact.Phone,u.Contact.MobilePhone,Munchkin_Id__c, u.Contact.Preferred_Language__c
                               From User u where Id =: UserInfo.getUserId()];
                                      
        if(usrList != null && usrList.size()>0){
            userDetails  =  usrList[0];            
            if(usrList[0].Contact.Number_of_admins__c != null && usrList[0].Contact.Number_of_admins__c > 0)
                isAuthorized = true; 
            if(usrList[0].Contact.Is_Authorized_Contact__c != null && usrList[0].Contact.Is_Authorized_Contact__c.equals('No')) 
                authorizedUser = false;
            if(usrList[0].Contact.Phone != null)
                Phone = usrList[0].Contact.Phone;    
             if(usrList[0].Contact.Preferred_Language__c != null)
                Language = usrList[0].Contact.Preferred_Language__c;  
            
            List<Community_Profile__c> usrList1 = [select Id, Display_Name__c, Company_Name__c, Title__c, Location__c, Website__c,CRM__c,
                    Customer_Since__c, About_Me__c, Date_I_Started_Using_Marketo__c, CSatSurveyPreferences__c,Member_of_user_group__c from Community_Profile__c where User__c =: userInfo.getUserID()];                    
            
            SurveyPreference = 'All';
            if(usrList1.size()>0){
               if(usrList1[0].CSatSurveyPreferences__c != null){
                   SurveyPreference = usrList1[0].CSatSurveyPreferences__c ; 
               }
           }             
       }                                                                     
                            
       System.debug('In userDetails  ---'+userDetails  ); 
       if(userDetails != null && userDetails.Contact.AccountId != null){
           acc =  [select id ,Name, Support_Level__c, CS_Team__c, (Select Company_Passcode__c, SlaProcess.Name From Entitlements Where Status = 'Active' AND Entitlement.Asset.Munchkin_Id__c != NULL AND Entitlement.Asset.Munchkin_Id__c = :userDetails.Munchkin_Id__c LIMIT 1) from Account where id = :userDetails.Contact.AccountId];
           if(acc != null) 
           {
               SuccessTeam  = acc.CS_Team__c;
               if(SuccessTeam != null) {
                   if(SuccessTeam.equalsIgnoreCase('Team K2')== true) { SuccessTeamPageURL = 'http://pages2.marketo.com/K2.html';}
                   else if(SuccessTeam.equalsIgnoreCase('Team Kuji')== true) { SuccessTeamPageURL = 'http://pages2.marketo.com/Fuji.html';}
                   else if(SuccessTeam.equalsIgnoreCase('Team Shasta')== true) { SuccessTeamPageURL = 'http://pages2.marketo.com/Shasta.html';}
                   else if(SuccessTeam.equalsIgnoreCase('Team Mont Blanc')== true) { SuccessTeamPageURL = 'http://pages2.marketo.com/MontBlanc.html';}                   
               }
           }
           
            if(acc != null && acc.Entitlements != null && acc.Entitlements.size() > 0) {
                passCode = acc.Entitlements[0].Company_Passcode__c;
                slaProcess = acc.Entitlements[0].SlaProcess.Name;
            }
           
            List<Authorized_Contact__c> authConList = [Select a.Entitlement__r.AccountId, a.Entitlement__c, a.Customer_Admin__c, a.Contact__r.Name, a.Contact__c, a.Entitlement__r.Asset.Munchkin_Id__c 
                                                       From Authorized_Contact__c a
                                                       where Entitlement__r.Asset.Status = 'Active' AND Entitlement__r.Status = 'Active' AND Entitlement__r.AccountId = :userDetails.Contact.AccountId AND a.Customer_Admin__c = true];
            System.Debug('authConList+++'+authConList);
            if(authConList != null && authConList.size() > 0) {
                Set<Id> adminContactId = new Set<Id>();
                if(authConList.size() == 1){
                   authContactName = authConList[0].Contact__r.Name;
                } else {
                    Boolean contactFound = FALSE;
                    for(Authorized_Contact__c tmpCont : authConList) {
                        System.Debug('tmpCont.Entitlement__r.Asset.Munchkin_Id__c+++'+tmpCont.Entitlement__r.Asset.Munchkin_Id__c);
                        System.Debug('userDetails.Munchkin_Id__c+++'+userDetails.Munchkin_Id__c);
                        if((tmpCont.Entitlement__r.Asset.Munchkin_Id__c != NULL) && (tmpCont.Entitlement__r.Asset.Munchkin_Id__c == userDetails.Munchkin_Id__c)){
                            authContactName = tmpCont.Contact__r.Name;
                            System.Debug('authContactName++++'+authContactName);
                            contactFound = TRUE;  
                            break;
                        }
                        adminContactId.add(tmpCont.Contact__r.Id);                       
                    }
                    if(contactFound == FALSE && adminContactId.size() == 1) {//Add admins are same and contact not found.
                        authContactName = authConList[0].Contact__r.Name;
                    }
                }
            }
            System.debug('In acc---'+acc);    
        }
    }
    
   /* public Map<String, String> getLanguageMap() {      
        Map<String, String> langMap = new Map<String, String>();
        Schema.DescribeFieldResult lang = User.LanguageLocaleKey.getDescribe(); 
        List<Schema.PicklistEntry> langList = lang.getPicklistValues();
        
        for(Schema.PicklistEntry l :langList){
            langMap.put(l.getValue(), l.getlabel());
        }
        return langMap;
    }*/
    
    public PageReference manageAuthorizedContacts() {
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Manage_Authorized_Contacts');
        } else {
            pgRef = new PageReference('/apex/Manage_Authorized_Contacts');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }    
        
}