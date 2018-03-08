({
  init : function(cmp, e, helper) {
    //Enable search
    cmp.set("v.enabled", true);
    //Get Conga_Templates and load into v.items
    helper.loadTemplates(cmp, helper);
        
  },
  doCheckboxClick : function(cmp, e, helper) {
    // This event will bubble up to parent to add to or remove from the array
    var templateEvent = cmp.getEvent("stepEvent");
    if (e.currentTarget.checked == true) {
      templateEvent.setParams({eventAction: "addTemplateToList"}).fire();
    }
    else {
      templateEvent.setParams({eventAction: "removeTemplateFromList"}).fire();
    }

  },
  uncheckAll: function(cmp, e, helper) {
    helper.uncheckAll(cmp);
  }
})