@isTest
private class insertUpdatePeakLdInfo_Test{
    static Account acc;
    static Opportunity opp;
    static LDC_Account__c lacc;
    static LDC_Account__c lacc1;
    static LDC_Account__c lacc2;
    static Contract ct;
    static Contract ct1;
    static LDC_Vendor__c ldcvendor;
    static Supplier__c supplier;
    static DASR_Request__c dasrReqgaac;
    static DASR_Request__c dasrReqgaac1;
    static Contract_LDC__c contractLDC;
    static Contract_LDC__c contractLDC1;
    static Service_Point__c sp;
    static Meter__c meter;
    static testmethod void testMethod1() {
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        String query = 'Select id, Reason_Code__c, DASR_Request__c, LDC_Account__c, DASR_Request__r.change_Effective_Date__c, DASR_Request__r.Capacity_Obligation__c, DASR_Request__r.Transmission_Obligation_Quantity__c, DASR_Request__r.DASR_Type__c from Account_Exception__c where id in: Trigger.new';
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
        
        lacc = new LDC_Account__c();
        lacc.name  ='Test LDC acc';
        lacc.Account__c = acc.id;
        lacc.enrolled__c = true;
        lacc.LDC_Account_Number__c = '00040621040044404';
        lacc.Enrollment_Status__c = 'Accepted';
        insert lacc;
        
        lacc1 = new LDC_Account__c();
        lacc1.name  ='Test LDC acc1';
        lacc1.Account__c = acc.id;
        lacc1.LDC_Account_Number__c = '00040621040044444';
        lacc1.opt_out__c = true;
        lacc1.enrolled__c = true;
        lacc1.LDC_Account_Status__c = 'Pending_Final';
        insert lacc1;
        
        lacc2 = new LDC_Account__c();
        lacc2.name  ='Test LDC acc2';
        lacc2.Account__c = acc.id;
        lacc2.LDC_Account_Number__c = '00040621044444444';
        lacc2.Enrollment_Status__c = 'Accepted';
        lacc2.enrolled__c = true;
        insert lacc2;
        
        
        ct=new Contract(Name='Test Contract',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM01', Bill_Method__c ='DUAL', Interval_Usage__c ='Summary');
        Insert ct;
        
        ct1=new Contract(Name='Test Contract1',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM02', Bill_Method__c ='RATE READY', Interval_Usage__c ='Summary');
        Insert ct1;
        
        contractLDC = new Contract_LDC__c();
        contractLDC.Contract__c = ct.Id;
        contractLDC.LDC_Account__c = lacc.Id;
        insert contractLDC;
        
        contractLDC1 = new Contract_LDC__c();
        contractLDC1.Contract__c = ct1.Id;
        contractLDC1.LDC_Account__c = lacc.Id;
        insert contractLDC1;
        
        sp = new Service_Point__c();
        sp.LDC_Account_Number__c = lacc.Id;
        sp.Service_Point_Number__c = '123';
        insert sp;
        
        meter = new Meter__c();
        meter.Service_Point__c = sp.Id;
        meter.Meter_Number__c ='ALL';
        insert meter;
        
        ldcvendor=new LDC_Vendor__c(Name='Test Vendor',Service_Territory__c='DAYTON',DUNS__c='123',Utility_Code__c='1234',Service_State__c = 'OH');
        Insert ldcvendor;
        
        dasrReqgaac = new DASR_Request__c();
        dasrReqgaac.DASR_Type__c  ='GAAC';
        dasrReqgaac.Contract__c = ct.Id;
        dasrReqgaac.DASR_Submit_Date__c = System.today();
        dasrReqgaac.Change_Effective_Date__c = System.today();
        dasrReqgaac.Capacity_Obligation__c = 2;
        dasrReqgaac.Transmission_Obligation_Quantity__c = 3;
        dasrReqgaac.LDC_Account__c = lacc.Id;
        dasrReqgaac.Billing_Entity__c='Dynegy';
        insert dasrReqgaac;
        
        Account_Exception__c ae2 = new Account_Exception__c();
        ae2.DASR_Request__c = dasrReqgaac.id;
        ae2.LDC_Account__c= lacc.Id;
        ae2.Reason_code__c = 'AMTKC';
        insert ae2;
              
        Account_Exception__c ae3 = new Account_Exception__c();
        ae3.DASR_Request__c = dasrReqgaac.id;
        ae3.LDC_Account__c= lacc.Id;
        ae3.Reason_code__c = 'AMTKZ';
        insert ae3;
        
        dasrReqgaac1 = new DASR_Request__c();
        dasrReqgaac1.DASR_Type__c  ='GAAC';
        dasrReqgaac1.Contract__c = ct.Id;
        dasrReqgaac1.DASR_Submit_Date__c = System.today();
        dasrReqgaac1.Change_Effective_Date__c = System.today();
        dasrReqgaac1.Capacity_Obligation__c = 2;
        dasrReqgaac1.Transmission_Obligation_Quantity__c = 3;
        dasrReqgaac1.LDC_Account__c = lacc.Id;
        dasrReqgaac1.Billing_Entity__c='Dynegy';
        insert dasrReqgaac1;
        
        Account_Exception__c ae = new Account_Exception__c();
        ae.DASR_Request__c = dasrReqgaac1.id;
        ae.LDC_Account__c= lacc.Id;
        ae.Reason_code__c = 'AMTKZ';
        insert ae;      
        
        Account_Exception__c ae1 = new Account_Exception__c();
        ae1.DASR_Request__c = dasrReqgaac.id;
        ae1.LDC_Account__c= lacc.Id;
        ae1.Reason_code__c = 'AMTKC';
        insert ae1;
    }
      
}