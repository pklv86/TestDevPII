/*****************************************Dynegy*************************************************************************************
 * Name: contracttrigger_test                                                                                                     *                                                                                                               *
 * Test Class:contracttrigger_test                                                                                                  *
 * Description:  This test class is used to provide test coverage for Contracttrigger and contracttriggerhandler class                                 *                                            
 * Change History:                                                                                                                  *
 *==================================================================================================================================*
 * Version     Author                       Date             Description                                                            *
 * 1.0         Mounika Duggirala            02/26/2017      Initial Version created                                                 *                            
 ************************************************************************************************************************************/
@isTest
public class contracttrigger_test
{
    static testmethod void contracttriggertestmethod()
    {
        
        Account a = new account();
        a.name = 'Test broker';
        a.Billing_Entity__c = 'Dynegy';
        insert a;
        
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
    
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONE';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        cont.Bill_Method__c='Rate Ready';
        cont.Referral_Broker__c = a.id;
        cont.Contract_Broker_Fee__c=123;
        cont.Contract_Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Vol_Rec__c=123;
        cont.ISO_NITS__c=123;
        cont.Tax__c=123;
        cont.Holding_Cost__c=123;
        
        
        insert cont;
        cont.status='Activated';
        update cont;
        
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
        CTH.createcontracttermsforFP_ONE(cont);
        CTH.createcontracttermsforFP_ONE_PT_C(cont);
        CTH.createcontracttermsforFP_MULT(cont);
        CTH.createcontracttermsforFP_MULT_PT_C(cont);
        CTH.createcontracttermsforFP_MULT_PT_L(cont);
        CTH.createcontracttermsforFP_MULT_PT_T(cont);
        CTH.createcontracttermsforFP_MULT_PT_CL(cont);
        CTH.createcontracttermsforFP_MULT_PT_CLT(cont);
        CTH.createcontracttermsforFP_MULT_PT_LT(cont);
        CTH.createcontracttermsforFP_MULT_PT_CT(cont);
        CTH.createcontracttermsforFP_ONOFF(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_C(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_L(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_T(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_CL(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_CLT(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_LT(cont);
        CTH.createcontracttermsforFP_ONOFF_PT_CT(cont);
       
        
        contract contOH=new contract();
        contOH.StartDate=system.today();
        contOH.ContractTerm=5;
        contOH.status='draft';
        contOH.accountid=accid;
        contOH.product_name__c='FP-ONE';
        contOH.Retail_Quote__c=retailid;
        contOH.Service_Territory__c ='DAYTON';
        contOH.Bill_Method__c='Bill Ready';
        contOH.Referral_Broker__c = a.id;
        contOH.Contract_Broker_Fee__c=123;
        contOH.Contract_Municipality_Fee__c=123;
        contOH.Marketing_Cost__c=123;
        contOH.Default_Risk__c=123;
        contOH.Vol_Rec__c=123;
        contOH.ISO_NITS__c=123;
       
           
        contOH.Tax__c=123;
        contOH.Holding_Cost__c=123;
        contOH.Broker_Fee__c = -100;
        contOH.Municipality_Fee__c = -100;
        contOH.Contract_Marketing_Cost__c = 100;
        insert contOH;
        contOH.status='Activated';
        update contOH;
        
        Contracttriggerhandler  CTHOH=new Contracttriggerhandler();  
        CTHOH.createcontracttermsforFP_ONE(contOH);
        CTHOH.createcontracttermsforFP_ONE_PT_C(contOH);
        CTHOH.createcontracttermsforFP_MULT(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_C(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_L(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_T(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_CL(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_CLT(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_LT(contOH);
        CTHOH.createcontracttermsforFP_MULT_PT_CT(contOH);
        CTHOH.createcontracttermsforFP_ONOFF(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_C(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_L(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_T(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_CL(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_CLT(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_LT(contOH);
        CTHOH.createcontracttermsforFP_ONOFF_PT_CT(contOH);
        
        
        contract contOH1=new contract();
        contOH1.StartDate=system.today();
        contOH1.ContractTerm=5;
        contOH1.status='draft';
        contOH1.accountid=accid;
        contOH1.product_name__c='FP-ONE';
        contOH1.Retail_Quote__c=retailid;
        contOH1.Service_Territory__c ='DAYTON';
        contOH1.Bill_Method__c='Bill Ready';
        contOH1.Referral_Broker__c = a.id;
        contOH1.Contract_Broker_Fee__c=123;
        contOH1.Contract_Municipality_Fee__c=123;
        contOH1.Marketing_Cost__c=123;
        contOH1.Vol_Rec__c=123;
        contOH1.ISO_NITS__c=123;
        contOH1.Tax__c=123;
        contOH1.Holding_Cost__c=123;
        contOH1.Broker_Fee__c = -100;
        contOH1.Municipality_Fee__c = -100;
        insert contOH1;
        contOH1.status='Activated';
        update contOH1;
    }

   /* public static testmethod void contracttriggertestmethod2()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONE-PT-C';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod3()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod4()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-C';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();   
    }
    public static testmethod void contracttriggertestmethod5()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();      
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-L';
        cont.Service_Territory__c ='Comed-IL';
        cont.Retail_Quote__c=retailid;
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod6()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();      
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-T';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod7()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();      
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-CL';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod8()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();       
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-CLT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod9()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();       
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-LT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod10()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-MULT-PT-CT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod11()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod12()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();       
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-C';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod13()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-L';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod14()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-T';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod15()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-CL';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
     public static testmethod void contracttriggertestmethod22()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-CLT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod16()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-LT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod17()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();       
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='FP-ONOFF-PT-CT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();  
    }
    public static testmethod void contracttriggertestmethod18()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();      
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='PCTG-PT-L';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler();        
    }
    public static testmethod void contracttriggertestmethod19()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='PCTG-PT-LT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler(); 
    }
    public static testmethod void contracttriggertestmethod20()
    {
        contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.accountid=accid;
        cont.product_name__c='PCTG-PT-CL';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler(); 
    }
    public static testmethod void contracttriggertestmethod21()
    {
         contracttrigger_testutility testutility=new contracttrigger_testutility();
        id retailid=testutility.createnecessaryrecords();
        id accid=testutility.createaccount();        
        contract cont=new contract();
        cont.StartDate=system.today();
        cont.ContractTerm=5;
        cont.status='draft';
        cont.Service_Territory__c='AEPOHIO';
        cont.accountid=accid;
        cont.product_name__c='PCTG-PT-CLT';
        cont.Retail_Quote__c=retailid;
        cont.Service_Territory__c ='Comed-IL';
        insert cont;
        cont.status='Activated';
        cont.Bill_Method__c= 'DUAL';
        cont.Broker_Fee__c=123;
        cont.Municipality_Fee__c=123;
        cont.Marketing_Cost__c=123;
        cont.Default_Risk__c=123;
        Cont.Retail_Quote__r.Contract_Energy_Off_PK__c= 123;
        Cont.Retail_Quote__r.Contract_Energy_On_PK__c 456;
        cont.Holding_Cost__c=123;
        update cont;
        Contracttriggerhandler  CTH=new Contracttriggerhandler(); 
    }*/
}