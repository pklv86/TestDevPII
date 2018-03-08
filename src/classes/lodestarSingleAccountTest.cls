/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class lodestarSingleAccountTest {

    static testMethod void lodestarSingleAccountTest1() {
        // TO DO: implement unit test
    	Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
	    Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
	    Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
	    Schema.RecordTypeInfo massMarketRecType = acctRecTypeMap.get('Mass Market Offer');
	    Schema.RecordTypeInfo massMarketIndRecType = acctRecTypeMap.get('Mass Market Individual Customer');
	    //we need to create a test operating company
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
	    //create a test vendor
	    LDC_Vendor__c testVendor = new LDC_Vendor__c(
	                                                    Name='Test Vendor',
	                                                    DUNS__c = DynegyCommonUtils.generateRandomString(8),
	                                                    Legacy_ID__c = 'TVNDR',
	                                                    Service_Territory__c = 'AEPOHIO',
	                                                    Utility_Code__c = 'TST',
	                                                    Vendor_Type__c = 'LDC',
	                                                    Service_State__c = 'OH',
	                                                    active__c=true
	                                                );
	    insert testVendor;
	    //create a series of test accounts of different kinds
	    List<Account> testAcctList = new List<Account>();
	    testAcctList.add(new Account(
	                                    Name='Test MM Offer',
	                                    Supplier__c = testOperatingCompany.Id,
	                                    RecordTypeId = massMarketRecType.getRecordTypeId(),
	                                    Billing_Entity__c='Dynegy'
	                                    ));
	    testAcctList.add(new Account(
	                                    RecordTypeId = massMarketIndRecType.getRecordTypeId(),
	                                    FirstName = 'TestMass',
	                                    LastName = 'MarketIndividualAcct',
	                                    PersonMailingStreet = '4171 Still Street',
	                                    PersonMailingPostalCode = '45819',
	                                    PersonMailingCity = 'Buckland',
	                                    PersonMailingState = 'OH',
	                                    PersonEmail='test@test.com',
	                                    PersonHomePhone='419-657-2441',
	                                    LodeStar_Integration_Status__c = 'Not Synchronized',
	                                    Billing_Entity__c='Dynegy'
	                                ));
	    testAcctList.add(new Account(
	                                    RecordTypeId = ciAcctRecType.getRecordTypeId(),
	                                    Name='Test C&I',
	                                    Supplier__c = testOperatingCompany.Id,
	                                    LodeStar_Integration_Status__c = 'Not Synchronized',
	                                    Billing_Entity__c='Dynegy'
	                                ));
	    testAcctList.add(new Account(
	                                    RecordTypeId = ciAcctRecType.getRecordTypeId(),
	                                    Name='Test C&I2',
	                                    Supplier__c = testOperatingCompany.Id,
	                                    LodeStar_Integration_Status__c = 'Not Synchronized',
	                                    Billing_Entity__c='Dynegy'
	                                ));
	    insert testAcctList;
	    testAcctList[1].Business_Account__c = testAcctList[0].Id;
	    update testAcctList[1];
	    //now we need to create an LDC_Account__c record
	    List<LDC_Account__c> LdcList = new List<LDC_Account__c>();
	    LdcList.add(new LDC_Account__c(    Name = 'LDC MM',
                                            Account__c=testAcctList[1].Id,
                                            LDC_Account_Number__c = 'LDCTEST MM',
                                            ldc_account_status__c ='Active',
                                            Service_Street_1__c = '4048 Vineyard Drive',
                                            Service_City__c = 'Solon',
                                            Service_State__c = 'OH',
                                            Service_Postal_Code__c = '44139',
                                            LDC_Start_Date__c = Date.today(),
                                            LDC_End_Date__c = Date.today().addYears(5),
                                            Enrolled__c = true,
                                            CRM_ID__C = 'HFUHGFIUWUF'
	                                        ));
	    LdcList.add(new LDC_Account__c(    Name = 'LDC CI 1',
	                                            Account__c=testAcctList[2].Id,
	                                            LDC_Account_Number__c = 'LDCTEST 1',
	                                            Service_Street_1__c = '4048 Vineyard Drive',
	                                            ldc_account_status__c ='Final',
	                                            account_type_code__c='UCBNONPOR_RR',
	                                            Service_City__c = 'Solon',
	                                            Service_State__c = 'OH',
	                                            service_territory__c = 'AEPOHIO',
	                                            LDC_Vendor__c = testVendor.id,
	                                            Service_Postal_Code__c = '44139',
	                                            LDC_Start_Date__c = Date.today(),
	                                            LDC_End_Date__c = null,
	                                            Enrolled__c = true,
	                                            CRM_ID__C = 'HFUHGFIUWUF1'
		                                        ));
	    LdcList.add(new LDC_Account__c(    Name = 'LDC CI 2',
	                                            Account__c=testAcctList[2].Id,
	                                            LDC_Account_Number__c = 'LDCTEST 2',
	                                            Service_Street_1__c = '4048 Vineyard Drive',
	                                            ldc_account_status__c ='Active',
	                                            account_type_code__c='UCBNONPOR_RR',
	                                            Service_City__c = 'Solon',
	                                            Service_State__c = 'OH',
	                                            service_territory__c = 'AEPOHIO',
	                                            LDC_Vendor__c = testVendor.id,
	                                            Service_Postal_Code__c = '44139',
	                                            LDC_Start_Date__c = Date.today(),
	                                            LDC_End_Date__c = Date.today().adddays(-2),
	                                            Enrolled__c = true,
	                                            CRM_ID__C = 'HFUHGFIUWUF2'
		                                        ));
		LdcList.add(new LDC_Account__c(    Name = 'LDC CI 3',
	                                            Account__c=testAcctList[2].Id,
	                                            LDC_Account_Number__c = 'LDCTEST 3',
	                                            Service_Street_1__c = '4048 Vineyard Drive',
	                                            ldc_account_status__c ='Final',
	                                            account_type_code__c='UCBNONPOR_RR',
	                                            Service_City__c = 'Solon',
	                                            Service_State__c = 'OH',
	                                            service_territory__c = 'AEPOHIO',
	                                            LDC_Vendor__c = testVendor.id,
	                                            Service_Postal_Code__c = '44139',
	                                            LDC_Start_Date__c = Date.today().addYears(1),
	                                            LDC_End_Date__c = Date.today(),
	                                            Enrolled__c = true,
	                                            CRM_ID__C = 'HFUHGFIUWUF3'
		                                        ));
	    LdcList.add(new LDC_Account__c(    Name = 'LDC CI 4',
	                                            Account__c=testAcctList[2].Id,
	                                            LDC_Account_Number__c = 'LDCTEST 4',
	                                            Service_Street_1__c = '4048 Vineyard Drive',
	                                            ldc_account_status__c ='Final',
	                                            account_type_code__c='UCBNONPOR_RR',
	                                            Service_City__c = 'Solon',
	                                            Service_State__c = 'OH',
	                                            service_territory__c = 'AEPOHIO',
	                                            LDC_Vendor__c = testVendor.id,
	                                            Service_Postal_Code__c = '44139',
	                                            LDC_Start_Date__c = Date.today().addYears(1),
	                                            LDC_End_Date__c = Date.today(),
	                                            Enrolled__c = true,
	                                            CRM_ID__C = 'HFUHGFIUWUF4'
		                                        ));
	    for(integer i=5; i<=150 ;i++){                                    
		    LdcList.add(new LDC_Account__c(    Name = 'LDC CI'+i,
	                                            Account__c=testAcctList[2].Id,
	                                            LDC_Account_Number__c = 'LDCTEST'+i,
	                                            Service_Street_1__c = '4048 Vineyard Drive',
	                                            ldc_account_status__c ='Active',
	                                            Service_City__c = 'Solon',
	                                            account_type_code__c='UCBNONPOR_RR',
	                                            Service_State__c = 'OH',
	                                            Service_Postal_Code__c = '44139',
	                                            service_territory__c = 'AEPOHIO',
	                                            LDC_Vendor__c = testVendor.id,
	                                            LDC_Start_Date__c = Date.today(),
	                                            Enrolled__c = true,
	                                            CRM_ID__C = 'HFUHGFIUWUF'+i
		                                        )); 
	    }
	    for(integer i=151; i<=250 ;i++){                                    
		    LdcList.add(new LDC_Account__c(    Name = 'LDC CI'+i,
	                                            Account__c=testAcctList[2].Id,
	                                            LDC_Account_Number__c = 'LDCTEST'+i,
	                                            Service_Street_1__c = '4048 Vineyard Drive',
	                                            ldc_account_status__c ='Final',
	                                            account_type_code__c='UCBPOR_RR',
	                                            Service_City__c = 'Solon',
	                                            Service_State__c = 'OH',
	                                            Service_Postal_Code__c = '44139',
	                                            service_territory__c = 'AEPOHIO',
	                                            LDC_Vendor__c = testVendor.id,
	                                            LDC_Start_Date__c = Date.today(),
	                                            LDC_End_Date__c = Date.today().addYears(5),
	                                            Enrolled__c = true,
	                                            CRM_ID__C = 'HFUHGFIUWUF'+i
		                                        )); 
	    }
        LdcList.add(new LDC_Account__c(    Name = 'LDC CI 251',
	                                            Account__c=testAcctList[3].Id,
	                                            LDC_Account_Number__c = 'LDCTEST 251',
	                                            Service_Street_1__c = '4048 Vineyard Drive',
	                                            ldc_account_status__c ='Final',
	                                            account_type_code__c='UCBNONPOR_RR',
	                                            Service_City__c = 'Solon',
	                                            Service_State__c = 'OH',
	                                            service_territory__c = 'AEPOHIO',
	                                            LDC_Vendor__c = testVendor.id,
	                                            Service_Postal_Code__c = '44139',
	                                            LDC_Start_Date__c = Date.today().addYears(-1),
	                                            LDC_End_Date__c = Date.today(),
	                                            Enrolled__c = true,
	                                            bill_cycle__c = '15',
	                                            CRM_ID__C = 'HFUHGFIUWUF251'
		                                        ));
        LdcList.add(new LDC_Account__c(    Name = 'LDC CI 252',
	                                            Account__c=testAcctList[3].Id,
	                                            LDC_Account_Number__c = 'LDCTEST 252',
	                                            Service_Street_1__c = '4048 Vineyard Drive',
	                                            ldc_account_status__c ='Active',
	                                            account_type_code__c='UCBNONPOR_RR',
	                                            Service_City__c = 'Solon',
	                                            Service_State__c = 'OH',
	                                            service_territory__c = 'AEPOHIO',
	                                            LDC_Vendor__c = testVendor.id,
	                                            Service_Postal_Code__c = '44139',
	                                            LDC_Start_Date__c = Date.today().addMonths(-10),
	                                            Enrolled__c = true,
	                                            bill_cycle__c = '15',
	                                            CRM_ID__C = 'HFUHGFIUWUF252'
		                                        ));
        LdcList.add(new LDC_Account__c(    Name = 'LDC CI 253',
	                                            Account__c=testAcctList[3].Id,
	                                            LDC_Account_Number__c = 'LDCTEST 253',
	                                            Service_Street_1__c = '4048 Vineyard Drive',
	                                            ldc_account_status__c ='Active',
	                                            account_type_code__c='UCBNONPOR_RR',
	                                            Service_City__c = 'Solon',
	                                            Service_State__c = 'OH',
	                                            service_territory__c = 'AEPOHIO',
	                                            LDC_Vendor__c = testVendor.id,
	                                            Service_Postal_Code__c = '44139',
	                                            LDC_Start_Date__c = Date.today().addMonths(-10),
	                                            Enrolled__c = true,
	                                            bill_cycle__c = '15',
	                                            CRM_ID__C = 'HFUHGFIUWUF253'
		                                        ));                                                                                                      
        insert LdcList;
	    //create test Contract
	    Contract testContract = new Contract(
	                                            AccountId=testAcctList[0].Id,
	                                            Name='',
	                                            Status='Draft',
	                                            StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
	                                            ContractTerm = 12,
	                                            Bill_Method__c = 'DUAL',
	                                            Rate_Code__c = 'TEST123',
	                                     		//Contract_Type__c = 'COST_BASED',
	                                            Service_Territory__c='AEPOHIO',
	                                            Product_Name__c='FP-ONE'
	                                        );
	    insert testContract;
	    Contract testContract1 = new Contract(
	                                            AccountId=testAcctList[2].Id,
	                                            Name='',
	                                            Status='Draft',
	                                            StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
	                                            ContractTerm = 12,
	                                            Bill_Method__c = 'DUAL',
	                                            Rate_Code__c = 'TEST123',
	                                     //     Contract_Type__c = 'COST_BASED',
	                                            Service_Territory__c='AEPOHIO',
	                                            Product_Name__c='FP-ONE'
	                                        );
	    insert testContract1;
	    Contract testContract2 = new Contract(
	                                            AccountId=testAcctList[3].Id,
	                                            Name='',
	                                            Status='Draft',
	                                            StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
	                                            ContractTerm = 12,
	                                            Bill_Method__c = 'DUAL',
	                                            Rate_Code__c = 'TEST123',
	                                     		contract_type__c = 'UCBPOR',
	                                            Service_Territory__c='AEPOHIO',
	                                            Product_Name__c='FP-ONE'
	                                        );
	    insert testContract2;
	    //activate the Contract
	    testContract.Status = 'Activated';
	    testContract.Contract_Counter_Signed_Date__c = datetime.now();
	    update testContract;
	    
	    testContract.Service_Territory__c = null;
	    update testContract;
	    
	    //activate the Contract
	    testContract1.Status = 'Activated';
	    testContract1.Contract_Counter_Signed_Date__c = datetime.now();
	    update testContract1;
	    
	    testContract2.Status = 'Activated';
	    testContract2.Contract_Counter_Signed_Date__c = datetime.now();
	    update testContract2;
	    //create a phone Contract Term
	    Contract_Term__c testContractTerm = new Contract_Term__c(
	                                                Contract__c = testContract.Id,
	                                                Term_Category__c = 'NOTBILLED',
	                                                Term_Type__c = 'CUST_CHRG',
	                                                Contract_Term_Value__c = 5.0,
	                                                Term_Start_Date__c = Datetime.now(),
	                                                Term_Stop_Date__c = Datetime.now().addMonths(11)
	                                            );
	    insert testContractTerm;

	    //create Contract LDC Record
	    List<Contract_LDC__c> CLdcList = new List<Contract_LDC__c>();
	    CLdcList.add(new Contract_LDC__c(
                                            LDC_Account__c=LdcList[0].Id,
                                            Contract__c = testContract.Id,
                                            Term_Start_Date__c = Datetime.now(),
                                            Term_Stop_Date__c = Datetime.now().addMonths(12),
                                            IsSynchronized__c = false
                                          ));
	    CLdcList.add(new Contract_LDC__c(
	                                            LDC_Account__c=LdcList[1].Id,
	                                            Contract__c = testContract1.Id,
	                                            Term_Start_Date__c = Datetime.now(),
	                                            Term_Stop_Date__c = Datetime.now().addMonths(12),
	                                            IsSynchronized__c = false
	                                          ));
	    CLdcList.add(new Contract_LDC__c(
	                                            LDC_Account__c=LdcList[2].Id,
	                                            Contract__c = testContract1.Id,
	                                            Term_Start_Date__c = Datetime.now(),
	                                            Term_Stop_Date__c = Datetime.now().addMonths(12),
	                                            Active__c = true,
	                                            IsSynchronized__c = false
	                                          ));
	    CLdcList.add(new Contract_LDC__c(
	                                            LDC_Account__c=LdcList[3].Id,
	                                            Contract__c = testContract1.Id,
	                                            Term_Start_Date__c = Datetime.now(),
	                                            Term_Stop_Date__c = null,//Datetime.now().addMonths(12),
	                                            Active__c = true,
	                                            IsSynchronized__c = false
	                                          ));   
	     CLdcList.add(new Contract_LDC__c(
	                                            LDC_Account__c=LdcList[4].Id,
	                                            Contract__c = testContract1.Id,
	                                            Term_Start_Date__c = Datetime.now(),
	                                            Term_Stop_Date__c = Datetime.now().addMonths(-1),
	                                            Active__c = true,
	                                            IsSynchronized__c = false
	                                          ));                                                                                                                  
	    for(integer i=5; i<=150 ;i++){ 
	    	CLdcList.add(new Contract_LDC__c(
	                                            LDC_Account__c=LdcList[i].Id,
	                                            Contract__c = testContract1.Id,
	                                            Term_Start_Date__c = Datetime.now(),
	                                            Term_Stop_Date__c = Datetime.now().addMonths(12),
	                                            Active__c = true,
	                                            IsSynchronized__c = false
	                                          ));
	    }
	    for(integer i=151; i<=245 ;i++){ 
	    	CLdcList.add(new Contract_LDC__c(
	                                            LDC_Account__c=LdcList[i].Id,
	                                            Contract__c = testContract1.Id,
	                                            Term_Start_Date__c = Datetime.now(),
	                                            Term_Stop_Date__c = Datetime.now().addMonths(12),
	                                            IsSynchronized__c = false
	                                          ));
	    } 
	    CLdcList.add(new Contract_LDC__c(
	                                            LDC_Account__c=LdcList[251].Id,
	                                            Contract__c = testContract2.Id,
	                                            Term_Start_Date__c = Datetime.now().addMonths(-6),
	                                            Term_Stop_Date__c = Datetime.now(),
	                                            Active__c = false,
	                                            IsSynchronized__c = false
	                                          ));
	    CLdcList.add(new Contract_LDC__c(
	                                            LDC_Account__c=LdcList[252].Id,
	                                            Contract__c = testContract2.Id,
	                                            Term_Start_Date__c = Datetime.now().addMonths(-6),
	                                            Term_Stop_Date__c = Datetime.now().addyears(1),
	                                            Active__c = true,
	                                            IsSynchronized__c = false
	                                          ));
	    CLdcList.add(new Contract_LDC__c(
	                                            LDC_Account__c=LdcList[253].Id,
	                                            Contract__c = testContract2.Id,
	                                            Term_Start_Date__c = Datetime.now().addMonths(-6),
	                                            Term_Stop_Date__c = Datetime.now().addyears(1),
	                                            Active__c = true,
	                                            IsSynchronized__c = false
	                                          ));
	    insert CLdcList;
	    
		Billing_Group__c bg = new Billing_Group__c(Name='Test Billing Group',Account__c=testAcctList[3].Id,contract__c=testContract2.id,synchronized__c=false);
		insert bg;
		Billing_Group__c bg2 = new Billing_Group__c(Name='Test Billing Group2',Account__c=testAcctList[3].Id,contract__c=testContract2.id,synchronized__c=false,Start_Date__c=date.today().addmonths(15));
		insert bg2;
		
		Billing_Group_Ldc__c bgldc = new Billing_Group_Ldc__c(billing_group__C = bg.id,ldc_account__c = LdcList[251].id,synchronized__c = false,Billing_Start_Date__c=system.now(),Billing_Stop_Date__c=system.now().addyears(1));
		Billing_Group_Ldc__c bgldc2 = new Billing_Group_Ldc__c(billing_group__C = bg.id,ldc_account__c = LdcList[252].id,synchronized__c = false,Billing_Start_Date__c=system.now(),Billing_Stop_Date__c=system.now().addyears(1));
		Billing_Group_Ldc__c bgldc3 = new Billing_Group_Ldc__c(billing_group__C = bg2.id,ldc_account__c = LdcList[253].id,synchronized__c = false,Billing_Start_Date__c=system.now(),Billing_Stop_Date__c=system.now().addyears(1));
		insert new list<Billing_Group_Ldc__c>{bgldc,bgldc2,bgldc3};
		
	    
	    
	    ApexPages.currentPage().getParameters().put('ID',testAcctList[2].id);
       	lodestarSingleAccount lsa = new lodestarSingleAccount();
       	lsa.hasNext();
       	lsa.hasPrevious();
       	lsa.last();
       	lsa.first();
       	lsa.getDisableNext();
       	lsa.getDisablePrevious();
       	lsa.getContractList();
       	
       	PageReference pg = page.sendToLodestar;
        Test.setCurrentPage(pg);        

        lodestarSingleAccount lsaCI = new lodestarSingleAccount();
        lsaCI.ldc.account__c = testAcctList[2].id;
        lsaCI.ldc.account_type_code__c = 'UCBNONPOR_RR';
        lsaCI.pickldc();
        lsaCI.validateToLS();
        
        lsaCI.ldc.account__c = testAcctList[3].id;
        lsaCI.ldc.account_type_code__c = 'UCBNONPOR_RR';
        lsaCI.pickldc();
        lsaCI.validateToLS();
        
	    bg.Start_Date__c = date.today();
	    update bg;
	    bg2.Start_Date__c = date.today();
	    update bg2;
	    lsaCI.validateToLS();
	    
	    //LdcList[0].ldc_end_date__c =date.today.addyears(1);
        
        lodestarSingleAccount lsaM = new lodestarSingleAccount();
        lsaM.ldc.account__c = testAcctList[1].id;
        lsaM.pickldc();
        lsaM.validateToLS();
        
        LdcList[0].account_type_code__c ='UCBPOR_RR';
        LdcList[0].LDC_Vendor__c = testVendor.id;
       	LdcList[0].service_territory__c = 'AEPOHIO';
       	LdcList[0].bill_cycle__c ='15';
       	LdcList[0].ldc_account_status__c = 'Final';
       	update LdcList[0];
       	
       	testContract.Service_Territory__c = 'AEPOHIO';
       	testContract.contract_type__c = 'UCBPOR';
	    update testContract;
	    
      	lsaM.pickldc();
        lsaM.validateToLS();
        lsaM.callLodestar();
        lsaM.lodestarResult();
       	
    }
}