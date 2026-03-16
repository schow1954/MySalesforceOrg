public class AccountUtility{
    
    public static void viewAnnualRevenue(){
        list<account> accountsList = [select Id, Name, AnnualRevenue from account];
        for(account acc: accountsList){
            string acctRev = acc.Name+' : '+acc.AnnualRevenue;
            system.debug(acctRev);
        }
    }
}