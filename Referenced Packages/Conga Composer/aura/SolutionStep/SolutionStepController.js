({
	init : function(cmp, e, helper) {
		var solutionId = cmp.get("v.solutionId");

	    var getAvailableObjectsAction = cmp.get("c.getAvailableObjects");
	    //Using setStorable WITH javascript promises is not really a good idea, because the SF caching mechanism can do a double callback when the cache expires,
	    //but js promises are designed for a single callback flow.
		getAvailableObjectsAction.setStorable();
	    
	    helper.callAction(cmp, getAvailableObjectsAction).then(function(list) {
	      list.unshift({"Key":"-- Select a Salesforce Object --","Value":""});
	      cmp.set("v.solutionId", solutionId);
	      cmp.set("v.objectList", list);
	    });

	    //If we've already created the solution for this wizard, get the solution details
	    if (cmp.get("v.solutionId") != "") {
	    	var getSolutionDetailsAction = cmp.get("c.getSolutionDetails");
			getSolutionDetailsAction.setStorable();
		    
		    helper.callAction(cmp, getSolutionDetailsAction,{
              solutionId : solutionId
	          }).then(function(solutionDetailsWrapper) {
			    	cmp.set("v.solutionName", solutionDetailsWrapper.name);
			    	cmp.set("v.description", solutionDetailsWrapper.description);
			    	cmp.set("v.sampleRecordId", solutionDetailsWrapper.sampleRecordId);	
			    	cmp.set("v.sampleRecordName", solutionDetailsWrapper.sampleRecordName);		
			    	cmp.set("v.masterObject", solutionDetailsWrapper.masterObject);	
			    });
	    }
	    
	},
	onMasterObjectChange: function(cmp, e, helper) {
        cmp.set("v.masterObject", cmp.find("selectMasterObject").get("v.value"));
        helper.loadSampleRecords(cmp);	
    },
    createSolution: function(cmp, e, helper) {
    	//TODO: This metadata check code is duplicated (and kind of tightly integrated into the QuickStartPackagesStep component code) so copy and paste
    	//into this component for now due to time constraints. When time available, refactor into single MetaDataEndpointCreator component for either implementation.
    	//Requires too much refactoring + testing at this point (3 weeks prior to release)
    	// Check to see if org already has remote sites for access to the metadata api, through apex
        var checkForMetadataAccessAction = cmp.get("c.checkForMetadataAccess");
        checkForMetadataAccessAction.setStorable();

        checkForMetadataAccessAction.setCallback(this, function(a) {
        var status = a.getState();
        if (cmp.isValid() && status === "SUCCESS") {
            
            // If the metadata api isn't available 
            if (a.getReturnValue()==false){
                //window.mixpanel.track("Custom Solution: Remote Sites Needed");
                // Get a list of the urls to add as remote sites
                var getRemoteSiteUrlsAction = cmp.get("c.getRemoteSiteUrls");
                getRemoteSiteUrlsAction.setStorable();

                getRemoteSiteUrlsAction.setCallback(this, function(a) {
                    var status = a.getState();
                    if (cmp.isValid() && status === "SUCCESS") {
                        // Set the list of remotes sites here, which will be dynamically loaded into the RemoteSiteSettingsModal remoteSiteList attribute
                        cmp.set("v.remoteSiteList", a.getReturnValue()); 
                        cmp.set("v.VFServerURL", JSON.parse(a.getReturnValue()).VFServerURL);
                        cmp.set("v.MyDomainNameSpaceVFServerBaseURL", "" + JSON.parse(a.getReturnValue()).MyDomainNameSpaceVFServerBaseURL);
                        cmp.set("v.SFServerBaseURL", JSON.parse(a.getReturnValue()).SFServerBaseURL);
                    }
                    else {
                        helper.handleErrors(response, cmp);
                    }
                });
                $A.enqueueAction(getRemoteSiteUrlsAction);
                
                var createModal = cmp.find("remoteSiteSettingsModal");
                createModal.openModal();
            }
            else{
                //window.mixpanel.track("Custom Solution: Remote Sites Exist");
                // The metadata api is already available, don't pop the modal, do create the solution
                helper.createSolutionRecord(cmp, helper);
                
            }
        }
        else {
            helper.handleErrors(response, cmp);
        }
    
        });
        $A.enqueueAction(checkForMetadataAccessAction);

    },
    hideSampleRecords: function(cmp, e, helper) {
    	helper.hideSampleRecords(cmp);
    },
    captureRemoteSiteSettingsEvent : function(cmp, e, helper) {
       
        // This event is fired from the modal, after the user OKs the remote sites to be set up
        // Get the session id from Apex to be used in the javascript XMLHttpRequest Soap request to the metadata api
        var action = cmp.get("c.getSessionId");
        action.setCallback(this, function(a) {
            
            var status = a.getState();
            if (cmp.isValid() && status === "SUCCESS") {
                // Send the SOAP request with the session id and list of remote sites
                helper.createRemoteSite(a.getReturnValue(), cmp.get("v.remoteSiteList"));
                // Create the solution
                helper.createSolutionRecord(cmp, helper);
            }
            else {
                handleErrors(response, cmp);
            }

        });

        $A.enqueueAction(action);
    }
})