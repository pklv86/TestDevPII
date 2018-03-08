/**
 * @Version 1.1 - Prasad - Modified for code coverage
 **/

@isTest
private class BatchSetEnrollmentProcessTest {
	
    
    static testmethod void test_Enrollment_Muni_Agg() {

        Account accnt=new Account(Name='Unit Test Dynegy',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account',ConstantUtility.CUST_MUNI_REC_TYPE),Billing_Entity__c='Dynegy');
        Account accnt1=new Account(Name='Unit Test CES',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account',ConstantUtility.CUST_MUNI_REC_TYPE),Billing_Entity__c='CES');
        insert new List<Account>{accnt,accnt1};
        
        Account pAccnt=new Account(FirstName='Unit',LastName='Test',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account','Muni Agg Individual Customer'),Business_Account__c = accnt.id,Billing_Entity__c='Dynegy');
        Account pAccntt=new Account(FirstName='Unit',LastName='Test123',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account','Muni Agg Individual Customer'),Business_Account__c = accnt.id,Billing_Entity__c='Dynegy');
        Account pAccntnull=new Account(FirstName='Unit',LastName='Test123',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account','Muni Agg Individual Customer'),Business_Account__c = accnt.id,Billing_Entity__c='Dynegy');
        Account pAccnt1=new Account(FirstName='Unit',LastName='Test 1',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account','Muni Agg Individual Customer'),Business_Account__c = accnt1.id,Billing_Entity__c='CES');
        Account pAccnt2=new Account(FirstName='Unit',LastName='Test 2',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account','Muni Agg Individual Customer'),Business_Account__c = accnt1.id,Billing_Entity__c='CES');
        Account pAccntIL1=new Account(FirstName='Unit',LastName='Test Il1',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account','Muni Agg Individual Customer'),Business_Account__c = accnt.id,Billing_Entity__c='Dynegy');
        Account pAccntIl2=new Account(FirstName='Unit',LastName='Test Il2',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account','Muni Agg Individual Customer'),Business_Account__c = accnt.id,Billing_Entity__c='Dynegy');
        insert new List<Account>{pAccnt,pAccntt,pAccnt1,pAccnt2,pAccntIL1,pAccntIL2,pAccntnull};

        LDC_Vendor__c ldcvendor=new LDC_Vendor__c(Name='Test Vendor1',Service_Territory__c='DEOHIO',DUNS__c='Test',Utility_Code__c='DEO',Service_State__c='OH');
        LDC_Vendor__c ldcvendor2=new LDC_Vendor__c(Name='Test Vendor2',Service_Territory__c='ComEd-IL',DUNS__c='Test2',Utility_Code__c='Com',Service_State__c='IL');
        insert new list<LDC_Vendor__c>{ldcvendor,ldcvendor2};

        Contract ct=new Contract(Name='Test Contract Dynegy',StartDate=Date.today().addmonths(-1),Status='Draft',AccountId=accnt.Id,contractTerm=12,Rate_code__c ='GEN21F');
        insert ct;
        
        ct.Status='Activated';
        ct.Contract_Counter_Signed_Date__c = datetime.now();
        ct.Enrollment_Stage__c='Ready to Enroll';
        update ct;
        
        Contract ct1=new Contract(Name='Test Contract CES',StartDate=Date.today().addmonths(-1),Status='Draft',AccountId=accnt1.Id,contractTerm=12,Rate_code__c ='GEN54F');
        insert ct1;
        
        ct1.Status='Activated';
        ct1.Contract_Counter_Signed_Date__c = datetime.now();
        ct1.Enrollment_Stage__c='Ready to Enroll';
        update ct1;

        contract cnt1= [select id,contractnumber from contract where name='Test Contract Dynegy'];
        contract cnt2= [select id,contractnumber from contract where name='Test Contract CES'];
        
        LDC_Account__c ldcAccnt=new LDC_Account__c(Name='Unit Test LDC D',Account__c=pAccnt.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='32126551212',Service_Territory__c='DEOHIO',contract__c = cnt1.ContractNumber);
        LDC_Account__c ldcAccnt2=new LDC_Account__c(Name='Unit Test LDC2 D',Account__c=pAccntt.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='32121212312',Service_Territory__c='DEOHIO',Ldc_Account_Status__c='ACTIVE',contract__c = cnt1.ContractNumber);
        LDC_Account__c ldcAccnt3=new LDC_Account__c(Name='Unit Test LDC3 C',Account__c=pAccnt1.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='3215346312',Service_Territory__c='DEOHIO',Ldc_Account_Status__c='ACTIVE',contract__c = cnt2.ContractNumber);
        LDC_Account__c ldcAccnt4=new LDC_Account__c(Name='Unit Test LDC4 C',Account__c=pAccnt2.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='36458735312',Service_Territory__c='DEOHIO',Ldc_Account_Status__c='NEW_ACCOUNT',contract__c = cnt2.ContractNumber);
        LDC_Account__c ldcAccnt5=new LDC_Account__c(Name='Unit Test LDC3 D',Account__c=pAccntIL1.Id,LDC_Vendor__c=ldcvendor2.Id,Bill_Cycle__c='2',LDC_Account_Number__c='52126551212',Service_Territory__c='ComEd-IL',contract__c = cnt1.ContractNumber);
        LDC_Account__c ldcAccnt6=new LDC_Account__c(Name='Unit Test LDC4 D',Account__c=pAccntIL2.Id,LDC_Vendor__c=ldcvendor2.Id,Bill_Cycle__c='2',LDC_Account_Number__c='62121212312',Service_Territory__c='ComEd-IL',Ldc_Account_Status__c='ACTIVE',contract__c = cnt1.ContractNumber);
        LDC_Account__c ldcAccnt7=new LDC_Account__c(Name='Unit Test LDC D',Account__c=pAccntnull.Id,LDC_Vendor__c=ldcvendor.Id,LDC_Account_Number__c='26435775287',Service_Territory__c='DEOHIO',contract__c = cnt1.ContractNumber);
        insert new List<Ldc_Account__c>{ldcAccnt,ldcAccnt2,ldcAccnt3,ldcAccnt4,ldcAccnt5,ldcAccnt6,ldcAccnt7};
       
        Bill_Cycle_Date__c bcd=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=ldcvendor.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
        insert bcd;
        Bill_Cycle_Date__c bcd1=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=ldcvendor.Id,Meter_Read_Date__c=Date.today().adddays(28),Meter_Read_Month__c=System.Now().addmonths(1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
        insert bcd1;
        
        Utility_Business_Rules__c setting = new Utility_Business_Rules__c(Name=ldcvendor.Service_Territory__c,Window_Days__c=-10,Days_in_Window__c=7,Days_Out_Window__c=-5);
        insert setting;
        
        EnrollmentHandler.SetContractToEnroll(cnt1.id);
        EnrollmentHandler.SetContractToEnroll(cnt2.id);
   }
    
    static testmethod void test_Enrollment_Muni_Agg_2() {

        scheduleBatchEnrollmentProcess sc=new scheduleBatchEnrollmentProcess();
        sc.execute(null);
    }

    static testmethod void test_Enrollment_CNI() {

        Account Cust=new Account(Name='Unit Test',RecordTypeId=ConstantUtility.getRecordTypeIdbyName('Account',ConstantUtility.CUST_CNI_REC_TYPE),Billing_Entity__c='Dynegy');
        insert Cust;
        LDC_Vendor__c ldcvendor=new LDC_Vendor__c(Name='Test Vendor2',Service_Territory__c='AEPOHIO',DUNS__c='Test',Utility_Code__c='OP1',Service_State__c='OH');
        insert ldcvendor;
        Opportunity opp =new Opportunity(Name='Test Opp',AccountId=Cust.Id,closeDate=Date.today().addmonths(5),StageName='New');
        insert opp;
        LDC_Account__c ldcAccnt=new LDC_Account__c(Name='Unit Test LDC',Account__c=Cust.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='2',LDC_Account_Number__c='32121212',Service_Territory__c=ldcvendor.Service_Territory__c);
        LDC_Account__c ldcAccnt2=new LDC_Account__c(Name='Unit Test LDC2',Account__c=Cust.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='7',LDC_Account_Number__c='321212123',Service_Territory__c=ldcvendor.Service_Territory__c,Ldc_Account_Status__c='ACTIVE');
        LDC_Account__c ldcAccnt4=new LDC_Account__c(Name='Unit Test LDC2',Account__c=Cust.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='7',LDC_Account_Number__c='421212123',Service_Territory__c=ldcvendor.Service_Territory__c,Ldc_Account_Status__c='ACTIVE',Rate_code__c='DK56');
        insert new list<ldc_account__c>{ldcAccnt,ldcAccnt2,ldcAccnt4};

        Contract ct=new Contract(Name='Test Contract',StartDate=Date.today().addmonths(-1),Status='Draft',AccountId=Cust.Id,Opportunity__c=opp.id,contractTerm=12);

        insert ct;
        ct.Status='Activated';
        ct.Contract_Counter_Signed_Date__c = datetime.now();
        ct.Enrollment_Stage__c='Ready to Enroll';
        update ct;
        Utility_Business_Rules__c setting = new Utility_Business_Rules__c(Name=ldcvendor.Service_Territory__c,Window_Days__c=7,Days_in_Window__c=7,Days_Out_Window__c=-5);
        
        insert setting;

        Bill_Cycle_Date__c bcd=new Bill_Cycle_Date__c(Bill_Cycle__c=2,LDC_Vendor__c=ldcvendor.Id,Meter_Read_Date__c=Date.today(),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
        insert bcd;
        Bill_Cycle_Date__c bcd2=new Bill_Cycle_Date__c(Bill_Cycle__c=7,LDC_Vendor__c=ldcvendor.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(-1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
        insert bcd2;
        Bill_Cycle_Date__c bcd3=new Bill_Cycle_Date__c(Bill_Cycle__c=7,LDC_Vendor__c=ldcvendor.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
        insert bcd3;
        Bill_Cycle_Date__c bcd4=new Bill_Cycle_Date__c(Bill_Cycle__c=7,LDC_Vendor__c=ldcvendor.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(1).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
        insert bcd4;
        Bill_Cycle_Date__c bcd5=new Bill_Cycle_Date__c(Bill_Cycle__c=7,LDC_Vendor__c=ldcvendor.Id,Meter_Read_Date__c=Date.today().adddays(7),Meter_Read_Month__c=System.Now().addmonths(2).format('MMM').toUpperCase(),Meter_Read_Year__c=String.valueof(Date.today().Year()));
        insert bcd5;

        Opportunity_LDC__c ldcOpp= new Opportunity_LDC__c(LDC_Account__c=ldcAccnt.Id,Opportunity__c=opp.id);
        Opportunity_LDC__c ldcOpp2= new Opportunity_LDC__c(LDC_Account__c=ldcAccnt2.Id,Opportunity__c=opp.id);
        Opportunity_LDC__c ldcOpp4= new Opportunity_LDC__c(LDC_Account__c=ldcAccnt4.Id,Opportunity__c=opp.id);
        insert new list<Opportunity_LDC__c>{ldcOpp,ldcOpp2,ldcOpp4};

        EnrollmentHandler.SetContractToEnroll(ct.id);
        EnrollmentHandler.SetContractToEnroll('');
        scheduleBatchEnrollmentProcess sc=new scheduleBatchEnrollmentProcess();
        sc.execute(null);
        
        LDC_Account__c ldcAccnt3=new LDC_Account__c(Name='Unit Test LDC3',Account__c=Cust.Id,LDC_Vendor__c=ldcvendor.Id,Bill_Cycle__c='50',LDC_Account_Number__c='321212124',Service_Territory__c=ldcvendor.Service_Territory__c);
        insert ldcAccnt3;
        Opportunity_LDC__c ldcOpp3= new Opportunity_LDC__c(LDC_Account__c=ldcAccnt3.Id,Opportunity__c=opp.id);
        insert ldcOpp3;
        
        EnrollmentHandler.SetContractToEnroll(ct.id);

        AsyncApexJob apexJob = new AsyncApexJob();
        apexjob = [Select Id,Apexclass.Name, Status, NumberOfErrors, JobItemsProcessed,ExtendedStatus, TotalJobItems, CreatedBy.Email from AsyncApexJob  where NumberOfErrors!= null AND apexclass.name='BatchStartEnrollmentProcess' limit 1];
        if(apexjob != null)BatchUtility.sendAsyncApexJobExceptionEmails(apexJob.id);

    }
    
}