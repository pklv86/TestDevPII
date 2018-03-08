/* 
 * Name: MissingContractLDC
 * Type: Apex Class
 * Test Class: MissingContractLDCTest
 * Description:  This batch job is to check if any dasr have missing contract LDC's or duplicate contract LDC's also duplicate DASR's. 
 * Change History:
 *============================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Prasad Paladugu         07/13/2016       1. Initial Version created
 */
 global class MissingContractLDC implements schedulable,Database.Batchable <sobject>,Database.Stateful{
  
  global void execute (schedulablecontext sc){
    MissingContractLDC mcldc = new MissingContractLDC();
    Id bid = Database.executeBatch( mcldc,20);
  }
  global MissingContractLDC(){

  }
  
  string query;
  global map<id,string> dasrlookupmap;
  global set<string> dupcldc; 
  global map<string,string> dupdasr;
  global set<id> dasrtodelsetglobal;
  global boolean runnedonce = true;
  
  /******* ORIGINAL QUERY
  query='select id,name,Change_Effective_Date__c,Contract__c,Contract__r.id,contract__r.Rate_Code__c,contract__r.StartDate,contract__r.EndDate,Integration_Status__c,';
    query+='Contract__r.contractnumber,ldc_account__c,ldc_account__r.name,ldc_account__r.LDC_Account_Number__c,createddate,accepted__c,rejected__c,DASR_Type__c';
    query+=' from dasr_request__c where Dynegy_Initiated__c = true and createdby.name != \'Integration User\'  order by ldc_account__c'; 
  ***********/
  
  global Database.QueryLocator start (Database.BatchableContext bc){
  	set<id> ldcset = new set<id>();
  	query='select id,ldc_account__c from dasr_request__c where Dynegy_Initiated__c = true and createdby.name != \'Integration User\' and lastmodifieddate = today   order by ldc_account__c limit 49000';
  	list<dasr_request__c> dsrlst = Database.query(query);
  	system.debug('DASR Lst : '+dsrlst.size());
  	for(dasr_request__c dasr : dsrlst){
  		ldcset.add(dasr.ldc_account__c);
  	}
  	query='';
    query='select id,name,Change_Effective_Date__c,Contract__c,Contract__r.id,contract__r.Rate_Code__c,contract__r.StartDate,contract__r.EndDate,Integration_Status__c,';
    query+='Contract__r.contractnumber,ldc_account__c,ldc_account__r.name,ldc_account__r.LDC_Account_Number__c,createddate,accepted__c,rejected__c,DASR_Type__c';
    query+=' from dasr_request__c where Dynegy_Initiated__c = true and createdby.name != \'Integration User\' and ldc_account__c IN : ldcset order by ldc_account__c'; 
    return Database.getQueryLocator(query);
  }
   
  global void execute (Database.BatchableContext bc, list<sobject> scope ){
    list<DASR_Request__c> dasrlst = (list<DASR_Request__c>)scope;
    map<id,map<date,list<dasr_request__c>>> tempdupdasr = new map<id,map<date,list<dasr_request__c>>>();
    if(dupdasr == null){
      dupdasr = new map<string,string>();
    }
    if(dasrlookupmap==null){
      dasrlookupmap = new map<id,string>();
    }
    if(dupcldc == null){
      dupcldc = new set<string>();
    }
    if(dasrtodelsetglobal == null){ 
      dasrtodelsetglobal = new set<id>();
    }
    
    list<contract_ldc__c> cldctoaddlst = new list<contract_ldc__c>();
    list<contract_ldc__c> cldctodellst = new list<contract_ldc__c>();
    list<dasr_request__c> dasrtodellst = new list<dasr_request__c>();
    set<id> cldctodelset = new set<id>();
    set<id> dasrtodelset = new set<id>();
    set<id> cldcset = new set<id>();
    set<id> accldcset = new set<id>();
        
    /****************** To Check for duplicate dasr based on change effective date and dasrtype excluding Manually fullfilled******************************/       
    for(dasr_request__c dasr : dasrlst){
      if(dasr.Change_Effective_Date__c != null){
        map<date,list<dasr_request__c>> tempdasrmap = new map<date,list<dasr_request__c>>();
        list<dasr_request__c> tempdasrlst = new list<dasr_request__c>();
        list<dasr_request__c> tempdasrlstfordup = new list<dasr_request__c>();
        if(tempdupdasr.containskey(dasr.ldc_account__c)){
          tempdasrmap = tempdupdasr.get(dasr.ldc_account__c);
          system.debug('tempdasrmap : '+tempdasrmap.size()+' : '+tempdasrmap);
          if(tempdasrmap.containskey(dasr.Change_Effective_Date__c)){
            tempdasrlst = tempdasrmap.get(dasr.Change_Effective_Date__c);
            system.debug('tempdasrlst : '+tempdasrlst.size()+' : '+tempdasrlst);
            tempdasrlstfordup.addAll(tempdasrlst);
            Integer counter=1;
            string dasrname= ''+dasr.name;
            string dasrname1 = '';
            Datetime dasrtodel = dasr.createddate;
            for(dasr_request__c innerdasr : tempdasrlst){
              if(dasr.Change_Effective_Date__c == innerdasr.Change_Effective_Date__c 
                && (dasr.Integration_Status__c != 'Manually Fulfilled' && innerdasr.Integration_Status__c != 'Manually Fulfilled')
                && dasr.DASR_Type__c == innerdasr.DASR_Type__c && dasr.rejected__c != true && innerdasr.rejected__c != true){
                system.debug('found duplicate dasr : '+dasr.name+' : '+innerdasr.name);
                counter++;
                tempdasrlstfordup.add(dasr);
                system.debug('createddate dasr : '+dasrtodel+' : '+innerdasr.createddate);
                if(dasrtodel >= innerdasr.createddate ){
                  system.debug('In for deleting dasr...');
                  dasrtodelset.add(innerdasr.id);
                  dasrtodelsetglobal.add(innerdasr.id);
                  dasrname1+= ':'+innerdasr.name;
                }
                else{
                  system.debug('In for deleting dasr...');
                  dasrtodelset.add(dasr.id);
                  dasrtodelsetglobal.add(dasr.id);
                }
                dasrname += '-->'+dasrname1;
                dupdasr.put(string.valueof(dasr.ldc_account__r.name),dasrname);
              }
            }
            
            if(counter>1){
              //tempdasrlst.add(dasr);
              tempdasrmap.put(dasr.Change_Effective_Date__c,tempdasrlstfordup);
              tempdupdasr.put(dasr.ldc_account__c,tempdasrmap);
            }
          }
          else{
            tempdasrlst.add(dasr);
            tempdasrmap.put(dasr.Change_Effective_Date__c,tempdasrlst);
            tempdupdasr.put(dasr.ldc_account__c,tempdasrmap);
          }
        }
        else{ //if(!tempdupdasr.containskey(dasr.ldc_account__c))  
          tempdasrlst.add(dasr);
          tempdasrmap.put(dasr.Change_Effective_Date__c,tempdasrlst);
          tempdupdasr.put(dasr.ldc_account__c,tempdasrmap);
        }
      }
    }
    
    
    /****************** To Check for duplicate dasr based on change effective date and dasrtype excluding Manually fullfilled******************************/
    for(dasr_request__c dasr : dasrlst){
      if(dasr.Integration_Status__c != 'Manually Fulfilled'){      
        list<dasr_request__c> dasrforldc = [select id,name,Change_Effective_Date__c,contract__r.name,createddate,Integration_Status__c,DASR_Type__c,rejected__c from dasr_request__c 
                            where ldc_account__c =: dasr.ldc_account__c and createdby.name != 'Integration User' 
                            and Integration_Status__c != 'Manually Fulfilled' and Change_Effective_Date__c != null];
        string dasrname=''+dasr.name;
        Datetime dasrtodel = dasr.createddate;
        string dasrname1='';
        for(dasr_request__c innerdasr : dasrforldc){
          if(dasr.id != innerdasr.id){
            if(innerdasr.Change_Effective_Date__c == dasr.Change_Effective_Date__c && dasr.DASR_Type__c == innerdasr.DASR_Type__c && dasr.rejected__c != true && innerdasr.rejected__c != true){
              system.debug('found duplicate dasr : '+dasr.name+' : '+innerdasr.name);
              //string dasrname1 = ' # '+ (dupdasr.get(dasr.ldc_account__r.name)==null)? innerdasr.name:dupdasr.get(dasr.ldc_account__r.name);  
              system.debug('createddate dasr : '+dasrtodel+' : '+innerdasr.createddate);
              if(dasrtodel >= innerdasr.createddate ){
                system.debug('In for deleting dasr...');
                dasrtodelset.add(innerdasr.id);
                dasrtodelsetglobal.add(innerdasr.id);
                dasrname1+= ':'+innerdasr.name;
              }
              else{
                system.debug('In for deleting dasr...');
                dasrtodelset.add(dasr.id);
                dasrtodelsetglobal.add(dasr.id);
              }
              dasrname += '-->'+dasrname1; 
              dupdasr.put(string.valueof(dasr.ldc_account__r.name),dasrname);
            }
          }
        }
      }
    }
    
    system.debug('dasrtodelset : '+dasrtodelset.size()+' : '+dasrtodelset);
    for(dasr_request__c dasr:[select id,name,ldc_account__c,contract__c from dasr_request__c where id IN : dasrtodelset]){
      dasrtodellst.add(dasr);
      cldcset.add(dasr.contract__c);
      accldcset.add(dasr.ldc_account__c);
    }
    
    try{
      if(!dasrtodellst.isempty()) delete dasrtodellst;
    }
    catch (DmlException e){
      system.debug('Delete Exception : '+e);
    }
    
    /****************** To remove duplicate dasr from the ongoing batch******************************/
    system.debug('Dasr lst : '+dasrlst.size());
    for(Integer i = dasrlst.size()-1 ; i>=0; --i){
      if(dasrtodelset.contains(dasrlst[i].id)){
        system.debug('Removing DASR : '+dasrlst[i]);
        dasrlst.remove(i);
      }
    }
    
    /****************** To Check for duplicate Contract ldcs and missing contract ldcs ******************************/
    system.debug('Dasr lst : '+dasrlst.size());
    for(dasr_request__c dasr : dasrlst){
      string cntaldc = '';
      if(dasr.contract__c != null ){
        cntaldc= dasr.name+':'+dasr.Contract__r.contractnumber+'@'+dasr.ldc_account__r.name+'#'+dasr.ldc_account__r.LDC_Account_Number__c; 
        contract_ldc__c cldcadd = new contract_ldc__c();
        
        list<contract_ldc__c> tempcldc = [select id,name from contract_ldc__c where ldc_account__c = : dasr.ldc_account__c and contract__c = : dasr.contract__c order by createddate desc];
        system.debug(' TEMP CLDC : '+tempcldc.size()+' : '+tempcldc);
        
        if(dasr.Integration_Status__c != 'Manually Fulfilled' && dasr.rejected__c != true){
          if(tempcldc.isempty()){
            system.debug('lodaing Map ...');
            dasrlookupmap.put(dasr.id,cntaldc);
            cldcadd.name         = dasr.contract__r.id;
            cldcadd.ldc_account__c    = dasr.ldc_account__c;
            cldcadd.contract__c      = dasr.contract__c;
            cldcadd.Rate_Code__c      = dasr.contract__r.Rate_Code__c;
            //changed below line for SCR 1187
            cldcadd.Term_Start_Date__c  = (dasr.Change_Effective_Date__c != null && dasr.accepted__c == True ) ? DateTime.newInstance(dasr.Change_Effective_Date__c,Time.newInstance(0,0,0,0)):null;
            cldcadd.Term_Stop_Date__c  = dasr.contract__r.EndDate;
            cldcadd.External_Reference_ID__c = dasr.name;
            cldctoaddlst.add(cldcadd);
          }
        }
        if(tempcldc.size()>1){
          system.debug('Identified duplicate CLDC : '+dasr.name); 
          dupcldc.add(dasr.name);
          for(integer i=1; i<tempcldc.size();i++){
            cldctodelset.add(tempcldc[i].id);
            system.debug('Checking ... : '+dasr.name+' : '+tempcldc[i].id);
          }
        }
      }        
    }
    
    for(contract_ldc__c cldc : [select id,name from contract_ldc__c where (contract__c IN : cldcset and ldc_account__c IN : accldcset) or id IN : cldctodelset]){
      cldctodellst.add(cldc);
    }
    
    try{
      if(!cldctoaddlst.isempty()) upsert cldctoaddlst;
      if(!cldctodellst.isempty()) delete cldctodellst;
    }
    catch (DmlException e){
      system.debug('Delete || Upsert Exception : '+e);
    }
    
  }
  
  global void finish (Database.BatchableContext bc){
    string result='';
    if(dupdasr == null){
      dupdasr = new map<string,string>();
    }
    if(dasrlookupmap==null){
      dasrlookupmap = new map<id,string>();
    }
    if(dupcldc == null){
      dupcldc = new set<string>();
    }
    if(dasrtodelsetglobal == null){ 
      dasrtodelsetglobal = new set<id>();
    }
    
    /****************** Converting all maps to string for showing as report ******************************/
    for(Id maploop : dasrlookupmap.keyset()){
      string dasrvalue= dasrlookupmap.get(maploop);
      string dasrname = dasrvalue.substringBefore(':');
      string contractname = dasrvalue.substringBetween(':','@');
      string ldcaccount = dasrvalue.substringBetween('@','#');
      string ldcaccountnumber = dasrvalue.substringAfter('#');
      
      result += dasrname+'  '+contractname+'  '+ldcaccount+'  : '+ldcaccountnumber+'\n';
    }
    
    string dupresult='';
    Integer count =1;
    for(String setloop : dupcldc){
      dupresult += ''+setloop+'\t';
      if(math.mod(count,5) == 0) 
        dupresult += '\n';
      count++;
    }
    dupresult += '\n';
    
    string dupdasrresult='';
    for(string dupdasrtemp : dupdasr.keyset()){
      dupdasrresult += ' '+dupdasrtemp+' --> '+dupdasr.get(dupdasrtemp)+'\n';
    }
    system.debug('dasrtodelset : '+dasrtodelsetglobal.size()+' : '+dasrtodelsetglobal);
    
    /****************** Self looping until all maps are empty ******************************/
    if(!dasrlookupmap.isempty() || !dupcldc.isempty() ||  !dupdasr.isempty()){
      MissingContractLDC missingCLDC = new MissingContractLDC();
      Database.executeBatch( missingCLDC,50);
    }

    string mailerslst = label.Missing_Contract_LDCs;
    list<string> mailerstr = mailerslst.split(';');
    list<user> usr = [select id,name,email from user where name IN : mailerstr];
    list<string> mailers = new list<string>();
    for(User U : Usr){
      mailers.add(u.email);
    }
    
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(mailers);
        mail.setSubject('Identified Missing Contract LDCs and Duplicate Contract LDCs and Duplicate DASRs');
        mail.setTargetObjectId(userinfo.getuserid());
        mail.setsaveAsActivity(false); 
    mail.setPlainTextBody('The batch found '+dasrlookupmap.size()+' empty contract LDC\'s : \n DASR Name  Contract Number    LDC Account Number  LDC Account Number \n'+result
                +'\n The batch found '+dupcldc.size()+' duplicate contract LDC\'s for DASR\'s : \n'+dupresult
                +'\n The batch found '+dupdasr.size()+' duplicate DASR\'s : \n'+dupdasrresult);
    
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }
  
}