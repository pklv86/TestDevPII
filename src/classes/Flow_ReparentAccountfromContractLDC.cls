/**
 * This class is designed to host an Invocable Method that can be called 
 * from the Process Builder. Its purpose is to reparent the LDC_Account__r.Account__c
 * from the Contract_LDC__c record based on the Contract__r.Account that it is connected to.
 * 
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 **/
public class Flow_ReparentAccountfromContractLDC {
    @InvocableMethod(label='Reparent Individual Accounts' description='Reparent Person Accounts to the correct offer or MuniAgg Account')
    public static void ReparentAccount(List<Id> contractLDCId){
        //put the List into a Set
        Set<Id> contractLDCIdSet = new Set<Id>();
        contractLDCIdSet.addAll(contractLDCId);
        //get the data needed as well as the Accounts to update
        List<Contract_LDC__c> contractLDCList = [SELECT 
                                                    Id, Contract__c, Contract__r.AccountId,
                                                    LDC_Account__c, LDC_Account__r.Account__c,
                                                    LDC_Account__r.Account__r.Business_Account__c
                                                FROM Contract_LDC__c 
                                                WHERE Id IN :contractLDCIdSet];
        Set<Id> accountIdSet = new Set<Id>();
        for(Contract_LDC__c contractLDC:contractLDCList){
            //get the AccountIds in a Map to possibly update
            if(contractLDC.LDC_Account__r.Account__c != null) accountIdSet.add(contractLDC.LDC_Account__r.Account__c);
        }
        //now get the possible accounts for Update
        Map<Id,Account> accountList = new Map<Id,Account>([SELECT
                                                            Id, Business_Account__c
                                                          FROM Account
                                                          WHERE Id IN :accountIdSet]);
        //go through each of the Contract_LDC__c records, and if the 
        //LDC_Account__r.Account__r.Business_Account__c is not empty and 
        //does not match the Contract__r.AccountId - update accordingly.
        List<Account> accountListToUpdate = new List<Account>();
        for(Contract_LDC__c contractLDC:contractLDCList){ 
            if(contractLDC.LDC_Account__r.Account__r.Business_Account__c != null &&
               contractLDC.LDC_Account__r.Account__r.Business_Account__c != contractLDC.Contract__r.AccountId){
               Account acct = accountList.get(contractLDC.LDC_Account__r.Account__c);
               system.debug('Account : '+acct);
               if(acct != null){ 
                    acct.Business_Account__c = contractLDC.Contract__r.AccountId;
                    Integer count= 0;
                    Integer accountlistsize=accountListToUpdate.size();
                    
                        if(accountListToUpdate.size()==0){
                            count=0;
                        }
                        else{
                            for(Integer i=0; i<accountlistsize ;i++){
                                if(accountListToUpdate[i].id != acct.id) {
                                    count++;
                                }
                            }
                        }
                        system.debug('Count : '+count);
                        if(accountListToUpdate.size() == count){
                            accountListToUpdate.add(acct);
                            system.debug('Adding account');
                        }
               }
            }
        }
        if(!accountListToUpdate.isEmpty()) update accountListToUpdate;
    }
}