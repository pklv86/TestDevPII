global class OLDCBatch implements Database.Batchable < sObject > {

    global OLDCBatch() {

    }
    String q;
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */
    global Database.QueryLocator start(Database.BatchableContext context) {
    	
		Datetime dt = system.now().addhours(-1);
		system.debug('Check : '+system.now()+' : '+dt);
        q = 'Select id,LDC_Account__c,LDC_Account__r.Acct_Annual_Usage__c,LDC_Annual_Usage__c,Opportunity__c from Opportunity_LDC__c where (LDC_Account__r.lastmodifieddate >: dt)';
        q+= ' or (createddate = today or lastmodifieddate >: dt)';

        system.debug('>>>>>>>>>>>>>>>>>*******' + q);
        return Database.getQueryLocator(q);
    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */
    global void execute(Database.BatchableContext context, List<Opportunity_LDC__c> scope) {

        list<Opportunity_LDC__c> lldcOpp = (list<Opportunity_LDC__c>) scope;
        list<Opportunity_LDC__c> oldclst = new list<Opportunity_LDC__c>();
        system.debug('>>>>>>>>>>>>>>>>>*******' + scope);
        for (Opportunity_LDC__c ldcOpp : lldcOpp) {
            if(ldcOpp.LDC_Annual_Usage__c != ldcOpp.LDC_Account__r.Acct_Annual_Usage__c){
        	    ldcOpp.LDC_Annual_Usage__c=ldcOpp.LDC_Account__r.Acct_Annual_Usage__c;
        	    oldclst.add(ldcopp);
            }
        }
        if (!oldclst.isempty()) update oldclst;
    }

    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */
    global void finish(Database.BatchableContext context) {

    }


}