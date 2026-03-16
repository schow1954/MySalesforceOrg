trigger choptrigger on Company_Chop__c (before insert,after insert,before update,after update) {

   /*
    if(trigger.isbefore && trigger.isinsert){
        for(Company_Chop__c chop:trigger.new){
            if(chop.Apply_Date__c > Date.today()){
                chop.addError('before insert error');
            }
        }
    }
    
    if(trigger.isafter && trigger.isinsert){
        for(Company_Chop__c chop:trigger.new){
            if(chop.Apply_Date__c > Date.today()){
                chop.addError('after insert error');
            }
        }
    }
    
    if(trigger.isbefore && trigger.isupdate){
        for(Company_Chop__c chop:trigger.new){
            if(chop.Apply_Date__c > Date.today()){
                chop.addError('before update error');
            }
        }
    }
    if(trigger.isafter && trigger.isupdate){
        for(Company_Chop__c chop:trigger.new){
            if(chop.Apply_Date__c > Date.today()){
                chop.addError('after update error');
            }
        }
    }*/
}