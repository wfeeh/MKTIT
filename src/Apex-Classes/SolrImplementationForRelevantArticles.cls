public class SolrImplementationForRelevantArticles  {
    //Solr Code
    public static XMLDom xmlResult;
    public static List<resultElement> results{get;set;}              
    public static String searchText;                          
    public static String sortBy;                            
    
    public SolrImplementationForRelevantArticles(){
        results = new List<resultElement>();
        results = getRelevantLinksFromSolr('landing page');    
    }
    
    public static String solrServerURL = System.label.solrapiurl;
    public static List<resultElement> getRelevantLinksFromSolr(String caseSubject) {
        searchText = caseSubject;
        String dCategoryFq = '';
        
        if(searchText == '') {searchText='*:*';}
        

        String getResults   = 'true';

        //String sortByQueryString = '';
        //sortByQueryString = '&sort=lastmodified+desc';
        //String sortByForProfiles = '&sort=lastmodified+desc';
        
       
        List <String>all_top_categories      = new List<String>{'&fq=top_category:Article+top_category:Tutorial+top_category:Video+top_category:IssueSolution+top_category:Deepdive'};       
        
        String countSolrApiUrl               = solrServerURL+'/select?userType='+userinfo.getUserType()+'&userId='+userinfo.getUserId()+'&rows=5&spellcheck.onlyMorePopular=true&spellcheck=true&spellcheck.dictionary=freq&spellcheck.extendedResults=true&spellcheck.collate=true&hl.fragsize=50000&hl=true&hl.fl=title,summary&indent=on&version=2.2&facet=on&facet.field=top_category&start=0&';
        
        String encodedURL = '';
        
        for (String top_category_temp:all_top_categories) {
            if (searchText != '*:*') {
                encodedURL = countSolrApiUrl + 'defType=dismax&pf=keywords^500.0&qf=keywords+title^8.0+summary^6.0+body^4.0&q='+EncodingUtil.urlEncode(searchText, 'UTF-8')+''+top_category_temp+dCategoryFq;
            }
        }        
        
        HTTPResponse response = makeAPIRequest(encodedURL);
        
        if (response == null) {
            //add code to fetch article list from knowledge article list using find query if solr fails.
            
            results = new List<resultElement>();
            String searchQuery = 'FIND {'+searchText+'} IN ALL FIELDS RETURNING Article__kav (Id, Title Where PublishStatus=\'online\' AND Language=\'en_US\' Limit 5)';
            List<List<SObject>> searchList = search.query(searchQuery); 
            List<article__kav> articleList = searchList[0];
            for(article__kav tempArticle : articleList){
                results.add(new resultElement(tempArticle.Title,tempArticle.id));        
            }
            System.Debug('results++++++++++++'+results);
            return results;
            //return new PageReference('/apex/AdvanceMarketoSearchResults?searchText='+searchText+'&searchType=');
        }            
        categorySpecificResults(response);
        System.Debug('Solr Search Articles+++++'+results);
        return results;
    }
    
    public Integer parseResultCount(HttpResponse response) {
        xmlResult = new XMLDom(response.getBody());
        xmldom.element xmlResultNode = xmlResult.getElementByTagName('result');
        return integer.ValueOf(xmlResultNode.getAttribute('numFound'));
    }
    
    
    public static void notifySolrDownEvent(){ //__TEMPORARY_FUNCTION_TO_MONITOR_SOLR_DOWN_EVENT__
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
    public static HTTPResponse makeAPIRequest(String encodedURL) {
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
    
    public static void categorySpecificResults(HTTPResponse res) {
        results             = new List<resultElement>();
        string solr_results = res.getBody();
        xmlResult           = new XMLDom(solr_results);
        
        xmldom.element xmlResultNode = xmlResult.getElementByTagName('result');
        results      = parseSolrDom(xmlResult);
    }
    
    public static List<resultElement> parseSolrDom(XMLDom tempXmlResult) {

        xmldom.element xmlResultNode = tempXmlResult.getElementByTagName('result');
        
        List<xmldom.element> docNodesList = xmlResultNode.getElementsByTagName('doc');
        system.debug('docNodesList-->'+docNodesList);
        List<ID> sortedIDs =  new List<Id>();

        Map<String,resultElement> tempResults = new Map<String,resultElement>();
        
        for (xmldom.element docNode:docNodesList) {
            //System.debug('__DOC__'+docNode);
            List<xmldom.element> subNodesList = docNode.getElementsByTagName('str');
            resultElement resultNode          = new resultElement();
            
            for(xmldom.element subNode:subNodesList) {
               String nodeName    = subNode.getAttribute('name'); 
               String nodeContent = subNode.textContent();
               nodeContent  = nodeContent.replace('\\','');
               if(nodeName=='sfdcid') {
                       resultNode.id = nodeContent;
               } else if (nodeName=='title'){ 
                       resultNode.title = nodeContent;
               }
            }
            
            tempResults.put(resultNode.id, resultNode); 
            sortedIDs.add(resultNode.id);
        }

        List<resultElement> sortedResults = new List<resultElement>();
        for (Id tempId:sortedIDs){
            sortedResults.add(tempResults.get(tempId));
        }
        return sortedResults;    
    }
    //Solr Code 
}