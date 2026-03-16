public class SubmitApprovalofChopController {

    @AuraEnabled
    public static Boolean setApprovers(String recordid){
        Boolean tag = false;
        Company_Chop__c chop = [SELECT Id,Approver1__c,Approver2__c,Approver3__c,Approver4__c,OwnerId,RecordTypeId,Contract_Management__c,
                                Contract_Types__c,Contract_Approval_Status__c,Signature_Target__c,Contract_Type__c,Contract_T__c,ContractAmountType__c,
                                Remark__c,Approvals_Status__c,Files_Content__c,Files_Types__c,Files_Type__c,Legal_Entity__c,Apply_User__c,Apply_Department__c,
                                Apply_Date__c,Name,Seal_Type__c,Certification_Doc__c
                               FROM Company_Chop__c
                               WHERE Id =:recordid];
        Company_Chop__c updateChop = CompanyChopHandler.setApprover(chop);
        try{
            Database.update(updateChop);
            tag = true;
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        return tag;
    }
    
    @AuraEnabled
    public static Boolean submitToApproval(String recordid,String comments){
        Boolean tag = false;
        Company_Chop__c chop = [SELECT Id,Approver1__c,Approver2__c,Approver3__c,Approver4__c,OwnerId,RecordTypeId,Contract_Management__c,
                                Contract_Types__c,Contract_Approval_Status__c,Signature_Target__c,Contract_Type__c,Contract_T__c,ContractAmountType__c,
                                Remark__c,Approvals_Status__c,Files_Content__c,Files_Types__c,Files_Type__c,Legal_Entity__c,Apply_User__c,Apply_Department__c,
                                Apply_Date__c,Name,Seal_Type__c,Certification_Doc__c
                               FROM Company_Chop__c
                               WHERE Id =:recordid];
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments(comments);
        req.setObjectId(recordid);
        req.setProcessDefinitionNameOrId('Standard_Chop_Approval_Process');
		Approval.ProcessResult result = Approval.process(req);
System.debug('result： '+result.isSuccess());
        return tag;
    }
}