/**
 * This class is designed to provide code coverage for the 
 * AccountTrigger and AccountTriggerHandlerBatch classes.
 *
 * @CreatedBy Prasad Paladugu
 * @version 1.0
 **/

@isTest
public class AccountResetForLodestarTest {
    
     public static testmethod void AccountResetForLodestarTest(){
        
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        //we need to create a test operating company
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST', Active__c = true);
        insert testOperatingCompany;
        
        LDC_Vendor__c testVendor = new LDC_Vendor__c(Name='Test Vendor',DUNS__c = DynegyCommonUtils.generateRandomString(8),Legacy_ID__c = 'TVNDR',
                                   Service_Territory__c = 'AEPOHIO',Utility_Code__c = 'TST',Vendor_Type__c = 'LDC',Service_State__c = 'OH');
        insert testVendor;
        
        Account testAcct = new Account(Name='Test CnI',Supplier__c = testOperatingCompany.Id,BillingStreet = '2114 Bates Brothers Road',
                           BillingCity = 'Westerville',BillingState = 'OH',BillingPostalCode = '43081',Billing_Entity__c='Dynegy');
        insert testAcct;
        testAcct.LodeStar_Integration_Status__c = 'Not Synchronized';
        update testAcct;
        
        LDC_Account__c ldcTestAccount = new LDC_Account__c(Name = DynegyCommonUtils.generateRandomString(10),Account__c=testAcct.Id,
                                        LDC_Account_Number__c = '1234567890' , Service_Street_1__c = '4048 Vineyard Drive',
                                        Service_City__c = 'Solon',Service_State__c = 'OH',Service_Postal_Code__c = '44139',LDC_Start_Date__c=date.today());
        insert ldcTestAccount;
        
        Contract testContract = new Contract(AccountId=testAcct.Id,Name='',Status='Draft',StartDate = Date.newInstance(Date.today().year(),Date.today().month(),1),
                                ContractTerm = 12,Bill_Method__c = 'DUAL', Rate_Code__c = '0611R3732',Service_Territory__c='AEPOHIO');        //,Contract_Type__c = 'COST_BASED'
        insert testContract;
        
        //activate the Contract
        testContract.Status = 'Activated';
        testContract.Contract_Counter_Signed_Date__c = datetime.now();
        update testContract;
        
        Contract_LDC__c testContractLDC = new Contract_LDC__c(LDC_Account__c=ldcTestAccount.Id,Contract__c = testContract.Id,Active__c=true,IsSynchronized__c=true);
        insert testContractLDC;
        
        time t =datetime.now().time();
        system.debug(''+t+' : '+t.minute()+' : '+t.hour());
        String schTime = '0 0 '+t.hour()+' * * ?';
        string str=''+ldcTestAccount.LDC_Account_Number__c+',1465846389';
        system.schedule('Test Acc Reset', schTime, new AccountResetForLodestar(str));
        AccountResetForLodestar acclstarnull = new AccountResetForLodestar();
        
        string query = 'SELECT Account__c,Account__r.Business_Account__c,CRM_Id__c,Id,Last_Sent_to_LoadStar__c,LDC_Account_Number__c,Name FROM LDC_Account__c WHERE LDC_Account_Number__c IN: ldcnumlst ';
        AccountResetForLodestar acclstar = new AccountResetForLodestar(str);
        Database.executeBatch(acclstar);
        
     }
    
}