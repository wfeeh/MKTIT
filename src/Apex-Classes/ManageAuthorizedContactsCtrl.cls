/****************************************************
Class Name: ManageAuthorizedContactsCtrl
Author: ClearTeask
Created Date: 6/6/2012
Usage: This class is used manage authorized contacts.
*****************************************************/
public class ManageAuthorizedContactsCtrl {
    
    public Authorized_Contact__c newAuthContact {get; set;}
    public Entitlement thisEnt {get; set;}
    public List<Authorized_Contact__c> authConList {get; set;}
    public List<Entitlement> entList {get; set;}
    public Boolean createNew {get; set;}
    public Boolean moreThanOneEntl {get; set;}
    public String entlName {get; set;}
    public String selectedEntl {get; set;}
    public List<SelectOption> entlOptions {get; set;}
    public ApexPages.StandardController controller {get;set;}
    
    Set<Id> authConIds;
    private String sortDirection = 'ASC';
    private String sortExp = 'Contact__r.Name';
    Integer index = 0;
    String query = ' Select Name, Entitlement__c, Entitlement__r.Name, Contact__c, Contact__r.Name, Email__c From Authorized_Contact__c where Entitlement__r.AccountId = :accId ';                             
    
    //Bikram 4/Mar/3684
    public String usrMunchkinId{get;set;}
    public String usrAssetId{get;set;}
    public Boolean isAuthorized{get;set;}
    //Bikram 28 Mar 3684
    public String usrEntitlemntId{get;set;}

