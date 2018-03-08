/* 
* Name: EDIInboundHelper
* Type: Apex Class
* Test Class: Covered under the respective main classes
* Description:  This class contains the helper functions for generating VO's and make WS calls. 
* Change History:
*===================================================================================================================================
* Version     Author                       Date             Description 
* 1.0         KPMG                      02/10/2016       1. Initial Version created
* 1.1         Prasad                    08/17/2016       1. Included Service Start Date and Service End Date into change effective date based on enrollment or drop
* 1.2         Chaitanya Kurra           11/10/2016       1. Included Drop Dasr's untility initiated with SDP Number
*                                                        2. Included the multiple Account Exceptions
* 1.3         Chaitanya Kurra           12/2/2016        1. Included the field Most_Recent_DASR for SCR 1239 Support Utility Initiated EDI (GAAD)
* 1.4         Chaitanya Kurra           08/07/2017       1. Included the field XML_File_Name for T-000720 to capture EDI Response file Name
*/
public with sharing class EDIInboundHelper 
{
    
    public static void processInboundEnrollSuccess(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct, Map<String, Meter__c> meterNumMap, Service_Point__c tServPoint, List<Contract_LDC__c> lContLDCs,Map<string,id> LDCVendorMap)
    {
        
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        final set<string> SPLC = new set<string>{'RATE ZONE I','RATE ZONE II','RATE ZONE III'};
        List<EDIInboundWebService.MeterInfo> vMeterInfoList = vTranInfo.Meter;
        List<EDIInboundWebService.CustomerInfo> vCustomerInfoList = vTranInfo.Customer;
        EDIInboundWebService.CustomerInfo  vCustomerInfo = vCustomerInfoList != null && vCustomerInfoList.size() > 0 && vCustomerInfoList[0].Name_Qualifier != null && vCustomerInfoList[0].Name_Qualifier =='8R' ? vCustomerInfoList[0] : (vCustomerInfoList != null && vCustomerInfoList.size() >= 1 ? vCustomerInfoList[1] : null) ;
        //List<Contract_LDC__c> lLDContractLDC = new List<Contract_LDC__c>();
        if(tLDCAct != null){
            system.debug('LDC_Start_Date__c : '+tLDCAct.LDC_Start_Date__c);
            if(tLDCAct.LDC_Start_Date__c == null)
                tLDCAct.LDC_Start_Date__c = vAcctInfo != null && vAcctInfo.Service_Start_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_Start_Date) : tLDCAct.LDC_Start_Date__c;
            tLDCAct.Capacity_PLC2__c = tLDCAct.Capacity_PLC1__c;
            tLDCAct.Capacity_PLC2_End__c = tLDCAct.Capacity_PLC1_End_Date__c;
            tLDCAct.Capacity_PLC2_Start__c = tLDCAct.Capacity_PLC1_Start_Date__c;
            
            tLDCAct.Capacity_PLC1__c = vAcctInfo != null ? vAcctInfo.Capacity_Obligation_Quantity : null;
            tLDCAct.NSPL2_KW__c  = tLDCAct.NSPL1_KW__c;
            tLDCAct.NSPL2_Start_Date__c = tLDCAct.NSPL1_Start_Date__c;
            tLDCAct.NSPL2_End_Date__c = tLDCAct.NSPL1_End_Date__c;
            
            tLDCAct.NSPL1_KW__c  = vAcctInfo != null ? vAcctInfo.Transmission_Obligation_Quantity : null;
            
            
            String ldcBillCycle = vAcctInfo != null && vAcctInfo.LDC_Bill_Cycle != null ? vAcctInfo.LDC_Bill_Cycle.substring(0,2)  : vAcctInfo.LDC_Bill_Cycle;
            tLDCAct.Bill_Cycle__c = ldcBillCycle;
            tLDCAct.Enrolled__c = true;
            tLDCAct.Enrollment_Status__c = 'Accepted';
            
            if(vCustomerInfo != null && vCustomerInfo.Address_Line_1 != null){
                tLDCAct.Service_Street_1__c  = vCustomerInfo != null && vCustomerInfo.Address_Line_1 != null ? vCustomerInfo.Address_Line_1 : tLDCAct.Service_Street_1__c;
                tLDCAct.Service_Street_2__c = vCustomerInfo != null && vCustomerInfo.Address_Line_2 != null ? vCustomerInfo.Address_Line_2 : null;
                tLDCAct.Service_City__c   = vCustomerInfo != null&& vCustomerInfo.City_Name != null ? vCustomerInfo.City_Name : tLDCAct.Service_City__c;
                tLDCAct.Service_State__c  = vCustomerInfo != null && vCustomerInfo.State_Province_Code != null ? vCustomerInfo.State_Province_Code : tLDCAct.Service_State__c;
                tLDCAct.Service_Postal_Code__c   = vCustomerInfo != null && vCustomerInfo.Postal_Code_Zip != null ? vCustomerInfo.Postal_Code_Zip : tLDCAct.Service_Postal_Code__c;
                tLDCAct.Service_County__c   = vCustomerInfo != null && vCustomerInfo.Country_Code != null ? vCustomerInfo.Country_Code : tLDCAct.Service_County__c ;
            }
            
            tLDCAct.Name   = vCustomerInfo != null && vCustomerInfo.Customer_Name != null ? vCustomerInfo.Customer_Name : tLDCAct.Name;
            tLDCAct.Acct_ADU__c = vAcctInfo != null && vAcctInfo.Total_KWH_Quantity != null && string.isNotBlank(vAcctInfo.Number_Of_Months_Requested) && (Integer.valueof(vAcctInfo.Number_Of_Months_Requested.trim()) > 0)? (vAcctInfo.Total_KWH_Quantity/(Integer.valueof(vAcctInfo.Number_Of_Months_Requested.trim())*30000)) : (vAcctInfo != null&& vAcctInfo.Total_KWH_Quantity != null && vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity != null && vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity > 0 ? (vAcctInfo.Total_KWH_Quantity/(vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity*30000)) : tLDCAct.Acct_ADU__c);
            
            //Included For updating the LDC vendor mainly for AMeren Rate ZOnes I,II,and III
            if( vAcctInfo != null && vAcctInfo.Standard_Point_Location_Code !=null && LDCVendorMap.size()>0 && SPLC.contains(vAcctInfo.Standard_Point_Location_Code)){
                System.debug('*****ldc vendorbefore****'+tLDCAct.LDC_Vendor__c);
                tLDCAct.LDC_Vendor__c = LDCVendorMap.get(vAcctInfo.Standard_Point_Location_Code) != null ? LDCVendorMap.get(vAcctInfo.Standard_Point_Location_Code): tLDCAct.LDC_Vendor__c;
                System.debug('*****ldc vendor****'+tLDCAct.LDC_Vendor__c);
            }
            //Completed
            //below code commented for task # (SCR-1282)
            //tLDCAct.LDC_Account_Status__c ='ACTIVE';
            
            EDIInboundHelper.updateContractLDC(vTranInfo,tDASR,tLDCAct,lContLDCs);            
        }
        
        if(vMeterInfoList != null && vMeterInfoList.size() > 0 ){
            if(tServPoint == null || tServPoint.id == null){
                System.debug('\n tLDCAct.Id='+tLDCAct.Id);
                System.debug('\n tServPoint='+tServPoint);
                //tServPoint = new Service_Point__c();
                tServPoint.LDC_Account_Number__c = tLDCAct.Id;
                tServPoint.Service_Point_Number__c = IntegrationUtil.generateRandomString(18);//IntegrationUtil.generateDateTime(System.now());
            }
            System.debug('\n xxx tServPoint='+tServPoint);
            
            //Do we need to insert service point here or return and insert in web service class?
            
            //tMeterList = tMeterList == null ? new List<Meter__c>() : tMeterList;
            //Map<String, Meter__c> mMeter = tMeterList != null && tMeterList.size() > 0 ? EDIInboundHelper.mapMeterByMtrNum(tMeterList) : new Map<String, Meter__c>();
            Meter__c tInMeter;
            Meter__c allMeter = meterNumMap != null ? meterNumMap.get('ALL') : null;
            //Id servPntId = allMeter != null ? allMeter.Service_Point__c : null;
            boolean hasAllAndOneMeter = meterNumMap != null && meterNumMap.containsKey('ALL') && meterNumMap.size() == 1 ? true : false;
            //boolean hasAllAndGtOneMeter = mMeter != null && mMeter.containsKey('ALL') && mMeter.size() > 1 ? true : false;
            System.debug('\n meterNumMap='+meterNumMap);
            
            for(EDIInboundWebService.MeterInfo tMeter: vMeterInfoList){
                System.debug('\n meterNumMap='+meterNumMap);
                //tInMeter = mMeter != null && mMeter.containsKey(tMeter.Meter_Number) ? mMeter.get(tMeter.Meter_Number) : null;
                tInMeter = meterNumMap != null ? meterNumMap.get(tMeter.Meter_Number) : null;
                System.debug('\n 11 tMeter.Meter_Number='+tMeter.Meter_Number);
                System.debug('\n 11 tMeter='+tMeter);
                System.debug('\n 11 tInMeter='+tInMeter);
                if(tInMeter == null || tMeter.Meter_Number == null || !tMeter.Meter_Number.equalsIgnoreCase('ALL')){ 
                    tInMeter = new Meter__c();
                }
                if(tServPoint != null && tServPoint.id != null){
                    tInMeter.Service_Point__c = tServPoint.id;
                }
                tInMeter.Meter_Number__c = tMeter.Meter_Number;
                tInMeter.Old_Meter_Number__c = tMeter.Old_Meter_Number != null ? tMeter.Old_Meter_Number : null;
                tInMeter.Load_Profile__c = tMeter.Load_Profile_Description != null ? tMeter.Load_Profile_Description : null;
                tInMeter.LDC_Rate_Class__c =  tMeter.LDC_Rate_Class != null ? tMeter.LDC_Rate_Class : null;
                tInMeter.LDC_Meter_Cycle__c =  tMeter.LDC_Meter_Cycle != null ? tMeter.LDC_Meter_Cycle : null;
                tInMeter.Meter_Type_Code__c =  tMeter.Meter_Type_Code != null ? tMeter.Meter_Type_Code : null;
                tInMeter.Service_Point_Number__c = tMeter.SDP_Number != null ? tMeter.SDP_Number : null;
                tInMeter.LDC_Rate_Subclass__c = tMeter.LDC_Rate_Subclass!= null ? tMeter.LDC_Rate_Subclass: null;
                tInMeter.Delivery_Voltage__c = tMeter.Delivery_Voltage != null ? tMeter.Delivery_Voltage : null ;   
                tInMeter.Meter_Multiplier_Quantity__c =  tMeter.Meter_Multiplier_Quantity != null ? tMeter.Meter_Multiplier_Quantity : null;
                tInMeter.Number_Of_Dials_Quantity__c =  tMeter.Number_Of_Dials_Quantity != null ? tMeter.Number_Of_Dials_Quantity : null;
                tInMeter.Time_Of_Use_Metering__c =  tMeter.Time_Of_Use_Metering != null ? ''+tMeter.Time_Of_Use_Metering : (tMeter.Measurement_Reference_Code != null ? ''+tMeter.Measurement_Reference_Code :null);
                tInMeter.Meter_Maintenance_Code__c =  tMeter.Meter_Maintenance_Code != null ? tMeter.Meter_Maintenance_Code : null;
                if(tDASR != null && tmeter.Type_Of_Service_Indicator != null ){
                    tDASR.Net_Meter_Type__c = tmeter.Type_Of_Service_Indicator;
                }
                meterNumMap.put(tInMeter.Meter_Number__c, tInMeter);
                System.debug('\n 11 meterNumMap='+meterNumMap);
            }
        }   
        
        if(tDASR != null){
            tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
            tDASR.Change_Effective_Date__c= vAcctInfo != null && vAcctInfo.Service_Start_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_Start_Date) : tLDCAct.LDC_Start_Date__c;
            tDASR.Capacity_Obligation__c = vAcctInfo != null && vAcctInfo.Capacity_Obligation_Quantity != null ? vAcctInfo.Capacity_Obligation_Quantity : null ;
            tDASR.Transmission_Obligation_Quantity__c = vAcctInfo != null && vAcctInfo.Transmission_Obligation_Quantity != null ? vAcctInfo.Transmission_Obligation_Quantity : null ;
            tDASR.Most_Recent_GAAD__c = TRUE;
            //IL changes Included
            tDASR.Old_LDC_Account_Number__c = vAcctInfo != null && vAcctInfo.Old_LDC_Account_Number !=null ? vAcctInfo.Old_LDC_Account_Number : null ;
            
            for(Bill_Method__c bml : Bill_Method__c.getall().values()){   
                if(bml.Bill_Calculator__c == vAcctInfo.Bill_Calculator && bml.Bill_Presenter__c == vAcctInfo.Bill_Presenter && bml.Payment_Arrangement_Code__c == vAcctInfo.Payment_Arrangement_Code){
                    tDASR.Bill_Method__c = bml.name;
                }
                else if (bml.Bill_Calculator__c == vAcctInfo.Bill_Calculator && bml.Bill_Presenter__c == vAcctInfo.Bill_Presenter)
                    tDASR.Bill_Method__c = bml.name;
            }
            
            tDASR.LDC_Bill_Cycle__c = vAcctInfo != null && vAcctInfo.LDC_Bill_Cycle !=null ? vAcctInfo.LDC_Bill_Cycle : null ;
            tDASR.LDC_Budget_Billing_Status__c = vAcctInfo != null && vAcctInfo.LDC_Budget_Billing_Status !=null ? vAcctInfo.LDC_Budget_Billing_Status : null ;
            tDASR.Standard_Point_Location_Code__c = vAcctInfo != null && vAcctInfo.Standard_Point_Location_Code !=null ? vAcctInfo.Standard_Point_Location_Code : null ;
            //tDASR.Interval_Level_Indicator__c = vAcctInfo != null && vAcctInfo.Interval_Level_Indicator != null ? vAcctInfo.Interval_Level_Indicator : null ;
            tDASR.Service_Relationship__c = vAcctInfo != null && vAcctInfo.Service_Relationship != null ? vAcctInfo.Service_Relationship : null ;
            tDASR.Number_Of_Months_Usage_Quantity__c = vAcctInfo != null && string.isNotBlank(vAcctInfo.Number_Of_Months_Requested) ? Integer.valueof(vAcctInfo.Number_Of_Months_Requested.trim()) : (vAcctInfo != null && vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity != null ? vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity : null) ;
            tDASR.POR_Group__c = vAcctInfo != null&& vAcctInfo.POR_Group != null ? vAcctInfo.POR_Group : null;
            tDASR.CP_Node__c = vAcctInfo != null&& vAcctInfo.CP_Node != null ? vAcctInfo.CP_Node : null;
            tDASR.Supply_Group__c = vAcctInfo != null&& vAcctInfo.Supply_Group != null ? vAcctInfo.Supply_Group : null;
            //tDaSR.Net_Meter_Type__c = vMeterInfoList != null ? vMeterInfoList[0].Type_Of_Service_Indicator : null;
            tDaSr.Special_Meter_Configuration__c = vAcctInfo != null&& vAcctInfo.Special_Meter_Configuration != null ? vAcctInfo.Special_Meter_Configuration : null;
            tDASR.Peak_Demand__c = vAcctInfo != null&& vAcctInfo.Peak_Demand_Usage_Quantity != null ? vAcctInfo.Peak_Demand_Usage_Quantity : null;
            tDASR.Total_KWH_Quantity__c = vAcctInfo != null&& vAcctInfo.Total_KWH_Quantity != null ? vAcctInfo.Total_KWH_Quantity : null;
            tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
            
            if(vCustomerInfo.Address_Line_1 != null){
                tDASR.Address_Line_1__c  = vCustomerInfo != null && vCustomerInfo.Address_Line_1 != null ? vCustomerInfo.Address_Line_1 : null;
                tDASR.Address_Line_2__c = vCustomerInfo != null && vCustomerInfo.Address_Line_2 != null ? vCustomerInfo.Address_Line_2 : null;
                tDASR.Phone_Number__c = vCustomerInfo != null &&vCustomerInfo.Phone_Number != null  ? vCustomerInfo.Phone_Number : null;
                tDASR.City_Name__c   = vCustomerInfo != null&& vCustomerInfo.City_Name != null ? vCustomerInfo.City_Name : null;
                tDASR.State_Province_Code__c  = vCustomerInfo != null && vCustomerInfo.State_Province_Code != null ? vCustomerInfo.State_Province_Code : null;
                tDASR.Postal_Code_Zip__c   = vCustomerInfo != null && vCustomerInfo.Postal_Code_Zip != null ? vCustomerInfo.Postal_Code_Zip : null;
                tDASR.Country_Code__c   = vCustomerInfo != null && vCustomerInfo.Country_Code != null ? vCustomerInfo.Country_Code : null;
                tDASR.Customer_Name__c   = vCustomerInfo != null && vCustomerInfo.Customer_Name != null ? vCustomerInfo.Customer_Name : null;
                tDASR.Name_Qualifier__c   = vCustomerInfo != null && vCustomerInfo.Name_Qualifier!= null ? vCustomerInfo.Name_Qualifier : null;
            }
            //IL changes Included
            upDASRReqSuccess(tDASR);
            //tDASR.Integration_Status__c  = 'Completed';
            //tDASR.Integration_Message__c = '';
            //tDASR.Accepted__c = true;
            //tDASR.Last_EDI_Update_Date__c = System.now();
        }
    }
    
    public static void processInboundEnrollFail(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct)
    {
        if(tLDCAct != null){
            //tLDCAct.Enrolled__c = false;
            tLDCAct.Enrollment_Status__c = 'Error';
            tLDCAct.LDC_Account_Status__c ='REJECTED';            
        }
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        List<EDIInboundWebService.AccountExceptionInfo> vAcctExcpInfo = vTranInfo.Account_Exception_Info;
        EDIInboundWebService.AccountExceptionInfo vFirstExcpInfo = vAcctExcpInfo != null && vAcctExcpInfo.size() > 0 ? vAcctExcpInfo[0]: null; 
        ChangeReason__c chngRsn =  vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vFirstExcpInfo.Reason_Code) : null;        
        if(tDASR != null){
            tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
            tDASR.Integration_Status__c  = 'Failed';
            //tDASR.Integration_Message__c = '';
            tDASR.Last_EDI_Update_Date__c = System.now();
            tDASR.Rejected__c  = true;
            tDASR.Accepted__c  = false;
            tDASR.Change_Reason_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? vFirstExcpInfo.Reason_Code : chngRsn.Reason_Code__c;
            tDASR.Exception_Type_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Exception_Type_Code != null ? vFirstExcpInfo.Exception_Type_Code : chngRsn.Exception_Type_Code__c;
            tDASR.Reason_Rejected__c  = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : null;
            //IL changes Included
            tDASR.Old_LDC_Account_Number__c = vAcctInfo != null && vAcctInfo.OLD_LDC_Account_Number != null ? vAcctInfo.Old_LDC_Account_Number : null ;
            for(Bill_Method__c bml : Bill_Method__c.getall().values()){
                if(bml.Bill_Calculator__c == vAcctInfo.Bill_Calculator && bml.Bill_Presenter__c == vAcctInfo.Bill_Presenter && bml.Payment_Arrangement_Code__c == vAcctInfo.Payment_Arrangement_Code){
                    tDASR.Bill_Method__c = bml.name;
                }
                else if (bml.Bill_Calculator__c == vAcctInfo.Bill_Calculator && bml.Bill_Presenter__c == vAcctInfo.Bill_Presenter)
                    tDASR.Bill_Method__c = bml.name;
            }       
            
            tDASR.LDC_Bill_Cycle__c = vAcctInfo != null && vAcctInfo.LDC_Bill_Cycle !=null ? vAcctInfo.LDC_Bill_Cycle : null ;
            tDASR.LDC_Budget_Billing_Status__c = vAcctInfo != null && vAcctInfo.LDC_Budget_Billing_Status !=null ? vAcctInfo.LDC_Budget_Billing_Status : null ;
            tDASR.Standard_Point_Location_Code__c = vAcctInfo != null && vAcctInfo.Standard_Point_Location_Code !=null ? vAcctInfo.Standard_Point_Location_Code : null ;
            //tDASR.Interval_Level_Indicator__c = vAcctInfo != null && vAcctInfo.Interval_Level_Indicator != null ? vAcctInfo.Interval_Level_Indicator : null ;
            tDASR.Service_Relationship__c = vAcctInfo != null && vAcctInfo.Service_Relationship != null ? vAcctInfo.Service_Relationship : null ;
            boolean b1 = vAcctInfo.Number_Of_Months_Requested != null ? true : false;
            boolean b2 = string.isNotBlank(vAcctInfo.Number_Of_Months_Requested);
            system.debug('test : '+vAcctInfo.Number_Of_Months_Requested+b1+b2+' : '+vAcctInfo);
            tDASR.Number_Of_Months_Usage_Quantity__c = (vAcctInfo != null && string.isNotBlank(vAcctInfo.Number_Of_Months_Requested)) ? Integer.valueof(vAcctInfo.Number_Of_Months_Requested.trim()) : (vAcctInfo != null && vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity != null ? vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity : null) ;
            tDASR.POR_Group__c = vAcctInfo != null && vAcctInfo.POR_Group != null ? vAcctInfo.POR_Group : null;
            tDASR.CP_Node__c = vAcctInfo != null && vAcctInfo.CP_Node != null ? vAcctInfo.CP_Node : null;
            tDASR.Supply_Group__c = vAcctInfo != null && vAcctInfo.Supply_Group != null ? vAcctInfo.Supply_Group : null;
            tDASR.Eligible_Switch_Date__c =  vAcctInfo != null && vAcctInfo.Eligible_Switch_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Eligible_Switch_Date) : null;
            tDaSr.Special_Meter_Configuration__c = vAcctInfo != null && vAcctInfo.Special_Meter_Configuration != null ? vAcctInfo.Special_Meter_Configuration : null;
            tDASR.Peak_Demand__c = vAcctInfo != null && vAcctInfo.Peak_Demand_Usage_Quantity != null ? vAcctInfo.Peak_Demand_Usage_Quantity : null;
            tDASR.Total_KWH_Quantity__c = vAcctInfo != null && vAcctInfo.Total_KWH_Quantity != null ? vAcctInfo.Total_KWH_Quantity : null;
            tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
            //IL changes Included
        }
        
    }
    //Added for Dynegy Initiated GAAR
    public static void processInboundReinstateSuccess(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct)
    {
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
     // List<EDIInboundWebService.MeterInfo> vMeterInfoList = vTranInfo.Meter;
        List<EDIInboundWebService.MeterExceptionInfo> vMeterExcpInfoList = vTranInfo.Meter_Exception_Info;
        EDIInboundWebService.MeterExceptionInfo vFirstMetrExcpInfo = vMeterExcpInfoList != null && vMeterExcpInfoList.size() > 0 ? vMeterExcpInfoList[0]: null; 
        List<EDIInboundWebService.AccountExceptionInfo> vAcctExcpInfo = vTranInfo.Account_Exception_Info;
        EDIInboundWebService.AccountExceptionInfo vFirstExcpInfo = vAcctExcpInfo != null && vAcctExcpInfo.size() > 0 ? vAcctExcpInfo[0]: null; 
        ChangeReason__c chngRsn =  vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vFirstExcpInfo.Reason_Code) : null;
        if(tDASR != null){
            tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
            tDASR.Change_Effective_Date__c = vAcctInfo.Change_Effective_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Change_Effective_Date) : tDASR.Change_Effective_Date__c;
         // tDASR.Integration_Status__c  = 'Completed';
            if(vFirstExcpInfo != null){
                tDASR.Change_Reason_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? vFirstExcpInfo.Reason_Code : (chngRsn.Reason_Code__c != null ? chngRsn.Reason_Code__c : null) ;
                tDASR.Exception_Type_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Exception_Type_Code != null ? vFirstExcpInfo.Exception_Type_Code : (chngRsn.Exception_Type_Code__c != null ? chngRsn.Exception_Type_Code__c : null);
                tDASR.Utility_Initiated_Change_Reason_Activity__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Reason_Description != null ? vFirstMetrExcpInfo.Reason_Description : null);
             }
         // tDASR.Integration_Message__c = '';
         // tDASR.Accepted__c = true;
            tDASR.Last_EDI_Update_Date__c = System.now();
            tDASR.Status_Reason__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : null ;
            tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
         // tDASR.Meter_Number__c  = vFirstMetrExcpInfo != null ? vFirstMetrExcpInfo.Meter_Number: null;
        
            upDASRReqSuccess(tDASR);
        }
    }
    
    public static void processInboundReinstateFail(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct)
    {
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
     // List<EDIInboundWebService.MeterInfo> vMeterInfoList = vTranInfo.Meter;
        List<EDIInboundWebService.MeterExceptionInfo> vMeterExcpInfoList = vTranInfo.Meter_Exception_Info;
        EDIInboundWebService.MeterExceptionInfo vFirstMetrExcpInfo = vMeterExcpInfoList != null && vMeterExcpInfoList.size() > 0 ? vMeterExcpInfoList[0]: null; 
        List<EDIInboundWebService.AccountExceptionInfo> vAcctExcpInfo = vTranInfo.Account_Exception_Info;
        EDIInboundWebService.AccountExceptionInfo vFirstExcpInfo = vAcctExcpInfo != null && vAcctExcpInfo.size() > 0 ? vAcctExcpInfo[0]: null; 
        ChangeReason__c chngRsn =  vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vFirstExcpInfo.Reason_Code) : null;
        if(tDASR != null){
            tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
        //  tDASR.Change_Effective_Date__c = vAcctInfo.Change_Effective_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Change_Effective_Date) : tDASR.Change_Effective_Date__c;
            tDASR.Change_Reason_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? vFirstExcpInfo.Reason_Code : (chngRsn.Reason_Code__c != null ? chngRsn.Reason_Code__c : null);
            tDASR.Integration_Status__c  = 'Failed';
            tDASR.Exception_Type_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Exception_Type_Code != null ? vFirstExcpInfo.Exception_Type_Code : (chngRsn.Exception_Type_Code__c != null ? chngRsn.Exception_Type_Code__c: null);
        //  tDASR.Utility_Initiated_Change_Reason_Activity__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Reason_Description != null ? vFirstMetrExcpInfo.Reason_Description : null);
            tDASR.Rejected__c  = true;
            tDASR.Reason_Rejected_Desc__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : null ;
        //  tDASR.Integration_Message__c = '';
            tDASR.Accepted__c = false;
            tDASR.Last_EDI_Update_Date__c = System.now();
            tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
        }
    }
    
    public static void processInboundChngSuccess(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct, Map<String, Meter__c> meterNumMap, Service_Point__c tServPoint)
    {
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        List<EDIInboundWebService.MeterInfo> vMeterInfoList = vTranInfo.Meter;
        
        if(tLDCAct != null){
            tLDCAct.Rate_Code__c = tDASR.Rate_Code__c != null ? tDASR.Rate_Code__c : tLDCAct.Rate_Code__c;
        }
        
        if(tDASR != null){
            tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
            tDASR.Change_Effective_Date__c = vAcctInfo.Change_Effective_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Change_Effective_Date) : tDASR.Change_Effective_Date__c;
            tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
            tDASR.Most_Recent_GAAD__c = TRUE;
            upDASRReqSuccess(tDASR);
            //tDASR.Integration_Status__c  = 'Completed';
            //tDASR.Integration_Message__c = '';
            //tDASR.Accepted__c = true;
            //tDASR.Last_EDI_Update_Date__c = System.now();
        }
    }
    
    public static void processInboundChngFail(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct)
    {
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        List<EDIInboundWebService.AccountExceptionInfo> vAcctExcpInfo = vTranInfo.Account_Exception_Info;
        EDIInboundWebService.AccountExceptionInfo vFirstExcpInfo = vAcctExcpInfo != null && vAcctExcpInfo.size() > 0 && vAcctExcpInfo[0].Exception_Type_Code != null && (vAcctExcpInfo[0].Exception_Type_Code == 'CH') ? vAcctExcpInfo[0] : (((vAcctExcpInfo != null && vAcctExcpInfo.size() > 1 && vAcctExcpInfo[1].Exception_Type_Code != null) && (vAcctExcpInfo[1].Exception_Type_Code == 'CH')) ? vAcctExcpInfo[1]: null);
        EDIInboundWebService.AccountExceptionInfo vSecondExcpInfo = vAcctExcpInfo != null && vAcctExcpInfo.size() > 0 && vAcctExcpInfo[0].Exception_Type_Code != null && (vAcctExcpInfo[0].Exception_Type_Code == 'RJ') ? vAcctExcpInfo[0] : (vAcctExcpInfo != null && vAcctExcpInfo.size() > 1 && vAcctExcpInfo[1].Exception_Type_Code != null && (vAcctExcpInfo[1].Exception_Type_Code == 'RJ') ? vAcctExcpInfo[1]: null);
        ChangeReason__c chngRsn =  vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vFirstExcpInfo.Reason_Code) : null;        
        if(tDASR != null){
            tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
            tDASR.Integration_Status__c  = 'Failed';
            //tDASR.Integration_Message__c = '';
            tDASR.Last_EDI_Update_Date__c = System.now();
            tDASR.Rejected__c  = true;
            tDASR.Accepted__c  = false;
            //IL changes Included
            tDASR.Eligible_Switch_Date__c =  vAcctInfo != null && vAcctInfo.Eligible_Switch_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Eligible_Switch_Date) : null;
            //IL changes Included
            tDASR.Change_Reason_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? vFirstExcpInfo.Reason_Code : (chngRsn != null ? chngRsn.Reason_Code__c : null);
            tDASR.Exception_Type_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Exception_Type_Code != null ? vFirstExcpInfo.Exception_Type_Code : (chngRsn != null ? chngRsn.Exception_Type_Code__c : null);
            tDASR.Reason_Rejected__c  = vSecondExcpInfo != null && vSecondExcpInfo.Reason_Code != null ? vSecondExcpInfo.Reason_Code : null;
            tDASR.Reason_Rejected_Desc__c = vSecondExcpInfo != null && vSecondExcpInfo.Reason_Description != null ? vSecondExcpInfo.Reason_Description : null;
            tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
        }
    }
    public static void processInboundDropSuccess(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct)
    {
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        if(tDASR != null){
            tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
            tDASR.Integration_Status__c  = 'Complete';
            tDASR.Integration_Message__c = '';
            tDASR.Accepted__c = true;
            tDASR.Rejected__c  = false;
            tDASR.Last_EDI_Update_Date__c = System.now();
            tDASR.Most_Recent_GAAD__c = TRUE;
            tDasr.Change_Effective_Date__c = vAcctinfo != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_End_Date) : system.today();
            tDasr.Drop_Date__c = vAcctinfo != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_End_Date) : system.today();
            tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
        }
    }
    
    public static void processInboundDropFail(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct)
    {
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        List<EDIInboundWebService.AccountExceptionInfo> vAcctExcpInfo = vTranInfo.Account_Exception_Info;
        EDIInboundWebService.AccountExceptionInfo vFirstExcpInfo = vAcctExcpInfo != null && vAcctExcpInfo.size() > 0 ? vAcctExcpInfo[0]: null; 
        ChangeReason__c chngRsn =  vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vFirstExcpInfo.Reason_Code) : null;        
        if(tDASR != null){
            tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
            tDASR.Integration_Status__c  = 'Failed';
            //tDASR.Integration_Message__c = '';
            tDASR.Last_EDI_Update_Date__c = System.now();
            tDASR.Rejected__c  = true;
            tDASR.Accepted__c  = false;
            tDASR.Change_Reason_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? vFirstExcpInfo.Reason_Code : chngRsn.Reason_Code__c;
            tDASR.Exception_Type_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Exception_Type_Code != null ? vFirstExcpInfo.Exception_Type_Code : chngRsn.Exception_Type_Code__c;
            tDASR.Reason_Rejected__c  = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : null;
            tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
        }
    }
    
    public static void processInboundDropReq(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct, List<Meter__c> tMeterList, Service_Point__c tServPoint, List<Vendor_Meter__c> lstVenMeter)
    {
        if(tLDCAct == null){
            return;
        }
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        List<EDIInboundWebService.MeterInfo> vMeterInfoList = vTranInfo.Meter;
        List<EDIInboundWebService.CustomerInfo> vCustomerInfoList = vTranInfo.Customer;
        //List<EDIInboundWebService.OrganizationInfo> vOrganizationInfolist = vTranInfo.Organization;
        //EDIInboundWebService.OrganizationInfo vOrganizationInfo1 = vOrganizationInfolist != null && vOrganizationInfolist.size() > 0 && vOrganizationInfolist[0].Organization_Identifier_Code == 'SJ' ? vOrganizationInfolist[0] : (vOrganizationInfolist != null && vOrganizationInfolist.size()>=1 && vOrganizationInfolist[1].Organization_Identifier_Code == 'SJ'? vOrganizationInfolist[1]: null);
        //EDIInboundWebService.OrganizationInfo vOrganizationInfo2 = vOrganizationInfolist != null && vOrganizationInfolist.size() >= 1 && vOrganizationInfolist[1].Organization_Identifier_Code == '8S' ? vOrganizationInfolist[1] : (vOrganizationInfolist != null && vOrganizationInfolist.size()>0 && vOrganizationInfolist[0].Organization_Identifier_Code == '8S'? vOrganizationInfolist[0]: null);
        EDIInboundWebService.CustomerInfo  vCustomerInfo = vCustomerInfoList != null && vCustomerInfoList.size() > 0 && vCustomerInfoList[0].Name_Qualifier != null && vCustomerInfoList[0].Name_Qualifier =='BT' ? vCustomerInfoList[0] : (vCustomerInfoList != null && vCustomerInfoList.size() >= 1 ? vCustomerInfoList[0] : null) ;
        List<EDIInboundWebService.AccountExceptionInfo> vAcctExcpInfoList = vTranInfo.Account_Exception_Info;
        EDIInboundWebService.AccountExceptionInfo vFirstExcpInfo = vAcctExcpInfoList != null && vAcctExcpInfoList.size() > 0 ? vAcctExcpInfoList[0]: null; 
        
        List<EDIInboundWebService.MeterExceptionInfo> vMeterExcpInfoList = vTranInfo.Meter_Exception_Info;
        EDIInboundWebService.MeterExceptionInfo vFirstMetrExcpInfo = vMeterExcpInfoList != null && vMeterExcpInfoList.size() > 0 ? vMeterExcpInfoList[0]: null; 
        
        ChangeReason__c chngRsn =  vAcctInfo != null && vAcctInfo.Drop_Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vAcctInfo.Drop_Reason_Code) : null;        
        System.debug('\n drop inbound='+chngRsn);    
        //Set DASR Request
        if(tDASR == null){
            tDASR = new DASR_Request__c();
        }
        tDASR.DASR_Type__c   = 'GAAD';
        tDASR.Integration_Status__c  = 'Complete';
        tDASR.Dynegy_Initiated__c = false;
        tDASR.DASR_Submit_Date__c = System.today();
        tDASR.Billing_Entity__c = 'Dynegy';
        
        
        tDASR.Change_Effective_Date__c = vAcctInfo.Service_End_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_End_Date) : System.today();
        tDASR.Line_Transaction_Id__c = vTranInfo != null && vTranInfo.Transaction_Info != null && vTranInfo.Transaction_Info.Line_Transaction_ID != null ? vTranInfo.Transaction_Info.Line_Transaction_ID : null;
        tDASR.Last_EDI_Update_Date__c = System.now();
        tDASR.Sender_Transaction_Id__c = vAcctInfo != null ?  vAcctInfo.Sender_Transaction_ID: null;
        
        //tDASR.Change_Reason_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? vFirstExcpInfo.Reason_Code : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Reason_Code != null ? vFirstMetrExcpInfo.Reason_Code  : null);
        //tDASR.Exception_Type_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Exception_Type_Code != null ? vFirstExcpInfo.Exception_Type_Code : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Exception_Type_Code != null ? vFirstMetrExcpInfo.Exception_Type_Code  : null);
        //tDASR.Reason_Rejected__c  = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : null;
        tDASR.Drop_Reason_Code__c = vAcctInfo != null && vAcctInfo.Drop_Reason_Code != null ? vAcctInfo.Drop_Reason_Code : null;
        //tDASR.Drop_Reason__c = vAcctInfo != null && vAcctInfo.Drop_Reason_Description != null ? vAcctInfo.Drop_Reason_Description : null;
        tDASR.Drop_Reason__c = chngRsn != null ? chngRsn.Reason_Value__c : null;
        
        tDASR.Drop_Reason__c = tDASR.Drop_Reason__c == null || tDASR.Drop_Reason__c == '' ? vAcctInfo.Drop_Reason_Description  : tDASR.Drop_Reason__c;
        tDASR.Number_Of_Months_Usage_Quantity__c  = vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity;
        tDASR.Total_KWH_Quantity__c = vAcctInfo.Total_KWH_Quantity;
        
        tDASR.LDC_Bill_Cycle__c = vAcctInfo.LDC_Bill_Cycle;
        tDASR.LDC_Account_Number__c  = vAcctInfo.LDC_Account_Number != null ? vAcctInfo.LDC_Account_Number : vAcctInfo.SDP_Number;
        tDASR.Old_LDC_Account_Number__c = vAcctInfo.OLD_LDC_Account_Number != null ? vAcctInfo.OLD_LDC_Account_Number : null;
        tDASR.ESP_Account_Number__c = vAcctInfo.ESP_Account_Number;
        tDASR.Customer_Name__c   = vCustomerInfo != null ? vCustomerInfo.Customer_Name : null;
        tDASR.Name_Qualifier__c   = vCustomerInfo != null ? vCustomerInfo.Name_Qualifier : null;
        tDASR.Service_End_Date__c = vAcctInfo.Service_End_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_End_Date): System.today();
        tDASR.Drop_Date__c = tDASR.Service_End_Date__c;
        tDASR.Most_Recent_GAAD__c = TRUE;
        tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
        //tDASR.DROP_Transaction_Type__c = vTranInfo != null && vTranInfo.Transaction_Info != null && vTranInfo.Transaction_Info.Transaction_Type_Code != null ? vTranInfo.Transaction_Info.Transaction_Type_Code : null;
        //tDASR.RecipientDUNS__c = vOrganizationInfo2.Organization_DUNS;
        //tDASR.RecipientName__c = vOrganizationInfo2.Organization_Name;
        //tDASR.Originating_Name__c = vOrganizationInfo1.Organization_Name;
        //tDASR.Originating_DUNS__c = vOrganizationInfo1.Organization_DUNS;
        tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
    }
    
    public static void processInboundHistoryReq(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct, List<Meter__c> tMeterList, Service_Point__c tServPoint, List<Vendor_Meter__c> lstVenMeter)
    {
        if(tLDCAct == null){
            return;
        }
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        List<EDIInboundWebService.MeterInfo> vMeterInfoList = vTranInfo.Meter;
        List<EDIInboundWebService.CustomerInfo> vCustomerInfoList = vTranInfo.Customer;
        //List<EDIInboundWebService.OrganizationInfo> vOrganizationInfolist = vTranInfo.Organization;
        //EDIInboundWebService.OrganizationInfo vOrganizationInfo1 = vOrganizationInfolist != null && vOrganizationInfolist.size() > 0 && vOrganizationInfolist[0].Organization_Identifier_Code == 'SJ' ? vOrganizationInfolist[0] : (vOrganizationInfolist != null && vOrganizationInfolist.size()>=1 && vOrganizationInfolist[1].Organization_Identifier_Code == 'SJ'? vOrganizationInfolist[1]: null);
        //EDIInboundWebService.OrganizationInfo vOrganizationInfo2 = vOrganizationInfolist != null && vOrganizationInfolist.size() >= 1 && vOrganizationInfolist[1].Organization_Identifier_Code == '8S' ? vOrganizationInfolist[1] : (vOrganizationInfolist != null && vOrganizationInfolist.size()>0 && vOrganizationInfolist[0].Organization_Identifier_Code == '8S'? vOrganizationInfolist[0]: null);
        EDIInboundWebService.CustomerInfo  vCustomerInfo = vCustomerInfoList != null && vCustomerInfoList.size() > 0 && vCustomerInfoList[0].Name_Qualifier != null && vCustomerInfoList[0].Name_Qualifier =='BT' ? vCustomerInfoList[0] : (vCustomerInfoList != null && vCustomerInfoList.size() >= 1 ? vCustomerInfoList[0] : null) ;
        List<EDIInboundWebService.AccountExceptionInfo> vAcctExcpInfoList = vTranInfo.Account_Exception_Info;
        EDIInboundWebService.AccountExceptionInfo vFirstExcpInfo = vAcctExcpInfoList != null && vAcctExcpInfoList.size() > 0 ? vAcctExcpInfoList[0]: null; 
        
        List<EDIInboundWebService.MeterExceptionInfo> vMeterExcpInfoList = vTranInfo.Meter_Exception_Info;
        EDIInboundWebService.MeterExceptionInfo vFirstMetrExcpInfo = vMeterExcpInfoList != null && vMeterExcpInfoList.size() > 0 ? vMeterExcpInfoList[0]: null; 
        
        
        ChangeReason__c chngRsn =  vAcctInfo != null && vAcctInfo.Drop_Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vAcctInfo.Drop_Reason_Code) : null;        
        System.debug('\n drop inbound='+chngRsn);    
        //Set DASR Request
        if(tDASR == null){
            tDASR = new DASR_Request__c();
        }
        tDASR.DASR_Type__c   = 'GAAH';
        tDASR.Integration_Status__c  = 'Complete';
        tDASR.Dynegy_Initiated__c = false;
        tDASR.DASR_Submit_Date__c = System.today();
        tDASR.Billing_Entity__c = 'Dynegy';
        
        
        tDASR.Change_Effective_Date__c = vAcctInfo.Service_End_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_End_Date) : System.today();
        tDASR.Line_Transaction_Id__c = vTranInfo != null && vTranInfo.Transaction_Info != null && vTranInfo.Transaction_Info.Line_Transaction_ID != null ? vTranInfo.Transaction_Info.Line_Transaction_ID : null;
        tDASR.Last_EDI_Update_Date__c = System.now();
        tDASR.Sender_Transaction_Id__c = vAcctInfo != null ?  vAcctInfo.Sender_Transaction_ID: null;
        
        tDASR.Drop_Reason_Code__c = vAcctInfo != null && vAcctInfo.Drop_Reason_Code != null ? vAcctInfo.Drop_Reason_Code : null;
        tDASR.Drop_Reason__c = chngRsn != null ? chngRsn.Reason_Value__c : null;
        
        tDASR.Drop_Reason__c = tDASR.Drop_Reason__c == null || tDASR.Drop_Reason__c == '' ? vAcctInfo.Drop_Reason_Description  : tDASR.Drop_Reason__c;
        tDASR.Number_Of_Months_Usage_Quantity__c  = vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity;
        tDASR.Total_KWH_Quantity__c = vAcctInfo.Total_KWH_Quantity;
        
        tDASR.LDC_Bill_Cycle__c = vAcctInfo.LDC_Bill_Cycle;
        tDASR.LDC_Account_Number__c  = vAcctInfo.LDC_Account_Number != null ? vAcctInfo.LDC_Account_Number : vAcctInfo.SDP_Number;
        tDASR.Old_LDC_Account_Number__c = vAcctInfo.OLD_LDC_Account_Number != null ? vAcctInfo.OLD_LDC_Account_Number : null;
        tDASR.ESP_Account_Number__c = vAcctInfo.ESP_Account_Number;
        tDASR.Customer_Name__c   = vCustomerInfo != null ? vCustomerInfo.Customer_Name : null;
        tDASR.Name_Qualifier__c   = vCustomerInfo != null ? vCustomerInfo.Name_Qualifier : null;
        tDASR.Service_End_Date__c = vAcctInfo.Service_End_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_End_Date): System.today();
        tDASR.Drop_Date__c = tDASR.Service_End_Date__c;
        tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
        //tDASR.RecipientDUNS__c = vOrganizationInfo2.Organization_DUNS;
        //tDASR.RecipientName__c = vOrganizationInfo2.Organization_Name;
        //tDASR.Originating_Name__c = vOrganizationInfo1.Organization_Name;
        //tDASR.Originating_DUNS__c = vOrganizationInfo1.Organization_DUNS;
        tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
    }
    
    public static void processInboundChangeReq(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct, List<Meter__c> tMeterList, Service_Point__c tServPoint, List<Vendor_Meter__c> lstVenMeter, List<Vendor_Meter_Exception__c> lstVendMeterExcp, List<Account_Exception__c> lstAccExcp)
    {
        if(tLDCAct == null){
            return;
        }
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        List<EDIInboundWebService.MeterInfo> vMeterInfoList = vTranInfo.Meter;
        List<EDIInboundWebService.CustomerInfo> vCustomerInfoList = vTranInfo.Customer;
        //List<EDIInboundWebService.OrganizationInfo> vOrganizationInfolist = vTranInfo.Organization;
        //EDIInboundWebService.OrganizationInfo vOrganizationInfo1 = vOrganizationInfolist != null && vOrganizationInfolist.size() > 0 && vOrganizationInfolist[0].Organization_Identifier_Code == 'SJ' ? vOrganizationInfolist[0] : (vOrganizationInfolist != null && vOrganizationInfolist.size()>=1 && vOrganizationInfolist[1].Organization_Identifier_Code == 'SJ'? vOrganizationInfolist[1]: null);
        //EDIInboundWebService.OrganizationInfo vOrganizationInfo2 = vOrganizationInfolist != null && vOrganizationInfolist.size() >= 1 && vOrganizationInfolist[1].Organization_Identifier_Code == '8S' ? vOrganizationInfolist[1] : (vOrganizationInfolist != null && vOrganizationInfolist.size()>0 && vOrganizationInfolist[0].Organization_Identifier_Code == '8S'? vOrganizationInfolist[0]: null);
        EDIInboundWebService.CustomerInfo  vCustomerInfo;
        if(vCustomerInfoList.size() >1){
            vCustomerInfo = vCustomerInfoList != null && vCustomerInfoList[1].Name_Qualifier != null && vCustomerInfoList[1].Name_Qualifier =='BT' ? vCustomerInfoList[1]:null ;
        }
        else
            vCustomerInfo =vCustomerInfoList != null && vCustomerInfoList.size() >0 ? vCustomerInfoList[0] : null;   
        
        //EDIInboundWebService.CustomerInfo  vCustomerInfo = vCustomerInfoList != null && vCustomerInfoList.size() >0 && vCustomerInfoList[1].Name_Qualifier != null && vCustomerInfoList[1].Name_Qualifier =='BT' ? vCustomerInfoList[1] : (vCustomerInfoList != null && vCustomerInfoList.size() >0) ? vCustomerInfoList[0] : null ;
        List<EDIInboundWebService.AccountExceptionInfo> vAcctExcpInfoList = vTranInfo.Account_Exception_Info;
        EDIInboundWebService.AccountExceptionInfo vFirstExcpInfo = vAcctExcpInfoList != null && vAcctExcpInfoList.size() > 0 ? vAcctExcpInfoList[0]: null; 
        
        List<EDIInboundWebService.MeterExceptionInfo> vMeterExcpInfoList = vTranInfo.Meter_Exception_Info;
        EDIInboundWebService.MeterExceptionInfo vFirstMetrExcpInfo = vMeterExcpInfoList != null && vMeterExcpInfoList.size() > 0 ? vMeterExcpInfoList[0]: null; 
        
        
        ChangeReason__c chngRsn =  vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vFirstExcpInfo.Reason_Code) : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vFirstMetrExcpInfo.Reason_Code)  : null);        
            
            //Set DASR Request
        if(tDASR == null){
            tDASR = new DASR_Request__c();
        }
        tDASR.DASR_Type__c   = 'GAAC';
        tDASR.Integration_Status__c  = 'Complete';
        tDASR.Dynegy_Initiated__c = false;
        tDASR.DASR_Submit_Date__c = System.today();
        tDASR.Billing_Entity__c = 'Dynegy';
        
        
        tDASR.Change_Effective_Date__c = vAcctInfo != null && vAcctInfo.Change_Effective_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Change_Effective_Date) : System.today();
        tDASR.Line_Transaction_Id__c = vTranInfo != null && vTranInfo.Transaction_Info != null && vTranInfo.Transaction_Info.Line_Transaction_ID != null ? vTranInfo.Transaction_Info.Line_Transaction_ID : null;
        tDASR.Last_EDI_Update_Date__c = System.now();
        tDASR.Sender_Transaction_Id__c = vAcctInfo != null ?  vAcctInfo.Sender_Transaction_ID: null;
        
        tDASR.Change_Reason_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? vFirstExcpInfo.Reason_Code : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Reason_Code != null ? vFirstMetrExcpInfo.Reason_Code  : null);
        tDASR.Exception_Type_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Exception_Type_Code != null ? vFirstExcpInfo.Exception_Type_Code : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Exception_Type_Code != null ? vFirstMetrExcpInfo.Exception_Type_Code  : null);
        //tDASR.Reason_Rejected__c  = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : null;
        tDASR.Utility_Initiated_Change_Reason_Activity__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Reason_Description != null ? vFirstMetrExcpInfo.Reason_Description : null);
        tDASR.LDC_Bill_Cycle__c = vAcctInfo.LDC_Bill_Cycle;
        tDASR.LDC_Account_Number__c  = vAcctInfo.LDC_Account_Number != null ? vAcctInfo.LDC_Account_Number : vAcctInfo.SDP_Number;
        tDASR.Old_LDC_Account_Number__c = vAcctInfo.OLD_LDC_Account_Number != null ? vAcctInfo.OLD_LDC_Account_Number : null;
        tDASR.ESP_Account_Number__c = vAcctInfo.ESP_Account_Number;
        tDASR.Address_Line_1__c  = vCustomerInfo != null ? vCustomerInfo.Address_Line_1 : null;
        
        //Newly Added SCR 1289
        tDASR.Address_Line_2__c = vCustomerInfo != null ? vCustomerInfo.Address_Line_2 : null;
        tDASR.Phone_Number__c = vCustomerInfo != null ? vCustomerInfo.Phone_Number : null;
        //Newly Added SCR 1289
        
        //newly Added SCR 1304
        tDASR.Payment_Arrangement_Code__c = vAcctInfo!= null && vAcctInfo.Payment_Arrangement_Code != null ? vAcctInfo.Payment_Arrangement_Code : null ;
        tDASR.Number_Of_Months_Usage_Quantity__c = vAcctInfo!= null && vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity != null ? vAcctInfo.Number_Of_Months_Calculated_Usage_Quantity : null ;
        tDASR.Service_Relationship__c = vAcctInfo!= null && vAcctInfo.Service_Relationship != null ? vAcctInfo.Service_Relationship : null ;
        tDASR.Supply_Group__c = vAcctInfo!= null && vAcctInfo.Supply_Group != null ? vAcctInfo.Supply_Group : null ;
        tDASR.Special_Meter_Configuration__c = vAcctInfo != null && vAcctInfo.Special_Meter_Configuration != null ? vAcctInfo.Special_Meter_Configuration : null ;
        tDASR.Peak_Demand__c = vAcctInfo!= null && vAcctInfo.Peak_Demand_Usage_Quantity != null ? vAcctInfo.Peak_Demand_Usage_Quantity : null ;      
        //Newly Added SCR 1304
        
        tDASR.City_Name__c   = vCustomerInfo != null ? vCustomerInfo.City_Name : null;
        tDASR.State_Province_Code__c   = vCustomerInfo != null ? vCustomerInfo.State_Province_Code : null;
        tDASR.Postal_Code_Zip__c   = vCustomerInfo != null ? vCustomerInfo.Postal_Code_Zip : null;
        tDASR.Country_Code__c   = vCustomerInfo != null ? vCustomerInfo.Country_Code : null;
        tDASR.Customer_Name__c   = vCustomerInfo != null ? vCustomerInfo.Customer_Name : null;
        tDASR.Name_Qualifier__c   = vCustomerInfo != null ? vCustomerInfo.Name_Qualifier : null;
        tDASR.Service_End_Date__c = vAcctInfo.Service_End_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_End_Date): null;
        tDASR.Capacity_Obligation__c = vAcctInfo.Capacity_Obligation_Quantity;
        tDASR.Transmission_Obligation_Quantity__c = vAcctInfo.Transmission_Obligation_Quantity;
        tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
        
        tDASR.Meter_Exception_Type_Code__c  = vFirstMetrExcpInfo != null ? vFirstMetrExcpInfo.Exception_Type_Code : null;
        tDASR.Meter_Exception_Reason_Code__c  = vFirstMetrExcpInfo != null ? vFirstMetrExcpInfo.Reason_Code : null;
        tDASR.Meter_Exception_Reason_Description__c  = vFirstMetrExcpInfo != null ? vFirstMetrExcpInfo.Reason_Description : null;
        tDASR.Meter_Number__c  = vFirstMetrExcpInfo != null ? vFirstMetrExcpInfo.Meter_Number: null;
        //tDASR.RecipientDUNS__c = vOrganizationInfo2.Organization_DUNS;
        //tDASR.RecipientName__c = vOrganizationInfo2.Organization_Name;
        //tDASR.Originating_Name__c = vOrganizationInfo1.Organization_Name;
        //tDASR.Originating_DUNS__c = vOrganizationInfo1.Organization_DUNS;
        tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
        
        //Set the LDC Account values based on the reason code
        //TBD
        Vendor_Meter__c tVM;    

        if(vMeterInfoList != null && vMeterInfoList.size() > 0){
            for(EDIInboundWebService.MeterInfo tMet : vMeterInfoList){

                tVM = new Vendor_Meter__c();
                tVM.LDC_Account__c = tLDCAct.Id;
                tVM.Meter_Number__c = tMet.Meter_Number;
                tVM.Old_Meter_Number__c = tMet.Old_Meter_Number;
                tVM.Load_Profile_Description__c = tMet.Load_Profile_Description;
                tVM.LDC_Rate_Class__c = tMet.LDC_Rate_Class;
                
                // Newly Added SCR 1304
                tVM.LDC_Rate_Subclass__c = tMet.LDC_Rate_Subclass;
                tVM.Meter_Service_Voltage__c = tMet.Meter_Service_Voltage ;
                tVM.Distribution_Loss_Factor__c = tMet.Distribution_Loss_Factor ;
                tVM.Service_Point__c = tMet.SDP_Number ;
                tVM.Advanced_Metering_Indicator__c = tMet.Advanced_Metering_Indicator;
                tVM.Delivery_Voltage__c = tMet.Delivery_Voltage ;
                tVM.Supply_Voltage__c = tMet.Supply_Voltage ;
                tVM.Net_Meter_Type__c = tMet.Type_Of_Service_Indicator ;
                //Newly Added SCR 1304

                tVM.ESP_Rate_Code__c = tMet.ESP_Rate_Code;
                tVM.LDC_Meter_Cycle__c = tMet.LDC_Meter_Cycle;
                tVM.Meter_Type_Code__c = tMet.Meter_Type_Code;
                tVM.Meter_Multiplier_Quantity__c = tMet.Meter_Multiplier_Quantity;
                tVM.Number_Of_Dials_Quantity__c = tMet.Number_Of_Dials_Quantity;
                tVM.Time_Of_Use_Metering__c = tMet.Time_Of_Use_Metering;
                tVM.Meter_Maintenance_Code__c = tMet.Meter_Maintenance_Code;
                lstVenMeter.add(tVM);
                system.debug('****test****'+tvm.Distribution_Loss_Factor__c );
                 system.debug('****test898****'+tMet.Distribution_Loss_Factor );
            }
        }  
        
        system.debug('****test****'+lstVenMeter);
        
        Vendor_Meter_Exception__c  tVME;    

        if(vMeterExcpInfoList != null && vMeterExcpInfoList.size() > 0){
            for(EDIInboundWebService.MeterExceptionInfo tMet : vMeterExcpInfoList){

                tVME = new Vendor_Meter_Exception__c();
                tVME.Sender_Transaction_ID__c  = tMet.Sender_Transaction_ID;
                tVME.Reason_Code__c  = tMet.Reason_Code;
                tVME.Reason_Description__c  = tMet.Reason_Description;
                tVME.Exception_Type_Code__c  = tMet.Exception_Type_Code;
                tVME.LDC_Account__c = tLDCAct.Id;
                tVME.Meter_Number__c = tMet.Meter_Number;
                
                //tVME.Meter_Maintenance_Code__c = tMet.Meter_Maintenance_Code;
                lstVendMeterExcp.add(tVME);
            }
        } 
        
        Account_Exception__c  tAE;    

        if(vAcctExcpInfoList != null && vAcctExcpInfoList.size() > 0){
            for(EDIInboundWebService.AccountExceptionInfo tAet : vAcctExcpInfoList){

                tAE = new Account_Exception__c();
                tAE.Sender_Transaction_ID__c  = tAet.Sender_Transaction_ID;
                tAE.Reason_Code__c  = tAet.Reason_Code;
                tAE.Reason_Description__c  = tAet.Reason_Description;
                tAE.Exception_Type_Code__c  = tAet.Exception_Type_Code;
                tAE.LDC_Account__c = tLDCAct.Id;
                lstAccExcp.add(tAE);
            }
        } 
    }
    public static void processInboundReinstateReq(EDIInboundWebService.CTGTransactionInfo vTranInfo, DASR_Request__c tDASR,LDC_Account__c tLDCAct, List<Meter__c> tMeterList, Service_Point__c tServPoint, List<Vendor_Meter__c> lstVenMeter, List<Vendor_Meter_Exception__c> lstVendMeterExcp)
    {
        
        if(tLDCAct == null){
            return;
        }
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        List<EDIInboundWebService.MeterInfo> vMeterInfoList = vTranInfo.Meter;
        //List<EDIInboundWebService.OrganizationInfo> vOrganizationInfolist = vTranInfo.Organization;
        //EDIInboundWebService.OrganizationInfo vOrganizationInfo1 = vOrganizationInfolist != null && vOrganizationInfolist.size() > 0 && vOrganizationInfolist[0].Organization_Identifier_Code == 'SJ' ? vOrganizationInfolist[0] : (vOrganizationInfolist != null && vOrganizationInfolist.size()>=1 && vOrganizationInfolist[1].Organization_Identifier_Code == 'SJ'? vOrganizationInfolist[1]: null);
        //EDIInboundWebService.OrganizationInfo vOrganizationInfo2 = vOrganizationInfolist != null && vOrganizationInfolist.size() >= 1 && vOrganizationInfolist[1].Organization_Identifier_Code == '8S' ? vOrganizationInfolist[1] : (vOrganizationInfolist != null && vOrganizationInfolist.size()>0 && vOrganizationInfolist[0].Organization_Identifier_Code == '8S'? vOrganizationInfolist[0]: null);
        List<EDIInboundWebService.CustomerInfo> vCustomerInfoList = vTranInfo.Customer;
        EDIInboundWebService.CustomerInfo  vCustomerInfo = vCustomerInfoList != null && vCustomerInfoList.size() > 0 && vCustomerInfoList[0].Name_Qualifier != null && vCustomerInfoList[0].Name_Qualifier =='BT' ? vCustomerInfoList[0] : (vCustomerInfoList != null && vCustomerInfoList.size() >= 1 ? vCustomerInfoList[0] : null) ;
        List<EDIInboundWebService.AccountExceptionInfo> vAcctExcpInfoList = vTranInfo.Account_Exception_Info;
        EDIInboundWebService.AccountExceptionInfo vFirstExcpInfo = vAcctExcpInfoList != null && vAcctExcpInfoList.size() > 0 ? vAcctExcpInfoList[0]: null; 
        
        List<EDIInboundWebService.MeterExceptionInfo> vMeterExcpInfoList = vTranInfo.Meter_Exception_Info;
        EDIInboundWebService.MeterExceptionInfo vFirstMetrExcpInfo = vMeterExcpInfoList != null && vMeterExcpInfoList.size() > 0 ? vMeterExcpInfoList[0]: null; 
        
        
        ChangeReason__c chngRsn =  vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vFirstExcpInfo.Reason_Code) : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Reason_Code != null ? ChangeReasonUtil.getChgRsnCodeForCode(vFirstMetrExcpInfo.Reason_Code)  : null);        
            
            //Set DASR Request
        if(tDASR == null){
            tDASR = new DASR_Request__c();
        }
        tDASR.DASR_Type__c   = 'GAAR';
        tDASR.Integration_Status__c  = 'Complete';
        tDASR.Dynegy_Initiated__c = false;
        tDASR.DASR_Submit_Date__c = System.today();
        tDASR.Billing_Entity__c = 'Dynegy';
        
        
        tDASR.Change_Effective_Date__c = vAcctInfo != null && vAcctInfo.Change_Effective_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Change_Effective_Date) : System.today();
        tDASR.Line_Transaction_Id__c = vTranInfo != null && vTranInfo.Transaction_Info != null && vTranInfo.Transaction_Info.Line_Transaction_ID != null ? vTranInfo.Transaction_Info.Line_Transaction_ID : null;
        tDASR.Last_EDI_Update_Date__c = System.now();
        tDASR.Sender_Transaction_Id__c = vAcctInfo != null ?  vAcctInfo.Sender_Transaction_ID: null;
        
        tDASR.Change_Reason_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Code != null ? vFirstExcpInfo.Reason_Code : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Reason_Code != null ? vFirstMetrExcpInfo.Reason_Code  : null);
        tDASR.Exception_Type_Code__c = vFirstExcpInfo != null && vFirstExcpInfo.Exception_Type_Code != null ? vFirstExcpInfo.Exception_Type_Code : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Exception_Type_Code != null ? vFirstMetrExcpInfo.Exception_Type_Code  : null);
        //tDASR.Reason_Rejected__c  = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : null;
        tDASR.Utility_Initiated_Change_Reason_Activity__c = vFirstExcpInfo != null && vFirstExcpInfo.Reason_Description != null ? vFirstExcpInfo.Reason_Description : (vFirstMetrExcpInfo != null && vFirstMetrExcpInfo.Reason_Description != null ? vFirstMetrExcpInfo.Reason_Description : null);
        tDASR.LDC_Bill_Cycle__c = vAcctInfo.LDC_Bill_Cycle;
        tDASR.LDC_Account_Number__c  = vAcctInfo.LDC_Account_Number != null ? vAcctInfo.LDC_Account_Number : vAcctInfo.SDP_Number;
        tDASR.Old_LDC_Account_Number__c = vAcctInfo.OLD_LDC_Account_Number != null ? vAcctInfo.OLD_LDC_Account_Number : null;
        tDASR.ESP_Account_Number__c = vAcctInfo.ESP_Account_Number;
        tDASR.Address_Line_1__c  = vCustomerInfo != null ? vCustomerInfo.Address_Line_1 : null;
        tDASR.City_Name__c   = vCustomerInfo != null ? vCustomerInfo.City_Name : null;
        tDASR.State_Province_Code__c   = vCustomerInfo != null ? vCustomerInfo.State_Province_Code : null;
        tDASR.Postal_Code_Zip__c   = vCustomerInfo != null ? vCustomerInfo.Postal_Code_Zip : null;
        tDASR.Country_Code__c   = vCustomerInfo != null ? vCustomerInfo.Country_Code : null;
        tDASR.Customer_Name__c   = vCustomerInfo != null ? vCustomerInfo.Customer_Name : null;
        tDASR.Name_Qualifier__c   = vCustomerInfo != null ? vCustomerInfo.Name_Qualifier : null;
        tDASR.Service_End_Date__c = vAcctInfo.Service_End_Date != null ? IntegrationUtil.convertStringToDate(vAcctInfo.Service_End_Date): null;
        tDASR.Capacity_Obligation__c = vAcctInfo.Capacity_Obligation_Quantity;
        tDASR.Transmission_Obligation_Quantity__c = vAcctInfo.Transmission_Obligation_Quantity;
        tDASR.Transaction_JSON__c  = Json.serialize(vTranInfo);
        
        tDASR.Meter_Exception_Type_Code__c  = vFirstMetrExcpInfo != null ? vFirstMetrExcpInfo.Exception_Type_Code : null;
        tDASR.Meter_Exception_Reason_Code__c  = vFirstMetrExcpInfo != null ? vFirstMetrExcpInfo.Reason_Code : null;
        tDASR.Meter_Exception_Reason_Description__c  = vFirstMetrExcpInfo != null ? vFirstMetrExcpInfo.Reason_Description : null;
        tDASR.Meter_Number__c  = vFirstMetrExcpInfo != null ? vFirstMetrExcpInfo.Meter_Number: null;
        //tDASR.RecipientDUNS__c = vOrganizationInfo2.Organization_DUNS;
        //tDASR.RecipientName__c = vOrganizationInfo2.Organization_Name;
        //tDASR.Originating_Name__c = vOrganizationInfo1.Organization_Name;
        //tDASR.Originating_DUNS__c = vOrganizationInfo1.Organization_DUNS;
        tDASR.XML_File_Name__c = vAcctInfo != null && vAcctInfo.XML_File_Name != null ? vAcctInfo.XML_File_Name : null;
        

    }
    public static Map<String, Meter__c> mapMeterByMtrNum(List<Meter__c> lMeter)
    {
        Map<String, Meter__c> retMap;
        if(lMeter != null && lMeter.size() > 0){
            retMap = new Map<String, Meter__c>(); 
            for(Meter__c tMeter: lMeter){
                retMap.put(tMeter.Meter_Number__c, tMeter);
            }
        }
        return retMap;
    }
    public static void updateContractLDC(EDIInboundWebService.CTGTransactionInfo vTranInfo,DASR_Request__c vDASRReq, LDC_Account__c vLDCAcct, List<Contract_LDC__c> vContLDCList)
    {
        EDIInboundWebService.AccountInfo vAcctInfo = vTranInfo.Account;
        if(vContLDCList != null && vContLDCList.size() > 0){
            for(Contract_LDC__c tCL : vContLDCList){
                if(tCL.Contract__c  != null && tCL.Contract__c  ==  vDASRReq.Contract__c){
                    tCL.Rate_Code__c = vDASRReq.DASR_Type__c != null && vDASRReq.DASR_Type__c == 'GAAE' ? vDASRReq.Contract_Rate_Code__c: vDASRReq.Rate_Code__c;

                    //Set the values to null
                    tCL.Active__c = false;
                    tCL.Term_Start_Date__c = null;

                    for(Bill_Method__c bml : Bill_Method__c.getall().values()){
                        if(bml.Bill_Calculator__c == vAcctInfo.Bill_Calculator && bml.Bill_Presenter__c ==vAcctInfo.Bill_Presenter){
                            tCL.Bill_Method__c = bml.name;
                        }
                    }

                    /**
                     * below code commented for task # (SCR-1282)
                     *
                    tCL.Active__c = true;
                    tCL.Term_Start_Date__c = vLDCAcct.LDC_Start_Date__c;

                    **/
                }
                else{
                    tCL.Active__c = false;   
                    tCL.Term_Stop_Date__c = tCL.Term_Stop_Date__c == null ? vLDCAcct.LDC_Start_Date__c : tCL.Term_Stop_Date__c;
                }
            }
        }
    }
    
    public static void upDASRReqSuccess(DASR_Request__c tDASR)
    {
        tDASR.Integration_Status__c  = 'Complete';
        tDASR.Integration_Message__c = '';
        tDASR.Accepted__c = true;
        tDASR.Last_EDI_Update_Date__c = System.now();
        
    }
    public static List<Vendor_Meter__c> assignDASRRequest(Map<Id, List<Vendor_Meter__c>> mapIdListVendMet, List<DASR_Request__c> lDASRToUpsert)
    {
        List<Vendor_Meter__c> lVendMetInsert = new List<Vendor_Meter__c>();
        if(lDASRToUpsert == null || mapIdListVendMet == null){
            return lVendMetInsert;
        }
        List<Vendor_Meter__c> myVM;
        
        for(DASR_Request__c tDASR: lDASRToUpsert){
            myVM = mapIdListVendMet.get(tDASR.LDC_Account__c);
            if(myVM != null){
                for(Vendor_Meter__c tVendM: myVM){
                    tVendM.DASR_Request__c = tDASR.Id;
                    lVendMetInsert.add(tVendM);
                }
            }
        }
        return lVendMetInsert;
    }
    public static List<Vendor_Meter_Exception__c > assignMetExctDASRRequest(Map<Id, List<Vendor_Meter_Exception__c>> mapIdListVendMet, List<DASR_Request__c> lDASRToUpsert)
    {
        List<Vendor_Meter_Exception__c> lVendMetInsert = new List<Vendor_Meter_Exception__c >();
        if(lDASRToUpsert == null || mapIdListVendMet == null){
            return lVendMetInsert;
        }
        List<Vendor_Meter_Exception__c> myVM;
        for(DASR_Request__c tDASR: lDASRToUpsert){
            myVM = mapIdListVendMet.get(tDASR.LDC_Account__c);
            if(myVM != null){
                for(Vendor_Meter_Exception__c tVendM: myVM){
                    tVendM.DASR_Request__c = tDASR.Id;
                    lVendMetInsert.add(tVendM);
                }
            }
        }
        return lVendMetInsert;
    }
    public static List<Account_Exception__c > assignAccExcpDASRREquest(Map<Id, List<Account_Exception__c>> mapIdListAccExcp, List<DASR_Request__c> lDASRToUpsert)
    {
        List<Account_Exception__c> lAccExcpInsert = new List<Account_Exception__c >();
        if(lDASRToUpsert == null || mapIdListAccExcp == null){
            return lAccExcpInsert;
        }
        List<Account_Exception__c> myAM;
        
        for(DASR_Request__c tDASR: lDASRToUpsert){
            myAM = mapIdListAccExcp.get(tDASR.LDC_Account__c);
            if(myAM != null){
                for(Account_Exception__c tAccE: myAM){
                    tAccE.DASR_Request__c = tDASR.Id;
                    lAccExcpInsert.add(tAccE);
                }
            }
        }
        return lAccExcpInsert;
    }
}