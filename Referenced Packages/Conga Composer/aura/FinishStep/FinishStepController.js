({
	init: function(cmp, e, helper) {
		
		//Only create the button for custom solution, not quick start, though they share this same finishstep component.
		var solutionId = cmp.get('v.solutionId');
		
		if (solutionId != '' && typeof solutionId != "undefined") {
			helper.callAction(cmp, cmp.get("c.getCreateButton"),{
				solutionId: solutionId
			}).then(function(returnVal) {
            	//Good to go
            	if (returnVal = ''){
            		//Everything worked
            	} else {
            		//Show toast
            		var toastComponent = cmp.find('toastComponent');
            		toastComponent.showToast($A.get("$Label.c.Toast_Title"), $A.get("$Label.c.Button_Create_Error"));
            	}
            });
		}
	},
	goToMasterObject : function(cmp, e, helper) {
		
		var masterObject = cmp.get('v.masterObject');
		var theme = cmp.get('v.theme');

		switch(theme) {
			case 'Theme4d':
			helper.navigateAway(cmp, e, '/one/one.app?source=aloha#/setup/object/' + masterObject + '/all/PageLayouts');
			break;
			default:
			helper.navigateAway(cmp, e, '/ui/setup/layout/PageLayouts?type=' + masterObject);
			break;
		}

	},
	openModal : function(cmp, e, helper) {
		var finishVideoModal = cmp.find("finishVideoModal");
        finishVideoModal.openModal();
	}
})