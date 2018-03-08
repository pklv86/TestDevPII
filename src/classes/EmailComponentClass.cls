public  class EmailComponentClass
{
    public Id opptyId {get;set;}
    public List<Retail_Quote__c> getretailQuotes()
    {    
        List<Retail_Quote__c> retailQuoteList;
        retailQuoteList = [SELECT id, name, Notional_Value__c FROM Retail_Quote__c WHERE opportunity__c=: opptyId and Notional_Value__c > = 10000000];
        system.debug('============retailQuoteList===='+retailQuoteList);
        return retailQuoteList;
        
    }
}