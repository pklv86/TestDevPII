/* 
 * Name: AsyncDynegyComServices_newTest
 * Type: Test Class
 * Apex Class: AsyncDynegyComServices_new
 * Description: Test class for code coverage of AsyncDynegyComServices_new. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/16/2016       1. Initial Version created
 */

@isTest(SeeAllData=false)
global class AsyncDynegyComServices_newTest {
 private static testmethod void asyncDynegyComServicesnew_UnitTest() 
 {
    Test.startTest();
     Test.setMock(WebServiceMock.class, new TestHandshakeMockImpl());
     System.Continuation con = new System.Continuation(2345);
     AsyncDynegyComServices_new.TestHandshakeResponse_elementFuture obj = new AsyncDynegyComServices_new.TestHandshakeResponse_elementFuture();
    // obj.getValue();
     AsyncDynegyComServices_new.RequestPricingResponse_elementFuture obj1 = new AsyncDynegyComServices_new.RequestPricingResponse_elementFuture();
    // obj1.getValue();
     AsyncDynegyComServices_new.AsyncBasicHttpBinding_IRetailWS obj2 = new AsyncDynegyComServices_new.AsyncBasicHttpBinding_IRetailWS();
     obj2.beginTestHandshake(con,2);
     obj2.beginRequestPricing(con,null);
     
    Test.stopTest(); 
 }
  global class TestHandshakeMockImpl implements WebServiceMock {
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
      dynegyComServices_new.TestHandshakeResponse_element respElement = new dynegyComServices_new.TestHandshakeResponse_element();
    respElement.TestHandshakeResult = 'test';
       response.put('response_x', respElement); 
   }
 }
    
}