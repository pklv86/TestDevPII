public with sharing class lodestarSingleAccount {

    public boolean ldcsection {get; set; }
    public boolean sendBtnDisable {get;Set;}
    public boolean errBlock {get;set;}
    public boolean sentBlock {get;set;}
    public boolean ValidateBtn {get;set;}
    public boolean syncFlag {get;set;}
    public set<id> accset {get;set;}
    public string acctype {get;set;}
    public string selectedContract{get;set;}
    public ldc_account__c ldc{get;set;}
    public Account acc{get;set;}
    public transient list<contract_ldc__c> contractLDCLstAll {get;set;}
    public transient list<contract_ldc__c> contractLDCLst{get;set;}
    public set<id> cldcset {get;set;}
    public map<string,list<string>> errmap {get;set;}
    public list<string> errldc {get;set;}
    public string JobType {get;set;}
    public string JobStatus {get;set;}
    public string apexstatus {get;set;}
    public ID JobID {get; set;}
    Integer counter = 0;    //TO track the number of records parsed
    Integer limitSize = 100; //Number of records to be displayed
    Integer totalSize =0;   //To Store the total number of records available
    
    public lodestarSingleAccount (){
        if(ldc == null)
            ldc = new ldc_account__c();
        system.debug('Incoming'+apexpages.currentpage().getParameters().get('ID'));
        string accid = Apexpages.currentpage().getParameters().get('ID');
        if(accid !=null){ 
            ldc.account__c = accid;
            pickLdc();
        }
    }
    
    public list<selectoption> getContractList(){
        system.debug('Onload'+apexpages.currentpage().getParameters().get('ID'));
        string accid = Apexpages.currentpage().getParameters().get('ID');
        List<SelectOption> cntlist = new List<SelectOption>();
        cntlist.add(new SelectOption('','-None-'));
        if(accid !=null && contractLDCLstAll == null){ 
            for(Contract c : [select id,name,contractnumber from contract where accountid =: accid]){
                cntlist.add(new Selectoption(c.id,c.contractnumber));
            }
        }
        else if(contractLDCLstAll != null){
            map<id,string> tmpcntmap = new map<id,string>();
            for(contract_ldc__c cldc : contractLDCLstAll){
                tmpcntmap.put(cldc.contract__c,cldc.contract__r.contractnumber);    
            }
            for(ID ct : tmpcntmap.keyset()){
                cntlist.add(new Selectoption(ct,tmpcntmap.get(ct)));
            }
        }
        return cntlist;
    }

    public void pickLdc() {
        //pagereference pg = new pagereference('/apex/sendToLodestar?ID='+ldc.account__c);
        //pg.setredirect(true);
        system.debug('Account : '+ldc.account__c+' Account Type Code : '+ldc.Account_Type_Code__c);
        
        acc = [select id,name,short_code__c,business_account__c,Supplier__c,recordtypeId,IsPersonAccount from account where id =: ldc.account__c];
        if(acc.business_account__c != null){
            acc = [select id,name,short_code__c,business_account__c,Supplier__c,recordtypeId,IsPersonAccount from account where id =: acc.business_account__c];
        }
        system.debug('Acc : '+acc);
        
        accset = new set<id>();
        cldcset = new set<id>();
        accset.add(acc.id);
        acctype = ldc.Account_Type_Code__c;
        system.debug('Acctype : '+acctype);
        system.debug('Selected Contract : '+selectedContract);
        
        contractLDCLst = new list<contract_ldc__c>();
        
        string query ='select Id,Term_Start_Date__c, Term_Stop_Date__c, Active__c, IsSynchronized__c,contract__c,Contract__r.ContractNumber,contract__r.Bill_Method__c,Contract__r.Service_Territory__c,contract__r.status,'+
              'Contract__r.StartDate, Contract__r.End_Date__c,contract__r.Contract_Type__c,ldc_account__c,LDC_Account__r.Bill_Cycle__c,ldc_account__r.LDC_Start_Date__c,ldc_account__r.LDC_end_Date__c,'+ 
              'LDC_Account__r.LDC_Account_Number__c,LDC_Account__r.CRM_Id__c,LDC_Account__r.Revenue_Class__c, LDC_Account__r.Service_Street_1__c,LDC_Account__r.LDC_Account_Status__c,contract__r.accountid,'+
              'LDC_Account__r.LDC_Vendor__r.Utility_Code__c,ldc_account__r.account__r.IsPersonAccount,ldc_account__r.account__r.LodeStar_Integration_Status__c,'+
              'LDC_Account__r.Account_Type_Code__c from contract_ldc__c where (LDC_Account__r.Account__c IN :accset OR LDC_Account__r.Account__r.business_account__c IN :accset) '+ 
              'AND LDC_Account__r.Account__r.LodeStar_Integration_Status__c != \'Synchronized\' AND IsSynchronized__c = false AND LDC_account__r.LDC_vendor__r.name !=\'AMEREN\' '+
              'AND (LDC_Account__r.LDC_Account_Status__c=\'ACTIVE\' OR LDC_Account__r.LDC_Account_Status__c=\'FINAL\') AND Term_Start_Date__c != null';
                      //AND  LDC_Account__r.Account__r.Validation__c = 'Validated'
        
        list<contract_ldc__c> tempcldclst = Database.query(query);
        query+=' AND contract__r.Validation__C = \'validated\'';
        if(ldc.Account_Type_Code__c != null)
            query+=' AND ldc_account__r.Account_Type_Code__c = \''+ldc.Account_Type_Code__c+'\'';
            
        if(selectedContract != null)
            query+=' AND contract__c =: selectedContract';
            
        system.debug('Formed Query : '+query);
        contractLDCLstAll = Database.query(query);     
        
        if(tempcldclst.size() == contractLDCLstAll.size())
            syncflag = true;
        else
            syncflag = false;           
        
        /*contractLDCLstAll  = [select Id,Term_Start_Date__c, Term_Stop_Date__c, Active__c, IsSynchronized__c,contract__c,Contract__r.ContractNumber,contract__r.Bill_Method__c,
                            Contract__r.StartDate, Contract__r.End_Date__c,contract__r.Contract_Type__c,ldc_account__c,LDC_Account__r.Bill_Cycle__c,ldc_account__r.LDC_Start_Date__c, 
                            LDC_Account__r.LDC_Account_Number__c,LDC_Account__r.CRM_Id__c,LDC_Account__r.Revenue_Class__c, LDC_Account__r.Service_Street_1__c,
                            LDC_Account__r.LDC_Account_Status__c,LDC_Account__r.Account_Type_Code__c,LDC_Account__r.LDC_Vendor__r.Utility_Code__c,ldc_account__r.account__r.IsPersonAccount,
                            ldc_account__r.account__r.LodeStar_Integration_Status__c,ldc_account__r.account__r.Validation__c from contract_ldc__c 
                            where (LDC_Account__r.Account__c IN :accset OR LDC_Account__r.Account__r.business_account__c IN :accset) 
                            AND LDC_Account__r.Account__r.LodeStar_Integration_Status__c != 'Synchronized' 
                            //AND  LDC_Account__r.Account__r.Validation__c = 'Validated'
                            AND IsSynchronized__c = false AND LDC_account__r.LDC_vendor__r.name !='AMEREN' AND (LDC_Account__r.LDC_Account_Status__c='ACTIVE' OR 
                            LDC_Account__r.LDC_Account_Status__c='FINAL') AND Term_Start_Date__c != null AND Term_Start_Date__c <= TODAY];*/
        system.debug('CLDC : '+contractLDCLstAll.size()+' : '+contractLDCLstAll );
        
        if(!contractLDCLstAll.isempty()){
            ldcsection = true;
            sendBtnDisable = true;
            validateBtn = false;
            errBlock = false;
            sentBlock = false;
            for(contract_ldc__c cldc : contractLDCLstAll){
                cldcset.add(cldc.id);
            }
            system.debug('Contract LDC set : '+cldcset.size()+' : '+cldcset);
        }    
        else
            ldcsection=false;
            
        totalSize = contractLDCLstAll .size();
        
        if((counter+limitSize) <= totalSize){
            for(Integer i=0;i<limitSize;i++){
                contractLDCLst.add(contractLDCLstAll.get(i));
            }
        }
        else{
            for(Integer i=0;i<totalSize;i++){
                contractLDCLst.add(contractLDCLstAll.get(i));
            }
        }
        //return pg;
    }
    
    public void First(){
        pickLdc();
        contractLDCLst.clear();
        counter=0;
        if((counter + limitSize) <= totalSize){
            for(Integer i=0;i<limitSize;i++){
                contractLDCLst.add(contractLDCLstAll.get(i));
            }   
        } 
        else{
            for(Integer i=0;i<totalSize;i++){
                contractLDCLst.add(contractLDCLstAll.get(i));
            }       
        }
    }
   
    public void hasNext(){
        pickLdc();
        contractLDCLst.clear();
        counter=counter+limitSize+1;
       
        if((counter+limitSize) <= totalSize){
            for(Integer i=counter-1;i<(counter+limitSize);i++){
                contractLDCLst.add(contractLDCLstAll.get(i));
            }
        } else{
            for(Integer i=counter;i<totalSize;i++){
                contractLDCLst.add(contractLDCLstAll.get(i));
            }
        }
    }
   
    public void hasPrevious(){
        pickLdc();
        contractLDCLst.clear();
      counter=counter-limitSize-1;       
       
        for(Integer i=counter;i<(counter+limitSize); i++){
            contractLDCLst.add(contractLDCLstAll.get(i));
        }
    }

    public void Last (){
        pickLdc();
        contractLDCLst.clear();
               
        if(math.mod(totalSize , limitSize) == 0){
            counter = limitSize * ((totalSize/limitSize)-1);
        } 
        else if (math.mod(totalSize , limitSize) != 0){
            counter = limitSize * ((totalSize/limitSize));
        }
       
        for(Integer i=counter-1;i<totalSize-1;i++){
                contractLDCLst.add(contractLDCLstAll.get(i));
        }
    }
   
    public Boolean getDisableNext(){
   
        if((counter + limitSize) >= totalSize )
            return true ;
        else
            return false ;
    }
   
    public Boolean getDisablePrevious(){
   
        if(counter == 0)
            return true ;
        else
            return false ;
    }
    
    public void callLodestar(){
        
        system.debug('Lodestar variables --> Acc : '+accset+' AccTypecode : '+acctype+' selectedContract : '+selectedContract);
        pickLdc();
        LodeStarIntegrationQueueJob LSqueue = new LodeStarIntegrationQueueJob(accset,acctype,selectedContract,syncflag,true);
        ID bid = System.enqueueJob(LSqueue);
        if (!Test.isRunningTest()){
        system.debug('Batch Id : '+bid);
            AsyncApexJob aJob = [select id,JobItemsProcessed,JobType,status from AsyncApexJob where id =: bid];
            if(aJob != null){
                jobID = aJob.id;
                JobType = aJob.JobType;
                jobstatus = aJob.status;
                apexstatus = 'Currently Running';
            }
        }
        sendBtnDisable = true;
        sentBlock = true;
    }
    
     public void lodestarResult(){
        
        system.debug('Lodestar variables --> Acc : '+accset+' AccTypecode : '+acctype);
        if (!Test.isRunningTest()){
            system.debug('Batch Job Id : '+jobID);
            AsyncApexJob aJob = [select id,JobItemsProcessed,JobType,status,CompletedDate,CreatedDate from AsyncApexJob where id =: jobID];
            if(aJob != null){
                jobID = aJob.id;
                JobType = aJob.JobType;
                jobstatus = aJob.status;
                apexstatus = 'Currently Running';
                datetime completedt = ajob.CompletedDate;
                if(aJob.JobType == 'Queueable')
                    datetime createdt = ajob.CreatedDate;
                system.debug('AsyncApex Job : '+ajob);
                if(aJob.status == 'Completed' && aJob.JobType == 'Queueable'){
                    AsyncApexJob aJob1 = [select id,JobItemsProcessed,JobType,status,CompletedDate from AsyncApexJob where createdbyid =: UserInfo.getUserId() and jobtype = 'BatchApex'  and createddate >= : completedt];
                    if(aJob1 != null){
                        jobID = aJob1.id;
                        JobType = aJob1.JobType;
                        jobstatus = aJob1.status;
                    }
                }
                else if(aJob.status == 'Completed' && aJob.JobType == 'BatchApex'){
                    jobID = aJob.id;
                    JobType = aJob.JobType;
                    jobstatus = aJob.status;
                    apexstatus = 'Finished';
                    completedt = ajob.CompletedDate;
                }
                system.debug('Contract LDC set : '+cldcset.size()+' : '+cldcset);
                string query='select id,term_start_date__c,term_stop_date__c,active__c,ldc_account__r.LDC_Account_Number__c,ldc_account__r.LDC_Account_Status__c,'+
                            'contract__r.contractnumber,contract__r.validation__C,contract__r.Contract_Type__c,contract__r.Bill_Method__c,ldc_account__r.account__r.LodeStar_Integration_Status__c'+
                            ' from contract_ldc__c where id IN : cldcset AND contract__r.validation__c = \'validated\'';
                contractLDCLstAll = Database.query(query); 
            }
        }
        sendBtnDisable = true;
        sentBlock = true;
    }
    
    public void ValidateToLS(){
        
        pickLdc();
        errmap = new map<string,list<string>>();
        errldc = new list<string>();
        set<id> bgaccset = new set<id>();
        map<string,list<string>> bgldcmap = new map<string,list<string>>();
        string errstr ='';
        
        for(contract_ldc__c cldc : contractLDCLstAll){
            bgaccset.add(cldc.contract__r.accountid);
        }
        system.debug('Accounts : '+bgaccset.size()+' : '+bgaccset);
        if(!bgaccset.isempty()){
            for(Billing_Group_Ldc__c bgldc : [select id,name,Billing_Group__c,Billing_Group__r.Name,Pseudo_Contract__c,Billing_Start_Date__c,Billing_Stop_Date__c,LDC_Account_Number__c,
                                        LDC_Account__c,LDC_Account__r.account__c,Billing_Group__r.Contract_Number__c,Billing_Group__r.Pseudo_Contract__c,Billing_Group__r.Group_Address_Line1__c,
                                        Billing_Group__r.Group_Address_Line2__c,Billing_Group__r.contract__c,Billing_Group__r.Group_Address_Line3__c,Billing_Group__r.Group_City__c,
                                        Billing_Group__r.Group_State__c,Billing_Group__r.Group_Postal_Code__c,Billing_Group__r.Start_Date__c,Billing_Group__r.Stop_date__c   
                                        from Billing_Group_Ldc__c where Billing_Group__r.Account__c IN : bgaccset and Synchronized__c = false ]){//and active__c = true
            
                errstr ='';
                list<string> errlist = new list<string>();
                system.debug('Dates : '+bgldc.Billing_Start_Date__c+' : '+bgldc.Billing_Stop_Date__c);
                if(bgldc.Billing_Start_Date__c > bgldc.Billing_Stop_Date__c){
                    errstr = 'Billing Group LDC Start Date is greater than stop date -- '+bgldc.name;
                    errlist.add(errstr);
                }
                
                system.debug('Dates : '+bgldc.Billing_Group__r.Start_Date__c+' : '+bgldc.Billing_Group__r.Stop_Date__c);
                if(bgldc.Billing_Group__r.Start_Date__c != null && bgldc.Billing_Group__r.Start_Date__c > bgldc.Billing_Group__r.Stop_date__c){
                    errstr = 'Billing Group Start Date is less than stop date -- '+bgldc.Billing_Group__r.Name;
                    errlist.add(errstr);
                }
                
                if(bgldc.Billing_Group__r.Start_Date__c == null){
                    errstr = 'Billing Group Start Date is Null -- '+bgldc.Billing_Group__r.Name;
                    errlist.add(errstr);
                }
                
                if(errstr != ''){  
                    list<string> tempstrlst = new list<string>(); 
                    if(bgldcmap.containskey(bgldc.ldc_account_number__c))
                        tempstrlst = bgldcmap.get(bgldc.ldc_account_number__c);
                    tempstrlst.addAll(errlist);
                    bgldcmap.put(bgldc.ldc_account_number__c,tempstrlst);
                }
            }
        }
        
        for(contract_ldc__c cldc : contractLDCLstAll){
            errstr ='';
            list<string> errlist = new list<string>();
            
            if(cldc.contract__c == null){
                errstr = 'Contract Cannot be BLANK -- '+cldc.id;
                errlist.add(errstr);
            }
            
            if(cldc.ldc_account__r.account_type_code__c == null){
                errstr = 'LDC Account Type Code is BLANK';
                errlist.add(errstr);
            }
            
            if(cldc.ldc_account__r.bill_cycle__c == null){
                errstr = 'LDC Bill Cycle is BLANK';
                errlist.add(errstr);
            }
            
            if(cldc.ldc_account__r.ldc_end_date__c == null && cldc.ldc_account__r.ldc_account_status__c == 'FINAL'){
                errstr = 'LDC Account is Final without LDC End Date';
                errlist.add(errstr);
            }
            
            if(cldc.ldc_account__r.ldc_end_date__c != null){
                date startdt = cldc.term_start_date__c.date();
                date enddt = (cldc.term_stop_date__c !=  null)?cldc.term_stop_date__c.date():null; //removing day as SF returns GMT
                system.debug('CLDC Start Date : '+startdt+' Enddate : '+enddt+' LDC End date : '+cldc.ldc_account__r.ldc_end_date__c);
                if(cldc.ldc_account__r.ldc_account_status__c != 'FINAL'){
                    errstr = 'LDC Account is NOT Final with LDC End Date Populated';
                    errlist.add(errstr);
                }
                if(cldc.ldc_account__r.ldc_end_date__c < startdt  && cldc.active__c == true){
                    errstr = 'LDC Account Enddate is less than Contract LDC Term start date -- '+cldc.id;
                    errlist.add(errstr);
                }
                if(cldc.ldc_account__r.ldc_end_date__c < enddt ){///&& cldc.active__c == true 
                    errstr = 'LDC Account Enddate is less than Contract LDC Term stop date';
                    errlist.add(errstr);
                }
            }
            
            if(cldc.ldc_account__r.ldc_start_date__c != null){
                date startdt = cldc.term_start_date__c.date();
                date enddt = (cldc.term_stop_date__c !=  null)?cldc.term_stop_date__c.adddays(-1).date():null;
                if(cldc.ldc_account__r.ldc_start_date__c > startdt && cldc.active__c == true){
                    errstr = 'LDC Account startdate is greater than Contract LDC Term start date -- '+cldc.id;
                    errlist.add(errstr);
                }
                if(cldc.ldc_account__r.ldc_start_date__c > enddt && cldc.active__c == true){
                    errstr = 'LDC Account Startdate is greater than Contract LDC Term stop date';
                    errlist.add(errstr);
                }
            }
            
            if(cldc.term_start_date__c == null){
                errstr = 'Contract LDC TermStart Date is Null -- '+cldc.id;
                errlist.add(errstr);
            }
            
            if(cldc.term_stop_date__c == null){
                errstr = 'Contract LDC TermStop Date is Null -- '+cldc.id;
                errlist.add(errstr);
            }
            
            if(cldc.term_start_date__c >= cldc.term_stop_date__c){
                errstr = 'Contract LDC TermStart Date is less than Term Stop date -- '+cldc.id;
                errlist.add(errstr);
            }
            
            if((cldc.ldc_account__r.ldc_start_date__c != null && cldc.ldc_account__r.ldc_end_date__c != null) && cldc.ldc_account__r.ldc_start_date__c > cldc.ldc_account__r.ldc_end_date__c ){
                errstr = 'LDC Account Startdate is greater than enddate -- '+cldc.ldc_account__r.ldc_account_number__c;
                errlist.add(errstr);
            }
            
            if(cldc.LDC_Account__r.LDC_Vendor__r.Utility_Code__c == null){
                errstr = 'LDC Vendor Utility Code or JURISCODE is empty';
                errlist.add(errstr);
            }
            
            if(cldc.contract__r.status == 'Draft' || cldc.contract__r.status == 'Cancelled'){
                errstr = 'Contract status is -- '+cldc.contract__r.status+' for -- '+cldc.contract__r.contractnumber;
                errlist.add(errstr);
            }
            
            if(cldc.contract__r.Contract_Type__c == null){
                errstr = 'Contract Type Cannot Be Null -- '+cldc.contract__r.contractnumber;
                errlist.add(errstr);
            }
            
            if(cldc.contract__r.Service_Territory__c == null){
                errstr = 'Contract Service Territory is Null -- '+cldc.contract__r.contractnumber;
                errlist.add(errstr);
            }
            
            if(errstr != '' || bgldcmap.containskey(cldc.ldc_account__r.ldc_account_number__c)){  
                if(!errmap.containskey(cldc.ldc_account__r.ldc_account_number__c))
                    errldc.add(cldc.ldc_account__r.ldc_account_number__c);
                
                list<string> tempstrlst = new list<string>(); 
                if(errmap.containskey(cldc.ldc_account__r.ldc_account_number__c))
                    tempstrlst = errmap.get(cldc.ldc_account__r.ldc_account_number__c);
                tempstrlst.addAll(errlist);
                if(bgldcmap != null && bgldcmap.containskey(cldc.ldc_account__r.ldc_account_number__c))
                    tempstrlst.addAll(bgldcmap.get(cldc.ldc_account__r.ldc_account_number__c));
                errmap.put(cldc.ldc_account__r.ldc_account_number__c,tempstrlst);
            }
        }
        system.debug('Map : '+errmap.isempty()+' : '+errmap);
        if(errmap.isempty()){
            sendBtnDisable =false;
            validateBtn = true;
        }
        else
            errBlock = true;
    }
}