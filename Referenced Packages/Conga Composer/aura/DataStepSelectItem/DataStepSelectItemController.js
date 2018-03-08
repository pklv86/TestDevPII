({
  hideAll: function(cmp, e, helper) {
    helper.hideAll(cmp);
  	helper.toggleView(cmp); 
  },
  previewTemplate: function(component, event, helper) {
    helper.toggleView(component);
    helper.previewTemplate(event.currentTarget.id, component);
  },
  deleteRecord: function(component, event, helper) {
    helper.toggleView(component);
    helper.deleteRecord(event.currentTarget.id, component, helper);
  }
})