public class MarketoTemplateSuppLeftSidebarWaterCtrl {
    public Boolean authorizedUser {get; set;}
    //public Map<String,Integer> caseStatusToNumberOfCases{get;set;}
    public String currUserMunchkinId{get;set;}    
    public Id accId{get;set;}
    public String usrEntitlemntId{get;set;}
    public String entProcessName{get;set;}
    public String entProcessId{get;set;}

    public Id userContactId{get;set;}
    public String userType{get;set;}
    public Map<String, Integer> caseStatusToNumberOfCases{get;set;}
    
    //Constructor
    public MarketoTemplateSuppLeftSidebarWaterCtrl() {
        System.Debug('Support About+++++++');
        userType = UserInfo.getUserType();
        getCheckAuthorizedUser();
        caseStatusToNumberOfCases = getCaseInfoMap();
    }
    
    public Void getCheckAuthorizedUser() {
        if (userType != 'Standard' || test.isRunningTest()) {
            authorizedUser = true;
            List<User> usrList = [Select u.Username, u.UserType, u.LanguageLocaleKey, u.UserRole.Name, u.UserRoleId, u.Name, u.Contact.Name, u.Contact.FirstName, 
                u.Contact.LastName, u.Contact.AccountId, u.Contact.Is_Authorized_Contact__c, u.ContactId, u.AccountId
                From User u where Id =: UserInfo.getUserId()];
            Id userId = UserInfo.getUserId();
            accId = usrList[0].Contact.AccountId;
            System.Debug('accId++++'+accId);
            userContactId = usrList[0].ContactId;
            List<User> userList = [select id, Munchkin_ID__c from User where id = :UserInfo.getUserId()];
            System.debug('userList+++++'+userList);
            if(userList != null && userList.size() > 0) {
                currUserMunchkinId = userList[0].Munchkin_ID__c;               
            }
            System.Debug('currUserMunchkinId+++'+currUserMunchkinId);
            Map<Id,slaProcess> entitlementProcessIdToName = new Map<Id,slaProcess>();
            for(slaProcess tempslaProcess : [Select Id,Name from slaProcess]){
                entitlementProcessIdToName.put(tempslaProcess.Id,tempslaProcess);    
            }
            List<Entitlement> entList = [Select id, Status, AssetId, slaProcessId, AccountId From Entitlement where AccountId = :accId AND Asset.Munchkin_ID__c = :currUserMunchkinId and Status = 'Active' and (Asset.Munchkin_ID__c != null OR Asset.Munchkin_ID__c != '') limit 1];
            //System.debug('slaProcessId+++++' + entList[0].slaProcessId);
            if(!entList.isEmpty()) { 
                entProcessName = entitlementProcessIdToName.get(entList[0].slaProcessId).Name;     
                usrEntitlemntId = entList[0].Id;
                //System.debug('usrEntitlemntId==>' + usrEntitlemntId);
                //System.debug('isSpark+++++' + isSpark);

            } 
            if(usrList != null && usrList.size() > 0) {
                Id userContactId = usrList[0].ContactId;
                if(usrList[0].Contact.Is_Authorized_Contact__c != null && usrList[0].Contact.Is_Authorized_Contact__c.equals('No')) {
                    authorizedUser = false;
                }
            }
        }
    }
    
