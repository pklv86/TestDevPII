/* 
 * Name: RequestPricingInfoTest
 * Type: Apex Class
 * Test Class: RequestPricingInfo
 * Description:  Test class for code coverage of RequestPricingInfo. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        Sneha Gadde        03/20/2016       1. Initial Version created
 */
 
 @isTest
public class RequestPricingInfoTest {

    private static testmethod void requestPricingInfo_UnitTest()
    {
        Test.startTest();  
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c='Dynegy';
        insert acc;
       Opportunity opp = new Opportunity();
       opp.name = 'Test Opp';
       opp.StageName = 'New';
       opp.CloseDate = date.today().addDays(5);
       opp.Accountid = acc.id;
       opp.RecordTypeId = rec.id;
       insert opp;
       
       Retail_Quote__c rq = new Retail_Quote__c();
       rq.Opportunity__c = opp.id;
       rq.Energy__c = 5.8;   
       rq.Request_Status__c = ConstantUtility.STATUS_PRICING_COMPLETE;
       rq.RecordTypeId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_INDICATIVE); 
       rq.Utility_Settlement_Zone__c = 'Test Utility';
       insert rq;
     
       RequestPricingInfo.requestPriceStatus(opp.id);
       Map<id,Retail_Quote__c> rqMap = new Map<id,Retail_Quote__c>([select id,name from Retail_Quote__c]);
       RequestPricingInfo.sendQuotesForPricing(rqMap.keySet(),opp.id);
        
      Test.stopTest();
    }
     private static testmethod void requestPricingInfoTest1()
    {
        Test.startTest();  
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c='Dynegy';
        insert acc;
       Opportunity opp = new Opportunity();
       opp.name = 'Test Opp';
       opp.StageName = 'New';
       opp.CloseDate = date.today().addDays(5);
       opp.Accountid = acc.id;
       opp.RecordTypeId = rec.id;
       insert opp;
       
       Retail_Quote__c rq = new Retail_Quote__c();
       rq.Opportunity__c = opp.id;
       rq.Energy__c = 5.8;   
       rq.Request_Status__c = ConstantUtility.STATUS_PRICING_COMPLETE;
       rq.RecordTypeId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_EXECUTABLE); 
       rq.Utility_Settlement_Zone__c = 'Test Utility';
       insert rq;
     
       RequestPricingInfo.requestPriceStatus(opp.id);
       rq.RecordTypeId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_INDICATIVE);
       rq.Request_Status__c = null;
       update rq;
       RequestPricingInfo.requestPriceStatus(opp.id);
       rq.Request_Status__c = ConstantUtility.STATUS_EXPIRED;
       update rq;
       RequestPricingInfo.requestPriceStatus(opp.id);
        
      Test.stopTest();
    }
     private static testmethod void requestPricingInfoTest2()
    {
        Test.startTest();  
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        Account acc = new Account();
        acc.name = 'Test Acc';
        acc.Billing_Entity__c='Dynegy';
        insert acc;
       Opportunity opp = new Opportunity();
       opp.name = 'Test Opp';
       opp.StageName = 'New';
       opp.CloseDate = date.today().addDays(5);
       opp.Accountid = acc.id;
       opp.RecordTypeId = rec.id;
       opp.Refresh_Expiration_Date__c = date.today().addDays(-3);
       insert opp;
       
       Retail_Quote__c rq = new Retail_Quote__c();
       rq.Opportunity__c = opp.id;
       rq.Energy__c = 5.8;   
       rq.Request_Status__c = ConstantUtility.STATUS_PRICING_COMPLETE;
       rq.RecordTypeId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_INDICATIVE); 
       rq.Utility_Settlement_Zone__c = 'Test Utility';
      
       insert rq;
     
       RequestPricingInfo.requestPriceStatus(opp.id);
      
        
      Test.stopTest();
    }
}