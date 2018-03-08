/* 
 * Name: EDIOutboundHelper_Test
 * Type: Test Class
 * Apex Class: EDIOutboundHelper
 * Description: Test class for code coverage of EDIDataResetBatch. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0        
 * 1.1        Prasad                        Aug 2016         1. Modified for code coverage
 */

@IsTest
private class EDIOutboundHelper_Test 
{
    static Account acc;
    static Opportunity opp;
    static LDC_Account__c lacc;
    static LDC_Account__c lacc2;
    static LDC_Account__c lacc3;
    static LDC_Account__c lacc4;
    static LDC_Account__c lacc5;
    static Contract ct;
    static Contract_Term__c cTerm;
    static LDC_Vendor__c ldcvendor;
    static LDC_Vendor__c ldcvendor2;
    static LDC_Vendor__c ldcvendor3;
    static Supplier__c supplier;
    static DASR_Request__c dasrReq;
    static DASR_Request__c dasrReqGAAE;
    static DASR_Request__c dasrReqGAAE2;
    static DASR_Request__c dasrReqGAAC;
    static DASR_Request__c dasrReqGAAC1;
    static DASR_Request__c dasrReqGAAC2;
    static DASR_Request__c dasrReqGAAC3;
    static DASR_Request__c dasrReqGAAC4;
    static DASR_Request__c dasrReqGAACacc;
    static DASR_Request__c dasrReqGAACacc4;
    static DASR_Request__c dasrReqGAACacc4rr;
    static DASR_Request__c dasrReqGAACacc5;
    static DASR_Request__c dasrReqGAACacc5br;
    static DASR_Request__c dasrReqGAAD;
    static DASR_Request__c dasrReqGAAR;
    static DASR_Request__c dasrReqGAAR2;
    static Contract_LDC__c contractLDC;
    static Service_Point__c sp;
    static Meter__c meter;
    
    static LDC_Account__c laccIL1;
    static LDC_Account__c laccIL2;
    static LDC_Account__c laccIL3;
    static LDC_Account__c laccIL4;
    static LDC_Account__c laccIL5;
    static LDC_Account__c laccIL6;
    static LDC_Vendor__c ldcvendorIL1;
    static LDC_Vendor__c ldcvendorIL2;
    static LDC_Vendor__c ldcvendorIL3;
    static DASR_Request__c dasrReqIL;
    static DASR_Request__c dasrReqILGAAE;
    static DASR_Request__c dasrReqILGAAE2;
    static DASR_Request__c dasrReqILGAAC;
    static DASR_Request__c dasrReqILGAAC1;
    static DASR_Request__c dasrReqILGAAC2;
    static DASR_Request__c dasrReqILGAAC2a;
    static DASR_Request__c dasrReqILGAAC3;
    static DASR_Request__c dasrReqILGAAC4;
    static DASR_Request__c dasrReqILGAACacc;
    static DASR_Request__c dasrReqILGAACacc4;
    static DASR_Request__c dasrReqILGAACacc4rr;
    static DASR_Request__c dasrReqILGAACacc5;
    static DASR_Request__c dasrReqILGAACacc5br;
    static DASR_Request__c dasrReqILGAAD;
    static DASR_Request__c dasrReqILGAAD2;
    static DASR_Request__c dasrReqILGAAR;
    static Service_Point__c sp2;
    
