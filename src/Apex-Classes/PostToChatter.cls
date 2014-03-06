/*
   Created Date: 3/15/2013
   Purpose: Accept a list of Accounts and for each account, post Sales Bell message to the Chatter Group, All: Marketo
*/
public class PostToChatter {
   public static boolean FirstPass = False;
   public static void PostSalesBellToChatter(List<Account> Accts, List<Id> Uids)
   {
      List <FeedItem> FItem = new List <FeedItem>();
      Map<Id,User> UserMap = new Map<Id, User>([select Id, Name, FirstName from User where Id IN :Uids]);
      for(Account ac : Accts)
      {
         String accURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + ac.id;
         String chTitle = 'COWBELL! ' + ac.Name + ' is a new Marketo Customer!';
         String chBody = '#COWBELL - ' +userMap.get(ac.Ownerid).name+ ' closed another deal. We just won ' + ac.Name + '! ';
         chBody = chBody + ' Congratulations '+userMap.get(ac.Ownerid).firstname+ '! Customer# ' +ac.Customer_Number__c+'.';
         FeedItem post = new FeedItem();
         post.ParentId = '0F950000000GnDL';
         post.Title = chTitle;
         post.Body = chBody;
         post.LinkUrl = accURL;
         post.Type = 'LinkPost';
         FItem.add(post);
      }
      insert FItem;
   }
}