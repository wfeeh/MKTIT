public class CaseUtils {

    @future(callout = true) 
    public static void sendCaseNotificationWithArticleList(List<Id>  idOfCasesCreatedViaEmail) {
         
        Map<Id,Case> caseParsedMap = new Map<Id,Case>([Select Id, ContactId, Subject, Origin, Thread_Id__c, CaseNumber, Contact.Name, Contact.Email from Case where Origin = 'Email' AND id IN : idOfCasesCreatedViaEmail]);
        List<Case_Related_Article_List__c> artList = new List<Case_Related_Article_List__c>();
        
        String baseURL = 'http://community.marketo.com/';
        for ( Case caseParser : caseParsedMap.values() ) {
            List<resultElement> helpArticleList = new List<resultElement>();
            Case_Related_Article_List__c ArticleToBeAdded = new Case_Related_Article_List__c();
            helpArticleList = SolrImplementationForRelevantArticles.getRelevantLinksFromSolr(caseParser.Subject); 
            System.Debug('___RESULTS___'+helpArticleList);
            
            ArticleToBeAdded.Case__c = caseParser.Id;
            ArticleToBeAdded.Contact_Email__c = caseParser.Contact.Email;  
                         
            Integer Count = 1;
            for( resultElement helpArticleParser : helpArticleList) {
                String helpArticleLink = '';
                if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA0')) {
                    helpArticleLink = baseURL + 'marketoArticle?id=' + helpArticleParser.Id;
                } 
                else if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA2')) { 
                    helpArticleLink = baseURL + 'marketoTutorial?id=' + helpArticleParser.Id;
                }
                else if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA3')) {
                    helpArticleLink = baseURL + 'marketoissueSolution?id=' + helpArticleParser.Id;
                }
                else if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA4')) { 
                    helpArticleLink = baseURL + 'marketoVideoLibrary?id=' + helpArticleParser.id + '&title=' + helpArticleParser.title;
                }
                else if(String.valueof(helpArticleParser.Id).startsWithIgnoreCase('kA5')) { 
                    helpArticleLink = baseURL + 'marketoDeepDive?id=' + helpArticleParser.id + '&title=' + helpArticleParser.title;                    
                }
                                
                if(helpArticleLink != '') {                      
                    if(Count == 1){                    
                        ArticleToBeAdded.Article_Title1__c = helpArticleParser.title;
                        ArticleToBeAdded.Article_Link1__c  = helpArticleLink;                        
                    } else if(Count == 2){                    
                        ArticleToBeAdded.Article_Title2__c = helpArticleParser.title;
                        ArticleToBeAdded.Article_Link2__c  = helpArticleLink;                        
                    } else if(Count == 3){                    
                        ArticleToBeAdded.Article_Title3__c = helpArticleParser.title;
                        ArticleToBeAdded.Article_Link3__c  = helpArticleLink;                        
                    } else if(Count == 4){                    
                        ArticleToBeAdded.Article_Title4__c = helpArticleParser.title;
                        ArticleToBeAdded.Article_Link4__c  = helpArticleLink;                        
                    } else if(Count == 5){                    
                        ArticleToBeAdded.Article_Title5__c = helpArticleParser.title;
                        ArticleToBeAdded.Article_Link5__c  = helpArticleLink;                        
                    }
                }
                count++;                                        
            }
            If(ArticleToBeAdded.Case__c != NULL)
                artList.add(ArticleToBeAdded);            
        }
    
        If( artList.size() > 0 )
            insert artList;
    }
}