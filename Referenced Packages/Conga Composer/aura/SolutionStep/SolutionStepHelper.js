({
	createSolutionRecord : function(cmp, helper) {
		//Get the solutionId from the BaseStep, if it exists
		var solutionId = cmp.get("v.solutionId");
		//Get the user entered information
		var solutionName = cmp.find("solutionName").get("v.value");
		var objectType = cmp.find("selectMasterObject").get("v.value");
		var sampleRecordId = cmp.find("searchAndSelectSampleRecord").get("v.sampleRecordId");
		var searchStr = cmp.find("searchAndSelectSampleRecord").get("v.searchStr");
		
		var description = cmp.find("description").get("v.value");

		//Set flags
		var solutionNameGood = false;
		var objectTypeGood = false;
		
		//Check to make sure input is good
		if (solutionName != null) {
			if (solutionName.trim() != "") {
				solutionNameGood = true;
			}
		}
		//Check to make sure input is good
		if (objectType != null && objectType.trim() != '') {
			if (objectType.trim() != "") {
				objectTypeGood = true;
			}
		}

		//If all input is good, create the solution if it doesn't already exist
		if ((solutionNameGood == true) && (objectTypeGood == true)) {

			helper.callAction(cmp, cmp.get("c.getCreateSolutionRecord"),{
				solutionId: solutionId,
				solutionName: solutionName,
				objectType: objectType, 
				sampleRecordId: sampleRecordId,
				sampleRecordName: searchStr,
				description: description
			}).then(function(returnVal) {
		        	//Good to go
		        	console.log(returnVal);
		        	cmp.set("v.solutionId", returnVal);

			        //Overwrite the history so the back button will work as expected
			        var theme = cmp.get("v.theme");
			        var stateObj = { solutionStep: "solutionStep" };
			        window.history.pushState(stateObj, "Details: 1", '/apex/SolutionStep'+'?mo='+objectType+'&sid='+returnVal+'&sn='+solutionName);
			        
			        helper.navigatePrevNext(cmp, true);
			    });
		}
		else {
			//If the solutionName is empty, force the lightning:input element to show its error message.
			document.getElementsByName('solutionName')[0].focus();
			document.getElementsByName('solutionName')[0].blur();
			//If the masterObject is empty, force the lightning:select element to show its error message.
			document.getElementsByName('masterObject')[0].focus();
			document.getElementsByName('masterObject')[0].blur();
		}
		
	},
	loadSampleRecords : function(cmp) {
		//Load the sample record data
		var searchAndSelectSampleRecord = cmp.find("searchAndSelectSampleRecord");
		searchAndSelectSampleRecord.reInit();
	},
	hideSampleRecords : function(cmp) {
		//Load the sample record data
		var searchAndSelectSampleRecord = cmp.find("searchAndSelectSampleRecord");
		searchAndSelectSampleRecord.hideSampleRecords();
	},
	createRemoteSite : function(sessionId, remoteSiteList)
	{ 
		// Calls the Metdata API from JavaScript to create the Remote Site Setting to permit Apex callouts
		// The urn:CallOptions element is required for Professional Edition
		var binding = new XMLHttpRequest();
		var request = 
			'<?xml version="1.0" encoding="utf-8"?>' + 
			'<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:cmd="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
				'<soap:Header>' + 
					'<cmd:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">' + 
						'<cmd:sessionId>' + JSON.parse(sessionId).sessionId + '</cmd:sessionId>' + 
					'</cmd:SessionHeader>' + 
					'<cmd:CallOptions><client>AppExtremes/</client></cmd:CallOptions>' +
				'</soap:Header>' + 
				'<soap:Body>' +
					'<createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">' + 
						'<metadata xsi:type="RemoteSiteSetting">' + 
							'<fullName>Conga_Front_End</fullName>' +
							'<description>Metadata API Remote Site Setting for Conga QuickStart Solution Packs</description>' + 
							'<disableProtocolSecurity>false</disableProtocolSecurity>' + 
							'<isActive>true</isActive>' + 
							'<url>https://' + JSON.parse(remoteSiteList).SFServerBaseURL + '</url>' +
						'</metadata>' +
	        			'<metadata xsi:type="RemoteSiteSetting">' + 
							'<fullName>Composer_VisualForce</fullName>' +
							'<description>Metadata API Remote Site Setting for Conga QuickStart Solution Packs</description>' + 
							'<disableProtocolSecurity>false</disableProtocolSecurity>' + 
							'<isActive>true</isActive>' + 
							'<url>https://' + JSON.parse(remoteSiteList).MyDomainNameSpaceVFServerBaseURL + '</url>' +
						'</metadata>' +
						'<metadata xsi:type="RemoteSiteSetting">' + 
							'<fullName>Standard_VisualForce</fullName>' +
							'<description>Metadata API Remote Site Setting for Conga QuickStart Solution Packs</description>' + 
							'<disableProtocolSecurity>false</disableProtocolSecurity>' + 
							'<isActive>true</isActive>' + 
							'<url>https://' + JSON.parse(remoteSiteList).VFServerURL + '</url>' +
						'</metadata>' +
					'</createMetadata>' +
				'</soap:Body>' + 
			'</soap:Envelope>';

		try {
			binding.open('POST', 'https://' + JSON.parse(remoteSiteList).MyDomainNameSpaceVFServerBaseURL + '/services/Soap/m/39.0');

			
			binding.setRequestHeader('SOAPAction','""');
			binding.setRequestHeader('Content-Type', 'text/xml');
			binding.onreadystatechange = 
				function() { 
					if(this.readyState==4) {
						/*alert(this.response);
						//TODO:Handle error properly
						var parser = new DOMParser();
						var doc  = parser.parseFromString(this.response, 'application/xml');
						var errors = doc.getElementsByTagName('errors');
						var messageText = '';
						for(var errorIdx = 0; errorIdx < errors.length; errorIdx++)
							messageText+= errors.item(errorIdx).getElementsByTagName('message').item(0).innerHTML + '\n';

						System.debug(messageText);*/
					} 
				}
			binding.send(request);
		}
		catch(e) {
			//Cannot send XMLHttpRequest through locker service (lightning experience with myDomains enabled) so navigate user to manually add remote site settings
			//Alter this flow, check for myDomains first then navigate or pop modal
			//Latest 5/2017 force lightning out in all cases so we should never get here.
			alert($A.get("$Label.c.My_Domains_Warning"));

		}	
	}
})