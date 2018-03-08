/* 
 * Name: RetailQuoteHandlerTest
 * Type: Test Class
 * Apex Class: RetailQuoteHandler
 * Description: Test class for code coverage of RetailQuoteHandler. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/14/2016       1. Initial Version created
 */


@isTest(SeeAllData=false)
public class RetailQuoteHandlerTest {

    private static testmethod void RetailQuoteHandler_UnitTest()
    {
      Test.startTest();  
        Opportunity opp = new Opportunity();
       opp.name = 'Test Opp';
       opp.StageName = 'New';
       opp.CloseDate = date.today().addDays(5);
       insert opp;
       
       Retail_Quote__c rq = new Retail_Quote__c();
       rq.Opportunity__c = opp.id;
       rq.Energy__c = 5.8;   
       rq.Utility_Settlement_Zone__c = 'Test Utility';
       insert rq;
       set<id> rtQuoteIdLst = new set<Id>();
       rtQuoteIdLst.add(rq.id);
       List<Retail_Quote__c> rtQuoteLst = new List<Retail_Quote__c>();
       rtQuoteLst.add(rq);
       List<Retail_Quote__c> newRtQuoteLst = RetailQuoteHandler.cloneAndCreateQuoteHistory(rtQuoteLst,rtQuoteIdLst,'Indicative','Indicative');
       system.assertEquals(newRtQuoteLst.size(), 1); 
      Test.stopTest();  
    }
}