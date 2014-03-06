public class MarketoCommunityLoginController {

    public String username {get; set;}
    public String password {get; set;}

    public PageReference login() {
    			
		List<String> msgs = new List<String>();
		
        if (username == null) {
            msgs.add('Username');
        }
        
        if (password == null) {
            msgs.add('Password');
        }
       
        if (msgs.size() > 0) {
        	
            String msg = 'Required fields are missing: ';
            for (Integer i=0; i<msgs.size(); i++) {
                msg +=  msgs[i] + (i<msgs.size()-1 ? ', ' : '');
            }	
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
            return null;
        }
		//PageReference pgHome = Page.MarketoCommunityHome;
		//pgHome.getParameters().put('showHeroPopup','true');
        return Site.login(username, password, '/MarketoCommunityHome?showHeroPopup=true');
    }
    
    public static testMethod void testSiteLoginController () {
        
        MarketoCommunityLoginController c = new MarketoCommunityLoginController();
        system.assertEquals(c.login(), null);
        
        c.username = 'tester@2marketo.com';
        c.password = 'abc123456'; 
        c.login();            
    }    
}