public class SolrMarketoSearchController  {

    public XMLDom xmlResult;
    public List<resultElement> results                  {get;set;}
    public String spellResults                          {get;set;}
    public String searchText                            {get;set;}
    public Integer numberOfResults                      {get;set;}
    public List<Integer> paginationList                 {get;set;}
    public Integer currentPage                          {get;set;}
    public String sortBy                                {get;set;}
    public Map<String,Integer> categoryToResultCountMap {get;set;}
    public Map<id, Idea>     ideasAdditionalInfo        {get;set;}
    public Map<id, Question> qsnsAdditionalInfo         {get;set;}
    public Map<id, boolean>  hasvoteMap                 {get;set;}

    public String solrServerURL = System.label.solrapiurl;
    //public String  genericPageSize = '5';
    
    public PageReference initialize() {
        searchText         = (ApexPages.currentPage().getParameters().get('searchText') != null)?ApexPages.currentPage().getParameters().get('searchText'):'';
        String dCategoryFq = (ApexPages.currentPage().getParameters().get('dcategory') != null && ApexPages.currentPage().getParameters().get('dcategory') != '')?'&fq=dcategory:'+EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('dcategory'),'UTF-8'):'';
        HTTPResponse response;
        
        if(searchText == '') {searchText='*:*';}
        
        sortBy              = (ApexPages.currentPage().getParameters().get('sortby') != null)?ApexPages.currentPage().getParameters().get('sortby'):'';
        String getResults   =  ApexPages.currentPage().getParameters().get('get_results') != null?ApexPages.currentPage().getParameters().get('get_results'):'';

        String sortByQueryString = '';
        if(sortBy == 'lastmodified') {
            sortByQueryString = '&sort=lastmodified+desc';
        } else if (sortBy == 'viewcount') {
            sortByQueryString = '&sort=viewcount+desc';
        }
        String origQueryString = sortByQueryString;    
        //String sortByForProfiles = '&sort=lastmodified+desc';
        
        //Get the result counter for all the categories first
        categoryToResultCountMap             = new Map<String, Integer>();
       
        List <String>all_top_categories      = new List<String>{'&fq=top_category:Article+top_category:Tutorial+top_category:Video+top_category:IssueSolution+top_category:Deepdive', '&fq=top_category:Idea', '&fq=top_category:Discussion', '&fq=top_category:CommunityProfile', '&fq=top_category:Resource' };        
        Map<String,String> solrKeyToCategMap = new Map<String, String>{'&fq=top_category:Article+top_category:Tutorial+top_category:Video+top_category:IssueSolution+top_category:Deepdive'=>'Article,Tutorial,Video,IssueSolution,Deepdive', '&fq=top_category:Idea'=>'Idea', '&fq=top_category:Discussion'=>'Discussion', '&fq=top_category:CommunityProfile'=>'CommunityProfile', '&fq=top_category:Resource'=>'Resource' };
        
        String countSolrApiUrl               = solrServerURL+'/select?userType='+userinfo.getUserType()+'&userId='+userinfo.getUserId()+'&spellcheck.onlyMorePopular=true&spellcheck=true&spellcheck.dictionary=freq&spellcheck.extendedResults=true&spellcheck.collate=true&hl.fragsize=50000&hl=true&hl.fl=title,summary&indent=on&version=2.2&facet=on&facet.field=top_category&start=0&rows=0&';
        
        for (String top_category_temp:all_top_categories) {
            String encodedURL = '';
           
            if (top_category_temp == '&fq=top_category:CommunityProfile' && sortBy == 'lastmodified') {
                Datetime sixMonthsFromNow = Datetime.now().addMonths(-6);
                sortByQueryString = '&sort=lastmodified+desc&fq=lastmodified:['+sixMonthsFromNow.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'+TO+NOW]';                   
                //sortByQueryString = '';
            } else if (top_category_temp == '&fq=top_category:CommunityProfile' && (sortBy == 'relevancy' || sortBy == '')) {
                Datetime sixMonthsFromNow = Datetime.now().addMonths(-6);
                sortByQueryString = '&fq=lastmodified:['+sixMonthsFromNow.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'+TO+NOW]';                   
                //sortByQueryString = '';
            } else {
                sortByQueryString = origQueryString;
            }
                       
            if (searchText != '*:*') {
                encodedURL = countSolrApiUrl + 'defType=dismax&pf=keywords^500.0&qf=keywords+title^8.0+summary^6.0+body^4.0&q='+EncodingUtil.urlEncode(searchText, 'UTF-8')+''+sortByQueryString+top_category_temp+dCategoryFq;
            } else {
                encodedURL = countSolrApiUrl + 'q='+searchText+''+sortByQueryString+top_category_temp+dCategoryFq;
            }
            response = makeAPIRequest(encodedURL);
            if (response == null) {
                notifySolrDownEvent();
                return new PageReference('/apex/AdvanceMarketoSearchResults?searchText='+searchText+'&searchType=');
            } 
            categoryToResultCountMap.put(solrKeyToCategMap.get(top_category_temp),parseResultCount(response));
        }        
        
