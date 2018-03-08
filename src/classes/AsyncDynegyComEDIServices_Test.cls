/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
global class AsyncDynegyComEDIServices_Test {

    static testMethod void myUnitTest() {

        Test.startTest();
        Test.setMock(WebServiceMock.class, new TestESGMockImpl());
        System.Continuation con = new System.Continuation(2345);

        AsyncDynegyComEDIServices.AsyncBasicHttpBinding_ISforceESG obj = new AsyncDynegyComEDIServices.AsyncBasicHttpBinding_ISforceESG();
        obj.beginSubmit_ESG_GAA_Request(con,null);
        
        AsyncDynegyComEDIServices.Submit_ESG_GAA_RequestResponse_elementFuture obj2 = new AsyncDynegyComEDIServices.Submit_ESG_GAA_RequestResponse_elementFuture();
       // obj2.getvalue();
         
        Test.stopTest(); 
        
    }
    
    global class TestESGMockImpl implements WebServiceMock {
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
          dynegyComEDIServices.TestHandshakeResponse_element respElement = new dynegyComEDIServices.TestHandshakeResponse_element();
        respElement.TestHandshakeResult = 'test';
           response.put('response_x', respElement); 
       }
    }
}