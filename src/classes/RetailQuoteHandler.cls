/* 
 * Name: RetailQuoteHandler
 * Type: Apex Class
 * Test Class: Covered under the respective main classes
 * Description:  This class contains the functions to assist with the Retail Quote realted modules. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         01/17/2016       1. Initial Version created
 */
public with sharing class RetailQuoteHandler {  
    
    public static List<Retail_Quote__c> cloneAndCreateQuoteHistory(List<Retail_Quote__c> lstRetQt, Set<Id> retQtToClone, String rtRecordType, String rtHistRecordType){
        Map<String, Schema.SObjectField> mapRetQtDescribe = schema.SObjectType.Retail_Quote__c.fields.getMap();
        Map<String, Schema.SObjectField> mapRetQtHistDescribe = schema.SObjectType.Retail_Quote_History__c.fields.getMap();
        List<Retail_Quote_History__c> lstRTQTHistToCreate = new List<Retail_Quote_History__c>();
        List<Retail_Quote__c> lstClonedRetQuotes = new List<Retail_Quote__c>();
        List<Retail_Quote__c> lstDeleteRetQuotes = new List<Retail_Quote__c>();
        ID rtRetQtId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_OBJECT,rtRecordType);
        ID rtRetQtHistId = ConstantUtility.getRecordTypeId(ConstantUtility.RT_HIST_OBJECT,rtHistRecordType);        
        
        for(Retail_Quote__c recRtQt : lstRetQt){
            Retail_Quote_History__c recRetQtHist = new Retail_Quote_History__c();
            //Loop through custom fields and copy to History record if matching field name is found
            for(String retQtField : mapRetQtDescribe.KeySet()){
                Schema.DescribeFieldResult describersult = mapRetQtDescribe.get(retQtField).getDescribe();
                if(describersult.isCustom() == false || describersult.isCreateable() == false){
                    continue;
                }
                else if(mapRetQtHistDescribe.containsKey(retQtField))
                {
                    recRetQtHist.put(retQtField, recRtQt.get(retQtField));
                }
            }
            //Add the standard fields to History record.
            recRetQtHist.Quote_Number__c = recRtQt.Name;
            recRetQtHist.RecordTypeId = rtRetQtHistId;
            
            lstRTQTHistToCreate.add(recRetQtHist);
            lstDeleteRetQuotes.add(recRtQt);

        }

        for(Retail_Quote__c rtq:[SELECT Id, Name, RecordTypeId, Product__c, Term__c, Opportunity__c, Utility_Settlement_Zone__c, ContractType__c, Payment_Terms__c, Start_Term__c, Margin__c, Margin_Allocation__c, Index_Margin__c, Index_Margin_Allocation__c, Broker_Fee__c, Broker_Fee_Allocation__c, Municipality_Fee__c, Municipality_Fee_Allocation__c, Marketing_Cost__c, Marketing_Cost_Allocation__c, Energy_Fixed__c, Voluntary_REC__c, Voluntary_REC_Generator_Type__c, Voluntary_REC_Geographic_Location__c, Off_Peak_Block_Size__c, On_Peak_Block_Size__c FROM Retail_Quote__c where Id in :retQtToClone]){
                Retail_Quote__c clonedRetQuote = rtq.clone(false, false, false, false);
                clonedRetQuote.Request_Status__c = ConstantUtility.STATUS_WAITING;
                clonedRetQuote.RecordTypeId = rtRetQtId;
                lstClonedRetQuotes.add(clonedRetQuote); 
        }
        
        if(!lstClonedRetQuotes.isEmpty()){
            //In future we can use the srList to log any faliures in a custom way if the need be.
            Database.SaveResult[] srList = Database.insert(lstClonedRetQuotes, false);
        }
        if(!lstRTQTHistToCreate.isEmpty()){
            //In future we can use the srList to log any faliures in a custom way if the need be.
            Database.SaveResult[] srList = Database.insert(lstRTQTHistToCreate, false);
        }
        if(!lstDeleteRetQuotes.isEmpty()){
            //In future we can use the srList to log any faliures in a custom way if the need be.
            Database.DeleteResult[] srList = Database.delete(lstDeleteRetQuotes, false);
        }
        return lstClonedRetQuotes;
    }   

}