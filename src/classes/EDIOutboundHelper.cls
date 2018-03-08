/* 
* Name: EDIOutboundHelper
* Type: Apex Class
* Test Class: Covered under the respective main classes
* Description:  This class contains the helper functions for generating VO's and make WS calls. 
* Change History:
*===================================================================================================================================
* Version     Author                       Date             Description 
* 1.0         KPMG                      02/10/2016       1. Initial Version created
*/


public with sharing class EDIOutboundHelper {
    //public static final String DASR_TYPE_ENROL = 'GAAE';
    //public static final String DASR_TYPE_DROP = 'GAAD';
    //public static final String DASR_TYPE_CHANGE = 'GAAC';
    
  public static String sendDASRUpdates(List<DASR_Request__c> lstDASRSumm, Map<Id,LDC_Account__c> ldcAccntMap,Map<Id,Supplier__c> supplMap,Map<Id,LDC_Vendor__c > vendorMap,Map<Id,List<Meter__c>> meterMap,Map<Id,Account> custMap,Map<Id,Contract> contractMap,Map<Id, List<Contract_Term__c>> contractTermMap,Integer vtotNumRecords, Integer vTransNum){
          
        system.debug('\n anand lstDASRSumm to process : ' + lstDASRSumm);
        Datetime currTime = System.now();
        String docId = IntegrationUtil.generateDocId(currTime);
        String currDate = IntegrationUtil.convertDateToString(currTime.date());
        String currT = IntegrationUtil.convertTimeToString(currTime);
        
        integer totalRecords = vtotNumRecords;
        integer transNum = vTransNum;
        String origDuns;
        String origName;
        String recDuns;
        String recName;
        
        dynegyComEDIServices.CTG_Document reqEDIOut = new dynegyComEDIServices.CTG_Document();
        reqEDIOut.Document_Info = getDocInfo(docId,currDate,currT, origDuns, origName,recDuns, recName);
        reqEDIOut.Transactions = getTransaction(lstDASRSumm,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap);
        
        Integer numOfTrans = 0;
        Integer numOfRecGen = 2;
        if(reqEDIOut.Transactions != null && reqEDIOut.Transactions.CTG_Transaction != null)
        {
            numOfTrans = reqEDIOut.Transactions.CTG_Transaction.size();
            for(dynegyComEDIServices.CTG_Transaction tCT : reqEDIOut.Transactions.CTG_Transaction)
            {
                numOfRecGen += tCT.Transaction_Info != null ? 1 : 0;
                System.debug('\n 11 numOfRecGen='+numOfRecGen);
                numOfRecGen += tCT.Account != null ? 1 : 0;
                System.debug('\n 22 numOfRecGen='+numOfRecGen);
                numOfRecGen += tCT.Account_Exception_Info != null && tCT.Account_Exception_Info.CTG_Account_Exception_Info != null ? tCT.Account_Exception_Info.CTG_Account_Exception_Info.size() : 0;
                System.debug('\n 33 numOfRecGen='+numOfRecGen);
                numOfRecGen += tCT.Meter != null && tCT.Meter != null && tCT.Meter.Sender_Transaction_ID != null ? 1 : 0;
                System.debug('\n 44 numOfRecGen='+numOfRecGen);
                
                numOfRecGen += tCT.Meter_Exception_Info != null && tCT.Meter_Exception_Info != null && tCT.Meter_Exception_Info.Reason_Code != null? 1 : 0;
                System.debug('\n 55 numOfRecGen='+numOfRecGen);
                
                numOfRecGen += tCT.Customer != null && tCT.Customer.CTG_Customer != null ? tCT.Customer.CTG_Customer.size() : 0;
                System.debug('\n 66 numOfRecGen='+numOfRecGen);
                numOfRecGen += tCT.Organization != null && tCT.Organization.CTG_Organization != null ? tCT.Organization.CTG_Organization.size() : 0;
                System.debug('\n 77 numOfRecGen='+numOfRecGen);
            }
        }
        System.debug('\n numOfTrans='+numOfTrans);
        System.debug('\n numOfRecGen='+numOfRecGen);
        reqEDIOut.Trailer = getTrailer(docId,numOfTrans,numOfRecGen);
        
        dynegyComEDIServices.BasicHttpBinding_ISforceESG tOrg = new dynegyComEDIServices.BasicHttpBinding_ISforceESG();
        //String v = EncodingUtil.base64Encode(Blob.valueOf(EDIIntegrationConfigUtil.getIntUserName() + ':' + EDIIntegrationConfigUtil.getIntUserPwd()));
        String v = EncodingUtil.base64Encode(Blob.valueOf(System.Label.WS_User_Name + ':' + System.Label.WS_Password));
        
        Map<String,String>  authMap = new Map<String,String>();
        authMap.put('Authorization', 'Basic ' + v);
        authMap.put('username',System.Label.WS_User_Name);
        authMap.put('password',System.Label.WS_Password);
        authMap.put('timeout','120000');
        tOrg.inputHttpHeaders_x = authMap;
        tOrg.timeout_x = 120000;
        String resultStr;
        try{
            resultStr = tOrg.Submit_ESG_GAA_Request(reqEDIOut);
            system.debug(' \n  resultStr : ' + resultStr);
        }
        catch(exception e){
            resultStr = e.getMessage();
            system.debug('\n ERROR In Web Service Call: ' + e.getMessage());
        }
        
        return resultStr;
        
    }
    
    public static dynegyComEDIServices.CTG_Document_Info getDocInfo(String docId,String currDate,String currT, String origDuns, String origName,String recDuns, String recName){
        dynegyComEDIServices.CTG_Document_Info retDocInfo = new dynegyComEDIServices.CTG_Document_Info();
        retDocInfo.Document_Date = currDate;
        retDocInfo.Document_ID = docId;
        retDocInfo.Document_Time = currT;
        retDocInfo.Originator_DUNS = origDuns;
        retDocInfo.Originator_Name = origName;
        //retDocInfo.Recipient_DUNS = recDuns;
        retDocInfo.Recipient_DUNS = EDIIntegrationConfigUtil.getESGRecpDuns();
        //retDocInfo.Recipient_Name = recName;
        retDocInfo.Recipient_Name = EDIIntegrationConfigUtil.getESGRecpName();
        retDocInfo.Version_Number = Label.EDI_Web_Service_Version;
        
        return retDocInfo;
    }
    
    public static dynegyComEDIServices.CTG_Trailer getTrailer(String docId,integer trasNumber, integer totalRec){
        dynegyComEDIServices.CTG_Trailer  retTrailer = new dynegyComEDIServices.CTG_Trailer();
        retTrailer.Document_ID = docId;
        retTrailer.Transaction_Count = String.valueOf(trasNumber);
        retTrailer.Records_Generated = String.valueOf(totalRec);
        
        return retTrailer;
    }
    
    
    public static dynegyComEDIServices.ArrayOfCTG_Transaction getTransaction(List<DASR_Request__c> lDASR,Map<Id,LDC_Account__c> ldcAccntMap,Map<Id,Supplier__c> supplMap,Map<Id,LDC_Vendor__c > vendorMap,Map<Id,List<Meter__c>> meterMap,Map<Id,Account> custMap,Map<Id,Contract> contractMap, Map<Id, List<Contract_Term__c>> contractTermMap){
        dynegyComEDIServices.ArrayOfCTG_Transaction retTran = new dynegyComEDIServices.ArrayOfCTG_Transaction();
        retTran.CTG_Transaction = getListTransaction(lDASR,ldcAccntMap,supplMap,vendorMap,meterMap,custMap,contractMap,contractTermMap);
        return retTran;
    }
    public static dynegyComEDIServices.CTG_Transaction[] getListTransaction(List<DASR_Request__c> lDASR,Map<Id,LDC_Account__c> ldcAccntMap,Map<Id,Supplier__c> supplMap,Map<Id,LDC_Vendor__c > vendorMap,Map<Id, List<Meter__c>> meterMap,Map<Id,Account> custMap,Map<Id,Contract> contractMap, Map<Id, List<Contract_Term__c>> contractTermMap)
    {
        dynegyComEDIServices.CTG_Transaction[] lstCTGtrans = new List<dynegyComEDIServices.CTG_Transaction>();
        dynegyComEDIServices.CTG_Account vAccount ;
        dynegyComEDIServices.CTG_Account_Exception_Info vAccount_Exception_Info;
        dynegyComEDIServices.ArrayOfCTG_Customer vCustomer;
        dynegyComEDIServices.CTG_Meter vMeter;
        dynegyComEDIServices.CTG_Meter_Exception_Info vMeter_Exception_Info;
        dynegyComEDIServices.ArrayOfCTG_Organization vOrganization;
        dynegyComEDIServices.ArrayOfCTG_Account_Exception_Info vAcctExcInfo;
        dynegyComEDIServices.CTG_Transaction_Info vTransaction_Info;
        
        dynegyComEDIServices.CTG_Transaction tTrans;
        dynegyComEDIServices.CTG_Customer vCustAcct1;
        dynegyComEDIServices.CTG_Customer vCustAcct2;
        
        LDC_Account__c tLDC;
        List<Meter__c> tMeter;
        Account tCustomer;
        Contract tContract;
        LDC_Vendor__c tVendor;
        Supplier__c tSupplier;
        List<Contract_Term__c> tContractTerms;
        for(DASR_Request__c tDASR : lDASR)
        {
            tTrans = new dynegyComEDIServices.CTG_Transaction();
            vAccount = new dynegyComEDIServices.CTG_Account();
            vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();
            vAcctExcInfo = new dynegyComEDIServices.ArrayOfCTG_Account_Exception_Info();
            vMeter = new dynegyComEDIServices.CTG_Meter();
            vMeter_Exception_Info = new dynegyComEDIServices.CTG_Meter_Exception_Info();
            vTransaction_Info = new dynegyComEDIServices.CTG_Transaction_Info();
            vCustomer = new dynegyComEDIServices.ArrayOfCTG_Customer();
            vOrganization = new dynegyComEDIServices.ArrayOfCTG_Organization();
            
            tCustomer = custMap.get(tDASR.Customer_Id__c);
            tVendor = vendorMap.get(tDASR.Vendor_Id__c );
            tSupplier = supplMap.get(tDASR.Supplier_ID__c);
            tLDC = ldcAccntMap.get(tDASR.LDC_Account__c);
            
            //Logic contract selection
            tContract = (contractMap != null && contractMap.containsKey(tDASR.Contract__c)) ? contractMap.get(tDASR.Contract__c) : null;
            tContractTerms = (tContract != null && contractTermMap != null && contractTermMap.containsKey(tContract.Id)) ? contractTermMap.get(tContract.Id) : null;
            
            List<dynegyComEDIServices.CTG_Organization> vCTGOrg = new List<dynegyComEDIServices.CTG_Organization>();
            if(tSupplier != null){
                dynegyComEDIServices.CTG_Organization vOrgSupplier = new dynegyComEDIServices.CTG_Organization(); 
                if(tVendor != null && tVendor.DUNS__c != null && (tVendor.DUNS__c == '007900293' || tVendor.DUNS__c == '006998371' || tVendor.DUNS__c == '007904626')){   
                    vOrgSupplier.Organization_DUNS = tSupplier.Supplier_DUNS__c != null && tSupplier.Supplier_DUNS__c.equals('141420484') ? tSupplier.Supplier_DUNS__c + 'DERS' : tSupplier.Supplier_DUNS__c;
                }
                else{
                    vOrgSupplier.Organization_DUNS = tSupplier.Supplier_DUNS__c;
                }
                vOrgSupplier.Organization_Identifier_Code = 'SJ'; //Sender
                vOrgSupplier.Organization_Name = tSupplier.Name;
                vOrgSupplier.Sender_Transaction_ID =tDASR.Id;
                vCTGOrg.add(vOrgSupplier);
            }
            if(tVendor != null){
                dynegyComEDIServices.CTG_Organization vOrgVendor = new dynegyComEDIServices.CTG_Organization(); 
                vOrgVendor.Organization_DUNS = tVendor.DUNS__c;
                vOrgVendor.Organization_Identifier_Code = '8S'; //Receiver
                vOrgVendor.Organization_Name = tVendor.Name;
                vOrgVendor.Sender_Transaction_ID =tDASR.Id;
                vCTGOrg.add(vOrgVendor);
            }
            if(tVendor != null && tVendor.DUNS__c != null && tVendor.DUNS__c.equalsIgnoreCase('147212336')){
                dynegyComEDIServices.CTG_Organization vOrgRSVendor = new dynegyComEDIServices.CTG_Organization(); 
                vOrgRSVendor.Organization_DUNS = tSupplier.Supplier_DUNS__c;
                vOrgRSVendor.Organization_Identifier_Code = 'RS'; //Scheduling Coordinator
                vOrgRSVendor.Organization_Name = tSupplier.Name;
                vOrgRSVendor.Sender_Transaction_ID =tDASR.Id;
                vCTGOrg.add(vOrgRSVendor);
            }            
            vOrganization.CTG_Organization = vCTGOrg;
            if(tCustomer != null){
                //Must send 2 customer record for the customer, one with 8R and one with BT
                List<dynegyComEDIServices.CTG_Customer> vCTGCustomer = new List<dynegyComEDIServices.CTG_Customer>();
                vCustAcct1 = new dynegyComEDIServices.CTG_Customer();
                vCustAcct1.Sender_Transaction_ID = tDASR.Id; 
                vCustAcct1.Customer_Name = (tCustomer.Name).length()>60 ? (tCustomer.Name).left(60) : tCustomer.Name ; 
                vCustAcct1.Name_Qualifier = '8R' ; //Customer name
                if(tDASR.DASR_Type__c != null && tDASR.DASR_Type__c.equalsIgnoreCase('GAAE')){
                    //Comment out sending the service address 
                    /**
                    vCustAcct1.Address_Line_1 = tLDC.Service_Street_1__c; //Service address
                    vCustAcct1.City_Name = tLDC.Service_City__c; //Service address city
                    //vCustAcct1.Country_Code = tLDC.Service_Street_1__c; //Service address country
                    vCustAcct1.Postal_Code_Zip = IntegrationUtil.remSpecialChars(tLDC.Service_Postal_Code__c);//Service address postal code
                    vCustAcct1.State_Province_Code = EDITransformationUtil.convStateValToCode(tLDC.Service_State__c);//Service address state
                    **/                
                }
                vCTGCustomer.add(vCustAcct1);
                
                //The OH market does not use the customer biiling information (4000-BT) and does not needs to be included
                //Based on feedback received on 02/23 by ESG
                // IL ESG guides specifies that we dont need to send Customer BT Section.
                /*if(tCustomer.BillingState == null || !tCustomer.BillingState.equalsIgnoreCase('OH')){
                    vCustAcct2 = new dynegyComEDIServices.CTG_Customer();
                    vCustAcct2.Sender_Transaction_ID = tDASR.Id; 
                    vCustAcct2.Customer_Name = (tCustomer.Name).length()>60 ? (tCustomer.Name).left(60) : tCustomer.Name ; 
                    vCustAcct2.Name_Qualifier = 'BT' ; //Billing address
                    if(tDASR.DASR_Type__c != null && tDASR.DASR_Type__c.equalsIgnoreCase('GAAE')){
                        vCustAcct2.Address_Line_1 = (tCustomer.BillingStreet).length()>60 ?(tCustomer.BillingStreet).left(60) : tCustomer.BillingStreet ;
                        vCustAcct2.City_Name = tCustomer.BillingCity;
                        vCustAcct2.Country_Code = EDITransformationUtil.convUSAValToCode(tCustomer.BillingCountry);
                        vCustAcct2.Postal_Code_Zip = IntegrationUtil.remSpecialChars(tCustomer.BillingPostalCode);
                        vCustAcct2.State_Province_Code = tCustomer.BillingState;                        
                    }
                    vCTGCustomer.add(vCustAcct2);
                }*/
                vCustomer.CTG_Customer = vCTGCustomer;
            }
            
            //vOrganization = new dynegyComEDIServices.ArrayOfCTG_Organization();
            
            tMeter = meterMap != null ? meterMap.get(tDASR.LDC_Account__c ) :  null;

            vTransaction_Info.Receiver_DUNS = tDASR.Recipient_DUNS__c;
            vTransaction_Info.Receiver_Name = tDASR.Recipient_Name__c;
            
            //Use master dun's number and not the supplier's duns number
            String mastDuns = tSupplier != null && tSupplier.master_Duns__c != null ? tSupplier.master_Duns__c : '078481476';
            mastDuns = mastDuns.length() == 8 ? '0'+mastDuns : mastDuns;
            vTransaction_Info.Sender_DUNS = mastDuns;
            vTransaction_Info.Sender_Name = tDASR.Originator_Name__c;
            
            vTransaction_Info.Action_ID = tDASR.DASR_Type__c;
            vTransaction_Info.Commodity = tLDC.Commodity__c != null && !String.isEmpty(tLDC.Commodity__c) ? EDITransformationUtil.convCommodityValToCode(tLDC.Commodity__c) : 'E'; //Electric
            vTransaction_Info.Sender_Transaction_ID = tDASR.Id;
            vTransaction_Info.Transaction_Qualifier ='1'; //1 = Request, 2 = Response
            vTransaction_Info.Transaction_Date = IntegrationUtil.convertDateToString(tDASR.DASR_Submit_Date__c.date());
            vTransaction_Info.Transaction_Time = IntegrationUtil.convertTimeToString(tDASR.DASR_Submit_Date__c);
            // PPL Changes Chaitanya Kurra 1301 SCR
                if(tVendor != null && tVendor.DUNS__c != null && (tVendor.DUNS__c == '007909427AC'))
                    {                                                                    
                         vTransaction_Info.LINE_TRANSACTION_ID = tLDC.CRM_Id__c;                                   
                    }
            // PPL Changes Completed Chaitanya Kurra 1301 SCR
           
            system.debug('**************Service State1************'+tVendor.Service_state__c);
            //Changed for IL Dynegy
                  
            if(tvendor != null && tVendor.Service_state__c != null && (tVendor.Service_state__c.containsIgnoreCase('IL'))){
              system.debug('************Service State2**********'+tVendor.Service_state__c);
              vTransaction_Info.LINE_TRANSACTION_ID = tLDC.CRM_Id__c;
                if(tDasr.Dasr_Type__c != null && tDasr.Dasr_type__c.equalsignorecase('GAAR')){
                   vTransaction_Info.Transaction_Type_code = 'CD';}
                else if(tDasr.Dasr_Type__c != null && tDasr.Dasr_type__c.equalsignorecase('GAAD')){
                  if(tldc.LDC_Account_Status__c.equalsignorecase('PENDING_ENROLLMENT')){
                      vTransaction_Info.Transaction_Type_code = 'EC';
                    }
                    else{
                        vTransaction_Info.Transaction_Type_code = 'DR';
                    }
                }
            }
            
            //Changed for IL Dynegy
            //Get account information by transaction type
            vAccount = getAcctByTran(tDASR, tLDC, tSupplier, tVendor, tMeter, tCustomer, tContract, tContractTerms);
            
            //Get account exception information by transaction type
            vAcctExcInfo = getAcctExcByTran(tDASR, tLDC, tSupplier, tVendor, tMeter, tCustomer, tContract, tContractTerms);
            
            //Get meter information by transaction type
            vMeter = getMeterByTran(tDASR, tLDC, tSupplier, tVendor, tMeter, tCustomer, tContract, tContractTerms);
            
            //Get meter exception information by transaction type
            vMeter_Exception_Info = getMeterExcByTran(tDASR, tLDC, tSupplier, tVendor, tMeter, tCustomer, tContract, tContractTerms);
            
            tTrans.Account = vAccount;
            
            tTrans.Account_Exception_Info = vAcctExcInfo;
            
            tTrans.Customer = vCustomer;
            tTrans.Organization =vOrganization;
            tTrans.Meter = vMeter;
            tTrans.Meter_Exception_Info = vMeter_Exception_Info;
            tTrans.Transaction_Info = vTransaction_Info;
            
            lstCTGtrans.add(tTrans);
        }
        return lstCTGtrans;
    }
    
    public static dynegyComEDIServices.CTG_Account getAcctByTran(DASR_Request__c vDASR, LDC_Account__c vldcAccnt,Supplier__c vSupplier,LDC_Vendor__c vVendor,List<Meter__c> vMeterList,Account vCustomer,Contract vContract, List<Contract_Term__c> vContractTerm)
    {
        dynegyComEDIServices.CTG_Account vAccount = new dynegyComEDIServices.CTG_Account();
        
        if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_ENROL)){
            Bill_Method__c tBM = vDASR.Contract_Bill_Method__c != null ?  BillMethodUtil.getBillMethodByName(vDASR.Contract_Bill_Method__c) : null;
            vAccount.Aggregator = vCustomer.Muni_Agg_Type__c  != null ? vCustomer.Muni_Agg_Type__c : ''; 
            vAccount.Bill_Calculator = tBM !=null && tBM.Bill_Calculator__c != null ? tBM.Bill_Calculator__c : ''; // example 'LDC'
            vAccount.Bill_Presenter = tBM !=null && tBM.Bill_Presenter__c != null ? tBM.Bill_Presenter__c : ''; // example 'LDC'
            vAccount.Budget_Amount = 0;
            vAccount.Budget_AmountSpecified = true;
            vAccount.Aggregator_Code = vCustomer.Aggregator_Code__c;
            
            //Change effective date is not applicable to enrollments
            //vAccount.Change_Effective_Date =  IntegrationUtil.convertDateToString(vDASR.Contract_Start_Date__c);
            vAccount.Contract_Effective_Date = IntegrationUtil.convertDateToString(vDASR.Contract_Counter_Signed_Date__c.date());
            vAccount.Contract_Effective_Time = '0001';
            //vAccount.Contract_Effective_Time_Zone = 'ET';
            
           // PPL Changes Chaitanya Kurra 1301 SCR
           if(vVendor != null && vVendor.DUNS__c != null && (vVendor.DUNS__c == '007909427AC'))
               {
               System.debug('***enter****');
                    vAccount.Contract_Effective_Time_Zone = 'ET';
                    vAccount.AParticipating_Interest = 1;
                    vAccount.AParticipating_InterestSpecified = true ;
                    System.debug('***ending1****'+vAccount.AParticipating_Interest);
                     System.debug('***ending****'+vAccount.AParticipating_InterestSpecified);
                }
            // PPL Changes Completed Chaitanya Kurra 1301 SCR
            System.debug('***ending****'+vAccount.AParticipating_Interest);
            //vAccount.ESP_Account_Number = vldcAccnt.ESP_Account_Number__c != null ? vldcAccnt.ESP_Account_Number__c : '1871754';
            vAccount.ESP_Account_Number = vldcAccnt.Id;
            
            // Changes for IL Dynegy Initiated DASR'section
            system.debug('**********Service State1*************'+vVendor.Service_state__c);       
            if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_state__c.containsIgnoreCase('IL'))){
                system.debug('**********Service State2*************'+vVendor.Service_state__c);
                vAccount.Secondary_Service_Historical_Usage_Request_Code = 'N';
                if(vDASR != null && vDasr.OFF_Cycle_Enrollment__c != null && vDasr.OFF_Cycle_Enrollment__c == TRUE){
                  vAccount.Special_Meter_Read_Date =  vDASR.Change_Effective_Date__c != null ? IntegrationUtil.convertDateToString(vDASR.Change_Effective_Date__c) : '' ;
                  vAccount.Secondary_Service_Offcycle_Enrollment_Request_Code =  (vDasr.OFF_Cycle_Enrollment__c != null && vDasr.OFF_Cycle_Enrollment__c == TRUE) ? 'Y' : '' ;
                }
                else {
                  vAccount.Secondary_Service_Offcycle_Enrollment_Request_Code =  vDasr.OFF_Cycle_Enrollment__c != null && vDasr.OFF_Cycle_Enrollment__c == FALSE ? 'N' : '' ;
                }
                vAccount.Payment_Arrangement_Code = tBM !=null && tBM.Payment_Arrangement_Code__c != null ? tBM.Payment_Arrangement_Code__c : '';
                vAccount.Interval_Level_Indicator_Code = '';
                vAccount.Service_Relationship = '';
                vAccount.CP_Node = '';
                vAccount.Contract_Effective_Date  ='';
                
            }
            // Changes for IL Completed  
            
            if(vVendor != null && vVendor.Name != null && (vVendor.Name.containsIgnoreCase('Ohio Power') || vVendor.Name.containsIgnoreCase('Columbus Southern Power'))){
                vAccount.SDP_Number = vldcAccnt.LDC_Account_Number__c;
            }else{
                vAccount.LDC_Account_Number = vldcAccnt.LDC_Account_Number__c;
            }
            
            //Always pass value of N which means detail information is requested. Y means Summary
            vAccount.Secondary_Service_Summary_Interval_Request_Code = EDITransformationUtil.getUsageValue( vDASR,  vldcAccnt, vSupplier, vVendor, vMeterList, vCustomer, vContract, vContractTerm);
            vAccount.Sender_Transaction_ID = vDASR.Id;
            
        }
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_CHANGE)){
            vAccount.Sender_Transaction_ID = vDASR.Id;
            
            //Get change reason code by reason
            String chngRsnCode = ChangeReasonUtil.getChgRsnCodeForVal(vDASR.Change_Reason__c,'LDC_Account__c');
            vAccount.Aggregator = vCustomer.Muni_Agg_Type__c  != null ? vCustomer.Muni_Agg_Type__c : '';
            vAccount.Aggregator_Code = (vCustomer.Aggregator_Code__c != null ) ? vCustomer.Aggregator_Code__c : vCustomer.Business_Account__r.Aggregator_Code__c;
            
            //New bill method from DASR Request
            Bill_Method__c tChangeBM = vDASR.Bill_Method__c != null ? BillMethodUtil.getBillMethodByName(vDASR.Bill_Method__c) : BillMethodUtil.getBillMethodByName(vDASR.Contract_Bill_Method__c) ;
            
            //IF the change reason is Change Billing Type (Billing Option)
            if(tChangeBM != null && chngRsnCode != null && chngRsnCode.equalsIgnoreCase('REFBLT')){
                vAccount.Bill_Calculator = tChangeBM !=null && tChangeBM.Bill_Calculator__c != null ? tChangeBM.Bill_Calculator__c : ''; // example 'LDC'
                vAccount.Bill_Presenter = tChangeBM !=null && tChangeBM.Bill_Presenter__c != null ? tChangeBM.Bill_Presenter__c : ''; // example 'LDC'
            }
             // Changes for IL Dynegy Initiated DASR'section
                       
            if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_state__c.containsIgnoreCase('IL'))){
                 vAccount.Payment_Arrangement_Code = tChangeBM !=null && tChangeBM.Payment_Arrangement_Code__c != null ? tChangeBM.Payment_Arrangement_Code__c : '';
                vAccount.Interval_Level_Indicator_Code = '';
                vAccount.Service_Relationship = '';
                vAccount.CP_Node = '';  
            }
            // Changes for IL Completed  
            vAccount.ESP_Account_Number = vldcAccnt.Id;
            if(vVendor != null && vVendor.Name != null && (vVendor.Name.containsIgnoreCase('Ohio Power') || vVendor.Name.containsIgnoreCase('Columbus Southern Power'))){
                vAccount.SDP_Number = vldcAccnt.LDC_Account_Number__c;
            }else{
                vAccount.LDC_Account_Number = vldcAccnt.LDC_Account_Number__c;
            }
            //vAccount.LDC_Account_Number = vldcAccnt.LDC_Account_Number__c;
            //vAccount.SDP_Number = vldcAccnt.LDC_Account_Number__c;
            
            //Change Service Indicator - REF17
            if(chngRsnCode != null && chngRsnCode.equalsIgnoreCase('REF17')){
                //Pass value of Y which means summary information is requested. N means Interval.Check custom setting to
                //see if the default value has changed
                vAccount.Secondary_Service_Summary_Interval_Request_Code = EDITransformationUtil.getUsageValue( vDASR,  vldcAccnt, vSupplier, vVendor, vMeterList, vCustomer, vContract, vContractTerm);
            }
            vAccount.Change_Effective_Date = vDASR.Change_Effective_Date__c != null ? IntegrationUtil.convertDateToString(vDASR.Change_Effective_Date__c) : IntegrationUtil.convertDateToString(vDASR.DASR_Submit_Date__c.date());
            
        }
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_DROP)){
            Bill_Method__c tBM = vDASR.Contract_Bill_Method__c != null ?  BillMethodUtil.getBillMethodByName(vDASR.Contract_Bill_Method__c) : null;
            vAccount.Aggregator = vCustomer.Muni_Agg_Type__c  != null ? vCustomer.Muni_Agg_Type__c : ''; 
            vAccount.Bill_Calculator = tBM !=null && tBM.Bill_Calculator__c != null ? tBM.Bill_Calculator__c : ''; // example 'LDC'
            vAccount.Bill_Presenter = tBM !=null && tBM.Bill_Presenter__c != null ? tBM.Bill_Presenter__c : ''; // example 'LDC'
            //vAccount.Budget_Amount = '0';
            vAccount.Budget_AmountSpecified = true;
            vAccount.Contract_Effective_Date = vDASR.Contract_End_Date__c != null ? IntegrationUtil.convertDateToString(vDASR.Contract_End_Date__c) : '';
            vAccount.Change_Effective_Date =  IntegrationUtil.convertDateToString(vDASR.Drop_Date__c);
            vAccount.Service_End_Date = IntegrationUtil.convertDateToString(vDASR.Drop_Date__c);
            //vAccount.Contract_Effective_Time = '0001';
            //vAccount.Contract_Effective_Time_Zone = 'ET';
            
            //vAccount.ESP_Account_Number = vldcAccnt.ESP_Account_Number__c != null ? vldcAccnt.ESP_Account_Number__c : '1871754';
            vAccount.ESP_Account_Number = vldcAccnt.Id;
            
            if(vVendor != null && vVendor.Name != null && (vVendor.Name.containsIgnoreCase('Ohio Power') || vVendor.Name.containsIgnoreCase('Columbus Southern Power'))){
                vAccount.SDP_Number = vldcAccnt.LDC_Account_Number__c;
            }
            else{
                vAccount.LDC_Account_Number = vldcAccnt.LDC_Account_Number__c;
            }
            if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_state__c.containsIgnoreCase('IL'))){
                vAccount.Drop_Type_Code ='ON';
            }
            //vAccount.LDC_Account_Number = vldcAccnt.LDC_Account_Number__c;
            //vAccount.SDP_Number = tLDC.SDP_Number__c;
            //Always pass value of N which means detail information is requested. Y means Summary
            //vAccount.Secondary_Service_Summary_Interval_Request_Code = EDIIntegrationConfigUtil.getIntRequestCode();
            vAccount.Sender_Transaction_ID = vDASR.Id;
            string rsnCode=ChangeReasonUtil.getDropCodeForVal(vDASR.Drop_Reason__c,'LDC_Account__c');
            vAccount.Drop_Reason_Code = rsnCode;
            
            if(rsnCode == 'A13' || vDASR.Drop_Reason__c == 'Other'){
                vAccount.Drop_Reason_Description = vDASR.Drop_Reason_Description__c;
            }
            vAccount.Service_End_Date = IntegrationUtil.convertDateToString(vDASR.Drop_Date__c);
        } 
        //Added for Dynegy Initiated GAAR
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_REINSTAT)){
            vAccount.Sender_Transaction_ID = vDASR.Id;
            vAccount.ESP_Account_Number = vldcAccnt.Id;
         // vAccount.LDC_Account_Number = vldcAccnt.LDC_Account_Number__c;
            if(vVendor != null && vVendor.Name != null && (vVendor.Name.containsIgnoreCase('Ohio Power') || vVendor.Name.containsIgnoreCase('Columbus Southern Power'))){
                vAccount.SDP_Number = vldcAccnt.LDC_Account_Number__c;
            }else{
                vAccount.LDC_Account_Number = vldcAccnt.LDC_Account_Number__c;
            }
        }           
        return vAccount;
    }  
    
    public static dynegyComEDIServices.ArrayOfCTG_Account_Exception_Info getAcctExcByTran(DASR_Request__c vDASR, LDC_Account__c vldcAccnt,Supplier__c vSupplier,LDC_Vendor__c vVendor,List<Meter__c> vMeterList,Account vCustomer,Contract vContract, List<Contract_Term__c> vContractTerm)
    {
        dynegyComEDIServices.ArrayOfCTG_Account_Exception_Info vActExtInfo = new dynegyComEDIServices.ArrayOfCTG_Account_Exception_Info();
        dynegyComEDIServices.CTG_Account_Exception_Info[] vListAcctExtInfo = new List<dynegyComEDIServices.CTG_Account_Exception_Info>();
        dynegyComEDIServices.CTG_Account_Exception_Info vAccount_Exception_Info;
        dynegyComEDIServices.CTG_Account_Exception_Info vAccount_Exception_Info1;
        dynegyComEDIServices.CTG_Account_Exception_Info vAccount_Exception_Info2;
        dynegyComEDIServices.CTG_Account_Exception_Info vAccount_Exception_Info3;
        
        
        
        if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_ENROL)){
            //No exception for enrollment
        }
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_CHANGE)){
            ChangeReason__c myChngRsn = ChangeReasonUtil.getChgRsnCodeForVal(vDASR.Change_Reason__c);
            String newBillMethod = vDASR.Bill_Method__c != null && vDASR.Bill_Method__c != '' ? vDASR.Bill_Method__c : vDASR.Contract_Bill_Method__c;
            String oldBillMethod = vldcAccnt.Bill_Method__c != null && vldcAccnt.Bill_Method__c != '' ? vldcAccnt.Bill_Method__c : (vDASR.Bill_Method__c != null && vDASR.Bill_Method__c != '' ? vDASR.Contract_Bill_Method__c : null);
            
            if(vDASR.Change_Reason__c != null && myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFBLT')){
            // Changes for IL Dynegy Initiated DASR'section
                         
                if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_state__c.containsIgnoreCase('IL'))){
                  vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                    vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                    vAccount_Exception_Info.Exception_Type_Code = 'CH';
                    vAccount_Exception_Info.Reason_Code = 'REFBLT';
                    vAccount_Exception_Info.Reason_Description = 'Bill Option Change';
                    
                    vAccount_Exception_Info1 = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                    vAccount_Exception_Info1.Sender_Transaction_ID = vDASR.Id;
                    vAccount_Exception_Info1.Exception_Type_Code = 'CH';
                    vAccount_Exception_Info1.Reason_Code = 'REFPC';
                    vAccount_Exception_Info1.Reason_Description = 'Bill Calculator';
                    
                    vAccount_Exception_Info2 = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                    vAccount_Exception_Info2.Sender_Transaction_ID = vDASR.Id;
                    vAccount_Exception_Info2.Exception_Type_Code = 'CH';
                    vAccount_Exception_Info2.Reason_Code = 'REF9V';
                    vAccount_Exception_Info2.Reason_Description = 'Change Payment Option(Consolidated Billing Only)';
                    
                    vListAcctExtInfo.add(vAccount_Exception_Info);
                    vListAcctExtInfo.add(vAccount_Exception_Info1);
                    vListAcctExtInfo.add(vAccount_Exception_Info2);
                }
                    // Changes for IL Dynegy Initiated DASR'section
                else{
                    //if(vDASR.Contract_Bill_Method__c != null && vDASR.Contract_Bill_Method__c.equalsIgnoreCase('DUAL') && vDASR.Bill_Method__c.equalsIgnoreCase('Rate Ready'))
                    if((oldBillMethod == null || oldBillMethod.equalsIgnoreCase('DUAL')) && newBillMethod != null && newBillMethod.equalsIgnoreCase('Rate Ready')){
                        //For bill method change pass two account exception 
                        //1) for bill method change reason code and
                        //2) for bill calculator change reason code
                        //3) for rate code change reason code
                        vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                        vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                        vAccount_Exception_Info.Exception_Type_Code = 'CH';
                        vAccount_Exception_Info.Reason_Code = 'REFBLT';
                            
                        vAccount_Exception_Info1 = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                        vAccount_Exception_Info1.Sender_Transaction_ID = vDASR.Id;
                        vAccount_Exception_Info1.Exception_Type_Code = 'CH';
                        vAccount_Exception_Info1.Reason_Code = 'REFPC';

                        vListAcctExtInfo.add(vAccount_Exception_Info);
                        vListAcctExtInfo.add(vAccount_Exception_Info1);
                    }
                    //else if(vDASR.Contract_Bill_Method__c != null && vDASR.Contract_Bill_Method__c.equalsIgnoreCase('Rate Ready') && vDASR.Bill_Method__c.equalsIgnoreCase('DUAL'))
                    else if((oldBillMethod == null || oldBillMethod.equalsIgnoreCase('Rate Ready')) && newBillMethod != null && newBillMethod.equalsIgnoreCase('DUAL')){
                        //For bill method change pass two account exception 
                        //1) for bill method change reason code and
                        //2) for bill calculator change reason code

                        vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                        vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                        vAccount_Exception_Info.Exception_Type_Code = 'CH';
                        vAccount_Exception_Info.Reason_Code = 'REFBLT';
                            
                      vAccount_Exception_Info1 = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                      vAccount_Exception_Info1.Sender_Transaction_ID = vDASR.Id;
                      vAccount_Exception_Info1.Exception_Type_Code = 'CH';
                      vAccount_Exception_Info1.Reason_Code = 'REFPC';

                        vListAcctExtInfo.add(vAccount_Exception_Info);
                        vListAcctExtInfo.add(vAccount_Exception_Info1);
                    }
                    //else if(vDASR.Contract_Bill_Method__c != null && vDASR.Contract_Bill_Method__c.equalsIgnoreCase('DUAL') && vDASR.Bill_Method__c.equalsIgnoreCase('Bill Ready'))
                    else if((oldBillMethod == null || oldBillMethod.equalsIgnoreCase('DUAL')) && newBillMethod != null && newBillMethod.equalsIgnoreCase('Bill Ready')){
                        //For bill method change pass two account exception 
                        //1) for bill method change reason code
                        vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                        vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                        vAccount_Exception_Info.Exception_Type_Code = 'CH';
                        vAccount_Exception_Info.Reason_Code = 'REFBLT';

                        vListAcctExtInfo.add(vAccount_Exception_Info);
                    }
                    //else if(vDASR.Contract_Bill_Method__c != null && vDASR.Contract_Bill_Method__c.equalsIgnoreCase('Bill Ready') && vDASR.Bill_Method__c.equalsIgnoreCase('DUAL'))
                    else if((oldBillMethod == null || oldBillMethod.equalsIgnoreCase('Bill Ready')) && newBillMethod != null && newBillMethod.equalsIgnoreCase('DUAL')){
                        //For bill method change pass two account exception 
                        //1) for bill method change reason code
                        vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                        vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                        vAccount_Exception_Info.Exception_Type_Code = 'CH';
                        vAccount_Exception_Info.Reason_Code = 'REFBLT';
                            
                        vListAcctExtInfo.add(vAccount_Exception_Info);
                    }
                    //else if(vDASR.Contract_Bill_Method__c != null && vDASR.Contract_Bill_Method__c.equalsIgnoreCase('Rate Ready') && vDASR.Bill_Method__c.equalsIgnoreCase('Bill Ready'))
                    else if((oldBillMethod == null || oldBillMethod.equalsIgnoreCase('Rate Ready')) && newBillMethod != null && newBillMethod.equalsIgnoreCase('Bill Ready')){
                        //For bill method change pass two account exception 
                        //1) for bill method change reason code
                        vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                        vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                        vAccount_Exception_Info.Exception_Type_Code = 'CH';
                        vAccount_Exception_Info.Reason_Code = 'REFPC';
                            
                        vListAcctExtInfo.add(vAccount_Exception_Info);
                    }
                    //else if(vDASR.Contract_Bill_Method__c != null && vDASR.Contract_Bill_Method__c.equalsIgnoreCase('Bill Ready') && vDASR.Bill_Method__c.equalsIgnoreCase('Rate Ready'))
                    else if((oldBillMethod == null || oldBillMethod.equalsIgnoreCase('Bill Ready')) && newBillMethod != null && newBillMethod.equalsIgnoreCase('Rate Ready')){
                        //For bill method change pass two account exception 
                        //1) for bill method change reason code and
                        //2) for bill calculator change reason code
                            
                        vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();  
                        vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                        vAccount_Exception_Info.Exception_Type_Code = 'CH';
                        vAccount_Exception_Info.Reason_Code = 'REFPC';
                            
                        vListAcctExtInfo.add(vAccount_Exception_Info);
                    }
                }
                vActExtInfo.CTG_Account_Exception_Info = vListAcctExtInfo;
            }
            else if(vDASR.Change_Reason__c != null && myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c == 'REFPG'){
                
                vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();
                vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                vAccount_Exception_Info.Reason_Code = 'REFPG';
                
                vListAcctExtInfo.add(vAccount_Exception_Info);
                vActExtInfo.CTG_Account_Exception_Info = vListAcctExtInfo;
            }
            else if(vDASR.Change_Reason__c != null && myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REF17')){
                //TBD- Check logic for exception type code
                //No exception info will be defined in Salesforce for DASR outbound request 
                vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();
                vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                vAccount_Exception_Info.Exception_Type_Code = 'CH';
                vAccount_Exception_Info.Reason_Code = 'REF17';
                
                vListAcctExtInfo.add(vAccount_Exception_Info);
                
                vActExtInfo.CTG_Account_Exception_Info = vListAcctExtInfo;
            }
            else if(vDASR.Change_Reason__c != null && myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFRB')){
                // Changes for IL Dynegy Initiated DASR'section
                system.debug('**********Service State2*************'+vVendor.Service_state__c);
                if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_state__c.containsIgnoreCase('IL'))){
                    system.debug('**********Service State2*************'+vVendor.Service_state__c);
                    vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();
                    vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                    vAccount_Exception_Info.Exception_Type_Code = 'CH';
                    vAccount_Exception_Info.Reason_Code = ChangeReasonUtil.getChgRsnCodeForVal(vDASR.Change_Reason__c, 'LDC_Account__c');
                    
                    vListAcctExtInfo.add(vAccount_Exception_Info);
                    vActExtInfo.CTG_Account_Exception_Info = vListAcctExtInfo;
                }
              // Changes for IL Dynegy Initiated DASR'section
                else {
                        // NO Account Exceptions
                }
            }
            else if(vDASR.Change_Reason__c != null && myChngRsn != null && myChngRsn.Reason_Code__c != null && !myChngRsn.Reason_Code__c.equalsIgnoreCase('REFRB')){
                vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info();
                vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                vAccount_Exception_Info.Exception_Type_Code = 'CH';
                vAccount_Exception_Info.Reason_Code = ChangeReasonUtil.getChgRsnCodeForVal(vDASR.Change_Reason__c, 'LDC_Account__c');
                        
                vListAcctExtInfo.add(vAccount_Exception_Info);
                vActExtInfo.CTG_Account_Exception_Info = vListAcctExtInfo;
             
            }
        }
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_DROP)){
            //No exception for drops
            if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_State__c.containsignorecase('IL'))){
                if(vldcAccnt.LDC_Account_Status__c != null && vldcAccnt.LDC_Account_Status__c.equalsIgnoreCase('PENDING_ENROLLMENT')){
                  vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info(); 
                
                  vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                  vAccount_Exception_Info.Exception_Type_Code = 'ST';
                  vAccount_Exception_Info.Reason_Code = 'EB3';
                  vAccount_Exception_Info.Reason_Description = 'Rescission of an Enrollment';
                  
                  vListAcctExtInfo.add(vAccount_Exception_Info);  
                  vActExtInfo.CTG_Account_Exception_Info = vListAcctExtInfo;
              }
                else{
                    //No exception for drops
                }
            }
            else{
                //No exception for drops
            }
        } 
        //Added for dynegy initiated GAAR  
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_REINSTAT)){    
            if(vVendor.service_state__c != null && (vVendor.service_state__c.containsIgnorecase('OH'))){
                vAccount_Exception_Info = new dynegyComEDIServices.CTG_Account_Exception_Info(); 
                system.debug('===========================DASRID====================='+vDASR.Id);
                vAccount_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                vAccount_Exception_Info.Exception_Type_Code = 'ST';
                vAccount_Exception_Info.Reason_Code = 'EB3';
                
                vListAcctExtInfo.add(vAccount_Exception_Info);  
                vActExtInfo.CTG_Account_Exception_Info = vListAcctExtInfo;
            }
        }          
        return vActExtInfo;
    }    
    public static dynegyComEDIServices.CTG_Meter getMeterByTran(DASR_Request__c vDASR, LDC_Account__c vldcAccnt,Supplier__c vSupplier,LDC_Vendor__c vVendor,List<Meter__c> vMeterList,Account vCustomer,Contract vContract, List<Contract_Term__c> vContractTerm)
    {
        dynegyComEDIServices.CTG_Meter vMeter = new dynegyComEDIServices.CTG_Meter();
        if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_ENROL)){   
            //if(vMeterList == null || vMeterList.isEmpty())
            //{   
                //Meter section is not required for enrollment
            vMeter.Sender_Transaction_ID = vDASR.Id;
            vMeter.Meter_Number= EDIIntegrationConfigUtil.getIntDefMeterNumber();
            if(vDASR.Contract_Bill_Method__c != null){
                Bill_Method__c tBM = vDASR.Contract_Bill_Method__c != null ?  BillMethodUtil.getBillMethodByName(vDASR.Contract_Bill_Method__c) : null;
                if(tBM != null && tBM.Bill_Calculator__c != null && tBM.Bill_Presenter__c != null && tBM.Bill_Calculator__c.equalsIgnoreCase('LDC') && tBM.Bill_Presenter__c.equalsIgnoreCase('LDC')){
                    vMeter.ESP_Rate_Code= vDASR.Contract_Rate_Code__c != null ? vDASR.Contract_Rate_Code__c : '' ;
                }
            }
            //Changed for IL Dynegy Initiated
                        
            if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_state__c.containsIgnoreCase('IL'))){
              if(vDASR.Service_Point__c != null){
                  vMeter.SDP_Number = vDASR.Service_Point__c;
              }   
              else 
                vMeter.SDP_Number ='';
            }
            //Changed for IL Dynegy Initiated
            //vMeter.Meter_Maintenance_Code = 'MQ';
            //}
        }
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_CHANGE)){
            ChangeReason__c myChngRsn = ChangeReasonUtil.getChgRsnCodeForVal(vDASR.Change_Reason__c);
            //Bill_Method__c tBM = vDASR.Contract_Bill_Method__c != null ?  BillMethodUtil.getBillMethodByName(vDASR.Bill_Method__c) : null;
            //Changed for IL Dynegy Initiated
            
            if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_state__c.containsIgnoreCase('IL'))){
                Bill_Method__c tBM = vDASR.Bill_Method__c != null ? BillMethodUtil.getBillMethodByName(vDASR.Bill_Method__c) : BillMethodUtil.getBillMethodByName(vDASR.Contract_Bill_Method__c) ;
                if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFBLT')){
                    vMeter.Sender_Transaction_ID = vDASR.Id;
                    vMeter.Meter_Number= EDIIntegrationConfigUtil.getIntDefMeterNumber();
                
                    if(tBM != null && tBM.Bill_Calculator__c != null && tBM.Bill_Presenter__c != null && tBM.Bill_Calculator__c.equalsIgnoreCase('LDC') && tBM.Bill_Presenter__c.equalsIgnoreCase('LDC')){
                        vMeter.ESP_Rate_Code= vDASR.Contract_Rate_Code__c ;
                    }
                    if(vDASR.Service_Point__c != null){
                        vMeter.SDP_Number = vDASR.Service_Point__c;
                    }   
                    else{
                      vMeter.SDP_Number ='';
                  }
                    vMeter.Meter_Maintenance_Code = 'MQ';            
                }   
                else if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFRB')){
                    vMeter.Sender_Transaction_ID = vDASR.Id;
                    vMeter.Meter_Number= EDIIntegrationConfigUtil.getIntDefMeterNumber();
                    if(tBM != null && tBM.Bill_Calculator__c != null && tBM.Bill_Presenter__c != null && tBM.Bill_Calculator__c.equalsIgnoreCase('LDC') && tBM.Bill_Presenter__c.equalsIgnoreCase('LDC')){
                        vMeter.ESP_Rate_Code= vDASR.Contract_Rate_Code__c ;
                    }
                    if(vDASR.Service_Point__c != null){
                        vMeter.SDP_Number = vDASR.Service_Point__c;
                    }   
                    else{ 
                      vMeter.SDP_Number ='';
                  }
                    vMeter.Meter_Maintenance_Code = 'MQ';
                }
      }
          else {  
              if(vMeterList == null || vMeterList.isEmpty()){
                  //Bill method change and value changing to rate ready
                  if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFBLT') && vDASR.Contract_Bill_Method__c  != null && vDASR.Contract_Bill_Method__c.equalsIgnoreCase('Rate Ready')){
                      vMeter.Sender_Transaction_ID = vDASR.Id;
                      vMeter.Meter_Number= EDIIntegrationConfigUtil.getIntDefMeterNumber();
                      
                      vMeter.ESP_Rate_Code= vDASR.Contract_Rate_Code__c ;
                      vMeter.Meter_Maintenance_Code = 'MQ';                    
                  }
                  else if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFRB')){
                      vMeter.Sender_Transaction_ID = vDASR.Id;
                      vMeter.Meter_Number= EDIIntegrationConfigUtil.getIntDefMeterNumber();
                      
                      vMeter.ESP_Rate_Code= vDASR.Contract_Rate_Code__c ;
                      vMeter.Meter_Maintenance_Code = 'MQ';
                  }
              }
              else if(vMeterList != null && !vMeterList.isEmpty() && myChngRsn != null){
                  if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFBLT') && vDASR.Contract_Bill_Method__c  != null && vDASR.Contract_Bill_Method__c.equalsIgnoreCase('Rate Ready')){
                      vMeter.Sender_Transaction_ID = vDASR.Id;
                      vMeter.Meter_Number= EDIIntegrationConfigUtil.getIntDefMeterNumber();
                      
                      vMeter.ESP_Rate_Code= vDASR.Contract_Rate_Code__c ;
                      vMeter.Meter_Maintenance_Code = 'MQ';                    
                  }
                  else if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFRB')){
                      vMeter.Sender_Transaction_ID = vDASR.Id;
                      vMeter.Meter_Number= EDIIntegrationConfigUtil.getIntDefMeterNumber();
                      vMeter.ESP_Rate_Code= vDASR.Contract_Rate_Code__c ;
                      vMeter.Meter_Maintenance_Code = 'MQ';
                  }
              }
          }
        }
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_DROP)){
            //No meter information for drop
        } 
        //Added for Dynegy intiated GAAR
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_REINSTAT)){
            //No meter information
            if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_State__c.containsignorecase('IL'))){
              if(vDASR.Service_Point__c != null){
                    vMeter.Sender_Transaction_ID = vDASR.Id;
                    vMeter.SDP_Number = vDASR.Service_Point__c;
                }   
              else {
                    //No Meter information 
                }
            }
            else{
                //No Meter information for OH
            }
        }         
        return vMeter;
    }
    public static dynegyComEDIServices.CTG_Meter_Exception_Info getMeterExcByTran(DASR_Request__c vDASR, LDC_Account__c vldcAccnt,Supplier__c vSupplier,LDC_Vendor__c vVendor,List<Meter__c> vMeterList,Account vCustomer,Contract vContract, List<Contract_Term__c> vContractTerm)
    {
        dynegyComEDIServices.CTG_Meter_Exception_Info vMeter_Exception_Info = new dynegyComEDIServices.CTG_Meter_Exception_Info();
        if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_ENROL)){
            if(vMeterList == null || vMeterList.isEmpty()){
                //No logic required at the moment
            }
        }
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_CHANGE)){
            ChangeReason__c myChngRsn = ChangeReasonUtil.getChgRsnCodeForVal(vDASR.Change_Reason__c);
            if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFBLT') && vDASR.Contract_Bill_Method__c  != null && vDASR.Contract_Bill_Method__c.equalsIgnoreCase('Rate Ready')){
                vMeter_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                vMeter_Exception_Info.Meter_Number = EDIIntegrationConfigUtil.getIntDefMeterNumber();
                vMeter_Exception_Info.Exception_Type_Code = 'CH';//ChangeReasonUtil.getChgRsnCodeForVal(vMeterList[0].Change_Reason__c, 'Meter__c');
                vMeter_Exception_Info.Reason_Code = 'REFRB';
            }
            else if((vMeterList == null || vMeterList.isEmpty()) && myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFRB')){
                if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_State__c.containsignorecase('IL'))){
                    //NO Meter Exception for IL
                }
                else{    
                  vMeter_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                  vMeter_Exception_Info.Meter_Number = EDIIntegrationConfigUtil.getIntDefMeterNumber();
                  vMeter_Exception_Info.Exception_Type_Code = 'CH';//ChangeReasonUtil.getChgRsnCodeForVal(vMeterList[0].Change_Reason__c, 'Meter__c');
                  vMeter_Exception_Info.Reason_Code = myChngRsn.Reason_Code__c;
                }
            }
            else if(vMeterList != null && !vMeterList.isEmpty() && myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFRB')){   
                if(vVendor != null && vVendor.Service_state__c != null && (vVendor.Service_State__c.containsignorecase('IL'))){
                    //NO Meter Exception for IL
                }
                else{ 
                    vMeter_Exception_Info.Sender_Transaction_ID = vDASR.Id;
                    vMeter_Exception_Info.Meter_Number = EDIIntegrationConfigUtil.getIntDefMeterNumber();
                    vMeter_Exception_Info.Exception_Type_Code = 'CH';//ChangeReasonUtil.getChgRsnCodeForVal(vMeterList[0].Change_Reason__c, 'Meter__c');
                    vMeter_Exception_Info.Reason_Code = ChangeReasonUtil.getChgRsnCodeForVal(vDASR.Change_Reason__c, 'Meter__c');
            }
            }
        }
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_DROP)){
            //No logic required at the moment
        }  
        //Added for Dynegy intiated GAAR
        else if(vDASR != null && vDASR.DASR_Type__c.equalsIgnorecase(EDIConstantUtil.DASR_TYPE_REINSTAT)){
            //No logic required
        }   
        return vMeter_Exception_Info;
    }
}