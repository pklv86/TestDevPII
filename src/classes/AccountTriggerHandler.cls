/**
 * the purpose of this class is to provide methods that can be used in the 
 * AccountTrigger.
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 **/
global class AccountTriggerHandler {

    global static Boolean parentAccountUpdateToChildAcctUpdateRun = false;

    public static void SetChildAccountsToNotSynchronized(Set<Id> parentAccountId,String runJob){
        //first we need to make sure this has not run already
        if(!AccountTriggerHandler.parentAccountUpdateToChildAcctUpdateRun){
            //List<Account> childAccountsToUpdate = new List<Account>();
            AccountTriggerHandler.parentAccountUpdateToChildAcctUpdateRun = true;
            //now grab all of the Child Account Records of the selected Parents and set them to 'Not Synchronized'
            /*AggregateResult ar = [SELECT count(Id) FROM Account WHERE Business_Account__c IN :parentAccountId];
            Integer result =Integer.valueof(ar.get('expr0'));
            system.debug('acc : '+ar+' size : '+ar.get('expr0')+' Result : '+result);
            if(result>200){*/
                system.debug(' RUN JOB : '+runJob);
                if(runJob == 'Person'){
                    AccountTriggerHandlerBatch childAccBatch = new AccountTriggerHandlerBatch(parentAccountId,runJob);
                    if(!BatchUtility.IsconcurrentjobsRunning()){
                        Database.executebatch(childAccBatch,1000);
                    }
                    else{
                        System.scheduleBatch(childAccBatch, 'Re-Scheduled AccountTriggerBatch @ '+Datetime.now(), 5,1000);
                    }
                }
            /*}
            else{
                for(Account a:[SELECT Id, LodeStar_Integration_Status__c,Validation__c FROM Account WHERE Business_Account__c IN :parentAccountId]){
                    a.LodeStar_Integration_Status__c = 'Not Synchronized';
                    a.Validation__c = 'Modified';                
                    childAccountsToUpdate.add(a);
                }
                if(!childAccountsToUpdate.isEmpty())
                    update childAccountsToUpdate;
            }*/
        }
    }

 
    public static void setLDCNotSynchronized(Set<Id> accountId,String runJob) {    //, boolean runJob2
        system.debug('>>>>>>>>>>>>>>>>>*******' + accountId);
        
        /*List<Contract_LDC__c> lclc = new list<Contract_LDC__c> ();
        List<Contract_LDC__c> finalUpdateCLdc = new list<Contract_LDC__c> ();
        map<id, Contract_LDC__c> cmap = new map<id, Contract_LDC__c> ();
        map<id, Contract_LDC__c> clcmap = new map<id, Contract_LDC__c> ();  
        /*AggregateResult ar2 = [SELECT count(Id) FROM contract_ldc__c WHERE ldc_account__r.account__r.business_account__c IN :accountId and active__c = true and issynchronized__c = true];
        system.debug('==================aggregator value==========='+ar2);
            Integer result2 =Integer.valueof(ar2.get('expr0'));
            system.debug('acc : '+ar2+' size : '+ar2.get('expr0')+' Result : '+result2);
            if(result2>200){
                system.debug(' RUN JOB : '+runJob2);
                if(runJob2){*/
                if(!accountId.isempty() && accountId.size() > 0){
                    AccountTriggerHandlerBatch childAccBatch = new AccountTriggerHandlerBatch(accountId,runJob);
                    system.debug('=========childAccBatch============='+childAccBatch); 
                    if(!BatchUtility.IsconcurrentjobsRunning()){
                        Database.executebatch(childAccBatch,1000);
                    }
                    else{
                        System.scheduleBatch(childAccBatch, 'Re-Scheduled AccountTriggerBatch @ '+Datetime.now(), 5,1000);
                    }
                }
                    /*runJob2 = false;
                }
            }
            else{
                for(Contract_LDC__c a:[SELECT Id,Term_Start_Date__c, IsSynchronized__c,Contract__c,Contract__r.Account.id, LDC_Account__r.Account__r.id FROM Contract_LDC__c
                                           WHERE (Contract__r.Account.id IN :accountId or LDC_Account__r.Account__r.id IN :accountId) and Active__c = true and IsSynchronized__c = true order by Term_Start_Date__c ASC ]){
                    system.debug('==========business account========='+a);
                    a.isSynchronized__c = false;
                    finalUpdateCLdc .add(a);
                }
                if(!finalUpdateCLdc.isEmpty())
                    update finalUpdateCLdc ;
            }*/
      }
 } 
    
    /*Commented out by Nanda for DML 10001
        for (Contract_LDC__c contractLDC :[SELECT Id,Term_Start_Date__c, IsSynchronized__c,Contract__c,Contract__r.Account.id, LDC_Account__r.Account__r.id FROM Contract_LDC__c
                                           WHERE Contract__r.Account.id IN :accountId or LDC_Account__r.Account__r.id IN :accountId order by Term_Start_Date__c ASC ]) {
             
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
            
        system.debug('>>>>>>>>>>>>>>>>>*******' + cmap);
        system.debug('>>>>>>>>>>>>>>>>>*******' + lclc);
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
       
       system.debug('=====finalupdateCLdc================'+finalUpdateCLdc);
       if (!finalUpdateCLdc.isempty()) update finalUpdateCLdc; 
   }
}*/

/* OLD CODE Commented Out for 101 SOQL Queries
for(Account a : acc){
    a.LodeStar_Integration_Status__c = 'Not Synchronized';
    childAccountsToUpdate.add(a);
}
if(!childAccountsToUpdate.isEmpty()) {
    if(childAccountsToUpdate.size() >= 1000){
    //list<AsyncApexJob> runningjob = [SELECT ApexClass.name,ExtendedStatus,Id,JobItemsProcessed,JobType,MethodName,Status FROM AsyncApexJob where ApexClass.name='AccountTriggerHandlerBatch' and Status= 'Processing'];
    /*system.debug(' RUN JOB : '+runJob);
    if(runJob){
        AccountTriggerHandlerBatch childAccBatch = new AccountTriggerHandlerBatch(parentAccountId);
        if(!BatchUtility.IsconcurrentjobsRunning()){
            Database.executebatch(childAccBatch,1000);
        }
        else{
            System.scheduleBatch(childAccBatch, 'Re-Scheduled BatchCNIEnrollmentProcess @ '+Datetime.now(), 5,1000);
        }
        runJob = false;
    }*/