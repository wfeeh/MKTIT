global class YourWebServiceMockImpl implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {

        // Create response element from the autogenerated class.  
  comDnbiEaiServiceCreditapplication.applyForCreditEnhancedResponse_element  res = new comDnbiEaiServiceCreditapplication.applyForCreditEnhancedResponse_element ();
         comDnbiEaiServiceCreditapplication.matchCompanyResponse_element res1 = new comDnbiEaiServiceCreditapplication.matchCompanyResponse_element ();
         
        
              // Populate response element. 
              res1.out=null;
              
                     res.out=null;
        // Add response element to the response parameter, as follows:      
        
          response.put('response_x', res); 
          response.put('response_x', res1); 
   }
}