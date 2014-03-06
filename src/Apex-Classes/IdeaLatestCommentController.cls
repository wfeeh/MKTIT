public class IdeaLatestCommentController {
    
    public Idea idea {get; set;}
    
    public IdeaComment getLatestComment() {
        try {
            IdeaComment comment = [select Id,CreatedBy.FirstName,CreatedBy.LastName,CommentBody from IdeaComment where IdeaId = :idea.Id order by CreatedDate desc limit 1];
            return comment;
        } catch (Exception e) {
            return new IdeaComment();
        }
    }

    public static testMethod void testController() {
        IdeaLatestCommentController controller = new IdeaLatestCommentController();
        controller.getLatestComment();
        
        Idea idea = new Idea();
        idea.Title = 'Test';
        idea.Body = 'Test';
        idea.CommunityId = GlobalFunctions.communityId;
        insert idea;
        
        IdeaComment comment = new IdeaComment();
        comment.IdeaId = idea.Id;
        comment.CommentBody = 'Test';
        insert comment;
        
        controller.idea = idea;
        controller.getLatestComment();
    }

}