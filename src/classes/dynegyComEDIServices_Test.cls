/* 
* Name: dynegyComServices_newTest
* Type: Test Class
* Apex Class: dynegyComEDIServices_Test
* Description:  This is test class for code coverage of dynegyComEDIServices. 
* Change History:
*===================================================================================================================================
* Version     Author                       Date             Description 
* 1.0        KPMG        03/16/2016       1. Initial Version created
*/

@isTest(SeeAllData=false)
global class dynegyComEDIServices_Test 
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
        //insert supplier;
        
        acc = new Account();
        acc.name = 'Test Acc';
        acc.Supplier__c = supplier.Id;
        //insert acc;
        
        opp = new Opportunity();
        opp.name = 'Test Opp';
        opp.StageName = 'New';
        opp.CloseDate = date.today().addDays(5);
        opp.Accountid = acc.id;
        opp.RecordTypeId = rec.id;
        //insert opp;
        
        lacc = new LDC_Account__c();
        lacc.name  ='Test LDC acc';
        lacc.Account__c = acc.id;
        lacc.LDC_Account_Number__c = '00040621040044404';
        //insert lacc;
        
        
        ct=new Contract(Name='Test Contract',StartDate=Date.today(),Status='Draft',AccountId=acc.Id, Rate_Code__c ='DM01', Bill_Method__c ='DUAL', Interval_Usage__c ='Summary');
        
        //insert ct;
        
        contractLDC = new Contract_LDC__c();
        contractLDC.Contract__c = ct.Id;
        contractLDC.LDC_Account__c = lacc.Id;
        //insert contractLDC;
        
        sp = new Service_Point__c();
        sp.LDC_Account_Number__c = lacc.Id;
        sp.Service_Point_Number__c = '123';
        //insert sp;
        
        meter = new Meter__c();
        meter.Service_Point__c = sp.Id;
        meter.Meter_Number__c ='ALL';
        //insert meter;
        
        ldcvendor=new LDC_Vendor__c(Name='Test Vendor',Service_Territory__c='DAYTON',DUNS__c='123',Utility_Code__c='1234');
        //insert ldcvendor;
        
        
        dasrReq = new DASR_Request__c();
        dasrReq.DASR_Type__c  ='GAAE';
        dasrReq.Contract__c = ct.Id;
        dasrReq.DASR_Submit_Date__c = System.today();
        dasrReq.LDC_Account__c = lacc.Id;
        //insert dasrReq;
        
        dasrReqGAAC = new DASR_Request__c();
        dasrReqGAAC.DASR_Type__c  ='GAAC';
        dasrReqGAAC.Contract__c = ct.Id;
        dasrReqGAAC.DASR_Submit_Date__c = System.today();
        dasrReqGAAC.Change_Reason__c  = 'Change Billing Type (Billing Option)';
        dasrReqGAAC.Bill_Method__c ='Rate Ready';
        dasrReqGAAC.LDC_Account__c = lacc.Id;
        //insert dasrReqGAAC;
        
        dasrReqGAAD = new DASR_Request__c();
        dasrReqGAAD.DASR_Type__c  ='GAAD';
        dasrReqGAAD.Contract__c = ct.Id;
        dasrReqGAAD.DASR_Submit_Date__c = System.today();
        dasrReqGAAD.Drop_Date__c  = System.today();
        dasrReqGAAD.Drop_Reason__c ='Contrct Expired';
        dasrReqGAAD.LDC_Account__c = lacc.Id;
        //insert dasrReqGAAD;
        
        EDIIntegrationConfiguration__c config = new EDIIntegrationConfiguration__c(name ='Default',Notify_Email__c='anands1775@gmail.com',User_Name__c='dynsfdev', Password__c='u7SBbSIG',EDI_Outbound_End_Point__c='https://salesforcetest.dynegy.com/SforceESG.svc/SforceESG',Interval_Request_Code__c='N',Default_Meter_Number__c='ALL',Recipient_Name__c='ESG',Receipient_DUNS__c='049050839');
        //insert config;
    }

    private static testmethod void dynegyComEDIServices_UnitTest()
    {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new DynegyComEDIServicesMockImpl());

        invokeserviceTest();
        
        Test.stopTest();
    }
    @future(callout=true)  
    public static void invokeserviceTest()
    {

        dynegyComEDIServices.CTG_Document req = new dynegyComEDIServices.CTG_Document();
        dynegyComEDIServices.CTG_Document_Info docInfo = new dynegyComEDIServices.CTG_Document_Info();
        docInfo.Document_ID = '8004717741';
        docInfo.Document_Date = '20160308';
        docInfo.Document_Time = '1620';
        docInfo.Originator_DUNS = '049050839';
        docInfo.Originator_Name = 'ENERGY SERVICES GROUP';
        docInfo.Recipient_DUNS = '078481476';
        docInfo.Recipient_NAME = 'DYNEGY';
        docInfo.Version_Number = '01.49';
        
        dynegyComEDIServices.CTG_Trailer trailInfo = new dynegyComEDIServices.CTG_Trailer();
        trailInfo.Document_ID = '8004717741';
        trailInfo.Records_Generated = '10';
        trailInfo.Transaction_Count = '1';
        
        
        List<dynegyComEDIServices.CTG_Transaction> lCInfo = new List<dynegyComEDIServices.CTG_Transaction>();
        
        dynegyComEDIServices.CTG_Transaction vTran = new dynegyComEDIServices.CTG_Transaction();
        dynegyComEDIServices.CTG_Transaction_Info vTranInfo = new dynegyComEDIServices.CTG_Transaction_Info();
        dynegyComEDIServices.CTG_Organization vOrgInfo = new dynegyComEDIServices.CTG_Organization();
        dynegyComEDIServices.CTG_Organization vOrgInfo1 = new dynegyComEDIServices.CTG_Organization();
        dynegyComEDIServices.CTG_Customer vCustInfo = new dynegyComEDIServices.CTG_Customer();
        dynegyComEDIServices.CTG_Customer vCustInfo1 = new dynegyComEDIServices.CTG_Customer();
        dynegyComEDIServices.CTG_Account vAcctInfo = new dynegyComEDIServices.CTG_Account();
        dynegyComEDIServices.CTG_Account_Exception_Info vAcctExctInfo = new dynegyComEDIServices.CTG_Account_Exception_Info();
        dynegyComEDIServices.CTG_Meter vMetInfo = new dynegyComEDIServices.CTG_Meter();
        dynegyComEDIServices.CTG_Meter_Exception_Info vMetExctInfo = new dynegyComEDIServices.CTG_Meter_Exception_Info();
        
        //dasrReq = [select Id from DASR_Request__c where DASR_Type__c ='GAAE'  limit 1];
        vTranInfo.Sender_Transaction_ID = 'CSPA725125B119494333';
        vTranInfo.Transaction_Date = '20160308';
        vTranInfo.Transaction_Time = '04040000';
        vTranInfo.Sender_DUNS = '007901739';
        vTranInfo.Sender_Name = 'COLUMBUS SOUTHERN POWER (AEP)';
        vTranInfo.Receiver_DUNS = '078481476';
        vTranInfo.Receiver_Name = 'DYNEGY';
        //vTranInfo.Originating_Transaction_ID = dasrReq.Id;
        vTranInfo.Line_Transaction_ID = '8020474607';
        vTranInfo.Action_ID = 'GAAE';
        vTranInfo.Commodity = 'E';
        vTranInfo.Transaction_Qualifier = '2';
        //vTranInfo.Response_Qualifier = '1';
        
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
        //vCustInfo1.Contact_Function_Qualifier = 'IC';
        vCustInfo1.Customer_Name = 'TEST SCENARIO 3';
        vCustInfo1.Address_Line_1 = '1234 SERVICE ADDR';
        vCustInfo1.City_Name = 'CINCINNATI';
        vCustInfo1.State_Province_Code = 'OH';
        vCustInfo1.Postal_Code_Zip = '43068';
        vCustInfo1.Country_Code = 'US';        
        
        vAcctInfo.Sender_Transaction_ID ='CSPA725125B119494333';
        vAcctInfo.Contract_Effective_Date ='20160229';
        vAcctInfo.Contract_Effective_Time ='0001';

        vAcctInfo.Bill_Presenter ='LDC';
        vAcctInfo.Bill_Calculator='LDC';
        vAcctInfo.SDP_Number = '00040621040044404';
        
        vMetInfo.Sender_Transaction_ID='CSPA725125B119494333';
        vMetInfo.Meter_Number='1234511133';
        vMetInfo.Meter_Maintenance_Code='MQ';
        
        List<dynegyComEDIServices.CTG_Organization> lOrgInfo = new List<dynegyComEDIServices.CTG_Organization>();
        lOrgInfo.add(vOrgInfo);
        lOrgInfo.add(vOrgInfo1);
        dynegyComEDIServices.ArrayOfCTG_Organization lAOrgInfo = new dynegyComEDIServices.ArrayOfCTG_Organization();
        lAOrgInfo.CTG_Organization  = lOrgInfo;
        
        List<dynegyComEDIServices.CTG_Customer> lCustInfo = new List<dynegyComEDIServices.CTG_Customer>();
        lCustInfo.add(vCustInfo);
        lCustInfo.add(vCustInfo1);
        
        dynegyComEDIServices.ArrayOfCTG_Customer lACustInfo = new dynegyComEDIServices.ArrayOfCTG_Customer(); 
        lACustInfo.CTG_Customer = lCustInfo;
            
        List<dynegyComEDIServices.CTG_Account_Exception_Info> lAcctExtInfo = new List<dynegyComEDIServices.CTG_Account_Exception_Info>();
        lAcctExtInfo.add(vAcctExctInfo);
        
        dynegyComEDIServices.ArrayOfCTG_Account_Exception_Info lAExInfo = new dynegyComEDIServices.ArrayOfCTG_Account_Exception_Info();
        lAExInfo.CTG_Account_Exception_Info = lAcctExtInfo;
        
        List<dynegyComEDIServices.CTG_Meter> lMetInfo = new List<dynegyComEDIServices.CTG_Meter>();
        lMetInfo.add(vMetInfo);
        
        List<dynegyComEDIServices.CTG_Meter_Exception_Info> lMetExctInfo = new List<dynegyComEDIServices.CTG_Meter_Exception_Info>();
        lMetExctInfo.add(vMetExctInfo);
        
        vTran.Transaction_Info = vTranInfo;
        vTran.Organization = lAOrgInfo;
        vTran.Customer = lACustInfo;
        vTran.Account = vAcctInfo;
        vTran.Account_Exception_Info = lAExInfo;
        vTran.Meter = vMetInfo;
        vTran.Meter_Exception_Info = vMetExctInfo;
        
        
        lCInfo.add(vTran);
        
        dynegyComEDIServices.ArrayOfCTG_Transaction lTranList = new dynegyComEDIServices.ArrayOfCTG_Transaction();
        lTranList.CTG_Transaction = lCInfo;
        
        req.Document_Info = docInfo;
        req.Transactions = lTranList;
        req.Trailer = trailInfo;
        
        dynegyComEDIServices.Submit_ESG_GAA_RequestResponse_element reqElement = new dynegyComEDIServices.Submit_ESG_GAA_RequestResponse_element();

        dynegyComEDIServices.Submit_ESG_GAA_RequestResponse_element reqPE = new dynegyComEDIServices.Submit_ESG_GAA_RequestResponse_element();
        dynegyComEDIServices.BasicHttpBinding_ISforceESG reqWS = new dynegyComEDIServices.BasicHttpBinding_ISforceESG();
        reqWS.Submit_ESG_GAA_Request(req);
    }
    private static testmethod void dynegyComServicesTest1()
    {
        Test.startTest();
        Test.setMock(WebServiceMock.class, new TestHandshakeMockImpl());
        RecordType rec =[select id,name from RecordType where name = 'Standard Opportunity'];
        dynegyComEDIServices.BasicHttpBinding_ISforceESG reqWS = new dynegyComEDIServices.BasicHttpBinding_ISforceESG();
        reqWS.TestHandshake(1);
        Test.stopTest();
    }
    
    global class TestHandshakeMockImpl implements WebServiceMock {
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
                dynegyComEDIServices.TestHandshakeResponse_element respElement = new dynegyComEDIServices.TestHandshakeResponse_element();
                respElement.TestHandshakeResult = 'test';
                response.put('response_x', respElement); 
            }
    }
    
    global class DynegyComEDIServicesMockImpl implements WebServiceMock {
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
                respElement.Submit_ESG_GAA_RequestResult = 'DONE';
                response.put('response_x', respElement); 
            }
    }
}