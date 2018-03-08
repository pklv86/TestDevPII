public class EDIOutboundMessageValidator 
{
    //public final static String DASR_ENROLLMENT = 'GAAE';
    //public final static String DASR_DROP = 'GAAD';
    //public final static String DASR_CHANGE = 'GAAC';
    //public final static String DASR_REINSTATEMENT = 'GAAR';
    
    public static List<String> isValLDCFromSFDCEnrolMsg(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        if(ldcAccount == null || dasrReq == null)
        {
            lstErrors.add(Label.EDI_Invalid_Request);
            return lstErrors;
        }
        //Enrollment
        if(dasrReq.DASR_Type__c == EDIConstantUtil.DASR_TYPE_ENROL)
        {
            lstErrors.addAll(validateCommonFields( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //lstErrors.addAll(validateAddress( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            
        }
        //Check for contract start date
        if(dasrReq.Contract_Counter_Signed_Date__c == null)
        {
            lstErrors.add(Label.EDI_Invalid_Contract_Counter_Signed_Date);
        }
        //Check for future contract start date
        if(dasrReq.Contract_Counter_Signed_Date__c != null && dasrReq.Contract_Counter_Signed_Date__c > system.today().addDays(1))
        {
            lstErrors.add(Label.EDI_Invalid_Future_Contract_Counter_Signed_Date);
        }
        
        //Check for contract start date
        if(dasrReq.Contract_Start_Date__c  == null)
        {
            lstErrors.add(Label.EDI_Invalid_Contract_Effective_Date);
        }
        
        //Check for rate code
        if(dasrReq.Contract_Rate_Code__c  == null || String.isEmpty(dasrReq.Contract_Rate_Code__c))
        {
            //lstErrors.add(Label.EDI_Invalid_Rate_Code);
        }
        
        Bill_Method__c tBM = dasrReq.Contract_Bill_Method__c != null ?  BillMethodUtil.getBillMethodByName(dasrReq.Contract_Bill_Method__c) : null;
        
        //Check for bill presenter 
        if(tBM == null || tBM.Bill_Presenter__c == null || tBM.Bill_Presenter__c == '')
        {
            lstErrors.add(Label.EDI_Invalid_Bill_Presenter);   
        }     
        
        //Check for bill calculator
        if(tBM == null || tBM.Bill_Calculator__c == null || tBM.Bill_Calculator__c == '')
        {
            lstErrors.add(Label.EDI_Invalid_Bill_Calculator);   
        } 

        system.debug('ldc : '+ldcAccount.Account__r.Muni_Agg_Type__c+' Account : '+customer.Business_Account__r.Muni_Agg_Type__c+' STerritory : '+ldcaccount.service_territory__c+' Utility : '+ldcaccount.LDC_Vendor__r.Utility_Code__c); 
        
        if(ldcAccount.account__r.RecordType.name == 'Muni Agg Individual Customer' || customer.Business_Account__r.RecordType.name == 'Muni Agg Customer'){
            if(ldcaccount.Account__r.Muni_Agg_Type__c == 'GAG' || customer.Business_Account__r.Muni_Agg_Type__c == 'GAG'){
                if(ldcaccount.service_territory__c == 'DAYTON' && ldcaccount.LDC_Vendor__r.Utility_Code__c == 'DPL'){
                    if(ldcAccount.account__r.Aggregator_Code__c != customer.Business_Account__r.Aggregator_Code__c) {
                        lstErrors.add(Label.EDI_Invalid_Aggregator_Code); 
                    }
                    else if(ldcAccount.account__r.Aggregator_Code__c == null || customer.Business_Account__r.Aggregator_Code__c == null) {
                        lstErrors.add('Aggregator Code is Required'); 
                    }
                }
                else if(customer.Business_Account__r.Aggregator_Code__c != null ){
                    if(ldcAccount.account__r.Aggregator_Code__c == null){
                        lstErrors.add('Aggregator code is not populated on person customer');
                    }
                    else if(ldcAccount.account__r.Aggregator_Code__c != customer.Business_Account__r.Aggregator_Code__c) {
                        lstErrors.add(Label.EDI_Invalid_Aggregator_Code); 
                    }
                }
            }
            else if(ldcaccount.Account__r.Muni_Agg_Type__c == null || customer.Business_Account__r.Muni_Agg_Type__c == null){
                lstErrors.add('Aggregator/Muni-agg Type is Required');
            }
        }
        
        return lstErrors;
    }
    
    public static List<String> isValLDCFromSFDCDropMsg(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        if(ldcAccount == null || dasrReq == null)
        {
            lstErrors.add(Label.EDI_Invalid_Request);
        }
        //Drop 
        if(dasrReq.DASR_Type__c == EDIConstantUtil.DASR_TYPE_DROP)
        {
            lstErrors.addAll(validateCommonFields( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //Check for drop reason
            //Below condition is Addded for IL since it does not send the drop reason
            if(ldcAccount != null ){
                if(!ldcAccount.Service_territory__c.contains('-IL')){
                    if(String.isBlank(dasrReq.Drop_Reason__c))
                    {
                        lstErrors.add(Label.Invalid_Drop_Reason);
                    }
                    //Check for drop date date
                    if(dasrReq.Drop_Date__c == null)
                    {
                        lstErrors.add(Label.EDI_Invalid_Contract_End_Date);
                    }  
                }
            }      
        }
        return lstErrors;
    }
    public static List<String> isValLDCFromSFDCChngMsg(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        if(ldcAccount == null || dasrReq == null)
        {
            lstErrors.add(Label.EDI_Invalid_Request);
        }
        //Change
        if(dasrReq.DASR_Type__c == EDIConstantUtil.DASR_TYPE_CHANGE)
        {
            lstErrors.addAll(validateCommonFields( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //lstErrors.addAll(validateAddress( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            
            //Check for change reason
            if(String.isBlank(dasrReq.Change_Reason__c))
            {
                lstErrors.add(Label.EDI_Invalid_Change_Reason);
            }
            String codeVal = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c, 'LDC_Account__c');
            if(codeVal != null && codeVal.equalsIgnoreCase('A13') && (dasrReq.Reason_Description__c == null || String.isEmpty(dasrReq.Reason_Description__c)))
            {
                lstErrors.add(Label.EDI_Invalid_Reason_Description);
            }
            ChangeReason__c myChngRsn = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
            if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFBLT') && (dasrReq.Contract_Bill_Method__c == null || String.isEmpty(dasrReq.Contract_Bill_Method__c)))
            {
                lstErrors.add(Label.EDI_Invalid_Bill_Method);
            }
            if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REF17') && (dasrReq.Contract_Interval_Usage__c == null || String.isEmpty(dasrReq.Contract_Interval_Usage__c)))
            {
                lstErrors.add(Label.EDI_Invalid_Interval_Usage );
            }
            if(myChngRsn != null && myChngRsn.Reason_Code__c != null && myChngRsn.Reason_Code__c.equalsIgnoreCase('REFRB') && (dasrReq.Contract_Rate_Code__c == null || String.isEmpty(dasrReq.Contract_Rate_Code__c)) && !dasrReq.Recipient_Name__c.containsignorecase('Ameren'))
            {
                lstErrors.add(Label.EDI_Invalid_Rate_Code );
            }            
             
            
        }
        return lstErrors;
    }
    //Added for Dynegy Initiated GAAR
    public static List<String> isValLDCFromSFDCReinstateMsg(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        if(ldcAccount == null || dasrReq == null)
        {
            lstErrors.add(Label.EDI_Invalid_Request);
        }
        //Reinstate
        if(dasrReq.DASR_Type__c == EDIConstantUtil.DASR_TYPE_REINSTAT)
        {
            lstErrors.addAll(validateCommonFields( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //lstErrors.addAll(validateAddress( ldcAccount,  customer,  ldcVendor, lstMeter, supplier,  contract, lstContTerm,dasrReq));
            //check for dasr submit date
            if(dasrReq.DASR_Submit_Date__c==null){
                lstErrors.add(Label.EDI_InValid_DASR_Submit_Date);
            }
            //check for the Dynegy initiated DASR
            if(dasrReq.Dynegy_Initiated__c==false){
                lstErrors.add(Label.EDI_InValid_DASR);
            } 
        }
        return lstErrors;
    }
    
    public static List<String> validateAddress(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        
        //Check for service address
        if(String.isBlank(ldcAccount.Service_Street_1__c))
        {
            lstErrors.add(Label.EDI_Invalid_Service_Address);
        }
        
        //Check for service city
        if(String.isBlank(ldcAccount.Service_City__c))
        {
            lstErrors.add(Label.EDI_Invalid_City);
        }
        //Check for service state
        if(String.isBlank(ldcAccount.Service_State__c))
        {
            lstErrors.add(Label.EDI_Invalid_State);
        }            
        //Check for billing address
        if(String.isBlank(customer.BillingStreet))
        {
            lstErrors.add(Label.EDI_Invalid_Billing_Street);
        }
        
        //Check for billing city
        if(String.isBlank(customer.BillingCity))
        {
            lstErrors.add(Label.EDI_Invalid_Billing_City );
        }
        //Check for billing state
        if(String.isBlank(customer.BillingState))
        {
            lstErrors.add(Label.EDI_Invalid_Billing_State );
        } 
        return lstErrors;
    }
    public static List<String> validateCommonFields(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor, List<Meter__c> lstMeter,Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        System.debug('\n dasrReq='+dasrReq);
        if(ldcAccount == null)
        {
            lstErrors.add(Label.EDI_Invalid_LDC_Account);
            return lstErrors;
        }
        //Check for supplier duns
        if(String.isBlank(dasrReq.Originator_DUNS__c))
        {
            lstErrors.add(Label.EDI_Originator_DUNS);
        }
        
        //Check for vendor duns
        if(String.isBlank(dasrReq.Recipient_DUNS__c))
        {
            lstErrors.add(Label.EDI_Vendor_DUNS);
        }
        //Check for contract start date
        
        // if(ldcAccount.LDC_Start_Date__c == null)
        // {
        //    lstErrors.add(Label.EDI_Invalid_Start_Date);
        // }
        
        //Check for LDC Number
        if(ldcAccount == null || ldcAccount.LDC_Account_Number__c == null || String.isBlank(ldcAccount.LDC_Account_Number__c))
        {
            lstErrors.add(Label.Invalid_LDC_Number);
        }    
        

        
        return lstErrors;
    }
/**
    public static List<String> validOldMeterNumber(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('MX') && (supplier == null || supplier.Supplier_DUNS__c !='006999189'))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.Old_Meter_Number__c == null)
            {
                lstErrors.add(Label.EDI_Invalid_Old_Meter_Number);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLoadProfileDesc(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('CH') && tCH.Reason_Code__c == 'REFLO')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.Load_Profile__c == null)
            {
                lstErrors.add(Label.EDI_Invalid_Load_Profile);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCRateClass(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('CH') && tCH.Reason_Code__c == 'REFNH')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.LDC_Rate_Class__c  == null)
            {
                lstErrors.add(Label.EDI_Invalid_LDC_Rate_Class);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCRateSubClass(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('CH') && tCH.Reason_Code__c == 'REFPR')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.LDC_Rate_Subclass__c  == null)
            {
                lstErrors.add(Label.EDI_Invalid_LDC_Rate_Subclass );   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCMeterCycle(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Maintenance_Code__c != null && tCH.Maintenance_Code__c.equalsIgnoreCase('CH') && tCH.Reason_Code__c == 'REFTZ')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter == null || myMeter.LDC_Meter_Cycle__c  == null)
            {
                lstErrors.add(Label.EDI_Invalid_LDC_Meter_Cycle);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCMeterTypeCode(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && (tCH.Maintenance_Code__c != null && (tCH.Maintenance_Code__c.equalsIgnoreCase('MA') ||tCH.Maintenance_Code__c.equalsIgnoreCase('MX') ) || (tCH.Reason_Code__c == 'REFMT' || tCH.Reason_Code__c == 'NM1MQ')))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  != null && !myMeter.Meter_Number__c.equalsIgnoreCase('All'))
            {
                lstErrors.add(Label.EDI_Invalid_Meter_Type_Code);   
            }
        }
        return lstErrors;
    }
    public static List<String> validLDCMeterMultiplier(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && (tCH.Maintenance_Code__c != null && (tCH.Maintenance_Code__c.equalsIgnoreCase('MA') ||tCH.Maintenance_Code__c.equalsIgnoreCase('MX') ) || (tCH.Reason_Code__c == 'REF4P' || tCH.Reason_Code__c == 'NM1MQ')))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  != null && !myMeter.Meter_Number__c.equalsIgnoreCase('All'))
            {
                lstErrors.add(Label.EDI_Invalid_Meter_Multiplier);   
            }
        }
        return lstErrors;
    }
    public static List<String> validDialsQuantity(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && (tCH.Maintenance_Code__c != null && (tCH.Maintenance_Code__c.equalsIgnoreCase('MA') ||tCH.Maintenance_Code__c.equalsIgnoreCase('MX') ) || (tCH.Reason_Code__c == 'REFIX' || tCH.Reason_Code__c == 'NM1MQ')))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  != null && !myMeter.Meter_Number__c.equalsIgnoreCase('All'))
            {
                lstErrors.add(Label.EDI_Invalid_Dials_Quantity );   
            }
        }
        return lstErrors;
    }
    public static List<String> validTimeOfUseMeter(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && (tCH.Maintenance_Code__c != null && (tCH.Maintenance_Code__c.equalsIgnoreCase('MA') ||tCH.Maintenance_Code__c.equalsIgnoreCase('MX') ) || (tCH.Reason_Code__c == 'REFTU' || tCH.Reason_Code__c == 'NM1MQ')))
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  != null && !myMeter.Meter_Number__c.equalsIgnoreCase('All'))
            {
                lstErrors.add(Label.EDI_Invalid_Time_Of_User  );   
            }
        }
        return lstErrors;
    }
    public static List<String> validServVoltage(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Reason_Code__c == 'REFSV')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  == null || myMeter.Meter_Service_Voltage__c  == null)
            {
                lstErrors.add(Label.Invalid_Meter_Service_Voltage  );   
            }
        }
        return lstErrors;
    }
    public static List<String> validDistLossFactor(LDC_Account__c ldcAccount, Account customer, LDC_Vendor__c ldcVendor,List<Meter__c> lstMeter, Supplier__c supplier, Contract contract, List<Contract_Term__c> lstContTerm,DASR_Request__c dasrReq)
    {
        List<String> lstErrors = new List<String>();
        Map<Id, Meter__c> mapMeter = (new Map<Id, Meter__c>(lstMeter));
        ChangeReason__c tCH = ChangeReasonUtil.getChgRsnCodeForVal(dasrReq.Change_Reason__c);
        if(tCH != null && tCH.Reason_Code__c == 'REFLF')
        {
            Meter__c myMeter = mapMeter != null && dasrReq.Meter__c != null && mapMeter.get(dasrReq.Meter__c) != null ?  mapMeter.get(dasrReq.Meter__c) : null;  
            if(myMeter.Meter_Number__c  == null || myMeter.Distribution_Loss_Factor__c   == null)
            {
                lstErrors.add(Label.EDI_Invalid_Distribution_Loass   );   
            }
        }
        return lstErrors;
    }
**/
}