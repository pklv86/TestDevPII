/**
 * @version 1.0
 * @version 1.1 - Prasad - Modified for code coverage
 **/

@Istest
private class EDIInboundWebService_Test 
{
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
    static DASR_Request__c dasrReqGAAR;
    static Contract_LDC__c contractLDC;
    static Contract_LDC__c contractLDC1;
    static Contract_LDC__c contractLDC2;
    static Contract_LDC__c contractLDC3;
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
        
        lacc1 = new LDC_Account__c();
        lacc1.name  ='Test LDC acc1';
        lacc1.Account__c = acc.id;
        lacc1.LDC_Account_Number__c = '00040621040044444';
        insert lacc1;
        
        lacc2 = new LDC_Account__c();
        lacc2.name  ='Test LDC acc2';
        lacc2.Account__c = acc.id;
        lacc2.LDC_Account_Number__c = '00040621044444444';
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
        
        ldcvendor=new LDC_Vendor__c(Name='Test Vendor',Service_Territory__c='DAYTON',DUNS__c='123',Utility_Code__c='1234',Service_State__c='OH');
        Insert ldcvendor;
        
        Bill_Method__c bm = new Bill_Method__c(Name='Rate Ready',Bill_Calculator__c='LDC',Bill_Presenter__c='LDC',Payment_Arrangement_Code__c='Y');
        insert bm;        
        
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
        dasrReqGAAE.DASR_Submit_Date__c = System.today();
        dasrReqGAAE.LDC_Account__c = lacc1.Id;
        dasrReqGAAE.Billing_Entity__c='Dynegy';
        insert dasrReqGAAE;
        
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
        
        dasrReqGAAR = new DASR_Request__c();
        dasrReqGAAR.DASR_Type__c  ='GAAR';
        dasrReqGAAR.Contract__c = ct.Id;
        dasrReqGAAR.DASR_Submit_Date__c = System.today();
        dasrReqGAAR.LDC_Account__c = lacc.Id;
        dasrReqGAAR.Billing_Entity__c='Dynegy';
        insert dasrReqGAAR;
        
