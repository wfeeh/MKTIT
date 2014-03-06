public class MarketoPost extends MarketoBaseController{
 
    public Id id {get; private set;}
    public Id bestReplyId {get; private set;}
    public String status {get; private set;}
    public String voteTotal {get; private set;}
    public Integer numReplies {get; private set;}
    public Integer numComments {get; private set;}
    public String title {get; set;}
    public String cats {get; private set;}
    public String createDate {get; private set;}
    public DateTime createddate {get; private set;}
    public String body {get; set;}
   // public String Email{get;set;}
    public String shortBody {get; private set;}
    public User createBy {get; private set;}
    public List<Vote> votes {get; private set;}
    public Boolean isIdea {get; private set;}
    public Id parentIdea{get;set;}
    public Boolean isPartner {get; private set;}
    public Boolean isEmployee {get; private set;}
    public Boolean isConsultant {get; private set;}
    public Boolean isCustomer {get; private set;}
    public Boolean isQuestion {get; private set;}
    public Boolean isChampion {get; private set;}
    public Boolean isProfessional {get; private set;}
    public Boolean isEnterprise {get; private set;}
    public Boolean isSpark {get; private set;}
    public Boolean islocked {get; private set;}
    public List<CategoryWrapper> cw {get; private set;}
    public Map<String,String> categoryMap = new Map<String,String>();
    public Community_Profile__c profile {get; private set;}
    public User profileUser {get; private set;}
    public string userBadgeValue{get;private set;}
    public string badgeImage{get;set;}
    
    public Boolean isPartnerSupported{get;set;}
    
    public List<string> badgevalues{get; private set;} 
    public MarketoPost(Idea idea) {
        this(idea, null); 
    }
    
    public MarketoPost(Idea idea, Community_Profile__c profile) {
        this.profile = profile;
        
        votes = idea.Votes;
        voteTotal = String.valueOf(idea.VoteTotal/10);
        numComments = idea.Comments.size();
        status = idea.Status;
        cats = idea.Categories;
        islocked = idea.IsLocked;
        isIdea = true;
        isQuestion = false;
        parentIdea = idea.ParentIdeaId;
        
        createBy = idea.CreatedBy;
        isPartner = createBy.is_partner__c;
        isEmployee = createBy.is_employee__c;
        isConsultant = createBy.is_consultant__c;
        isCustomer = createBy.is_customer__c;
        isChampion = createBy.Champion__c;
        isProfessional = createBy.Professional__c;
        isEnterprise = createBy.Enterprise__c;
        isSpark  = createBy.Spark__c;
        //Email = createBy.Email;
           
        
        
        isPartnerSupported = false; //GlobalFunctions.getPartner_Supported_Status(createBy.id);  
        
        init(idea);
    }
    //badgeville changes for partner supported
    
    public MarketoPost(Idea idea, Community_Profile__c profile, Boolean isSupported ) {
        this.profile = profile;        
        votes = idea.Votes;
        voteTotal = String.valueOf(idea.VoteTotal/10);
        numComments = idea.Comments.size();
        status = idea.Status;
        cats = idea.Categories;
        islocked = idea.IsLocked;
        isIdea = true;
        isQuestion = false;
        parentIdea = idea.ParentIdeaId;
                
        createBy = idea.CreatedBy;
        isPartner = createBy.is_partner__c;
        isEmployee = createBy.is_employee__c;
        isConsultant = createBy.is_consultant__c;
        isCustomer = createBy.is_customer__c;
        isChampion = createBy.Champion__c;
        isProfessional = createBy.Professional__c;
        isEnterprise = createBy.Enterprise__c;
        isSpark  = createBy.Spark__c;
        //Email = createBy.Email;                         
        isPartnerSupported = isSupported ; 
        
        init(idea);
    }
    
    //badgeville changes for partner supported
    public MarketoPost(Question question) {
        this(question, null);
    }
    
    public MarketoPost(Question q, Community_Profile__c profile) {
        this.profile = profile;

        numComments = q.numReplies;
        cats = q.DataCategorySelections.size() > 0 ? q.DataCategorySelections[0].DataCategoryName : '';
        isQuestion = true;
        isIdea = false;
        bestReplyId = q.bestReplyId;
        createBy = q.CreatedBy;
        isPartner = createBy.is_partner__c;
        isEmployee = createBy.is_employee__c;
        isConsultant = createBy.is_consultant__c;
        isCustomer = createBy.is_customer__c;
        isChampion = createBy.Champion__c;
        isProfessional = createBy.Professional__c;
        isEnterprise = createBy.Enterprise__c;
        isSpark  = createBy.Spark__c;
        //Email = createBy.Email;
        
        isPartnerSupported = false; //GlobalFunctions.getPartner_Supported_Status(createBy.id);
        init(q);
    }
     //badgeville changes for partner supported            
    public MarketoPost(Question q, Community_Profile__c profile, Boolean isSupported) {
        this.profile = profile;
        numComments = q.numReplies;
        cats = q.DataCategorySelections.size() > 0 ? q.DataCategorySelections[0].DataCategoryName : '';
        isQuestion = true;
        isIdea = false;
        bestReplyId = q.bestReplyId;
        createBy = q.CreatedBy;
        isPartner = createBy.is_partner__c;
        isEmployee = createBy.is_employee__c;
        isConsultant = createBy.is_consultant__c;
        isCustomer = createBy.is_customer__c;
        isChampion = createBy.Champion__c;
        isProfessional = createBy.Professional__c;
        isEnterprise = createBy.Enterprise__c;
        isSpark  = createBy.Spark__c;
        //Email = createBy.Email;        
        isPartnerSupported = isSupported;
        init(q);
    }
    //badgeville changes for partner supported    
   public void setProfileImageName(){
     
    Map<String, Boolean> profile_badge_value  = new map<String, Boolean>();
    profile_badge_value.put('Partner',   isPartner);
    profile_badge_value.put('Champion',  isChampion);
    profile_badge_value.put('Employee',  isEmployee);
    profile_badge_value.put('Consultant',  isConsultant);
    userBadgeValue  = '';
    
    for(String profile_badge_val : profile_badge_value.keySet()) {
        if (profile_badge_value.get(profile_badge_val) == true) {
            userBadgeValue += profile_badge_val + ', ';
            //System.debug('*************** userBadgeValue : ' + userBadgeValue );
        }
    } 
    
    if(userBadgeValue.endsWith(', ')){
        userBadgeValue = userBadgeValue.substring(0,userBadgeValue.length()-2);
    }   
  }
    
    private void init(SObject obj) {           
        id = (Id) obj.get('Id');
        body = (String) obj.get('Body');
        title = (String) obj.get('Title');
        createddate = (DateTime) obj.get('CreatedDate');
        
        createDate = GlobalFunctions.formatDate(createddate);   
        categoryMap = DataCategoryHelper.getHelper(new String[]{'Question'}).getNameToLabelMap();
        
        cw = new List<CategoryWrapper>();
        if (cats != null) {
            List<String> c = cats.split(';');
            for (Integer i = 0; i < c.size(); i++) {
                if (isQuestion) {
                    cw.add(new CategoryWrapper(c[i], i < c.size() - 1 ? categoryMap.get(c[i]) + ' •' : categoryMap.get(c[i])));
                } else {
                    cw.add(new CategoryWrapper(c[i], i < c.size() - 1 ? c[i] + ' •' : c[i]));
                }
            }
        }
        setProfileImageName();                  
        shortBody = GlobalFunctions.getShortBody(body);
    }
    
    public String getPostedBy() {
        if (profile != null && profile.Display_Name__c != null && profile.Display_Name__c.trim().length() > 0) {
            return profile.Display_Name__c;
        } else {
            return createby.firstname + ' ' + createby.lastname.substring(0, 1);
        }
    }
        
    public Boolean getUserVoted() {
        if (votes != null && votes.size() > 0) {
            return true;
        }
        return false;
    }
    
    public class CategoryWrapper {
        public String name {get; private set;}
        public String label {get; private set;}

        public CategoryWrapper(String name, String label) {
            this.name = name;
            this.label = label;
        }
    }

}