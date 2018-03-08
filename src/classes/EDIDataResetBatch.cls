global class EDIDataResetBatch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts
{
    String q;
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        q=ConstantUtility.getObjectFieldsQuery('DASR_Request__c') +' From DASR_Request__c where (Integration_Status__c  in (\'Waiting For Response\')) AND DASR_Submit_Date__c !=null  ' ;
        
        q += ' order by Originator_Name__c,Recipient_Name__c, CreatedDate ASC ';
        //q = generateSOQLQuery('DASR_Request__c');
        System.debug('q=='+q);
        return Database.getQueryLocator(q);
    }
    public void execute(Database.BatchableContext BC, List<Sobject> scope)
    {
        List<DASR_Request__c> lToProcess = (List<DASR_Request__c>) scope;
        
        List<DASR_Request__c> lDR = new List<DASR_Request__c>();
        Set<Id> sLDCID = new Set<Id>();
        LisT<LDC_Account__c> lLA = new list<LDC_Account__c>();
        LDC_Account__c tLA;
        for(DASR_Request__c tDR : lToProcess)
        {
            if(tDR.DASR_Type__c != null)
            {
                sLDCID.add(tDR.LDC_Account__c);
                tDR.Integration_Status__c ='Complete';
                tDR.Integration_Send_Date__c = System.today();
                tDR.Accepted__c	 = true;
                tDR.Last_EDI_Update_Date__c = system.today();
                lDR.add(tDR);
                
                if(tDR.LDC_Account__c != null && tDR.DASR_Type__c == 'GAAE' )
                { 
                    tLA = new LDC_Account__c();
                    tLA.id = tDR.LDC_Account__c;
                    tLA.LDC_Account_Status__c ='ACTIVE';
                    tLA.Enrollment_Status__c ='Accepted';
                    tLA.Enrolled__c = true;
                    if(tDR.LDC_Account__r.LDC_Start_Date__c == null){
                        
                        tLA.LDC_Start_Date__c = System.today();
                    }
                    lLA.add(tLA);
                    
                }
                else if(tDR.LDC_Account__c != null && tDR.DASR_Type__c == 'GAAD' )
                { 
                    tLA = new LDC_Account__c();
                    tLA.id = tDR.LDC_Account__c;
                    tLA.LDC_Account_Status__c ='PENDING_FINAL';

                    lLA.add(tLA);
                    
                }
            }
        }
        update lDR;
        update lLA;
    }
    public void finish(Database.BatchableContext BC)
    {}    
}