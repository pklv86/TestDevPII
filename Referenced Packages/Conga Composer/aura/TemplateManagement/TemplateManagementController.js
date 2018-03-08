({
	uploadTemplateClick: function(cmp, e, helper) {
		var uploadModal = cmp.find("uploadTemplateModal");
		uploadModal.openModal();
	},
	createTemplateClick: function(cmp, e, helper) {
		var createModal = cmp.find("createTemplateModal");
		createModal.openModal();
	},
	captureStepEvent: function(cmp, e, helper) {
	    switch(e.getParam("eventAction")) {
	    case "refreshTable":
	    	//Reload the table
	        var lightningTableTemplates = cmp.find("lightningTableTemplates");
	        lightningTableTemplates.reInit();
	        break;
	    case "refreshListAndTable":
	    	//Reload the table
	        var lightningTableTemplates = cmp.find("lightningTableTemplates");
	        lightningTableTemplates.reInit();
	        //Reload the template list
	        var searchAndSelectTemplates = cmp.find("searchAndSelectTemplates");
	        searchAndSelectTemplates.reInit();
	        break;
	    case "addTemplateToList":
	    	var templatesToAdd = cmp.get("v.templatesToAdd");
		    templatesToAdd.push(event.currentTarget.id);
		    cmp.set("v.templatesToAdd", templatesToAdd);
		    break;
		case "removeTemplateFromList":
	    	var templatesToAdd = cmp.get("v.templatesToAdd");
		    templatesToAdd.splice(templatesToAdd.indexOf(event.currentTarget.id), 1);
		    cmp.set("v.templatesToAdd", templatesToAdd);
		    break;
	    default:
	        
	    }
	    
	},
	captureSpinnerEvent: function(cmp, e, helper) {
        switch(e.getParam("eventAction")) {
	    case "showSpinner":
        	helper.showSpinner(cmp);
	        break;
	    case "hideSpinner":
	    	helper.hideSpinner(cmp);
		    break;
	    default:
	        helper.hideSpinner(cmp);
	    }
	},
	addTemplateClick: function(cmp, e, helper) {
		var templatesToAdd = cmp.get("v.templatesToAdd");

		//If we have any templates to add
		if (templatesToAdd != '') {
		//Spin!
		helper.showSpinner(cmp);

		helper.callAction(cmp, cmp.get("c.getInsertSolutionTemplate"),{
			  solutionId : cmp.get("v.solutionId"),
              IdsToInsert : cmp.get("v.templatesToAdd")
          }).then(function(returnVal) {
            //Good to go
            if (returnVal == 'success'){
              		//Refresh the lightning table
	                var lightningTableTemplates = cmp.find("lightningTableTemplates");
		        	lightningTableTemplates.reInit();
		        	//Uncheck all the boxes
		            var searchAndSelectTemplates = cmp.find("searchAndSelectTemplates");
		        	searchAndSelectTemplates.uncheckAll();
		        	//Clear the templates to add
		        	cmp.set("v.templatesToAdd", '');
              	}
              	else if (returnVal == 'alreadyExists') {
              		alert('Selected template already exists in solution.');
              		helper.hideSpinner(cmp);
              	}
              	else if (returnVal == 'templateLimitExceeded') {
              		alert('Maximum of 10 templates per solution.');
              		helper.hideSpinner(cmp);
              	}
        });

		
        }
        else {
        	alert('No templates selected.');
        }
	}
})