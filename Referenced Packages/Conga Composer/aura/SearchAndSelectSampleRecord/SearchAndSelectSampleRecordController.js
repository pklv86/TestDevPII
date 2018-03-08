({
  init : function(cmp, e, helper) {
    //Get Conga_Templates and load into v.items
    helper.loadSampleRecords(cmp, helper);

    //Only show 10
    cmp.set("v.itemsToShow", 10);    
  },
  selectThisRecord : function(cmp, e, helper) {
    alert(e.currentTarget.title);
    //cmp.set("v.searchStr", e.currentTarget.title);
    //cmp.set("v.sampleRecordId", e.currentTarget.id);
    //helper.hideAll(cmp, e, helper);
  },
  hideSampleRecords : function(cmp, e, helper) {
    helper.hideAll(cmp, e, helper);
  }
})