trigger AccountTrigger on Account (after update) {
    for(Account acc : trigger.new){
        system.debug('OrderType__c : '+acc.OrderType__c);
    }
}