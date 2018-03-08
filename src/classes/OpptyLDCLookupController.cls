/* 
 * Name: OpptyLDCLookupController
 * Type: Apex Class
 * Test Class: OpptyLDCLookupControllerTest
 * Description:  This class controls the custom Lookup for LDC Account. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti        01/15/2016       1. Initial Version created
 */
public with sharing class OpptyLDCLookupController {
    public Opportunity_LDC__c optyLDC {get;set;}
    public Opportunity oppRec;
    
    public LDC_Account__c account {get;set;} 
    public List<LDC_Account__c> results{get;set;}
    public string searchString{get;set;} 
    
    public OpptyLDCLookupController () {
      optyLDC = new Opportunity_LDC__c();
      List<Opportunity> lstOpp = [Select id, Name, AccountId, Service_Territory__c from Opportunity where id = :ApexPages.currentPage().getParameters().get('masterId')];
      if(!lstOpp.isEmpty()){
        oppRec = lstOpp[0];
        optyLDC.Opportunity__c = oppRec.id;   
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
        insert optyLDC;
        if(oppRec == null) new PageReference('/');
        return optyViewRedirect();
    } 
    
    private PageReference optyViewRedirect(){
        PageReference opptyPage = new ApexPages.StandardController(oppRec).view();
        opptyPage.setRedirect(true);
        return opptyPage;
    }
    
    public void setSearchParam() {
      account = new LDC_Account__c();     
      searchString = System.currentPageReference().getParameters().get('lksrch');
      runSearch();  
    }
    
    public PageReference search() {
      runSearch();
      return null;
    }
    
    private void runSearch() {
      results = performSearch(searchString);               
    } 
    
    // run the search and return the records found. 
    private List<LDC_Account__c> performSearch(string searchString) {
      String opptyId = System.currentPageReference().getParameters().get('oppID');
      if(opptyId != null){
          //String accId = [Select id,Name,AccountId from Opportunity where id =:opptyId].AccountId;
          Opportunity oppty = [SELECT Name,AccountId,Service_Territory__c FROM Opportunity WHERE Id =:opptyId LIMIT 1];
          //String soql = 'select Id, Name, LDC_Account_Number__c,  Service_Territory__c from LDC_Account__c where Account__c = :accId';
          String accId = oppty.AccountId;
          String sTerr = oppty.Service_Territory__c;
          String soql = 'select Id, Name, LDC_Account_Number__c,  Service_Territory__c from LDC_Account__c where Account__c = :accId AND Service_Territory__c = :sTerr';
          if(searchString != '' && searchString != null)
            soql = soql +  ' AND name LIKE \'%' + searchString +'%\'';
          soql = soql + ' Limit 25'; 
          return database.query(soql);
      }
      return null;  
    }
    
    public PageReference saveAccount() {
      insert account;
      account = new LDC_Account__c();
      return null;
    }
    
    public string getFormTag() {
      return System.currentPageReference().getParameters().get('frm');
    }
    
    public string getTextBox() {
      return System.currentPageReference().getParameters().get('txt');
    }
}