        // Get the results of the specific category requested
        String top_category           = (ApexPages.currentPage().getParameters().get('top_category') != null)?ApexPages.currentPage().getParameters().get('top_category'):'';
        List <String> top_categories  = new List<String>();
        if(top_category != '') {top_categories = top_category.split(',');}
        
        String top_category_query = '&fq='; //fq=type:knowledgeBase
        //System.debug('top_CATEGORIRES_'+top_categories.size());
        //sortByQueryString = '';
        if (top_categories.size() > 0) {
            for (String temp_category:top_categories) {
                top_category_query += 'top_category:'+temp_category+'+';  
                if (temp_category == 'CommunityProfile' && sortBy == 'lastmodified') {
                    Datetime sixMonthsFromNow = Datetime.now().addMonths(-6);
                    sortByQueryString = '&sort=lastmodified+desc&fq=lastmodified:['+sixMonthsFromNow.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'+TO+NOW]';                   
                }
                else if (temp_category == 'CommunityProfile' && (sortBy == 'relevancy' || sortBy == '')) {
                    Datetime sixMonthsFromNow = Datetime.now().addMonths(-6);
                    sortByQueryString = '&fq=lastmodified:['+sixMonthsFromNow.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')+'+TO+NOW]';                   
                } else {
                    sortByQueryString = origQueryString;
                }               
            }
        }            
        
        currentPage = ApexPages.currentPage().getParameters().get('page')!=null?integer.valueof(ApexPages.currentPage().getParameters().get('page')):0;
        
        String SolrApiUrl = '';
        if (top_category_query.contains('CommunityProfile')) {
            // STOPEED HIGHLIGHTING SolrApiUrl = solrServerURL+'/select?userType='+userinfo.getUserType()+'&userId='+userinfo.getUserId()+'&spellcheck.onlyMorePopular=true&spellcheck=true&spellcheck.dictionary=freq&spellcheck.extendedResults=true&spellcheck.collate=true&hl.fragsize=450&hl=true&hl.fl=title,summary&hl.simple.pre=<span+class%3D"highlight">&hl.simple.post=<%2Fspan>&fl=lastmodified,sfdcid,summary,title,top_category,child_category,body&indent=on&version=2.2&facet=on&facet.field=top_category&start='+(currentPage*10)+'&';
            SolrApiUrl = solrServerURL+'/select?userType='+userinfo.getUserType()+'&userId='+userinfo.getUserId()+'&spellcheck.onlyMorePopular=true&spellcheck=true&spellcheck.dictionary=freq&spellcheck.extendedResults=true&spellcheck.collate=true&hl.fragsize=450&fl=lastmodified,sfdcid,summary,title,top_category,child_category,body&indent=on&version=2.2&facet=on&facet.field=top_category&start='+(currentPage*10)+'&';
        } else {
            // STOPPED HIGHLIGHTING SolrApiUrl = solrServerURL+'/select?userType='+userinfo.getUserType()+'&userId='+userinfo.getUserId()+'&spellcheck.onlyMorePopular=true&spellcheck=true&spellcheck.dictionary=freq&spellcheck.extendedResults=true&spellcheck.collate=true&hl.fragsize=450&hl=true&hl.fl=title,summary&hl.simple.pre=<span+class%3D"highlight">&hl.simple.post=<%2Fspan>&fl=lastmodified,sfdcid,summary,title,top_category,child_category&indent=on&version=2.2&facet=on&facet.field=top_category&start='+(currentPage*10)+'&';
            SolrApiUrl = solrServerURL+'/select?userType='+userinfo.getUserType()+'&userId='+userinfo.getUserId()+'&spellcheck.onlyMorePopular=true&spellcheck=true&spellcheck.dictionary=freq&spellcheck.extendedResults=true&spellcheck.collate=true&fl=lastmodified,sfdcid,summary,title,top_category,child_category&indent=on&version=2.2&facet=on&facet.field=top_category&start='+(currentPage*10)+'&';
        }
        
        String encodedURL = '';
        
        if (searchText != '*:*') {
            encodedURL = SolrApiUrl  + 'defType=dismax&pf=keywords^500.0&qf=keywords+title^8.0+summary^6.0+body^4.0&q='+EncodingUtil.urlEncode(searchText, 'UTF-8')+''+sortByQueryString+top_category_query+dCategoryFq;
        } else {
            encodedURL = SolrApiUrl  + 'q='+searchText+''+sortByQueryString+top_category_query+dCategoryFq;
        }
        
        response = makeAPIRequest(encodedURL);
        if (response == null) {
            notifySolrDownEvent();
            return new PageReference('/apex/AdvanceMarketoSearchResults?searchText='+searchText+'&searchType=');
        }            
        categorySpecificResults(response);
        return null;       
    }
    public Pagereference insertIdeaVote(){
        String ideaId = Apexpages.currentPage().getParameters().get('firstParam');
        Id idea_id = Id.valueOf(ideaId);
        if(idea_id != null){
            try{
                Vote vote = new Vote();
                vote.ParentId = idea_id;
                vote.Type = 'Up';
                insert vote;
                System.Debug('VOTEINSERTED');       
                hasvoteMap.put(idea_id, false);
                idea ideainsert = [Select id, status, CreatedById, ParentIdeaId, VoteTotal, (Select Id,  CreatedById From Votes) from Idea where id =:idea_id limit 1];
                ideasAdditionalInfo.put(idea_id,ideainsert); 
                BadgeVilleWebServiceCallout.badgvillePointsOnAnIdea(idea_id);  
            }catch(Exception ex){
                System.Debug('Exception=>' + ex);
                //Handle Duplicate Insertion.
            }
        }
        return null;
    } 
    public Integer parseResultCount(HttpResponse response) {
        xmlResult = new XMLDom(response.getBody());
        xmldom.element xmlResultNode = xmlResult.getElementByTagName('result');
        return integer.ValueOf(xmlResultNode.getAttribute('numFound'));
    }
    
    
    public void notifySolrDownEvent(){ //__TEMPORARY_FUNCTION_TO_MONITOR_SOLR_DOWN_EVENT__
        Solr_Status__c solrStatus = [Select Name,IsSolrDown__c from Solr_Status__c Limit 1];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'community@marketo.com'];
        if(solrStatus.IsSolrDown__c == false){
            try{
                Messaging.SingleEmailMessage solrBreakDownEmail  = new Messaging.SingleEmailMessage();
                String[] emailRecipient = new String[]{'vishals@grazitti.com'};
                solrBreakDownEmail.setToAddresses(emailRecipient);
                solrBreakDownEmail.setOrgWideEmailAddressId(owea.get(0).Id);
                solrBreakDownEmail.setReplyTo('vishals@grazitti.com');
                //solrBreakDownEmail.setSenderDisplayName('Marketo- SOLR IS DOWN ');
                solrBreakDownEmail.setSubject('Solr Is Down Please Fix It ASAP');
                solrBreakDownEmail.setHtmlBody('Dear Administrator, Solr is down and flag "Is Solr Down" is set to true. ,So as to recieve mails of further breakdowns<br /><br /> Thanks<br />Grazitti Interactive');
                Messaging.sendEmail(new Messaging.Email[] { solrBreakDownEmail  });
                solrStatus.IsSolrDown__c = true;
                update solrStatus;
            }
            catch(EmailException e){
                System.debug(e.getMessage());
            }
        }
    }
        
    public HTTPResponse makeAPIRequest(String encodedURL) {
        HTTPResponse response;
        HttpRequest req  = new HttpRequest();
        req.setEndPoint(encodedURL );
        req.setMethod('GET');
        Http http = new Http();
        
        if (!Test.isRunningTest()) {
            response  = http.send(req);
            System.Debug('REQUESTISTHERE'+req);
            if (response.getStatus() == 'OK') {
                System.debug('RESPONSEISTHERE'+response);
                return response;
            } else {
                return null;
            }
        } else {
            response = new HTTPResponse();
            response.setBody('<?xml version="1.0" encoding="UTF-8"?><response><lst name="responseHeader"><int name="status">0</int><int name="QTime">0</int><lst name="params"><str name="fl">sfdcid,type,title,body,summary,lastmodified,top_category</str><str name="q">*:*</str><arr name="fq"><str>top_category:Idea</str><str>sfdcid:087W00000004GG2IAM</str></arr></lst></lst><result name="response" numFound="1" start="0"><doc><str name="sfdcid">087W00000004GG2IAM</str><str name="title">Test Idea</str><str name="summary">Test Idea</str><str name="body">Testing comments on ideas! Test Comment2 Test Comment Test Comment 12_02_13 </str><str name="lastmodified">2013-02-12T12:45:23.000Z</str><str name="top_category">Idea</str></doc></result></response>');
            return response;        
        }
    }
    
    /* DEPRECATED
    public void getGenericResults(List<String> top_categories, Map<String,HTTPResponse> res){
        results = new List<resultElement>();

        // Get the top_categories to be fetched
        knbResults                = new List<resultElement>();
        ideaResults               = new List<resultElement>();
        discussionResults         = new List<resultElement>();
        communityProfileResults   = new List<resultElement>();
        resourceResults           = new List<resultElement>(); 
        
        for(String top_category:top_categories) {
            results = new List<resultElement>();
            string solr_results = res.get(top_category).getBody();
            //System.debug('LWE_results '+solr_results );
            xmlResult = new XMLDom(solr_results );
            //System.debug('dom-->'+xmlResult );
            xmldom.element xmlResultNode = xmlResult.getElementByTagName('result');
            numberOfResults            = integer.ValueOf(xmlResultNode.getAttribute('numFound'));
            Integer paginationStart    = integer.ValueOf(xmlResultNode.getAttribute('start'));
            List<xmldom.element> docNodesList = xmlResultNode.getElementsByTagName('doc');
            //results = parseSolrDom(docNodesList); Commented for highlighters ticket 4603
            results = parseSolrDom(xmlResult);
            spellResults = spellSuggester(xmlResult);
            
            System.Debug('TOP_CATEGORY'+top_category);
            if (top_category.contains('Idea')) {
                ideaResults.addAll(results);
                if(numberOfResults > integer.valueOf(genericPageSize)){
                    showMoreIdea = true;
                }
            } else if (top_category.contains('Discussion')) {
                discussionResults.addAll(results);
                if(numberOfResults > integer.valueOf(genericPageSize)){
                    showMoreDiscussion = true;
                }               
            } else if (top_category.contains('CommunityProfile')) {
                communityProfileResults.addAll(results);
                if(numberOfResults > integer.valueOf(genericPageSize)){
                    showMoreCommunityProfile = true;
                }
            } else if (top_category.contains('Resource')) {
                resourceResults.addAll(results);
                if(numberOfResults > integer.valueOf(genericPageSize)){
                    showMoreResource = true;
                }                   
            } else {
                knbResults.addAll(results);
                if(numberOfResults > integer.valueOf(genericPageSize)){
                    showMoreKnb = true;
                }                
            }            
        } 
        System.debug('IDEA_SIZE'+ideaResults.size()); System.debug('DSC_SIZE'+discussionResults.size()); System.debug('KNB_SIZE'+knbResults.size());
    }
    */
    
    public void categorySpecificResults(HTTPResponse res) {
        results             = new List<resultElement>();
        string solr_results = res.getBody();
        xmlResult           = new XMLDom(solr_results);
        
        xmldom.element xmlResultNode = xmlResult.getElementByTagName('result');
        numberOfResults              = integer.ValueOf(xmlResultNode.getAttribute('numFound'));
        Integer paginationStart      = integer.ValueOf(xmlResultNode.getAttribute('start'));
        
        paginationList = createPaginationList(numberOfResults, currentPage, 10);

        //List<xmldom.element> docNodesList = xmlResultNode.getElementsByTagName('doc');
        
        results      = parseSolrDom(xmlResult);
        spellResults = spellSuggester(xmlResult);
    }
    
    public String spellSuggester(XMLDom xmlResult){
        List<xmldom.element> xmlResultNodeSpell     =  xmlResult.getElementsByPath('/response/lst/lst/str');
            
            for(xmldom.element ResultNodeSpellList:xmlResultNodeSpell){
                System.Debug('NAMES__NAMES'+ResultNodeSpellList.getAttribute('name'));
                String spellNode = ResultNodeSpellList.getAttribute('name');
                if (spellNode == 'collation'){
                    spellResults = ResultNodeSpellList.textcontent();
                } 
            }
            return spellResults;
    }
    
    public List<resultElement> parseSolrDom(XMLDom xmlResult) {

        xmldom.element xmlResultNode = xmlResult.getElementByTagName('result');
        numberOfResults              = integer.ValueOf(xmlResultNode.getAttribute('numFound'));
        Integer paginationStart      = integer.ValueOf(xmlResultNode.getAttribute('start'));
        
        List<xmldom.element> docNodesList = xmlResultNode.getElementsByTagName('doc');
        
        List<ID> sortedIDs =  new List<Id>();

        Map<String,resultElement> results = new Map<String,resultElement>();
        
        for (xmldom.element docNode:docNodesList) {
            //System.debug('__DOC__'+docNode);
            List<xmldom.element> subNodesList = docNode.getElementsByTagName('str');
            resultElement resultNode          = new resultElement();
            
            for(xmldom.element subNode:subNodesList) {
               String nodeName    = subNode.getAttribute('name'); 
               String nodeContent = subNode.textContent();
               nodeContent  = nodeContent.replace('\\','');
               //system.debug('nodeContent-->'+nodeContent);
               if(nodeName=='sfdcid') {
                       resultNode.sfdc_id = nodeContent;
               } else if (nodeName=='summary'){  
                       resultNode.summary = GlobalFunctions.getShortBody(nodeContent);
               } else if (nodeName=='title'){ 
                       resultNode.title = nodeContent;
               } else if (nodeName=='top_category') {
                       resultNode.top_category = nodeContent;
               } else if (nodeName=='child_category') {
                       resultNode.child_category = nodeContent;
               } else if (nodeName=='lastmodified') {
                       try {
                           resultNode.lastmodified = DateTime.valueOfGmt(String.valueof(nodeContent).substring(0,10)+' 00:00:00 AM').format('MMMMM d, yyyy');
                       } catch (Exception ex) {
                           resultNode.lastmodified = '';
                       }
               } else if (nodeName=='body') { // This will execute only for commprofiles
                       //resultNode.body = nodeContent;
                       AdditionalCommunityProfileInfo addCommProfInfo = new AdditionalCommunityProfileInfo();
                       List<String> addCommProfInfoList = nodeContent.split('__##__');
                       addCommProfInfo.aboutMe                   = addCommProfInfoList.size()>0?addCommProfInfoList[0].trim():'';
                       addCommProfInfo.company                   = addCommProfInfoList.size()>1?addCommProfInfoList[1].trim():'';
                       addCommProfInfo.whatIWantToLearnMoreAbout = addCommProfInfoList.size()>2?addCommProfInfoList[2].trim():'';
                       addCommProfInfo.expertiseInMarketo        = addCommProfInfoList.size()>3?addCommProfInfoList[3].trim():'';
                       addCommProfInfo.country                   = addCommProfInfoList.size()>4?addCommProfInfoList[4].trim():'';
                       addCommProfInfo.state                     = addCommProfInfoList.size()>5?addCommProfInfoList[5].trim():'';
                       addCommProfInfo.city                      = addCommProfInfoList.size()>6?addCommProfInfoList[6].trim():'';
                       addCommProfInfo.whoIMarketTo              = addCommProfInfoList.size()>7?addCommProfInfoList[7].trim():'';
                       addCommProfInfo.memberOfUserGroup         = addCommProfInfoList.size()>8?addCommProfInfoList[8].trim():'';
                       addCommProfInfo.crm                       = addCommProfInfoList.size()>9?addCommProfInfoList[9].trim():'';
                       resultNode.additionalCommProf             = addCommProfInfo;                     
               }
               System.debug('__NodeAdded__'+resultNode);
            }
            
            results.put(resultNode.sfdc_id, resultNode); 
            sortedIDs.add(resultNode.sfdc_id);
        }
         /* BUILT IN HIGHLIGHTING STOPPED DUE TO HTML BREAK ISSUE WITH DATA
        // Add highlighting
        List<xmldom.element> xmlTopLSTNodes    = xmlResult.getElementsByTagName('lst');
        List<xmldom.element> highlightingNodes = new List<xmldom.element>(); 
        for (xmldom.element tempLSTNode:xmlTopLSTNodes) {
            System.debug('_LST_NODES_'+tempLSTNode.getAttribute('name'));
            if (tempLSTNode.getAttribute('name') == 'highlighting') {
                highlightingNodes = tempLSTNode.getElementsBytagName('lst');
                break;
            }
        }
        
        for (xmldom.element hltNode:highlightingNodes) {
            List<xmldom.element> hltSubNodes = new List<xmldom.element>();
            String sfdcIDOfHighlightingElem  = hltNode.getAttribute('name');
            hltSubNodes                      = hltNode.getElementsByTagName('arr'); 
            System.debug('_HLT_NODE_ID_'+sfdcIDOfHighlightingElem);
            for (xmldom.element hltSubNode:hltSubNodes) {
                String nameOfSubNode = hltSubNode.getAttribute('name');
                System.Debug('_HLT_NODE_NAME_'+nameOfSubNode);
                if (results.containsKey(sfdcIDOfHighlightingElem)) {
                    if (nameOfSubNode == 'title') {
                        results.get(sfdcIDOfHighlightingElem).title   = hltSubNode.getElementsByTagName('str').get(0).textContent();
                    } else if (nameOfSubNode == 'summary') {
                        String nodeContent = hltSubNode.getElementsByTagName('str').get(0).textContent();
                        results.get(sfdcIDOfHighlightingElem).summary = nodeContent;//GlobalFunctions.getShortBody(nodeContent);
                    }
                }
            }
        }
         */
        List<resultElement> sortedResults = new List<resultElement>();
        for (Id tempId:sortedIDs){
            sortedResults.add(results.get(tempId));
        }
        // Make additional data for Ideas/Answers
        String top_category = (ApexPages.currentPage().getParameters().get('top_category') != null)?ApexPages.currentPage().getParameters().get('top_category'):'';
 
        if (top_category.containsIgnoreCase('Discussion')) {
            qsnsAdditionalInfo = new Map<Id, Question>([Select id, bestreplyid from Question where id in:sortedIDs]);
            for(Id tmpId : sortedIDs) {
                if(!qsnsAdditionalInfo.containsKey(tmpId)) {
                    qsnsAdditionalInfo.put(tmpId, new Question());
                }
            }
        }
        if (top_category.containsIgnoreCase('Idea')) {
            hasvoteMap = new map<id,boolean>();
            ideasAdditionalInfo = new Map<Id, Idea>([Select id, status,ParentIdeaId, CreatedById, VoteTotal, (Select Id,  CreatedById From Votes) from Idea where id in:sortedIDs]);
            for(Id tmpId : sortedIDs) {
                if(!ideasAdditionalInfo.containsKey(tmpId)) {
                    ideasAdditionalInfo.put(tmpId, new Idea());
                    hasvoteMap.put(tmpId, false);
                }
            }
            for(idea temp :ideasAdditionalInfo.values()){
                if(temp.votes.size() > 0){
                    for(vote v: temp.votes){
                        if(string.valueof(v.CreatedById) == UserInfo.getUserId()){
                            hasvoteMap.put(temp.id, false);
                            break;
                        }else{
                             hasvoteMap.put(temp.id, true);
                        }
                    }    
                } else {
                   hasvoteMap.put(temp.id, true);  
                }
            }   
        }  
        return sortedResults;    
    }
    
    public class resultElement {
        public String title                {get;set;}
        public String summary              {get;set;}
        public String body                 {get;set;}
        public String sfdc_id              {get;set;}
        public String top_category         {get;set;}
        public String child_category       {get;set;}
        public String lastmodified         {get;set;}
        public List<String> dataCategories {get;set;}
        
        public AdditionalCommunityProfileInfo additionalCommProf {get;set;}
    
    }
    
    public class AdditionalCommunityProfileInfo{
        public String aboutMe                   {get;set;}
        public String company                   {get;set;}
        public String whatIWantToLearnMoreAbout {get;Set;}
        public String expertiseInMarketo        {get;set;}
        public String country                   {get;set;}
        public String state                     {get;set;}
        public String city                      {get;set;}
        public String whoIMarketTo              {get;set;}
        public String crm                       {get;set;}
        public String memberOfUserGroup         {get;set;}

    }
    
    public List<Integer> createPaginationList (Integer totalResults, Integer curPageNo, Integer pagesize) {
        try {
            List<Integer> paginationList = new List<Integer>(); 
            Double totalNumOfPages       = math.ceil(Double.valueof(totalResults)/Double.valueof(pagesize));
            System.Debug('totalNumOfPages++++'+totalNumOfPages);
            System.Debug('curPageNo+++'+curPageNo);
            Integer index;
            If(curPageNo < 4 ){
                System.Debug('++++Less than 4');
                for (index=curPageNo-3;index<curPageNo;index+=1) {//Enter Here for first 3 pages
                    if(index<0) {
                        continue;  
                    }
                    paginationList.add(index);
                }
                paginationList.add(curPageNo);
                Integer jindex;      
                for (jindex=curPageNo+1;jindex<=6;jindex+=1) {
                    If(jindex >= totalNumOfPages){
                        break;
                    }
                    paginationList.add(jindex);
                }
            }else If(curPageNo >= 4 && curPageNo < totalNumOfPages-3){//Enter here for Pages In Between
                for (index=curPageNo-3;index<curPageNo;index+=1) {
                    if(index<=0) {
                        continue;  
                    }
                    paginationList.add(index);
                }
                paginationList.add(curPageNo);
                Integer jindex;      
                for (jindex=curPageNo+1;jindex<=curPageNo+3;jindex+=1) {
                    if(jindex > totalResults/pageSize){
                        break;
                    }
                    paginationList.add(jindex);
                }
            }
            else {//Enter Here for last 3 pages
                System.Debug('Entered here for last three numbers'+curPageNo);
                Integer tempNum;//Number of digits before last three digits to keep the list count(7) for last three digits
                System.Debug(''+totalNumOfPages);
                If(curPageNo == totalNumOfPages-3){tempNum = 4;}
                If(curPageNo == totalNumOfPages-2){tempNum = 5;}
                If(curPageNo == totalNumOfPages-1){tempNum = 6;}
                If(curPageNo == totalNumOfPages)  {tempNum = 7;}
                for (index=curPageNo-tempNum;index<curPageNo;index+=1) {
                    if(index<=0) {
                        continue;  
                    }
                    paginationList.add(index);
                }
                paginationList.add(curPageNo);
                Integer jindex;      
                for (jindex=curPageNo+1;jindex<=totalNumOfPages+2;jindex+=1) {
                    if(jindex >= totalNumOfPages){
                        break;
                    }
                    paginationList.add(jindex);
                }
            }
            System.Debug('++paginationList++'+paginationList);
            return paginationList;
        }
        catch(Exception ex){
            System.Debug('Exception'+ex);
            list<Integer> defaultList = new list<Integer> {1,2,3,4,5,6,7};
            return defaultList; 
        }
    }    

    
    public static testMethod void myUnitTest() {
      PageReference pg = Page.SolrSearchPage; 
      pg.getParameters().put('page', '0');
      pg.getParameters().put('searchText', 'marketo');
      pg.getParameters().put('sortby', '');
      pg.getParameters().put('top_category', 'Article,Tutorial,Video,IssueSolution');
      pg.getParameters().put('get_results', 'true');
      pg.getParameters().put('dcategory', '');
      
      Test.setCurrentPage(pg);
      
      SolrMarketoSearchController c = new SolrMarketoSearchController();  
      c.initialize();  
      
      PageReference pg1 = Page.SolrSearchPage; 
      pg1.getParameters().put('page', '0');
      pg1.getParameters().put('searchText', 'marketo');
      pg1.getParameters().put('sortby', '');
      pg1.getParameters().put('top_category', 'all');
      pg1.getParameters().put('get_results', 'true');
      pg1.getParameters().put('dcategory', '');
      
      Test.setCurrentPage(pg1);
      SolrMarketoSearchController c1 = new SolrMarketoSearchController();  
      c1.initialize();  
      c1.createPaginationList(30,3,10);
      c1.createPaginationList(30,5,10);
      c1.createPaginationList(30,15,10);      
    }    
}