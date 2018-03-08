global class FRMDeleter implements system.schedulable,Database.Batchable<sObject> {
	
	public FRMDeleter(){
		
	}
	
	global void execute(SchedulableContext SC){
        
        FRMDeleter frmdel = new FRMDeleter();
        Database.executeBatch(frmdel,2000);
        
    }
    
    global Database.QueryLocator Start(Database.BatchableContext bc){
        Datetime dt =system.now().addhours(-2);
        string frmQuery = 'select id From frm_report__c where lastmodifieddate != today';//< :dt
        system.debug('Query : '+frmQuery);
        return Database.getQueryLocator(frmQuery);
    }
    
    global void execute(Database.BatchableContext bc,list<sObject> scope){ 
    	list<frm_report__c> frmlst = (list<frm_report__c>)scope;
    	for(frm_report__c frm : frmlst){
    		frm.Reconcile__c = true;
    	}
    	update frmlst;
    	//delete frmlst;
    }
    
     global void finish(Database.BatchableContext bc){
     	
     }
}