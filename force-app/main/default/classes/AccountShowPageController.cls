public class AccountShowPageController{
	
    public static list<account> getAccounts(){
        list<account> data = [select id,name,Pictures__c from account limit 2];
        account acc = [select id,name,Pictures__c from account where id = '0012v00003CvZv9'];
        data.add(acc);
        return data;
    }
}