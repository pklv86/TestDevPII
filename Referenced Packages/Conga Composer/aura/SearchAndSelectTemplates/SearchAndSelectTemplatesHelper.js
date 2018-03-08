({
    loadTemplates : function(cmp, helper) {
        helper.callAction(cmp, cmp.get("c.getTemplateRecords"),{
            ObjectName : "APXTConga4__Conga_Template__c",
            limits : "1000",
            fieldstoget : "Id,APXTConga4__Name__c,APXTConga4__Template_Group__c,APXTConga4__Description__c,APXTConga4__Template_Extension__c",
            pageNumber : 1,
            pageSize : "1000"
        }).then(function(returnVal) {
            //Good to go
            cmp.set("v.items", returnVal.sObjectrecords);
        });
    },
    uncheckAll: function(cmp) {
        var chkTemplate = document.getElementsByName('chkTemplate');
        for(var i = 0; i<chkTemplate.length; i++) {
            chkTemplate[i].checked = false;
        }
    }
})