    @testSetup static void setupData() 
    {
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        
        
        supplier = new Supplier__c();
        supplier.NAme ='Test supplier';
        supplier.Master_DUNS__c  ='1223';
        supplier.Supplier_DUNS__c ='999';
        supplier.Active__c = true;
        insert supplier;
        
        ldcvendor=new LDC_Vendor__c(Name='Test Vendor',Service_Territory__c='DAYTON',DUNS__c='123',Utility_Code__c='1234',Service_State__c='OH');
        ldcvendor2=new LDC_Vendor__c(Name='Ohio Power Test',Service_Territory__c='DAYTON',DUNS__c='006998371',Utility_Code__c='2345',Service_State__c='OH');
        ldcvendor3=new LDC_Vendor__c(Name='Ohio Power Test2',Service_Territory__c='DAYTON',DUNS__c='147212336',Utility_Code__c='2345',Service_State__c='OH');
        ldcvendorIL1=new LDC_Vendor__c(Name='Test Vendor Il',Service_Territory__c='Ameren-IL',DUNS__c='123',Utility_Code__c='1234',Service_State__c='IL');
        ldcvendorIL2=new LDC_Vendor__c(Name='Ohio Power Test Il',Service_Territory__c='Ameren-IL',DUNS__c='006998371',Utility_Code__c='2345',Service_State__c='IL');
        ldcvendorIL3=new LDC_Vendor__c(Name='Ohio Power Test2 IL',Service_Territory__c='Ameren-IL',DUNS__c='147212336',Utility_Code__c='2345',Service_State__c='IL');
        insert new List<LDC_Vendor__c>{ldcvendor,ldcvendor2,ldcvendor3,ldcvendorIL1,ldcvendorIL2,ldcvendorIL3};
        
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
        lacc.Bill_Method__c ='DUAL';
        lacc.Interval_Usage__c ='Summary';
        lacc.Service_Territory__c='DAYTON';
        lacc.LDC_Vendor__c = ldcvendor.id;
        
        lacc2 = new LDC_Account__c();
        lacc2.name  ='Test LDC acc 2';
        lacc2.Account__c = acc.id;
        lacc2.LDC_Account_Number__c = '00040621040044444';
        lacc2.Bill_Method__c ='DUAL';
        lacc2.Interval_Usage__c ='Summary';
        lacc2.Service_Territory__c='DAYTON';
        lacc2.LDC_Vendor__c = ldcvendor2.id;
        
        lacc3 = new LDC_Account__c();
        lacc3.name  ='Test LDC acc 3';
        lacc3.Account__c = acc.id;
        lacc3.LDC_Account_Number__c = '00040621044444444';
        lacc3.Bill_Method__c ='UCB';
        lacc3.Interval_Usage__c ='Summary';
        lacc3.Service_Territory__c='DAYTON';
        lacc3.LDC_Vendor__c = ldcvendor3.id;
        
        lacc4 = new LDC_Account__c();
        lacc4.name  ='Test LDC acc 4';
        lacc4.Account__c = acc.id;
        lacc4.LDC_Account_Number__c = '40040621040044404';
        lacc4.Bill_Method__c ='Bill ready';
        lacc4.Interval_Usage__c ='Summary';
        lacc4.Service_Territory__c='DAYTON';
        lacc4.LDC_Vendor__c = ldcvendor2.id;
        
        lacc5 = new LDC_Account__c();
        lacc5.name  ='Test LDC acc 5';
        lacc5.Account__c = acc.id;
        lacc5.LDC_Account_Number__c = '50040621040044404';
        lacc5.Bill_Method__c ='Rate ready';
        lacc5.Interval_Usage__c ='Summary';
        lacc5.Service_Territory__c='DAYTON';
        lacc5.LDC_Vendor__c = ldcvendor3.id;
        
        laccIL1 = new LDC_Account__c();
        laccIL1.name  ='Test LDC acc';
        laccIL1.Account__c = acc.id;
        laccIL1.LDC_Account_Number__c = '12040621040044404';
        laccIL1.Bill_Method__c ='DUAL';
        laccIL1.Interval_Usage__c ='Summary';
        laccIL1.Service_Territory__c='Ameren-IL';
        laccIL1.LDC_Vendor__c = ldcvendorIL1.id;
        
        laccIL2 = new LDC_Account__c();
        laccIL2.name  ='Test LDC acc 2';
        laccIL2.Account__c = acc.id;
        laccIL2.LDC_Account_Number__c = '12040621040044444';
        laccIL2.Bill_Method__c ='DUAL';
        laccIL2.Interval_Usage__c ='Summary';
        laccIL2.Service_Territory__c='Ameren-IL';
        laccIL2.LDC_Vendor__c = ldcvendorIL2.id;
        
        laccIL3 = new LDC_Account__c();
        laccIL3.name  ='Test LDC acc 3';
        laccIL3.Account__c = acc.id;
        laccIL3.LDC_Account_Number__c = '12040621044444444';
        laccIL3.Bill_Method__c ='UCB';
        laccIL3.Interval_Usage__c ='Summary';
        laccIL3.Service_Territory__c='Ameren-IL';
        laccIL3.LDC_Vendor__c = ldcvendorIL3.id;
        
        laccIL4 = new LDC_Account__c();
        laccIL4.name  ='Test LDC acc 4';
        laccIL4.Account__c = acc.id;
        laccIL4.LDC_Account_Number__c = '14040621040044404';
        laccIL4.Bill_Method__c ='Bill ready';
        laccIL4.Interval_Usage__c ='Summary';
        laccIL4.Service_Territory__c='Ameren-IL';
        laccIL4.LDC_Vendor__c = ldcvendorIL2.id;
        
        laccIL5 = new LDC_Account__c();
        laccIL5.name  ='Test LDC acc 5';
        laccIL5.Account__c = acc.id;
        laccIL5.LDC_Account_Number__c = '15040621040044404';
        laccIL5.Bill_Method__c ='Rate ready';
        laccIL5.Interval_Usage__c ='Summary';
        laccIL5.Service_Territory__c='Ameren-IL';
        laccIL5.LDC_Vendor__c = ldcvendorIL3.id;
        
        laccIL6 = new LDC_Account__c();
        laccIL6.name  ='Test LDC acc 6';
        laccIL6.Account__c = acc.id;
        laccIL6.LDC_Account_Number__c = '16040621040044404';
        laccIL6.Bill_Method__c ='Rate ready';
        laccIL6.Interval_Usage__c ='Summary';
        laccIL6.Service_Territory__c='Ameren-IL';
        laccIL6.LDC_Vendor__c = ldcvendorIL3.id;
        laccIL6.ldc_account_status__c = 'PENDING_ENROLLMENT';
        
        insert new List<LDC_Account__c>{lacc,lacc2,lacc3,lacc4,lacc5,laccIL1,laccIL2,laccIL3,laccIL4,laccIL5,laccIL6};
        
        ct=new Contract(Name='Test Contract',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM01', Bill_Method__c ='Rate Ready', Interval_Usage__c ='Summary',Contract_Counter_Signed_Date__c=System.today().addDays(-1));
        
        Insert ct;
        
        cTerm = new Contract_Term__c();
        
        cTerm.Term_Category__c = 'Test Cat';
        cTerm.Term_Start_Date__c= system.today().adddays(10);
        cTerm.Term_Stop_Date__c = system.today().adddays(100);
        cTerm.Term_Type__c = 'tupe1';
        cTerm.Value_Num__c=123;
        cTerm.Contract_Term_Value__c=100;
        cTerm.Contract__c=ct.id;
        
        
        insert cTerm;
        contractLDC = new Contract_LDC__c();
        contractLDC.Contract__c = ct.Id;
        contractLDC.LDC_Account__c = lacc.Id;
        insert contractLDC;
        
        sp = new Service_Point__c();
        sp.LDC_Account_Number__c = lacc.Id;
        sp.Service_Point_Number__c = '123';
        insert sp;
        
        sp2 = new Service_Point__c();
        sp2.LDC_Account_Number__c = laccIL3.Id;
        sp2.Service_Point_Number__c = '456';
        insert sp2;
        
        meter = new Meter__c();
        meter.Service_Point__c = sp.Id;
        meter.Meter_Number__c ='ALL';
        insert meter;
        
        dasrReq = new DASR_Request__c();
        dasrReq.DASR_Type__c  ='GAAE';
        dasrReq.Contract__c = ct.Id;
        dasrReq.DASR_Submit_Date__c = System.today();
        dasrReq.LDC_Account__c = lacc.Id;
        dasrReq.Dynegy_Initiated__c = true;
        dasrReq.Billing_Entity__c='Dynegy';
        insert dasrReq;
        
        dasrReqGAAE = new DASR_Request__c();
        dasrReqGAAE.DASR_Type__c  ='GAAE';
        dasrReqGAAE.Contract__c = ct.Id;
        dasrReqGAAE.DASR_Submit_Date__c = System.today();
        dasrReqGAAE.LDC_Account__c = lacc2.Id;
        dasrReqGAAE.Dynegy_Initiated__c = true;
        dasrReqGAAE.Billing_Entity__c='Dynegy';
        insert dasrReqGAAE;
        
        dasrReqGAAE2 = new DASR_Request__c();
        dasrReqGAAE2.DASR_Type__c  ='GAAE';
        dasrReqGAAE2.Contract__c = ct.Id;
        dasrReqGAAE2.DASR_Submit_Date__c = System.today();
        dasrReqGAAE2.LDC_Account__c = lacc3.Id;
        dasrReqGAAE2.Dynegy_Initiated__c = true;
        dasrReqGAAE2.Billing_Entity__c='Dynegy';
        insert dasrReqGAAE2;
        
        dasrReqGAAC = new DASR_Request__c();
        dasrReqGAAC.DASR_Type__c  ='GAAC';
        dasrReqGAAC.Contract__c = ct.Id;
        dasrReqGAAC.DASR_Submit_Date__c = System.today();
        dasrReqGAAC.Dynegy_Initiated__c = true;
        dasrReqGAAC.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAAC.Bill_Method__c ='Rate Ready';
        dasrReqGAAC.LDC_Account__c = lacc.Id;
        dasrReqGAAC.Billing_Entity__c='Dynegy';
        
        dasrReqGAACacc = new DASR_Request__c();
        dasrReqGAACacc.DASR_Type__c  ='GAAC';
        dasrReqGAACacc.Contract__c = ct.Id;
        dasrReqGAACacc.DASR_Submit_Date__c = System.today();
        dasrReqGAACacc.Dynegy_Initiated__c = true;
        dasrReqGAACacc.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAACacc.Bill_Method__c ='Bill Ready';
        dasrReqGAACacc.LDC_Account__c = lacc.Id;
        dasrReqGAACacc.Billing_Entity__c='Dynegy';
        
        dasrReqGAACacc4 = new DASR_Request__c();
        dasrReqGAACacc4.DASR_Type__c  ='GAAC';
        dasrReqGAACacc4.Contract__c = ct.Id;
        dasrReqGAACacc4.DASR_Submit_Date__c = System.today();
        dasrReqGAACacc4.Dynegy_Initiated__c = true;
        dasrReqGAACacc4.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAACacc4.Bill_Method__c ='dual';
        dasrReqGAACacc4.LDC_Account__c = lacc4.Id;
        dasrReqGAACacc4.Billing_Entity__c='Dynegy';
        
        dasrReqGAACacc4rr = new DASR_Request__c();
        dasrReqGAACacc4rr.DASR_Type__c  ='GAAC';
        dasrReqGAACacc4rr.Contract__c = ct.Id;
        dasrReqGAACacc4rr.DASR_Submit_Date__c = System.today();
        dasrReqGAACacc4rr.Dynegy_Initiated__c = true;
        dasrReqGAACacc4rr.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAACacc4rr.Bill_Method__c ='rate Ready';
        dasrReqGAACacc4rr.LDC_Account__c = lacc4.Id;
        dasrReqGAACacc4rr.Billing_Entity__c='Dynegy';
        
        dasrReqGAACacc5 = new DASR_Request__c();
        dasrReqGAACacc5.DASR_Type__c  ='GAAC';
        dasrReqGAACacc5.Contract__c = ct.Id;
        dasrReqGAACacc5.DASR_Submit_Date__c = System.today();
        dasrReqGAACacc5.Dynegy_Initiated__c = true;
        dasrReqGAACacc5.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAACacc5.Bill_Method__c ='dual';
        dasrReqGAACacc5.LDC_Account__c = lacc5.Id;
        dasrReqGAACacc5.Billing_Entity__c='Dynegy';
        
        dasrReqGAACacc5br = new DASR_Request__c();
        dasrReqGAACacc5br.DASR_Type__c  ='GAAC';
        dasrReqGAACacc5br.Contract__c = ct.Id;
        dasrReqGAACacc5br.DASR_Submit_Date__c = System.today();
        dasrReqGAACacc5br.Dynegy_Initiated__c = true;
        dasrReqGAACacc5br.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAACacc5br.Bill_Method__c ='Bill Ready';
        dasrReqGAACacc5br.LDC_Account__c = lacc5.Id;
        dasrReqGAACacc5br.Billing_Entity__c='Dynegy';
        

        dasrReqGAAC1 = new DASR_Request__c();
        dasrReqGAAC1.DASR_Type__c  ='GAAC';
        dasrReqGAAC1.Contract__c = ct.Id;
        dasrReqGAAC1.DASR_Submit_Date__c = System.today();
        dasrReqGAAC1.Dynegy_Initiated__c = true;
        dasrReqGAAC1.Change_Reason__c  = 'Change Service Indicator (Summary or Detail Interval Data)';
        //dasrReqGAAC.Bill_Method__c ='Rate Ready';
        dasrReqGAAC1.LDC_Account__c = lacc.Id;
        dasrReqGAAC1.Billing_Entity__c='Dynegy';


        dasrReqGAAC2 = new DASR_Request__c();
        dasrReqGAAC2.DASR_Type__c  ='GAAC';
        dasrReqGAAC2.Contract__c = ct.Id;
        dasrReqGAAC2.DASR_Submit_Date__c = System.today();
        dasrReqGAAC2.Dynegy_Initiated__c = true;
        dasrReqGAAC2.Change_Reason__c  = 'Change ESP Rate Code';
        //dasrReqGAAC.Bill_Method__c ='Rate Ready';
        dasrReqGAAC2.LDC_Account__c = lacc.Id;
        dasrReqGAAC2.Billing_Entity__c='Dynegy';
        
        dasrReqGAAC3 = new DASR_Request__c();
        dasrReqGAAC3.DASR_Type__c  ='GAAC';
        dasrReqGAAC3.Contract__c = ct.Id;
        dasrReqGAAC3.DASR_Submit_Date__c = System.today();
        dasrReqGAAC3.Dynegy_Initiated__c = true;
        dasrReqGAAC3.Change_Reason__c  = 'Change Aggregation Category';
        //dasrReqGAAC.Bill_Method__c ='Rate Ready';
        dasrReqGAAC3.LDC_Account__c = lacc.Id;
        dasrReqGAAC3.Billing_Entity__c='Dynegy';
        
        dasrReqGAAC4 = new DASR_Request__c();
        dasrReqGAAC4.DASR_Type__c  ='GAAC';
        dasrReqGAAC4.Contract__c = ct.Id;
        dasrReqGAAC4.DASR_Submit_Date__c = System.today();
        dasrReqGAAC4.Dynegy_Initiated__c = true;
        dasrReqGAAC4.Change_Reason__c  = 'Test Change Reason';
        //dasrReqGAAC.Bill_Method__c ='Rate Ready';
        dasrReqGAAC4.LDC_Account__c = lacc.Id;
        dasrReqGAAC4.Billing_Entity__c='Dynegy';
        
        insert new List<DASR_Request__c>{dasrReqGAAC,dasrReqGAAC1,dasrReqGAAC2,dasrReqGAAC3,dasrReqGAAC4,dasrReqGAACacc,dasrReqGAACacc4,dasrReqGAACacc4rr,dasrReqGAACacc5,dasrReqGAACacc5br};
        
        dasrReqGAAD = new DASR_Request__c();
        dasrReqGAAD.DASR_Type__c  ='GAAD';
        dasrReqGAAD.Contract__c = ct.Id;
        dasrReqGAAD.DASR_Submit_Date__c = System.today();
        dasrReqGAAD.Drop_Date__c  = System.today();
        dasrReqGAAD.Drop_Reason__c ='Contract Expired';
        dasrReqGAAD.Dynegy_Initiated__c = true;
        dasrReqGAAD.LDC_Account__c = lacc.Id;
        dasrReqGAAD.Billing_Entity__c='Dynegy';
        insert dasrReqGAAD;
        
        dasrReqGAAR = new DASR_Request__c();
        dasrReqGAAR.DASR_Type__c  ='GAAR';
        dasrReqGAAR.Contract__c = ct.Id;
        dasrReqGAAR.DASR_Submit_Date__c = System.today();
        dasrReqGAAR.Dynegy_Initiated__c = true;
        dasrReqGAAR.LDC_Account__c = lacc.Id;
        dasrReqGAAR.Billing_Entity__c='Dynegy';
        insert dasrReqGAAR;
        
        dasrReqGAAR2 = new DASR_Request__c();
        dasrReqGAAR2.DASR_Type__c  ='GAAR';
        dasrReqGAAR2.Contract__c = ct.Id;
        dasrReqGAAR2.DASR_Submit_Date__c = System.today();
        dasrReqGAAR2.Dynegy_Initiated__c = true;
        dasrReqGAAR2.LDC_Account__c = lacc2.Id;
        dasrReqGAAR2.Billing_Entity__c='Dynegy';
        insert dasrReqGAAR2;
        
        dasrReqIL = new DASR_Request__c();
        dasrReqIL.DASR_Type__c  ='GAAE';
        dasrReqIL.Contract__c = ct.Id;
        dasrReqIL.DASR_Submit_Date__c = System.today();
        dasrReqIL.LDC_Account__c = laccIL1.Id;
        dasrReqIL.Dynegy_Initiated__c = true;
        dasrReqIL.Billing_Entity__c='Dynegy';
        insert dasrReqIL;
        
        dasrReqILGAAE = new DASR_Request__c();
        dasrReqILGAAE.DASR_Type__c  ='GAAE';
        dasrReqILGAAE.Contract__c = ct.Id;
        dasrReqILGAAE.DASR_Submit_Date__c = System.today();
        dasrReqILGAAE.LDC_Account__c = laccIL2.Id;
        dasrReqILGAAE.Dynegy_Initiated__c = true;
        dasrReqILGAAE.Billing_Entity__c='Dynegy';
        insert dasrReqILGAAE;
        
        dasrReqILGAAE2 = new DASR_Request__c();
        dasrReqILGAAE2.DASR_Type__c  ='GAAE';
        dasrReqILGAAE2.Contract__c = ct.Id;
        dasrReqILGAAE2.DASR_Submit_Date__c = System.today();
        dasrReqILGAAE2.LDC_Account__c = laccIL3.Id;
        dasrReqILGAAE2.Dynegy_Initiated__c = true;
        dasrReqILGAAE2.Billing_Entity__c='Dynegy';
        dasrReqILGAAE2.OFF_Cycle_Enrollment__c = true;
        dasrReqILGAAE2.Service_Point__c= 'Il Service Point';
        insert dasrReqILGAAE2;
        
        dasrReqILGAAC = new DASR_Request__c();
        dasrReqILGAAC.DASR_Type__c  ='GAAC';
        dasrReqILGAAC.Contract__c = ct.Id;
        dasrReqILGAAC.DASR_Submit_Date__c = System.today();
        dasrReqILGAAC.Dynegy_Initiated__c = true;
        dasrReqILGAAC.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqILGAAC.Bill_Method__c ='Rate Ready';
        dasrReqILGAAC.LDC_Account__c = laccIL1.Id;
        dasrReqILGAAC.Billing_Entity__c='Dynegy';
        
        dasrReqILGAACacc = new DASR_Request__c();
        dasrReqILGAACacc.DASR_Type__c  ='GAAC';
        dasrReqILGAACacc.Contract__c = ct.Id;
        dasrReqILGAACacc.DASR_Submit_Date__c = System.today();
        dasrReqILGAACacc.Dynegy_Initiated__c = true;
        dasrReqILGAACacc.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqILGAACacc.Bill_Method__c ='Bill Ready';
        dasrReqILGAACacc.LDC_Account__c = laccIL1.Id;
        dasrReqILGAACacc.Billing_Entity__c='Dynegy';
        
        dasrReqILGAACacc4 = new DASR_Request__c();
        dasrReqILGAACacc4.DASR_Type__c  ='GAAC';
        dasrReqILGAACacc4.Contract__c = ct.Id;
        dasrReqILGAACacc4.DASR_Submit_Date__c = System.today();
        dasrReqILGAACacc4.Dynegy_Initiated__c = true;
        dasrReqILGAACacc4.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqILGAACacc4.Bill_Method__c ='dual';
        dasrReqILGAACacc4.LDC_Account__c = laccIL4.Id;
        dasrReqILGAACacc4.Service_Point__c= 'Il Service Point Chg';
        dasrReqILGAACacc4.Billing_Entity__c='Dynegy';
        
        dasrReqILGAACacc4rr = new DASR_Request__c();
        dasrReqILGAACacc4rr.DASR_Type__c  ='GAAC';
        dasrReqILGAACacc4rr.Contract__c = ct.Id;
        dasrReqILGAACacc4rr.DASR_Submit_Date__c = System.today();
        dasrReqILGAACacc4rr.Dynegy_Initiated__c = true;
        dasrReqILGAACacc4rr.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqILGAACacc4rr.Bill_Method__c ='rate Ready';
        dasrReqILGAACacc4rr.LDC_Account__c = laccIL4.Id;
        dasrReqILGAACacc4rr.Billing_Entity__c='Dynegy';
        
        dasrReqILGAACacc5 = new DASR_Request__c();
        dasrReqILGAACacc5.DASR_Type__c  ='GAAC';
        dasrReqILGAACacc5.Contract__c = ct.Id;
        dasrReqILGAACacc5.DASR_Submit_Date__c = System.today();
        dasrReqILGAACacc5.Dynegy_Initiated__c = true;
        dasrReqILGAACacc5.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqILGAACacc5.Bill_Method__c ='dual';
        dasrReqILGAACacc5.LDC_Account__c = laccIL5.Id;
        dasrReqILGAACacc5.Billing_Entity__c='Dynegy';
        
        dasrReqILGAACacc5br = new DASR_Request__c();
        dasrReqILGAACacc5br.DASR_Type__c  ='GAAC';
        dasrReqILGAACacc5br.Contract__c = ct.Id;
        dasrReqILGAACacc5br.DASR_Submit_Date__c = System.today();
        dasrReqILGAACacc5br.Dynegy_Initiated__c = true;
        dasrReqILGAACacc5br.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqILGAACacc5br.Bill_Method__c ='Bill Ready';
        dasrReqILGAACacc5br.LDC_Account__c = laccIL5.Id;
        dasrReqILGAACacc5br.Billing_Entity__c='Dynegy';
        

        dasrReqILGAAC1 = new DASR_Request__c();
        dasrReqILGAAC1.DASR_Type__c  ='GAAC';
        dasrReqILGAAC1.Contract__c = ct.Id;
        dasrReqILGAAC1.DASR_Submit_Date__c = System.today();
        dasrReqILGAAC1.Dynegy_Initiated__c = true;
        dasrReqILGAAC1.Change_Reason__c  = 'Change Service Indicator (Summary or Detail Interval Data)';
        //dasrReqILGAAC.Bill_Method__c ='Rate Ready';
        dasrReqILGAAC1.LDC_Account__c = laccIL1.Id;
        dasrReqILGAAC1.Billing_Entity__c='Dynegy';


        dasrReqILGAAC2 = new DASR_Request__c();
        dasrReqILGAAC2.DASR_Type__c  ='GAAC';
        dasrReqILGAAC2.Contract__c = ct.Id;
        dasrReqILGAAC2.DASR_Submit_Date__c = System.today();
        dasrReqILGAAC2.Dynegy_Initiated__c = true;
        dasrReqILGAAC2.Change_Reason__c  = 'Change ESP Rate Code';
        //dasrReqILGAAC.Bill_Method__c ='Rate Ready';
        dasrReqILGAAC2.LDC_Account__c = laccIL1.Id;
        dasrReqILGAAC2.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAC2a = new DASR_Request__c();
        dasrReqILGAAC2a.DASR_Type__c  ='GAAC';
        dasrReqILGAAC2a.Contract__c = ct.Id;
        dasrReqILGAAC2a.DASR_Submit_Date__c = System.today();
        dasrReqILGAAC2a.Dynegy_Initiated__c = true;
        dasrReqILGAAC2a.Change_Reason__c  = 'Change ESP Rate Code';
        //dasrReqILGAACa.Bill_Method__c ='Rate Ready';
        dasrReqILGAAC2a.LDC_Account__c = laccIL1.Id;
        dasrReqILGAAC2a.Service_Point__c= 'Il Service Point';
        dasrReqILGAAC2a.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAC3 = new DASR_Request__c();
        dasrReqILGAAC3.DASR_Type__c  ='GAAC';
        dasrReqILGAAC3.Contract__c = ct.Id;
        dasrReqILGAAC3.DASR_Submit_Date__c = System.today();
        dasrReqILGAAC3.Dynegy_Initiated__c = true;
        dasrReqILGAAC3.Change_Reason__c  = 'Change Aggregation Category';
        //dasrReqILGAAC.Bill_Method__c ='Rate Ready';
        dasrReqILGAAC3.LDC_Account__c = laccIl1.Id;
        dasrReqILGAAC3.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAC4 = new DASR_Request__c();
        dasrReqILGAAC4.DASR_Type__c  ='GAAC';
        dasrReqILGAAC4.Contract__c = ct.Id;
        dasrReqILGAAC4.DASR_Submit_Date__c = System.today();
        dasrReqILGAAC4.Dynegy_Initiated__c = true;
        dasrReqILGAAC4.Change_Reason__c  = 'Test Change Reason';
        //dasrReqILGAAC.Bill_Method__c ='Rate Ready';
        dasrReqILGAAC4.LDC_Account__c = laccIl1.Id;
        dasrReqILGAAC4.Billing_Entity__c='Dynegy';
        
        insert new List<DASR_Request__c>{dasrReqILGAAC,dasrReqILGAAC1,dasrReqILGAAC2,dasrReqILGAAC2a,dasrReqILGAAC3,dasrReqILGAAC4,dasrReqILGAACacc,dasrReqILGAACacc4,dasrReqILGAACacc4rr,dasrReqILGAACacc5,dasrReqILGAACacc5br};
        
        dasrReqILGAAD = new DASR_Request__c();
        dasrReqILGAAD.DASR_Type__c  ='GAAD';
        dasrReqILGAAD.Contract__c = ct.Id;
        dasrReqILGAAD.DASR_Submit_Date__c = System.today();
        dasrReqILGAAD.Drop_Date__c  = System.today();
        dasrReqILGAAD.Drop_Reason__c ='Contract Expired';
        dasrReqILGAAD.Dynegy_Initiated__c = true;
        dasrReqILGAAD.LDC_Account__c = laccIl1.Id;
        dasrReqILGAAD.Billing_Entity__c='Dynegy';
        insert dasrReqILGAAD;
        
        dasrReqILGAAD2 = new DASR_Request__c();
        dasrReqILGAAD2.DASR_Type__c  ='GAAD';
        dasrReqILGAAD2.Contract__c = ct.Id;
        dasrReqILGAAD2.DASR_Submit_Date__c = System.today();
        dasrReqILGAAD2.Drop_Date__c  = System.today();
        dasrReqILGAAD2.Drop_Reason__c ='Other';
        dasrReqILGAAD2.Drop_Reason_Description__c = 'Contract Expired';
        dasrReqILGAAD2.Dynegy_Initiated__c = true;
        dasrReqILGAAD2.LDC_Account__c = laccIl6.Id;
        dasrReqILGAAD2.Billing_Entity__c='Dynegy';
        dasrReqILGAAD2.OFF_Cycle_Enrollment__c = true;
        insert dasrReqILGAAD2;
        
        dasrReqILGAAR = new DASR_Request__c();
        dasrReqILGAAR.DASR_Type__c  ='GAAR';
        dasrReqILGAAR.Contract__c = ct.Id;
        dasrReqILGAAR.DASR_Submit_Date__c = System.today();
        dasrReqILGAAR.Dynegy_Initiated__c = true;
        dasrReqILGAAR.LDC_Account__c = laccIL1.Id;
        dasrReqILGAAR.Billing_Entity__c='Dynegy';
        dasrReqILGAAR.Service_Point__c= 'Il Service Point';
        insert dasrReqILGAAR;
        
        EDIIntegrationConfiguration__c config = new EDIIntegrationConfiguration__c(name ='Default',Notify_Email__c='anands1775@gmail.com',User_Name__c='dynsfdev', Password__c='u7SBbSIG',EDI_Outbound_End_Point__c='https://salesforcetest.dynegy.com/SforceESG.svc/SforceESG',Interval_Request_Code__c='N',Default_Meter_Number__c='ALL',Recipient_Name__c='ESG',Receipient_DUNS__c='049050839');
        insert config;
        
        ChangeReason__c  chngRsn1 = new ChangeReason__c(name='CHA',Reason_Code__c ='CHA',Reason_Value__c ='Customer Changed to another Service Provider');
        ChangeReason__c  chngRsn2 = new ChangeReason__c(name='REF17',Reason_Code__c ='REF17',Reason_Value__c ='Change Service Indicator (Summary or Detail Interval Data)');
        ChangeReason__c  chngRsn3 = new ChangeReason__c(name='REFBLT',Reason_Code__c ='REFBLT ',Reason_Value__c ='Change Billing Type (Billing Option)');
        ChangeReason__c  chngRsn4 = new ChangeReason__c(name='REFRB',Reason_Code__c ='REFRB',Reason_Value__c ='Change ESP Rate Code');
        ChangeReason__c  chngRsn5 = new ChangeReason__c(name='REFPG',Reason_Code__c ='REFPG',Reason_Value__c ='Change Aggregation Category');
        ChangeReason__c  chngRsn6 = new ChangeReason__c(name='REFTest',Reason_Code__c ='REFTest',Reason_Value__c ='Test Change Reason');
        
        insert new List<ChangeReason__c>{chngRsn1,chngRsn2,chngRsn3,chngRsn4,chngRsn5,chngRsn6};
        
        Bill_Method__c   billMthd1 = new Bill_Method__c (name='Bill Ready', Bill_Calculator__c ='DUAL',Bill_Presenter__c ='LDC');
        Bill_Method__c   billMthd2 = new Bill_Method__c (name='Rate Ready', Bill_Calculator__c ='LDC',Bill_Presenter__c ='LDC');
        Bill_Method__c   billMthd3 = new Bill_Method__c (name='DUAL', Bill_Calculator__c ='DUAL',Bill_Presenter__c ='DUAL');
        Bill_Method__c   billMthd4 = new Bill_Method__c (name='SBO', Bill_Calculator__c ='DUAL',Bill_Presenter__c ='ESP');
        
        insert new List<Bill_Method__c>{billMthd1,billMthd2,billMthd3,billMthd4};        
        
    }
    @IsTest static void testHelper1() 
    {
        List<DASR_Request__c> lDasr = new List<DASR_Request__c>();
        dasrReq = [select Id,DASR_Type__c,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Supplier_ID__c,Vendor_Id__c,Customer_Id__c,DASR_Submit_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAE' and LDC_Account__r.LDC_Account_Number__c = '00040621040044404' limit 1];
        dasrReqGAAE = [select Id,DASR_Type__c,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Supplier_ID__c,Vendor_Id__c,Customer_Id__c,DASR_Submit_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAE' and LDC_Account__r.LDC_Account_Number__c = '00040621040044444' limit 1];
        dasrReqGAAE2 = [select Id,DASR_Type__c,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Supplier_ID__c,Vendor_Id__c,Customer_Id__c,DASR_Submit_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAE' and LDC_Account__r.LDC_Account_Number__c = '00040621044444444' limit 1];
        dasrReqGAAC = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '00040621040044404' and Bill_Method__c='rate ready' limit 1];
        dasrReqGAACacc = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '00040621040044404' and Bill_Method__c='bill ready' limit 1];
        dasrReqGAACacc4 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '40040621040044404' and Bill_Method__c='DUAL' limit 1];
        dasrReqGAACacc4rr = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '40040621040044404' and Bill_Method__c='rate ready' limit 1];
        dasrReqGAACacc5 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '50040621040044404' and Bill_Method__c='DUAL' limit 1];
        dasrReqGAACacc5br = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '50040621040044404' and Bill_Method__c='bill ready' limit 1];
        dasrReqGAAC1 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '00040621040044404' and Change_Reason__c ='Change Service Indicator (Summary or Detail Interval Data)' limit 1];
        dasrReqGAAC2 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '00040621040044404' and Change_Reason__c ='Change ESP Rate Code' limit 1];
        dasrReqGAAC3 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '00040621040044404' and Change_Reason__c ='Change Aggregation Category' limit 1];
        dasrReqGAAC4 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '00040621040044404' and Change_Reason__c ='Test Change Reason' limit 1];
        dasrReqGAAD = [select Id,Contract_Rate_Code__c,Drop_Date__c,Drop_Reason__c ,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c  from DASR_Request__c where DASR_Type__c ='GAAD' and LDC_Account__r.LDC_Account_Number__c = '00040621040044404' limit 1];
        dasrReqGAAR = [select Id,Contract_Rate_Code__c,Drop_Date__c,Drop_Reason__c ,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c  from DASR_Request__c where DASR_Type__c ='GAAR' and LDC_Account__r.LDC_Account_Number__c = '00040621040044404' limit 1];
        dasrReqGAAR2 = [select Id,Contract_Rate_Code__c,Drop_Date__c,Drop_Reason__c ,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c  from DASR_Request__c where DASR_Type__c ='GAAR' and LDC_Account__r.LDC_Account_Number__c = '00040621040044444' limit 1];
        
        dasrReqIL = [select Id,DASR_Type__c,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Supplier_ID__c,Vendor_Id__c,Customer_Id__c,DASR_Submit_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAE' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' limit 1];
        dasrReqILGAAE = [select Id,DASR_Type__c,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Supplier_ID__c,Vendor_Id__c,Customer_Id__c,DASR_Submit_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAE' and LDC_Account__r.LDC_Account_Number__c = '12040621040044444' limit 1];
        dasrReqILGAAE2 = [select Id,DASR_Type__c,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Supplier_ID__c,Vendor_Id__c,Customer_Id__c,DASR_Submit_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAE' and LDC_Account__r.LDC_Account_Number__c = '12040621044444444' limit 1];
        dasrReqILGAAC = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' and Bill_Method__c='rate ready' limit 1];
        dasrReqILGAACacc = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' and Bill_Method__c='bill ready' limit 1];
        dasrReqILGAACacc4 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '14040621040044404' and Bill_Method__c='DUAL' limit 1];
        dasrReqILGAACacc4rr = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '14040621040044404' and Bill_Method__c='rate ready' limit 1];
        dasrReqILGAACacc5 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '15040621040044404' and Bill_Method__c='DUAL' limit 1];
        dasrReqILGAACacc5br = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '15040621040044404' and Bill_Method__c='bill ready' limit 1];
        dasrReqILGAAC1 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' and Change_Reason__c ='Change Service Indicator (Summary or Detail Interval Data)' limit 1];
        dasrReqILGAAC2 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' and Change_Reason__c ='Change ESP Rate Code' and service_point__c = null limit 1];
        dasrReqILGAAC2a = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' and Change_Reason__c ='Change ESP Rate Code' and service_point__c != null limit 1];
        dasrReqILGAAC3 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' and Change_Reason__c ='Change Aggregation Category' limit 1];
        dasrReqILGAAC4 = [select Id,Contract_Rate_Code__c,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c from DASR_Request__c where DASR_Type__c ='GAAC' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' and Change_Reason__c ='Test Change Reason' limit 1];
        dasrReqILGAAD = [select Id,Contract_Rate_Code__c,Drop_Date__c,Drop_Reason__c ,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c  from DASR_Request__c where DASR_Type__c ='GAAD' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' limit 1];
        dasrReqILGAAD2 = [select Id,Contract_Rate_Code__c,Drop_Date__c,Drop_Reason__c ,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c,Drop_Reason_Description__c  from DASR_Request__c where DASR_Type__c ='GAAD' and LDC_Account__r.LDC_Account_Number__c = '16040621040044404' limit 1];
        dasrReqILGAAR = [select Id,Contract_Rate_Code__c,Drop_Date__c,Drop_Reason__c ,Originator_Name__c,Recipient_Name__c,Recipient_DUNS__c,Contract__c,LDC_Account__c,Vendor_Id__c,Supplier_ID__c,Customer_Id__c,DASR_Type__c,DASR_Submit_Date__c,Contract_End_Date__c,Change_Effective_Date__c,Bill_Method__c,Change_Reason__c,Interval_Usage__c,Contract_Bill_Method__c,Contract_Counter_Signed_Date__c,OFF_Cycle_Enrollment__c,Service_Point__c  from DASR_Request__c where DASR_Type__c ='GAAR' and LDC_Account__r.LDC_Account_Number__c = '12040621040044404' limit 1];
        lDasr.add(dasrReq);
        lDasr.add(dasrReqGAAE);
        lDasr.add(dasrReqGAAE2);
        lDasr.add(dasrReqGAAC);
        lDasr.add(dasrReqGAACacc);
        lDasr.add(dasrReqGAACacc4);
        lDasr.add(dasrReqGAACacc4rr);
        lDasr.add(dasrReqGAACacc5);
        lDasr.add(dasrReqGAACacc5br);
        lDasr.add(dasrReqGAAC1);
        lDasr.add(dasrReqGAAC2);
        lDasr.add(dasrReqGAAC3);
        lDasr.add(dasrReqGAAC4);
        lDasr.add(dasrReqGAAD);
        lDasr.add(dasrReqGAAR);
        lDasr.add(dasrReqGAAR2);
        lDasr.add(dasrReqIL);
        lDasr.add(dasrReqILGAAE);
        lDasr.add(dasrReqILGAAE2);
        lDasr.add(dasrReqILGAAC);
        lDasr.add(dasrReqILGAACacc);
        lDasr.add(dasrReqILGAACacc4);
        lDasr.add(dasrReqILGAACacc4rr);
        lDasr.add(dasrReqILGAACacc5);
        lDasr.add(dasrReqILGAACacc5br);
        lDasr.add(dasrReqILGAAC1);
        lDasr.add(dasrReqILGAAC2);
        lDasr.add(dasrReqILGAAC2a);
        lDasr.add(dasrReqILGAAC3);
        lDasr.add(dasrReqILGAAC4);
        lDasr.add(dasrReqILGAAD);
        lDasr.add(dasrReqILGAAD2);
        lDasr.add(dasrReqILGAAR);
        
        lacc = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c  from LDC_Account__c where LDC_Account_Number__c = '00040621040044404' limit 1];
        lacc2 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c  from LDC_Account__c where LDC_Account_Number__c = '00040621040044444' limit 1];
        lacc3 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c  from LDC_Account__c where LDC_Account_Number__c = '00040621044444444' limit 1];
        lacc4 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c  from LDC_Account__c where LDC_Account_Number__c = '40040621040044404' limit 1];
        lacc5 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c  from LDC_Account__c where LDC_Account_Number__c = '50040621040044404' limit 1];
        
        laccIL1 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c,LDC_Account_Status__c,CRM_Id__c  from LDC_Account__c where LDC_Account_Number__c = '12040621040044404' limit 1];
        laccIL2 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c,LDC_Account_Status__c,CRM_Id__c   from LDC_Account__c where LDC_Account_Number__c = '12040621040044444' limit 1];
        laccIL3 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c,LDC_Account_Status__c,CRM_Id__c   from LDC_Account__c where LDC_Account_Number__c = '12040621044444444' limit 1];
        laccIL4 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c,LDC_Account_Status__c,CRM_Id__c   from LDC_Account__c where LDC_Account_Number__c = '14040621040044404' limit 1];
        laccIL5 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c,LDC_Account_Status__c,CRM_Id__c   from LDC_Account__c where LDC_Account_Number__c = '15040621040044404' limit 1];
        laccIL6 = [select Id,Commodity__c,Interval_Usage__c,Bill_Method__c,LDC_Account_Number__c,Service_Street_1__c, Service_Street_2__c ,Service_State__c ,Service_City__c ,Service_Postal_Code__c,LDC_Account_Status__c,CRM_Id__c   from LDC_Account__c where LDC_Account_Number__c = '16040621040044404' limit 1];
        Map<Id,LDC_Account__c> mapLDC = new Map<Id,LDC_Account__c>();
        mapLDC.put(lacc.Id, lacc);
        mapLDC.put(lacc2.Id, lacc2);
        mapLDC.put(lacc3.Id, lacc3);
        mapLDC.put(lacc4.Id, lacc4);
        mapLDC.put(lacc5.Id, lacc5);
        mapLDC.put(laccIL1.Id, laccIL1);
        mapLDC.put(laccIL2.Id, laccIL2);
        mapLDC.put(laccIL3.Id, laccIL3);
        mapLDC.put(laccIL4.Id, laccIL4);
        mapLDC.put(laccIL5.Id, laccIL5);
        mapLDC.put(laccIL6.Id, laccIL6);
        
        ct = [select Id,Interval_Usage__c,Bill_Method__c from Contract limit 1];
        Map<Id, Contract> mapContract = new Map<Id, Contract>();
        mapContract.put(ct.Id, ct);
        
        supplier = [select Id,Supplier_DUNS__c,Name,Master_DUNS__c from Supplier__c limit 1];
        
        Map<Id, Supplier__c> mapSuppl= new Map<Id, Supplier__c>();
        mapSuppl.put(supplier.Id, supplier);
        
        ldcvendor = [select Id,Name,Service_Territory__c,Service_State__c,DUNS__c,Utility_Code__c from LDC_Vendor__c where Name='Test Vendor' limit 1];
        ldcvendor2 = [select Id,Name,Service_Territory__c,Service_State__c,DUNS__c,Utility_Code__c from LDC_Vendor__c where Name='Ohio Power Test' limit 1];
        ldcvendor3 = [select Id,Name,Service_Territory__c,Service_State__c,DUNS__c,Utility_Code__c from LDC_Vendor__c where Name='Ohio Power Test2' limit 1];
        ldcvendorIL1 = [select Id,Name,Service_Territory__c,Service_State__c,DUNS__c,Utility_Code__c from LDC_Vendor__c where Name='Test Vendor IL' limit 1];
        ldcvendorIL2 = [select Id,Name,Service_Territory__c,Service_State__c,DUNS__c,Utility_Code__c from LDC_Vendor__c where Name='Ohio Power Test IL' limit 1];
        ldcvendorIL3 = [select Id,Name,Service_Territory__c,Service_State__c,DUNS__c,Utility_Code__c from LDC_Vendor__c where Name='Ohio Power Test2 IL' limit 1];
        Map<Id, LDC_Vendor__c> mapVend = new Map<Id, LDC_Vendor__c>();
        mapVend.put(ldcvendor.Id, ldcvendor);
        mapVend.put(ldcvendor2.Id, ldcvendor2);
        mapVend.put(ldcvendor3.Id, ldcvendor3);
        mapVend.put(ldcvendorIL1.Id, ldcvendorIL1);
        mapVend.put(ldcvendorIL2.Id, ldcvendorIL2);
        mapVend.put(ldcvendorIL3.Id, ldcvendorIL3);
        
        cTerm = [select Id from Contract_Term__c];
        
        acc = [select Id,Muni_Agg_Type__c,Name,Aggregator_Code__c ,Business_Account__r.Aggregator_Code__c,BillingState,BillingCountry, BillingStreet, BillingCity,BillingPostalCode from Account limit 1];
        sp = [select Id from Service_Point__c limit 1];
        meter = [select Id from Meter__c limit 1];
        Map<Id,List<Meter__c>> mapMeter = new Map<Id,List<Meter__c>>();
        List<Meter__c> meterList = new List<Meter__c>();
        meterList.add(meter);
        mapMeter.put(lacc.Id, meterList);
        
        
        Map<Id,Account> mapCust = new Map<Id,Account>();
        mapCust.put(acc.Id, acc);
        EDIOutboundHelper.getAcctByTran(dasrReq, lacc, supplier, ldcvendor, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqGAAE, lacc2, supplier, ldcvendor2, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqGAAE2, lacc3, supplier, ldcvendor3, meterList, acc, ct, null);   
        EDIOutboundHelper.getAcctByTran(dasrReqGAAC, lacc, supplier, ldcvendor, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqGAACacc, lacc, supplier, ldcvendor, meterList, acc, ct, null);  
        EDIOutboundHelper.getAcctByTran(dasrReqGAACacc4, lacc, supplier, ldcvendor, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqGAACacc4rr, lacc, supplier, ldcvendor, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqGAACacc5, lacc, supplier, ldcvendor, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqGAACacc5br, lacc, supplier, ldcvendor, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqGAAC1, lacc, supplier, ldcvendor, meterList, acc, ct, null);   
        EDIOutboundHelper.getAcctByTran(dasrReqGAAC2, lacc, supplier, ldcvendor, meterList, acc, ct, null);  
        EDIOutboundHelper.getAcctByTran(dasrReqGAAC3, lacc, supplier, ldcvendor, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqGAAC4, lacc, supplier, ldcvendor, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqGAAD, lacc, supplier, ldcvendor, meterList, acc, ct, null);   
        
        EDIOutboundHelper.getAcctExcByTran(dasrReq, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAE, lacc2, supplier, ldcvendor2, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAE2, lacc3, supplier, ldcvendor3, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAACacc, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAACacc4, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAACacc4rr, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAACacc5, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAACacc5br, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC1, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC2, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC3, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC4, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAD, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        
        EDIOutboundHelper.getMeterByTran(dasrReq, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAE, lacc2, supplier, ldcvendor2, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAE2, lacc3, supplier, ldcvendor3, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc4, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc4rr, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc5, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc5br, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC1, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC2, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC3, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC3, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc4, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc4rr, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc5, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAACacc5br, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC1, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC2, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC3, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAC4, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqGAAD, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        
        EDIOutboundHelper.getMeterExcByTran(dasrReq, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAE, lacc2, supplier, ldcvendor2, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAE2, lacc3, supplier, ldcvendor3, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc4, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc4rr, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc5, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc5br, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC1, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC2, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC3, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC4, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc4, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc4rr, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc5, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAACacc5br, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC1, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC2, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC3, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAC4, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqGAAD, lacc, supplier, ldcvendor, meterList, acc, ct, null); 
        
        /****************************************** IL Test Data  ***************************************************/
        EDIOutboundHelper.getAcctByTran(dasrReqIL, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqILGAAE, laccIL2, supplier, ldcvendorIL2, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqILGAAE2, laccIL3, supplier, ldcvendorIL3, meterList, acc, ct, null);   
        EDIOutboundHelper.getAcctByTran(dasrReqILGAAC, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqILGAACacc, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);  
        EDIOutboundHelper.getAcctByTran(dasrReqILGAACacc4, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqILGAACacc4rr, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqILGAACacc5, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqILGAACacc5br, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqILGAAC1, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);   
        EDIOutboundHelper.getAcctByTran(dasrReqILGAAC2, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);  
        EDIOutboundHelper.getAcctByTran(dasrReqILGAAC3, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqILGAAC4, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null); 
        EDIOutboundHelper.getAcctByTran(dasrReqILGAAD, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);   
        
        EDIOutboundHelper.getAcctExcByTran(dasrReqIL, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAE, laccIL2, supplier, ldcvendorIL2, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAE2, laccIL3, supplier, ldcvendorIL3, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAACacc, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAACacc4, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAACacc4rr, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAACacc5, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAACacc5br, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC1, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC2, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC3, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC4, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAD, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        
        EDIOutboundHelper.getMeterByTran(dasrReqIL, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAE, laccIL2, supplier, ldcvendorIL2, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAE2, laccIL3, supplier, ldcvendorIL3, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc4, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc4rr, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc5, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc5br, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC1, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC2, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC3, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC3, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc4, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc4rr, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc5, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAACacc5br, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC1, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC2, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC3, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAC4, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterByTran(dasrReqILGAAD, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        
        EDIOutboundHelper.getMeterExcByTran(dasrReqIL, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAE, laccIL2, supplier, ldcvendorIL2, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAE2, lacc3, supplier, ldcvendorIL3, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc4, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc4rr, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc5, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc5br, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC1, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC2, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC3, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC4, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc4, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc4rr, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc5, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAACacc5br, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC1, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC2, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC3, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAC4, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getMeterExcByTran(dasrReqILGAAD, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null); 
               
        EDIOutboundHelper.getDocInfo('123', '20160101', '0001', '8888', 'Test-1', '999', 'DUKE');
        EDIOutboundHelper.getTrailer('123',1,1);
        
        EDIOutboundHelper.sendDASRUpdates(lDasr, mapLDC, mapSuppl, mapVend, mapMeter, mapCust, mapContract, null, 10, 1);
        
        ct.Bill_Method__c = 'DUAL';
        update ct;
        
        lacc.Bill_Method__c ='Rate Ready';
        update lacc;
        
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC1, lacc, supplier, ldcvendor, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC2, lacc, supplier, ldcvendor, meterList, acc, ct, null);

        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC1, lacc, supplier, ldcvendor, null, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqGAAC2, lacc, supplier, ldcvendor, null, acc, ct, null);
        
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC1, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC2, laccIL1, supplier, ldcvendorIL1, meterList, acc, ct, null);

        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC1, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        EDIOutboundHelper.getAcctExcByTran(dasrReqILGAAC2, laccIL1, supplier, ldcvendorIL1, null, acc, ct, null);
        
    }
}