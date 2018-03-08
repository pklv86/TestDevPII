({
  showPrompt : function(cmp, event, helper) {
    var showOnEvent = cmp.get("v.showOnEvent");
    if (showOnEvent) {
      var params = event.getParam('arguments');
        if (params) {
            var title = params.title;
            var message = params.message;
            if (title && title.length > 0) cmp.set("v.title", title);
            cmp.set("v.message", message);
            cmp.set("v.visible", true);
        }
    }
  },
  close: function(cmp, event, helper) {
    cmp.set("v.visible", false);
  }
})