global class AccountProcessor {
	
    @future
    global static void countContacts(list<Id> ids){
        
        list<Account> acclist = [select id,Number_of_Contacts__c from Account where Id IN:ids];
        for(Account acc:acclist){
            acc.Number_of_Contacts__c = [select count() from Contact where AccountId =:acc.Id];
        }
        Update acclist;
    }
}