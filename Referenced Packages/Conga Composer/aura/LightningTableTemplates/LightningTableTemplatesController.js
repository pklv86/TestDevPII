({
    captureEvent: function(cmp, e, helper) {
	   
	    switch(e.getParam("eventAction")) {
	    case "refreshList":
	    	//Spin!
        	helper.showSpinner(cmp);
	        helper.getsObjectRecords(cmp,1);
	        break;
	    case "hideAll":
	        helper.hideAll(cmp);
	        break;
	    default:
	        
	    }
	    
	  }
})