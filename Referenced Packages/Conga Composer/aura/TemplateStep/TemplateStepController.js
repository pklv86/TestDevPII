({
	init: function(cmp, e, helper) {
         $A.createComponent(
            "APXTConga4:TemplateManagement",
            {
                 "solutionId": cmp.get("v.solutionId")
            },
            function(newCmp){
                if (cmp.isValid()) {
                    cmp.set("v.body", newCmp);
                }
            }
        );
	},
	handleEmailEvent: function(cmp) {
		$A.createComponent(
            "APXTConga4:EmailTemplateBuilder",
            {
                "solutionId": cmp.get("v.solutionId")
            },
            function(newCmp){
                if (cmp.isValid()) {
                    cmp.set("v.body", newCmp);
                }
            }
        );	
	}
})