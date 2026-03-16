Trigger CompanyChopTrigger on Company_Chop__c(Before Insert,Before Update){
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert))
    {
        for(Company_Chop__c chop:Trigger.new){CompanyChopHandler.setApprover(chop); }
    }
}