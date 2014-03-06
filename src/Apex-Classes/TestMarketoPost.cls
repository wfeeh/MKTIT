/*
   17-03-11 vishals@grazitti.com
   Created Test class to increase code coverage.
*/
@isTest
private class TestMarketoPost {
	
	static testmethod void TestMarketoPost1(){
		Idea idea = new Idea();
		idea.Title = 'Test';
		idea.Body = 'Test';
		idea.CommunityId = GlobalFunctions.communityId;
		insert idea;
		
		idea = [Select  (Select Id, IsDeleted, ParentId, Type, CreatedDate, CreatedById, SystemModstamp From Votes) ,  (Select Id, IdeaId, CommentBody, CreatedById, CreatedDate, SystemModstamp, IsDeleted, IsHtml From Comments) , createdBy.is_partner__c, createdBy.is_employee__c, createdBy.is_consultant__c,createdBy.is_customer__c, createdBy.Champion__c, createdBy.Enterprise__c, createdBy.Professional__c, createdBy.Spark__c, CreatedBy.FirstName, CreatedBy.LastName, i.VoteTotal, i.VoteScore, i.Title, i.SystemModstamp, i.Status, i.ParentIdeaId, i.NumComments, i.MarketoId__c, i.LastModifiedDate, i.LastModifiedById, i.LastCommentId, i.LastCommentDate, i.IsLocked, i.IsHtml, i.IsDeleted, i.Id, i.CreatedDate, i.CreatedById, i.CommunityId, i.Categories, i.Body From Idea i where id=:idea.Id];
		IdeaComment comment = new IdeaComment();
		comment.IdeaId = idea.Id;
		comment.CommentBody = 'Test';
		insert comment;
		
		Question question = new Question();
        question.Title = 'Test';
        question.Body = 'Test';
        //question.categories = 'Marketing_Activities';
        question.CommunityId = GlobalFunctions.communityId;
        insert question;
		question = [Select  (Select Id, ParentId, DataCategoryGroupName, DataCategoryName, CreatedDate, CreatedById, IsDeleted, SystemModstamp From DataCategorySelections),createdBy.is_partner__c, createdBy.is_employee__c, createdBy.is_consultant__c, createdBy.Champion__c, createdBy.Enterprise__c, createdBy.Professional__c, createdBy.Spark__c, createdBy.is_customer__c, CreatedBy.FirstName, CreatedBy.LastName, q.Title, q.SystemModstamp, q.NumReplies, q.LastReplyId, q.LastReplyDate, q.LastModifiedDate, q.LastModifiedById, q.IsDeleted, q.Id, q.CreatedDate, q.CreatedById, q.CommunityId, q.Body, q.BestReplyId From Question q where Id=:question.Id];
		Reply myReply = new Reply(QuestionId = question.Id);
        myReply.Body = ' answer 2';
        insert myReply;
        
        Community_profile__c profile;
		
		List<Community_profile__c> profileList = [Select c.Website__c, c.User__c, c.Twitter__c, c.Title__c, c.SystemModstamp, c.Profile_Picture_ID__c, c.Picture_Link__c, c.OwnerId, c.Name, c.Location__c, c.LinkedIn__c, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Facebook__c, c.Display_Name__c, c.Customer_Since__c, c.CreatedDate, c.CreatedById, c.CreatedBy.FirstName, c.CreatedBy.LastName, c.Company_Name__c, c.About_Me__c From Community_Profile__c c limit 1];
		if(profileList.size() == 0){
			profile = new Community_profile__c();
			profile.Display_Name__c = 'test';
			profile.User__c = UserInfo.getUserId();
			insert profile;
		}
		MarketoPost mPost1 = new MarketoPost(idea);
		
		mPost1 = new MarketoPost(idea, profile);
		
		mPost1 = new MarketoPost(question);
		
		mPost1 = new MarketoPost(question, profile);
		mPost1.getPostedBy();
		mPost1.getUserVoted();
		
	}
}