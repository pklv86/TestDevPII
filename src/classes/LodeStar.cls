/**
 * this class is designed as a container to hold inner classes
 * to be used in the LodeStar Integration.
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.0
 * @version Chaitanya kurra -PA Changes Account Supplement and three new feilds
 **/
global class LodeStar {

    /** 
     * Class used as container for transporting data to LodeStar
     **/
    global class LodeStarDataContainer implements Comparable {
    
        public String customerSFID { get; set; }
        public String customerName { get; set; }
        public String customerShortCode { get; set; }
        public Contract c { get; set; }
        public List<Contract_Term__c> contractTermList { get; set; }
        public Map<Id,List<Contract_LDC__c>> contractLDCMap { get; set; }
        public Map<Id,LDC_Account__c> accountLDCMap { get; set; }
        public Map<Id,List<AccountBillDeterminate__c>> accountBillDeterminateMap{ get; set; }
        public Map<Id,Billing_Group__c> BillingGroupMap {get; Set;}
        public Map<id,List<Billing_Group_Ldc__c>> BillingGroupLDCMap {get; set;}
        public Map<id,List<Peak_Load_Information__c>> PlcLDCMap {get; set;}
        public Map<id,List<Account_Supplement__c>> ASLDCMap {get; set;}
        public Set<Id> processedAccountIdSet { get; set; }
        public Set<Id> processedLDCAccountIdSet { get; set; }
        public Set<Id> processedContractLDCIdSet { get; set; }
        public Set<Id> processedBGroupIdSet { get; set; }
        public Set<Id> processedBGroupLDCIdSet { get; set; }
        
        public LodeStarDataContainer(){
            this.contractLDCMap = new Map<Id,List<Contract_LDC__c>>();
            this.accountLDCMap = new Map<Id,LDC_Account__c>();
            this.contractTermList = new List<Contract_Term__c>();
            this.accountBillDeterminateMap = new Map<Id,List<AccountBillDeterminate__c>>();
            this.BillingGroupMap = new Map<id,Billing_Group__c>();
            this.BillingGroupLDCMap = new Map<id,list<Billing_Group_Ldc__c>>();
            this.PlcLDCMap = new Map<id,List<Peak_Load_Information__c>>();
            this.ASLDCMap = new Map<id,List<Account_Supplement__c>>();
            this.processedLDCAccountIdSet = new Set<Id>();
            this.processedContractLDCIdSet = new Set<Id>();
            this.processedAccountIdSet = new Set<Id>();
            this.processedBGroupIdSet = new Set<Id>();
            this.processedBGroupLDCIdSet = new Set<Id>();
        }
        
        /**
         * This method is designed to take the data contained in the class, and return
         * a populated SforceLstarCustomer Object ready to be used to send to the 
         * Process responsible for building and sending the data through the webservice.
         *
         * @return dynegyComServicesLodeStar.SforceLstarCustomer - customer object populated with data
         **/
        public dynegyComServicesLodeStar.SforceLstarCustomer buildWebServiceObject(){
            //define the customer Web Service Object
            dynegyComServicesLodeStar.SforceLstarCustomer ws_customerObj = new dynegyComServicesLodeStar.SforceLstarCustomer();
            ws_customerObj.CustomerName = this.customerName;
            ws_customerObj.CustomerShortcode = this.customerShortCode;
            //define and populate the Contract Object
            ws_customerObj.Contract = new dynegyComServicesLodeStar.SforceLstarContract();
            ws_customerObj.Contract.BillingAddress = new dynegyComServicesLodeStar.SforceAddress();

            if(this.c != null){
                ws_customerObj.Contract.BillingAddress.AddrLine1 = c.Account.BillingStreet;
                ws_customerObj.Contract.BillingAddress.City = c.Account.BillingCity;
                ws_customerObj.Contract.BillingAddress.State = c.Account.BillingState;
                ws_customerObj.Contract.BillingAddress.Country = c.Account.BillingCountry;
                ws_customerObj.Contract.BillingAddress.Zip = c.Account.BillingPostalCode;
                ws_customerObj.Contract.ApproveTime = c.ActivatedDate;
                ws_customerObj.Contract.Description = c.Description;
                ws_customerObj.Contract.ExecuteTime = c.Contract_Counter_Signed_Date__c;
                ws_customerObj.Contract.ID = c.ContractNumber;
                ws_CustomerObj.Contract.LstarIdentifier = c.LodeStar_Identifier__c;
                ws_customerObj.Contract.MassMarketOfferCode = c.Offer_Code__c;
                ws_customerObj.Contract.OperCompanyCode = c.Supplier__r.Supplier_Code__c; 
                ws_customerObj.Contract.BillMethod = c.Bill_method__c;
                
                //system.debug('*****Opco@contract******' +c.Supplier__r.Supplier_Code__c); 
                //ws_customerObj.Contract.Revision = null
                if(c.StartDate != null) ws_customerObj.Contract.StartTime = Datetime.newInstance(c.StartDate.year(),c.StartDate.month(),c.StartDate.day());
                if(c.End_Date__c != null) ws_customerObj.Contract.StopTime = Datetime.newInstance(c.End_Date__c.year(),c.End_Date__c.month(),c.End_Date__c.day());
                if(c.End_Date__c != null) ws_customerObj.Contract.TerminateTime = Datetime.newInstance(c.End_Date__c.year(),c.End_Date__c.month(),c.End_Date__c.day());
                /*if(c.Contract_Type__c == 'Small Stable Contract - Evergreen' || c.Contract_Type__c == 'Small Stable Contract - MTM Renewal' 
                    || c.Contract_Type__c == 'Large Stable Contract'){
                    if(c.Bill_Method__c == 'DUAL' || c.Bill_Method__c == 'SBO/ESP'){
                        ws_customerObj.Contract.TypeCode = 'TIER_A';
                    }
                    else{
                        ws_customerObj.Contract.TypeCode = 'UCBNONPOR';
                    }
                }
                else if(c.Contract_Type__c == 'Large Stable PT-C Contract' || c.Contract_Type__c == 'Hybrid'){
                    ws_customerObj.Contract.TypeCode = 'TIER_1_2';
                }
                else{
                    ws_customerObj.Contract.TypeCode = c.Contract_Type__c;
                }*/
                Boolean foundNewtype = false;
                for(Contract_Type_Setting__c cts : Contract_Type_Setting__c.getAll().Values()){
                    system.debug('Contract Values -- Type : '+c.Contract_Type__c+' Service Territory : '+c.Service_Territory__c+' BillMethod : '+c.Bill_Method__c);
                    if(cts.New_Contract_Type__c != null && cts.New_Contract_Type__c.equalsIgnorecase(c.Contract_Type__c) 
                            && cts.Service_Territory__c.equalsIgnorecase(c.Service_Territory__c) && cts.Bill_Method__c.equalsIgnorecase(c.Bill_Method__c)){
                        ws_customerObj.Contract.TypeCode = cts.Contract_Type__c;
                        foundNewtype = true;
                    }
                }
                if(!foundNewtype)
                    ws_customerObj.Contract.TypeCode = c.Contract_Type__c;
                ws_customerObj.Contract.ParentContractID = c.Parent_Contract__r.ContractNumber;
                ws_customerObj.Contract.ProductName = c.Product_Name__c;
            }
            
            ws_customerObj.Contract.BillingGroups = new dynegyComServicesLodeStar.ArrayOfSforceLstarBillingGroup();
            ws_customerObj.Contract.BillingGroups.SforceLstarBillingGroup = new list<dynegyComServicesLodeStar.SforceLstarBillingGroup>();
            for(Billing_Group__c bg : BillingGroupMap.values()){
                dynegyComServicesLodeStar.SforceLstarBillingGroup ws_BGroupObj = new dynegyComServicesLodeStar.SforceLstarBillingGroup();
                ws_BGroupObj.Id = bg.id;
                ws_BGroupObj.Name = bg.Name;
                ws_BGroupObj.PseudoContractID = bg.Pseudo_Contract__c;
                ws_BGroupObj.ContractID = bg.Contract_Number__c;
                ws_BGroupObj.StartTime = bg.Start_Date__c;
                ws_BGroupObj.StopTime = bg.Stop_Date__c;
                //ws_BGroupObj.GroupAddressLine1 = bg.Group_Address_Line1__c;
                //ws_BGroupObj.GroupAddressLine2 = bg.Group_Address_Line2__c;
                
                ws_BGroupObj.BillingAddress = new dynegyComServicesLodeStar.SforceAddress();
                ws_BGroupObj.BillingAddress.AddrLine1 = bg.Group_Address_Line1__c;
                ws_BGroupObj.BillingAddress.AddrLine2 = bg.Group_Address_Line2__c;
                ws_BGroupObj.BillingAddress.ICOName = bg.Group_Address_Line3__c;
                ws_BGroupObj.BillingAddress.City = bg.Group_City__c;
                ws_BGroupObj.BillingAddress.State = bg.Group_State__c;
                ws_BGroupObj.BillingAddress.Zip = bg.Group_Postal_Code__c;
                
                ws_customerObj.Contract.BillingGroups.SforceLstarBillingGroup.add(ws_BGroupObj);
                processedBGroupIdSet.add(bg.id);
            }
            
            //define the Accounts Object
            ws_customerObj.Contract.Accounts = new dynegyComServicesLodeStar.ArrayOfSforceLstarAccount();
            ws_customerObj.Contract.Accounts.SforceLstarAccount = new List<dynegyComServicesLodeStar.SforceLstarAccount>();
            for(LDC_Account__c ldcAccount:accountLDCMap.values()){
                dynegyComServicesLodeStar.SforceLstarAccount ws_accountObj = new dynegyComServicesLodeStar.SforceLstarAccount();
                //ws_accountObj.AccountName = ldcAccount.Account__r.Name;                
                if(c.Bill_Method__c == 'DUAL' || c.Bill_Method__c == 'SBO/ESP'){
                    if(ldcAccount.Account__r.Business_Account__c == null && ldcAccount.Account__r.Legal_Entity_Name__c != null){
                        String tempLegal = ldcAccount.Account__r.Legal_Entity_Name__c;
                        Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9\\s-&\']');
                        Matcher matcher = nonAlphanumeric.matcher(tempLegal );
                        tempLegal = matcher.replaceAll('');
                        if(tempLegal.length()>39){
                           tempLegal = tempLegal.left(39);
                        }
                        ws_accountObj.AccountName = tempLegal;            
                    }
                    else{
                        ws_accountObj.AccountName = ldcAccount.Account__r.Name;
                    }
                }
                else{
                    ws_accountObj.AccountName = ldcAccount.Account__r.Name;
                }
                ws_accountObj.BillingCycle = ldcAccount.Bill_Cycle__c;
                ws_accountObj.CrmID = ldcAccount.CRM_Id__c;
                ws_accountObj.DeliveryVoltage = ldcAccount.Delivery_Voltage__c;
                ws_accountObj.LDCAccountNumber = ldcAccount.LDC_Account_Number__c;
                ws_accountObj.LDCCreatedDate = ldcAccount.CreatedDate;
             // ws_accountObj.LDCType = ldcAccount.LDC_Type__c;
                if(ldcAccount.Ldc_type__c == 'Governmental'){
                    ws_accountObj.LDCType = 'GOVT_ENTITY';
                }
                /*else{
                    ws_accountObj.LDCType = ldcAccount.LDC_Type__c;
                }*/
                ws_accountObj.LDCVendor = ldcAccount.LDC_Vendor__r.Name;
                ws_accountObj.LegacyID = ldcAccount.Legacy_ID__c;
                ws_accountObj.OperCompanyCode = ldcAccount.Account__r.Supplier__r.Supplier_Code__c;
                ws_accountObj.ProfileClass = ldcAccount.Acct__c;
                ws_accountObj.RateCode = ldcAccount.Utility_Rate_Class__c;
                ws_accountObj.RevenueClass = ldcAccount.Revenue_Class__c;
                if(ldcAccount.LDC_Start_Date__c != null) ws_accountObj.StartTime = Datetime.newInstance(ldcAccount.LDC_Start_Date__c.year(),ldcAccount.LDC_Start_Date__c.month(),ldcAccount.LDC_Start_Date__c.day());
                ws_accountObj.StatusCode = ldcAccount.LDC_Account_Status__c;
                if(ldcAccount.LDC_End_Date__c != null) ws_accountObj.StopTime = Datetime.newInstance(ldcAccount.LDC_End_Date__c.year(),ldcAccount.LDC_End_Date__c.month(),ldcAccount.LDC_End_Date__c.day());
                ws_accountObj.SupplyGroup = ldcAccount.Supply_Group__c;
                ws_accountObj.TypeCode = ldcAccount.Account_Type_Code__c;
                ws_accountObj.UtilityCode = ldcAccount.LDC_Vendor__r.Utility_Code__c;
                ws_accountObj.ServiceAddress = new dynegyComServicesLodeStar.SforceAddress();
                ws_accountObj.ServiceAddress.AddrLine1 = ldcAccount.Service_Street_1__c;
                //changes PA
                //ws_accountObj.TaxAccountID= ldcAccount.Tax_Account_id__c;
                //ws_accountObj.Fein = c.Account.FEIN__c;
                //ws_accountObj.RegulatoryType = ldcAccount.Regulatory_Classification__c;
                //PA Changes completed
                ws_accountObj.ServiceAddress.AddrLine2= ldcAccount.Service_Street_2__c;
                ws_accountObj.ServiceAddress.City = ldcAccount.Service_City__c;
                ws_accountObj.ServiceAddress.State = ldcAccount.Service_State__c;
                ws_accountObj.ServiceAddress.Zip = ldcAccount.Service_Postal_Code__c;
                ws_accountObj.ServiceAddress.FIPSCode = ldcAccount.FIPS_Code__c;
                ws_accountObj.ServiceAddress.ServiceCounty = ldcAccount.Service_County__c;
                //Add Account Billing Address
                ws_accountObj.BillingAddress = new dynegyComServicesLodeStar.SforceAddress();
                ws_accountObj.BillingAddress.AddrLine1 = ldcAccount.Billing_Street__c;
                ws_accountObj.BillingAddress.AddrLine2= ldcAccount.Billing_Address_Line_2__c;
                ws_accountObj.BillingAddress.City = ldcAccount.Billing_City__c;
                ws_accountObj.BillingAddress.State = ldcAccount.Billing_State_Province__c;
                ws_accountObj.BillingAddress.Zip = ldcAccount.Billing_Zip_Postal_code__c;
                ws_accountObj.BillingAddress.ICOName = ldcAccount.Billing_Address_Line_3__c;
                //add in the Contract_LDC__c records that match as the ContractItems
                ws_accountObj.ContractItems = new dynegyComServicesLodeStar.ArrayOfSforceLstarContractItem();
                ws_accountObj.ContractItems.SforceLstarContractItem = new List<dynegyComServicesLodeStar.SforceLstarContractItem>();
                List<Contract_LDC__c> contractItemList = contractLDCMap.get(ldcAccount.Id);
                if(contractItemList != null){
                    for(Contract_LDC__c contractItem:contractItemList){
                        dynegyComServicesLodeStar.SforceLstarContractItem ws_contractItemObj = new dynegyComServicesLodeStar.SforceLstarContractItem();
                        ws_contractItemObj.ContractID = contractItem.Contract__r.ContractNumber;
                        ws_contractItemObj.LDCAccountNumber = contractItem.LDC_Account__r.LDC_Account_Number__c;
                        ws_contractItemObj.BillMethod=contractItem.Bill_Method__c;
                        ws_contractItemObj.Revison = '0';
                        if(contractItem.Term_Start_Date__c != null) ws_contractItemObj.StartTime = contractItem.Term_Start_Date__c;
                        if(contractItem.Term_Stop_Date__c != null) ws_contractItemObj.StopTime = contractItem.Term_Stop_Date__c;
                        ws_contractItemObj.BillingGroupLDCS = new dynegyComServicesLodeStar.ArrayOfSforceLstarBillingGroupLDC();
                        ws_contractItemObj.BillingGroupLDCS.SforceLstarBillingGroupLDC = new List<dynegyComServicesLodeStar.SforceLstarBillingGroupLDC>();
                        list<Billing_Group_Ldc__c> bgldclst = BillingGroupLDCMap.get(ldcAccount.id);
                        if(bgldclst != null){
                            for(Billing_Group_Ldc__c bgldc : bgldclst){
                                dynegyComServicesLodeStar.SforceLstarBillingGroupLDC ws_BGLDCObj = new dynegyComServicesLodeStar.SforceLstarBillingGroupLDC();
                                ws_BGLDCObj.BillingGroupName = bgldc.Billing_Group__r.Name;
                                ws_BGLDCObj.StartTime = bgldc.Billing_Start_Date__c;
                                ws_BGLDCObj.StopTime = bgldc.Billing_Stop_Date__c;
                                ws_BGLDCObj.PseudoContractID = bgldc.Pseudo_Contract__c;
                                ws_contractItemObj.BillingGroupLDCS.SforceLstarBillingGroupLDC.add(ws_BGLDCObj);
                                processedBGroupLDCIdSet.add(bgldc.id);
                            }
                        }
                        ws_accountObj.ContractItems.SforceLstarContractItem.add(ws_contractItemObj);
                        processedContractLDCIdSet.add(contractItem.Id);
                    }
                }
                ws_accountObj.PeakLoadData = new dynegyComServicesLodeStar.ArrayOfSforceLstarPeakData();
                ws_accountObj.PeakLoadData.SforceLstarPeakData = new List<dynegyComServicesLodeStar.SforceLstarPeakData>();
                List<Peak_Load_Information__c> PlcList = PlcLDCMap.get(ldcAccount.Id);
                if(PlcList != null){
                    for(Peak_Load_Information__c plc : PlcList){
                        dynegyComServicesLodeStar.SforceLstarPeakData ws_PlcObj = new dynegyComServicesLodeStar.SforceLstarPeakData();
                        ws_PlcObj.LoadType = plc.Load_Type__c;
                        ws_PlcObj.Value = plc.Load_Value__c;
                        ws_PlcObj.Name = plc.Name;
                        ws_PlcObj.StartTime = plc.Start_Date__c;
                        ws_PlcObj.StopTime = plc.EndDate__c;
                        ws_accountObj.PeakLoadData.SforceLstarPeakData.add(ws_PlcObj);
                    }
                }
                
                //Account Supplement to Lodestar code changes 
                ws_accountObj.AccountSupplementData = new dynegyComServicesLodeStar.ArrayOfSforceLstarAccountSupplementData ();
                ws_accountObj.AccountSupplementData.SforceLstarAccountSupplementData  = new List<dynegyComServicesLodeStar.SforceLstarAccountSupplementData >();
                List<Account_Supplement__c> ASLDCList = ASLDCMap.get(ldcAccount.Id);
                if(ASLDCList!= null){
                    for(Account_Supplement__c AS1 : ASLDCList){
                        dynegyComServicesLodeStar.SforceLstarAccountSupplementData ws_AsLDCObj = new dynegyComServicesLodeStar.SforceLstarAccountSupplementData ();
                        ws_AsLDCObj.ID = AS1.id;
                        ws_AsLDCObj.Value= AS1.Percentage__c;
                        ws_AsLDCObj.Type_x = AS1.Type__c;
                        ws_AsLDCObj.StartDate = DateTime.newInstance(AS1.Start_Date__c,Time.newInstance(0,0,0,0)); //AS1.Start_Date__c; //
                        ws_AsLDCObj.EndDate = DateTime.newInstance(AS1.End_Date__c,Time.newInstance(0,0,0,0)); //AS1.End_Date__c; //
                        ws_AsLDCObj.GRTCategory = (As1.GRT_Category__c != null) ? As1.GRT_Category__c.subStringBefore(' -- ') : null;
                        ws_AsLDCObj.SaleIntrasateRevenue = (As1.Sale_Intrasate_Revenue__c == true) ? 'Yes' : 'No';
                        ws_AsLDCObj.StringValue = (As1.Exemption_Type__c != null) ? As1.Exemption_Type__c.subStringBefore(' -- ') : null;
                        ws_AsLDCObj.SalesType = (As1.Sales_Type__c != null) ? As1.Sales_Type__c.subStringBefore(' -- ') : null;
                        ws_accountObj.AccountSupplementData.SforceLstarAccountSupplementData.add(ws_AsLDCObj);
                    }
                }
                // code changes completed for Account supplement
                
                
                
                
                ws_customerObj.Contract.Accounts.SforceLstarAccount.add(ws_accountObj);
                processedLDCAccountIdSet.add(ldcAccount.Id);
                processedAccountIdSet.add(ldcAccount.Account__c);
            }   
            
            //define and populate the Contract Terms
            ws_customerObj.Contract.Terms = new dynegyComServicesLodeStar.ArrayOfSforceLstarContractTerm();
            ws_customerObj.Contract.Terms.SforceLstarContractTerm = new List<dynegyComServicesLodeStar.SforceLstarContractTerm>();
            for(Contract_Term__c ct:contractTermList){
                dynegyComServicesLodeStar.SforceLstarContractTerm ctWSObj = new dynegyComServicesLodeStar.SforceLstarContractTerm();
                ctWSObj.Category = ct.Term_Category__c;
                ctWSObj.StartTime = ct.Term_Start_Date__c;
                ctWSObj.StopTime = ct.Term_Stop_Date__c;
                ctWSObj.TypeCode = ct.Term_Type__c;
                ctWSObj.ValueNum = ct.Contract_Term_Value__c;
                ctWSObj.ValueString = ct.Value_String__c;
                ws_customerObj.Contract.Terms.SforceLstarContractTerm.add(ctWSObj);
            }
            
            return ws_customerObj;
        }
        
        /**
         * this method is inherited from the Comparable Implementation
         **/
        global Integer compareTo(Object objToCompareTo){
            LodeStar.LodeStarDataContainer containerToCompareTo = (LodeStar.LodeStarDataContainer)objToCompareTo;
            //if the contract is null, then this object comes first
            if(this.c == null){
                return -1;
            } 
            //if the contract of the object to compareto is null, that object comes first
            if(containerToCompareTo.c == null){
                return 1;
            }
            //compare the date and times of the Start Contracts
            Date thisDate = this.c.StartDate;
            Date thatDate = containerToCompareTo.c.StartDate;
            if(thisDate > thatDate){
                return -1;
            } else if(thisDate < thatDate) {
                return 1;
            } else {
                return 0;
            }
        }
    }

    /**
     * Exception class used in LodeStar Processing
     **/
    public class LodeStarException extends Exception{
        public string ExceptionMsg {get; set;}
        public string PrevEx {get; set;}
        
        public LodeStarException(String ex,String e){
            this.ExceptionMsg = ex;
            this.PrevEx =e;
        }
    }
}