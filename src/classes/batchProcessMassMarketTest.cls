/* 
 * Name: batchProcessMassMarketTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the batchProcessMassMarket Apex Batch Class.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         03/20/2016       1. Initial Version created
 * 2.0         Prasad                       08/29/2016       1. Modified because of no code coverage 
 */
@isTest 
private class batchProcessMassMarketTest {

    static testMethod void batchProcessMassMarket_UnitTest() {
        
        ID CustRecMMId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Mass Market Offer').RecordTypeId;
        
        Supplier__c tstSupRec = new Supplier__c(Active__c = true,Supplier_Code__c='TstMM001',Supplier_DUNS__c='TstMMDUNS001');
        Insert tstSupRec;
        
        Account tstAccRec=new Account(Name='Test Mass Market Account',RecordTypeId=CustRecMMId,OFFER_CODE__C='OCMM001',Supplier__c=tstSupRec.Id,Billing_Entity__c='Dynegy');
        Insert tstAccRec;
        
        Account tstAccRec1=new Account(Name='Test Mass Market Account 123',RecordTypeId=CustRecMMId,OFFER_CODE__C='OCMM004',Supplier__c=tstSupRec.Id,Billing_Entity__c='Dynegy');
        Insert tstAccRec1;
        
        LDC_Vendor__c tstRecLDCVendor=new LDC_Vendor__c(Name='Test Vendor MM001',Service_Territory__c='DAYTON',DUNS__c='MM001',Utility_Code__c='MM0001',Service_State__c = 'OH');
        Insert tstRecLDCVendor;
        
        list<LDC_Account__c> ldclst = new list<LDC_Account__c>();
        LDC_Account__c tstRecLDCAcc=new LDC_Account__c(Name='Test LDC Account MM001',Account__c=tstAccRec.Id,Service_Territory__c='DAYTON',LDC_Vendor__c=tstRecLDCVendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='TSTMM0002');
        ldclst.add(tstRecLDCAcc);
        
        LDC_Account__c tstRecLDCAcc1=new LDC_Account__c(Name='Test LDC Account MM005',Account__c=tstAccRec.Id,Service_Territory__c='DAYTON',LDC_Vendor__c=tstRecLDCVendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='TSTMM0005');
        ldclst.add(tstRecLDCAcc1);
        insert ldclst;
                    
        Contract tstRecCtrt=new Contract(Name='Test Contract MM001',Rate_Code__c='RC001',StartDate=Date.today(),Status='Draft',AccountId=tstAccRec.Id,contractTerm=12); 
        Insert tstRecCtrt;
        
        Mass_Market__c tstRecMM = new Mass_Market__c(BILLING_COUNTRY__C='Test MM Billing Country',  BILLING_STATE_PROVINCE__C='Test MM Billing State',  BILLING_STREET__C='Test MM Billing Street'
                        ,BILLING_ZIP_POSTAL_CODE__C='MM000001',   BILLING__C='Test MM Billing', EMAIL__C='testmm@testmm.com',   FIRST_NAME__C='Test MM FN',  LDC_ACCOUNT_NAME__C='Test MM LDC Account'   
                        ,LDC_ACCOUNT_NUMBER__C='TSTMM0001',    LDC_VENDOR__C='Test Vendor MM001',  LAST_NAME__C='Test MM LN',   PHONE__C='9123456789',   SERVICE_CITY__C='Test MM SERVICE CITY' 
                        ,SERVICE_COUNTY__C='Test MM SERVICE COUNTY',    SERVICE_POSTAL_CODE__C='TSTMM0001', SERVICE_STATE__C='Test MM SERVICE STATE',   SERVICE_STREET_1__C='Test MM SERVICE STREET',RATE_CODE__C='RC001'  
                        ,SERVICE_STREET_2__C='Test MM SERVICE STREET 2',  SERVICE_TERRITORY__C='Test MM SERVICE TERITORY',   PROCESSED__C=false, OFFER_CODE__C='OCMM001');
                        
       Insert tstRecMM;
       
       Mass_Market__c tstRecMM1 = tstRecMM.clone();
       tstRecMM1.Last_Name__c = ''; 
       Insert tstRecMM1;
       
       Mass_Market__c tstRecMM2 = tstRecMM.clone();
       tstRecMM2.LDC_ACCOUNT_NUMBER__C = ''; 
       Insert tstRecMM2;
       
       Mass_Market__c tstRecMM3 = tstRecMM.clone();
       tstRecMM3.LDC_ACCOUNT_NUMBER__C='TSTMM0002'; 
       Insert tstRecMM3;
       
       Mass_Market__c tstRecMM5 = tstRecMM.clone();
       tstRecMM5.LDC_ACCOUNT_NUMBER__C='TSTMM0005'; 
       tstRecMM5.LDC_VENDOR__C='';
       tstRecMM5.OFFER_CODE__C = 'OCMM004';
       Insert tstRecMM5;
       
       Bill_Cycle_Date__c bcd=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=tstRecLDCVendor.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
       insert bcd;
       
       time t =datetime.now().time();
        system.debug(''+t+' : '+t.minute()+' : '+t.hour());
        String schTime = '0 0 '+t.hour()+' * * ?';
       Test.startTest();                
          string JobId = batchProcessMassMarket.ProcessMassMarket();
          batchProcessMassMarket bMM = new batchProcessMassMarket();
          System.schedule('batchProcessMassMarketTest',schTime,bMM);
          database.executeBatch(bMM);
       Test.stopTest(); 
    }
    
