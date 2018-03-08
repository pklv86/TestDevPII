global class DASRBatchJobAuto implements System.Queueable{
    
   /* global void execute (SchedulableContext sc){
      system.debug('Starting auto.......');
        list<aggregateresult> result = [select count(id),Change_Effective_Date__c from dasr_request__c where Accepted__c = true and Dynegy_Initiated__c = true and Integration_Status__c = 'Complete'
                                            and createdby.name != 'Integration User' and DASR_Type__c = 'GAAC' and DASR_Activated__c = false 
                                            and Change_Effective_Date__c <= today 
                                            group by Change_Effective_Date__c
                                            order by Change_Effective_Date__c ];
        system.debug('Result : '+result.size()+' : '+result);
        string dateres ='';
        for(AggregateResult arr : result){
            system.debug('AggregateResult : '+arr); 
            dateres=string.valueof(arr.get('Change_Effective_Date__c'));
            
        }
        system.debug('dateres : '+dateres);
        dateres=string.valueof(result[0].get('Change_Effective_Date__c')); 
        DASRBatchJob Dasr = new DASRBatchJob(Date.valueof(result[0].get('Change_Effective_Date__c')),Integer.valueof(result[0].get('expr0')));
        Database.executeBatch(Dasr,20);
        system.debug('dateres : '+dateres);
    }*/
    global final Integer recordstotal;
    global final Date DatetoProcess;
    global set<id> errset;
    
    public DASRBatchJobAuto(){
       
    }
    
    public DASRBatchJobAuto(Date dt,Integer co,set<id> idset){
      DatetoProcess = dt;
      recordstotal = co;
      errset = idset;
    }
    
    global void execute (QueueableContext qc){
      system.debug('Starting Queueable auto.......');
        list<aggregateresult> result = [select count(id),Change_Effective_Date__c from dasr_request__c where Accepted__c = true and Dynegy_Initiated__c = true and ((Integration_Status__c = 'Complete'
                                            and Most_recent_gaad__c = true) or (Integration_Status__c = 'Manually Fulfilled'  and ldc_account__r.service_territory__c = 'ComEd-IL')) 
                                            and createdby.name != 'Integration User' and DASR_Type__c = 'GAAC' and DASR_Activated__c = false and Change_Effective_Date__c <= today 
                                            group by Change_Effective_Date__c
                                            order by Change_Effective_Date__c limit 20];
        system.debug('Result : '+result.size()+' : '+result);
        if(!result.isempty()){
          if(errset == null)
              errset = new set<id>();
              
          string dateres = string.valueof(result[0].get('Change_Effective_Date__c')); 
          Date dasrdt = Date.valueof(result[0].get('Change_Effective_Date__c'));
          system.debug('dateres : '+dateres);
          DASRBatchJob Dasr;
          if(DatetoProcess == dasrdt){        //If looping over same date reduce batch size in order to filter out the erroring one.
            if(recordstotal < 5){
              Dasr = new DASRBatchJob(Date.valueof(result[0].get('Change_Effective_Date__c')),recordstotal+1,errset);
              Database.executeBatch(Dasr,10);
            }
            else if(recordstotal == 5){
              Dasr = new DASRBatchJob(Date.valueof(result[0].get('Change_Effective_Date__c')),recordstotal+1,errset);
              Database.executeBatch(Dasr,1);
            }
          else{                //If error is not resolved skip that dasr by updating                
              list<Dasr_request__c> dasruplst = new list<Dasr_request__c>();
              for(Dasr_request__c dlist : [select id,dasr_activated__c from dasr_request__c where Accepted__c = true and Dynegy_Initiated__c = true and (Integration_Status__c = 'Complete'
                                            or (Integration_Status__c = 'Manually Fulfilled'  and ldc_account__r.service_territory__c = 'ComEd-IL')) and createdby.name != 'Integration User' 
                                            and DASR_Type__c = 'GAAC' and DASR_Activated__c = false and Change_Effective_Date__c =: dasrdt ]){
                      errset.add(dlist.id);
                      dlist.dasr_activated__c = true;
                      dasruplst.add(dlist);                                                
                    }
                    if(!dasruplst.isempty()) update dasruplst;
                    if(result.size() > 1){
                      Dasr = new DASRBatchJob(Date.valueof(result[1].get('Change_Effective_Date__c')),1,errset);
                Database.executeBatch(Dasr,100);
                    }
                    else{
                      Dasr = new DASRBatchJob(Date.valueof(result[0].get('Change_Effective_Date__c')),1,errset);
                Database.executeBatch(Dasr,100);
                    }
            }
          }
          else{
            Dasr = new DASRBatchJob(Date.valueof(result[0].get('Change_Effective_Date__c')),1,errset);
            Database.executeBatch(Dasr,100);
          }
          system.debug('dateres : '+dateres);
        }
    }
}