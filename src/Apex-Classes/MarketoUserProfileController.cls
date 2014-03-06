public class MarketoUserProfileController 
{
	/*
	
	public User user {get; set;}
	public String position {get; set;}
	public Boolean editMode {get; set;}
	public List<Activity> rows {get; set;}
	
	public MarketoUserProfileController() {
		init();
	}
    public void init() 
    {
    	editMode = false;
    	
    	user = [select firstname, lastname, about_me__c, communitynickname, companyname, is_partner__c, is_employee__c, is_consultant__c, is_customer__c from User 
    			where id = :ApexPages.currentPage().getParameters().get('id')];
    	
    	List<Long> times = new List<Long>();
        Map<Long,Activity> rowMap = new Map<Long,Activity>();
              
    	for (Idea id : GlobalFunctions.getIdeasForProfile(user.id)) {
            times.add(id.createddate.getTime());
            rowMap.put(id.createdDate.getTime(), new Activity(id.id, id.title, GlobalFunctions.getShortBody(id.Body), id.createdby.communitynickname, id.createdbyid, id.createddate, 'Idea'));
        }
        
    	for (Question q : GlobalFunctions.getQuestionsForProfile(user.id)) {
            times.add(q.createddate.getTime());
            rowMap.put(q.createdDate.getTime(), new Activity(q.id, q.title, GlobalFunctions.getShortBody(q.Body), q.createdby.communitynickname, q.createdby.id, q.createddate, 'Question'));
        }
    
    	for (IdeaComment ic : GlobalFunctions.getComments(user.id)) {
            times.add(ic.createddate.getTime());
            rowMap.put(ic.createdDate.getTime(), new Activity(ic.idea.id, ic.Idea.title, GlobalFunctions.getShortBody(ic.commentBody), ic.createdby.communitynickname, ic.createdbyid, ic.createddate, 'IdeaComment'));
        }
        
        for (Reply r : GlobalFunctions.getRepliesForProfile(user.id)) {
            times.add(r.createddate.getTime());
            rowMap.put(r.createdDate.getTime(), new Activity(r.question.id, r.Question.title, GlobalFunctions.getShortBody(r.body), r.createdby.communitynickname, r.createdby.id, r.createddate, 'Reply'));
        }
        
        times.sort();
        rows = new List<Activity>();
        for (Integer i=times.size()-1; i>=0; i--) {
        	if (rows.size() < 10) {
            	rows.add(rowMap.get(times[i]));
        	}
        }
    }
    
    public Boolean canEdit {
    	get {
    		return (UserInfo.getUserId()==user.Id && !editMode);
    	}
    }
    
    public PageReference edit() {
    	editMode = true;
    	return null;
    }
    
    public PageReference save() {
    	
    	update user;
    	
    	editMode = false;
    	return null;
    }
    
     public PageReference cancel() {
    	
    	editMode = false;
    	return null;
    }
    
    public PageReference editPhoto() {
    	return null;
    }
    
    public class Activity {
    	
    	public Id id {get; set;}
    	public String title {get; set;}
    	public String body {get; set;}
    	public String poster {get; set;}
    	public Id createdById {get; set;}
    	public String daysElapsed {get; set;}
    	public DateTime createddate {get; set;}
    	public String activityType {get; set;}
    	
    	public Activity (Id id, String title, String body, String poster, Id createdById, DateTime createddate, String activityType) {
    		this.id = id;
    		this.title = title;
    		this.body = body;
    		this.poster = poster;
    		this.activityType = activityType;
    		this.createddate = createddate;
    		this.createdById = createdById;
    		this.daysElapsed = String.valueOf(createddate.date().daysBetween(system.today()));
    	}
    	
    	public String getSection() {
    		return activityType.indexOf('Idea') > -1 ? 'Idea' : 'Question';
    	}
    }
    
    public static testMethod void testProfileController() {
    	
    	User u = [select id from User limit 1];
    	//Added by Vishal to increase code coverage 
    	Idea idea = new Idea();
		idea.Title = 'Test';
		idea.Body = 'Test';
		idea.CommunityId = GlobalFunctions.communityId;
		insert idea;
		
    	ApexPages.currentPage().getParameters().put('id', u.id);
    	MarketoUserProfileController c = new MarketoUserProfileController();
    	c.init();
    	system.debug(c.canEdit);
    	c.edit();
    	c.save();
    	c.cancel();
    	c.editPhoto();
    }
    
    // 09-03-11 vishals@grazitti.com Added to increase code coverage 
    public static testMethod void testProfileController2() {    	
    	Idea idea = new Idea();
		idea.Title = 'Test';
		idea.Body = 'Test';
		idea.CommunityId = GlobalFunctions.communityId;
		insert idea;
		
		Question question = new Question();
        question.Title = 'Test';
        question.Body = 'Test';
        question.CommunityId = GlobalFunctions.communityId;
        insert question;
        
    	ApexPages.currentPage().getParameters().put('id', userinfo.getuserid());
    	MarketoUserProfileController c = new MarketoUserProfileController();
    	c.init();
    	system.debug(c.canEdit);
    	c.edit();
    	c.save();
    	c.cancel();
    	c.editPhoto();
    }
    */
}