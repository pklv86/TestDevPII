@isTest
private class sendPostApprovalMail_Test{
    static Account acc;
    static Opportunity opp;
    static Supplier__c supplier;
    static testmethod void testMethod1() {
   
        DOA_Approval_Mail__c doaApp = new DOA_Approval_Mail__c();
        doaApp.name = 'Email';
        doaApp.Doa_Email__c = 'test@gmail.com';
        doaApp.Doa_Email2__c = 'test@gmail.com';
        doaApp.Doa_Email3__c = 'test@gmail.com';
        doaApp.Doa_Email4__c = 'test@gmail.com';
        doaApp.Doa_Email5__c = 'test@gmail.com';
        doaApp.Doa_Email6__c = 'test@gmail.com';
        insert doaApp;
        
        profile p = [select id from profile limit 1];
        
        User u = new user();
        u.LastName = 'Test User'+system.now();
        u.Email = 'robert.c.flexon2@dynegy.com';
        u.UserName = 'Test321@test.com.test';
        u.Alias = 'Test';
        u.profileId = p.id;
        u.EmailEncodingKey = 'UTF-8';
        u.TimeZoneSidKey = 'America/New_York';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        insert u;
        
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
        opp.DOA_Approved__c = false;
        opp.DOA_Approver__c = u.id;
        insert opp;
        
        Retail_Quote__c rq = new Retail_Quote__c();
        rq.Opportunity__c = opp.id;
        rq.Energy__c = 5.8;   
        rq.Request_Status__c = ConstantUtility.STATUS_PRICING_COMPLETE;
        rq.RecordTypeId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,ConstantUtility.RT_EXECUTABLE);
        rq.Notional_Value__c = 10000007; 
        rq.Utility_Settlement_Zone__c = 'Test Utility';
        insert rq;
        test.startTest();
        opp.DOA_Approved__c = true;
        update opp;
        Test.stopTest();
  }
}