/**
 * This class is designed to provide code coverage for the 
 * OLDCBatch class.
 *
 * @
 * @version 1.0
 **/

@isTest
public class OLDCBatchTest{
    
    public static testmethod void OLDCBatchTest(){
        
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> acctRecTypeMap = dsr.getRecordTypeInfosByName();
        Schema.RecordTypeInfo ciAcctRecType = acctRecTypeMap.get('C&I Customer');
        //we need to create a test operating company
        Supplier__c testOperatingCompany = new Supplier__c(Name='Test Supplier',Supplier_DUNS__c = 'DUNSTEST',Legacy_ID__c = 'TEST',Master_DUNS__c = 'DUNSTEST',
                                           Organization_Identifier_Code__c = 'TESTSUP',Supplier_Code__c = 'TEST',ESP_Account_Number__c = 'TEST', Active__c = true);
        insert testOperatingCompany;
        
        ID optyRecId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Standard Opportunity').RecordTypeId;
        RecordType rtExec = [select id,name from RecordType where name='Executable' and sobjectType='Retail_Quote__c' limit 1];
  
        Account Cust=new Account(Name='Unit Test',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account',ConstantUtility.CUST_CNI_REC_TYPE),Billing_Entity__c='Dynegy');
        Insert Cust;
        LDC_Vendor__c ldcvendor=new LDC_Vendor__c(Name='Test Vendor2',Service_Territory__c='AEPOHIO',DUNS__c='Test',Utility_Code__c='OP1',Service_State__c = 'OH');
        Insert ldcvendor;
        Opportunity opp =new Opportunity(Name='Test Opp',AccountId=Cust.Id,closeDate=Date.today().addmonths(5),StageName='New');
        Insert opp;
        LDC_Account__c ldcAccnt=new LDC_Account__c(Name='Unit Test LDC',Account__c=Cust.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='32121212',Service_Territory__c=ldcvendor.Service_Territory__c);
        Insert ldcAccnt;
        LDC_Account__c ldcAccnt2=new LDC_Account__c(Name='Unit Test LDC2',Account__c=Cust.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='7',LDC_Account_Number__c='321212123',Service_Territory__c=ldcvendor.Service_Territory__c,Ldc_Account_Status__c='ACTIVE');
        Insert ldcAccnt2;


        Opportunity_LDC__c ldcOpp= new Opportunity_LDC__c(LDC_Account__c=ldcAccnt.Id,Opportunity__c=opp.id);
        Insert ldcOpp;
        Opportunity_LDC__c ldcOpp2= new Opportunity_LDC__c(LDC_Account__c=ldcAccnt2.Id,Opportunity__c=opp.id);
        Insert ldcOpp2;        

        system.schedule('Test OLDC', '0 0 17 * * ?', new OLDCBatchScheduler());

        ldcAccnt.Acct_Annual_Usage__c = 43252.34;
        ldcAccnt2.Acct_Annual_Usage__c = 231.63;
        update new list<ldc_account__c>{ldcAccnt,ldcAccnt2};
        
        OLDCBatch oLDCBatch = new OLDCBatch();
        //testContractLDC2.active__c = false;
        //update testContractLDC2;
        oLDCBatch = new OLDCBatch();
        Database.executeBatch(oLDCBatch, 20);
        
        
        
    }
    
}