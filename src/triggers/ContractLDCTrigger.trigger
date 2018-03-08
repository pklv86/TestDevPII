/**
 * This class is designed to host an Invocable Action 
 * Its purpose is to set an Active Contract for a particular Account LDC and Contract that has been 
 * successfully processed.
 *
 *
 * @author 
 * @version 1.1
 **/

trigger ContractLDCTrigger on Contract_LDC__c(before insert, before update, after insert, after update) {

	Boolean hasAccess = true;
    String Usr = Label.Bypass_Users;
    list<string> UsrLst = Usr.split(';');
    for(string str : UsrLst){
    	if(UserInfo.getName() == str){
    		hasAccess = false;
    		system.debug('------------------------ Bypassed User ------------------------');
    	}
    }
    
    if(hasAccess && TriggerHandler.LSresponse){    
    	if(Trigger.isAfter && Trigger.isUpdate) {
        	//if(TriggerHandler.firstRun){
            	//List<Contract_LDC__c> lClc = new list<Contract_LDC__c> ();
                //List<LDC_Account__c> lLdc = new list<LDC_Account__c> ();
                map<id, Account> amap = new map<id, Account> ();
                List<Id> idList = new List<Id> ();
                //List<Id> idList2 = new List<Id> ();
                //List<Id> idListLDC = new List<Id> ();
                Set<Id> cntIdSet = new Set<Id>();
        		Set<Id> ldcIdSet = new Set<Id>();
                List<Account> accountsToUpdate = new List<Account> ();
                Account a = new Account();
                for(Contract_LDC__c clc : Trigger.new){
                	Contract_LDC__c oldClc = Trigger.oldMap.get(clc.ID);
                	
                    if(clc.IsSynchronized__c == false && (clc.IsSynchronized__c != oldClc.IsSynchronized__c)){
                        idList.add(clc.Id);
                        cntIdSet.add(clc.contract__c);
                        ldcIdSet.add(clc.ldc_account__c);
                    }
                    /*if (clc.Active__c && (clc.IsSynchronized__c == oldClc.IsSynchronized__c)) {
                        idList.add(clc.Id);
                        //idListLDC.add(clc.LDC_Account__c);
                        //clc.IsSynchronized__c = false;
                    }*/
                    else if (!clc.Active__c && (clc.IsSynchronized__c == oldClc.IsSynchronized__c)){
                        idList.add(clc.Id);
                        //clc.IsSynchronized__c = false;
                    }
                }
                /*if(idList.size()>0){
                        //Flow_SetAccountLDCAcctTypeCode.SetAccountLDCInfoFROMContractLDC(idList);
                        //Flow_DeactivateNonApplicableContracts.DeactivateNonActiveContractLDCRecs(idList);
                }
                /*if(idListLDC.size()>0){    
                    lLdc = [select id, LDC_Account_Number__c, LDC_Vendor__c, LDC_Vendor__r.DUNS__c, LDC_Vendor__r.Utility_Code__c from LDC_Account__c where id in :idListLDC];
                    for (LDC_Account__c ldc : lLdc){
                        ldc.LDC_Account_Status__c = 'ACTIVE';
                    }
                }
                if(!lLdc.isempty()) update lLdc;*/
                
                //if(idList.size()>0)   
                	//Flow_ReparentAccountfromContractLDC.ReparentAccount(idList);
                	
                //idList2.addall(idList);
                system.debug('>>>>>>>>>>>>>>>>>*******' + idList);
                if(idList.size()>0){
                	for (Contract_LDC__c contractLDC :[SELECT Id,IsSynchronized__c,Contract__c,Contract__r.Account.LodeStar_Integration_Status__c,
                                                         Contract__r.Account.Id,LDC_Account__r.Account__c,LDC_Account__r.Account__r.id,
                                                         LDC_Account__r.Account__r.LodeStar_Integration_Status__c		//,LDC_Account__r.Account__r.Validation__c
                                                          FROM Contract_LDC__c WHERE id in :idList]){
                    	if (contractLDC.LDC_Account__r.Account__r.LodeStar_Integration_Status__c != null && 
                    				contractLDC.LDC_Account__r.Account__r.LodeStar_Integration_Status__c.equalsIgnoreCase('Not Synchronized')){
                                continue;
                        }
                        a = new Account();
                        a.Id = contractLDC.LDC_Account__r.Account__r.Id;
                        a.LodeStar_Integration_Status__c = 'Not Synchronized';
                     // a.Validation__c = 'Modified';
                        amap.put(a.Id, a);
               		}
                }
                system.debug('>>>>>>>>>>>>>>>>>*******' + amap);
        
                accountsToUpdate = amap.values();
                if(!accountsToUpdate.isEmpty()) 
                	update accountsToUpdate;
                	
            	if(!ldcIdSet.isempty() && !cntIdSet.isempty()){
            		list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
			        for(Billing_Group_Ldc__c bgldc : [select id,name,Billing_Start_Date__c,Billing_Stop_Date__c,Active__c,Synchronized__c,Billing_Group__c,Billing_Group__r.contract__c, 
			        									ldc_account__r.billing_group__c from Billing_Group_Ldc__c where ldc_account__c IN : ldcIdSet AND Billing_Group__r.contract__c IN : cntIdSet 
			        									and ldc_account__r.billing_group__c != null]){
						if(cntIdSet.contains(bgldc.billing_group__r.contract__c)){
							bgldc.synchronized__c = false;
							bgldclst.add(bgldc);
						}	
					}
					if(!bgldclst.isempty()) update bgldclst;
            	}
                //TriggerHandler.firstRun = false;
            //}
        }
    }
}