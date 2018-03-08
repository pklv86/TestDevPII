({
    getsObjectRecords : function(cmp,page) {
        var page = page || 1;
        var action = cmp.get("c.getSolutionRecords");
        var fields = cmp.get("v.fields");
        action.setParams({
            solutionId : cmp.get("v.solutionId"),
            ObjectName : cmp.get("v.object"),
            limits : cmp.get("v.limit"),
            fieldstoget : fields.join(),
            pageNumber : page,
            pageSize : cmp.get("v.pageSize")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                
                cmp.set("v.latestRecords",response.getReturnValue().sObjectrecords);
                
                cmp.set("v.page",page);
                var retResponse = response.getReturnValue();
                cmp.set("v.total",retResponse.total);
                cmp.set("v.pages",Math.ceil(retResponse.total/cmp.get("v.pageSize")))
                var retRecords = retResponse.sObjectrecords;

                this.hideSpinner(cmp);
                
             }else if (state === "ERROR") {
                console.log('Error');
                this.hideSpinner(cmp);
            }
        });
        $A.enqueueAction(action);
    },
    hideAll: function(cmp) {
        var ddDiv = cmp.find('ddm');
        for(var i = 0; i<ddDiv.length; i++) {
            ddDiv[i].set("v.hide", true);
        }
    },
    showSpinner: function(cmp) {
        var spinnerEvent = cmp.getEvent("spinnerEvent");
        spinnerEvent.setParams({eventAction: "showSpinner"}).fire();
    },
    hideSpinner : function(cmp){
        var spinnerEvent = cmp.getEvent("spinnerEvent");
        spinnerEvent.setParams({eventAction: "hideSpinner"}).fire();
    }    
})