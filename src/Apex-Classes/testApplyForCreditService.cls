@isTest(SeeAllData=true)

private class testApplyForCreditService {
    
   @istest  static void testWsApplyforCredit() {              
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new YourWebServiceMockImpl ());
        string aid='0015000000Fduuv';
        string oppid='0065000000KIQnL';
        // Call the method that invokes a callout
               User u = [select Name,ID from user where id = :Userinfo.getUserId()];
    
         System.runAs(u){
            
        
         ApplyForCreditService.ApplyForCredit(aid,oppid);
         
                }
    
  
        
        // Verify that a fake result is returned
        //System.assertEquals('Mock response', output); 
    }
}