/*
Name: ArticleSearchController
Created Date: 06/05/2012
Usage: To search articles and relate them to a case.
*/
public class ArticleSearchController {
    
    public Integer currResourcePgNum{get; set;}
    public String caseId {get; set;}
    public String searchText {get; set;}
    public String selectedLang {get; set;}
    public List<ArticleWrap> articleList {get; set;}
    public Case caseRecord;
    public Integer pageNum{get;set;}
    public List<resultElement> results{get;set;}
    public string attachedArticles{get;set;}
    public String solrServerURL = System.label.solrapiurl;
    public XMLDom xmlResult;
    public Integer numberOfResults{get;set;}
    public List<Integer> paginationList{get;set;}
    public Integer currentPage{get; set;}
    public Static Integer MAX_PAGE_SIZE = 10;
    public Integer currResourcePageNum{get;set;}
    
    public articleSearchController(ApexPages.StandardController controller) {
        currResourcePageNum = 1;
        caseRecord = (Case)controller.getRecord();
        currentPage = ApexPages.currentPage().getParameters().get('page')!=null?integer.valueof(ApexPages.currentPage().getParameters().get('page')):0;
        if (searchText == null) {
            searchText = ApexPages.currentPage().getParameters().get('searchText') != null?ApexPages.currentPage().getParameters().get('searchText'):null;
        }
        searchKnowledgeRecords();
    }
    public void resourceArticleNext() {
      currResourcePageNum = currResourcePageNum + 1;
    }
    public void resourceArticlePrev() {
        currResourcePageNum = currResourcePageNum - 1;
    }
    
    public PageReference searchKnowledgeRecords() {
        currResourcePageNum = 1;
        Integer caseCount = [select COUNT() from Case where id = :caseRecord.Id];
        
        if(caseCount > 0) {
            caseRecord = [select Subject from Case where id = :caseRecord.id];
            
            if(searchText == null && caseRecord.Subject != null)
                searchText = caseRecord.Subject;
            if(searchText == null && caseRecord.Subject == null)
                searchText = '';
        }
        
        /* fetch the results from SOlr API */
        // Get the top_categories to be fetched
        List <String> top_categories  = new List<string>{'Article','Tutorial'};
        String sortByQueryString = '';
        String dCategoryFq       = '';
        //System.debug('top_category_string--->    '+top_category);
        //if(top_category != '') {top_categories = top_category.split(',');}
                
        //create top_categories query
        String top_category_query = '&fq='; //fq=type:knowledgeBase
        System.debug('top_CATEGORIRES_'+top_categories.size());
        if (top_categories.size() > 0) {
            for (String top_category_temp :top_categories) {
             top_category_query += 'top_category:'+top_category_temp+'+';  
            }
        }            
        //currentPage = ApexPages.currentPage().getParameters().get('page')!=null?integer.valueof(ApexPages.currentPage().getParameters().get('page')):0;
        String SolrApiUrl = solrServerURL+'/select?userType='+userinfo.getUserType()+'&userId='+userinfo.getUserId()+'&fl=lastmodified,sfdcid,summary,title,top_category&indent=on&version=2.2&facet=on&facet.field=top_category&start='+(currentPage*10)+'&';
        
        String encodedURL = SolrApiUrl  + 'defType=dismax&pf=keywords^500.0&qf=keywords+title^8.0+summary^6.0+body^4.0&q='+EncodingUtil.urlEncode(searchText, 'UTF-8')+''+sortByQueryString+top_category_query+dCategoryFq;
        //String encodedURL = SolrApiUrl  + 'defType=dismax&qf=keywords^10.0+title^8.0+summary^6.0+body^4.0&q='+EncodingUtil.urlEncode(searchText, 'UTF-8')+''+sortByQueryString+top_category_query+dCategoryFq;

        HTTPResponse response = makeAPIRequest(encodedURL);
        if (response == null) {
            return new PageReference('/apex/AdvanceMarketoSearchResults?searchText='+searchText+'&searchType=');
        }            
        categorySpecificResults(response);
        /*Fetch the results from Solr API*/        

        createWrapper();
        return null;
    }
    
