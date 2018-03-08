/**
 * The purpose if this class is to Host an Invocable Method that can be called
 * from the Process Builder. Its purpose is to set the Term_Stop_Date__c on the
 * Contract_LDC__c records that are related to the DASR_Request__c records by
 * Contract__c and LDC_Account__c. It should also de-activate the Contract_LDC__c
 * Record.
 *
 * 
 * @author Chris Gary<cgary@cloudperformer.com>
 * @version 1.0
 * @ Chaitanya Kurra <Chaitanyasfdev@gmail.com>
 * Modified for the production issue SCR #1325
 **/
 public class Flow_EndContractLDC{
    @InvocableMethod(label='Terminate Active Contracts' description='Set a Term End Date and set Contract Active to False')
    public static void TerminateActiveContractsByDASR(List<Id> dasrID){
        //convert the list passed in into a set of Ids
        Set<Id> dasrIdSet = new Set<Id>();
        Map<id,date> ldcfinalset = new map<id,date>();
        dasrIdSet.addAll(dasrID);
        //get the DASR_Requests__c and find the related Contract_LDC__c records
        List<DASR_Request__c> dasrList = [SELECT 
                                            Id, Contract__c, LDC_Account__c,
                                            Change_Effective_Date__c
                                          FROM DASR_Request__c 
                                          WHERE id IN :dasrIdSet];
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> ldcAccountIdSet = new Set<Id>();
        Set<Id> ldcIdSet = new Set<Id>();
        List<LDC_Account__c> LDClisttoUpdate = new List<LDC_Account__c>();
        for(DASR_Request__c dasrRequest:dasrList){
            if(dasrRequest.Contract__c != null){
                contractIdSet.add(dasrRequest.Contract__c);
                if(dasrRequest.LDC_Account__c != null)
                    ldcAccountIdSet.add(dasrRequest.LDC_Account__c);
                    ldcfinalset.put(dasrRequest.LDC_Account__c,dasrRequest.Change_Effective_Date__c);
            }
            else{
                ldcIdSet.add(dasrRequest.LDC_Account__c);
                ldcfinalset.put(dasrRequest.LDC_Account__c,dasrRequest.Change_Effective_Date__c);
            }
        }
        List<Contract_LDC__c> contractLDCList = [SELECT 
                                                    Id, Term_Stop_Date__c, Active__c,
                                                    Contract__c, LDC_Account__c
                                                FROM Contract_LDC__c
                                                WHERE LDC_Account__c IN :ldcAccountIdSet
                                                AND Contract__c IN :contractIdSet];
                                                
        //sort this list into a Map of ContractId's and LDC_Account__c Id Records
        //Map<Id,Set<Id>> contractIdToLDCAccountIdSet = new Map<Id,Set<Id>>();
        Map<Id,Map<Id,Contract_LDC__c>> contractIdToLDCAccountIdSet = new Map<Id,Map<Id,Contract_LDC__c>>();
        for(Contract_LDC__c contractLDC:contractLDCList){
            Map<Id,Contract_LDC__c> tempContractMap;
            if(contractIdToLDCAccountIdSet.containsKey(contractLDC.Contract__c)){
                tempContractMap = contractIdToLDCAccountIdSet.get(contractLDC.Contract__c);
            } else {
                tempContractMap = new Map<Id,Contract_LDC__c>();
            }
            tempContractMap.put(contractLDC.LDC_Account__c,contractLDC);
            contractIdToLDCAccountIdSet.put(contractLDC.Contract__c,tempContractMap);
        }
        //now for each DASR Request, determine if there is a Contract_LDC__c record that matches
        //by Contract__c and LDC_Account__c record. If there is, then set the end date and mark as
        //inactive
        
        //Adding same logic as contract_ldc_c deactive on change effective date to billing group ldcs also
        list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
        Map<Id,Map<Id,Billing_Group_Ldc__c>> ldcbgset = new Map<Id,Map<Id,Billing_Group_Ldc__c>>();
        for(Billing_Group_Ldc__c bgldc : [select id,name,Billing_Start_Date__c,Billing_Stop_Date__c,Active__c,Synchronized__c,Billing_Group__c,Billing_Group__r.contract__c, 
                                            ldc_account__c from Billing_Group_Ldc__c where ldc_account__c IN : ldcAccountIdSet AND Billing_Group__r.contract__c IN : contractIdSet]){
            
            Map<Id,Billing_Group_Ldc__c> tempbgldcMap;
            if(ldcbgset.containsKey(bgldc.billing_group__r.Contract__c)){
                tempbgldcMap = ldcbgset.get(bgldc.billing_group__r.Contract__c);
            } else {
                tempbgldcMap = new Map<Id,Billing_Group_Ldc__c>();
            }
            tempbgldcMap.put(bgldc.LDC_Account__c,bgldc);
            ldcbgset.put(bgldc.billing_group__r.Contract__c,tempbgldcMap);
        }
        
        List<Contract_LDC__c> contractLDCListToUpdate = new List<Contract_LDC__c>();
        map<id,id> ldcbgmap = new map<id,id>();
        for(DASR_Request__c dasrRequest:dasrList){
            Map<Id,Contract_LDC__c> contractLDCMap = contractIdToLDCAccountIdSet.get(dasrRequest.Contract__c);
            if(contractLDCMap != null && contractLDCMap.containsKey(dasrRequest.LDC_Account__c)){
                Contract_LDC__c chosenContractLDC = contractLDCMap.get(dasrRequest.LDC_Account__c);
                chosenContractLDC.Active__c = false;
                chosenContractLDC.Term_Stop_Date__c = DateTime.newInstance(dasrRequest.Change_Effective_Date__c,Time.newInstance(0,0,0,0));
                system.debug(' Test Date : '+ chosenContractLDC.Term_Stop_Date__c);
                contractLDCListToUpdate.add(chosenContractLDC);
            }
            
            Map<Id,Billing_Group_Ldc__c> tempbgldcMap = ldcbgset.get(dasrRequest.Contract__c);
            if(tempbgldcMap != null && tempbgldcMap.containsKey(dasrRequest.LDC_Account__c)){
                Billing_Group_Ldc__c bgldc = tempbgldcMap.get(dasrRequest.LDC_Account__c);
                bgldc.Active__c = false;
                bgldc.synchronized__c = false;
                bgldc.Billing_Stop_Date__c = DateTime.newInstance(dasrRequest.Change_Effective_Date__c,Time.newInstance(0,0,0,0));
                bgldclst.add(bgldc);
                ldcbgmap.put(bgldc.ldc_account__c,bgldc.Billing_Group__c);
                system.debug(' Test Date : '+ bgldc.Billing_Stop_Date__c);
            }
        }
        
        contractLDCList = [select Id, Term_Stop_Date__c, Active__c,Contract__c, LDC_Account__c FROM Contract_LDC__c WHERE LDC_Account__c IN :ldcIdSet AND Active__c = TRUE];
        system.debug('Empty contract : '+contractLDCList);
        //contractLDCList.addAll(cldclst);
        Map<id,Map<Id,Contract_LDC__c>> EmptyLDCAccountIdSet = new Map<Id,Map<id,Contract_LDC__c>>();
        for(Contract_LDC__c contractLDC:contractLDCList){
            Map<Id,Contract_LDC__c> tempContractMap;
            if(EmptyLDCAccountIdSet.containsKey(contractLDC.ldc_account__c)){
                tempContractMap = EmptyLDCAccountIdSet.get(contractLDC.ldc_account__c);
            }
            else{
                tempContractMap = new Map<Id,Contract_LDC__c>();
            }
            tempContractMap.put(contractLDC.contract__c,contractLDC);
            EmptyLDCAccountIdSet.put(contractLDC.ldc_account__c,tempContractMap);
        }
        
        for(DASR_Request__c dasrRequest:dasrList){
            system.debug('Empty contract Map Active : '+EmptyLDCAccountIdSet.get(dasrRequest.ldc_account__c));
            Map<Id,Contract_LDC__c> contractLDCMap = EmptyLDCAccountIdSet.get(dasrRequest.ldc_account__c);
            system.debug('contractLDCMap : '+contractLDCMap);
            Integer counter = 0;
            string cntId='';
            if(contractLDCMap != null ){   // && contractLDCMap.containsKey(dasrRequest.contract__c)
                for(contract_ldc__c cldc : contractLDCList){
                    //system.debug('Test : '+cldc.ldc_account__c+' : '+contractLDCMap.get(dasrRequest.ldc_account__c).ldc_account__c+' : '+contractLDCMap.get(dasrRequest.ldc_account__c).active__c+' : '+contractLDCMap.get(dasrRequest.ldc_account__c).contract__c);
                    //if(cldc.ldc_account__c == contractLDCMap.get(dasrRequest.ldc_account__c).ldc_account__c && contractLDCMap.get(dasrRequest.ldc_account__c).active__c == true ){
                    if(cldc.ldc_account__c == dasrRequest.ldc_account__c){
                        counter++;  
                        cntId = cldc.contract__c;
                    }
                }
            }
            if(counter == 1 && contractLDCMap.containsKey(cntId)){
                Contract_LDC__c chosenContractLDC = contractLDCMap.get(cntId);
                chosenContractLDC.Active__c = false;
                chosenContractLDC.Term_Stop_Date__c = DateTime.newInstance(dasrRequest.Change_Effective_Date__c,Time.newInstance(0,0,0,0));
                system.debug(' Test Date : '+ chosenContractLDC.Term_Stop_Date__c);
                contractLDCListToUpdate.add(chosenContractLDC);
            }
        }
                
        system.debug('******' +ldcfinalset);
        // Modified for Deactivating all the LDC accounts on the change effective date SCR 1325.
        if(ldcfinalset.size()>0){
           for(id ldc1 : ldcfinalset.keyset()){
               system.debug('******' +ldc1);
               LDC_Account__c LDCNEW = new LDC_Account__c();
               LDCNEW.id = ldc1;
               LDCNEW.LDC_Account_Status__c ='FINAL';
               LDCNEW.LDC_End_Date__c  = ldcfinalset.get(ldc1);
               if(ldcbgmap.containskey(ldc1))
                    LDCNEW.billing_group__c = Null;
               LDClisttoUpdate.add(LDCNEW);
           }
        }
        /*if(!ldcbgset.isempty()){
            for(id ldcid : ldcbgset.keyset()){
                ldc_account__c ldc = new ldc_account__c();
                ldc.id = ldcid;
                ldc.billing_group__c = '';
                LDClisttoUpdate.add(ldc);
            }
        }*/
        system.debug('******' +LDClisttoUpdate);
        if(!LDClisttoUpdate.isempty()) update LDClisttoUpdate;
        
        if(!contractLDCListToUpdate.isEmpty()) update contractLDCListToUpdate;
        
        if(!bgldclst.isempty()) update bgldclst;
        
    }
 }