/* 
 * Name: batchProcessMuniAggTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the batchProcessMuniAgg Apex Batch Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         03/20/2016       1. Initial Version created
 */
@isTest(SeeAllData=false)
private class batchProcessMuniAggTest {

    static testMethod void batchProcessMuniAgg_UnitTest() {
        ID CustRecMAId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Muni Agg Customer').RecordTypeId;
        ID CustRecMAIndvId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Muni Agg Individual Customer').RecordTypeId;
        Schema.SObjectType token = Schema.getGlobalDescribe().get('Muni_Agg__c');
        Schema.DescribeSObjectResult dr = token.getDescribe();
        Map<String, Schema.SObjectField> field_map = dr.fields.getMap();
        List<Schema.PicklistEntry> pickListValues = field_map.get('LDC_VENDOR__C').getDescribe().getPickListValues();
        
        String LDCName = (!pickListValues.isEmpty())?pickListValues[0].getValue():'Test LDC Account MA001';
        
        String custID = '';
        Account tstAccRec=new Account(Name='Test Muni Agg Account',RecordTypeId=CustRecMAId,Billing_Entity__c='Dynegy');
        Insert tstAccRec;
        
        Account tstpAccRec1=new Account(LastName='Test Muni Agg Indv Account 1',RecordTypeId=CustRecMAIndvId,Billing_Entity__c='Dynegy',Business_account__c=tstAccRec.Id);
        Account tstpAccRec2=new Account(LastName='Test Muni Agg Indv Account 2',RecordTypeId=CustRecMAIndvId,Billing_Entity__c='Dynegy',Business_account__c=tstAccRec.Id);
        Account tstpAccRec3=new Account(LastName='Test Muni Agg Indv Account 3',RecordTypeId=CustRecMAIndvId,Billing_Entity__c='Dynegy',Business_account__c=tstAccRec.Id);
        insert new List<Account>{tstpAccRec1,tstpAccRec2,tstpAccRec3};
        custId = String.ValueOf(tstAccRec.id).substring(0,15);
        
        LDC_Vendor__c tstRecLDCVendor=new LDC_Vendor__c(Name='Test Vendor MA001',Service_Territory__c='DAYTON',DUNS__c='MA001',Utility_Code__c='MA0001',Service_State__c = 'OH');
        Insert tstRecLDCVendor;
        
        Contract tstRecCtrt=new Contract(Name='Test Contract MA001',Rate_Code__c='RC001',StartDate=Date.today(),Status='Draft',AccountId=tstAccRec.Id); 
        Insert tstRecCtrt;
        String cNumber = [select ID, ContractNumber from Contract where ID = :tstRecCtrt.id].ContractNumber;
        
        system.debug('>>>> Contract : ' + cNumber);
        
        
        Muni_Agg__c tstRecMACC = new Muni_Agg__c(BILLING_COUNTRY__C='Test MA Billing Country',  BILLING_STATE_PROVINCE__C='Test MA Billing State',  BILLING_STREET__C='Test MA Billing Street'
                        ,BILLING_ZIP_POSTAL_CODE__C='MA000001',   BILLING__C='Test MA Billing', EMAIL__C='testMA@testMA.com',   FIRST_NAME__C='Test MA FN',  LDC_ACCOUNT_NAME__C='Test MA LDC Account'   
                        ,LDC_ACCOUNT_NUMBER__C='TSTMA0002DUP',    LDC_VENDOR__C=LDCName,  LAST_NAME__C='Test MA LN',   PHONE__C='9123456789',   SERVICE_CITY__C='Test MA SERVICE CITY' 
                        ,SERVICE_COUNTY__C='Test MA SERVICE COUNTY',    SERVICE_POSTAL_CODE__C='TSTMA0001', SERVICE_STATE__C='Test MA SERVICE STATE',   SERVICE_STREET_1__C='Test MA SERVICE STREET',RATE_CODE__C='RC001'  
                        ,SERVICE_STREET_2__C='Test MA SERVICE STREET 2',  SERVICE_TERRITORY__C='DAYTON',   CONTRACT_NUMBER__C=cNumber, PROCESSED__C=false, Muni_Agg_Customer_Id__c=custId);
        insert tstRecMACC;                
        
        string ex = [select id,name from Muni_Agg__c where id =: tstRecMACC.id].name;
        
        LDC_Account__c tstRecLDCAcc1=new LDC_Account__c(Name='LDCName1',Account__c=tstpAccRec1.Id,Service_Territory__c='DAYTON',LDC_Vendor__c=tstRecLDCVendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='TSTMA0002');
        LDC_Account__c tstRecLDCAcc2=new LDC_Account__c(Name='LDCName2',Account__c=tstpAccRec2.Id,Service_Territory__c='DAYTON',LDC_Vendor__c=tstRecLDCVendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='TSTMA0004',Ldc_account_Status__c='Final');
        LDC_Account__c tstRecLDCAcc3=new LDC_Account__c(Name='LDCName1',Account__c=tstpAccRec3.Id,Service_Territory__c='DAYTON',LDC_Vendor__c=tstRecLDCVendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='TSTMA0002DUP',External_Reference_ID__c=ex);
        insert new List<LDC_Account__c>{tstRecLDCAcc1,tstRecLDCAcc2,tstRecLDCAcc3};
                    
        
        Muni_Agg__c tstRecMA = new Muni_Agg__c(BILLING_COUNTRY__C='Test MA Billing Country',  BILLING_STATE_PROVINCE__C='Test MA Billing State',  BILLING_STREET__C='Test MA Billing Street'
                        ,BILLING_ZIP_POSTAL_CODE__C='MA000001',   BILLING__C='Test MA Billing', EMAIL__C='testMA@testMA.com',   FIRST_NAME__C='Test MA FN',  LDC_ACCOUNT_NAME__C='Test MA LDC Account'   
                        ,LDC_ACCOUNT_NUMBER__C='TSTMA0001',    LDC_VENDOR__C=LDCName,  LAST_NAME__C='Test MA LN',   PHONE__C='9123456789',   SERVICE_CITY__C='Test MA SERVICE CITY' 
                        ,SERVICE_COUNTY__C='Test MA SERVICE COUNTY',    SERVICE_POSTAL_CODE__C='TSTMA0001', SERVICE_STATE__C='Test MA SERVICE STATE',   SERVICE_STREET_1__C='Test MA SERVICE STREET',RATE_CODE__C='RC001'  
                        ,SERVICE_STREET_2__C='Test MA SERVICE STREET 2',  SERVICE_TERRITORY__C='AEPOHIO',   CONTRACT_NUMBER__C=cNumber, PROCESSED__C=false, Muni_Agg_Customer_Id__c=custId);
                        
       Insert tstRecMA;
       
       Muni_Agg__c tstRecMA1 = tstRecMA.clone();
       tstRecMA1.Last_Name__c = ''; 
       
       Muni_Agg__c tstRecMA2 = tstRecMA.clone();
       tstRecMA2.LDC_ACCOUNT_NUMBER__C = ''; 
       
       Muni_Agg__c tstRecMA3 = tstRecMA.clone();
       tstRecMA3.LDC_ACCOUNT_NUMBER__C='TSTMA0002'; 
       
       Muni_Agg__c tstRecMA4 = tstRecMA.clone();
       tstRecMA4.LDC_ACCOUNT_NUMBER__C='TSTMA0004'; 
       
       Muni_Agg__c tstRecMA5 = tstRecMA.clone();
       tstRecMA4.LDC_ACCOUNT_NUMBER__C='TSTMA0005';
       tstRecMA5.LDC_VENDOR__C=''; 
       
       Muni_Agg__c tstRecMA6 = tstRecMA.clone();
       tstRecMA4.LDC_ACCOUNT_NUMBER__C='TSTMA0006';
       tstRecMA6.CONTRACT_NUMBER__C=''; 
       
       Muni_Agg__c tstRecMA7 = tstRecMA.clone();
       tstRecMA4.LDC_ACCOUNT_NUMBER__C='TSTMA0007';
       tstRecMA7.CONTRACT_NUMBER__C='c-11110000'; 
       
       Muni_Agg__c tstRecMA8 = tstRecMA.clone();
       tstRecMA4.LDC_ACCOUNT_NUMBER__C='TSTMA0008';
       tstRecMA8.PHONE__C='Testphone';
       
       insert new List<Muni_Agg__c>{tstRecMA1,tstRecMA2,tstRecMA3,tstRecMA4,tstRecMA5,tstRecMA6,tstRecMA7,tstRecMA8};
       
       String CRON_EXP = '0 0 * * * ?';
       Test.startTest(); 
       batchProcessMuniAgg.ProcessMuniAgg(custId);
       batchProcessMuniAgg.MuniAggCC(custId, tstRecMACC.id);
       String jobId = System.schedule('batchProcessMuniAggTest',CRON_EXP,new batchProcessMuniAgg());  
       
       Muni_Agg__c ma = [select id,name,processed__c,HAS_ERROR__C,LDC_Account_Number__c from Muni_Agg__c where isdeleted = false and LDC_ACCOUNT_NUMBER__C ='TSTMA0002DUP'limit 1];
       ldc_account__c ldc = [select Id, Account__r.Business_account__c, LDC_Account_Number__c,LDC_Account_Status__c,Contract__c,SERVICE_TERRITORY__C,External_Reference_ID__c from LDC_Account__c where External_Reference_ID__c =: ma.name limit 1];
       batchProcessMuniAgg.MuniAggCC(custId, ma.id);    
       Test.stopTest();
    }
    
    static testMethod void batchProcessMuniAgg_UnitTest2() {
    	batchProcessMuniAgg.ProcessMuniAgg('');
    	String CRON_EXP = '0 0 * * * ?';
    	String jobId = System.schedule('batchProcessMuniAggTest',CRON_EXP,new batchProcessMuniAgg());
    }
    
    static testMethod void batchProcessMuniAgg_UnitTest3() {
        ID CustRecMMId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Mass Market Offer').RecordTypeId;
        
        String custID = '';
        Account tstAccRec=new Account(Name='Test Mass Account',RecordTypeId=CustRecMMId,Billing_Entity__c='Dynegy');
        Insert tstAccRec;
        custId = String.ValueOf(tstAccRec.id).substring(0,15);
        
        batchProcessMuniAgg.ProcessMuniAgg(custId); 
    }
}