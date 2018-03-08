@Istest
private class EDITransformationUtil_Test 
{
    static Account acc;
    static Opportunity opp;
    static LDC_Account__c lacc;
    static Contract ct;
    static LDC_Vendor__c ldcvendor;
    static Supplier__c supplier;
    static DASR_Request__c dasrReq;
    static DASR_Request__c dasrReqGAAC;
    static DASR_Request__c dasrReqGAAD;
    static Contract_LDC__c contractLDC;
    static Service_Point__c sp;
    static Meter__c meter;
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
        insert lacc;
        
        
        ct=new Contract(Name='Test Contract',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM01', Bill_Method__c ='DUAL', Interval_Usage__c ='Summary');
        
        Insert ct;
        
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
        dasrReq.Billing_Entity__c='Dynegy';
        insert dasrReq;
        
        dasrReqGAAC = new DASR_Request__c();
        dasrReqGAAC.DASR_Type__c  ='GAAC';
        dasrReqGAAC.Contract__c = ct.Id;
        dasrReqGAAC.DASR_Submit_Date__c = System.today();
        dasrReqGAAC.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAAC.Bill_Method__c ='Rate Ready';
        dasrReqGAAC.LDC_Account__c = lacc.Id;
        dasrReqGAAC.Billing_Entity__c='Dynegy';
        insert dasrReqGAAC;
        
        dasrReqGAAD = new DASR_Request__c();
        dasrReqGAAD.DASR_Type__c  ='GAAD';
        dasrReqGAAD.Contract__c = ct.Id;
        dasrReqGAAD.DASR_Submit_Date__c = System.today();
        dasrReqGAAD.Drop_Date__c  = System.today();
        dasrReqGAAD.Drop_Reason__c ='Contract Expired';
        dasrReqGAAD.LDC_Account__c = lacc.Id;
        dasrReqGAAD.Billing_Entity__c='Dynegy';
        insert dasrReqGAAD;
        
        EDIIntegrationConfiguration__c config = new EDIIntegrationConfiguration__c(name ='Default',Notify_Email__c='anands1775@gmail.com',User_Name__c='dynsfdev', Password__c='u7SBbSIG',EDI_Outbound_End_Point__c='https://salesforcetest.dynegy.com/SforceESG.svc/SforceESG',Interval_Request_Code__c='N',Default_Meter_Number__c='ALL',Recipient_Name__c='ESG',Receipient_DUNS__c='049050839');
        insert config;
    }
    @testSetup static void setupDataCS() 
    {
        State_Country__c sc = new State_Country__c();
        sc.name = 'Nevada';
        sc.Value__c = 'Nevada';
        sc.Country__c = 'United States';
        sc.Code__c  = 'NV';
        insert sc;
    }
    @IsTest private static void testTransformUtil()
    {
        EDITransformationUtil.convCommodityCodeToVal('E');
        EDITransformationUtil.convCommodityCodeToVal(null);
        EDITransformationUtil.convCommodityCodeToVal('G');
        EDITransformationUtil.convCommodityValToCode('Electric');
        EDITransformationUtil.convCommodityValToCode(null);
        EDITransformationUtil.convCommodityValToCode('Gas');
        EDITransformationUtil.convStateValToCode('Nevada');
        EDITransformationUtil.convStateValToCode(null);
        EDITransformationUtil.convStateValToCode('NV');
        EDITransformationUtil.convUsageCodeToVal('N');
        EDITransformationUtil.convUsageCodeToVal('Y');
        EDITransformationUtil.convUsageCodeToVal(null);
        EDITransformationUtil.convUsageValToCode('Interval');
        EDITransformationUtil.convUsageValToCode('Summary');
        EDITransformationUtil.convUsageValToCode(null);
        EDITransformationUtil.convUSAValToCode('United States');
        EDITransformationUtil.convUSAValToCode(null);
        EDITransformationUtil.convUSAValToCode('US');
        
        dasrReq = [select Id,Interval_Usage__c,Change_Reason__c from DASR_Request__c where DASR_Type__c ='GAAE'  limit 1];
        lacc = [select Id,Interval_Usage__c from LDC_Account__c limit 1];
        ct = [select Id,Interval_Usage__c,Bill_Method__c from Contract limit 1];
        EDITransformationUtil.getUsageValue(dasrReq, lacc, null, null, null, null, null, null);
    }
}