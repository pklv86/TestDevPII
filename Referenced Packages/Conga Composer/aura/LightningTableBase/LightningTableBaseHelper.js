({
    getsObjectRecords : function(component,page) {
        var page = page || 1;
        var action = component.get("c.getSolutionRecords");
        var fields = component.get("v.fields");
        action.setParams({
            solutionId : component.get("v.solutionId"),
            ObjectName : component.get("v.object"),
            limits : component.get("v.limit"),
            fieldstoget : fields.join(),
            pageNumber : page,
            pageSize : component.get("v.pageSize")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                
                component.set("v.latestRecords",response.getReturnValue().sObjectrecords);
                
                component.set("v.page",page);
                var retResponse = response.getReturnValue();
                component.set("v.total",retResponse.total);
                component.set("v.pages",Math.ceil(retResponse.total/component.get("v.pageSize")))
                var retRecords = retResponse.sObjectrecords;
                
             }else if (state === "ERROR") {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    }
}
})