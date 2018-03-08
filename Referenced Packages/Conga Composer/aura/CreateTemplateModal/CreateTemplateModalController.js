({
	emailTemplateClick: function(cmp, e, helper) {
		var emailEvent = cmp.getEvent("emailEvent");
        emailEvent.fire();
        helper.closeModal(cmp);
	},
})