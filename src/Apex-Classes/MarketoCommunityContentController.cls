public with sharing class MarketoCommunityContentController 
{
    // Exception vars
    public String exceptionText {get; private set;}
    public Boolean hasException {get; private set;}    
    
    // Matching member vars to make data input more customizable
    public String home1 {get; set;} 
    public String home2 {get; set;} 
    public String home3 {get; set;} 
    public String home4 {get; set;} 
    public String home5 {get; set;}
    public String home6 {get; set;} 

    public String hLURL1 {get; set;}
    public String hLLabel1 {get; set;}
    public String hLText1 {get; set;}
    public String hLURL2 {get; set;}
    public String hLLabel2 {get; set;}
    public String hLText2 {get; set;}
    public String hLURL3 {get; set;}
    public String hLLabel3 {get; set;}
    public String hLText3 {get; set;}
    public String hLURL4 {get; set;}
    public String hLLabel4 {get; set;}
    public String hLText4 {get; set;}
    
    // Other page vars...
    public String homeMessageRows {get; private set;}

    // This will contain dynamic page content and settings, retrieved from settings obj
    public MarketoCommunityContent__c marketoCommunityContent;
    
    public MarketoCommunityContentController()
    {
        fc();
    }   
    
    private void fc()
    {
        marketoCommunityContent = getMarketoCommunityContent();

        homeMessageRows = '7';
        customSettingToVars();
        hasException = false;
        exceptionText = '';
    }

    public void customSettingToVars()
    {
        home1 = marketoCommunityContent.Home_Message_1__c;
        home2 = marketoCommunityContent.Home_Message_2__c;
        home3 = marketoCommunityContent.Home_Message_3__c;
        home4 = marketoCommunityContent.Home_Message_4__c;
        home5 = marketoCommunityContent.Home_Message_5__c;
        home6 = marketoCommunityContent.Home_Message_6__c;

        hLURL1 = marketoCommunityContent.Home_Link_URL_1__c;
        hLLabel1 = marketoCommunityContent.Home_Link_Label_1__c;
        hLText1 = marketoCommunityContent.Home_Link_Text_1__c;
        hLURL2 = marketoCommunityContent.Home_Link_URL_2__c;
        hLLabel2 = marketoCommunityContent.Home_Link_Label_2__c;
        hLText2 = marketoCommunityContent.Home_Link_Text_2__c;
        hLURL3 = marketoCommunityContent.Home_Link_URL_3__c;
        hLLabel3 = marketoCommunityContent.Home_Link_Label_3__c;
        hLText3 = marketoCommunityContent.Home_Link_Text_3__c;
        hLURL4 = marketoCommunityContent.Home_Link_URL_4__c;
        hLLabel4 = marketoCommunityContent.Home_Link_Label_4__c;
        hLText4 = marketoCommunityContent.Home_Link_Text_4__c;
    }
    
    public void varsToCustomSetting()
    {
        try
        {
            marketoCommunityContent.Home_Message_1__c = home1;
            marketoCommunityContent.Home_Message_2__c = home2;
            marketoCommunityContent.Home_Message_3__c = home3;
            marketoCommunityContent.Home_Message_4__c = home4;
            marketoCommunityContent.Home_Message_5__c = home5;
            marketoCommunityContent.Home_Message_6__c = home5;
            
            marketoCommunityContent.Home_Link_URL_1__c = hLURL1;
            marketoCommunityContent.Home_Link_Label_1__c = hLLabel1;
            marketoCommunityContent.Home_Link_Text_1__c = hLText1;
            marketoCommunityContent.Home_Link_URL_2__c = hLURL2;
            marketoCommunityContent.Home_Link_Label_2__c = hLLabel2;
            marketoCommunityContent.Home_Link_Text_2__c = hLText2;
            marketoCommunityContent.Home_Link_URL_3__c = hLURL3;
            marketoCommunityContent.Home_Link_Label_3__c = hLLabel3;
            marketoCommunityContent.Home_Link_Text_3__c = hLText3;
            marketoCommunityContent.Home_Link_URL_4__c = hLURL3;
            marketoCommunityContent.Home_Link_Label_4__c = hLLabel3;
            marketoCommunityContent.Home_Link_Text_4__c = hLText3;

            upsert marketoCommunityContent;

            hasException = false;
            exceptionText = '';
        }
        catch(Exception e)
        {
            hasException = true;
            exceptionText = e.getMessage();
        }
    }
    
    public PageReference loadDefaults()
    {
        PageReference retVal;
        initMarketoCommunityContent(true);
        
        customSettingToVars();
        
        return retVal;
    }

    // Get custom settings from MarketoCommunityContent
    public MarketoCommunityContent__c getMarketoCommunityContent()
    {
        if(marketoCommunityContent == null)
            initMarketoCommunityContent();
        return marketoCommunityContent;
    }
    public void setMarketoCommunityContent(MarketoCommunityContent__c o)
    {
        this.marketoCommunityContent = o;
    }
    private void initMarketoCommunityContent()
    {
        initMarketoCommunityContent(false);
    }
    private void initMarketoCommunityContent(Boolean isForcedFresh) 
    {
        MarketoCommunityContent__c instance = MarketoCommunityContent__c.getInstance();
        
        if(instance == null || isForcedFresh)
        {
            instance = new MarketoCommunityContent__c(Home_Message_1__c = 'Hi! I am Heather, the Community Manager for the Marketo Community Hub. I am glad you\'re here. ' + 
                '\n\nIn this new community you can get product support, submit ideas, and connect with other Marketo users.', 
                Home_Message_2__c = 'Home message #2', 
                Home_Message_3__c = 'Home message #3', 
                Home_Message_4__c = 'Home message #4', 
                Home_Message_5__c = 'Home message #5', 
                Home_Message_6__c = 'Home message #6', 
                Home_Link_URL_1__c = 'http://www.google.com', Home_Link_Label_1__c = 'New Content:', Home_Link_Text_1__c = 'Landing Page Best Practices', 
                Home_Link_URL_2__c = 'http://www.dell.com', Home_Link_Label_2__c = 'New Release:', Home_Link_Text_2__c = 'See what\'s new this month in Marketo', 
                Home_Link_URL_3__c = 'http://www.yahoo.com', Home_Link_Label_3__c = 'New Survey:', Home_Link_Text_3__c = 'Who is your favorite marketer', 
                Home_Link_URL_4__c = 'http://www.bing.com', Home_Link_Label_4__c = 'Check out Bing.com:', Home_Link_Text_4__c = 'Just a link to Bing.com');
        } 

        marketoCommunityContent = instance;
        marketoCommunityContent.Name = 'Marketo Community Content';
    }
    
    public static testMethod void testContentController() {
    	
    	MarketoCommunityContentController c = new MarketoCommunityContentController();
    	c.customSettingToVars();
    	c.varsToCustomSetting();
    	c.loadDefaults();
    }
}