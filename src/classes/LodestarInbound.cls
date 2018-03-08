/**********************************************************
Class :  LodestarInbound
Version	Date	Author
1.0	
***********************************************************/
global class LodestarInbound {
	
	global class LSInboundRequest{
        Webservice list<AccountInfo> Account_Info {get; set;}
    }
	
	global class AccountInfo{
		Webservice String CRMID;
		Webservice String AccountID;
		Webservice String Shortcode;
		Webservice String LstarIdentifier;
		Webservice String ContractID;
		Webservice String ErrorMessage;
	}
	
	global class response{
		webservice String Status;
        webservice string MessageDesc;
	}
	
	webservice static response processrequest(LSInboundRequest lsreq){
		response res = new response();
		if(lsreq == null){
            res.status=ConstantUtility.STATUS_SUCCESS;
            res.MessageDesc = 'No request Found'; 
           return res;  
        }
        
        set<string> ldcset = new set<string>();
        if(lsreq != null && lsreq.account_info != null){
        	for(AccountInfo acinfo : lsreq.account_info){
        		if(!ldcset.contains(acinfo.accountID)){
        			ldcset.add(acinfo.accountID);
        		}
        	}
        }
        
        list<ldc_account__c> ldclst = [select id,name,ldc_account_number__c,LodeStar_Response__c,Last_LS_Response__c from ldc_account__c where Ldc_account_number__c IN : ldcset];
        map<string,ldc_account__c> ldcmap = new map<string,ldc_account__c>();
        for(ldc_account__c ldc : Ldclst){
        	ldcmap.put(ldc.ldc_account_number__c,ldc);
        }
        
        if(lsreq != null && lsreq.account_info != null){
        	string msg = '';
        	for(AccountInfo acinfo : lsreq.account_info){
        		msg= 'Contract '+acinfo.contractID;
        		if(string.isBlank(acinfo.ErrorMessage) || acinfo.ErrorMessage == null)
        			msg+=' has been successfully processed';
    			else
    				msg+=' has an error --> '+acinfo.errormessage;
        		if(ldcmap.containskey(acinfo.accountID)){
        			ldc_account__c ldc = ldcmap.get(acinfo.accountID);
        			if(ldc.Last_LS_Response__c != null && ldc.Last_LS_Response__c <= system.now().adddays(-30)){
        				system.debug('Check last updated by LS : '+ldc.Last_LS_Response__c+' : '+system.now().adddays(-30));
        				ldc.LodeStar_Response__c = msg;
        				ldcmap.put(acinfo.accountID,ldc);
        			}
        			else{
        				ldc.LodeStar_Response__c = msg+ldc.LodeStar_Response__c;
        				ldcmap.put(acinfo.accountID,ldc);
        			}
        			ldc.Last_LS_Response__c=system.today();
        		}
    		}
    	}
    	
    	ldclst = new list<ldc_account__c>();
    	for(string str : ldcmap.keyset()){
    		ldclst.add(ldcmap.get(str));
    	}
    	try{
    		List<String> errList = new List<String>();
	    	if(!ldclst.isempty()){
	    		Database.SaveResult[] srLDCList = database.update(ldclst, false);
	            errList.addAll(IntegrationUtil.collectErrors(srLDCList));
	    	}
	    	
	    	res.status= errList != null && !errList.isEmpty() ? ConstantUtility.STATUS_Failure : ConstantUtility.STATUS_SUCCESS;
            res.MessageDesc = errList != null && !errList.isEmpty() ? 'Response Failed:' : 'Response Processed Successfully:'; 
            res.MessageDesc += errList;
    	}
    	catch(Exception e){
    		res.status=ConstantUtility.STATUS_Failure;
            res.MessageDesc = 'Exception'+e.getMessage();
    	}
		return res;
	}
    
}