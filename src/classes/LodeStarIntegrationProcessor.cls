/**
 * This class is designed to be a Scheduled Job that will look for all 
 * Accounts that have not been sent to LodeStar (marked as 'Not Synchronized'),
 * and send them.  It will continue to run until all Account have either been 
 * Synchronized or an error has been found.


 *


 * @author Chris Gary <cgary@cloudperformer.com> 
 * @version 1.0
 * @version 1.1 Modification for not running ObtainNonSynchronizedAccount too many times in a single context -Prasad
 **/
global class LodeStarIntegrationProcessor implements Database.Batchable<SObject>,
                                                     Database.AllowsCallouts,
                                                     System.Schedulable,Database.Stateful{
    //global variable that will hold the Set if Account Id's to process.
    global final Set<Id> IdProcessingSet;
    global set<id> processedAccounts;
    global set<id> accountsNotsync;
    global ID bID;   
    global final string acctype;
    global final boolean singleacc;
    global final boolean syncflag;
    global final ID CntId;
    public LodeStarIntegrationProcessor(){
        singleacc  = false;
    }
    /**
     * Constructor
     **/    
    public LodeStarIntegrationProcessor(Set<Id> accountIdSetIn, set<id> pickedset,set<id> accountstoNotsync){
        IdProcessingSet = accountIdSetIn;
        processedAccounts = pickedset;
        accountsNotsync = accountstoNotsync;
        singleacc  = false;
    }
    
    /* For Single Account Processing */
    public LodeStarIntegrationProcessor(Set<Id> accountIdSetIn, String typecode, Id cid, boolean sflag, boolean sacc){
        IdProcessingSet = accountIdSetIn;
        acctype = typecode;
        singleacc = sacc;
        CntId = cid;
        syncflag = sflag;
        processedAccounts = new set<id>();
        processedAccounts.addAll(LodeStarActions.ObtainAccountsSet(IdProcessingSet));
    }

    /**
     * inherited from Database.Batchable
     **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        if (IdProcessingSet==null || IdProcessingSet.isEmpty()) {
            // Pull a blank query locator since there is nothing to process
            system.debug('*** Nothing to process');
            return Database.getQueryLocator([Select Id from Account where Id='001000000000000']);
        }
        String inStatement = '';
        for(Id accountId:IdProcessingSet){
            inStatement += '\'' + accountId + '\',';
        }
        inStatement = inStatement.left(inStatement.length()-1);
        String initialQuery = 'SELECT Id FROM Account WHERE Id IN (' + inStatement + ')';
        return Database.getQueryLocator(initialQuery);
    }
    
    /**
     * inherited from Database.Batchable
     **/
    global void execute(Database.BatchableContext bc, List<SObject> objList){
        Set<Id> accountIdSet = new Set<Id>();
        if(processedAccounts==null)
            processedAccounts = new set<id>();
        if(accountsNotsync==null) 
          accountsNotsync = new set<id>();          
        system.debug('processedAccounts : '+processedAccounts.size()+' : '+processedAccounts);
        system.debug('Accounts to be set Notsync : '+accountsNotsync);
        system.debug('Object List : '+objList);
        for(sObject obj:objList){
            accountIdSet.add((Id)obj.get('Id'));
        }
        system.debug('Single Process starting : '+singleacc);  
        if(!accountIdSet.isEmpty() && !singleacc)
            LodeStarActions.MainProcess(accountIdSet,accountsNotsync);
        else if(!accountIdSet.isEmpty() && singleacc){
            //processedAccounts.addAll(LodeStarActions.ObtainAccountsSet(accountIdSet));
            LodeStarActions.SingleAccountProcess(accountIdSet,acctype,Cntid,syncflag,singleacc);
        }
    }
    

    /**
     * inherited from Database.Batchable
     **/
    global void finish(Database.BatchableContext bc){
        //if more records need to be processed, then start up another instance.
        system.debug('Calling From Finish Batch Context ....');
        if(processedAccounts==null)
            processedAccounts = new set<id>();
        if(accountsNotsync==null) 
          accountsNotsync = new set<id>();  
        set<id> accToProcess = new set<id>();
        if(singleAcc != Null && !singleAcc){
            accToProcess = LodeStarActions.ObtainNonSynchronizedAccounts();
            processedAccounts.addAll(accToProcess);
        }
        /*else
            processedAccounts.addAll(IdProcessingSet);
        /*if(!processedAccounts.isempty()){
            set<id> accError = LodeStarActions.ErrorIdentifier(accToProcess);
            accToProcess.removeAll(accError);
        }*/
        if((!accToProcess.isempty() || accToProcess.size() >0) && datetime.now().time().minute() <= 55  && !singleAcc){
            System.enqueueJob(new LodeStarIntegrationQueueJob(accToProcess,processedAccounts,accountsNotsync));
        }
        else{
            sendmail(processedAccounts,singleAcc);
        }
    }
    
    /**
     * inherited from System.Schedulable.  This is the first method kicked off 
     * for this process.  It will find a set of Accounts not Synchronized to begin 
     * Synchronization.
     **/
    global void execute(System.SchedulableContext sc){
        //check to make sure there are account records to process before beginning.
        //if(processedAccounts==null)
        
        system.debug('Calling From Schedulable Context ....');
        if(processedAccounts==null){
            processedAccounts = new set<id>();
            system.debug('Calling From Schedulable Context ....'+processedAccounts.size()+' : '+processedAccounts);
            lodeStarValidator lsv = new lodeStarValidator();
            bID = Database.executeBatch(lsv,100);
        }
    }
    
    public static void sendmail(set<id> processedAccounts,boolean singleAcc){
        string res ='';
        string res1='';
        string res2='';
        if(!processedAccounts.isempty()){
            Datetime dt = Datetime.newInstance(Date.today(),Time.newInstance(datetime.now().time().hour(),0,0,0));
            Datetime sysdt = Datetime.newInstance(Date.today(),Time.newInstance(0,0,0,0));
            system.debug('Current Hour : '+dt);
            res='<table border="1"><tr><th>Account ID</th><th>Account(Customer) Name</th><th>Service Territory</th><th>Lodestar Integration Status</th><th></th></tr><br/>';
            for(Ldc_account__c ldc : [select id,name,account__r.Lodestar_integration_status__c,service_territory__c from ldc_account__c where account__c IN : processedAccounts 
                                            and LastSent_to_Lodestar__c >= : sysdt and lastmodifieddate >= : dt order by account__r.Lodestar_integration_status__c]){ 
                if(res.length() <= 50000)
                    res+='<br/><tr><td>'+ldc.id+'</td><td>'+ldc.name+'</td><td>'+ldc.service_territory__c+'</td><td><i>'+ldc.account__r.Lodestar_integration_status__c+'</i></td></tr><br/>';
                else if(res1.length() <= 50000)
                    res1+='<br/><tr><td>'+ldc.id+'</td><td>'+ldc.name+'</td><td>'+ldc.service_territory__c+'</td><td><i>'+ldc.account__r.Lodestar_integration_status__c+'</i></td></tr><br/>';
                else 
                    res2+='<br/><tr><td>'+ldc.id+'</td><td>'+ldc.name+'</td><td>'+ldc.service_territory__c+'</td><td><i>'+ldc.account__r.Lodestar_integration_status__c+'</i></td></tr><br/>';            
            }
            
            if((res1 == '' || res1 == null || res1.length() == 0) && (res2 == '' || res2 == null || res2.length() == 0))
                res+='</table>';
            else if(res2 == '' || res2 == null || res2.length() == 0)
                res1+='</table>';
            else
                res2+='</table>';   
        }    
        else{
            res='\n\t\t<b> No Accounts are Sent to Lodestar in this Hour </b>\n\n';
        }
        
        string bodyMsg='';
        if(!singleacc)
            bodyMsg = 'The Lode star batch job @<b>'+datetime.now().time().hour()+':00</b> results are : <br/>';
        else
            bodyMsg = 'The Lode star Initiation job by '+UserInfo.getName()+' @<b>'+datetime.now().time()+'</b>  results are : <br/>';
        
        string mailerslst = label.LodeStar_Mailers;
        list<string> mailerstr = mailerslst.split(';');
        mailerstr.add(UserInfo.getName());
            
        list<user> usr = [select id,name,email from user where name IN : mailerstr];
        list<string> mailers = new list<string>();
        for(User U : Usr){
            mailers.add(u.email);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(mailers);
        mail.setSubject('LodeStar Job result');
        mail.setTargetObjectId(userinfo.getuserid());
        mail.setsaveAsActivity(false); 
        mail.setHtmlBody(bodyMsg+res+res1+res2);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
}