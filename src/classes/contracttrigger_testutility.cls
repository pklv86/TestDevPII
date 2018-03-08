/*****************************************Dynegy*************************************************************************************
 * Name: contracttrigger_testutility                                                                                                     *                                                                                                               *
 * Test Class:contracttrigger_test                                                                                                  *
 * Description:  This test class is used to provide test coverage for Contracttrigger and contracttriggerhandler class                                 *                                            
 * Change History:                                                                                                                  *
 *==================================================================================================================================*
 * Version     Author                       Date             Description                                                            *
 * 1.0         Mounika Duggirala            02/26/2017      Initial Version created                                                 *                            
 ************************************************************************************************************************************/
public class contracttrigger_testutility
{
  public id createaccount()
    { 
    Account Acc=new Account();
    acc.Industry='Government';
        acc.name='test acc';
        acc.Billing_Entity__c='Dynegy';
         insert acc;
        return acc.id;
        
    }
    public id createnecessaryrecords()
    {
       id accid=createaccount();
        
        RecordType rt = [select id,Name from RecordType where SobjectType='opportunity' and Name='standard Opportunity' Limit 1];
        
        Opportunity opp= new Opportunity();
        opp.RecordTypeId=rt.id;
        opp.name='test opp';
        opp.Accountid=accid;
        opp.type='Small Business';
        opp.closedate=system.today();
        opp.stagename='New';
        opp.Service_Territory__c='AEPOHIO';
        
        opp.Pricing_Due_Date__c=system.today();
        insert opp;
        
        
        
        product2 Fp_pro=new product2();
        Fp_pro.name='FP-ONE';
        Fp_pro.IsActive=true;
        insert Fp_pro;
        
        RecordType retail_rt = [select id,Name from RecordType where SobjectType='Retail_Quote__c'  and Name='Executable' Limit 1];
        Retail_Quote__c retail=new Retail_Quote__c(); 
             
       retail.recordtypeid=retail_rt.id;  
       retail.Product__c=Fp_pro.id;
        retail.Payment_Terms__c='14';
        retail.Start_Term__c=system.Today();
        retail.Term__c=12;
        retail.Utility_Settlement_Zone__c='COMED';
        retail.ContractType__c='UCBPOR';
         retail.Margin__c=12;
        retail.Margin_Allocation__c='Lump Sum';
        retail.Energy_Fixed__c=12;
        retail.Index_Margin__c=12;
        retail.Index_Margin_Allocation__c='Lump Sum';
        retail.Broker_Fee__c=0.00;
        retail.Broker_Fee_Allocation__c='Lump Sum';
        retail.Municipality_Fee__c=0.00;
        retail.Municipality_Fee_Allocation__c='Lump Sum';
        retail.Marketing_Cost__c=0.00;
        retail.Marketing_Cost_Allocation__c='Lump Sum';
       string abc = (!string.isblank(retail.Contract_Energy_On_PK__c) && retail.Contract_Energy_On_PK__c !='') ? (retail.Contract_Energy_On_PK__c) : '0' ;
            
            if (abc.startswith('$'))
            abc = abc.removeStart('$');
             string abc1 = (!string.isblank(retail.Contract_Energy_Off_PK__c) && retail.Contract_Energy_Off_PK__c !='') ? (retail.Contract_Energy_Off_PK__c) : '0' ;
            
            if (abc1.startswith('$'))
            abc1 = abc1.removeStart('$');
            
            string abc2 = (!string.isblank(retail.Contract_Energy_Off_PK__c) && retail.Contract_Energy_Off_PK__c !='') ? (retail.Contract_Energy_Off_PK__c) : '0' ;
            
            if (abc2.startswith('$'))
            abc2 = abc2.removeStart('$');
             retail.Contract_Energy_Off_PK__c= '$0.123';
       retail.Contract_Energy_On_PK__c= '$0.456';
        retail.Opportunity__c=opp.id;
        insert retail;
        return retail.id;
    }
}