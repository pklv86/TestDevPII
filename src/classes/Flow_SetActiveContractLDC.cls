/**
 * This class is designed to host an Invocable Action and be called from the Process Builder
 * Its purpose is to set an Active Contract for a particular Account LDC and Contract.  THis 
 * information can be obtained from the DASR_Request__c of DASR_Type__c = 'GAAE' that has been 
 * successfully processed.
 *
 * @revision 1.1 - CJG - 03-17-2016 : Set the Contract_LDC__c.Term_Start_Date__c
 * @revision 1.2 - CJG - 03-21-2016 : Set the Contract_LDC__c.Term_Stop_Date__c
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.2
 * @Chaitanya Kurra<chaitanyasfdev@gmail.com>
 * Modified for production issue SCR #1325
 **/
public class Flow_SetActiveContractLDC {
    @InvocableMethod(label='Set Active Contract By DASR' description='Will take the Id of a successful DASR Record and set the associated Contract LDC to Active.')
    public static void setActiveContractFromDASR(List<Id> dasrIdList){
        //deduplicate the List into a set
        Set<Id> dasrIdSet = new Set<Id>();
        list<LDC_Account__c> LDClisttoUpdate = new list<LDC_Account__c>();
        list<Contract_LDC__c> contractLDCListToUpdate = new list<Contract_LDC__c>();
        map<id, date> ldcaccountidwithdate = new map<id,date>();
        dasrIdSet.addAll(dasrIdList);
        //now lets get the List of DASR_Request__c records
        List<DASR_Request__c> resultList = [SELECT 
                                                Id, Name, Contract__c, LDC_Account__c, Change_Effective_Date__c,
                                                Contract__r.EndDate, Contract__r.End_Date__c
                                            FROM DASR_Request__c 
                                            WHERE Id IN :dasrIdSet];
        //now lets put the Contract Id's and LDC Account Id's in a set and get the related Contract_LDC__c's.
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> ldcAccountIdSet = new Set<Id>();
        Set<Id> ldcAccountIdSet1 = new Set<Id>();
        //loop through the DASR Request List and Populate the Set
        for(DASR_Request__c dasr:resultList){
            if(dasr.Contract__c != null)
                contractIdSet.add(dasr.Contract__c);
                
            if(dasr.LDC_Account__c != null && dasr.contract__c != null){
                ldcAccountIdSet.add(dasr.LDC_Account__c);
                ldcaccountidwithdate.put(dasr.LDC_Account__c,dasr.change_effective_date__c);
            }
            else if(dasr.LDC_Account__c != null && dasr.contract__c == null){
                ldcAccountIdSet1.add(dasr.LDC_Account__c);
                ldcaccountidwithdate.put(dasr.LDC_Account__c,dasr.change_effective_date__c);
            }
            
        }
        //now lets get the Contract LDCS Associated
        List<Contract_LDC__c> contractLDCList = [SELECT 
                                                    Id, Active__c, Term_Start_Date__c, Contract__c,
                                                    Contract__r.EndDate, Contract__r.End_Date__c,
                                                    Term_Stop_Date__c,
                                                    LDC_Account__c
                                                FROM Contract_LDC__c
                                                WHERE Contract__c IN :contractIdSet
                                                AND LDC_Account__c IN :ldcAccountIdSet];
        System.debug(LoggingLevel.INFO,'\n\n*****\nContract LDC List Obtained: ' + contractLDCList + '\n*****\n\n');                                        
        
        map<id,Contract_LDC__c> cldcmap = new map<id,Contract_LDC__c>();
        list<Contract_LDC__c> ContractLDClist1 = new list<Contract_LDC__c>();
        for(Contract_LDC__c cldc : [SELECT Id, Active__c, Term_Start_Date__c, Contract__c,Contract__r.EndDate, Contract__r.End_Date__c,Term_Stop_Date__c,
                                        LDC_Account__c FROM Contract_LDC__c WHERE LDC_Account__c IN :ldcAccountIdSet1 AND TERM_Start_Date__c != null and 
                                        contract__c != null and id not in :contractLDCList order by TERM_Start_Date__c ]){
        	cldcmap.put(cldc.LDC_Account__c,cldc);
        }
        
        for(ID cldc : cldcmap.keyset()){
        	ContractLDClist1.add(cldcmap.get(cldc));
        }
        
        /*List<Contract_LDC__c> ContractLDClist1 = [SELECT 
                                                    Id, Active__c, Term_Start_Date__c, Contract__c,
                                                    Contract__r.EndDate, Contract__r.End_Date__c,
                                                    Term_Stop_Date__c,
                                                    LDC_Account__c
                                                FROM Contract_LDC__c
                                                WHERE LDC_Account__c IN :ldcAccountIdSet1 AND Active__c = false and TERM_Start_Date__c != null 
                                                and contract__c != null and id not in :contractLDCList order by TERM_Start_Date__c ]; */      
        
        System.debug(LoggingLevel.INFO,'\n\n*****\nContract LDC1 List Obtained: ' + contractLDCList1 + '\n*****\n\n');
        
        //now lets loop through these, and set them to active
        //create a searchable structure to store Change Effective Dates in
        Map<Id,Map<Id,Date>> contractIdToLDCIdToDateMap = new Map<Id,Map<Id,Date>>();
        for(DASR_Request__c dasr:resultList){
            Map<Id,Date> tempHolder;
            if(contractIdToLDCIdToDateMap.containsKey(dasr.Contract__c)){
                tempHolder = contractIdToLDCIdToDateMap.get(dasr.Contract__c);
            } else {
                tempHolder = new Map<Id,Date>();
            }
            tempHolder.put(dasr.LDC_Account__c,dasr.Change_Effective_Date__c);
            contractIdToLDCIdToDateMap.put(dasr.Contract__c,tempHolder);
        }
        System.debug(LoggingLevel.INFO,'\n\n*****\nContractIdToLDCIdDateMap: ' + contractIdToLDCIdToDateMap + '\n*****\n\n' );
        //loop through the Contract_LDC__c's and update applicable data.
        for(Contract_LDC__c contractLDC:contractLDCList){
            system.debug('LdcId : '+contractLDC.LDC_Account__c+' :Contract Id : '+contractLDC.Contract__c);
            Map<Id,Date> chosenContractMapData = contractIdToLDCIdToDateMap.get(contractLDC.Contract__c);
            if(chosenContractMapData != null){
                //need to do conversion from Date to Datetime
                Date originalValue = chosenContractMapData.get(contractLDC.LDC_Account__c);
                system.debug('originalValue : '+originalValue+' chosenContractMapData : '+chosenContractMapData+' : '+chosenContractMapData.get(contractLDC.LDC_Account__c));
                Datetime conversionValue;
                //Bindu: commented out this code as it's updating wrong contractLDC combination w.r.t DASR
                /*if(originalValue == null){
                    for(dasr_request__c dasr : resultlist){
                        system.debug(' current : '+dasr.name+' : '+contractldc.contract__c+' : '+contractldc.id);
                        if(dasr.contract__c == contractldc.contract__c){
                            originalvalue = dasr.Change_Effective_Date__c;
                            system.debug('Original value : '+originalvalue);
                        }
                    }
                    conversionValue = DateTime.newInstance(originalValue.year(), originalValue.month(), originalValue.day());
                    contractLDC.Term_Start_Date__c = conversionValue;
                }
                else*/
                if(originalValue != null)
                {
                    //contractLDC.Active__c = true;
                    contractLDC.Term_Stop_Date__c = Datetime.newInstance(contractLDC.Contract__r.End_Date__c,Time.newInstance(0,0,0,0));
                    contractLDC.Term_Start_Date__c = DateTime.newInstance(chosenContractMapData.get(contractLDC.LDC_Account__c),Time.newInstance(0,0,0,0));
                }
            }
        }
        
        contractLDCListToUpdate.addall(contractLDCList);
        if(contractLDCList1.size()>0){
            for(Contract_LDC__c conLDC:contractLDCList1)
                {
                    system.debug('*******Contractldc*****'+conLDC);
                    Contract_LDC__c cldc = new Contract_LDC__c();
                    cldc.id = conLDC.id;
                    cldc.Term_Stop_Date__c = Datetime.newInstance(ConLDC.Contract__r.End_Date__c,Time.newInstance(0,0,0,0));
                    cldc.Term_Start_Date__c = Datetime.newInstance(ldcaccountidwithdate.get(conLDC.LDC_Account__c),Time.newInstance(0,0,0,0));
                    //cldc.Active__c = true;
                    contractLDCListToUpdate.add(cldc);
                }
        }
        
        //Adding same logic as contract_ldc_c active on change effective date to billing group ldcs also
        list<Billing_Group_Ldc__c> bgldclst = new list<Billing_Group_Ldc__c>();
        map<id,id> ldcbgset = new map<id,id>();
        for(Billing_Group_Ldc__c bgldc : [select id,name,Billing_Start_Date__c,Billing_Stop_Date__c,Active__c,Synchronized__c,Billing_Group__c,Billing_Group__r.contract__c, 
                                            ldc_account__c from Billing_Group_Ldc__c where ldc_account__c IN : ldcAccountIdSet AND Billing_Group__r.contract__c IN : contractIdSet]){
            
            system.debug('LdcId : '+bgldc.LDC_Account__c+' :Contract Id : '+bgldc.Billing_Group__r.Contract__c);
            Map<Id,Date> chosenContractMapData = contractIdToLDCIdToDateMap.get(bgldc.Billing_Group__r.Contract__c);
            if(chosenContractMapData != null){
                //bgldc.active__c = true;
                bgldc.synchronized__c = false;
                bgldc.Billing_Start_Date__c = DateTime.newInstance(chosenContractMapData.get(bgldc.LDC_Account__c),Time.newInstance(0,0,0,0));
                bgldclst.add(bgldc);
                ldcbgset.put(bgldc.ldc_account__c,bgldc.Billing_Group__c);
            }
        }
        system.debug('ldcbgset map : '+ldcbgset);
        system.debug('****LDC account with start date**' +ldcaccountidwithdate);
        
        // Modified for Activating all the LDC accounts on the change effective date.
        if(ldcaccountidwithdate.size()>0){
            for(id ldc1 : ldcaccountidwithdate.keyset()){
                system.debug('***LDC account enter***' +ldc1);
                LDC_Account__c LDCNEW = new LDC_Account__c();
                LDCNEW.id = ldc1;
                LDCNEW.LDC_Account_Status__c ='Active';
                //LDCNEW.LDC_Start_Date__c  = ldcaccountidwithdate.get(ldc1);
                if(ldcbgset.containskey(ldc1))
                    LDCNEW.billing_group__c = ldcbgset.get(ldc1);   
                LDClisttoUpdate.add(LDCNEW);
                   
            }
        }
        /*if(!ldcbgset.isempty()){
            for(id ldcid : ldcbgset.keyset()){
                ldc_account__c ldc = new ldc_account__c();
                ldc.id = ldcid;
                ldc.billing_group__c = ldcbgset.get(ldcid);
                LDClisttoUpdate.add(ldc);
            }
        }*/
        system.debug('******' +LDClisttoUpdate);
                
         //finally update all of the Contract LDCs.
        if(!contractLDCListToUpdate.isEmpty()) update contractLDCListToUpdate;
        
                //Update the LDC accounts to Active
        if(!LDClisttoUpdate.isempty()) update LDClisttoUpdate;
        
        if(!bgldclst.isempty()) update bgldclst;
    }
}