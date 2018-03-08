/**********************************************************
Class :  FlagContractLDC
Version		Date			Author
1.0			11/29/2017		Prasad Paladugu	
***********************************************************/
global class FlagContractLDC implements system.schedulable,database.Batchable<sObject>,database.Stateful{
    
    public FlagContractLDC(){
    }
    
    global set<id> aeIDSet;
    
    global void execute(schedulableContext sc){
    	system.debug('Schedule Run Start >>>>>>>>');
    	FlagContractLDC fcldc = new FlagContractLDC();
    	database.executebatch(fcldc,100);
    }
    
    global database.QueryLocator Start (database.BatchableContext bc){
    	
    	aeIDSet = new set<id>();
    	for(Account_Exception__c ae : [select dasr_request__c from Account_Exception__c where Reason_Code__c='DTM150' and Most_Recent__c = true]){
    		aeIDSet.add(ae.dasr_request__c);
    	}
    	
    	string q='select id, dasr_type__c, dynegy_initiated__c,ldc_account__c,contract__c, LDC_Account__r.LDC_Account_Status__c From DASR_Request__c  where'+ 
    			 '(Dynegy_Initiated__c = true AND Change_Effective_Date__c != null AND ((Accepted__c = true AND Integration_Status__c = \'Complete\'  and '+
    			 'Dasr_type__c = \'GAAE\' and dasr_activated__C = false and lastmodifieddate >= '+label.dasr_gaae+') OR (Dasr_type__c = \'GAAC\' and '+
    			 'dasr_activated__C = false and lastmodifieddate >= '+label.dasr_gaae+' and (Integration_Status__c = \'Complete\' OR (Integration_Status__c = \'Manually Fulfilled\' '+
    			 'and ldc_account__r.service_territory__c = \'ComEd-IL\'))))) OR (ID IN: aeIDSet)';
    	return database.getQueryLocator(q);    	
    }
    
    global void execute(database.BatchableContext bc,list<dasr_request__c> scope){
    	
    	list<dasr_request__c> dasrlst = (list<dasr_request__c>)scope;
    	set<string> dasrESet = new set<string>();
    	set<string> dasrCSet = new set<string>();
    	list<contract_ldc__c> cldclst = new list<contract_ldc__c>();
    	list<id> cldcEId = new list<id>();
    	list<id> cldcCId = new list<id>();
    	set<id> ldcset = new set<id>();
    	set<id> cntset = new set<id>();
    	
    	for(dasr_request__c dasr : dasrlst){
			ldcset.add(dasr.ldc_account__c);
			if(dasr.contract__c != null)
				cntset.add(dasr.contract__c);
			
    		if(dasr.dasr_type__c == 'GAAE')
    			dasrESet.add(dasr.ldc_account__c+''+dasr.contract__c);
			else if(dasr.dasr_type__c == 'GAAC')
    			dasrCSet.add(dasr.ldc_account__c+''+dasr.contract__c);
			
			if(aeIDSet.contains(dasr.id)){
				
			}
    	}
    	
    	for(contract_ldc__c cldc : [select id,ldc_account__c,contract__c from contract_ldc__c where ldc_account__c IN : ldcset and contract__c IN : cntset order by createddate]){
    		cldc.active__c = true;
    		if(dasrESet.contains(cldc.ldc_account__c+''+cldc.contract__c))
    			cldcEId.add(cldc.id);
    		else if(dasrCSet.contains(cldc.ldc_account__c+''+cldc.contract__c))
    			cldcCId.add(cldc.id);
    		cldclst.add(cldc);
    	}
    	
    	//for only GAAC dasrs specifically as they move from one to other contract and reenrollment is not considered as there might be gap in service
    	Flow_DeactivateNonApplicableContracts.DeactivateNonActiveContractLDCRecs(cldcCId);
    	
    	cldcEId.addAll(cldcCId);
    	Flow_ReparentAccountfromContractLDC.ReparentAccount(cldcEId);
    	
    	list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
    	for(Billing_Group_Ldc__c bgldc : [select id,active__c from Billing_Group_Ldc__c where ldc_account__c IN : ldcset and Billing_Group__r.contract__c IN : cntset]){
    		bgldc.active__c = true;
    		bgldclst.add(bgldc);
    	}
    	if(!bgldclst.isempty()) update bgldclst;
    }
    
    global void finish(database.BatchableContext bc){
    	
    }
}