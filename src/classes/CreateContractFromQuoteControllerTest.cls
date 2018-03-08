/* 
 * Name: CreateContractFromQuoteControllerTest
 * Type: Apex Test Coverage  
 * Description: Test coverage for the CreateContractFromQuoteController Apex Controller.         
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         03/21/2016       1. Initial Version created
 */
@isTest
private class CreateContractFromQuoteControllerTest {

    static testMethod void CreateContractFromQuoteController_UnitTest() {
       ID optyRecId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Standard Opportunity').RecordTypeId;
       ID optyRecAmndId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Amendment').RecordTypeId;
       RecordType rtExec = [select id,name from RecordType where name='Executable' and sobjectType='Retail_Quote__c' limit 1];
        
       Account tstAccRec=new Account(Name='Test Account 001',Billing_Entity__c='Dynegy');
       Insert tstAccRec;
       
       Opportunity tstOppRec = new Opportunity(Name='Test Opty 001', Service_Territory__c='DAYTON', StageName='New',AccountId=tstAccRec.id,RecordTypeId=optyRecId,CloseDate = date.today().addDays(7));
       Insert tstOppRec;
       
       LDC_Vendor__c tstRecLDCVendor=new LDC_Vendor__c(Name='Test Vendor CCQ001',Service_Territory__c='DAYTON',DUNS__c='CCQ001',Utility_Code__c='CCQ0001',Service_State__c='OH');
       Insert tstRecLDCVendor;
       
       LDC_Account__c tstRecLDCAcc=new LDC_Account__c(Name='Test LDC Account CCQ001',Account__c=tstAccRec.Id,Service_Territory__c='DAYTON',LDC_Vendor__c=tstRecLDCVendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='TSTCCQ0001');
       Insert tstRecLDCAcc;
       
       Opportunity_LDC__c tstOLDCRec = new Opportunity_LDC__c(LDC_Account__c=tstRecLDCAcc.id,Opportunity__c=tstOppRec.id);
       Insert tstOLDCRec;
       
       Rate_Code__c tstRCRec = new Rate_Code__c(Name='TSTRC001',Price__c=0.00501,Service_Territory__c='DAYTON');
       Insert tstRCRec;
       
       Retail_Quote__c tstRQRec = new Retail_Quote__c(Opportunity__c=tstOppRec.id,RecordTypeId=rtExec.id,Request_Status__c = 'Pricing Complete',Quote_Price_KWH__c=0.00501,Term__c=12,Utility_Settlement_Zone__c = 'Test Utility');
       insert tstRQRec;
       
       String OptyContract = CreateContractFromQuoteController.contractExists(null);
       system.assertEquals(OptyContract,'NA');
       String RQContract = CreateContractFromQuoteController.contractExistsOnQuote(null);
       system.assertEquals(RQContract,'NA');
       
       OptyContract = CreateContractFromQuoteController.contractExists(tstOppRec.id);
       system.assertEquals(OptyContract,'NO');
       RQContract = CreateContractFromQuoteController.contractExistsOnQuote(tstRQRec.id);
       system.assertEquals(RQContract,'NO');
       
       Test.startTest();
       PageReference pageRef = Page.CreateContractFromQuote;
       Test.setCurrentPage(pageRef);
       
       ApexPages.StandardController sc = new ApexPages.StandardController(tstRQRec);
       CreateContractFromQuoteController CCQcontroller = new CreateContractFromQuoteController(sc);
       CCQcontroller.finishRequest();
       
       CCQcontroller.contractName = 'Test Contract CCQ001';
       CCQcontroller.quoteContract.Contract_Type__c = 'COST_BASED';
       CCQcontroller.quoteContract.Bill_Method__c = 'UCB';
       CCQcontroller.quoteContract.Contract_Counter_Signed_Date__c = system.now();
       
       CCQcontroller.finishRequest();
       CCQcontroller.exitRequest();
       
       PageReference tstRef = CCQcontroller.cancelCode();
       tstRef = CCQcontroller.submitCode();
       tstRef = CCQcontroller.findRateCode();
       
       
        
    }
    
    static testMethod void CreateContractFromQuoteController_UnitTest2() {
       ID optyRecAmndId = Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('Amendment').RecordTypeId;
       RecordType rtExec = [select id,name from RecordType where name='Executable' and sobjectType='Retail_Quote__c' limit 1];
        
       Account tstAccRec=new Account(Name='Test Account 001',Billing_Entity__c='Dynegy');
       Insert tstAccRec;
       
       Contract ct=new Contract(Name='Test Contract 2',StartDate=Date.today().addmonths(-1),Status='Draft',AccountId=tstAccRec.Id,contractTerm=12);
       insert ct;
        
       ct.Status='Activated';
       ct.Contract_Counter_Signed_Date__c = datetime.now();
       update ct;
    
       ct = [select id,name,contractnumber from contract];
       
       Opportunity tstOppRec = new Opportunity(Name='Test Opty Amnd', Service_Territory__c='DAYTON', StageName='New',AccountId=tstAccRec.id,RecordTypeId=optyRecAmndId,CloseDate = date.today().addDays(7),contractid=ct.id);
       insert tstOppRec;
       
       LDC_Vendor__c tstRecLDCVendor=new LDC_Vendor__c(Name='Test Vendor CCQ001',Service_Territory__c='DAYTON',DUNS__c='CCQ001',Utility_Code__c='CCQ0001',Service_State__c='OH');
       insert tstRecLDCVendor;
       
       LDC_Account__c tstRecLDCAcc=new LDC_Account__c(Name='Test LDC Account CCQ002',Account__c=tstAccRec.Id,Service_Territory__c='DAYTON',LDC_Vendor__c=tstRecLDCVendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='TSTCCQ0002');
       insert tstRecLDCAcc;
       
 	   Opportunity_LDC__c tstOLDCRec = new Opportunity_LDC__c(LDC_Account__c=tstRecLDCAcc.id,Opportunity__c=tstOppRec.id);
       insert tstOLDCRec;
 	
       Retail_Quote__c tstRQRec = new Retail_Quote__c(Opportunity__c=tstOppRec.id,RecordTypeId=rtExec.id,Request_Status__c = 'Pricing Complete',Quote_Price_KWH__c=0.05501,Term__c=12,Utility_Settlement_Zone__c = 'Test Utility');
       insert tstRQRec;
       
       Contract_Type_Setting__c ctypes = new Contract_Type_Setting__c(Name='DAYTON-DUAL',Bill_Method__c='DUAL',Contract_Type__c='UCBNONPOR',Service_Territory__c='DAYTON');
       insert ctypes;
       
       Test.startTest();
       PageReference pageRef = Page.CreateContractFromQuote;
       Test.setCurrentPage(pageRef);
       
       ApexPages.StandardController sc = new ApexPages.StandardController(tstRQRec);
       CreateContractFromQuoteController CCQcontroller = new CreateContractFromQuoteController(sc);
       
       CCQcontroller.contractName = 'Test Contract CCQ002';
       CCQcontroller.quoteContract.Bill_Method__c = 'DUAL';
       //Contract_Type_Setting__c cts = Contract_Type_Setting__c.getvalues('DAYTON-DUAL');
       CCQcontroller.finishRequest();
       
       CCQcontroller.quoteContract.Contract_Type__c = 'COST_BASED';
       CCQcontroller.quoteContract.Bill_Method__c = 'UCB';
       CCQcontroller.quoteContract.Contract_Counter_Signed_Date__c = system.now();
       CCQcontroller.finishRequest();
 	
       Test.stopTest();
       	
    }
}