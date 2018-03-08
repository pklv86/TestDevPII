/*****************************************Dynegy*************************************************************************************
 * Name: Contracttriggerhandler                                                                                                     *
 * Type: Apex Trigger                                                                                                                 *
 * Test Class:contracttrigger_test                                                                                                  *
 * Description:  This process is used for creating Contract Terms when the contract is Activated.                                   *                                            
 * Change History:                                                                                                                  *
 *==================================================================================================================================*
 * Version     Author                       Date             Description                                                            *
 * 1.0         Mounika Duggirala            02/26/2017      Initial Version created                                                 *                            
 ************************************************************************************************************************************/
trigger contracttrigger on Contract (before update) 
{
    Boolean hasAccess = true;
    String Usr = Label.Bypass_Users;
    list<string> UsrLst = Usr.split(';');
    for(string str : UsrLst){
    	if(UserInfo.getName() == str){
    		hasAccess = false;
    		system.debug('------------------------ Bypassed User ------------------------');
    	}
    }
    
    if(hasAccess){     
         Contracttriggerhandler  CTH=new Contracttriggerhandler();  
	    list<Contract> c = trigger.new;
	    string cId = c[0].id;
	    string query = ConstantUtility.getObjectFieldsQuery('Contract')+ ',Opportunity__r.Referral_Broker__r.description,Contract.Account.Industry, Retail_Quote__r.Contract_Energy_On_PK__c,Retail_Quote__r.Contract_Energy_Off_PK__c from contract where id = :cId';
	    list<contract> cnt = Database.query(query);
	    for (Contract cont: cnt){
	        if ((Trigger.newMap.get(cont.Id).status)=='Activated'&&Trigger.oldMap.get(cont.Id).status!= Trigger.newMap.get(cont.Id).status){
	            if(cont.product_name__c=='FP-ONE'){
	                CTH.createcontracttermsforFP_ONE(cont);
	            }
	            else if(cont.product_name__c=='FP-ONE-PT-C'){
	                CTH.createcontracttermsforFP_ONE_PT_C(cont);
	            }
	            else if(cont.product_name__c=='FP-MULT'){
	                CTH.createcontracttermsforFP_MULT(cont);
	            }
	            else if(cont.product_name__c=='FP-MULT-PT-C'){
	                CTH.createcontracttermsforFP_MULT_PT_C(cont);
	            } 
	            else if(cont.product_name__c=='FP-MULT-PT-L'){
	                CTH.createcontracttermsforFP_MULT_PT_L(cont);
	            }
	            else if(cont.product_name__c=='FP-MULT-PT-T'){
	                CTH.createcontracttermsforFP_MULT_PT_T(cont);
	            }
	            else if(cont.product_name__c=='FP-MULT-PT-CL'){
	                CTH.createcontracttermsforFP_MULT_PT_CL(cont);
	            }
	            else if(cont.product_name__c=='FP-MULT-PT-CLT'){
	                CTH.createcontracttermsforFP_MULT_PT_CLT(cont);
	            }
	            else if(cont.product_name__c=='FP-MULT-PT-LT'){
	                CTH.createcontracttermsforFP_MULT_PT_LT(cont);
	            }
	            else if(cont.product_name__c=='FP-MULT-PT-CT'){
	                CTH.createcontracttermsforFP_MULT_PT_CT(cont);
	            }
	            else if(cont.product_name__c=='FP-ONOFF'){
	                CTH.createcontracttermsforFP_ONOFF(cont);
	            }
	            else if(cont.product_name__c=='FP-ONOFF-PT-C'){
	                CTH.createcontracttermsforFP_ONOFF_PT_C(cont);
	            }
	            else if(cont.product_name__c=='FP-ONOFF-PT-L'){
	                CTH.createcontracttermsforFP_ONOFF_PT_L(cont);
	            }
	            else if(cont.product_name__c=='FP-ONOFF-PT-T'){
	                CTH.createcontracttermsforFP_ONOFF_PT_T(cont);
	            }
	            else if(cont.product_name__c=='FP-ONOFF-PT-CL'){
	                CTH.createcontracttermsforFP_ONOFF_PT_CL(cont);
	            }
	            else if(cont.product_name__c=='FP-ONOFF-PT-CLT'){
	                CTH.createcontracttermsforFP_ONOFF_PT_CLT(cont);
	            }
	            else if(cont.product_name__c=='FP-ONOFF-PT-LT'){
	                CTH.createcontracttermsforFP_ONOFF_PT_LT(cont);
	            }
	            else if(cont.product_name__c=='FP-ONOFF-PT-CT'){
	                CTH.createcontracttermsforFP_ONOFF_PT_CT(cont);
	            }
	        }
	    }
	}
}