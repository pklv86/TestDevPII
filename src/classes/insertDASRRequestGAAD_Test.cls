@isTest
private class insertDASRRequestGAAD_Test{
    static Account acc;
    static Opportunity opp;
    static LDC_Account__c lacc;
    static LDC_Account__c lacc1;
    static LDC_Account__c lacc2;
    static Contract ct;
    static Contract ct1;
    static LDC_Vendor__c ldcvendor;
    static Supplier__c supplier;
    static DASR_Request__c dasrReq;
    static DASR_Request__c dasrReqGAAE;
    static DASR_Request__c dasrReqGAAC;
    static DASR_Request__c dasrReqGAAD;
    static Contract_LDC__c contractLDC;
    static Contract_LDC__c contractLDC1;
    static Contract_LDC__c contractLDC2;
    static Contract_LDC__c contractLDC3;
    static Service_Point__c sp;
    static Meter__c meter;
    static testmethod void testMethod1() {
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        String query = 'Select LDC_Account__c, DASR_Type__c, Most_Recent_GAAD__c, Contract__c, Integration_Status__C, LDC_Account__r.LDC_Account_Status__c, LDC_Account__r.opt_out__c, change_effective_date__c from DASR_Request__c where (LDC_Account__r.opt_out__c = true and Integration_Status__C = \'Waiting For Response\' and DASR_Type__c = \'GAAE\' and LDC_Account__r.LDC_Vendor__r.Service_State__c = \'IL\') or (DASR_Type__c = \'GAAE\' and LDC_Account__r.LDC_Account_Status__c = \'Pending_Final\' and LDC_Account__r.LDC_Vendor__r.Service_State__c = \'IL\')';
        supplier = new Supplier__c();
        supplier.NAme ='Test supplier';
        supplier.Master_DUNS__c  ='1223';
        supplier.Supplier_DUNS__c ='999';
        supplier.Active__c = true;
        insert supplier;
                                
        ldcvendor = new LDC_Vendor__c(Name='Test Vendor',Service_Territory__c='Ameren-IL',DUNS__c='123',Utility_Code__c='1234',Service_State__c = 'IL');
        insert ldcvendor; 
        
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
        lacc.LDC_Account_Number__c = '00040621040044404';
        lacc.Service_State__c = 'IL';
        lacc.Service_Territory__c = ldcvendor.Service_Territory__c;               
        lacc.LDC_Vendor__c = ldcvendor.id;
        insert lacc;
        
        lacc1 = new LDC_Account__c();
        lacc1.name  ='Test LDC acc1';
        lacc1.Account__c = acc.id;
        lacc1.LDC_Account_Number__c = '00040621040044444';
        lacc1.opt_out__c = true;
        lacc1.Service_State__c = 'IL';
        lacc1.Service_Territory__c = ldcvendor.Service_Territory__c;        
        lacc1.LDC_Vendor__c = ldcvendor.id;
        lacc1.LDC_Account_Status__c = 'Pending_Final';
        insert lacc1;
                
        lacc2 = new LDC_Account__c();
        lacc2.name  ='Test LDC acc2';
        lacc2.Account__c = acc.id;
        lacc2.LDC_Account_Number__c = '00040621044444444';
        lacc2.Service_Territory__c = ldcvendor.Service_Territory__c;        
        lacc2.LDC_Vendor__c = ldcvendor.id;
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
        
        contractLDC2 = new Contract_LDC__c();
        contractLDC2.Contract__c = ct1.Id;
        contractLDC2.LDC_Account__c = lacc1.Id;
        contractLDC2.Active__c = true;
        insert contractLDC2;
        
        contractLDC3 = new Contract_LDC__c();
        contractLDC3.Contract__c = ct1.Id;
        contractLDC3.LDC_Account__c = lacc2.Id;
        insert contractLDC3;
        
        sp = new Service_Point__c();
        sp.LDC_Account_Number__c = lacc.Id;
        sp.Service_Point_Number__c = '123';
        insert sp;
        
        meter = new Meter__c();
        meter.Service_Point__c = sp.Id;
        meter.Meter_Number__c ='ALL';
        insert meter;               
        
        dasrReq = new DASR_Request__c();
        dasrReq.DASR_Type__c  ='GAAE';
        dasrReq.Contract__c = ct.Id;
        dasrReq.DASR_Submit_Date__c = System.today();
        dasrReq.LDC_Account__c = lacc.Id;
        dasrReq.Billing_Entity__c='Dynegy';
        insert dasrReq;
        
        dasrReqGAAE = new DASR_Request__c();
        dasrReqGAAE.DASR_Type__c  ='GAAE';
        dasrReqGAAE.Contract__c = ct1.Id;
        dasrReqGAAE.change_effective_date__c = System.today()+6;
        dasrReqGAAE.DASR_Submit_Date__c = System.today();
        dasrReqGAAE.LDC_Account__c = lacc1.Id;
        dasrReqGAAE.Integration_Status__C = 'Waiting For Response';
        dasrReqGAAE.Billing_Entity__c='Dynegy';
        insert dasrReqGAAE;

        Test.startTest();
        insertDASRRequestGAAD c = new insertDASRRequestGAAD(query);
        Database.executeBatch(c);
        
        schedulableDASRInsertGAAD sch = new schedulableDASRInsertGAAD();
        Date dt = date.today();
        time t =datetime.now().time();
        String schTime = ''+(t.second()+1)+' '+t.minute()+' '+t.hour()+' * * ?';
        system.schedule('Test insertGAADDasr', schTime, sch);
        //Database.execute(sch);
        Test.stopTest();
    }
}