    public manageAuthorizedContactsCtrl() {
        newAuthContact = new Authorized_Contact__c();
        User u = [select AccountId, Munchkin_Id__c from User where id = :UserInfo.getUserId()];
        accId = u.AccountId;                
        //Bikram 4/Mar/3684  259-ZMM-495
        usrMunchkinId = u.Munchkin_Id__c;     
        
        System.debug('usrMunchkinId ==>'+usrMunchkinId + ' ' + accId);
   
        //Bikram 5/Mar/3684 / Added MunckinId to query
        entList = [select id, Name, AccountId, of_Allowed_Authorized_Contacts__c, OK_to_Add__c from Entitlement where status = 'Active' and AccountId = :accId AND Asset.Munchkin_Id__c != NULL AND Asset.Munchkin_Id__c != '' AND Asset.Munchkin_Id__c =: usrMunchkinId];
        
        List<User> usrList = [Select u.Username, u.UserType, u.LanguageLocaleKey, u.UserRole.Name, u.UserRoleId, u.Name, u.Contact.Name, u.Contact.FirstName, 
                               u.Contact.LastName, u.Contact.AccountId, u.ContactId, u.AccountId, u.Contact.Number_of_admins__c, u.Contact.Is_Authorized_Contact__c 
                               ,u.Contact.Phone,u.Contact.MobilePhone 
                               From User u where Id =: UserInfo.getUserId()];       
        if(usrList != null && usrList.size()>0){
            if(usrList[0].Contact.Number_of_admins__c != null && usrList[0].Contact.Number_of_admins__c > 0)
                isAuthorized = true;         
        }
        //Bikram 28/Mar/3684
        if(!entList.isEmpty()){
            usrEntitlemntId =  entList[0].Id;
            System.debug('usrentList==>' + entList);
            //(Entitlement:{Name=2tor Inc. Standard, AccountId=0015000000bdG2kAAE, OK_to_Add__c=true, of_Allowed_Authorized_Contacts__c=4, Id=55050000000GnSjAAK, AssetId=02i50000004vWfJAAU})
        }      
        
        queryAuthorizedContacts();
        
        if(isAuthorized != true) 
        {
            ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, 'You are not authorized contact.'));
        }
        //Select Name, Entitlement__c, Entitlement__r.Name, Contact__c, Contact__r.Name, Email__c From Authorized_Contact__c where Entitlement__r.AccountId = '0015000000bdG2kAAE' AND (Entitlement__r.Id != null AND Entitlement__r.Id != '' AND Entitlement__r.Id = '55050000000GnSjAAK') order by Contact__r.Name ASC

        //entList = [select id, Name, AccountId, of_Allowed_Authorized_Contacts__c, OK_to_Add__c from Entitlement where AccountId = :accId];
    }
     
    public PageReference updateEntitlements() {        
        for(Entitlement e :entList) {
        update e;
        }
        return null;
    }
    
    /* --method to be show sort direction image-- */
    public String getSortDirection(){
        /* if column is not selected */
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    /*-- method to be set sort direction image-- */
    public void setSortDirection(String value){  
        sortDirection = value;
    }
    
     /*--returns the sort expression --*/
    public String sortExpression{
        get{            
            return sortExp;            
        }
        set{
        /* if the column is clicked on then switch between Ascending and Descending modes */
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';            
            sortExp = value;
        }
    }
    String accId = '';  //001P000000XG6Di
    
    /* methods to query authorized contacts */
    public void queryAuthorizedContacts() {
        authConList = new List<Authorized_Contact__c>();
        authConIds = new Set<Id>();
        
        //Bikram 4/Mar/3684
        Map<ID,Asset> tmpAssetMap = new Map<Id,Asset>([SELECT Id from Asset Where AccountId = :accId AND Munchkin_Id__c != NULL AND Munchkin_Id__c =: usrMunchkinId]);
        List<Id> tmpAssetIdStrLst = new List<Id>();               
        if(tmpAssetMap.size() > 0 ) {
            tmpAssetIdStrLst.addAll(tmpAssetMap.keySet());
            usrAssetId =  tmpAssetIdStrLst[0];                    
        }

        String sortFullExp = sortExpression  + ' ' + sortDirection;


        //Bikram 4/Mar/3684
        String tmpEntlmntStr = ' AND (Entitlement__r.Id != null AND Entitlement__r.Id != \'\' AND Entitlement__r.Id =: usrEntitlemntId) ';
        String tmpAssetStr = ' AND (Entitlement__r.AssetId != null AND  Entitlement__r.AssetId != \'\' AND Entitlement__r.AssetId = :usrAssetId ) ';

        
        String queryAll = query + tmpAssetStr + tmpEntlmntStr + ' order by ' + sortFullExp;        
        System.Debug('queryAll==>' + accId + '=>'+ usrEntitlemntId+ '=>' + queryAll);        
        
        //Select Name, Entitlement__c, Entitlement__r.Name, Contact__c, Contact__r.Name, Email__c From Authorized_Contact__c where Entitlement__r.AccountId = '0015000000bdG2kAAE'  AND (Entitlement__r.Id != null AND Entitlement__r.Id != '') AND (Entitlement__r.Id = '55050000000GnSjAAK')  order by Contact__r.Name ASC
        //Bikram 4/Mar/3684 If conditon for munchinkinId added to original query call
        
        if(usrEntitlemntId != Null && usrEntitlemntId != '') {
            authConList = Database.query(queryAll);                        
        }
        for(Authorized_Contact__c ac :authConList) {
            authConIds.add(ac.Contact__c);
        }
    }
    

    /* metod to save authorized contacts */
    public PageReference saveAuthorizedContact() {
        try {
            if(authConIds != null && authConIds.contains(newAuthContact.Contact__c)) {
                ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, 'This contact is already authorized.'));
                return null;
            }
            
            //11 Mar Bikram 3684 munchkin ID on the user who is an authorized contact, matches the munchkin ID of the Support Administrator/entitlement they are administrator of            
            List<User> myAddedUser = [SELECT Id, Munchkin_Id__c from User where ContactId =: newAuthContact.Contact__c AND Munchkin_Id__c =: usrMunchkinId Limit 1];
            if(myAddedUser.isEmpty()) {
                ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, 'This contact does not fall under your entitlement.'));
                return null;
            } // 11 Mar Bikram.                     

            newAuthContact.Entitlement__c = selectedEntl;
            insert newAuthContact;
        } catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        
        createNew = false;
        queryAuthorizedContacts();        
        PageReference pgRef;
            if(Utils.isSite) {
                pgRef = new PageReference('/Manage_Authorized_Contacts');
            } else {
                pgRef = new PageReference('/apex/Manage_Authorized_Contacts');
            }
        pgRef.setRedirect(true);
        return pgRef;        
        //return null;
    }
    
    /* method to redirect to authorized contact list page */
    public PageReference backToList() {
        
        createNew = false;
        return null;
    }
    
    /* method to redirect to create authorized contacts */
    public PageReference goToCreate() {
        //List<Entitlement> entlList = [select id, Name, AccountId from Entitlement where AccountId = :accId];

        //11 March Bikram
        List<Entitlement> entlList = [select id, Name, AccountId from Entitlement where status = 'Active' and AccountId = :accId AND AssetId =:usrAssetID];
        
        if(entlList != null) {
            if(entlList.size() > 1) {
                entlOptions = new List<SelectOption>();
                moreThanOneEntl = true;
                for(Entitlement entl :entlList) {
                    entlOptions.add(new SelectOption(entl.id, entl.name));
                }
                
            } else if(entlList.size() == 1) {
                moreThanOneEntl = false;
                entlName = entlList[0].Name;
                selectedEntl = entlList[0].id;
            }
        }
        
        createNew = true;
        return null;
    }
    
    /* method to redirect to home page */
    public PageReference backToHome() {
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/MarketoSupportHome');
        } else {
            pgRef = new PageReference('/apex/MarketoSupportHome');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* metod to sort data */
    public PageReference sortData(){
        authConList = new List<Authorized_Contact__c>();
        /* build the full sort expression */
        String sortFullExp = sortExpression  + ' ' + sortDirection;
        String queryConditionOrder = query + ' order by ' + sortFullExp;
        authConList = Database.query(queryConditionOrder);
        return null;
    }
    
    /* metod to delete authorized contacts */
    public PageReference deleteAuthorizedContact() {
        String authConId = ApexPages.currentPage().getParameters().get('authConToDelete');
        List<Authorized_Contact__c> authConListToDelete = [Select id From Authorized_Contact__c where id = :authConId];
        try {
            if(authConListToDelete != null && authConListToDelete.size() > 0) {
                delete authConListToDelete;
            }
        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
        queryAuthorizedContacts();
        //entList = [select id, Name, AccountId, of_Allowed_Authorized_Contacts__c, OK_to_Add__c from Entitlement where AccountId = :accId];
        return null;
    }
}