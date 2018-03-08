global class CESInbound implements schedulable,Database.Batchable<sobject>,Database.stateful {
	
	String query;
	
	global void execute (SchedulableContext sc){
		CESInbound ci = new CESInbound();
		Database.executeBatch(ci,100);		
	}
	
	global Database.QueryLocator start(Database.BatchableContext bc){
		query = ConstantUtility.getObjectFieldsQuery('Dasr_Summary__c')+' from dasr_summary__c where createddate <= today and processed__c = false '+
		        'and (response__c = \'Accept\' or response__c = \'Reject\')';
		system.debug('Query : '+query);
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext bc, List<sobject> scope){
		list<dasr_summary__c> dasrslst = (list<dasr_summary__c>)scope;
		set<string> ldcnumber = new set<string>();
		set<string> ldcnumbertemp = new set<string>();
		map<string,string> ldcnumforutility = new map<string,string>();
		list<dasr_request__c> dasrlst = new list<dasr_request__c>();
		list<dasr_request__c> dasrlstupdate = new list<dasr_request__c>();
		list<dasr_summary__c> dasrslstupdate = new list<dasr_summary__c>();
		
		for(dasr_summary__c dasrs : dasrslst){
			ldcnumber.add(dasrs.LDC_Account_Number__c);
			ldcnumforutility.put(dasrs.LDC_Account_Number__c,dasrs.utility__c);			
		}
		ldcnumbertemp.addAll(ldcnumber);		
		
		string dasrquery = ConstantUtility.getObjectFieldsQuery('Dasr_request__c')+',ldc_account__r.LDC_Account_Number__c from dasr_request__c where '+
						   'ldc_account__r.LDC_Account_Number__c =: ldcnumber and Integration_Status__c = \'Waiting For Response\'';
	    system.debug('DASR Query : '+dasrquery);
		dasrlst = Database.query(dasrquery);
		
		for(dasr_summary__c dasrs : dasrslst){
			for(dasr_request__c dasr : dasrlst){
				if(dasr.ldc_account__r.LDC_Account_Number__c == dasrs.LDC_Account_Number__c){
					if(dasr.dasr_type__c == dasrs.Dasr_Type__c){
						ChangeReason__c chngRsn =  dasrs.Reject_Code__c != null ? ChangeReasonUtil.getChgRsnCodeForVal(dasrs.Reject_Code__c) : null;   
						
						dasr.Integration_status__c = dasrs.response__c;
						dasr.Sender_Transaction_Id__c = dasrs.request_id__c;
						dasr.Integration_Send_Date__c = dasrs.DASR_Submit_Date__c;
						dasr.Last_EDI_Update_Date__c = dasrs.Response_Date__c;
						dasr.Status_Reason__c = dasrs.Account_Status__c;
						if(dasrs.response__c == 'Accept')
							dasr.accepted__c = true;
						else
							dasr.rejected__c = true;
						dasr.Reason_Rejected__c= dasrs.Reject_Reason__c;
						dasr.Reason_Rejected_Desc__c =dasrs.Reject_Code__c;
						if(dasrs.Request_Type__c == 'Addition'){
							dasr.Change_Effective_Date__c = dasrs.Service_Start_Date__c;
						}
						else if(dasrs.Request_Type__c == 'Change'){
							dasr.Change_Effective_Date__c = dasrs.Change_Effective_Date__c;
						}
						else if(dasrs.Request_Type__c == 'Drop'){
							dasr.Change_Effective_Date__c = dasrs.Drop_Date__c;
						}
						else if(dasrs.Request_Type__c == 'Historical Usage'){
							
						}
						
						if(chngRsn != null)
							dasr.Reason_Rejected_Desc__c += ':'+chngRsn.Reason_Value__c;
						dasr.Integration_Message__c = dasrs.Notes__c;
						dasrlstupdate.add(dasr);
						
						dasrs.processed__c = true;
						dasrslstupdate.add(dasrs);
					}
				}
				if(ldcnumbertemp.contains(dasr.ldc_account__r.LDC_Account_Number__c)){
					system.debug('Before : '+ldcnumbertemp.size());
					ldcnumbertemp.remove(dasr.ldc_account__r.LDC_Account_Number__c);
					system.debug('After : '+ldcnumbertemp.size());
				}
			}
		}
		if(!dasrlstupdate.isempty()) update dasrlstupdate;
		
		for(dasr_summary__c dasrs : [select id,Error_Message__c,processed__c,error__c from dasr_summary__c where ldc_account_number__c IN : ldcnumbertemp]){
			dasrs.processed__c = true;
			dasrs.error__c = true;
			dasrs.Error_Message__c = 'No Matching LDC Account Found';
			dasrslstupdate.add(dasrs);
		}
		if(!dasrslstupdate.isempty()) update dasrslstupdate;
		
	}
	
	global void finish(Database.BatchableContext bc){
		
	}
    
}