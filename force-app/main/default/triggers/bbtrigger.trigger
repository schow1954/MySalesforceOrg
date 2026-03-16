trigger bbtrigger on BB__c (before insert,after insert,before update,after update) {
    if(Trigger.isBefore){
        system.debug('yes');
    }
}