    static testMethod void batchProcessMassMarket_UnitTest2() {
        
        ID CustRecMMId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Mass Market Offer').RecordTypeId;
        
        Supplier__c tstSupRec = new Supplier__c(Active__c = true,Supplier_Code__c='TstMM001',Supplier_DUNS__c='TstMMDUNS001');
        Insert tstSupRec;
        
        Account tstAccRec=new Account(Name='Test Mass Market Account',RecordTypeId=CustRecMMId,OFFER_CODE__C='OCMM002',Supplier__c=tstSupRec.Id,Billing_Entity__c='Dynegy');
        Insert tstAccRec;
        
        Account tstAccRec1=new Account(Name='Test Mass Market Account 123',RecordTypeId=CustRecMMId,OFFER_CODE__C='OCMM003',Supplier__c=tstSupRec.Id,Billing_Entity__c='Dynegy');
        Insert tstAccRec1;
        
        LDC_Vendor__c tstRecLDCVendor=new LDC_Vendor__c(Name='Test Vendor MM001',Service_Territory__c='DAYTON',DUNS__c='MM001',Utility_Code__c='MM0001',Service_State__c = 'OH');
        Insert tstRecLDCVendor;
        
        LDC_Account__c tstRecLDCAcc=new LDC_Account__c(Name='Test LDC Account MM001',Account__c=tstAccRec.Id,Service_Territory__c='DAYTON',LDC_Vendor__c=tstRecLDCVendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='TSTMM0002',LDC_Account_Status__c='Active');
        Insert tstRecLDCAcc;
                    
        Contract tstRecCtrt=new Contract(Name='Test Contract MM001',Rate_Code__c='RC002',StartDate=Date.today(),Status='Draft',AccountId=tstAccRec.Id,contractTerm=12); 
        Insert tstRecCtrt;
        
        Mass_Market__c tstRecMM = new Mass_Market__c(BILLING_COUNTRY__C='Test MM Billing Country',  BILLING_STATE_PROVINCE__C='Test MM Billing State',  BILLING_STREET__C='Test MM Billing Street'
                        ,BILLING_ZIP_POSTAL_CODE__C='MM000001',   BILLING__C='Test MM Billing', EMAIL__C='testmm@testmm.com',   FIRST_NAME__C='Test MM FN',  LDC_ACCOUNT_NAME__C='Test MM LDC Account'   
                        ,LDC_ACCOUNT_NUMBER__C='TSTMM0001',    LDC_VENDOR__C='Test Vendor MM001',  LAST_NAME__C='Test MM LN',   PHONE__C='9123456789',   SERVICE_CITY__C='Test MM SERVICE CITY' 
                        ,SERVICE_COUNTY__C='Test MM SERVICE COUNTY',    SERVICE_POSTAL_CODE__C='TSTMM0001', SERVICE_STATE__C='Test MM SERVICE STATE',   SERVICE_STREET_1__C='Test MM SERVICE STREET',RATE_CODE__C='RC002'  
                        ,SERVICE_STREET_2__C='Test MM SERVICE STREET 2',  SERVICE_TERRITORY__C='Test MM SERVICE TERITORY',   PROCESSED__C=false, OFFER_CODE__C='OCMM002');
                        
       Insert tstRecMM;
       
       Mass_Market__c tstRecMM1 = tstRecMM.clone();
       tstRecMM1.Last_Name__c = ''; 
       
       Mass_Market__c tstRecMM2 = tstRecMM.clone();
       tstRecMM2.LDC_ACCOUNT_NUMBER__C = ''; 
       
       Mass_Market__c tstRecMM3 = tstRecMM.clone();
       tstRecMM3.LDC_ACCOUNT_NUMBER__C='TSTMM0002';
       
       Mass_Market__c tstRecMM4 = tstRecMM.clone();
       tstRecMM4.LDC_ACCOUNT_NUMBER__C='TSTMM0004'; 
       tstRecMM4.OFFER_CODE__C = 'OCMM1234';
       
       Mass_Market__c tstRecMM5 = tstRecMM.clone();
       tstRecMM5.LDC_ACCOUNT_NUMBER__C='TSTMM0005'; 
       tstRecMM5.LDC_VENDOR__C='';
       tstRecMM5.OFFER_CODE__C = 'OCMM003';
       
       Mass_Market__c tstRecMM6 = tstRecMM.clone();
       tstRecMM6.FIRST_NAME__C='';
       tstRecMM6.LDC_ACCOUNT_NUMBER__C='TSTMM0006'; 
       tstRecMM6.SERVICE_TERRITORY__C = 'DAYTON'; 
       
       insert new List<Mass_Market__c>{tstRecMM1,tstRecMM2,tstRecMM3,tstRecMM4,tstRecMM5,tstRecMM6};
       
       Bill_Cycle_Date__c bcd=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=tstRecLDCVendor.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
       insert bcd;
       Bill_Cycle_Date__c bcd1=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=tstRecLDCVendor.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().addmonths(1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
       insert bcd1;
       Bill_Cycle_Date__c bcd2=new Bill_Cycle_Date__c(Bill_Cycle__c=1,LDC_Vendor__c=tstRecLDCVendor.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
       insert bcd2;
       Bill_Cycle_Date__c bcd3=new Bill_Cycle_Date__c(Bill_Cycle__c=1,LDC_Vendor__c=tstRecLDCVendor.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().addmonths(1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
       insert bcd3;
       
       String result = batchProcessMassMarket.ProcessMassMarket();
       
       time t =datetime.now().time();
        system.debug(''+t+' : '+t.minute()+' : '+t.hour());
        String schTime = '0 0 '+t.hour()+' * * ?';
       Test.startTest();                
          batchProcessMassMarket bMM = new batchProcessMassMarket();
          System.schedule('batchProcessMassMarketTest',schTime,bMM);
          database.executeBatch(bMM);
       Test.stopTest();
    }
}