/**
 * This class is designed to provide code coverage for the 
 * AccountTrigger and AccountTriggerHandlerBatch classes.
 *
 * @CreatedBy Prasad Paladugu
 * @version 1.0
 **/

@isTest 
public class AccountTriggerHandlerBatchTest{
    
    public static testmethod void AccountTriggerHandlerBatchTest1(){
        
        Schema.DescribeSObjectResult acc = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = acc.getRecordTypeInfosByName();
        Schema.RecordTypeInfo muniaggRecType = acctRecTypeMap.get('Muni Agg Customer');
        Schema.RecordTypeInfo muniaggIndRecType = acctRecTypeMap.get('Muni Agg Individual Customer');
        
        Supplier__c testOperatingCompany = new Supplier__c(
                                                        Name='Test Supplier',
                                                        Supplier_DUNS__c = 'DUNSTEST',
                                                        Legacy_ID__c = 'TEST',
                                                        Master_DUNS__c = 'DUNSTEST',
                                                        Organization_Identifier_Code__c = 'TESTSUP',
                                                        Supplier_Code__c = 'TEST',
                                                        ESP_Account_Number__c = 'TEST',
                                                        Active__c = true
                                                      );
        insert testOperatingCompany;
        
        
        Account accMuniagg = new Account(
                                        Name='Test Muni',
                                        Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = muniaggRecType.getRecordTypeId(),
                                        Billing_Entity__c='Dynegy'
                                         );
        
        insert accMuniagg;
        
        List<Account> testAcctList = new List<Account>();
        for(Integer i=1; i<=1000; i++){
            testAcctList.add(new Account(
                                        RecordTypeId = muniaggIndRecType.getRecordTypeId(),
                                        FirstName = 'TestMuni',
                                        LastName = 'IndividualAcct'+i,
                                        PersonMailingStreet = '4171 Still Street',
                                        PersonMailingPostalCode = '45819',
                                        PersonMailingCity = 'Buckland',
                                        PersonMailingState = 'OH',
                                        PersonEmail='test@test.com',
                                        PersonHomePhone='419-657-2441',
                                        Business_Account__c = accMuniagg.id,
                                        Billing_Entity__c='Dynegy'
                                    ));
        }
        insert testAcctList;
        
        accMuniagg.name = 'Test Muni'+system.today();
        update accMuniagg;
    }
    
    public static testmethod void AccountTriggerHandlerBatchTest2(){
        
        Schema.DescribeSObjectResult acc = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = acc.getRecordTypeInfosByName();
        Schema.RecordTypeInfo muniaggRecType = acctRecTypeMap.get('Muni Agg Customer');
        Schema.RecordTypeInfo muniaggIndRecType = acctRecTypeMap.get('Muni Agg Individual Customer');
        
        Supplier__c testOperatingCompany = new Supplier__c(
                                                        Name='Test Supplier',
                                                        Supplier_DUNS__c = 'DUNSTEST',
                                                        Legacy_ID__c = 'TEST',
                                                        Master_DUNS__c = 'DUNSTEST',
                                                        Organization_Identifier_Code__c = 'TESTSUP',
                                                        Supplier_Code__c = 'TEST',
                                                        ESP_Account_Number__c = 'TEST',
                                                        Active__c = true
                                                      );
        insert testOperatingCompany;
        
        
        Account accMuniagg = new Account(
                                        Name='Test Muni',
                                        Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = muniaggRecType.getRecordTypeId(),
                                        Billing_Entity__c='Dynegy'
                                        );
        
        insert accMuniagg;
        
        List<Account> testAcctList = new List<Account>();
        for(Integer i=1; i<=100; i++){
            testAcctList.add(new Account(
                                        RecordTypeId = muniaggIndRecType.getRecordTypeId(),
                                        FirstName = 'TestMuni',
                                        LastName = 'IndividualAcct'+i,
                                        PersonMailingStreet = '4171 Still Street',
                                        PersonMailingPostalCode = '45819',
                                        PersonMailingCity = 'Buckland',
                                        PersonMailingState = 'OH',
                                        PersonEmail='test@test.com',
                                        PersonHomePhone='419-657-2441',
                                        Business_Account__c = accMuniagg.id,
                                        Billing_Entity__c='Dynegy'
                                    ));
        }
        insert testAcctList;
        
        accMuniagg.name = 'Test Muni'+system.now();
        update accMuniagg;
    }
    
    public static testmethod void AccountTriggerHandlerBatchTest3(){
    	Schema.DescribeSObjectResult acc = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = acc.getRecordTypeInfosByName();
        Schema.RecordTypeInfo CIRecType = acctRecTypeMap.get('C&I Customer');
        
        Supplier__c testOperatingCompany = new Supplier__c(
                                                        Name='Test Supplier',
                                                        Supplier_DUNS__c = 'DUNSTEST',
                                                        Legacy_ID__c = 'TEST',
                                                        Master_DUNS__c = 'DUNSTEST',
                                                        Organization_Identifier_Code__c = 'TESTSUP',
                                                        Supplier_Code__c = 'TEST',
                                                        ESP_Account_Number__c = 'TEST',
                                                        Active__c = true
                                                      );
        insert testOperatingCompany;
        
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDR',
                                   Service_Territory__c = 'AEPOHIO',Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        
        Account a = new Account(
                                        Name='Test C&I',
                                        Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = CIRecType.getRecordTypeId(),
                                        Billing_Entity__c='Dynegy',
                                        Lodestar_integration_status__c='Synchronized'
                                        );
        
        insert a;
        
        Contract tstRecCtrt=new Contract(Name='Test Contract MA001',Rate_Code__c='RC001',StartDate=Date.today(),Status='Draft',AccountId=a.Id); 
        Insert tstRecCtrt;
        
        List<ldc_Account__c> testAcctList = new List<ldc_Account__c>();
        for(Integer i=1; i<=20; i++){
            testAcctList.add(new ldc_Account__c(
                                        Name = 'IndividualAcct'+i,
                                        Ldc_account_number__c = 'Test LDC 123-'+i,
                                        Account__c = a.id,
                                        Ldc_type__c = 'Commercial',
                                        Service_territory__c = 'AEPOHIO',
                                        Ldc_vendor__c = testVendor.id,
                                        Enrolled__c=true
                                    ));
        }
        insert testAcctList;
        
        List<contract_ldc__c> cldcList = new List<contract_ldc__c>();
        for(Integer i=1; i<=20; i++){
            cldcList.add(new contract_ldc__c(
                                        Name = 'CLDC'+i,
                                        Ldc_account__c = testAcctList[i-1].id,
                                        contract__c = tstRecCtrt.id,
                                        term_start_date__c = system.now(),
                                        active__c = true,
                                        issynchronized__c = true
                                    ));
        }
        insert cldcList;
        
        for(Integer i=1; i<=20; i++){
        	system.debug('CLDC----->'+cldcList[i-1]);
        }
        
        //a.Lodestar_integration_status__c='Not Synchronized';
        //update a;
        testAcctList[0].ldc_account_status__c = 'ACTIVE';
        update testAcctList[0];
    }
}