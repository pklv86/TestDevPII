/* 
 * Name: AccountTriggerHandlerBatch
 * Type: Apex Class
 * Test Class: AccountTriggerHandlerBatchTest
 * Description:  This batch job updates the Accounts if any of these fields (Name,Shortcode,Billing Street,Billing State,
                 Billing City,Billing Postalcode) are changed . 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu         05/23/2016       1. Initial Version created
 */
global class AccountTriggerHandlerBatch implements Database.Batchable<sObject> {
    
     String query;
     global final Set<Id> parentAccId;
     global String isPerson;
     public Integer size;
     //global list<account> childAcc {get; set;}
    
    global AccountTriggerHandlerBatch(Set<Id> parentAccountId, String person) {
        parentAccId=parentAccountId;
        isperson = person;
    }
    
    /*global AccountTriggerHandlerBatch(Set<Id> parentAccountId, Boolean person) {
        parentAccId=parentAccountId;
        isperson = person;
    }*/
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('Test : '+parentAccId);
        if(isPerson == 'Person')
            query = 'Select Id,LodeStar_Integration_Status__c FROM Account WHERE Business_Account__c IN :parentAccId';
        else
            query = 'SELECT Id,Term_Start_Date__c, IsSynchronized__c,Contract__c,Contract__r.Account.id, LDC_Account__r.Account__r.id FROM Contract_LDC__c WHERE (Contract__r.AccountId IN : parentAccId or LDC_Account__r.Account__c IN : parentAccId) and IsSynchronized__c = true order by Term_Start_Date__c ASC';
        system.debug('Query : '+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        if(isPerson == 'Person'){
            list<account> childAcc=(List<Account>)scope; 
            //BatchUtility.sendAccountEmails( BC.getJobId(),childAcc.size());
            for(Account a : childAcc){
                system.debug('Before Change : '+a.LodeStar_Integration_Status__c);
                a.LodeStar_Integration_Status__c = 'Not Synchronized';
                a.Validation__c = 'Modified';
                system.debug('After Change : '+a.LodeStar_Integration_Status__c);
            }
            system.debug('The batch size : '+childAcc.size()); 
            Database.update(childAcc);
        }
        else{
            list<Contract_LDC__c> childAcc=(List<Contract_LDC__c>)scope; 
            List<Contract_LDC__c> lclc = new list<Contract_LDC__c> ();
            List<Contract_LDC__c> finalUpdateCLdc = new list<Contract_LDC__c> ();
            map<id, Contract_LDC__c> cmap = new map<id, Contract_LDC__c> ();
            map<id, Contract_LDC__c> clcmap = new map<id, Contract_LDC__c> ();
            for(Contract_LDC__c contractLDC : childAcc){  
                system.debug(contractLDC.Contract__r.Account.id);  
                if (contractLDC.Contract__r.Account.id != null){
                    //cmap.put(contractLDC.Contract__r.Account.id, contractLDC);
                    system.debug(contractLDC.LDC_Account__r.Account__r.id);
                    if (contractLDC.LDC_Account__r.Account__r.id != null){
                        system.debug('insider main condition');
                        cmap.put(contractLDC.LDC_Account__r.Account__r.id, contractLDC);
                    }    
                }
            }
            system.debug(cmap);
            lclc = cmap.values();
            
            system.debug('=====CMAP=====' + cmap);
            system.debug('=====LCLC=====' + lclc);
            for (Contract_LDC__c clc : lclc) {
            clcmap.put(clc.id, clc);
            }
            
            lclc = clcmap.values();
            
            for (Contract_LDC__c clc : lclc) {
                if (clc.IsSynchronized__c != false){
                    clc.IsSynchronized__c = false;
                    //for SCR:1186 To upadte only modified records
                    finalUpdateCLdc.add(clc);
                }
            }
            
            system.debug('=====finalupdateCLdc====='+finalUpdateCLdc);
            if (!finalUpdateCLdc.isempty()) update finalUpdateCLdc; 
            
         /**   
            for(Contract_LDC__c a : childAcc){
              system.debug('Before Change : '+a.IsSynchronized__c);
              a.IsSynchronized__c = false;
              system.debug('After Change : '+a.IsSynchronized__c);
            }
            system.debug('The batch size : '+childAcc.size()); 
            Database.update(childAcc);
            */
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        //BatchUtility.sendAccountEmails( BC.getJobId(),0);
    }
    
}