    public void createWrapper() {
        articleList = new List<ArticleWrap>();
        
        List<CaseArticle> caList = [select CaseId, KnowledgeArticleId from CaseArticle where
                                        CaseId = :caseRecord.id];
        Set<Id> kaId = new Set<Id>(); 
        attachedArticles = '__';                           
        for(CaseArticle ca :caList) {
            kaId.add(ca.KnowledgeArticleId);
            attachedArticles += ca.KnowledgeArticleId+'__';
        }
        System.Debug('attachedArticles+++++'+attachedArticles);
        for(KnowledgeArticleVersion kav :knowledgeRecords(searchText)) {
            if(kaId != null && kaId.contains(kav.KnowledgeArticleId)) {
                articleList.add(new ArticleWrap(kav, false));
            } else {
                articleList.add(new ArticleWrap(kav, true));
            }
        }
    }
    
    public void attachArticles() {
        System.Debug('IN ATTCHED ARTICLES');
        String articleId = ApexPages.currentPage().getParameters().get('articleId');
        try {
            if(articleId != null && caseRecord.id != null) {
                CaseArticle caRecord = new CaseArticle (
                    KnowledgeArticleId = articleId,
                    CaseId = caseRecord.id
                );
                System.Debug('Hello '+caseId+' '+articleId);
                insert caRecord;
                createWrapper();
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
        }
        //return new PageReference('/' + caseId);
    }
    
    public void deAttachArticles() {
        String articleId = ApexPages.currentPage().getParameters().get('articleId');
        try {
            List<CaseArticle> caList = [select CaseId, KnowledgeArticleId from CaseArticle where
                                        CaseId = :caseRecord.id and
                                        KnowledgeArticleId = :articleId];
            if(caList != null && caList.size() > 0) {
                delete caList;
                createWrapper();
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
        }
        //return new PageReference('/' + caseId);
    }
    
    public List<KnowledgeArticleVersion> knowledgeRecords(String searchText) {
         List<KnowledgeArticleVersion> records = new List<KnowledgeArticleVersion>();
         
         if (searchText != null && searchText.trim().length() > 0) {
             
             String strTxt = '%' + searchText + '%';
             String publishStatus = 'Online';
             System.debug('-----selectedLang --------' + selectedLang );
             String query = 'Select k.UrlName, k.Title, k.PublishStatus, k.KnowledgeArticleId, k.Summary, language' +
                       ' From KnowledgeArticleVersion k WHERE PublishStatus = :publishStatus '+
                       ' AND language = \'en_US\' and Title like :strTxt';
                      
             records = Database.query(query);
             System.debug('------------' + records);
         }  
         return records;     
    }
    
    public List<SelectOption> getLanguageList() {      
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult language = User.LanguageLocaleKey.getDescribe(); 
        List<Schema.PicklistEntry> lang = language.getPicklistValues();
        for(Schema.PicklistEntry l :lang){
            options.add(new SelectOption(l.getValue(), l.getlabel()));
        }
        return options;
    } 
    
    public Map<String, String> languageStaticMap(){
        Map<String, String> langMap = new Map<String, String>();
        langMap.put('English (UK)', 'en_US');
        langMap.put('German', 'de');
        langMap.put('French', 'fr');
        langMap.put('Spanish', 'es');
        langMap.put('Italian', 'it');
        return langMap;
    }
    
    public class ArticleWrap {
    
        public KnowledgeArticleVersion kav {get; set;}
        public Boolean isAttach {get; set;}
        
        public articleWrap(KnowledgeArticleVersion kav, Boolean isAttach) {
            this.kav = kav;
            this.isAttach = isAttach;
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
            System.Debug('REQUEST'+req);
            if (response.getStatus() == 'OK') {
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

    public void categorySpecificResults(HTTPResponse res) {
        System.Debug('CAT SPECIFIC RESULTS');
        results = new List<resultElement>();
        string solr_results = res.getBody();
        //System.debug('LWE_results '+solr_results );
        xmlResult = new XMLDom(solr_results );
        //System.debug('dom-->'+xmlResult );
        xmldom.element xmlResultNode = xmlResult.getElementByTagName('result');
        //System.Debug('NODES'+xmlResultNode);
        numberOfResults            = integer.ValueOf(xmlResultNode.getAttribute('numFound'));
        Integer paginationStart    = integer.ValueOf(xmlResultNode.getAttribute('start'));
        paginationList = createPagination(paginationStart, numberOfResults, MAX_PAGE_SIZE, currentPage);

        //System.debug('numberOfResults -->'+numberOfResults );
        List<xmldom.element> docNodesList = xmlResultNode.getElementsByTagName('doc');
        //Integer count=0;
        System.Debug('DOC LIST SIZE'+docNodesList.size());
        results = parseSolrDom(docNodesList);
        System.debug('SOLR Results'+results);
        System.debug('Results-->'+results);
    }
    
    public List<resultElement> parseSolrDom(List<xmldom.element> docNodesList) {
        results = new List<resultElement>();
        for (xmldom.element docNode:docNodesList) {
            //System.debug('__DOC__'+docNode);
            List<xmldom.element> subNodesList = docNode.getElementsByTagName('str');
            resultElement resultNode = new resultElement();
            for(xmldom.element subNode:subNodesList) {
               String nodeName    = subNode.getAttribute('name'); 
               String nodeContent = subNode.textContent();
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
                   resultNode.lastmodified = DateTime.valueOfGmt(String.valueof(nodeContent).substring(0,10)+' 00:00:00 AM').format('MMMMM d, yyyy');
               }
               //System.debug('NodeAdded'+nodeName);
            }
            results.add(resultNode); 
        }
        return results;    
    }
    
    public class resultElement {
        public String title   {get; set;}
        public String summary {get; set;}
        public String sfdc_id {get; set;}
        public String top_category   {get; set;}
        public String child_category {get;set;}
        public String lastmodified {get;set;}
        public List<String> dataCategories{get;set;}
    }
    
    public Integer getLastPageNumber(){
        system.debug('numberOfResults, MAX_PAGE_SIZE=>' + numberOfResults + ' ' + MAX_PAGE_SIZE);
        if (math.mod(numberOfResults, MAX_PAGE_SIZE) == 0) {
            return (numberOfResults/MAX_PAGE_SIZE)-1;
        } else {
            return numberOfResults/MAX_PAGE_SIZE;
        }
        //Decimal lastPageNumber = Decimal.valueOf(numberOfResults)/Decimal.valueOf(MAX_PAGE_SIZE));
    }
    
    public List<Integer> createPagination (Integer start, Integer totalResults, Integer pagesize, Integer curPageNo) {
       List<Integer> paginationList = new List<Integer>(); 

       Integer index;
       for (index=curPageNo-3;index<curPageNo;index+=1) {
           if(index<0) {
               continue;
           }
           paginationList.add(index);
       }
       paginationList.add(currentPage);
       Integer jindex; 
       for (jindex=curPageNo+1;jindex<=curPageNo+3;jindex+=1) {
           Double maxjIndex = Decimal.valueOf(totalResults)/Decimal.valueOf(pageSize);  
           System.Debug('NUMBERS'+Decimal.valueOf(jindex)+' '+Decimal.ValueOf(maxjIndex));
           if(Decimal.valueOf(jindex) >= Decimal.ValueOf(maxjIndex)){
               break;
           }
           paginationList.add(jindex);
           System.debug('totalResults/pageSize'+maxjIndex);
           
       }
          
       return paginationList;  
    }

     
}