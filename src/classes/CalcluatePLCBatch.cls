/****
 * This batch will query all the accounts whose business records has to be re-calulated
 * and update the business customer with the sum
 */
global class CalcluatePLCBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id'
                                        +' ,Capacity_PLC1__c'
                                        +' ,account__c'
                                        +' ,account__r.Business_Account__c'
                                        +' ,account__r.CustomerPLC__c'
                                        +' ,account__r.Business_Account__r.CustomerPLC__c'
                                        +' FROM ldc_account__c'
                                        +' WHERE capacity_plc1__c != null and (account__r.PLC_Change__c = true'
                                            +' OR account__r.business_account__r.PLC_Change__c = true)');
   }   
   
   global void execute(Database.BatchableContext BC, List<sObject> scope){
       map<string,decimal> mapBusinessPLC = new map<string,decimal>();         
       List<Account> lstAccUpdate = new List<Account>();
       for(ldc_account__c ldc : (List<ldc_account__c>) scope){
           if(ldc.account__c != null){
               //For Muni-agg and Mass-Market
               if(ldc.account__r.Business_Account__c != null){                    
                   if(mapBusinessPLC.containsKey(ldc.account__r.Business_Account__c)){
                       decimal totalTemp = mapBusinessPLC.get(ldc.account__r.Business_Account__c);
                       totalTemp += ldc.Capacity_PLC1__c;                      
                       mapBusinessPLC.put(ldc.account__r.Business_Account__c,totalTemp);
                   }                    
                   else{
                       mapBusinessPLC.put(ldc.account__r.Business_Account__c,ldc.Capacity_PLC1__c);
                   }
               }
               //For C&I Customers
               else{                   
                   if(mapBusinessPLC.containsKey(ldc.account__c)){
                       decimal totalTemp = mapBusinessPLC.get(ldc.account__c);                       
                       totalTemp += ldc.Capacity_PLC1__c;
                       mapBusinessPLC.put(ldc.account__c,totalTemp);
                   }                    
                   else{
                       mapBusinessPLC.put(ldc.account__c,ldc.Capacity_PLC1__c);
                   }                    
               }                
           }                       
       }
       system.debug('\n====mapBusinessPLC===='+mapBusinessPLC);
       List<Account> lstAccount = [SELECT Id, CustomerPLC__c FROM Account WHERE ID IN :mapBusinessPLC.keyset() FOR UPDATE];        
       for(Account accRec : lstAccount){            
           if(mapBusinessPLC.containsKey(accRec.Id)){                
           //  system.debug('\n====accRec.CustomerPLC__c===='+accRec.CustomerPLC__c+'\n====Id===='+mapBusinessPLC.get(accRec.Id));                
               if(accRec.CustomerPLC__c == null){
                   accRec.CustomerPLC__c = mapBusinessPLC.get(accRec.Id);
               }
               else{
                   accRec.CustomerPLC__c += mapBusinessPLC.get(accRec.Id);
               }
           }
       }  
       system.debug('\n====lstAccount===='+lstAccount);
       if(!lstAccount.isEmpty()){
           update lstAccount;
       }
   }
   
   global void finish(Database.BatchableContext BC){
       Database.executeBatch(new SetAccountPLCChangeBatch(),2000);
   }
    
}