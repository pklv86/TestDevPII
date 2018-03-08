global class AccountResetForLodestar implements schedulable,Database.Batchable <sobject>,Database.Stateful{
    
    global void execute (schedulablecontext sc){
        AccountResetForLodestar acctolStar = new AccountResetForLodestar(ldcnumstr);
        Id bid = Database.executeBatch( acctolStar,20);
    }
    global AccountResetForLodestar(){

    }
    
    global final string accoffer;
    global final string ldcnumstr;
    global list<string> ldcnumlst;
    global AccountResetForLodestar(string ldcnum){
        ldcnumstr = ldcnum;
    }
    
    string query;
    
    global Database.QueryLocator start (Database.BatchableContext bc){
        ldcnumlst = ldcnumstr.split(',');
        system.debug('List size : '+ldcnumlst.size()+' : '+ldcnumlst);
        query='SELECT Account__c,Account__r.Business_Account__c,CRM_Id__c,Id,Last_Sent_to_LoadStar__c,LDC_Account_Number__c,Name FROM LDC_Account__c WHERE LDC_Account_Number__c IN: ldcnumlst ';
        return Database.getQueryLocator(query);
    }
     
    global void execute (Database.BatchableContext bc, list<sobject> scope ){
        list<LDC_Account__c> ldcacclst = (list<LDC_Account__c>)scope;
        system.debug('LDC Account size : '+ldcacclst.size());
        set<id> ldcid = new set<id>();
        set<id> accid = new set<id>();
        for(ldc_account__c ldcacc : ldcacclst){
            ldcid.add(ldcacc.id);
            accid.add(ldcacc.Account__c);
        }
        
        list<account> acclst = [select id,Business_Account__c,LodeStar_Integration_Status__c from account where id IN : accid];
        system.debug('Account size : '+acclst.size());
        for(Account acc : acclst){
            acc.LodeStar_Integration_Status__c='Not Synchronized';
        }
        update acclst;
        
        list<contract_ldc__c> cldclst = [SELECT Active__c,Contract__c,Id,IsSynchronized__c,LDC_Account_Number__c,LDC_Account__c,Name,Term_Start_Date__c,Term_Stop_Date__c FROM Contract_LDC__c WHERE LDC_Account_Number__c IN : ldcnumlst AND LDC_Account__c IN : ldcid and active__c = true];
        system.debug('Contract LDC size : '+ cldclst.size());
        for(contract_ldc__c cldc : cldclst){
            if(cldc.IsSynchronized__c != false)
                cldc.IsSynchronized__c = false;
        }
        update cldclst;
    }
    
    global void finish (Database.BatchableContext bc){
        
    }
    
}