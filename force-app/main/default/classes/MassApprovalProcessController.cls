public class MassApprovalProcessController{
    
	@AuraEnabled
    public static List<ProcesWorkitem__c> getItems(){
        list<ProcesWorkitem__c> records = new list<ProcesWorkitem__c>();
        Set<String> setids = new Set<String>();
        Map<Id,Account> accts = new Map<Id,Account>([Select ID from Account where ApproveStatus__c = '已提交']);
        for(ProcessInstance ins: [Select ID,createdDate from ProcessInstance where TargetObjectId In: accts.keySet()]){
            setids.add(ins.Id);
        }
        for(ProcessInstanceWorkitem item: [Select Id,ActorId,Actor.Name,ProcessInstanceId,ProcessInstance.SubmittedById,
                                           ProcessInstance.TargetObjectId,ProcessInstance.TargetObject.Name,ProcessInstance.createdDate
                                           From ProcessInstanceWorkitem Where ProcessInstanceId In:setids])
        {
            ProcesWorkitem__c p = new ProcesWorkitem__c();
            p.CurrencyApprover__c = item.ProcessInstance.SubmittedById;
            p.ApprovalName__c = [select Id,name from user where id =:item.ProcessInstance.SubmittedById].name;
            p.Account__c = item.ProcessInstance.TargetObjectId;
            p.AccountName__c = item.ProcessInstance.TargetObject.Name;
            p.CurrencyName__c = item.Actor.Name;
            p.IsChecked__c = false;
            p.ApprovalIdeas__c = '';
            p.InstanceId__c = item.Id;
            p.Type__c = 'Account';
            p.submitedDate__c = string.valueOf(Date.today());
            records.add(p);
        }
        return records;
    }
    
    @AuraEnabled
    public static void doApproveMethod(List<ProcesWorkitem__c> data,string myaction){
       
        if(!data.isEmpty()){
            List<ProcesWorkitem__c> records = new List<ProcesWorkitem__c>();
            for(ProcesWorkitem__c item: data){
                if(item.IsChecked__c){
                   Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments(item.ApprovalIdeas__c);
                    req2.setAction(myaction);
                    req2.setWorkitemId(item.InstanceId__c);
                    Approval.ProcessResult result2 =  Approval.process(req2);
                }
            }
        }
    }    
}