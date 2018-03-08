/**
 * @version 1.0
 * @version 1.1 - Prasad - Modified for code coverage
 **/
 
@IsTest
global class EDIOutBoundProcesBatch_Test 
{
    static Account acc;
    static Opportunity opp;
    static LDC_Account__c lacc;
    static LDC_Account__c lacc2;
    static LDC_Account__c lacc3;
    static LDC_Account__c laccIL1;
    static LDC_Account__c laccIL2;
    static LDC_Account__c laccIL3;
    static Contract ct;
    static Contract ct2;
    static Contract_Term__c cTerm;
    static LDC_Vendor__c ldcvendor;
    static LDC_Vendor__c ldcvendorIL;
    static Supplier__c supplier;
    static DASR_Request__c dasrReqGAAE;
    static DASR_Request__c dasrReqGAAE2;
    static DASR_Request__c dasrReqGAAC;
    static DASR_Request__c dasrReqGAAC2;
    static DASR_Request__c dasrReqGAAD;
    static DASR_Request__c dasrReqGAAD2;
    static DASR_Request__c dasrReqGAAR;
    static DASR_Request__c dasrReqGAAR2;
    static DASR_Request__c dasrReqILGAAE;
    static DASR_Request__c dasrReqILGAAE2;
    static DASR_Request__c dasrReqILGAAC;
    static DASR_Request__c dasrReqILGAAC2;
    static DASR_Request__c dasrReqILGAAD;
    static DASR_Request__c dasrReqILGAAD2;
    static DASR_Request__c dasrReqILGAAR;
    static DASR_Request__c dasrReqILGAAR2;
    static Contract_LDC__c contractLDC;
    static Service_Point__c sp;
    static Meter__c meter;
    static Bill_Method__c bm;
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
        
        ldcvendor=new LDC_Vendor__c(Name='Test Vendor',Service_Territory__c='DAYTON',DUNS__c='123',Utility_Code__c='1234',Service_State__c='OH');
        Insert ldcvendor;
        ldcvendorIL=new LDC_Vendor__c(Name='Test Vendor IL',Service_Territory__c='Ameren-IL',DUNS__c='123',Utility_Code__c='1234',Service_State__c='IL');
        Insert ldcvendorIL;
        
        lacc = new LDC_Account__c();
        lacc.name  ='Test LDC acc';
        lacc.Account__c = acc.id;
        lacc.LDC_Account_Number__c = '00040621040044404';
        lacc.Service_Territory__c='DAYTON';
        lacc.LDC_Vendor__c = ldcvendor.id;
        insert lacc;
        
        lacc2 = new LDC_Account__c();
        lacc2.name  ='Test LDC acc2';
        lacc2.Account__c = acc.id;
        lacc2.LDC_Account_Number__c = '00040621040044444';
        lacc2.Service_Territory__c='DAYTON';
        //lacc2.LDC_Vendor__c = ldcvendor.id;
        insert lacc2;
        
        lacc3 = new LDC_Account__c();
        lacc3.name  ='Test LDC acc3';
        lacc3.Account__c = acc.id;
        lacc3.LDC_Account_Number__c = '00040621044444444';
        lacc3.Service_Territory__c='DAYTON';
        lacc3.LDC_Vendor__c = ldcvendor.id;
        insert lacc3;
        
        laccIL1 = new LDC_Account__c();
        laccIL1.name  ='Test LDC acc IL1';
        laccIL1.Account__c = acc.id;
        laccIL1.LDC_Account_Number__c = '12040621040044404';
        laccIL1.Service_Territory__c='DAYTON';
        laccIL1.LDC_Vendor__c = ldcvendor.id;
        insert laccIL1;
        
        laccIL2 = new LDC_Account__c();
        laccIL2.name  ='Test LDC acc IL2';
        laccIL2.Account__c = acc.id;
        laccIL2.LDC_Account_Number__c = '12040621040044444';
        laccIL2.Service_Territory__c='DAYTON';
        //laccIL2.LDC_Vendor__c = ldcvendor.id;
        insert laccIL2;
        
        laccIL3 = new LDC_Account__c();
        laccIL3.name  ='Test LDC acc IL3';
        laccIL3.Account__c = acc.id;
        laccIL3.LDC_Account_Number__c = '12040621044444444';
        laccIL3.Service_Territory__c='DAYTON';
        laccIL3.LDC_Vendor__c = ldcvendor.id;
        insert laccIL3;
        
        bm = new Bill_Method__c(Name = 'DUAL',Bill_Calculator__c = 'DUAL',Bill_Presenter__c = 'DUAL');
        insert bm;
        
        ct=new Contract(Name='Test Contract',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM01', Bill_Method__c ='DUAL', Interval_Usage__c ='Summary',Contract_Counter_Signed_Date__c=date.today());
        Insert ct;
        
        ct2=new Contract(Name='Test Contract2',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM02', Bill_Method__c ='UCB', Interval_Usage__c ='Summary',Contract_Counter_Signed_Date__c=null);
        Insert ct2;
        
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
        
        dasrReqGAAE = new DASR_Request__c();
        dasrReqGAAE.DASR_Type__c  ='GAAE';
        dasrReqGAAE.Contract__c = ct.Id;
        dasrReqGAAE.DASR_Submit_Date__c = System.today();
        dasrReqGAAE.LDC_Account__c = lacc.Id;
        dasrReqGAAE.Dynegy_Initiated__c = true;
        dasrReqGAAE.Billing_Entity__c='Dynegy';
        
        dasrReqGAAE2 = new DASR_Request__c();
        dasrReqGAAE2.DASR_Type__c  ='GAAE';
        dasrReqGAAE2.Contract__c = ct2.Id;
        dasrReqGAAE2.DASR_Submit_Date__c = System.today();
        //dasrReqGAAE2.LDC_Account__c = lacc2.Id;
        dasrReqGAAE2.Dynegy_Initiated__c = true;
        dasrReqGAAE2.Billing_Entity__c='Dynegy';

        dasrReqGAAC = new DASR_Request__c();
        dasrReqGAAC.DASR_Type__c  ='GAAC';
        dasrReqGAAC.Contract__c = ct.Id;
        dasrReqGAAC.DASR_Submit_Date__c = System.today();
        dasrReqGAAC.Dynegy_Initiated__c = true;
        dasrReqGAAC.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAAC.Bill_Method__c ='Rate Ready';
        dasrReqGAAC.LDC_Account__c = lacc.Id;
        dasrReqGAAC.Billing_Entity__c='Dynegy';
        
        dasrReqGAAC2 = new DASR_Request__c();
        dasrReqGAAC2.DASR_Type__c  ='GAAC';
        dasrReqGAAC2.Contract__c = ct2.Id;
        dasrReqGAAC2.DASR_Submit_Date__c = System.today();
        dasrReqGAAC2.Dynegy_Initiated__c = true;
        //dasrReqGAAC2.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAAC2.Bill_Method__c ='Rate Ready';
        //dasrReqGAAC2.LDC_Account__c = lacc2.Id;
        dasrReqGAAC2.Billing_Entity__c='Dynegy';
        
        dasrReqGAAD = new DASR_Request__c();
        dasrReqGAAD.DASR_Type__c  ='GAAD';
        dasrReqGAAD.Contract__c = ct.Id;
        dasrReqGAAD.DASR_Submit_Date__c = System.today();
        dasrReqGAAD.Drop_Date__c  = System.today();
        dasrReqGAAD.Drop_Reason__c ='Contract Expired';
        dasrReqGAAD.Dynegy_Initiated__c = true;
        dasrReqGAAD.LDC_Account__c = lacc.Id;
        dasrReqGAAD.Billing_Entity__c='Dynegy';
        
        dasrReqGAAD2 = new DASR_Request__c();
        dasrReqGAAD2.DASR_Type__c  ='GAAD';
        dasrReqGAAD2.Contract__c = ct2.Id;
        dasrReqGAAD2.DASR_Submit_Date__c = System.today();
        dasrReqGAAD2.Drop_Date__c  = System.today();
        dasrReqGAAD2.Drop_Reason__c ='Contract Expired';
        dasrReqGAAD2.Dynegy_Initiated__c = true;
        //dasrReqGAAD2.LDC_Account__c = lacc2.Id;
        dasrReqGAAD2.Billing_Entity__c='Dynegy';
        
        dasrReqGAAR = new DASR_Request__c();
        dasrReqGAAR.DASR_Type__c  ='GAAR';
        dasrReqGAAR.Contract__c = ct.Id;
        dasrReqGAAR.DASR_Submit_Date__c = System.today();
        dasrReqGAAR.Dynegy_Initiated__c = true;
        dasrReqGAAR.LDC_Account__c = lacc.Id;
        dasrReqGAAR.Billing_Entity__c='Dynegy';
        
        dasrReqGAAR2 = new DASR_Request__c();
        dasrReqGAAR2.DASR_Type__c  ='GAAR';
        dasrReqGAAR2.Contract__c = ct.Id;
        dasrReqGAAR2.DASR_Submit_Date__c = System.today();
        dasrReqGAAR2.Dynegy_Initiated__c = false;
        dasrReqGAAR2.LDC_Account__c = lacc3.Id;
        dasrReqGAAR2.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAE = new DASR_Request__c();
        dasrReqILGAAE.DASR_Type__c  ='GAAE';
        dasrReqILGAAE.Contract__c = ct.Id;
        dasrReqILGAAE.DASR_Submit_Date__c = System.today();
        dasrReqILGAAE.LDC_Account__c = laccIL1.Id;
        dasrReqILGAAE.Dynegy_Initiated__c = true;
        dasrReqILGAAE.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAE2 = new DASR_Request__c();
        dasrReqILGAAE2.DASR_Type__c  ='GAAE';
        dasrReqILGAAE2.Contract__c = ct2.Id;
        dasrReqILGAAE2.DASR_Submit_Date__c = System.today();
        //dasrReqILGAAE2.LDC_Account__c = lacc2.Id;
        dasrReqILGAAE2.Dynegy_Initiated__c = true;
        dasrReqILGAAE2.Billing_Entity__c='Dynegy';

        dasrReqILGAAC = new DASR_Request__c();
        dasrReqILGAAC.DASR_Type__c  ='GAAC';
        dasrReqILGAAC.Contract__c = ct.Id;
        dasrReqILGAAC.DASR_Submit_Date__c = System.today();
        dasrReqILGAAC.Dynegy_Initiated__c = true;
        dasrReqILGAAC.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqILGAAC.Bill_Method__c ='Rate Ready';
        dasrReqILGAAC.LDC_Account__c = laccIL1.Id;
        dasrReqILGAAC.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAC2 = new DASR_Request__c();
        dasrReqILGAAC2.DASR_Type__c  ='GAAC';
        dasrReqILGAAC2.Contract__c = ct2.Id;
        dasrReqILGAAC2.DASR_Submit_Date__c = System.today();
        dasrReqILGAAC2.Dynegy_Initiated__c = true;
        //dasrReqILGAAC2.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqILGAAC2.Bill_Method__c ='Rate Ready';
        //dasrReqILGAAC2.LDC_Account__c = lacc2.Id;
        dasrReqILGAAC2.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAD = new DASR_Request__c();
        dasrReqILGAAD.DASR_Type__c  ='GAAD';
        dasrReqILGAAD.Contract__c = ct.Id;
        dasrReqILGAAD.DASR_Submit_Date__c = System.today();
        dasrReqILGAAD.Drop_Date__c  = System.today();
        dasrReqILGAAD.Drop_Reason__c ='Contract Expired';
        dasrReqILGAAD.Dynegy_Initiated__c = true;
        dasrReqILGAAD.LDC_Account__c = laccIL1.Id;
        dasrReqILGAAD.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAD2 = new DASR_Request__c();
        dasrReqILGAAD2.DASR_Type__c  ='GAAD';
        dasrReqILGAAD2.Contract__c = ct2.Id;
        dasrReqILGAAD2.DASR_Submit_Date__c = System.today();
        dasrReqILGAAD2.Drop_Date__c  = System.today();
        dasrReqILGAAD2.Drop_Reason__c ='Contract Expired';
        dasrReqILGAAD2.Dynegy_Initiated__c = true;
        //dasrReqILGAAD2.LDC_Account__c = lacc2.Id;
        dasrReqILGAAD2.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAR = new DASR_Request__c();
        dasrReqILGAAR.DASR_Type__c  ='GAAR';
        dasrReqILGAAR.Contract__c = ct.Id;
        dasrReqILGAAR.DASR_Submit_Date__c = System.today();
        dasrReqILGAAR.Dynegy_Initiated__c = true;
        dasrReqILGAAR.LDC_Account__c = laccIL1.Id;
        dasrReqILGAAR.Billing_Entity__c='Dynegy';
        
        dasrReqILGAAR2 = new DASR_Request__c();
        dasrReqILGAAR2.DASR_Type__c  ='GAAR';
        dasrReqILGAAR2.Contract__c = ct.Id;
        dasrReqILGAAR2.DASR_Submit_Date__c = System.today();
        dasrReqILGAAR2.Dynegy_Initiated__c = false;
        dasrReqILGAAR2.LDC_Account__c = laccIL3.Id;
        dasrReqILGAAR2.Billing_Entity__c='Dynegy';
        
        insert new List<DASR_Request__c>{dasrReqGAAE,dasrReqGAAE2,dasrReqGAAC,dasrReqGAAC2,dasrReqGAAD,dasrReqGAAD2,dasrReqGAAR,dasrReqGAAR2,dasrReqILGAAE,dasrReqILGAAE2,dasrReqILGAAC,dasrReqILGAAC2,dasrReqILGAAD,dasrReqILGAAD2,dasrReqILGAAR,dasrReqILGAAR2};
        
        EDIIntegrationConfiguration__c config = new EDIIntegrationConfiguration__c(name ='Default',Notify_Email__c='anands1775@gmail.com',User_Name__c='dynsfdev', Password__c='u7SBbSIG',EDI_Outbound_End_Point__c='https://salesforcetest.dynegy.com/SforceESG.svc/SforceESG',Interval_Request_Code__c='N',Default_Meter_Number__c='ALL',Recipient_Name__c='ESG',Receipient_DUNS__c='049050839');
        insert config;
    }
    @IsTest static void testBatch() 
    {
        Test.setMock(WebServiceMock.class, new DynegyEDIMockImpl());
        EDIOutBoundProcesBatch batch = new EDIOutBoundProcesBatch();
        Database.executeBatch(batch);
    }
    @IsTest static void testBatchWithDASRIds() 
    {
        ct = [select id from contract where name='Test Contract'];
        dasrReqGAAE = [select Id from DASR_Request__c where DASR_Type__c ='GAAE' and contract__c =:ct.id limit 1];
        Test.setMock(WebServiceMock.class, new DynegyEDIMockImpl());
        EDIOutBoundProcesBatch batch = new EDIOutBoundProcesBatch(new set<Id>{dasrReqGAAE.Id});
        EDIOutBoundProcesBatch.populateRespnse(new List<DASR_Request__c>{dasrReqGAAE}, 'DONE');
        Database.executeBatch(batch);
    }
    
    global class DynegyEDIMockImpl implements WebServiceMock {
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
        dynegyComEDIServices.Submit_ESG_GAA_RequestResponse_element respElement = new dynegyComEDIServices.Submit_ESG_GAA_RequestResponse_element();
        //respElement.GetLstarErrorsResult.Errors.LstarError.ErrorMsg 
        respElement.Submit_ESG_GAA_RequestResult = 'Done';
        response.put('response_x', respElement); 
       }
     } 
}