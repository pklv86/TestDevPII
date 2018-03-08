/****
 * This batch will set the PLC_Change__c on business customer to false after PLC calulation
 */
global class SetAccountPLCChangeBatch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,PLC_Change__c from account where PLC_Change__c = true');
    }
     
    global void execute(Database.BatchableContext BC, List<sObject> scope){        
        List<Account> lstAcc = new List<Account>();        
        for(Account rec : (List<Account>) scope){
            lstAcc.add(new Account(Id = rec.Id, PLC_Change__c = false));
        }
        update lstAcc;
    }
   
    global void finish(Database.BatchableContext BC){
    }
    
}