/****
 * This batch will set the CustomerPLC__c value on business customer to '0' for re-calulation
 */
global class SetAccountPLCValueBatch implements Database.Batchable<sObject>{

   String query;
   global SetAccountPLCValueBatch(){}
   global SetAccountPLCValueBatch(String q){
        query = q;
   }
   global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,CustomerPLC__c from account where PLC_Change__c = true');
   }
      
   global void execute(Database.BatchableContext BC, List<sObject> scope){        
        List<Account> lstAcc = new List<Account>();        
        for(Account rec : (List<Account>) scope){           
            lstAcc.add(new Account(Id = rec.Id,CustomerPLC__c = 0));
        }
        update lstAcc;
   }
   
   global void finish(Database.BatchableContext BC){
       Database.executeBatch(new CalcluatePLCBatch(),2000);
   }    
}