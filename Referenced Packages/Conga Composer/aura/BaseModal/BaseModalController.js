({
	openModal: function(cmp, e, helper) {
		helper.openModal(cmp);
	},
	
	closeModal: function(cmp, e, helper) {
		helper.closeModal(cmp);
	},	
	saveModal: function(cmp, e, helper) {
		cmp.getConcreteComponent().saveModal();
	}
})