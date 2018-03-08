/**
 * This class is designed to provide code coverage for FRMReport class.
 *
 * @CreatedBy Prasad Paladugu
 * @version 1.0
 **/

@isTest
public class FRMReportTest {
    
    public static testmethod void FRMReportTest1(){
        
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        Schema.RecordTypeInfo massMarketRecType = acctRecTypeMap.get('Mass Market Offer');
        Schema.RecordTypeInfo massMarketIndRecType = acctRecTypeMap.get('Mass Market Individual Customer');
        Schema.RecordTypeInfo muniRecType = acctRecTypeMap.get('Muni Agg Customer');
        Schema.RecordTypeInfo muniIndRecType = acctRecTypeMap.get('Muni Agg Individual Customer');
        Schema.DescribeSObjectResult dsr1 = Opportunity.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> oppRecTypeMap = dsr1.getRecordTypeInfosByName();
        Schema.RecordTypeInfo oppRecType = oppRecTypeMap.get('Standard Opportunity');
        Schema.DescribeSObjectResult dsr2 = Retail_Quote__c.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> rqRecTypeMap = dsr2.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rqRecType = rqRecTypeMap.get('Executable');
        
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST',
                                                           Active__c = true);
        insert testOperatingCompany;
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDR',Service_Territory__c = 'AEPOHIO',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        List<Account> testAcctList = new List<Account>();
        testAcctList.add(new Account(RecordTypeId = ciAcctRecType.getRecordTypeId(),Name='Test C&I',Supplier__c = testOperatingCompany.Id,Billing_Entity__c='Dynegy'));
        
        testAcctList.add(new Account(Name='Test MM Offer',Offer_Code__c = 'XEN-F23-45RT',Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        
        testAcctList.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'TestMass',LastName = 'MarketIndividualAcct',PersonMailingStreet = '4171 Still Street',
                                     PersonMailingPostalCode = '45819',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2441',
                                     Billing_Entity__c='Dynegy'));
                                     
