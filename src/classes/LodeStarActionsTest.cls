/**
 * This class is designed to provide code coverage for the LodeStarActions
 * class.
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 * @Version 2.0 - Prasad - Modified in order to run through whole lodestar process
 **/
@isTest
global class LodeStarActionsTest{
    /**
     * Designed to set up test data
     **/
    private static void SetupTestData(){
        //first we need to create a test Account
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
                                                        Service_State__c = 'OH'
                                                    );
        insert testVendor;
        //create a series of test accounts of different kinds
        List<Account> testAcctList = new List<Account>();
        testAcctList.add(new Account(
                                        Name='Test MM Offer',
                                        Supplier__c = testOperatingCompany.Id,
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
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
                                        Billing_Entity__c='Dynegy',Validation__c = 'Validated'
                                    ));
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketRecType.getRecordTypeId(),
                                        Name='Test MM Offer 2',
                                        Supplier__c = testOperatingCompany.Id,
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
                                        Billing_Entity__c='Dynegy',
                                        Legal_Entity_Name__c = 'Test 1256142___532()3434__37621039%&^$%$%^@*&&#@$&*&@$@^$&*@dsafusdfguYUWBG&@21`38YWQGE@*&&@YJ*uswhYGYWWU'
                                    ));
        testAcctList.add(new Account(
                                        RecordTypeId = massMarketIndRecType.getRecordTypeId(),
                                        FirstName = 'TestMass',
                                        LastName = 'MarketIndividualAcct2',
                                        PersonMailingStreet = '4173 Still Street',
                                        PersonMailingPostalCode = '45819',
                                        PersonMailingCity = 'Buckland',
                                        PersonMailingState = 'OH',
                                        PersonEmail='test@test.com',
                                        PersonHomePhone='419-657-2441',
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
                                        Billing_Entity__c='Dynegy',Validation__c = 'Validated'
                                    ));
        testAcctList.add(new Account(
                                        RecordTypeId = ciAcctRecType.getRecordTypeId(),
                                        Name='Test CI',
                                        Supplier__c = testOperatingCompany.Id,
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
                                        Billing_Entity__c='Dynegy'
                                    ));
        testAcctList.add(new Account(
                                        RecordTypeId = ciAcctRecType.getRecordTypeId(),
                                        Name='Test CI2',
                                        Supplier__c = testOperatingCompany.Id,
                                        LodeStar_Integration_Status__c = 'Not Synchronized',
                                        Billing_Entity__c='Dynegy'
                                    ));
        insert testAcctList;
        testAcctList[1].Business_Account__c = testAcctList[0].Id;
        testAcctList[3].Business_Account__c = testAcctList[2].Id;
        update new list<account>{testAcctList[1],testAcctList[3],testAcctList[4]};
        
        LodeStar_Error__c ld1 = new LodeStar_Error__c(Name = 'LDC_Start_Date__C', Object__c = 'LDC_Account__c');
        LodeStar_Error__c ld2 = new LodeStar_Error__c(Name = 'LDC_End_Date__C', Object__c = 'LDC_Account__C');
        LodeStar_Error__c ld3 = new LodeStar_Error__c(Name = 'Start_Date__C', Object__c = 'Billing_Group__c');
        insert new list<LodeStar_Error__c>{ld1,ld2,ld3};
        
        //now we need to create an LDC_Account__c record
        LDC_Account__c ldcTestAccount = new LDC_Account__c(
                                                Name = 'Test LDC Acc 1',
                                                Account__c=testAcctList[1].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4048 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_status__c = 'ACTIVE',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount2 = new LDC_Account__c(
                                                Name = 'Test LDC Acc 2',
                                                Account__c=testAcctList[3].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4049 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_status__c = 'ACTIVE',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount3 = new LDC_Account__c(
                                                Name = 'Test LDC Acc 2',
                                                Account__c=testAcctList[4].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4050 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                               // LDC_Start_Date__c = Date.today(),
                                              //  LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_status__c = 'ACTIVE',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount4 = new LDC_Account__c(
                                                Name = 'Test LDC Acc 2',
                                                Account__c=testAcctList[4].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4051 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_status__c = 'ACTIVE',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount5 = new LDC_Account__c(
                                                Name = 'Test LDC Acc 2',
                                                Account__c=testAcctList[4].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4052 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_status__c = 'ACTIVE',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount6 = new LDC_Account__c(
                                                Name = 'Test LDC Acc CI 2_1',
                                                Account__c=testAcctList[5].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4052 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_status__c = 'ACTIVE',
                                                Enrolled__c = true
                                            );
        LDC_Account__c ldcTestAccount7 = new LDC_Account__c(
                                                Name = 'Test LDC Acc CI 2_2',
                                                Account__c=testAcctList[5].Id,
                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                Service_Street_1__c = '4052 Vineyard Drive',
                                                Service_City__c = 'Solon',
                                                Service_State__c = 'OH',
                                                Service_Postal_Code__c = '44139',
                                                LDC_Start_Date__c = Date.today(),
                                                LDC_End_Date__c = Date.today().addYears(5),
                                                LDC_Account_status__c = 'ACTIVE',
                                                Enrolled__c = true
                                            );
        insert new list<ldc_account__c>{ldcTestAccount,ldcTestAccount2,ldcTestAccount3,ldcTestAccount4,ldcTestAccount5,ldcTestAccount6,ldcTestAccount7};
        
        Peak_Load_Information__c plc = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c plc2 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount2.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc2 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount2.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c plc3 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount3.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc3 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount3.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c plc4 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount4.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc4 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount4.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c plc5 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount5.id,Load_Type__c='PLC',Load_Value__c=3.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		Peak_Load_Information__c nsplc5 = new Peak_Load_Information__c(Ldc_account__c = ldcTestAccount5.id,Load_Type__c='NSPLC',Load_Value__c=10.431,
        																Start_Date__c=Date.today(),EndDate__c= date.today().addMonths(6));
		insert new list<Peak_Load_Information__c>{plc,nsplc,plc2,nsplc2,plc3,nsplc3,plc4,nsplc4,plc5,nsplc5};
		
		Contract_Type_Setting__c cts1 = new Contract_Type_Setting__c(Name='AEPOHIO-DUAL-CT1',Contract_Type__c='UCBPOR',New_Contract_Type__c='Hybrid',Bill_Method__c='DUAL',Contract_Code__c='CT1',Service_Territory__c='AEPOHIO');
		Contract_Type_Setting__c cts2 = new Contract_Type_Setting__c(Name='AEPOHIO-DUAL-CT2',Contract_Type__c='TIER_1_2',New_Contract_Type__c='Small Stable Contract - Evergreen',Bill_Method__c='DUAL',Contract_Code__c='CT2',Service_Territory__c='AEPOHIO');
		Contract_Type_Setting__c cts3 = new Contract_Type_Setting__c(Name='AEPOHIO-RateReady-CT3',Contract_Type__c='UCBNONPOR',New_Contract_Type__c='Large Stable Contract',Bill_Method__c='RateReady',Contract_Code__c='CT3',Service_Territory__c='AEPOHIO');
		insert new list<Contract_Type_Setting__c>{cts1,cts2,cts3};
        
        opportunity opp = new opportunity(Name = 'Test opp',accountId=testAcctList[5].Id,type='C&I',service_territory__c='AEPOHIO',CloseDate=date.today(),
											StageName='New',Pricing_Due_Date__c=date.today());
        insert opp;
        
        //create test Contract
        Contract testContract = new Contract(
                                                AccountId=testAcctList[0].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'Small Stable Contract - Evergreen',
                                                Service_Territory__c='AEPOHIO'
                                            );
        Contract testContract2 = new Contract(
                                                AccountId=testAcctList[2].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'Hybrid',
                                                Service_Territory__c='AEPOHIO'
                                            );
        Contract testContract3 = new Contract(
                                                AccountId=testAcctList[4].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'RateReady',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'COST_BASED',
                                                Service_Territory__c='AEPOHIO'
                                            );
        Contract testContract4 = new Contract(
                                                AccountId=testAcctList[4].Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'RateReady',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'Large Stable Contract',
                                                Service_Territory__c='AEPOHIO'
                                            );                                    
        Contract testContract5 = new Contract(
                                                AccountId=testAcctList[5].Id,
                                                opportunity__c = opp.Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'RateReady',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'Large Stable Contract',
                                                Service_Territory__c='AEPOHIO'
                                            );                                    
        insert new list<contract>{testContract,testContract2,testContract3,testContract4,testContract5};
        //activate the Contract
        testContract.Status = 'Activated';
        testContract.Contract_Counter_Signed_Date__c = datetime.now();
        testContract2.Status = 'Activated';
        testContract2.Contract_Counter_Signed_Date__c = datetime.now();
        testContract3.Status = 'Activated';
        testContract3.Contract_Counter_Signed_Date__c = datetime.now();
        testContract4.Status = 'Activated';
        testContract4.Contract_Counter_Signed_Date__c = datetime.now();
        testContract5.Status = 'Activated';
        testContract5.Contract_Counter_Signed_Date__c = datetime.now();
        update new list<contract>{testContract,testContract2,testContract3,testContract4,testContract5};
        
        opp.accountId = testAcctList[2].Id;
        update opp;
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
        Contract_Term__c testContractTerm1 = new Contract_Term__c(
                                                    Contract__c = testContract.Id,
                                                    Term_Category__c = 'STANDARD_CHARGE',
                                                    Term_Type__c = 'BUNDLED_ENERGY',
                                                    Contract_Term_Value__c = 3.69,
                                                    Term_Start_Date__c = Datetime.now(),
                                                    Term_Stop_Date__c = Datetime.now().addMonths(11)
                                                );
        insert testContractTerm1;
        //create Contract LDC Record
        Contract_LDC__c testContractLDC = new Contract_LDC__c(  Name='Test CLDC 1',
                                                                LDC_Account__c=ldcTestAccount.Id,
                                                                Contract__c = testContract.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                IsSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC2 = new Contract_LDC__c( Name='Test CLDC 2',
                                                                LDC_Account__c=ldcTestAccount2.Id,
                                                                Contract__c = testContract2.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                IsSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC3 = new Contract_LDC__c( Name='Test CLDC 3',
                                                                LDC_Account__c=ldcTestAccount3.Id,
                                                                Contract__c = testContract3.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                IsSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC4 = new Contract_LDC__c( Name='Test CLDC 4',
                                                                LDC_Account__c=ldcTestAccount4.Id,
                                                                Contract__c = testContract3.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                IsSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC5 = new Contract_LDC__c( Name='Test CLDC 5',
                                                                LDC_Account__c=ldcTestAccount5.Id,
                                                                Contract__c = testContract4.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                IsSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC6 = new Contract_LDC__c( Name='Test CLDC 5',
                                                                LDC_Account__c=ldcTestAccount6.Id,
                                                                Contract__c = testContract5.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                IsSynchronized__c = false
                                                              );
        Contract_LDC__c testContractLDC7 = new Contract_LDC__c( Name='Test CLDC 5',
                                                                LDC_Account__c=ldcTestAccount7.Id,
                                                                Contract__c = testContract5.Id,
                                                                Term_Start_Date__c = Datetime.now(),
                                                                Term_Stop_Date__c = Datetime.now().addMonths(12),
                                                                IsSynchronized__c = false
                                                              );
        insert new list<contract_ldc__c>{testContractLDC,testContractLDC2,testContractLDC3,testContractLDC4,testContractLDC5,testContractLDC6,testContractLDC7};
        //create an AccountBillDeterminate__c record
        AccountBillDeterminate__c testABD = new AccountBillDeterminate__c(
                                                    Contract_LDC__c = testContractLDC.Id,
                                                    Determinate_Value__c = 2.0,
                                                    LDC_Account__c = ldcTestAccount.Id,
                                                    StartDateTime__c = Datetime.now(),
                                                    StopDateTime__c = Datetime.now().addMonths(11)
                                                );
        insert testABD;
		
		Billing_Group__c bg = new Billing_Group__c(Name='Test Billing Group',Account__c=testAcctList[4].Id,contract__c=testContract3.id,synchronized__c=false);
		insert bg;
		
		Billing_Group_Ldc__c bgldc = new Billing_Group_Ldc__c(billing_group__C = bg.id,ldc_account__c = ldcTestAccount3.id,synchronized__c = false);
		Billing_Group_Ldc__c bgldc2 = new Billing_Group_Ldc__c(billing_group__C = bg.id,ldc_account__c = ldcTestAccount4.id,synchronized__c = false);
		insert new list<Billing_Group_Ldc__c>{bgldc,bgldc2};
		
		testAcctList[1].Validation__c = 'Validated';
        testAcctList[3].Validation__c = 'Validated';
        testAcctList[4].Validation__c = 'Validated';
        testAcctList[5].Validation__c = 'Validated';
        update new list<account>{testAcctList[1],testAcctList[3],testAcctList[4],testAcctList[5]};
				
    }
    
    //Commented out by prasad in order to call the whole lodestar process
   /* @isTest
    private static void ObtainNonSynchronizedAccounts(){
        SetupTestData();
        
        Test.startTest();
        
        Set<Id> idSet = LodeStarActions.ObtainNonSynchronizedAccounts();
        
        Test.stopTest();
    }
    
    @isTest
    private static void NonSynchronizedRecsExist(){
        SetupTestData();
        
        Test.startTest();
        
        Boolean trueResExists = LodeStarActions.NonSynchronizedRecsExist();
        List<Account> accountList = [SELECT 
                                        Id, LodeStar_Integration_Status__c FROM 
                                    Account WHERE LodeStar_Integration_Status__c = 'Not Synchronized'];
        for(Account a:accountList){
            a.LodeStar_Integration_Status__c = 'Synchronized';
        }
        update accountList;
        Boolean falseResExists = LodeStarActions.NonSynchronizedRecsExist();
        
        Test.stopTest();
    }
    
    @isTest
    private static void ObtainDataForWSSynchronization(){
        SetupTestData();
        Test.startTest();
        
        Set<Id> resultIdSet = LodeStarActions.ObtainNonSynchronizedAccounts();
        List<LodeStar.LodeStarDataContainer> resultMap = LodeStarActions.ObtainDataObjectsForWSSynchronization(resultIdSet);
        
        Test.stopTest();
    }
    
    @isTest
    private static void MainProcess(){
        SetupTestData();
        Test.startTest();
        
        Set<Id> resultIdSet = LodeStarActions.ObtainNonSynchronizedAccounts();
        LodeStarActions.MainProcess(resultIdSet);
        
        Test.stopTest();
        
    }*/
    
    @isTest
    private static void Lodestar_test1(){
        SetupTestData();
        
        Boolean falseResExists = LodeStarActions.NonSynchronizedRecsExist();
        Test.setMock(WebServiceMock.class, new DynegylstarMockImpl());      
        time t =datetime.now().time();
        String schTime = '0 0 '+t.hour()+' * * ?';
        LodeStarIntegrationProcessor lsip = new LodeStarIntegrationProcessor();
        
        System.schedule('LodeStarIntegrationTest',schTime,lsip);
        Database.executeBatch(lsip);
        
    }
    
    @isTest
    private static void Lodestar_test2(){
        SetupTestData();
        
        Test.setMock(WebServiceMock.class, new DynegylstarErrorMockImpl());
        time t =datetime.now().time();
        String schTime = '0 0 '+t.hour()+' * * ?';
        LodeStarIntegrationProcessor lsip = new LodeStarIntegrationProcessor();
        
        System.schedule('LodeStarIntegrationTest',schTime,lsip);
        Database.executeBatch(lsip);
        try{
            dynegyComServicesLodeStar.BasicHttpBinding_ISforceLstar svc = new dynegyComServicesLodeStar.BasicHttpBinding_ISforceLstar();
            svc.GetLstarErrors();
        }
        catch(system.exception ex){
            
        }
        Boolean falseResExists = LodeStarActions.NonSynchronizedRecsExist();
        
    }
    
    @isTest
    private static void Lodestar_test3(){
        SetupTestData();
        
        //Boolean falseResExists = LodeStarActions.NonSynchronizedRecsExist();
        Test.setMock(WebServiceMock.class, new DynegylstarMockImpl());      
        time t =datetime.now().time();
        String schTime = '0 0 '+t.hour()+' * * ?';
        lodeStarValidator lsv = new lodeStarValidator();
        
        System.schedule('lodeStarValidatorTest',schTime,lsv);
        Database.executeBatch(lsv);
        
    }
   /* @isTest
    private static void Lodestar_test3(){
        SetupTestData();
        
        Test.setMock(WebServiceMock.class, new DynegylstarErrorMockImpl());
        time t =datetime.now().time();
        String schTime = ''+(t.second()+1)+' '+t.minute()+' '+t.hour()+' * * ?';
        LodeStarIntegrationProcessor lsip = new LodeStarIntegrationProcessor();
        
    	try{
    		try{
		        Contract_Type_Setting__c cts4 = new Contract_Type_Setting__c(Name='AEPOHIO-DUAL-CT1',Contract_Type__c='COST_BASED',New_Contract_Type__c='COST_BASED',Bill_Method__c='DUAL',Contract_Code__c='CT1',Service_Territory__c='AEPOHIO');
				insert cts4;
    		}
    		catch(System.Exception ex){
    			system.assertEquals('Script-thrown exception', ex.getMessage());
    		}
		
	        System.schedule('LodeStarIntegrationTest',schTime,lsip);
	        Database.executeBatch(lsip);
    		throw new LodeStar.LodeStarException('Script-thrown exception','Test Lodestar Exception');
    	}
    	catch(Exception e){
    		
    		system.assertEquals('Row with duplicate Name at index: 3', e.getMessage());
    	}
    }*/
     
    global class DynegylstarErrorMockImpl implements WebServiceMock {
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
        dynegyComServicesLodeStar.GetLstarErrorsResponse_element respElement = new dynegyComServicesLodeStar.GetLstarErrorsResponse_element();
        //respElement.GetLstarErrorsResult.Errors.LstarError.ErrorMsg 
        dynegyComServicesLodeStar.LstarErrors errors1 = new dynegyComServicesLodeStar.LstarErrors();
        
        dynegyComServicesLodeStar.ArrayOfLstarError errorarray = new dynegyComServicesLodeStar.ArrayOfLstarError();
        
        
        list<dynegyComServicesLodeStar.LstarError> errorlst = new list<dynegyComServicesLodeStar.LstarError>();
        
        dynegyComServicesLodeStar.LstarError error = new dynegyComServicesLodeStar.LstarError();
        
        error.ShortCode = 'FGGWEJZX43984JK';
        error.ErrorMsg = 'test';
        error.CustomerName = 'test customer';
        error.ExceptionTime = system.now();
        error.StatusCD = 'Test statuscd';
        errorlst.add(error);
        errorarray.LstarError = errorlst;
        errors1.errors = errorarray;
        respElement.GetLstarErrorsResult = errors1;
        response.put('response_x', respElement); 
       }
     } 
     
     global class DynegylstarMockImpl implements WebServiceMock {
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
        dynegyComServicesLodeStar.LoadstarInterfaceResponse_element respElement = new dynegyComServicesLodeStar.LoadstarInterfaceResponse_element();
        //respElement.GetLstarErrorsResult.Errors.LstarError.ErrorMsg 
        respElement.LoadstarInterfaceResult = 'Done';
        response.put('response_x', respElement); 
       }
     } 
      
}