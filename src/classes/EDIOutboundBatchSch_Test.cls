@IsTest
private class EDIOutboundBatchSch_Test {
    static Account acc;
    static Opportunity opp;
    static LDC_Account__c lacc;
    static Contract ct;
    static Contract_Term__c cTerm;
    static LDC_Vendor__c ldcvendor;
    static Supplier__c supplier;
    static DASR_Request__c dasrReq;
    static DASR_Request__c dasrReqGAAC;
    static DASR_Request__c dasrReqGAAC1;
    static DASR_Request__c dasrReqGAAC2;
    static DASR_Request__c dasrReqGAAD;
    static DASR_Request__c dasrReqGAAR;
    static Contract_LDC__c contractLDC;
    static Service_Point__c sp;
    static Meter__c meter;
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @testSetup static void setupData() 
    {
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
        
        lacc = new LDC_Account__c();
        lacc.name  ='Test LDC acc';
        lacc.Account__c = acc.id;
        lacc.LDC_Account_Number__c = '00040621040044404';
        lacc.Bill_Method__c ='DUAL';
        lacc.Interval_Usage__c ='Summary';
        insert lacc;
        
        
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
        
        meter = new Meter__c();
        meter.Service_Point__c = sp.Id;
        meter.Meter_Number__c ='ALL';
        insert meter;
        
        ldcvendor=new LDC_Vendor__c(Name='Test Vendor',Service_Territory__c='DAYTON',DUNS__c='123',Utility_Code__c='1234',Service_State__c='OH');
        Insert ldcvendor;
        
        
        dasrReq = new DASR_Request__c();
        dasrReq.DASR_Type__c  ='GAAE';
        dasrReq.Contract__c = ct.Id;
        dasrReq.DASR_Submit_Date__c = System.today();
        dasrReq.LDC_Account__c = lacc.Id;
        dasrReq.Dynegy_Initiated__c = true;
        dasrReq.Billing_Entity__c='Dynegy';
        insert dasrReq;
        
        dasrReqGAAC = new DASR_Request__c();
        dasrReqGAAC.DASR_Type__c  ='GAAC';
        dasrReqGAAC.Contract__c = ct.Id;
        dasrReqGAAC.DASR_Submit_Date__c = System.today();
        dasrReqGAAC.Dynegy_Initiated__c = true;
        dasrReqGAAC.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        //dasrReqGAAC.Bill_Method__c ='Rate Ready';
        dasrReqGAAC.LDC_Account__c = lacc.Id;
        dasrReqGAAC.Billing_Entity__c='Dynegy';

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
        
        insert new List<DASR_Request__c>{dasrReqGAAC,dasrReqGAAC1,dasrReqGAAC2};
        
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
        
        EDIIntegrationConfiguration__c config = new EDIIntegrationConfiguration__c(name ='Default',Notify_Email__c='anands1775@gmail.com',User_Name__c='dynsfdev', Password__c='u7SBbSIG',EDI_Outbound_End_Point__c='https://salesforcetest.dynegy.com/SforceESG.svc/SforceESG',Interval_Request_Code__c='N',Default_Meter_Number__c='ALL',Recipient_Name__c='ESG',Receipient_DUNS__c='049050839');
        insert config;
        
        ChangeReason__c  chngRsn1 = new ChangeReason__c(name='CHA',Reason_Code__c ='CHA',Reason_Value__c ='Customer Changed to another Service Provider');
        ChangeReason__c  chngRsn2 = new ChangeReason__c(name='REF17',Reason_Code__c ='REF17',Reason_Value__c ='Change Service Indicator (Summary or Detail Interval Data)');
        ChangeReason__c  chngRsn3 = new ChangeReason__c(name='REFBLT',Reason_Code__c ='REFBLT ',Reason_Value__c ='Change Billing Type (Billing Option)');
        ChangeReason__c  chngRsn4 = new ChangeReason__c(name='REFRB',Reason_Code__c ='REFRB',Reason_Value__c ='Change ESP Rate Code');
        
        insert new List<ChangeReason__c>{chngRsn1,chngRsn2,chngRsn3,chngRsn4};
        
        Bill_Method__c   billMthd1 = new Bill_Method__c (name='Bill Ready', Bill_Calculator__c ='DUAL',Bill_Presenter__c ='LDC');
        Bill_Method__c   billMthd2 = new Bill_Method__c (name='Rate Ready', Bill_Calculator__c ='LDC',Bill_Presenter__c ='LDC');
        Bill_Method__c   billMthd3 = new Bill_Method__c (name='DUAL', Bill_Calculator__c ='DUAL',Bill_Presenter__c ='DUAL');
        Bill_Method__c   billMthd4 = new Bill_Method__c (name='SBO', Bill_Calculator__c ='DUAL',Bill_Presenter__c ='ESP');
        
        insert new List<Bill_Method__c>{billMthd1,billMthd2,billMthd3,billMthd4};        
        
    }
    @IsTest static void testHelper1() 
    {
        // Schedule the test job
        String jobId = System.schedule('EDIOutboundBatchScheduler',
                                       CRON_EXP, 
                                       new EDIOutboundBatchScheduler());
        
    }
}