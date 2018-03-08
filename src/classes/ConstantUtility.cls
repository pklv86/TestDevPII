/* 
 * Name: ConstantUtility
 * Type: Apex Class
 * Test Class: Covered under the respective main classes
 * Description:  This class define various constants used accross the project. 
 * Change History:
 *===================================================================================================================================
 * Version     Author                       Date             Description 
 * 1.0         Sreenivas Amirisetti         01/18/2016       1. Initial Version created
 */
public with sharing class ConstantUtility {
    public static final String ERR_NO_QUOTES = (label.No_Quotes_on_Opportunity !=null && label.No_Quotes_on_Opportunity != '')?label.No_Quotes_on_Opportunity:'Please add Quotes and request for price';
    public static final String ERR_PRICE_VALID = (label.Price_Still_Valid !=null && label.Price_Still_Valid != '')?label.Price_Still_Valid:'Price is still valid or waiting for Pricing System response';
    public static final String ERR_VALID_QUOTES_SUBMITTED = (label.Valid_Quotes_Submit !=null && label.Valid_Quotes_Submit != '')?label.Valid_Quotes_Submit:'All valid Quotes have been sent to Pricing System';
    public static final String ERR_INVALID_QUOTE_STATUS = (label.Invalid_Quote_Status !=null && label.Invalid_Quote_Status != '')?label.Invalid_Quote_Status:'Please add a Request Status to one of your Retail Quotes';
    public static final String ERR_CHECK_CREDIT_APPROVAL = (label.Credit_Check_Approval_Message !=null && label.Credit_Check_Approval_Message != '')?label.Credit_Check_Approval_Message:'Get the credit check approval before proceeding to creating an executable quote';
    public static final String ERR_NO_EXECUTABLE_QUOTES_AVAILABLE = (label.No_Quotes_available_for_Executable_Price !=null && label.No_Quotes_available_for_Executable_Price != '')?label.No_Quotes_available_for_Executable_Price:'Please add qualified quotes and then request for the Executable Price';
    public static final String STATUS_WAITING = 'Waiting on Load Data';
    public static final String STATUS_EXPIRED = 'Expired';
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_PRICING_COMPLETE = 'Pricing Complete';
    public static final String RT_INDICATIVE = 'Indicative';
    public static final String RT_EXECUTABLE = 'Executable';
    public static final String RT_OBJECT = 'Retail_Quote__c';
    public static final String RT_HIST_OBJECT = 'Retail_Quote_History__c';
    public static final string STATUS_SUCCESS='Success';
    public static final string STATUS_Failure='Failure';
    public static final string CUST_MUNI_REC_TYPE='Muni Agg Customer';
    public static final string CUST_CNI_REC_TYPE='C&I Customer';
    public static final string CUST_MASS_REC_TYPE='Mass Market Offer';
    
    public static Id getRecordTypeId(String sObj, String sRectypeName){
        List<RecordType> recTypeLst = [select id,name from RecordType where sobjectType =:sObj and name = :sRectypeName];
        return (!recTypeLst.isEmpty())?recTypeLst[0].id:null;
    }

    public static Id getRecordTypeIdbyName(string obj,String recTypeName){
        return Schema.getGlobalDescribe().get(obj).getDescribe().getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
    }
    
    public static String getObjectFieldsQuery(String selectedObject){
        String strQuery = ' Select ';
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
        
        for(String strField : fieldMap.keySet()){
            strQuery += strField +',';
        }
        
        strQuery = strQuery.substring(0, strQuery.length() - 1);
        
        if(selectedObject == ConstantUtility.RT_OBJECT){
            strQuery +=',Product__r.Name';  
        }
         
        return strQuery;        
    }
    
    public static sObject getObject(String sObjName, String objFields, ID objId){
        String strQuery = ' Select ';
        List<String> lstFields = new List<String>();
        lstFields = objFields.split(':');
        for(String strField : lstFields){
            strQuery += strField +',';
        }
        strQuery = strQuery.substring(0, strQuery.length() - 1);
        strQuery += ' FROM '+sObjName +' WHERE Id = :objId' ;
        
        List<sObject> lstObj = Database.query(strQuery);
        
        if(!lstObj.isEmpty()){
            return lstObj[0];
        }
        
        return null;
    }
    
    public static Boolean IsSobjectType(string objName,Id ObjId){
        return String.valueOf(ObjId.getSobjectType())==objName;
    }
    
    public static List<String> CheckDatabaseResults(Database.SaveResult[] results){
        List<string> errors=new List<string>();
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                Database.Error[] errs = result.getErrors();
                for(Database.Error err : errs){
                    System.debug(err.getStatusCode() + ' - ' + err.getMessage());
                    Errors.add(err.getMessage());
                   }
            }
        }
        return errors;
    }
}