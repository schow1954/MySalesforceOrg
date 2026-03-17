/**
 * Controller for Approver Name Update Modal (VF page)
 * Used on approver_conf__c detail page to update the approver Name via popup
 */
public with sharing class ApproverConfUpdateController {

    public approver_conf__c record { get; set; }
    public String approverName { get; set; }

    public ApproverConfUpdateController(ApexPages.StandardController stdController) {
        record = (approver_conf__c) stdController.getRecord();
        if (record != null && record.Id != null) {
            List<approver_conf__c> recs = [SELECT Id, Name FROM approver_conf__c WHERE Id = :record.Id LIMIT 1];
            if (!recs.isEmpty()) {
                record = recs[0];
                approverName = record.Name;
            } else {
                record = new approver_conf__c();
            }
        } else {
            record = new approver_conf__c();
        }
    }

    /**
     * Updates the approver Name field and returns PageReference to close popup
     */
    public PageReference save() {
        if (record == null || record.Id == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record Id is missing.'));
            return null;
        }
        if (String.isBlank(approverName) || approverName.trim().length() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter approver Name.'));
            return null;
        }
        try {
            approver_conf__c toUpdate = new approver_conf__c(
                Id = record.Id,
                Name = approverName.trim()
            );
            update toUpdate;
            return closeAndRefresh();
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
            return null;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }

    /**
     * Returns a PageReference that closes the popup and refreshes the opener
     */
    private PageReference closeAndRefresh() {
        return new PageReference('/apex/ClosePopup');
    }

    /**
     * Cancel - close popup without saving
     */
    public PageReference cancel() {
        return closeAndRefresh();
    }
}
