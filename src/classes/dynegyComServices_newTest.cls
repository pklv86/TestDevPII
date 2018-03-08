/* 
 * Name: dynegyComServices_newTest
 * Type: Test Class
 * Apex Class: dynegyComServices_new
 * Description:  This is test class for code coverage of dynegyComServices_new. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/16/2016       1. Initial Version created
 */

@isTest(SeeAllData=false)
global class dynegyComServices_newTest {

  private static testmethod void dynegyComServices_UnitTest()
  {
      Test.startTest();
       Test.setMock(WebServiceMock.class, new DynegyComServicesMockImpl());
       RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        Account acc = new Account();
         acc.name = 'Test Acc';
         //insert acc;
       Opportunity opp = new Opportunity();
         opp.name = 'Test Opp';
         opp.StageName = 'New';
         opp.CloseDate = date.today().addDays(5);
         opp.Accountid = acc.id;
         opp.RecordTypeId = rec.id;
         //insert opp;
       
       Retail_Quote__c rq = new Retail_Quote__c();
         rq.Opportunity__c = opp.id;
         rq.Energy__c = 5.8;   
         rq.RecordTypeId = ConstantUtility.getRecordTypeIdbyName('Retail_Quote__c','Indicative');
         //insert rq;
       
       LDC_Account__c lacc = new LDC_Account__c();
         lacc.name  ='Test LDC acc';
         lacc.LDC_Account_Number__c = '1234';
         lacc.Account__c = acc.id;
        // insert lacc;
      Opportunity_LDC__c oppLdc = new Opportunity_LDC__c();
     //  oppLdc.name = 'Test LDC Acc';
         oppLdc.LDC_Account__c = lacc.id;   
         oppLdc.Opportunity__c = opp.id;
        // insert oppLdc;
      invokeserviceTest(opp.id,rq.id,oppLdc.id);
     
      Test.stopTest();
   }
  @future(callout=true)  
  public static void invokeserviceTest(id oppid,id qtid,id ladaccId)
  {
  	
    dynegyComServices_new.SforceOpportunity opp1 = new dynegyComServices_new.SforceOpportunity();
      opp1.OfferType = 'test';
      opp1.OpportunityID = oppid;
    dynegyComServices_new.SforceQuote qt = new dynegyComServices_new.SforceQuote();
      qt.QuoteID = qtid;
      List<dynegyComServices_new.SforceQuote> qlst = new List<dynegyComServices_new.SforceQuote>();
      qlst.add(qt);
    dynegyComServices_new.ArrayOfSforceQuote qtLst = new dynegyComServices_new.ArrayOfSforceQuote();
      qtLst.SforceQuote = qlst;
    dynegyComServices_new.SforceAccount ldcAcc1 = new dynegyComServices_new.SforceAccount();
      ldcAcc1.SforceLdcId = ladaccId;
      //ldcAcc1.LDCAccountNumber = lacc.Account__c;
      List<dynegyComServices_new.SforceAccount> adcAccLst1 = new List<dynegyComServices_new.SforceAccount>();
      adcAccLst1.add(ldcAcc1);
    dynegyComServices_new.ArrayOfSforceAccount ldcAccLst = new dynegyComServices_new.ArrayOfSforceAccount();
      ldcAccLst.SforceAccount = adcAccLst1;
    dynegyComServices_new.SforcePricingRequest req = new dynegyComServices_new.SforcePricingRequest();
      req.Opportunity = opp1;
      req.Quotes = qtLst;
      req.LDCAccounts = ldcAccLst;
    dynegyComServices_new.RequestPricing_element reqPE = new dynegyComServices_new.RequestPricing_element();
      reqPE.request = req;
    dynegyComServices_new.RequestPricingResponse_element reqPRE = new dynegyComServices_new.RequestPricingResponse_element();  
    
    dynegyComServices_new.BasicHttpBinding_IRetailWS reqWS = new dynegyComServices_new.BasicHttpBinding_IRetailWS();
      //reqWS.TestHandshake(1);
      reqWS.RequestPricing(req);
   }
 private static testmethod void dynegyComServicesTest1()
 {
   Test.startTest();
    Test.setMock(WebServiceMock.class, new TestHandshakeMockImpl());
    RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
    dynegyComServices_new.BasicHttpBinding_IRetailWS reqWS = new dynegyComServices_new.BasicHttpBinding_IRetailWS();
      reqWS.TestHandshake(1);
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
global class DynegyComServicesMockImpl implements WebServiceMock {
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
    dynegyComServices_new.RequestPricingResponse_element respElement = new dynegyComServices_new.RequestPricingResponse_element();
    respElement.RequestPricingResult = 'test';
    response.put('response_x', respElement); 
   }
 }
     
}