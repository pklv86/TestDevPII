/**
 * This class is designed to host an Invocable Action and can be called from the Process Builder
 * Its purpose is to set the LDC_Account__r.Account_Type_Code__c value based on the Contract.Bill_Type__c,
 * and the LDC_Account__r.LDC_Vendor__r.DUNS__c on the Contract_LDC__c record that has been marked as Active.
 * 
 * @version 1.1 - CJG - 03/21/2016 - Updated the functionality to also update the Rate_Code__c
 *									 on the Account_LDC from the Contract_LDC
 * @version 1.2 - CJG - 03/31/2016 - Updated the functionality to also update the Contract_Type__c
 *									 on the related Contract record
 * @version 1.3 - CJG - 04/14/2016 - Updated functionality not to Set Contract Type Any longer.
 * @version 1.4 - CJG - 04/14/2016 - Change to obtaining AccountTypeCode__c - now determined By Contract Type and Service Territory.
 *
 * @author Chris Gary <cgary@cloudperformer.com>
 * @version 1.4
 **/
public class Flow_SetAccountLDCAcctTypeCode {
	@InvocableMethod(label='Set Account LDC' description='Set the Related LDC Account Type Code from the Contract LDC if marked as active.')
	public static void SetAccountLDCInfoFROMContractLDC(List<Id> contractLDCId){
		map<Id,String> ldcAccountIdToAccountTypeMap = new map<Id,String>();
		map<String,map<String,map<string,AccountTypeSetting__c>>> settingsMap = ObtainAccountTypeSettingMapByAlternateKey();
		for(Contract_LDC__c cntrct:[SELECT Id, Name, Contract__c, LDC_Account__c,LDC_Account__r.Service_Territory__c,Contract__r.Contract_Type__c,
											Contract__r.Bill_Method__c FROM Contract_LDC__c WHERE Id IN :contractLDCId]){
												
			map<String,map<string,AccountTypeSetting__c>> contractTypeMap = settingsMap.get(cntrct.LDC_Account__r.Service_Territory__c);
			if(contractTypeMap != null){
				map<string,AccountTypeSetting__c> billMethodMap = contractTypeMap.get(cntrct.Contract__r.Contract_Type__c);
				if(billMethodMap != null){
					system.debug('test : '+billMethodMap);
					AccountTypeSetting__c acctTypeSetting;
					if(billMethodMap.size() > 1){
						for(AccountTypeSetting__c ats : billMethodMap.values()){
							system.debug('test inner : '+ats.Bill_Method__c +' : '+cntrct.Contract__r.Bill_Method__c);
							if(ats.Bill_Method__c.equalsIgnorecase(cntrct.Contract__r.Bill_Method__c) && ats.Bill_Method__c != null)
								 acctTypeSetting = billMethodMap.get(ats.Bill_Method__c);
						}
					}
					else{
						AccountTypeSetting__c ats1 = billMethodMap.get(cntrct.Contract__r.Bill_Method__c);
						system.debug('test ats1 : '+ats1);
						if(ats1 != null && ats1.Contract_Type__c.equalsIgnorecase(cntrct.Contract__r.Contract_Type__c))
							acctTypeSetting = ats1;
						else
							acctTypeSetting = billMethodMap.get(null);
					}
					if(acctTypeSetting != null) ldcAccountIdToAccountTypeMap.put(cntrct.LDC_Account__c,acctTypeSetting.AccountTypeCode__c);
				}
			}
		}
		List<LDC_Account__c> ldcsToUpdate = new List<LDC_Account__c>();
		for(LDC_Account__c ldcAcct:[SELECT Id, Account_Type_Code__c FROM LDC_Account__c WHERE Id IN :ldcAccountIdToAccountTypeMap.keySet()]){
			ldcAcct.Account_Type_Code__c = ldcAccountIdToAccountTypeMap.get(ldcAcct.Id);
			ldcsToUpdate.add(ldcAcct);
		}
		if(!ldcsToUpdate.isEmpty()) update ldcsToUpdate;
		
	}
	/**
	 * Simply returns the AccounTypeSetting__c records in a Map of Maps with the first key being
	 * ServiceTerritory__c and the Second Key being the Contract_Type__c.
	 *
	 * @return Map<String,Map<String,AccountTypeSetting__c>>  - the Map to return
	 **/
	private static map<String,map<String,map<string,AccountTypeSetting__c>>> ObtainAccountTypeSettingMapByAlternateKey(){
		Map<String,AccountTypeSetting__c> settingMap = AccountTypeSetting__c.getAll();
		map<String,map<String,map<string,AccountTypeSetting__c>>> returnMap = new map<String,map<String,map<string,AccountTypeSetting__c>>>();
		for(AccountTypeSetting__c setting:settingMap.values()){
		    map<String,map<string,AccountTypeSetting__c>> tempMap;
		    map<string,AccountTypeSetting__c> tempMap2;
		    if(returnMap.containsKey(setting.ServiceTerritory__c)){
		        tempMap = returnMap.get(setting.ServiceTerritory__c);
		        for(string st : tempMap.keyset()){
		            tempMap2 = new map<string,AccountTypeSetting__c>();
		            if(tempMap.containsKey(setting.Contract_Type__c))
		                tempMap2 = tempMap.get(setting.Contract_Type__c);
		            else
		                tempMap2 = new map<String,AccountTypeSetting__c>();
		        }
		    }else{
		        tempMap2 = new map<String,AccountTypeSetting__c>();
		        tempMap = new map<String,map<string,AccountTypeSetting__c>>();
		    }
		    tempMap2.put(setting.Bill_Method__c,setting);
		    tempMap.put(setting.Contract_Type__c,tempMap2);
		    returnMap.put(setting.ServiceTerritory__c,tempMap);
		}
		return returnMap;
	}
}