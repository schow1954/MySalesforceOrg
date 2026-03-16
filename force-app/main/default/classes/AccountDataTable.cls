public class AccountDataTable {
    /*apex method to fetch account list*/
    @AuraEnabled
    public static List <Account> getAccounts() {
        List<Account> accountList = new List<Account>();
        for(Account Acc : [SELECT  Name, Industry, Type, VIP_Account__c FROM Account ORDER BY LastModifiedDate DESC LIMIT 20]){
            accountList.add(Acc);
        }
        return accountList;
    }
}