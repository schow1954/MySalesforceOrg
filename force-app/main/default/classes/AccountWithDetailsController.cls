public class AccountWithDetailsController{
	
    @AuraEnabled
    public static list<Account> initMethod(){
		list<Account> acclist = new list<Account>();
        for(Account acc:[Select Id,showDetails__c,Name,Phone,Rating From Account limit 20]){
            acc.showDetails__c = true;
            acclist.add(acc);
        }
        return acclist;
    }
    
    @AuraEnabled
    public static list<Contact> getContacts(String accid){
        list<Contact> contlist = new list<Contact>();
        if(String.isNotBlank(accid)){
            contlist = [Select Accountid,Id,LastName,Email,Title From Contact where Accountid =: accid];
        }
        return contlist;
    }
}