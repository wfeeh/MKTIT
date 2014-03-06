/*
   Created Date: 4/23/2013
   Purpose: Accept a list of Opportunity IDs and update the Latest Payment Date from Sales Invoice object
*/
public class UpdOppFromSalesInv {
   public static boolean OSIFirstPass = False;
   public static void updateLatestPaymentDate(List<Id> OppIds)
   {
      map <Id, Date> OppLPmtDtMap = new map <Id, Date>();
      List<Sales_Invoice__c> siList = [select Opportunity__c, Last_Payment_Date__c from Sales_Invoice__c 
           where Opportunity__c in :OppIds and Document_Type__c <> 'Revenue Recognition Activation'
           order by Opportunity__c, Last_Payment_Date__c];
      for (Sales_Invoice__c si : siList){
         if (OppLPmtDtMap.get(si.Opportunity__c) == null || OppLPmtDtMap.get(si.Opportunity__c) < si.Last_Payment_Date__c) {
            OppLPmtDtMap.put(si.Opportunity__c, si.Last_Payment_Date__c);
         }
      }

      List<Opportunity> oppList = [select id, Latest_Payment_Date__c from Opportunity where ID in :OppIds];
      for (Opportunity opp : oppList){
      opp.frm_payment__c=true;
         if (OppLPmtDtMap.get(opp.id) <> null){
            
            opp.Latest_Payment_Date__c = OppLPmtDtMap.get(opp.id);
         }
      }
      update oppList;
   }
   }