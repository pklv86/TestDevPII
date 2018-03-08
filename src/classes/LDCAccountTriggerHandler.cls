public with sharing class LDCAccountTriggerHandler {
    
    public LDCAccountTriggerHandler(){
        
    }
    
    public void updateLDCIndividualInfo(set<id> ldcset){
        set<id> accset = new set<id>();
        for(ldc_account__c ldc : [select id,account__c,account__r.business_account__c from ldc_account__c where id IN : ldcset]){
            if(ldc.account__r.business_account__c != null)
                accset.add(ldc.account__r.business_account__c);
            else
                accset.add(ldc.account__c);
        }
        if(!accset.isempty()){
        	LDCInfo ldc = new LDCinfo(accset);
            Database.executeBatch(ldc,1000);
        }
    }
}

/*********** OLD CODE  LINE 14***********/
        /*ldcset.clear();
        aggregateresult ar = [select count(id) from ldc_account__c where account__c IN : accset or account__r.business_account__c IN : accset];
        system.debug('aggregateresult : '+ar);
        Integer LDCCount = Integer.valueof(ar.get('expr0'));
        if(LDCCount <= 10000){
	        for(ldc_account__c ldc : [select id from ldc_account__c where account__c IN : accset or account__r.business_account__c IN : accset]){
	            ldcset.add(ldc.id);
	        }
	        
	        if(!ldcset.isempty()){
	            LDCInfo ldc = new LDCinfo(ldcset);
	            Database.executeBatch(ldc,1000);
	        }
        }
        else{*/