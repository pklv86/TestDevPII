/**
 * The purpose of this class is to provide code coverage to the
 * Flow_SetAccountLDCAcctTypeCode class
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 **/
@isTest
public class Flow_SetActLDCActTypeCodeTest{
    private static void SetupTestData(){
      //first we need to create a test Account
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
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
        Account testAcct = new Account(
                                        Name='Test CnI',
                                        Supplier__c = testOperatingCompany.Id,
                                        BillingStreet = '2114 Bates Brothers Road',
                                        BillingCity = 'Westerville',
                                        BillingState = 'OH',
                                        BillingPostalCode = '43081',
                                        Billing_Entity__c='Dynegy'
                                        );
        insert testAcct;
        LDC_Account__c ldc1 = new LDC_Account__c(	Name = DynegyCommonUtils.generateRandomString(10),
	                                                Account__c=testAcct.Id,Service_Territory__c='AEPOHIO',
	                                                LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
	                                                Service_Street_1__c = '4048 Vineyard Drive',
	                                                Service_City__c = 'Solon',
	                                                Service_State__c = 'OH',
	                                                Service_Postal_Code__c = '44139'
	                                                );
        
        LDC_Account__c ldc2 = new LDC_Account__c(	Name = DynegyCommonUtils.generateRandomString(10),
                                                    Account__c=testAcct.Id,Service_Territory__c='AEPOHIO',
                                                    LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                    Service_Street_1__c = '4048 Vineyard Drive',
                                                    Service_City__c = 'Solon',
                                                    Service_State__c = 'OH',
                                                    Service_Postal_Code__c = '44139'
                                                    );
        LDC_Account__c ldc3 = new LDC_Account__c(	Name = DynegyCommonUtils.generateRandomString(10),
                                                    Account__c=testAcct.Id,Service_Territory__c='AEPOHIO',
                                                    LDC_Account_Number__c = DynegyCommonUtils.generateRandomString(10),
                                                    Service_Street_1__c = '4048 Vineyard Drive',
                                                    Service_City__c = 'Solon',
                                                    Service_State__c = 'OH',
                                                    Service_Postal_Code__c = '44139'
                                                    );
        insert new list<LDC_Account__c>{ldc1,ldc2,ldc3};
        
        //create test Contract
        Contract cnt1 = new Contract(
                                                AccountId=testAcct.Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'UCBNONPOR',
                                                Service_Territory__c='AEPOHIO'
                                            );
        Contract cnt2 = new Contract(
                                                AccountId=testAcct.Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'Large Stable Contract',
                                                Service_Territory__c='AEPOHIO'
                                            );                                    
        Contract cnt3 = new Contract(
                                                AccountId=testAcct.Id,
                                                Name='',
                                                Status='Draft',
                                                StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                                ContractTerm = 12,
                                                Bill_Method__c = 'DUAL',
                                                Rate_Code__c = 'TEST123',
                                                Contract_Type__c = 'Block and Index',
                                                Service_Territory__c='AEPOHIO'
                                            );
        insert new list<Contract>{cnt1,cnt2,cnt3};
        //activate the Contract
        cnt1.Status = 'Activated';
        cnt1.Contract_Counter_Signed_Date__c = datetime.now();
        cnt2.Status = 'Activated';
        cnt2.Contract_Counter_Signed_Date__c = datetime.now();
        cnt3.Status = 'Activated';
        cnt3.Contract_Counter_Signed_Date__c = datetime.now();
        update new list<Contract>{cnt1,cnt2,cnt3};
        //create Contract LDC Record
        Contract_LDC__c cldc1 = new Contract_LDC__c( LDC_Account__c=ldc1.Id,Contract__c = cnt1.Id);
        Contract_LDC__c cldc2 = new Contract_LDC__c( LDC_Account__c=ldc2.Id,Contract__c = cnt2.Id);
        Contract_LDC__c cldc3 = new Contract_LDC__c( LDC_Account__c=ldc3.Id,Contract__c = cnt3.Id);
        insert new list<Contract_LDC__c>{cldc1,cldc2,cldc3};
        //create DASR Record for enrollment
        DASR_Request__c dasr1 = new DASR_Request__c(Contract__c = cnt1.Id,LDC_Account__c = ldc1.Id,DASR_Type__c = 'GAAE',DASR_Submit_Date__c = Datetime.now(),
                                                            Integration_Status__c = 'Pending',Change_Effective_Date__c = Date.today(),Billing_Entity__c='Dynegy');
        
        DASR_Request__c dasr2 = new DASR_Request__c(Contract__c = cnt2.Id,LDC_Account__c = ldc2.Id,DASR_Type__c = 'GAAE',DASR_Submit_Date__c = Datetime.now(),
                                                            Integration_Status__c = 'Pending',Change_Effective_Date__c = Date.today(),Billing_Entity__c='Dynegy');
        
        DASR_Request__c dasr3 = new DASR_Request__c(Contract__c = cnt3.Id,LDC_Account__c = ldc3.Id,DASR_Type__c = 'GAAE',DASR_Submit_Date__c = Datetime.now(),
                                                            Integration_Status__c = 'Pending',Change_Effective_Date__c = Date.today(),Billing_Entity__c='Dynegy');
        insert new list<DASR_Request__c>{dasr1,dasr2,dasr3};
         //may need to create new custom setting record.
        AccountTypeSetting__c setting1  = new AccountTypeSetting__c(
                                
                                                                    AccountTypeCode__c = 'UCBNONPOR_RR',
                                                                    Contract_Type__c = 'UCBNONPOR',
                                                                    ServiceTerritory__c = 'AEPOHIO',
                                                                    Name = testVendor.Service_Territory__c + ' : ' + cnt1.Contract_Type__c
                                                                  );
        AccountTypeSetting__c setting2  = new AccountTypeSetting__c(
                                
                                                                    AccountTypeCode__c = 'RETAIL_STANDALONE',
                                                                    Contract_Type__c = 'Large Stable Contract',
                                                                    ServiceTerritory__c = 'AEPOHIO',
                                                                    Bill_Method__c = 'DUAL',
                                                                    Name = testVendor.Service_Territory__c + ' : CT1 : ' + cnt2.Bill_Method__c
                                                                  );
        AccountTypeSetting__c setting3  = new AccountTypeSetting__c(
                                
                                                                    AccountTypeCode__c = 'UCBNONPOR',
                                                                    Contract_Type__c = 'Large Stable Contract',
                                                                    ServiceTerritory__c = 'AEPOHIO',
                                                                    Bill_Method__c = 'Rate Ready',
                                                                    Name = testVendor.Service_Territory__c + ' : CT1 : Rate Ready'
                                                                  );
        AccountTypeSetting__c setting4  = new AccountTypeSetting__c(
                                
                                                                    AccountTypeCode__c = 'RETAIL_STANDALONE',
                                                                    Contract_Type__c = 'Block and Index',
                                                                    ServiceTerritory__c = 'AEPOHIO',
                                                                    Bill_Method__c = 'DUAL',
                                                                    Name = testVendor.Service_Territory__c + ' : CT2 : DUAL'
                                                                  );
        insert new list<AccountTypeSetting__c>{setting1,setting2,setting3,setting4};
    }
    
    @isTest
    public static void SetAccountLDCInfoFROMContractLDC(){
      SetupTestData();
      
      Test.startTest();
      
      List<Id> testIdList = new List<Id>();
      for(Contract_LDC__c cldc : [SELECT Id,ldc_account__c,contract__c FROM Contract_LDC__c]){
      	testIdList.add(cldc.Id);
      }
      
      Flow_SetAccountLDCAcctTypeCode.SetAccountLDCInfoFROMContractLDC(testIdList);
      
      Test.stopTest();
    }
}