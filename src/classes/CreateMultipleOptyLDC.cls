/* 
 * Name: CreateMultipleOptyLDC
 * Type: Apex Class
 * Test Class: CreateMultipleOptyLDCTest
 * Description:  Allows Selecting Multiple Account LDC for Opportunity. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         03/13/2016       1. Initial Version created
 */
public with sharing class CreateMultipleOptyLDC {
 
    public String selectionId{get;set;}
    public ApexPages.StandardSetController setCon;
    public Set<Id> selectedIds;
    public Opportunity oppRec;
    public boolean resetHeader {get; set;}
    
    public CreateMultipleOptyLDC ()
    {
        Integer pageSize = 5;
        try{
            if(label.OpportunityLDCPageSize != null && label.OpportunityLDCPageSize != '' && label.OpportunityLDCPageSize != '0'){
                pageSize = (Integer.ValueOf(label.OpportunityLDCPageSize) < 50)?Integer.ValueOf(label.OpportunityLDCPageSize):50;
            }
        }
        catch (Exception ex){
            system.debug('>>> Invalid Value for Paging Size:' + label.OpportunityLDCPageSize);
        }
        List<Opportunity> lstOpp = [Select id, Name, AccountId, Service_Territory__c from Opportunity where id = :ApexPages.currentPage().getParameters().get('masterId')];
        if(!lstOpp.isEmpty()){
          oppRec = lstOpp[0];
          selectedIds= new Set<Id>();
          setCon= new ApexPages.StandardSetController(  [select Id, Name, Alias_Name__c,    LDC_Account_Status__c, LDC_Account_Number__c,  Service_Territory__c from LDC_Account__c where Account__c = :oppRec.AccountId AND Service_Territory__c = :oppRec.Service_Territory__c AND Id Not IN (select LDC_Account__c From Opportunity_LDC__c Where Opportunity__c = :oppRec.id) order by ldc_account_number__C ASC] );
          setCon.setpageNumber(1);
          setCon.setPageSize(pageSize);
          if(setCon.getResultSize() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No more LDC Accounts available to add'));
          }
        }
        else{
          oppRec = null;
        } 
        
    }
    
    public PageReference cancel() { 
        if(oppRec == null) return new PageReference('/');   
        return optyViewRedirect();
    }
    
    public PageReference save() {
        List<Opportunity_LDC__c> lstOptyLDC = new List<Opportunity_LDC__c>();
        for(ID selId : selectedIds){   
            Opportunity_LDC__c oRec = new Opportunity_LDC__c();
            oRec.LDC_Account__c = selId;
            oRec.Opportunity__c = oppRec.id;
            lstOptyLDC.add(oRec);                        
        }
        system.debug('>>> Inserting List: ' + lstOptyLDC);
        if(!lstOptyLDC.isEmpty()){
            insert lstOptyLDC;
        }
        
        if(oppRec == null) return new PageReference('/');
        return optyViewRedirect();
    }
    
    private PageReference optyViewRedirect(){
        PageReference opptyPage = new ApexPages.StandardController(oppRec).view();
        opptyPage.setRedirect(true);
        return opptyPage;
    }
    
    public void addSelectedId(){
        if(selectionId != null && selectionId != ''){
            system.debug('>>> Adding To Set :' + selectionId);
            selectedIds.add(selectionId);
            setHeaderValue();
        }
        else{
            system.debug('>>> Iterating Over Current Record set');
            for(sObject so : setCon.getRecords()){
                LDC_Account__c a = (LDC_Account__c)so;
                system.debug('>>> Checking for : ' + a.Id); 
                if(!selectedIds.contains(a.Id)){
                    system.debug('>>> Adding : ' + a.Id + ' TO : '+selectedIds);
                    selectedIds.add(a.Id);
                }
                else{
                    system.debug('>>> SET : ' + selectedIds + ' Allready Has : '+a.id);
                }
            }
        }
        
        system.debug('>>> Selection Set :' + selectedIds);  
 
    }

    public void removeSelectedId(){
        if(selectionId != null && selectionId != ''){
            system.debug('>>> Removing From Set :' + selectionId);
            selectedIds.remove(selectionId);
            setHeaderValue();
        }
        else{
            system.debug('>>> Iterating Over Current Record set');
            for(sObject so : setCon.getRecords()){
                LDC_Account__c a = (LDC_Account__c)so;
                system.debug('>>> Checking for : ' + a.Id); 
                if(!selectedIds.contains(a.Id)){
                    system.debug('>>> SET : ' + selectedIds + ' Do Not Have : '+a.id + ' Ignoring.....');
                }
                else{
                    system.debug('>>> SET : ' + selectedIds + ' Has : '+a.id + ' Removing this');
                    selectedIds.remove(a.id);
                }
            }
        }
        system.debug('>>> Selection Set :' + selectedIds);
    }
 
    public Integer getSelectedCount(){
 
        return selectedIds.size();
 
    }
 
    public void doNext(){
 
        if(setCon.getHasNext()){
            setCon.next();            
            setHeaderValue();
        }
            
    }
 
    public void doPrevious(){
 
        if(setCon.getHasPrevious()){
            setCon.previous();        
            setHeaderValue();
        }
    }
 
    public List<ldcAccountWrapper> getLDCAccounts(){
 
        List<ldcAccountWrapper> lstLDCAccWrapper = new List<ldcAccountWrapper>();
 
        for(sObject so : setCon.getRecords()){
            LDC_Account__c a = (LDC_Account__c)so;
 
            ldcAccountWrapper ldcWapper = new ldcAccountWrapper(a,false);
            if(selectedIds.contains(a.Id)){
                ldcWapper.IsSelected=true;
            }
            else{
                ldcWapper.IsSelected=false;
            }
            lstLDCAccWrapper.add(ldcWapper);
        }
 
        return lstLDCAccWrapper;
 
    }
 
    public Boolean getHasPrevious(){
 
        return setCon.getHasPrevious();
 
    }
 
    public Boolean getHasNext(){
 
        return setCon.getHasNext();
 
    }
 
    public Integer getPageNumber(){
 
        return setCon.getPageNumber();
 
    }
 
    public Integer getTotalPages(){
 
        Decimal totalSize = setCon.getResultSize();
        Decimal pageSize = setCon.getPageSize();
 
        Decimal pages = totalSize/pageSize;
 
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }
    
    public void setHeaderValue(){
        resetHeader = true;
        for(sObject so : setCon.getRecords()){
            LDC_Account__c a = (LDC_Account__c)so;              
            if(!selectedIds.contains(a.Id)){
                resetHeader = false;
                break;      
            }
        }
        
    }
 
    public with sharing class ldcAccountWrapper{
 
        public LDC_Account__c ldcAcc{get;set;}
        public Boolean IsSelected{get;set;}
 
        public ldcAccountWrapper(LDC_Account__c a, Boolean s){
            ldcAcc=a;
            IsSelected=s;
        }
 
    }
}