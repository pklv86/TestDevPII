({
	searchKeyChange: function(cmp, e, helper) {
        cmp.find('searchInput').showHelpMessageIfInvalid();

		var searchStr = e.target.value.toLowerCase();
		cmp.set("v.searchStr", searchStr);
        var returnStrArray = [];
        for (var i = 0, l = cmp.get("v.items").length; i < l; i++) {
            var obj = cmp.get("v.items")[i];
            if (JSON.stringify(obj).toLowerCase().includes(searchStr)){
              returnStrArray.push(obj);
            }
        }
        //Only show x number of results in the result pane
        cmp.set("v.searchedItems", returnStrArray.slice(0, cmp.get("v.itemsToShow")));
        //Show the result pane
        cmp.set("v.showItems", true);
    }
})