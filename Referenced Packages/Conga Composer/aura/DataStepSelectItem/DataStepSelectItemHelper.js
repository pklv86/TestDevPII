({
	previewTemplate : function(idtopreview, component) {
        window.open('/' + idtopreview, '_blank');
    },
    deleteRecord : function(idtodel, cmp, helper) {
        if (confirm('Are you sure you want to remove this template from your solution?')){

        	helper.callAction(cmp, cmp.get("c.getDeleteRecord"),{
	            IdToDel : idtodel
	        }).then(function(returnVal) {
	            //Good to go
	            // This event will bubble up to parent
				var event = cmp.getEvent("stepEvent");
		    	event.setParams({
			    	eventAction: "refreshList"
				}).fire();
            });

        }
    },
    toggleView : function(cmp) {
    	//toggle view
    	cmp.set("v.hide", !cmp.get("v.hide"));
    },
    hideAll : function(cmp) {
    	//if this isn't already showing, close any others that might be open first
    if (cmp.get("v.hide") == true) {
      // This event will bubble up to parent
        var event = cmp.getEvent("stepEvent");
          event.setParams({
            eventAction: "hideAll"
        }).fire();
    }
    }
})