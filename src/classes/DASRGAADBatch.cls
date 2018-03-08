global class DASRGAADBatch implements Database.Batchable < sObject > {

    global DASRGAADBatch() {

    }
    String q;
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */
    global Database.QueryLocator start(Database.BatchableContext context) {


        q = 'select id,ldc_account__r.ldc_account_status__C From DASR_Request__c  where (Dynegy_Initiated__c = False OR Accepted__c = true) AND Integration_Status__c = \'Complete\' AND Change_Effective_Date__c != null and Change_Effective_Date__c <= Today and Dasr_type__c = \'GAAD\'  and Most_recent_gaad__C = true and lastmodifieddate >='+label.DASR_GAAD_Date;

        system.debug('>>>>>>>>>>>>>>>>>*******' + q);

        return Database.getQueryLocator(q);
    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */
    global void execute(Database.BatchableContext context, List<DASR_Request__c> scope) {


        List<Id> idList = new List<Id> ();
        list<DASR_Request__c> lDASR = (list<DASR_Request__c>) scope;
        list<DASR_Request__c> updateDASRList = new list<DASR_Request__c>();
        system.debug('>>>>>>>>>>>>>>>>>*******' + scope);
        
        for (DASR_Request__C dasrRequest : lDASR) {
            if(dasrRequest.ldc_account__r.ldc_account_status__C.equalsignorecase('FINAL'))
                {
                    dasrRequest.Most_recent_gaad__C = false;
                    updateDASRList.add(dasrRequest);
                }
            else
                {
                	idList.add(dasrRequest.Id);
                    dasrRequest.Most_recent_gaad__C = false;
                    updateDASRList.add(dasrRequest);
                }
        }
        system.debug('>>>>>>>>>>>>>>>>>*******' + idList);
        Flow_EndContractLDC.TerminateActiveContractsByDASR(idList);
        system.debug('>>>>>>>>>>>>>>>>>*******' +updateDASRList);
        if (!updateDASRList.isempty()) update updateDASRList;

    }

    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */
    global void finish(Database.BatchableContext context) {

    }


}