        testAcctList.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'TestMass',LastName = 'MarketIndividualAcct 2',PersonMailingStreet = '4172 Still Street',
                                     PersonMailingPostalCode = '45820',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2442',
                                     Billing_Entity__c='Dynegy'));
        
        testAcctList.add(new Account(RecordTypeId = ciAcctRecType.getRecordTypeId(),Name='Test C&I 2',Supplier__c = testOperatingCompany.Id,Billing_Entity__c='Dynegy'));
        
        testAcctList.add(new Account(RecordTypeId = ciAcctRecType.getRecordTypeId(),Name='Test C&I 3',Supplier__c = testOperatingCompany.Id,Billing_Entity__c='Dynegy'));
        testAcctList.add(new Account(RecordTypeId = ciAcctRecType.getRecordTypeId(),Name='Test C&I 4',Supplier__c = testOperatingCompany.Id,Billing_Entity__c='Dynegy'));
        testAcctList.add(new Account(RecordTypeId = ciAcctRecType.getRecordTypeId(),Name='Test C&I 5',Supplier__c = testOperatingCompany.Id,Billing_Entity__c='Dynegy'));
        
        testAcctList.add(new Account(Name='Test MA township',Supplier__c = testOperatingCompany.Id,RecordTypeId = muniRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        
        testAcctList.add(new Account(RecordTypeId = muniIndRecType.getRecordTypeId(),FirstName = 'TestMuni',LastName = 'IndividualAcct',PersonMailingStreet = '4171 Still Street',
                                     PersonMailingPostalCode = '45819',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2441',
                                     Billing_Entity__c='Dynegy'));
                                     
        testAcctList.add(new Account(RecordTypeId = muniIndRecType.getRecordTypeId(),FirstName = 'TestMuni',LastName = 'IndividualAcct 2',PersonMailingStreet = '4172 Still Street',
                                     PersonMailingPostalCode = '45820',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2442',
                                     Billing_Entity__c='Dynegy'));
        
        insert testAcctList;
        testAcctList[2].Business_account__c = testAcctList[1].id;
        update testAcctList[2];
        testAcctList[3].Business_account__c = testAcctList[1].id;
        update testAcctList[3];
        testAcctList[9].Business_account__c = testAcctList[8].id;
        update testAcctList[9];
        testAcctList[10].Business_account__c = testAcctList[8].id;
        update testAcctList[10];
        
        List<ldc_account__c> ldclist = new List<ldc_account__c>();
        ldclist.add(new ldc_account__c(Name='Test CI 1',ldc_account_number__c='CI826598252559',account__c=testAcctList[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=23.235,NSPL2_KW__c=398.238598,
                                       Off_Pk_Kwh__c=25.346,On_Pk_Kwh__c=238.232));
        
        ldclist.add(new ldc_account__c(Name='Test CI 2',ldc_account_number__c='CI2348259825',account__c=testAcctList[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='ISSI3',Utility_Rate_Class__c='OE-84AEP',Utility_Zone__c='AEP',Acct_ADU__c=235.253,NSPL2_KW__c=33.525,
                                       Off_Pk_Kwh__c=2435.223,On_Pk_Kwh__c=235.323));
        
        ldclist.add(new ldc_account__c(Name='Test CI 3',ldc_account_number__c='CI58762856265',account__c=testAcctList[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='N/A',Utility_Rate_Class__c='DS6',Utility_Zone__c='AEP',Acct_ADU__c=235.231,NSPL2_KW__c=52.4323,
                                       Off_Pk_Kwh__c=634.5235,On_Pk_Kwh__c=34.352));
        
        ldclist.add(new ldc_account__c(Name='Test CI 4',ldc_account_number__c='CI324563280458',account__c=testAcctList[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='',Utility_Rate_Class__c='DS6',Utility_Zone__c='',Acct_ADU__c=143.233,NSPL2_KW__c=34.6321,
                                       Off_Pk_Kwh__c=343.25,On_Pk_Kwh__c=3463.3));
                                       
        ldclist.add(new ldc_account__c(Name='Test MM 1',ldc_account_number__c='MM3265498057285',account__c=testAcctList[2].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=643.637,NSPL2_KW__c=832.436,
                                       Off_Pk_Kwh__c=834.22,On_Pk_Kwh__c=324.67));
        
        ldclist.add(new ldc_account__c(Name='Test MM 2',ldc_account_number__c='MM3264509857',account__c=testAcctList[3].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=84.433,NSPL2_KW__c=346.22,
                                       Off_Pk_Kwh__c=346.436,On_Pk_Kwh__c=1.4674));
        
        ldclist.add(new ldc_account__c(Name='Test CI 2',ldc_account_number__c='CI298359034838',account__c=testAcctList[4].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='IS-03HY',Utility_Zone__c='AEP',Acct_ADU__c=5.3245,NSPL2_KW__c=345.22,
                                       Off_Pk_Kwh__c=23.552,On_Pk_Kwh__c=235.12));
        
        ldclist.add(new ldc_account__c(Name='Test CI 3',ldc_account_number__c='CI3254635932',account__c=testAcctList[5].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='N/A',Utility_Rate_Class__c='',Utility_Zone__c=''));
                                       
        ldclist.add(new ldc_account__c(Name='Test CI 4',ldc_account_number__c='CI464687324590',account__c=testAcctList[5].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='',Utility_Rate_Class__c='',Utility_Zone__c=''));
                                       
        ldclist.add(new ldc_account__c(Name='Test CI 5',ldc_account_number__c='CI4564545743',account__c=testAcctList[6].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=23.235,NSPL2_KW__c=398.238598,
                                       Off_Pk_Kwh__c=25.346,On_Pk_Kwh__c=238.232));
        
        ldclist.add(new ldc_account__c(Name='Test CI 6',ldc_account_number__c='CI4574578483',account__c=testAcctList[6].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='ISSI3',Utility_Rate_Class__c='OE-84AEP',Utility_Zone__c='AEP',Acct_ADU__c=235.253,NSPL2_KW__c=33.525,
                                       Off_Pk_Kwh__c=2435.223,On_Pk_Kwh__c=235.323));
        
        ldclist.add(new ldc_account__c(Name='Test CI 7',ldc_account_number__c='CI79342658773',account__c=testAcctList[7].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='IS-03HY',Utility_Zone__c='AEP',Acct_ADU__c=5.3245,NSPL2_KW__c=345.22,
                                       Off_Pk_Kwh__c=23.552,On_Pk_Kwh__c=235.12));
        
        ldclist.add(new ldc_account__c(Name='Test CI 8',ldc_account_number__c='CI58365463576',account__c=testAcctList[7].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='IS-03HY',Utility_Zone__c='AEP',Acct_ADU__c=3465.3245,NSPL2_KW__c=345.22,
                                       Off_Pk_Kwh__c=646.552,On_Pk_Kwh__c=235.12));                               
        
        ldclist.add(new ldc_account__c(Name='Test CI 8',ldc_account_number__c='MA58365463576',account__c=testAcctList[9].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='IS-03HY',Utility_Zone__c='AEP',Acct_ADU__c=3465.3245,NSPL2_KW__c=345.22,
                                       Off_Pk_Kwh__c=646.552,On_Pk_Kwh__c=235.12));                               
        
        ldclist.add(new ldc_account__c(Name='Test CI 8',ldc_account_number__c='MA45457457',account__c=testAcctList[10].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='IS-03HY',Utility_Zone__c='AEP',Acct_ADU__c=3465.3245,NSPL2_KW__c=345.22,
                                       Off_Pk_Kwh__c=646.552,On_Pk_Kwh__c=235.12));                               
        insert ldclist;
        
        List<opportunity> opplist = new List<opportunity>();
        opplist.add(new Opportunity(Name='Test CI opp',accountid=testAcctList[0].id,type='C&I',Service_Territory__c='AEPOHIO',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test MM opp',accountid=testAcctList[1].id,type='Mass-Market',Service_Territory__c='AEPOHIO',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test MM opp 1',accountid=testAcctList[1].id,type='Mass-Market',Service_Territory__c='AEPOHIO',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test MM opp 2',accountid=testAcctList[1].id,type='Mass-Market',Service_Territory__c='DEOHIO',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test CI opp 1',accountid=testAcctList[4].id,type='Mass-Market',Service_Territory__c='FEOHIO',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test CI opp 2',accountid=testAcctList[5].id,type='Mass-Market',Service_Territory__c='DAYTON',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test MA opp ',accountid=testAcctList[8].id,type='MuniAgg',Service_Territory__c='DAYTON',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        insert opplist;
        
        List<opportunity_ldc__c> oldclist = new List<opportunity_ldc__c>();
        oldclist.add(new opportunity_ldc__c(ldc_account__c = ldclist[0].id, opportunity__c = opplist[0].id));
        oldclist.add(new opportunity_ldc__c(ldc_account__c = ldclist[1].id, opportunity__c = opplist[0].id));
        oldclist.add(new opportunity_ldc__c(ldc_account__c = ldclist[2].id, opportunity__c = opplist[0].id));
        oldclist.add(new opportunity_ldc__c(ldc_account__c = ldclist[6].id, opportunity__c = opplist[4].id));
        
        insert oldclist;
        
        ldclist[0].Acct_ADU__c+= 0.0001;  
        ldclist[1].Acct_ADU__c+= 0.0001;
        ldclist[2].Acct_ADU__c+= 0.0001;
        ldclist[3].Acct_ADU__c+= 0.0001;
        ldclist[6].Acct_ADU__c+= 0.0001;  
        ldclist[7].is_record_updated__c= true;
        ldclist[8].is_record_updated__c= true;
        ldclist[9].Acct_ADU__c+= 0.0001;
        ldclist[10].Acct_ADU__c+= 0.0001;
        ldclist[11].Acct_ADU__c+= 0.0001;
        update ldclist;
        
        List<product2> prolist = new List<product2>();
        prolist.add(new product2(name='FP-Test',isactive=true));
        prolist.add(new product2(name='BI-Test',isactive=true));
        prolist.add(new product2(name='PCTG-Test',isactive=true));
        insert prolist;
        
        List<Retail_Quote__c> rqlist = new List<Retail_Quote__c>();
        rqlist.add(new Retail_Quote__c(Product__c=prolist[0].id,Payment_Terms__c='21',Opportunity__c=opplist[0].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'Test Utility'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[1].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'Test Utility'));
        
        rqlist.add(new Retail_Quote__c(Product__c=prolist[0].id,Payment_Terms__c='21',Opportunity__c=opplist[2].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'Test Utility'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[1].id,Payment_Terms__c='21',Opportunity__c=opplist[3].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'DEOK_RESID_AGG'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[4].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'FEOH_RESID_AGG'));
                                                                   
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[5].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'DAY_RESID_AGG'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[6].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'DAY_RESID_AGG',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;CGETUI-II,2314.1243;DSS0-1-II,3873.2355;CGSSOH-III,12.445;null,53.645;'));
                                       
        insert rqlist;
        
        rqlist[0].Request_Status__c ='Pricing Complete';
        rqlist[1].Request_Status__c ='Pricing Complete';
        rqlist[2].Request_Status__c ='Pricing Complete';
        rqlist[3].Request_Status__c ='Pricing Complete';
        rqlist[4].Request_Status__c ='Pricing Complete';
        rqlist[5].Request_Status__c ='Pricing Complete';
        rqlist[6].Request_Status__c ='Pricing Complete';
        update rqlist;
        
        List<Contract> cntlist = new List<Contract>();
        cntlist.add(new Contract(AccountId=testAcctList[0].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST123',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Retail_Quote__c=rqlist[0].id,
                                 Opportunity__c=opplist[0].id));
                                 
        cntlist.add(new Contract(AccountId=testAcctList[1].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Retail_Quote__c=rqlist[1].id,
                                 Opportunity__c=opplist[1].id));
        
        cntlist.add(new Contract(AccountId=testAcctList[1].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Retail_Quote__c=rqlist[2].id,
                                 Opportunity__c=opplist[2].id));
        
        cntlist.add(new Contract(AccountId=testAcctList[1].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Retail_Quote__c=rqlist[3].id,
                                 Opportunity__c=opplist[3].id));
                                 
        cntlist.add(new Contract(AccountId=testAcctList[4].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Retail_Quote__c=rqlist[4].id,
                                 Opportunity__c=opplist[4].id));
                                                                                                            
        cntlist.add(new Contract(AccountId=testAcctList[5].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Retail_Quote__c=rqlist[5].id,
                                 Opportunity__c=opplist[5].id));
        
        cntlist.add(new Contract(AccountId=testAcctList[6].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO'));
                                 
        cntlist.add(new Contract(AccountId=testAcctList[7].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Ameren-IL'));
        
        cntlist.add(new Contract(AccountId=testAcctList[8].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Retail_Quote__c=rqlist[6].id,
                                 Opportunity__c=opplist[6].id));
        
        insert cntlist;
        cntlist[0].Status = 'Activated';
        cntlist[0].RPS__c = 0.7;
        cntlist[0].Vol_Rec__c = 1.5;
        cntlist[0].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[1].Status = 'Activated';
        cntlist[1].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[2].Status = 'Cancelled';
        cntlist[2].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[3].Status = 'Expired';
        cntlist[3].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[4].Status = 'Activated';
        cntlist[4].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[5].Status = 'Activated';
        cntlist[5].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[6].Status = 'Activated';
        cntlist[6].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[7].Status = 'Activated';
        cntlist[7].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[8].Status = 'Activated';
        cntlist[8].Contract_Counter_Signed_Date__c = datetime.now();
        update cntlist;
        
        FRMReport frm = new FRMReport();
        Database.executeBatch(frm);

        ldclist[0].Acct_ADU__c+= 0.0001;
        update ldclist[0];
        
        ldc_account__c ldcnew = new ldc_account__c(Name='Test CI 5',ldc_account_number__c='CI238652354838',account__c=testAcctList[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='EZ2',Utility_Rate_Class__c='IS-03HY',Utility_Zone__c='AEP',Acct_ADU__c=42.256,NSPL2_KW__c=43.253,Off_Pk_Kwh__c=328.536,On_Pk_Kwh__c=6.336);
                                       
        insert ldcnew;
        
        ldc_account__c ldcnew1 = new ldc_account__c(Name='Test CI 6',ldc_account_number__c='CI32456870345',account__c=testAcctList[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor.id,
                                       FRM_Profile__c='EZ2',Utility_Rate_Class__c='IS-03HY',Utility_Zone__c='AEP',Acct_ADU__c=3434.43,NSPL2_KW__c=15.2563,Off_Pk_Kwh__c=345.545,On_Pk_Kwh__c=3.3687);
        insert ldcnew1;
        
        decimal adu;
        decimal NSPLC;
        decimal tot;
        decimal CPLC;
        decimal CusPLC;
        string vnd;
        string rateclass;
        integer tAcc;
        LDCinfo.cusWrapper lc = new LDCinfo.cusWrapper(adu,NSPLC,CPLC,CusPLC,tot,rateclass,vnd,tAcc);
        
        time t =datetime.now().time();
        system.debug(''+t+' : '+t.minute()+' : '+t.hour());
        String schTime = '0 0 '+t.hour()+' * * ?';
        system.schedule('Test FRM', schTime, frm);
        Database.executeBatch(frm);

		ldclist[0].is_record_updated__c= true;  
        ldclist[1].is_record_updated__c= true;
        ldclist[2].is_record_updated__c= true;
        ldclist[3].is_record_updated__c= true;
        ldclist[4].is_record_updated__c= true;  
        ldclist[5].is_record_updated__c= true;
        ldclist[6].is_record_updated__c= true;
        ldclist[7].is_record_updated__c= true;
        ldclist[8].is_record_updated__c= true;  
        ldclist[9].is_record_updated__c= true;
        ldclist[10].is_record_updated__c= true;
        ldclist[11].is_record_updated__c= true;
        ldclist[12].is_record_updated__c= true;
        update ldclist;
        
        LDCinfo linfo = new LDCinfo();
        system.schedule('LDC Batch', schTime, linfo);
        /*FRMReport frmupdate = new FRMReport();
        Database.executeBatch(frmupdate);*/
        
    }
    
    public static testmethod void FRMReportTest2(){
        
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        Schema.RecordTypeInfo massMarketRecType = acctRecTypeMap.get('Mass Market Offer');
        Schema.RecordTypeInfo massMarketIndRecType = acctRecTypeMap.get('Mass Market Individual Customer');
        Schema.RecordTypeInfo muniRecType = acctRecTypeMap.get('Muni Agg Customer');
        Schema.RecordTypeInfo muniIndRecType = acctRecTypeMap.get('Muni Agg Individual Customer');
        Schema.DescribeSObjectResult dsr1 = Opportunity.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> oppRecTypeMap = dsr1.getRecordTypeInfosByName();
        Schema.RecordTypeInfo oppRecType = oppRecTypeMap.get('Standard Opportunity');
        Schema.DescribeSObjectResult dsr2 = Retail_Quote__c.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> rqRecTypeMap = dsr2.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rqRecType = rqRecTypeMap.get('Executable');
        
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST',
                                                           Active__c = true);
        insert testOperatingCompany;
        LDC_Vendor__c testVendor1 = new LDC_Vendor__c(Name='Test Vendor OH',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDROH',Service_Territory__c = 'AEPOHIO',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        LDC_Vendor__c testVendor2 = new LDC_Vendor__c(Name='Test Vendor IL',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDRIL',Service_Territory__c = 'Comed-IL',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'IL');
		insert new list<ldc_vendor__c>{testVendor1,testVendor2};
		
		List<Account> BAcct = new List<Account>();
        BAcct.add(new Account(RecordTypeId = ciAcctRecType.getRecordTypeId(),Name='Test C&I OH',Supplier__c = testOperatingCompany.Id,Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(Name='Test MM Offer OH',Offer_Code__c = 'XEN-F23-45RT',Supplier__c = testOperatingCompany.Id,RecordTypeId = massMarketRecType.getRecordTypeId(),
        							Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(Name='Test Muni-Agg OH',Supplier__c = testOperatingCompany.Id,RecordTypeId = muniRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(RecordTypeId = ciAcctRecType.getRecordTypeId(),Name='Test C&I IL',Supplier__c = testOperatingCompany.Id,Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(Name='Test MM Offer IL',Offer_Code__c = 'WUH-RWU-656ET',Supplier__c = testOperatingCompany.Id,RecordTypeId = massMarketRecType.getRecordTypeId(),
        							Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(Name='Test Muni-Agg IL',Supplier__c = testOperatingCompany.Id,RecordTypeId = muniRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(RecordTypeId = ciAcctRecType.getRecordTypeId(),Name='Test C&I Null OH 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890',
        							Supplier__c = testOperatingCompany.Id,Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(Name='Test MM Offer NULL OH',Offer_Code__c = 'F6F-798SR',Supplier__c = testOperatingCompany.Id,RecordTypeId = massMarketRecType.getRecordTypeId(),
        							Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(Name='Test Muni-Agg NULL OH',Supplier__c = testOperatingCompany.Id,RecordTypeId = muniRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(Name='Test Muni-Agg AM-IL',Supplier__c = testOperatingCompany.Id,RecordTypeId = muniRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(Name='Test Muni-Agg AM-IL3',Supplier__c = testOperatingCompany.Id,RecordTypeId = muniRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        BAcct.add(new Account(Name='Test Muni-Agg AM-IL4',Supplier__c = testOperatingCompany.Id,RecordTypeId = muniRecType.getRecordTypeId(),Billing_Entity__c='Dynegy'));
        insert BAcct;
        
        List<Account> PAcct = new List<Account>();
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'TestMass',LastName = 'MarketIndividualAcct OH1',PersonMailingStreet = '4171 Still Street',
                                     PersonMailingPostalCode = '45819',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2441',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[1].id));
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'TestMass',LastName = 'MarketIndividualAcct OH2',PersonMailingStreet = '4172 Still Street',
                                     PersonMailingPostalCode = '45820',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2442',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[1].id));
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'Test',LastName = 'MuniIndividualAcct OH1',PersonMailingStreet = '4171 Still Street',
                                     PersonMailingPostalCode = '45819',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2441',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[2].id));
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'Test',LastName = 'MuniIndividualAcct OH2',PersonMailingStreet = '4172 Still Street',
                                     PersonMailingPostalCode = '45820',PersonMailingCity = 'Buckland',PersonMailingState = 'OH',PersonEmail='test@test.com',PersonHomePhone='419-657-2442',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[2].id));
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'TestMass',LastName = 'MarketIndividualAcct IL1',PersonMailingStreet = '4171 Still Street',
                                     PersonMailingPostalCode = '45819',PersonMailingCity = 'Buckland',PersonMailingState = 'IL',PersonEmail='test@test.com',PersonHomePhone='419-657-2441',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[4].id));
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'TestMass',LastName = 'MarketIndividualAcct IL2',PersonMailingStreet = '4172 Still Street',
                                     PersonMailingPostalCode = '45820',PersonMailingCity = 'Buckland',PersonMailingState = 'IL',PersonEmail='test@test.com',PersonHomePhone='419-657-2442',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[4].id));   
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'Test',LastName = 'MuniIndividualAcct IL1',PersonMailingStreet = '4171 Still Street',
                                     PersonMailingPostalCode = '45819',PersonMailingCity = 'Buckland',PersonMailingState = 'IL',PersonEmail='test@test.com',PersonHomePhone='419-657-2441',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[5].id));
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'Test',LastName = 'MuniIndividualAcct IL2',PersonMailingStreet = '4172 Still Street',
                                     PersonMailingPostalCode = '45820',PersonMailingCity = 'Buckland',PersonMailingState = 'IL',PersonEmail='test@test.com',PersonHomePhone='419-657-2442',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[5].id));       
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'Test',LastName = 'MuniIndividualAcct IL3',PersonMailingStreet = '4172 Still Street',
                                     PersonMailingPostalCode = '45820',PersonMailingCity = 'Buckland',PersonMailingState = 'IL',PersonEmail='test@test.com',PersonHomePhone='419-657-2442',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[10].id));       
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'Test',LastName = 'MuniIndividualAcct IL4',PersonMailingStreet = '4172 Still Street',
                                     PersonMailingPostalCode = '45820',PersonMailingCity = 'Buckland',PersonMailingState = 'IL',PersonEmail='test@test.com',PersonHomePhone='419-657-2442',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[10].id));       
        PAcct.add(new Account(RecordTypeId = massMarketIndRecType.getRecordTypeId(),FirstName = 'Test',LastName = 'MuniIndividualAcct IL5',PersonMailingStreet = '4172 Still Street',
                                     PersonMailingPostalCode = '45820',PersonMailingCity = 'Buckland',PersonMailingState = 'IL',PersonEmail='test@test.com',PersonHomePhone='419-657-2442',
                                     Billing_Entity__c='Dynegy',Business_account__c = BAcct[11].id));       
        insert PAcct;    
        
        List<ldc_account__c> ldclist = new List<ldc_account__c>();
        ldclist.add(new ldc_account__c(Name='Test MM OH 1',ldc_account_number__c='MM826598252559',account__c=PAcct[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=23.235,NSPL2_KW__c=398.238598,
                                       Off_Pk_Kwh__c=25.346,On_Pk_Kwh__c=238.232));
        
        ldclist.add(new ldc_account__c(Name='Test MM OH 2',ldc_account_number__c='MM2348259825',account__c=PAcct[1].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='OE-84AEP',Utility_Zone__c='AEP',Acct_ADU__c=235.253,NSPL2_KW__c=33.525,
                                       Off_Pk_Kwh__c=2435.223,On_Pk_Kwh__c=235.323));
        
        ldclist.add(new ldc_account__c(Name='Test MU OH 1',ldc_account_number__c='MU58762856265',account__c=PAcct[2].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='N/A',Utility_Rate_Class__c='DS6',Utility_Zone__c='AEP',Acct_ADU__c=235.231,NSPL2_KW__c=52.4323,
                                       Off_Pk_Kwh__c=634.5235,On_Pk_Kwh__c=34.352));
        
        ldclist.add(new ldc_account__c(Name='Test MU OH 2',ldc_account_number__c='MU324563280458',account__c=PAcct[3].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='',Utility_Rate_Class__c='DS6',Utility_Zone__c='',Acct_ADU__c=143.233,NSPL2_KW__c=34.6321,
                                       Off_Pk_Kwh__c=343.25,On_Pk_Kwh__c=3463.3));
                                       
        ldclist.add(new ldc_account__c(Name='Test MM IL 1',ldc_account_number__c='MM3265498057285',account__c=PAcct[4].id,Service_Territory__c='Comed-IL',LDC_Vendor__c=testVendor2.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=643.637,NSPL2_KW__c=832.436,
                                       Off_Pk_Kwh__c=834.22,On_Pk_Kwh__c=324.67));
        
        ldclist.add(new ldc_account__c(Name='Test MM IL 2',ldc_account_number__c='MM3264509857',account__c=PAcct[5].id,Service_Territory__c='Comed-IL',LDC_Vendor__c=testVendor2.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=84.433,NSPL2_KW__c=346.22,
                                       Off_Pk_Kwh__c=346.436,On_Pk_Kwh__c=1.4674));
        
        ldclist.add(new ldc_account__c(Name='Test MU IL 1',ldc_account_number__c='MU298359034838',account__c=PAcct[6].id,Service_Territory__c='Comed-IL',LDC_Vendor__c=testVendor2.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='IS-03HY',Utility_Zone__c='AEP',Acct_ADU__c=5.3245,NSPL2_KW__c=345.22,
                                       Off_Pk_Kwh__c=23.552,On_Pk_Kwh__c=235.12));
        
        ldclist.add(new ldc_account__c(Name='Test MU IL 2',ldc_account_number__c='MU3254635932',account__c=PAcct[7].id,Service_Territory__c='Comed-IL',LDC_Vendor__c=testVendor2.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='IS-03HY',Utility_Zone__c='AEP',Acct_ADU__c=5.3245,NSPL2_KW__c=345.22,
                                       Off_Pk_Kwh__c=23.552,On_Pk_Kwh__c=235.12));
                                       
        ldclist.add(new ldc_account__c(Name='Test CI OH 1',ldc_account_number__c='CI46985543844',account__c=BAcct[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=84.433,NSPL2_KW__c=346.22,
                                       Off_Pk_Kwh__c=346.436,On_Pk_Kwh__c=1.4674));
        
        ldclist.add(new ldc_account__c(Name='Test CI OH 2',ldc_account_number__c='CI3745758587',account__c=BAcct[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=84.433,NSPL2_KW__c=346.22,
                                       Off_Pk_Kwh__c=346.436,On_Pk_Kwh__c=1.4674));
        
        ldclist.add(new ldc_account__c(Name='Test CI OH 3',ldc_account_number__c='CI468596544357',account__c=BAcct[0].id,Service_Territory__c='AEPOHIO',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=84.433,NSPL2_KW__c=346.22,
                                       Off_Pk_Kwh__c=346.436,On_Pk_Kwh__c=1.4674));                                                            
        
        ldclist.add(new ldc_account__c(Name='Test CI IL 1',ldc_account_number__c='CI45848569859',account__c=BAcct[3].id,Service_Territory__c='Comed-IL',LDC_Vendor__c=testVendor2.id,
                                       FRM_Profile__c='DS1',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=84.433,NSPL2_KW__c=346.22,
                                       Off_Pk_Kwh__c=346.436,On_Pk_Kwh__c=1.4674));
        
        ldclist.add(new ldc_account__c(Name='Test CI IL 2',ldc_account_number__c='CI546385685687568',account__c=BAcct[3].id,Service_Territory__c='Comed-IL',LDC_Vendor__c=testVendor2.id,
                                       FRM_Profile__c='',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=84.433,NSPL2_KW__c=346.22,
                                       Off_Pk_Kwh__c=346.436,On_Pk_Kwh__c=1.4674));                            
        
        ldclist.add(new ldc_account__c(Name='Test CI IL 2',ldc_account_number__c='CI6968565687568',account__c=BAcct[8].id,Service_Territory__c='Comed-IL',LDC_Vendor__c=testVendor2.id,
                                       FRM_Profile__c='',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=84.433,NSPL2_KW__c=346.22,
                                       Off_Pk_Kwh__c=346.436,On_Pk_Kwh__c=1.4674));                            
        
        ldclist.add(new ldc_account__c(Name='Test CI IL 2',ldc_account_number__c='CI4780785687568',account__c=BAcct[9].id,Service_Territory__c='Comed-IL',LDC_Vendor__c=testVendor2.id,
                                       FRM_Profile__c='',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=7876.433,NSPL2_KW__c=311.22,
                                       Off_Pk_Kwh__c=33.436,On_Pk_Kwh__c=568.4674));                            
        
        ldclist.add(new ldc_account__c(Name='Test MA IL 2',ldc_account_number__c='MA4780785687568',account__c=PAcct[10].id,Service_Territory__c='Comed-IL',LDC_Vendor__c=testVendor2.id,
                                       FRM_Profile__c='',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=7876.433,NSPL2_KW__c=311.22,
                                       Off_Pk_Kwh__c=33.436,On_Pk_Kwh__c=568.4674));                            
        
        insert ldclist;
        
        ldclist[0].Acct_ADU__c+= 0.0001;  
        ldclist[2].Acct_ADU__c+= 0.0001;
        ldclist[4].Acct_ADU__c+= 0.0001;
        ldclist[6].Acct_ADU__c+= 0.0001;
        ldclist[8].Acct_ADU__c+= 0.0001;  
        ldclist[11].Acct_ADU__c+= 0.0001;
        
        update ldclist;
        
        List<opportunity> opplist = new List<opportunity>();
        opplist.add(new Opportunity(Name='Test CI opp OH',accountid=BAcct[0].id,type='C&I',Service_Territory__c='AEPOHIO',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test CI opp IL',accountid=BAcct[3].id,type='C&I',Service_Territory__c='Comed-IL',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test MM opp OH',accountid=BAcct[1].id,type='Mass-Market',Service_Territory__c='AEPOHIO',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test MM opp IL',accountid=BAcct[4].id,type='Mass-Market',Service_Territory__c='Comed-IL',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test MU opp OH',accountid=BAcct[2].id,type='Muni-Agg',Service_Territory__c='AEPOHIO',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
        opplist.add(new Opportunity(Name='Test MU opp IL',accountid=BAcct[5].id,type='Muni-Agg',Service_Territory__c='Comed-IL',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                    
		opplist.add(new Opportunity(Name='Test MU opp IL2',accountid=BAcct[5].id,type='Muni-Agg',Service_Territory__c='Comed-IL',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
        
        opplist.add(new Opportunity(Name='Test MU opp IL3',accountid=BAcct[9].id,type='Muni-Agg',Service_Territory__c='Ameren-IL',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
                                                                
        opplist.add(new Opportunity(Name='Test MU opp IL4',accountid=BAcct[10].id,type='Muni-Agg',Service_Territory__c='Comed-IL',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
        
        opplist.add(new Opportunity(Name='Test MU opp IL5',accountid=BAcct[10].id,type='Muni-Agg',Service_Territory__c='Comed-IL',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
        
        opplist.add(new Opportunity(Name='Test MU opp IL6',accountid=BAcct[10].id,type='Muni-Agg',Service_Territory__c='Comed-IL',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
        
        opplist.add(new Opportunity(Name='Test MU opp IL6',accountid=BAcct[11].id,type='Muni-Agg',Service_Territory__c='Comed-IL',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
        
        insert opplist;
        
        List<product2> prolist = new List<product2>();
        prolist.add(new product2(name='FP-Test',isactive=true));
        prolist.add(new product2(name='BI-Test',isactive=true));
        prolist.add(new product2(name='PCTG-Test',isactive=true));
        insert prolist;
        
        List<Retail_Quote__c> rqlist = new List<Retail_Quote__c>();
        rqlist.add(new Retail_Quote__c(Product__c=prolist[0].id,Payment_Terms__c='21',Opportunity__c=opplist[0].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'AEPOHIO_RESID_AGG'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[1].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED'));
        
        rqlist.add(new Retail_Quote__c(Product__c=prolist[0].id,Payment_Terms__c='21',Opportunity__c=opplist[2].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'AEPOHIO_RESID_AGG'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[1].id,Payment_Terms__c='21',Opportunity__c=opplist[3].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[4].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'AEPOHIO_RESID_AGG'));
                                                                   
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[5].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED'));
        
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[6].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='24',Opportunity__c=opplist[7].id,Start_Term__c=date.today(),Term__c=24,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'AMIL.AEM.IL',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;CGETUI-II,2314.1243;DSS0-1-II,3873.2355;CGSSOH-III,12.445;null,53.645;'));
                                                                      
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[8].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;',Include_In_TMF__c =true));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[9].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;',Include_In_TMF__c=true));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[10].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[6].id,Start_Term__c=date.today().addyears(1),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[6].id,Start_Term__c=date.today(),Term__c=18,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[6].id,Start_Term__c=date.today().addyears(2),Term__c=18,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'COMED',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[11].id,Start_Term__c=date.today().addyears(2),Term__c=18,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'APS_RESID_AGG',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;'));
                                       
        rqlist.add(new Retail_Quote__c(Product__c=prolist[2].id,Payment_Terms__c='21',Opportunity__c=opplist[11].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'APS_RESID_AGG',
                                       Muniagg_Profiling__c='CGSSOU-I,12.445;'));
                                       
        insert rqlist;
        
        rqlist[0].Request_Status__c ='Pricing Complete';
        rqlist[1].Request_Status__c ='Pricing Complete';
        rqlist[2].Request_Status__c ='Pricing Complete';
        rqlist[3].Request_Status__c ='Pricing Complete';
        rqlist[4].Request_Status__c ='Pricing Complete';
        rqlist[5].Request_Status__c ='Pricing Complete';
        rqlist[6].Request_Status__c ='Pricing Complete';
        rqlist[7].Request_Status__c ='Pricing Complete';
        rqlist[8].Request_Status__c ='Pricing Complete';
        rqlist[9].Request_Status__c ='Pricing Complete';
        rqlist[10].Request_Status__c ='Pricing Complete';
        rqlist[11].Request_Status__c ='Pricing Complete';
        rqlist[12].Request_Status__c ='Pricing Complete';
        rqlist[13].Request_Status__c ='Pricing Complete';
        rqlist[14].Request_Status__c ='Pricing Complete';
        rqlist[15].Request_Status__c ='Pricing Complete';
        update rqlist;
        
        List<Contract> cntlist = new List<Contract>();
        cntlist.add(new Contract(AccountId=BAcct[0].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST123',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Retail_Quote__c=rqlist[0].id,
                                 Opportunity__c=opplist[0].id));
                                 
        cntlist.add(new Contract(AccountId=BAcct[3].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Retail_Quote__c=rqlist[1].id,
                                 Opportunity__c=opplist[1].id));
        
        cntlist.add(new Contract(AccountId=BAcct[1].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Retail_Quote__c=rqlist[2].id,
                                 Opportunity__c=opplist[2].id));
        
        cntlist.add(new Contract(AccountId=BAcct[4].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Retail_Quote__c=rqlist[3].id,
                                 Opportunity__c=opplist[3].id));
                                 
        cntlist.add(new Contract(AccountId=BAcct[2].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Retail_Quote__c=rqlist[4].id,
                                 Opportunity__c=opplist[4].id));
                                                                                                            
        cntlist.add(new Contract(AccountId=BAcct[5].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Retail_Quote__c=rqlist[5].id,
                                 Opportunity__c=opplist[5].id));
        
        cntlist.add(new Contract(AccountId=BAcct[5].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Retail_Quote__c=rqlist[6].id,
                                 Opportunity__c=opplist[6].id,Vol_Rec__c=0));
        
        cntlist.add(new Contract(AccountId=BAcct[9].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 24,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Retail_Quote__c=rqlist[7].id,
                                 Opportunity__c=opplist[7].id));
                                                          
        cntlist.add(new Contract(AccountId=BAcct[6].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732));
                                 
        cntlist.add(new Contract(AccountId=BAcct[7].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='AEPOHIO',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732));
                                                                                                            
        cntlist.add(new Contract(AccountId=BAcct[8].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732));
        
        cntlist.add(new Contract(AccountId=BAcct[10].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732,Retail_Quote__c=rqlist[8].id,Opportunity__c=opplist[8].id));
        
        cntlist.add(new Contract(AccountId=BAcct[10].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732,Retail_Quote__c=rqlist[9].id,Opportunity__c=opplist[9].id));
        
        cntlist.add(new Contract(AccountId=BAcct[10].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732,Retail_Quote__c=rqlist[10].id,Opportunity__c=opplist[10].id));
        
        cntlist.add(new Contract(AccountId=BAcct[5].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732,Retail_Quote__c=rqlist[11].id,Opportunity__c=opplist[6].id,Vol_Rec__c=1.3443));
        
        cntlist.add(new Contract(AccountId=BAcct[5].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Retail_Quote__c=rqlist[12].id,
                                 Opportunity__c=opplist[6].id,Vol_Rec__c=0));
        
        cntlist.add(new Contract(AccountId=BAcct[5].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732,Retail_Quote__c=rqlist[13].id,Opportunity__c=opplist[6].id,Vol_Rec__c=1.3443));
        
        cntlist.add(new Contract(AccountId=BAcct[5].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year()-1,Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732,Retail_Quote__c=rqlist[13].id,Opportunity__c=opplist[6].id,Vol_Rec__c=1.3443));
        
        cntlist.add(new Contract(AccountId=BAcct[11].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year()-1,Date.today().month(),1),ContractTerm = 18,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732,Retail_Quote__c=rqlist[14].id,Opportunity__c=opplist[11].id,Vol_Rec__c=1.3443));
        
        cntlist.add(new Contract(AccountId=BAcct[11].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year()-1,Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST456',Contract_Type__c = 'COST_BASED',Service_Territory__c='Comed-IL',Energy__c=23.4256,
                                 Capacity__c=84.252,Broker_Fee__c=3.14356,Tax__c=2.57732,Retail_Quote__c=rqlist[14].id,Opportunity__c=opplist[11].id,Vol_Rec__c=1.3443));
        
        insert cntlist;
        cntlist[0].Status = 'Activated';
        cntlist[0].RPS__c = 0.7;
        cntlist[0].Vol_Rec__c = 1.5;
        cntlist[0].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[1].Status = 'Activated';
        cntlist[1].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[2].Status = 'Cancelled';
        cntlist[2].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[3].Status = 'Expired';
        cntlist[3].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[4].Status = 'Activated';
        cntlist[4].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[5].Status = 'Activated';
        cntlist[5].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[6].Status = 'Activated';
        cntlist[6].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[7].Status = 'Activated';
        cntlist[7].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[8].Status = 'Activated';
        cntlist[8].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[9].Status = 'Activated';
        cntlist[9].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[10].Status = 'Activated';
        cntlist[10].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[11].Status = 'Activated';
        cntlist[11].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[12].Status = 'Activated';
        cntlist[12].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[13].Status = 'Activated';
        cntlist[13].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[14].Status = 'Activated';
        cntlist[14].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[15].Status = 'Activated';
        cntlist[15].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[16].Status = 'Activated';
        cntlist[16].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[17].Status = 'Expired';
        cntlist[17].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[18].Status = 'Expired';
        cntlist[18].Contract_Counter_Signed_Date__c = datetime.now();
        cntlist[19].Status = 'Expired';
        cntlist[19].Contract_Counter_Signed_Date__c = datetime.now();
        update cntlist;   
        
        FRMReport frm = new FRMReport();
        Database.executeBatch(frm);     
        
        list<FRM_Report__c> frmMap = [select id,FRM_Profile__c,Contr_Agree_Num__c,FRM_Profile_Zone__c from FRM_Report__c];
        Database.executeBatch(frm);
                                                                       
    }
    
     public static testmethod void FRMReportTest3(){
     	FRMReport frm = new FRMReport();
        Database.executeBatch(frm);
        
        FRMDeleter frmdel = new FRMDeleter();
        time t =datetime.now().time();
        String schTime = '0 0 '+t.hour()+' * * ?';
        system.schedule('Test FRM', schTime, frmdel);
     }
     
     public static testmethod void FRMReportTestPA(){
     	Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        Schema.RecordTypeInfo massMarketRecType = acctRecTypeMap.get('Mass Market Offer');
        Schema.RecordTypeInfo massMarketIndRecType = acctRecTypeMap.get('Mass Market Individual Customer');
        Schema.RecordTypeInfo muniRecType = acctRecTypeMap.get('Muni Agg Customer');
        Schema.RecordTypeInfo muniIndRecType = acctRecTypeMap.get('Muni Agg Individual Customer');
        Schema.DescribeSObjectResult dsr1 = Opportunity.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> oppRecTypeMap = dsr1.getRecordTypeInfosByName();
        Schema.RecordTypeInfo oppRecType = oppRecTypeMap.get('Standard Opportunity');
        Schema.DescribeSObjectResult dsr2 = Retail_Quote__c.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> rqRecTypeMap = dsr2.getRecordTypeInfosByName();
        Schema.RecordTypeInfo rqRecType = rqRecTypeMap.get('Executable');
        
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST',
                                                           Active__c = true);
        insert testOperatingCompany;
        LDC_Vendor__c testVendor1 = new LDC_Vendor__c(Name='Test Vendor OH',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDROH',Service_Territory__c = 'PPL - PA',
                                                     Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'PA');
		insert new list<ldc_vendor__c>{testVendor1};
		
		List<Account> BAcct = new List<Account>();
		BAcct.add(new Account(RecordTypeId = ciAcctRecType.getRecordTypeId(),Name='Test C&I PA',Supplier__c = testOperatingCompany.Id,Billing_Entity__c='Dynegy'));
		insert BAcct;
		
		List<ldc_account__c> ldclist = new List<ldc_account__c>();
        ldclist.add(new ldc_account__c(Name='Test MM OH 1',ldc_account_number__c='MM826598252559',account__c=BAcct[0].id,Service_Territory__c='PPL - PA',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='CG-47AP',Utility_Zone__c='AEP',Acct_ADU__c=23.235,NSPL2_KW__c=398.238598,
                                       Off_Pk_Kwh__c=25.346,On_Pk_Kwh__c=238.232));
        
        ldclist.add(new ldc_account__c(Name='Test MM OH 2',ldc_account_number__c='MM2348259825',account__c=BAcct[0].id,Service_Territory__c='PPL - PA',LDC_Vendor__c=testVendor1.id,
                                       FRM_Profile__c='DS0',Utility_Rate_Class__c='OE-84AEP',Utility_Zone__c='AEP',Acct_ADU__c=235.253,NSPL2_KW__c=33.525,
                                       Off_Pk_Kwh__c=2435.223,On_Pk_Kwh__c=235.323));
        insert ldclist;
        
        List<opportunity> opplist = new List<opportunity>();
        opplist.add(new Opportunity(Name='Test CI opp PA',accountid=BAcct[0].id,type='C&I',Service_Territory__c='PPL - PA',CloseDate=system.today(),StageName='New',
                                    Pricing_Due_Date__c= system.today(),RecordTypeId=oppRecType.getRecordTypeId()));
        insert opplist;  
        
        List<opportunity_ldc__c> oldclist = new List<opportunity_ldc__c>();
        oldclist.add(new opportunity_ldc__c(ldc_account__c = ldclist[0].id, opportunity__c = opplist[0].id));
        oldclist.add(new opportunity_ldc__c(ldc_account__c = ldclist[1].id, opportunity__c = opplist[0].id));
        
        insert oldclist;      
        
        List<product2> prolist = new List<product2>();
        prolist.add(new product2(name='FP-Test',isactive=true));
        prolist.add(new product2(name='BI-Test',isactive=true));
        prolist.add(new product2(name='PCTG-Test',isactive=true));
        insert prolist;
        
        List<Retail_Quote__c> rqlist = new List<Retail_Quote__c>();
        rqlist.add(new Retail_Quote__c(Product__c=prolist[0].id,Payment_Terms__c='21',Opportunity__c=opplist[0].id,Start_Term__c=date.today(),Term__c=12,Margin__c=1.346,
                                       Energy_Fixed__c=60,Index_Margin__c=23.145,RecordTypeId=rqRecType.getRecordTypeId(),Utility_Settlement_Zone__c = 'AEPOHIO_RESID_AGG'));
        insert rqlist;    
        
        rqlist[0].Request_Status__c ='Pricing Complete';
        update rqlist;
        
        List<Contract> cntlist = new List<Contract>();
        cntlist.add(new Contract(AccountId=BAcct[0].Id,Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),ContractTerm = 12,
                                 Bill_Method__c = 'DUAL',Rate_Code__c = 'TEST123',Contract_Type__c = 'COST_BASED',Service_Territory__c='PPL - PA',Retail_Quote__c=rqlist[0].id,
                                 Opportunity__c=opplist[0].id));
                                 
        insert cntlist; 
         
        cntlist[0].Status = 'Activated';
        cntlist[0].Contract_Counter_Signed_Date__c = datetime.now();
        update cntlist;  
        
        ldclist[1].Acct_ADU__c+= 0.0001;
        update ldclist; 
        
        FRMReport frm = new FRMReport();
        Database.executeBatch(frm);     
        
        list<FRM_Report__c> frmMap = [select id,FRM_Profile__c,Contr_Agree_Num__c,FRM_Profile_Zone__c from FRM_Report__c];
        Database.executeBatch(frm);                         
                               
     }
    
}