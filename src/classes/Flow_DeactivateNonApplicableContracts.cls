/**
 * The purpose of this class is to Deactivate the Contract_LDC__c records that are not
 * supposed to be active based on the List of Active Contract_LDC__c records passed in.
 * For each of the Active Contract_LDC__c records passed in look at the other Contract_LDC__c
 * Records passed in related to the LDC_Account__c and deaactivate them.  Also set the Contract End
 * Date.
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 * @Version 1.1 Restricting the contract ldc's of ldc account to set issynchronization & active false for only previously active contract ldc if it has any -prasad
 **/
public class Flow_DeactivateNonApplicableContracts {
    @InvocableMethod(label='Deactivate Non Active Contracts' description='Will take a list of acitve Contracts, and deactivate the other contracts associated to the same LDC_Account__c records')
    public static void DeactivateNonActiveContractLDCRecs(List<Id> activeContractLDCId){
        //convert the list into a set
        Set<Id> contractLDCSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> ldcAccountIdSet = new Set<Id>();
        //gather all of the Active Contract LDC Records into a Map by LDC_Account__c Id.
        Map<Id,Contract_LDC__c> contractLDCByLDCAccountMap = new Map<Id,Contract_LDC__c>();
        contractLDCSet.addAll(activeContractLDCId);
        system.debug('contractLDCSet : '+contractLDCSet);
        for(Contract_LDC__c contractLDC:[SELECT 
                                            Id, LDC_Account__c, Term_Start_Date__c, Term_Stop_Date__c,
                                            Contract__c, Contract__r.End_Date__c
                                        FROM Contract_LDC__c WHERE Id IN :contractLDCSet]){
            contractLDCByLDCAccountMap.put(contractLDC.LDC_Account__c,contractLDC);
        }
        List<Contract_LDC__c> contractLDCsToUpdate = new List<Contract_LDC__c>();
        list<contract_ldc__c> cldclst = [SELECT Id, LDC_Account__c, Active__c, Term_Start_Date__c, Term_Stop_Date__c,Contract__c FROM Contract_LDC__c 
                                            WHERE LDC_Account__c IN :contractLDCByLDCAccountMap.keySet()];
        
                                
        for(Contract_LDC__c contractLDC:cldclst){
            system.debug('Instance Date : '+contractLDC.Active__c+' : '+contractLDC.Term_Start_Date__c);
            if(!contractLDCSet.contains(contractLDC.Id) && contractLDC.Active__c == true){ //&& contractLDC.Term_Stop_Date__c == startinstance
                contractIdSet.add(contractLDC.Contract__c);
                ldcAccountIdSet.add(contractLDC.LDC_Account__c);
                Contract_LDC__c activeContractLDC = contractLDCByLDCAccountMap.get(contractLDC.LDC_Account__c);
                if(activeContractLDC != null ){ //&& activeContractLDC.Term_Start_Date__c < contractLDC.Term_Stop_Date__c
                    contractLDC.Term_Stop_Date__c = activeContractLDC.Term_Start_Date__c.addMinutes(-1); 
                    contractLDC.Active__c = false;  
                    contractLDCsToUpdate.add(contractLDC);
                }
            }
        }
        if(!contractLDCsToUpdate.isEmpty()) update contractLDCsToUpdate;
        
        //Adding same logic as contract_ldc_c deactive on change effective date to billing group ldcs also
        list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
        //map<id,id> ldcbgset = new map<id,id>();
        for(Billing_Group_Ldc__c bgldc : [select id,name,Billing_Start_Date__c,Billing_Stop_Date__c,Active__c,Synchronized__c,Billing_Group__c,Billing_Group__r.contract__c, 
                                            ldc_account__c from Billing_Group_Ldc__c where ldc_account__c IN : ldcAccountIdSet AND Billing_Group__r.contract__c IN : contractIdSet]){
            if(bgldc.active__c){
                bgldc.active__c = false;
                bgldc.synchronized__c = false;
                Contract_LDC__c activeContractLDC = contractLDCByLDCAccountMap.get(bgldc.LDC_Account__c);
                if(activeContractLDC != null ){ //&& activeContractLDC.Term_Start_Date__c < contractLDC.Term_Stop_Date__c
                    bgldc.Billing_Stop_Date__c = activeContractLDC.Term_Start_Date__c.addMinutes(-1); 
                }
                bgldclst.add(bgldc);
                //ldcbgset.put(bgldc.ldc_account__c,bgldc.Billing_Group__c);
            }
        }
       /* List<LDC_Account__c> LDClisttoUpdate = new List<LDC_Account__c>();
        if(!ldcbgset.isempty()){
            for(id ldcid : ldcbgset.keyset()){
                ldc_account__c ldc = new ldc_account__c();
                ldc.id = ldcid;
                //ldc.billing_group__c = '';
                LDClisttoUpdate.add(ldc);
            }
        }
        system.debug('******' +LDClisttoUpdate);
        if(!LDClisttoUpdate.isempty()) update LDClisttoUpdate;*/
        if(!bgldclst.isempty()) update bgldclst;
    }
}