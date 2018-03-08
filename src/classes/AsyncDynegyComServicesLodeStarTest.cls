/* 
 * Name: AsyncDynegyComServicesLodeStarTest
 * Type: Test Class
 * Apex Class: AsyncDynegyComServicesLodeStar
 * Description: Test class for code coverage of AsyncDynegyComServicesLodeStarTest. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu        		02/16/2017       1. Initial Version created
 */

@isTest(SeeAllData=false)
global class AsyncDynegyComServicesLodeStarTest {
 private static testmethod void AsyncDynegyComServicesLodeStar_UnitTest() 
 {
    Test.startTest();
     Test.setMock(WebServiceMock.class, new TestHandshakeMockImpl());
     System.Continuation con = new System.Continuation(2345);
     AsyncDynegyComServicesLodeStar.AsyncBasicHttpBinding_ISforceLstar obj = new AsyncDynegyComServicesLodeStar.AsyncBasicHttpBinding_ISforceLstar();
     obj.beginGetLstarErrors(con);
     obj.beginLoadstarInterface(con,null);
     
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