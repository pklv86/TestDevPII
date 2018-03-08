(function(w){
    "use strict"; //Optional because LC on LockerService active runs in strict mode

    var utilMethods = {
        "navigateTo":navigateTo
    };

    function navigateTo(cmp, navigateTarget) {
        var theme = cmp.get("v.theme");
        window.location.assign('/apex/' + navigateTarget + '?theme=' + theme);
    } 

    w.lightningUtils = utilMethods;

})(window);