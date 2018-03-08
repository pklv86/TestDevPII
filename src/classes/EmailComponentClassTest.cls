@isTest
private class EmailComponentClassTest{
    static Account acc;
    static Opportunity opp;
    static Supplier__c supplier;
    static testmethod void testMethod1() {        
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        
        supplier = new Supplier__c();
        supplier.NAme ='Test supplier';
        supplier.Master_DUNS__c  ='1223';
        supplier.Supplier_DUNS__c ='999';
        supplier.Active__c = true;
        insert supplier;
        
        acc = new Account();
        acc.name = 'Test Acc';
        acc.Supplier__c = supplier.Id;
        acc.Billing_Entity__c='Dynegy';
        insert acc;
        
        opp = new Opportunity();
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
        rq.Notional_Value__c = 10000007; 
        rq.Utility_Settlement_Zone__c = 'Test Utility';       
        insert rq;
        
     // Test.startTest();
        EmailComponentClass emComp = new EmailComponentClass();
     // Test.stopTest();
    }
}