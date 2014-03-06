public class MarketoIdeaNewController extends MarketoBaseController {
    
    public Idea newIdea {get; set;}
    public Boolean subscribe {get; set;}
    private transient Idea[] searchResult;
    public String defaultTitle { get; set; }
    private Boolean searchSimilar = false;
    
    private static Id communityProfilePicturesFolderId = [select Id from Folder where Name = 'Community Discussion new'].Id;
    
    public MarketoIdeaNewController() {
        init();
    }
    
    private void init() {
        newIdea = new Idea(); 
        subscribe = true;
    }
    
    public PageReference save() {
        List<String> msg = new List<String>();
        if (newIdea.title == null)
            msg.add('Title');
        if (newIdea.body == null || newIdea.body == '')
            msg.add('Description');
        if (newIdea.categories == null)
            msg.add('Categories');
        
        
        if (msg.size() > 0) {
            String msg2 = 'Missing required fields: ';
            for (Integer i=0; i<msg.size(); i++) {
                msg2 +=  msg[i] + (i<msg.size()-1 ? ', ' : '');
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg2));
            return null;
        }
        
        /* badgeville kanupriyag@grazitti.com 16-04-2012 */
           BadgeVilleWebServiceCallout badgeAskQuest = new BadgeVilleWebServiceCallout();
           badgeAskQuest.badgvilleSubmitIdea();  
        /* badgeville kanupriyag@grazitti.com 16-04-2012 */
           
        /* 14-05-11 vishals@grazitti.com Added to preserve carriage return*/ 
        if(!getIsRichTextRequired())
            newIdea.body = preserveCarriageReturn(newIdea.body);
            newIdea.communityId = GlobalFunctions.communityId;
            newIdea.Status = 'New';
            upsert newIdea;
        
        if (subscribe) {
            Community_Subscription__c s = new Community_Subscription__c();
            s.idea_question_id__c = newIdea.id;
            s.user__c = UserInfo.getUserId();
            s.type__c = 'Idea';
            insert s;
        }
        
        PageReference retVal = Page.MarketoIdeasHome;       
        retVal.setRedirect(true);
        
        return retVal;
    }

    public Idea getIdea() {
        return newIdea;
    }
    public PageReference loadSimilar() {
        Id[] similarIds = Ideas.findSimilar(newIdea);

        if (similarIds == null || similarIds.size() == 0) {
            searchSimilar = true;
            return null;
        } else {
            searchResult = [select title from idea where id in :similarIds];
        }
        
        return null;
    }

    public Integer getHasSimilarIdeas() {
        if (searchResult != null && searchResult.size() > 0)
            return 1;
        else if (searchSimilar && (searchResult==null || searchResult.size()==0))
            return 0;
        return -1;
    }
    
    public Idea[] getSimilarIdeas() {
        return searchResult;
    }
    
    public static testMethod void testIdeasNewController() {
        MarketoIdeaNewController c = new MarketoIdeaNewController();
        c.newIdea.title = 'Test';
        c.newIdea.body = 'Test';
        c.newIdea.categories = 'Test';
        c.loadSimilar();
        c.getHasSimilarIdeas();
        c.getSimilarIdeas();
        
        c.subscribe = true;
         /*09-03-11 vishals@grazitti.com Added to increase code coverage */
        C.getIdea();
        c.save();
    }
    
    /* 09-03-11 vishals@grazitti.com Added to increase code coverage */
    public static testMethod void testIdeasNewController2() {
        MarketoIdeaNewController c = new MarketoIdeaNewController();
        //c.newIdea.title = 'Test';
        //c.newIdea.body = 'Test';
        //c.newIdea.categories = 'Test';
        c.save();
    }

}