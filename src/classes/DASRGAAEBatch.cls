global class DASRGAAEBatch implements Database.Batchable < sObject > {

    global DASRGAAEBatch() {

    }
    String q;
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */
    global Database.QueryLocator start(Database.BatchableContext context) {
        q = 'select id, dasr_type__c, dynegy_initiated__c,ldc_account__c,contract__c, LDC_Account__r.LDC_Account_Status__c From DASR_Request__c  where Dynegy_Initiated__c = true AND Accepted__c = true AND Integration_Status__c = \'Complete\' AND Change_Effective_Date__c != null and Dasr_type__c = \'GAAE\' and Most_recent_gaad__c = true and lastmodifieddate >= '+label.dasr_gaae;
        //and Change_Effective_Date__c<=Today REMOVED THE FILTER FOR SENDING EARLY TO LODESTAR
        system.debug('>>>>>>>>>>>>>>>>>*******' + q);
        return Database.getQueryLocator(q);
    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */
    global void execute(Database.BatchableContext context, List<DASR_Request__c> scope) {

        list<DASR_Request__c> lDASR = (list<DASR_Request__c>) scope;
        list<DASR_Request__c> updateDASRList = new list<DASR_Request__c>();       
        set<id> ldcset = new set<id>();
        set<id> cntset = new set<id>();
        list<ldc_account__c> ldclst = new list<ldc_account__c>();
        list<Id> idList = new List<Id> ();
        map<string,id> cldcmap = new map<string,id>();
        
        system.debug('>>>>>>>>>>>>>>>>>*******' + scope);
        for(DASR_Request__C dasrRequest : lDASR) {
            idList.add(dasrRequest.Id); 
            dasrRequest.Most_recent_gaad__C = false;
            dasrRequest.dasr_activated__c = false;
            updateDASRList.add(dasrRequest);
            ldcset.add(dasrRequest.ldc_account__c);
            cntset.add(dasrRequest.contract__c);
        }    
        system.debug('Final Ids:' + idList);
        Flow_SetActiveContractLDC.setActiveContractFromDASR(idList);   
        
        for(contract_ldc__c cldc : [select id,ldc_account__c,contract__c from contract_ldc__c where ldc_account__c IN : ldcset and contract__c IN : cntset order by createddate]){
        	cldcmap.put(cldc.ldc_account__c+''+cldc.contract__c,cldc.id);
        }
        if(!cldcmap.isempty()) 
        	Flow_SetAccountLDCAcctTypeCode.SetAccountLDCInfoFROMContractLDC(cldcmap.values());
             
        system.debug('>>>>>>>>>>>>>>>>>*******' + updateDASRList);
        if (!updateDASRList.isempty()) update updateDASRList;  
        
        // Added by Prasad for blanking out ldc end date on enrollment response and activating contract ldc 
        if(!ldcset.isempty()){
        	for(ldc_account__c ldc : [select id,ldc_end_date__c,LDC_Account_Status__c from ldc_account__c where id IN : ldcset]){
        		if(ldc.ldc_end_date__c != null){
        			ldc.ldc_end_date__c = null;
        			ldc.LDC_Account_Status__c = 'ACTIVE';
        			ldclst.add(ldc);
        		}
        	}
        }
        if(!ldclst.isempty()) update ldclst;  
   }

    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */
    global void finish(Database.BatchableContext context) {

    }
}