    public Map<String, Integer> getCaseInfoMap() {
        Map<String, Integer> caseStatusToNumberOfCases = new Map<String, Integer>();
        if (userType != 'Standard' || test.isRunningTest()) {
            String smRecIds = CaseRecordOrTypeIds__c.getValues('SM_RecordType_Ids').ReferenceIds__c;
            List<String> sm_RecId = new List<String>();
            sm_RecId = smRecIds.split(';');
            System.DebuG('userContactId+++'+userContactId);
            List<Case> myAllCases = [Select Id,isClosed,Case_Status__c,Close_Reason__c,EntitlementId,AccountId,ContactID from Case where contactId =: userContactId  and RecordTypeId NOT in :sm_RecId ];
            List<Case> allCompanyCases = [Select Id,isClosed,Case_Status__c,Close_Reason__c,EntitlementId,AccountId,ContactID from Case where accountId =: accId and RecordTypeId NOT in :sm_RecId ];
            System.Debug('sm_RecId++++'+sm_RecId);
            caseStatusToNumberOfCases = new Map<String,Integer>();
            caseStatusToNumberOfCases.put('Open',0);
            caseStatusToNumberOfCases.put('Closed',0);
            caseStatusToNumberOfCases.put('Pending Fix',0);
            caseStatusToNumberOfCases.put('Company Pending Fix',0);
            caseStatusToNumberOfCases.put('Company Closed',0);
            
            for(Case tempCase : myAllCases){
                If(tempCase.isClosed == false || tempCase.Case_Status__c == 'Suggestion Provided'){
                        caseStatusToNumberOfCases.put('Open',caseStatusToNumberOfCases.get('Open')+1); 
                } If(tempCase.isClosed == true && tempCase.Case_Status__c != 'Suggestion Provided' && tempCase.Case_Status__c != 'Awaiting Fix'){
                        caseStatusToNumberOfCases.put('Closed',caseStatusToNumberOfCases.get('Closed')+1); 
                } If(tempCase.isClosed == true && tempCase.Close_Reason__c == 'Awaiting Engineering Fix (Soft Close)' && tempCase.Case_Status__c == 'Awaiting Fix'){
                        caseStatusToNumberOfCases.put('Pending Fix',caseStatusToNumberOfCases.get('Pending Fix')+1); 
                }
            }
            for(Case tempCompanyCase : allCompanyCases){  
                If(tempCompanyCase.isClosed == true && tempCompanyCase.Close_Reason__c == 'Awaiting Engineering Fix (Soft Close)' && tempCompanyCase.Case_Status__c == 'Awaiting Fix'){
                        caseStatusToNumberOfCases.put('Company Pending Fix',caseStatusToNumberOfCases.get('Company Pending Fix')+1); 
                }else If(tempCompanyCase.isClosed == true && tempCompanyCase.Case_Status__c != 'Suggestion Provided' && tempCompanyCase.Case_Status__c != 'Awaiting Fix'){
                        caseStatusToNumberOfCases.put('Company Closed',caseStatusToNumberOfCases.get('Company Closed')+1); 
                }
            }
            System.Debug('userContactId+1234'+userContactId);
            System.Debug('caseStatusToNumberOfCases+++'+caseStatusToNumberOfCases.size());  
            System.Debug('MyClosedCases'+caseStatusToNumberOfCases.get('My_Closed_Cases'));
        } 
        return caseStatusToNumberOfCases;    
    } 
    
    public Map<String,String> getstatusTextToLabelMap() {
        Map<String,String> tempstatusTextToLabelMap = new Map<String,String>();
        tempstatusTextToLabelMap.put('Open','My_Open_Cases');
        tempstatusTextToLabelMap.put('Closed','My_Closed_Cases');
        tempstatusTextToLabelMap.put('Pending Fix','My_Awaiting_Fix_Cases');
        tempstatusTextToLabelMap.put('Company Pending Fix','All_Company_Awaiting_Fix_Cases');
        tempstatusTextToLabelMap.put('Company Closed','All_Company_Closed_Cases');
        return tempstatusTextToLabelMap;
    }
    @isTest(SeeAllData=true) 
    public static void testMarketoTemplateSuppLeftSidebarWaterCtrl () { 
        User testUser = new User();
        testUser = [Select id from User where userType != 'Standard' and isActive = true and ContactId != null Limit 1];

        System.runAs(testUser) {
            MarketoTemplateSuppLeftSidebarWaterCtrl test = new MarketoTemplateSuppLeftSidebarWaterCtrl (); 
            test.getstatusTextToLabelMap();  
            System.Debug('testUser+++++++'+testUser.Id);
        }
    }
}