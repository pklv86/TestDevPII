/** 
 * Name: AccountChildTriggerHandlerBatch
 * Type: Apex Class
 * Test Class: 
 * Description:  This batch job updates the Contract LDC's underneath the Accounts if any of these fields (Shortcode,Billing Street,Billing State,
                 Billing City,Billing Postalcode) are changed . 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Nanda Eluru                 03/24/2017       1. Initial Version created
 **/
global class AccountChildTriggerHandlerBatch implements Database.Batchable<sObject> {
    String query;
    global final Set<Id> parentAccId;
    public Integer size;

    global AccountChildTriggerHandlerBatch(Set<Id> accountId) {
        parentAccId=accountId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
    	system.debug('ID CHECK : '+parentAccId);
        query = 'SELECT Id,Term_Start_Date__c, IsSynchronized__c,Contract__c,Contract__r.Account.id, LDC_Account__r.Account__r.id FROM Contract_LDC__c WHERE (Contract__r.Account.id IN :parentAccId or LDC_Account__r.Account__r.business_account__c IN :parentAccId) and Active__c = true and IsSynchronized__c = true order by Term_Start_Date__c ASC';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        list<Contract_LDC__c> childAcc=(List<Contract_LDC__c>)scope; 
        for(Contract_LDC__c a : childAcc){
          system.debug('Before Change : '+a.IsSynchronized__c);
          a.IsSynchronized__c = false;
          system.debug('After Change : '+a.IsSynchronized__c);
        }
        system.debug('The batch size : '+childAcc.size()); 
        Database.update(childAcc);
    }
    global void finish(Database.BatchableContext BC) {}
}