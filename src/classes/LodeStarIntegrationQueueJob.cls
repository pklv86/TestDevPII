global class LodeStarIntegrationQueueJob implements System.Queueable{
    /**
     * Properties
     **/
    global final Set<Id> processingSet;
    global final Set<Id> pickedSet;
    global final set<id> accountstoNotsync;
    global final string acctype;
    global final boolean singleacc;
    global final boolean syncflag;
    global final ID CntID;
    
    /**
     * Constuctor of Queueable Process
     **/
    global LodeStarIntegrationQueueJob(Set<Id> accountIdSetProcessing,Set<Id> processedAccounts, set<id> accountsNotsync){
        processingSet = accountIdSetProcessing;
        accountstoNotsync = accountsNotsync;
        pickedSet = processedAccounts;
        singleacc = false;
    }
    
    global LodeStarIntegrationQueueJob(Set<Id> accountIdSetProcessing,string typecode,ID cid,boolean sflag,boolean sacc){//
        processingSet = accountIdSetProcessing;
        acctype = typecode;
        singleacc = sacc;
        syncflag = sflag;
        CntID = cid;        
    }
    /**
     * inherited from System.Queueable
     **/
    public void execute(QueueableContext qc){
        system.debug('processingSet of IDs : '+processingSet);
        Set<Id> accountIdSetToProcess = new Set<Id>();
        List<Account> acctList = [SELECT 
                                    Id, LodeStar_Integration_Status__c 
                                  FROM Account 
                                  WHERE Id IN :processingSet];
        for(Account a:acctList){
            a.LodeStar_Integration_Status__c = 'Processing';
            accountIdSetToProcess.add(a.Id);
        }
        update acctList;
        //now we kick off a job to process.
        if(!singleacc)
            Database.executeBatch(new LodeStarIntegrationProcessor(processingSet,pickedset,accountstoNotsync));
        else
            Database.executeBatch(new LodeStarIntegrationProcessor(processingSet,acctype,Cntid,syncflag,singleacc));
    }
}