        EDIIntegrationConfiguration__c config = new EDIIntegrationConfiguration__c(name ='Default',Notify_Email__c='anands1775@gmail.com',User_Name__c='dynsfdev', Password__c='u7SBbSIG',EDI_Outbound_End_Point__c='https://salesforcetest.dynegy.com/SforceESG.svc/SforceESG',Interval_Request_Code__c='N',Default_Meter_Number__c='ALL',Recipient_Name__c='ESG',Receipient_DUNS__c='049050839');
        insert config;
    }
    
    @IsTest private static void testGAAESuccess()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 30;
        trailInfo.Transaction_Count = 3;
        
        Bill_Method__c bm = [select id,name,Bill_Calculator__c,Bill_Presenter__c,Payment_Arrangement_Code__c from Bill_Method__c];
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReq = [select Id from DASR_Request__c where DASR_Type__c ='GAAE'  limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReq.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAE';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '2';
        vTranInfo.Response_Qualifier = '1';
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        vCustInfo.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInfo.City_Name = 'CINCINNATI';
        vCustInfo.State_Province_Code = 'OH';
        vCustInfo.Postal_Code_Zip = '43068';
        vCustInfo.Country_Code = 'US';
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        vCustInfo1.Customer_Name = 'TEST SCENARIO 3';
        vCustInfo1.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInfo1.City_Name = 'CINCINNATI';
        vCustInfo1.State_Province_Code = 'OH';
        vCustInfo1.Postal_Code_Zip = '43068';
        vCustInfo1.Country_Code = 'US';        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.Contract_Effective_Date ='20160229';
        vAcctInfo.Contract_Effective_Time ='0001';
        vAcctInfo.Service_Start_Date ='20160308';
        vAcctInfo.LDC_Bill_Cycle ='12MA';
        vAcctInfo.Capacity_Obligation_Quantity =1.3;
        vAcctInfo.Transmission_Obligation_Quantity =1.2;
        vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity =12;
        vAcctInfo.Peak_Demand_Usage_Quantity =0;
        vAcctInfo.Total_KWH_Quantity =10;
        vAcctInfo.Bill_Presenter ='LDC';
        vAcctInfo.Bill_Calculator='LDC';
        vAcctInfo.SDP_Number = '00040621040044404';
        
        vMetInfo.Sender_Transaction_ID='CSPA725125B119494333';
        vMetInfo.Meter_Number='1234511133';
        vMetInfo.Load_Profile_Description='CCCSRESA';
        vMetInfo.LDC_Rate_Class='013';
        vMetInfo.LDC_Meter_Cycle='12MA';
        vMetInfo.Meter_Type_Code='KHMON';
        vMetInfo.Meter_Multiplier_Quantity=1;
        vMetInfo.Number_Of_Dials_Quantity='5';
        vMetInfo.Time_Of_Use_Metering='51';
        vMetInfo.Meter_Maintenance_Code='MQ';
        vMetInfo.Type_Of_Service_Indicator = 'Indicator';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);

        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);

        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        // SECOND TRANSACTION
        EDIInboundWebService.CTGTransactionInfo vCTInforeq2 = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInforeq2 = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInforeq2 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1req2 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInforeq2 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1req2 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInforeq2 = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInforeq2 = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInforeq2 = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInforeq2 = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAE = [select Id from DASR_Request__c where DASR_Type__c ='GAAE' and id != :dasrReq.id limit 1];
        vTranInforeq2.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInforeq2.Transaction_Date = '20160308';
        vTranInforeq2.Transaction_Time = '04040000';
        vTranInforeq2.Sender_DUNS = '007901739';
        vTranInforeq2.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInforeq2.Receiver_DUNS = '078481476';
        vTranInforeq2.Receiver_Name = 'DYNEGY';
        vTranInforeq2.Originating_Transaction_ID = dasrReqGAAE.Id;
        vTranInforeq2.Line_Transaction_ID = '8020474607';
        vTranInforeq2.Action_ID = 'GAAE';
        vTranInforeq2.Commodity = 'E';
        vTranInforeq2.Transaction_Qualifier = '2';
        vTranInforeq2.Response_Qualifier = '1';
        
        vOrgInforeq2.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInforeq2.Organization_Identifier_Code = 'SJ';
        vOrgInforeq2.Organization_DUNS = '141420484';
        vOrgInforeq2.Organization_Name = 'DYNEGY';
        
        vOrgInfo1req2.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1req2.Organization_Identifier_Code = '8S';
        vOrgInfo1req2.Organization_DUNS = '007901739';
        vOrgInfo1req2.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInforeq2.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInforeq2.Name_Qualifier = '8R';
        vCustInforeq2.Customer_Name = 'TEST SCENARIO 3';
        vCustInforeq2.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInforeq2.City_Name = 'CINCINNATI';
        vCustInforeq2.State_Province_Code = 'OH';
        vCustInforeq2.Postal_Code_Zip = '43068';
        vCustInforeq2.Country_Code = 'US';
        
        vCustInfo1req2.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1req2.Name_Qualifier = 'BT';
        vCustInfo1req2.Contact_Function_Qualifier = 'IC';
        vCustInfo1req2.Customer_Name = 'TEST SCENARIO 3';
        vCustInfo1req2.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInfo1req2.City_Name = 'CINCINNATI';
        vCustInfo1req2.State_Province_Code = 'OH';
        vCustInfo1req2.Postal_Code_Zip = '43068';
        vCustInfo1req2.Country_Code = 'US';        
        
        vAcctInforeq2.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInforeq2.Contract_Effective_Date ='20160229';
        vAcctInforeq2.Contract_Effective_Time ='0001';
        vAcctInforeq2.Service_Start_Date ='20160308';
        vAcctInforeq2.LDC_Bill_Cycle ='12MA';
        vAcctInforeq2.Capacity_Obligation_Quantity =1.3;
        vAcctInforeq2.Transmission_Obligation_Quantity =1.2;
        vAcctInforeq2.Number_Of_Months_Calculated_Usage_Quantity =10;
        vAcctInforeq2.Peak_Demand_Usage_Quantity =0;
        vAcctInforeq2.Total_KWH_Quantity =5655;
        vAcctInforeq2.Bill_Presenter ='LDC';
        vAcctInforeq2.Bill_Calculator='LDC';
        vAcctInforeq2.SDP_Number = '00040621040044444';
        
        vMetInforeq2.Sender_Transaction_ID='CSPA725125B119494333';
        vMetInforeq2.Meter_Number='1234511133';
        vMetInforeq2.Load_Profile_Description='CCCSRESA';
        vMetInforeq2.LDC_Rate_Class='013';
        vMetInforeq2.LDC_Meter_Cycle='12MA';
        vMetInforeq2.Meter_Type_Code='KHMON';
        vMetInforeq2.Meter_Multiplier_Quantity=1;
        vMetInforeq2.Number_Of_Dials_Quantity='5';
        vMetInforeq2.Time_Of_Use_Metering='51';
        vMetInforeq2.Meter_Maintenance_Code='MQ';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInforeq2 = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInforeq2.add(vOrgInforeq2);
        lOrgInforeq2.add(vOrgInfo1req2);

        List<EDIInboundWebService.CustomerInfo> lCustInforeq2 = new List<EDIInboundWebService.CustomerInfo>();
        lCustInforeq2.add(vCustInforeq2);
        lCustInforeq2.add(vCustInfo1req2);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInforeq2 = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInforeq2.add(vAcctExctInforeq2);

        List<EDIInboundWebService.MeterInfo> lMetInforeq2 = new List<EDIInboundWebService.MeterInfo>();
        lMetInforeq2.add(vMetInforeq2);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInforeq2 = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInforeq2.add(vMetExctInforeq2);
        
        vCTInforeq2.Transaction_Info = vTranInforeq2;
        vCTInforeq2.Organization = lOrgInforeq2;
        vCTInforeq2.Customer = lCustInforeq2;
        vCTInforeq2.Account = vAcctInforeq2;
        vCTInforeq2.Account_Exception_Info = lAcctExtInforeq2;
        vCTInforeq2.Meter = lMetInforeq2;
        vCTInforeq2.Meter_Exception_Info = lMetExctInforeq2;
        
         // THIRD TRANSACTION
        EDIInboundWebService.CTGTransactionInfo vCTInforeq3 = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInforeq3 = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInforeq3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1req3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInforeq3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1req3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInforeq3 = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInforeq3 = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInforeq3 = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInforeq3 = new EDIInboundWebService.MeterExceptionInfo();
        
        vTranInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInforeq3.Transaction_Date = '20160308';
        vTranInforeq3.Transaction_Time = '04040000';
        vTranInforeq3.Sender_DUNS = '007901739';
        vTranInforeq3.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInforeq3.Receiver_DUNS = '078481476';
        vTranInforeq3.Receiver_Name = 'DYNEGY';
        vTranInforeq3.Originating_Transaction_ID = 'FH74292HDUI830';
        vTranInforeq3.Line_Transaction_ID = '8020474607';
        vTranInforeq3.Action_ID = 'GAAE';
        vTranInforeq3.Commodity = 'E';
        vTranInforeq3.Transaction_Qualifier = '2';
        vTranInforeq3.Response_Qualifier = '1';
        
        vOrgInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInforeq3.Organization_Identifier_Code = 'SJ';
        vOrgInforeq3.Organization_DUNS = '141420484';
        vOrgInforeq3.Organization_Name = 'DYNEGY';
        
        vOrgInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1req3.Organization_Identifier_Code = '8S';
        vOrgInfo1req3.Organization_DUNS = '007901739';
        vOrgInfo1req3.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInforeq3.Name_Qualifier = '8R';
        vCustInforeq3.Customer_Name = 'TEST SCENARIO 3';
        vCustInforeq3.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInforeq3.City_Name = 'CINCINNATI';
        vCustInforeq3.State_Province_Code = 'OH';
        vCustInforeq3.Postal_Code_Zip = '43068';
        vCustInforeq3.Country_Code = 'US';
        
        vCustInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1req3.Name_Qualifier = 'BT';
        vCustInfo1req3.Contact_Function_Qualifier = 'IC';
        vCustInfo1req3.Customer_Name = 'TEST SCENARIO 3';
        vCustInfo1req3.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInfo1req3.City_Name = 'CINCINNATI';
        vCustInfo1req3.State_Province_Code = 'OH';
        vCustInfo1req3.Postal_Code_Zip = '43068';
        vCustInfo1req3.Country_Code = 'US';        
        
        vAcctInforeq3.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInforeq3.Contract_Effective_Date ='20160229';
        vAcctInforeq3.Contract_Effective_Time ='0001';
        vAcctInforeq3.Service_Start_Date ='20160308';
        vAcctInforeq3.LDC_Bill_Cycle ='12MA';
        vAcctInforeq3.Capacity_Obligation_Quantity =1.3;
        vAcctInforeq3.Transmission_Obligation_Quantity =1.2;
        vAcctInforeq3.Number_Of_Months_Calculated_Usage_Quantity =15;
        vAcctInforeq3.Peak_Demand_Usage_Quantity =0;
        vAcctInforeq3.Total_KWH_Quantity =5751;
        vAcctInforeq3.Bill_Presenter ='LDC';
        vAcctInforeq3.Bill_Calculator='LDC';
        vAcctInforeq3.SDP_Number = '00040621044444444';
        vAcctInforeq3.Payment_Arrangement_Code='Y';
        
        vMetInforeq3.Sender_Transaction_ID='CSPA725125B119494333';
        vMetInforeq3.Meter_Number='1234511133';
        vMetInforeq3.Load_Profile_Description='CCCSRESA';
        vMetInforeq3.LDC_Rate_Class='013';
        vMetInforeq3.LDC_Meter_Cycle='12MA';
        vMetInforeq3.Meter_Type_Code='KHMON';
        vMetInforeq3.Meter_Multiplier_Quantity=1;
        vMetInforeq3.Number_Of_Dials_Quantity='5';
        vMetInforeq3.Time_Of_Use_Metering='51';
        vMetInforeq3.Meter_Maintenance_Code='MQ';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInforeq3 = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInforeq3.add(vOrgInforeq3);
        lOrgInforeq3.add(vOrgInfo1req3);

        List<EDIInboundWebService.CustomerInfo> lCustInforeq3 = new List<EDIInboundWebService.CustomerInfo>();
        lCustInforeq3.add(vCustInforeq3);
        lCustInforeq3.add(vCustInfo1req3);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInforeq3 = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInforeq3.add(vAcctExctInforeq3);

        List<EDIInboundWebService.MeterInfo> lMetInforeq3 = new List<EDIInboundWebService.MeterInfo>();
        lMetInforeq3.add(vMetInforeq3);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInforeq3 = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInforeq3.add(vMetExctInforeq3);
        
        vCTInforeq3.Transaction_Info = vTranInforeq3;
        vCTInforeq3.Organization = lOrgInforeq3;
        vCTInforeq3.Customer = lCustInforeq3;
        vCTInforeq3.Account = vAcctInforeq3;
        vCTInforeq3.Account_Exception_Info = lAcctExtInforeq3;
        vCTInforeq3.Meter = lMetInforeq3;
        vCTInforeq3.Meter_Exception_Info = lMetExctInforeq3;
        
        
        lCInfo.add(vCTInfo);
        lCInfo.add(vCTInforeq2);
        lCInfo.add(vCTInforeq3);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testGAAEFailure()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 20;
        trailInfo.Transaction_Count = 2;
        
        Bill_Method__c bm = [select id,name,Bill_Calculator__c,Bill_Presenter__c,Payment_Arrangement_Code__c from Bill_Method__c];
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReq = [select Id from DASR_Request__c where DASR_Type__c ='GAAE' limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReq.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAE';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '2';
        vTranInfo.Response_Qualifier = '2';
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        vCustInfo.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInfo.City_Name = 'CINCINNATI';
        vCustInfo.State_Province_Code = 'OH';
        vCustInfo.Postal_Code_Zip = '43068';
        vCustInfo.Country_Code = 'US';
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        vCustInfo1.Customer_Name = 'TEST SCENARIO 3';
        vCustInfo1.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInfo1.City_Name = 'CINCINNATI';
        vCustInfo1.State_Province_Code = 'OH';
        vCustInfo1.Postal_Code_Zip = '43068';
        vCustInfo1.Country_Code = 'US';        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.Contract_Effective_Date ='20160229';
        vAcctInfo.Contract_Effective_Time ='0001';
        vAcctInfo.Service_Start_Date ='20160308';
        vAcctInfo.LDC_Bill_Cycle ='12MA';
        vAcctInfo.Capacity_Obligation_Quantity =1.3;
        vAcctInfo.Transmission_Obligation_Quantity =1.2;
        vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity =0;
        vAcctInfo.Peak_Demand_Usage_Quantity =0;
        vAcctInfo.Total_KWH_Quantity =0;
        vAcctInfo.Bill_Presenter ='LDC';
        vAcctInfo.Bill_Calculator='LDC';
        vAcctInfo.SDP_Number = '00040621040044404';
        
        vMetInfo.Sender_Transaction_ID='CSPA725125B119494333';
        vMetInfo.Meter_Number='1234511133';
        vMetInfo.Load_Profile_Description='CCCSRESA';
        vMetInfo.LDC_Rate_Class='013';
        vMetInfo.LDC_Meter_Cycle='12MA';
        vMetInfo.Meter_Type_Code='KHMON';
        vMetInfo.Meter_Multiplier_Quantity=1;
        vMetInfo.Number_Of_Dials_Quantity='5';
        vMetInfo.Time_Of_Use_Metering='51';
        vMetInfo.Meter_Maintenance_Code='MQ';
        
        vAcctExctInfo.Sender_Transaction_ID= 'CSPA725125B119494333';
        vAcctExctInfo.Reason_Code= 'A76';
        vAcctExctInfo.Reason_Description= 'Account not found or invalid';
        vAcctExctInfo.Exception_Type_Code= 'RJ';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
         // SECOND TRANSACTION
        EDIInboundWebService.CTGTransactionInfo vCTInforeq3 = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInforeq3 = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInforeq3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1req3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInforeq3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1req3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInforeq3 = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInforeq3 = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInforeq3 = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInforeq3 = new EDIInboundWebService.MeterExceptionInfo();
        
        vTranInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInforeq3.Transaction_Date = '20160308';
        vTranInforeq3.Transaction_Time = '04040000';
        vTranInforeq3.Sender_DUNS = '007901739';
        vTranInforeq3.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInforeq3.Receiver_DUNS = '078481476';
        vTranInforeq3.Receiver_Name = 'DYNEGY';
        vTranInforeq3.Originating_Transaction_ID = 'FH74292HDUI830';
        vTranInforeq3.Line_Transaction_ID = '8020474607';
        vTranInforeq3.Action_ID = 'GAAE';
        vTranInforeq3.Commodity = 'E';
        vTranInforeq3.Transaction_Qualifier = '2';
        vTranInforeq3.Response_Qualifier = '2';
        
        vOrgInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInforeq3.Organization_Identifier_Code = 'SJ';
        vOrgInforeq3.Organization_DUNS = '141420484';
        vOrgInforeq3.Organization_Name = 'DYNEGY';
        
        vOrgInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1req3.Organization_Identifier_Code = '8S';
        vOrgInfo1req3.Organization_DUNS = '007901739';
        vOrgInfo1req3.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInforeq3.Name_Qualifier = '8R';
        vCustInforeq3.Customer_Name = 'TEST SCENARIO 3';
        vCustInforeq3.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInforeq3.City_Name = 'CINCINNATI';
        vCustInforeq3.State_Province_Code = 'OH';
        vCustInforeq3.Postal_Code_Zip = '43068';
        vCustInforeq3.Country_Code = 'US';
        
        vCustInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1req3.Name_Qualifier = 'BT';
        vCustInfo1req3.Contact_Function_Qualifier = 'IC';
        vCustInfo1req3.Customer_Name = 'TEST SCENARIO 3';
        vCustInfo1req3.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInfo1req3.City_Name = 'CINCINNATI';
        vCustInfo1req3.State_Province_Code = 'OH';
        vCustInfo1req3.Postal_Code_Zip = '43068';
        vCustInfo1req3.Country_Code = 'US';        
        
        vAcctInforeq3.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInforeq3.Contract_Effective_Date ='20160229';
        vAcctInforeq3.Contract_Effective_Time ='0001';
        vAcctInforeq3.Service_Start_Date ='20160308';
        vAcctInforeq3.LDC_Bill_Cycle ='12MA';
        vAcctInforeq3.Capacity_Obligation_Quantity =1.3;
        vAcctInforeq3.Transmission_Obligation_Quantity =1.2;
        vAcctInforeq3.Number_Of_Months_Calculated_Usage_Quantity =0;
        vAcctInforeq3.Peak_Demand_Usage_Quantity =0;
        vAcctInforeq3.Total_KWH_Quantity =0;
        vAcctInforeq3.Bill_Presenter ='LDC';
        vAcctInforeq3.Bill_Calculator='LDC';
        vAcctInforeq3.SDP_Number = '00040621044444444';
        vAcctInforeq3.Payment_Arrangement_Code='Y';
        
        vMetInforeq3.Sender_Transaction_ID='CSPA725125B119494333';
        vMetInforeq3.Meter_Number='1234511133';
        vMetInforeq3.Load_Profile_Description='CCCSRESA';
        vMetInforeq3.LDC_Rate_Class='013';
        vMetInforeq3.LDC_Meter_Cycle='12MA';
        vMetInforeq3.Meter_Type_Code='KHMON';
        vMetInforeq3.Meter_Multiplier_Quantity=1;
        vMetInforeq3.Number_Of_Dials_Quantity='5';
        vMetInforeq3.Time_Of_Use_Metering='51';
        vMetInforeq3.Meter_Maintenance_Code='MQ';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInforeq3 = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInforeq3.add(vOrgInforeq3);
        lOrgInforeq3.add(vOrgInfo1req3);

        List<EDIInboundWebService.CustomerInfo> lCustInforeq3 = new List<EDIInboundWebService.CustomerInfo>();
        lCustInforeq3.add(vCustInforeq3);
        lCustInforeq3.add(vCustInfo1req3);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInforeq3 = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInforeq3.add(vAcctExctInforeq3);

        List<EDIInboundWebService.MeterInfo> lMetInforeq3 = new List<EDIInboundWebService.MeterInfo>();
        lMetInforeq3.add(vMetInforeq3);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInforeq3 = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInforeq3.add(vMetExctInforeq3);
        
        vCTInforeq3.Transaction_Info = vTranInforeq3;
        vCTInforeq3.Organization = lOrgInforeq3;
        vCTInforeq3.Customer = lCustInforeq3;
        vCTInforeq3.Account = vAcctInforeq3;
        vCTInforeq3.Account_Exception_Info = lAcctExtInforeq3;
        vCTInforeq3.Meter = lMetInforeq3;
        vCTInforeq3.Meter_Exception_Info = lMetExctInforeq3;
        
        lCInfo.add(vCTInfo);
        lCInfo.add(vCTInforeq3);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    @IsTest private static void testGAACSuccess()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 20;
        trailInfo.Transaction_Count = 2;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAC = [select Id from DASR_Request__c where DASR_Type__c ='GAAC' limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAC.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAC';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '2';
        vTranInfo.Response_Qualifier = '1';
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.SDP_Number = '00040621040044404';
        
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        // SECOND TRANSACTION
        EDIInboundWebService.CTGTransactionInfo vCTInforeq3 = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInforeq3 = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInforeq3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1req3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInforeq3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1req3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInforeq3 = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInforeq3 = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInforeq3 = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInforeq3 = new EDIInboundWebService.MeterExceptionInfo();
        
        vTranInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInforeq3.Transaction_Date = '20160308';
        vTranInforeq3.Transaction_Time = '04040000';
        vTranInforeq3.Sender_DUNS = '007901739';
        vTranInforeq3.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInforeq3.Receiver_DUNS = '078481476';
        vTranInforeq3.Receiver_Name = 'DYNEGY';
        vTranInforeq3.Originating_Transaction_ID = 'DHSU924HUOI943IO';
        vTranInforeq3.Line_Transaction_ID = '8020474607';
        vTranInforeq3.Action_ID = 'GAAC';
        vTranInforeq3.Commodity = 'E';
        vTranInforeq3.Transaction_Qualifier = '2';
        vTranInforeq3.Response_Qualifier = '1';
        
        vOrgInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInforeq3.Organization_Identifier_Code = 'SJ';
        vOrgInforeq3.Organization_DUNS = '141420484';
        vOrgInforeq3.Organization_Name = 'DYNEGY';
        
        vOrgInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1req3.Organization_Identifier_Code = '8S';
        vOrgInfo1req3.Organization_DUNS = '007901739';
        vOrgInfo1req3.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInforeq3.Name_Qualifier = '8R';
        vCustInforeq3.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1req3.Name_Qualifier = 'BT';
        vCustInfo1req3.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInforeq3.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInforeq3.SDP_Number = '00040621044444444';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInforeq3 = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInforeq3.add(vOrgInforeq3);
        lOrgInforeq3.add(vOrgInfo1req3);

        List<EDIInboundWebService.CustomerInfo> lCustInforeq3 = new List<EDIInboundWebService.CustomerInfo>();
        lCustInforeq3.add(vCustInforeq3);
        lCustInforeq3.add(vCustInfo1req3);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInforeq3 = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInforeq3.add(vAcctExctInforeq3);

        List<EDIInboundWebService.MeterInfo> lMetInforeq3 = new List<EDIInboundWebService.MeterInfo>();
        lMetInforeq3.add(vMetInforeq3);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInforeq3 = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInforeq3.add(vMetExctInforeq3);
        
        vCTInforeq3.Transaction_Info = vTranInforeq3;
        vCTInforeq3.Organization = lOrgInforeq3;
        vCTInforeq3.Customer = lCustInforeq3;
        vCTInforeq3.Account = vAcctInforeq3;
        vCTInforeq3.Account_Exception_Info = lAcctExtInforeq3;
        vCTInforeq3.Meter = lMetInforeq3;
        vCTInforeq3.Meter_Exception_Info = lMetExctInforeq3;
        
        lCInfo.add(vCTInfo);
        lCInfo.add(vCTInforeq3);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testGAACFailure()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 20;
        trailInfo.Transaction_Count = 2;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAC = [select Id from DASR_Request__c where DASR_Type__c ='GAAC'  limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAC.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAC';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '2';
        vTranInfo.Response_Qualifier = '2';
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Customer_Name = 'TEST SCENARIO 3';
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.SDP_Number = '00040621040044404';
        
        
        vAcctExctInfo.Sender_Transaction_ID= 'CSPA725125B119494333';
        vAcctExctInfo.Reason_Code= 'A76';
        vAcctExctInfo.Reason_Description= 'Account not found or invalid';
        vAcctExctInfo.Exception_Type_Code= 'RJ';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        
        // SECOND TRANSACTION
        EDIInboundWebService.CTGTransactionInfo vCTInforeq3 = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInforeq3 = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInforeq3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1req3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInforeq3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1req3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInforeq3 = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInforeq3 = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInforeq3 = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInforeq3 = new EDIInboundWebService.MeterExceptionInfo();
        
        vTranInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInforeq3.Transaction_Date = '20160308';
        vTranInforeq3.Transaction_Time = '04040000';
        vTranInforeq3.Sender_DUNS = '007901739';
        vTranInforeq3.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInforeq3.Receiver_DUNS = '078481476';
        vTranInforeq3.Receiver_Name = 'DYNEGY';
        vTranInforeq3.Originating_Transaction_ID = 'DHSU924HUOI943IO';
        vTranInforeq3.Line_Transaction_ID = '8020474607';
        vTranInforeq3.Action_ID = 'GAAC';
        vTranInforeq3.Commodity = 'E';
        vTranInforeq3.Transaction_Qualifier = '2';
        vTranInforeq3.Response_Qualifier = '2';
        
        vOrgInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInforeq3.Organization_Identifier_Code = 'SJ';
        vOrgInforeq3.Organization_DUNS = '141420484';
        vOrgInforeq3.Organization_Name = 'DYNEGY';
        
        vOrgInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1req3.Organization_Identifier_Code = '8S';
        vOrgInfo1req3.Organization_DUNS = '007901739';
        vOrgInfo1req3.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInforeq3.Name_Qualifier = '8R';
        vCustInforeq3.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1req3.Name_Qualifier = 'BT';
        vCustInfo1req3.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInforeq3.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInforeq3.SDP_Number = '00040621044444444';
        
        vAcctExctInforeq3.Sender_Transaction_ID= 'CSPA725125B119494333';
        vAcctExctInforeq3.Reason_Code= 'A76';
        vAcctExctInforeq3.Reason_Description= 'Account not found or invalid';
        vAcctExctInforeq3.Exception_Type_Code= 'RJ';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInforeq3 = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInforeq3.add(vOrgInforeq3);
        lOrgInforeq3.add(vOrgInfo1req3);

        List<EDIInboundWebService.CustomerInfo> lCustInforeq3 = new List<EDIInboundWebService.CustomerInfo>();
        lCustInforeq3.add(vCustInforeq3);
        lCustInforeq3.add(vCustInfo1req3);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInforeq3 = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInforeq3.add(vAcctExctInforeq3);

        List<EDIInboundWebService.MeterInfo> lMetInforeq3 = new List<EDIInboundWebService.MeterInfo>();
        lMetInforeq3.add(vMetInforeq3);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInforeq3 = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInforeq3.add(vMetExctInforeq3);
        
        vCTInforeq3.Transaction_Info = vTranInforeq3;
        vCTInforeq3.Organization = lOrgInforeq3;
        vCTInforeq3.Customer = lCustInforeq3;
        vCTInforeq3.Account = vAcctInforeq3;
        vCTInforeq3.Account_Exception_Info = lAcctExtInforeq3;
        vCTInforeq3.Meter = lMetInforeq3;
        vCTInforeq3.Meter_Exception_Info = lMetExctInforeq3;
        
        lCInfo.add(vCTInfo);
        lCInfo.add(vCTInforeq3);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testGAADSuccess()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 20;
        trailInfo.Transaction_Count = 2;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAD = [select Id from DASR_Request__c where DASR_Type__c ='GAAD' limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAD.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAD';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '2';
        vTranInfo.Response_Qualifier = '1';
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.SDP_Number = '00040621040044404';
        
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        
        // SECOND TRANSACTION
        EDIInboundWebService.CTGTransactionInfo vCTInforeq3 = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInforeq3 = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInforeq3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1req3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInforeq3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1req3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInforeq3 = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInforeq3 = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInforeq3 = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInforeq3 = new EDIInboundWebService.MeterExceptionInfo();
        
        vTranInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInforeq3.Transaction_Date = '20160308';
        vTranInforeq3.Transaction_Time = '04040000';
        vTranInforeq3.Sender_DUNS = '007901739';
        vTranInforeq3.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInforeq3.Receiver_DUNS = '078481476';
        vTranInforeq3.Receiver_Name = 'DYNEGY';
        vTranInforeq3.Originating_Transaction_ID = 'UO04HFDO4375UIFO';
        vTranInforeq3.Line_Transaction_ID = '8020474607';
        vTranInforeq3.Action_ID = 'GAAD';
        vTranInforeq3.Commodity = 'E';
        vTranInforeq3.Transaction_Qualifier = '2';
        vTranInforeq3.Response_Qualifier = '1';
        
        vOrgInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInforeq3.Organization_Identifier_Code = 'SJ';
        vOrgInforeq3.Organization_DUNS = '141420484';
        vOrgInforeq3.Organization_Name = 'DYNEGY';
        
        vOrgInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1req3.Organization_Identifier_Code = '8S';
        vOrgInfo1req3.Organization_DUNS = '007901739';
        vOrgInfo1req3.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInforeq3.Name_Qualifier = '8R';
        vCustInforeq3.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1req3.Name_Qualifier = 'BT';
        vCustInfo1req3.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInforeq3.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInforeq3.SDP_Number = '00040621044444444';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInforeq3 = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInforeq3.add(vOrgInforeq3);
        lOrgInforeq3.add(vOrgInfo1req3);

        List<EDIInboundWebService.CustomerInfo> lCustInforeq3 = new List<EDIInboundWebService.CustomerInfo>();
        lCustInforeq3.add(vCustInforeq3);
        lCustInforeq3.add(vCustInfo1req3);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInforeq3 = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInforeq3.add(vAcctExctInforeq3);

        List<EDIInboundWebService.MeterInfo> lMetInforeq3 = new List<EDIInboundWebService.MeterInfo>();
        lMetInforeq3.add(vMetInforeq3);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInforeq3 = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInforeq3.add(vMetExctInforeq3);
        
        vCTInforeq3.Transaction_Info = vTranInforeq3;
        vCTInforeq3.Organization = lOrgInforeq3;
        vCTInforeq3.Customer = lCustInforeq3;
        vCTInforeq3.Account = vAcctInforeq3;
        vCTInforeq3.Account_Exception_Info = lAcctExtInforeq3;
        vCTInforeq3.Meter = lMetInforeq3;
        vCTInforeq3.Meter_Exception_Info = lMetExctInforeq3;
        
        lCInfo.add(vCTInfo);
        lCInfo.add(vCTInforeq3);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testGAADFailure()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 20;
        trailInfo.Transaction_Count = 2;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAD = [select Id from DASR_Request__c where DASR_Type__c ='GAAD'  limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAD.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAD';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '2';
        vTranInfo.Response_Qualifier = '2';
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Customer_Name = 'TEST SCENARIO 3';
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.SDP_Number = '00040621040044404';
        
        vAcctExctInfo.Sender_Transaction_ID= 'CSPA725125B119494333';
        vAcctExctInfo.Reason_Code= 'A76';
        vAcctExctInfo.Reason_Description= 'Account not found or invalid';
        vAcctExctInfo.Exception_Type_Code= 'RJ';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        
        // SECOND TRANSACTION
        EDIInboundWebService.CTGTransactionInfo vCTInforeq3 = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInforeq3 = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInforeq3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1req3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInforeq3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1req3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInforeq3 = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInforeq3 = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInforeq3 = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInforeq3 = new EDIInboundWebService.MeterExceptionInfo();
        
        vTranInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInforeq3.Transaction_Date = '20160308';
        vTranInforeq3.Transaction_Time = '04040000';
        vTranInforeq3.Sender_DUNS = '007901739';
        vTranInforeq3.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInforeq3.Receiver_DUNS = '078481476';
        vTranInforeq3.Receiver_Name = 'DYNEGY';
        vTranInforeq3.Originating_Transaction_ID = 'UO04HFDO4375UIFO';
        vTranInforeq3.Line_Transaction_ID = '8020474607';
        vTranInforeq3.Action_ID = 'GAAD';
        vTranInforeq3.Commodity = 'E';
        vTranInforeq3.Transaction_Qualifier = '2';
        vTranInforeq3.Response_Qualifier = '2';
        
        vOrgInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInforeq3.Organization_Identifier_Code = 'SJ';
        vOrgInforeq3.Organization_DUNS = '141420484';
        vOrgInforeq3.Organization_Name = 'DYNEGY';
        
        vOrgInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1req3.Organization_Identifier_Code = '8S';
        vOrgInfo1req3.Organization_DUNS = '007901739';
        vOrgInfo1req3.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInforeq3.Name_Qualifier = '8R';
        vCustInforeq3.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1req3.Name_Qualifier = 'BT';
        vCustInfo1req3.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInforeq3.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInforeq3.SDP_Number = '00040621044444444';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInforeq3 = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInforeq3.add(vOrgInforeq3);
        lOrgInforeq3.add(vOrgInfo1req3);

        List<EDIInboundWebService.CustomerInfo> lCustInforeq3 = new List<EDIInboundWebService.CustomerInfo>();
        lCustInforeq3.add(vCustInforeq3);
        lCustInforeq3.add(vCustInfo1req3);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInforeq3 = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInforeq3.add(vAcctExctInforeq3);

        List<EDIInboundWebService.MeterInfo> lMetInforeq3 = new List<EDIInboundWebService.MeterInfo>();
        lMetInforeq3.add(vMetInforeq3);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInforeq3 = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInforeq3.add(vMetExctInforeq3);
        
        vCTInforeq3.Transaction_Info = vTranInforeq3;
        vCTInforeq3.Organization = lOrgInforeq3;
        vCTInforeq3.Customer = lCustInforeq3;
        vCTInforeq3.Account = vAcctInforeq3;
        vCTInforeq3.Account_Exception_Info = lAcctExtInforeq3;
        vCTInforeq3.Meter = lMetInforeq3;
        vCTInforeq3.Meter_Exception_Info = lMetExctInforeq3;
        
        lCInfo.add(vCTInfo);
        lCInfo.add(vCTInforeq3);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testGAARSuccess()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 20;
        trailInfo.Transaction_Count = 2;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAR = [select Id from DASR_Request__c where DASR_Type__c ='GAAR' limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAR.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAR';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '2';
        vTranInfo.Response_Qualifier = '1';
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.SDP_Number = '00040621040044404';
        
        vAcctExctInfo.Sender_Transaction_ID= 'CSPA725125B119494333';
        vAcctExctInfo.Reason_Code= 'A76';
        vAcctExctInfo.Reason_Description= 'Account not found or invalid';
        vAcctExctInfo.Exception_Type_Code= 'RJ';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        
        // SECOND TRANSACTION
        EDIInboundWebService.CTGTransactionInfo vCTInforeq3 = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInforeq3 = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInforeq3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1req3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInforeq3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1req3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInforeq3 = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInforeq3 = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInforeq3 = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInforeq3 = new EDIInboundWebService.MeterExceptionInfo();
        
        vTranInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInforeq3.Transaction_Date = '20160308';
        vTranInforeq3.Transaction_Time = '04040000';
        vTranInforeq3.Sender_DUNS = '007901739';
        vTranInforeq3.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInforeq3.Receiver_DUNS = '078481476';
        vTranInforeq3.Receiver_Name = 'DYNEGY';
        vTranInforeq3.Originating_Transaction_ID = 'UO04HFDO4375UIFO';
        vTranInforeq3.Line_Transaction_ID = '8020474607';
        vTranInforeq3.Action_ID = 'GAAR';
        vTranInforeq3.Commodity = 'E';
        vTranInforeq3.Transaction_Qualifier = '2';
        vTranInforeq3.Response_Qualifier = '1';
        
        vOrgInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInforeq3.Organization_Identifier_Code = 'SJ';
        vOrgInforeq3.Organization_DUNS = '141420484';
        vOrgInforeq3.Organization_Name = 'DYNEGY';
        
        vOrgInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1req3.Organization_Identifier_Code = '8S';
        vOrgInfo1req3.Organization_DUNS = '007901739';
        vOrgInfo1req3.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInforeq3.Name_Qualifier = '8R';
        vCustInforeq3.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1req3.Name_Qualifier = 'BT';
        vCustInfo1req3.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInforeq3.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInforeq3.SDP_Number = '00040621044444444';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInforeq3 = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInforeq3.add(vOrgInforeq3);
        lOrgInforeq3.add(vOrgInfo1req3);

        List<EDIInboundWebService.CustomerInfo> lCustInforeq3 = new List<EDIInboundWebService.CustomerInfo>();
        lCustInforeq3.add(vCustInforeq3);
        lCustInforeq3.add(vCustInfo1req3);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInforeq3 = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInforeq3.add(vAcctExctInforeq3);

        List<EDIInboundWebService.MeterInfo> lMetInforeq3 = new List<EDIInboundWebService.MeterInfo>();
        lMetInforeq3.add(vMetInforeq3);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInforeq3 = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInforeq3.add(vMetExctInforeq3);
        
        vCTInforeq3.Transaction_Info = vTranInforeq3;
        vCTInforeq3.Organization = lOrgInforeq3;
        vCTInforeq3.Customer = lCustInforeq3;
        vCTInforeq3.Account = vAcctInforeq3;
        vCTInforeq3.Account_Exception_Info = lAcctExtInforeq3;
        vCTInforeq3.Meter = lMetInforeq3;
        vCTInforeq3.Meter_Exception_Info = lMetExctInforeq3;
        
        lCInfo.add(vCTInfo);
        lCInfo.add(vCTInforeq3);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testGAARFailure()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 20;
        trailInfo.Transaction_Count = 2;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAR = [select Id from DASR_Request__c where DASR_Type__c ='GAAR' limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAR.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAR';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '2';
        vTranInfo.Response_Qualifier = '2';
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.SDP_Number = '00040621040044404';
        
        vAcctExctInfo.Sender_Transaction_ID= 'CSPA725125B119494333';
        vAcctExctInfo.Reason_Code= 'A76';
        vAcctExctInfo.Reason_Description= 'Account not found or invalid';
        vAcctExctInfo.Exception_Type_Code= 'RJ';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        
        // SECOND TRANSACTION
        EDIInboundWebService.CTGTransactionInfo vCTInforeq3 = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInforeq3 = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInforeq3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1req3 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInforeq3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1req3 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInforeq3 = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInforeq3 = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInforeq3 = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInforeq3 = new EDIInboundWebService.MeterExceptionInfo();
        
        vTranInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInforeq3.Transaction_Date = '20160308';
        vTranInforeq3.Transaction_Time = '04040000';
        vTranInforeq3.Sender_DUNS = '007901739';
        vTranInforeq3.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInforeq3.Receiver_DUNS = '078481476';
        vTranInforeq3.Receiver_Name = 'DYNEGY';
        vTranInforeq3.Originating_Transaction_ID = 'UO04HFDO4375UIFO';
        vTranInforeq3.Line_Transaction_ID = '8020474607';
        vTranInforeq3.Action_ID = 'GAAR';
        vTranInforeq3.Commodity = 'E';
        vTranInforeq3.Transaction_Qualifier = '2';
        vTranInforeq3.Response_Qualifier = '2';
        
        vOrgInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInforeq3.Organization_Identifier_Code = 'SJ';
        vOrgInforeq3.Organization_DUNS = '141420484';
        vOrgInforeq3.Organization_Name = 'DYNEGY';
        
        vOrgInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1req3.Organization_Identifier_Code = '8S';
        vOrgInfo1req3.Organization_DUNS = '007901739';
        vOrgInfo1req3.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInforeq3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInforeq3.Name_Qualifier = '8R';
        vCustInforeq3.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1req3.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1req3.Name_Qualifier = 'BT';
        vCustInfo1req3.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInforeq3.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInforeq3.SDP_Number = '00040621044444444';
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInforeq3 = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInforeq3.add(vOrgInforeq3);
        lOrgInforeq3.add(vOrgInfo1req3);

        List<EDIInboundWebService.CustomerInfo> lCustInforeq3 = new List<EDIInboundWebService.CustomerInfo>();
        lCustInforeq3.add(vCustInforeq3);
        lCustInforeq3.add(vCustInfo1req3);

        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInforeq3 = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInforeq3.add(vAcctExctInforeq3);

        List<EDIInboundWebService.MeterInfo> lMetInforeq3 = new List<EDIInboundWebService.MeterInfo>();
        lMetInforeq3.add(vMetInforeq3);

        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInforeq3 = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInforeq3.add(vMetExctInforeq3);
        
        vCTInforeq3.Transaction_Info = vTranInforeq3;
        vCTInforeq3.Organization = lOrgInforeq3;
        vCTInforeq3.Customer = lCustInforeq3;
        vCTInforeq3.Account = vAcctInforeq3;
        vCTInforeq3.Account_Exception_Info = lAcctExtInforeq3;
        vCTInforeq3.Meter = lMetInforeq3;
        vCTInforeq3.Meter_Exception_Info = lMetExctInforeq3;
        
        lCInfo.add(vCTInfo);
        lCInfo.add(vCTInforeq3);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        	EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testInboundGAACSuccess()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 20;
        trailInfo.Transaction_Count = 2;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAC = [select Id from DASR_Request__c where DASR_Type__c ='GAAC' limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAC.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAC';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '1';
       
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.LDC_Account_Number = '00040621040044404';
        vAcctInfo.ESP_Account_Number = '72835';
        vAcctInfo.Change_Effective_Date = '20160210';
        
        vMetInfo.Sender_Transaction_ID='CSPA725125B119494333';
        vMetInfo.Meter_Number='1234511133';
        vMetInfo.Old_Meter_Number='108117698';
        vMetInfo.Load_Profile_Description='RS6';
        vMetInfo.LDC_Rate_Class='RS';
        vMetInfo.LDC_Meter_Cycle='07';
        vMetInfo.Meter_Type_Code='KHMON';
        vMetInfo.Meter_Multiplier_Quantity=1;
        vMetInfo.Number_Of_Dials_Quantity='5';
        vMetInfo.Time_Of_Use_Metering='51';
        vMetInfo.Meter_Maintenance_Code='MX';
        
        vMetExctInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vMetExctInfo.Reason_Code = 'NM1MX';
        vMetExctInfo.Reason_Description = 'Meter exchange';
        vMetExctInfo.Exception_Type_Code = 'CH';
        vMetExctInfo.Meter_Number = '108250202';
       
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        
        lCInfo.add(vCTInfo);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testInboundGAADSuccess()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 10;
        trailInfo.Transaction_Count = 1;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAC = [select Id from DASR_Request__c where DASR_Type__c ='GAAC' limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAC.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAD';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '1';
       
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.LDC_Account_Number = '00040621040044404';
        vAcctInfo.ESP_Account_Number = '72835';
        vAcctInfo.Drop_Reason_Code = 'CHA';
        vAcctInfo.Drop_Reason_Description = 'CUSTOMER CHANGED TO ANOTHER SERVICE PROVIDER';
        vAcctInfo.Service_End_Date = '20160310';
        vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity = 1;
        vAcctInfo.Total_KWH_Quantity = 6086;
        vAcctInfo.Bill_Presenter = 'LDC';
        vAcctInfo.Bill_Calculator = 'DUAL';
        
       
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        
        lCInfo.add(vCTInfo);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testInboundGAAHSuccess()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 10;
        trailInfo.Transaction_Count = 1;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAC = [select Id from DASR_Request__c where DASR_Type__c ='GAAC' limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAC.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAH';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '1';
       
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.LDC_Account_Number = '00040621040044404';
        vAcctInfo.ESP_Account_Number = '72835';
        vAcctInfo.Drop_Reason_Code = 'CHA';
        vAcctInfo.Drop_Reason_Description = 'CUSTOMER CHANGED TO ANOTHER SERVICE PROVIDER';
        vAcctInfo.Service_End_Date = '20160310';
        vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity = 1;
        vAcctInfo.Total_KWH_Quantity = 6086;
        vAcctInfo.Bill_Presenter = 'LDC';
        vAcctInfo.Bill_Calculator = 'DUAL';
        
       
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        
        lCInfo.add(vCTInfo);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testInboundGAARSuccess()
    {
        EDIInboundWebService.EDIInboundRequest req = new EDIInboundWebService.EDIInboundRequest();
        EDIInboundWebService.DocumentInfo docInfo = new EDIInboundWebService.DocumentInfo();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        EDIInboundWebService.TrailerInfo trailInfo = new EDIInboundWebService.TrailerInfo();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = 10;
        trailInfo.Transaction_Count = 1;
        
        
        List<EDIInboundWebService.CTGTransactionInfo> lCInfo = new List<EDIInboundWebService.CTGTransactionInfo>();
        EDIInboundWebService.CTGTransactionInfo vCTInfo = new EDIInboundWebService.CTGTransactionInfo();
        
        EDIInboundWebService.TransactionInfo vTranInfo = new EDIInboundWebService.TransactionInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.OrganizationInfo vOrgInfo1 = new EDIInboundWebService.OrganizationInfo();
        EDIInboundWebService.CustomerInfo vCustInfo = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.CustomerInfo vCustInfo1 = new EDIInboundWebService.CustomerInfo();
        EDIInboundWebService.AccountInfo vAcctInfo = new EDIInboundWebService.AccountInfo();
        EDIInboundWebService.AccountExceptionInfo vAcctExctInfo = new EDIInboundWebService.AccountExceptionInfo();
        EDIInboundWebService.MeterInfo vMetInfo = new EDIInboundWebService.MeterInfo();
        EDIInboundWebService.MeterExceptionInfo vMetExctInfo = new EDIInboundWebService.MeterExceptionInfo();
        
        dasrReqGAAC = [select Id from DASR_Request__c where DASR_Type__c ='GAAC' limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        vTranInfo.Originating_Transaction_ID = dasrReqGAAC.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAR';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '1';
       
        
        vOrgInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo.Organization_Identifier_Code = 'SJ';
        vOrgInfo.Organization_DUNS = '141420484';
        vOrgInfo.Organization_Name = 'DYNEGY';
        
        vOrgInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vOrgInfo1.Organization_Identifier_Code = '8S';
        vOrgInfo1.Organization_DUNS = '007901739';
        vOrgInfo1.Organization_Name = 'COLUMBUS SOUTHERN POWER';
        
        vCustInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo.Name_Qualifier = '8R';
        vCustInfo.Customer_Name = 'TEST SCENARIO 3';
        
        
        vCustInfo1.Sender_Transaction_ID = 'CSPA725125B119494333';
        vCustInfo1.Name_Qualifier = 'BT';
        vCustInfo1.Contact_Function_Qualifier = 'IC';
        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.LDC_Account_Number = '00040621040044404';
        vAcctInfo.ESP_Account_Number = '72835';
        vAcctInfo.Drop_Reason_Code = 'CHA';
        vAcctInfo.Drop_Reason_Description = 'CUSTOMER CHANGED TO ANOTHER SERVICE PROVIDER';
        vAcctInfo.Service_End_Date = '20160310';
        vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity = 1;
        vAcctInfo.Total_KWH_Quantity = 6086;
        vAcctInfo.Bill_Presenter = 'LDC';
        vAcctInfo.Bill_Calculator = 'DUAL';
        
       
        
        List<EDIInboundWebService.OrganizationInfo> lOrgInfo = new List<EDIInboundWebService.OrganizationInfo>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        List<EDIInboundWebService.CustomerInfo> lCustInfo = new List<EDIInboundWebService.CustomerInfo>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        List<EDIInboundWebService.AccountExceptionInfo> lAcctExtInfo = new List<EDIInboundWebService.AccountExceptionInfo>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        List<EDIInboundWebService.MeterInfo> lMetInfo = new List<EDIInboundWebService.MeterInfo>();
        lMetInfo.add(vMetInfo);
        
        List<EDIInboundWebService.MeterExceptionInfo> lMetExctInfo = new List<EDIInboundWebService.MeterExceptionInfo>();
        lMetExctInfo.add(vMetExctInfo);
        
        vCTInfo.Transaction_Info = vTranInfo;
        vCTInfo.Organization = lOrgInfo;
        vCTInfo.Customer = lCustInfo;
        vCTInfo.Account = vAcctInfo;
        vCTInfo.Account_Exception_Info = lAcctExtInfo;
        vCTInfo.Meter = lMetInfo;
        vCTInfo.Meter_Exception_Info = lMetExctInfo;
        
        
        lCInfo.add(vCTInfo);
        
        req.Document_Info = docInfo;
        req.CTG_Transaction = lCInfo;
        req.Trailer = trailInfo;
        
        EDIInboundWebService.processRequest(req);
    }
    
    @IsTest private static void testEnrollment()
    {
        EDIInboundWebService.processRequest(null);
    }
    
}