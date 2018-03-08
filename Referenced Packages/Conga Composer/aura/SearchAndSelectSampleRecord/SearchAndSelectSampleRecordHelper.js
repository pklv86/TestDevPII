({
    loadSampleRecords : function(cmp, helper) {
        var myMasterObject = cmp.get("v.myMasterObject");
            if (myMasterObject != '') {
                helper.callAction(cmp, cmp.get("c.getRecords"),{
                ObjectName : cmp.get("v.myMasterObject"),
                //ObjectName : "Opportunity",
                limits : "1000",
                fieldstoget : "Id,Name",
                pageNumber : 1,
                pageSize : "1000"
            }).then(function(returnVal) {
                //Good to go
                cmp.set("v.items", returnVal.sObjectrecords);
                cmp.set("v.enabled", true);
                //Master object changed, reset sample record information
                cmp.set("v.searchStr", "");
                cmp.set("v.sampleRecordId", "");
            });
        }
    },
    hideAll : function(cmp, e, helper) {
        cmp.set("v.showItems", false);
    }
})