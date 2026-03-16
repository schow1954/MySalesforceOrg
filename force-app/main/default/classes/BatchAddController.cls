public class BatchAddController{
	
    @AuraEnabled
    public static Account getAccount(){
        return new Account();
    }
    
	@AuraEnabled
    public static string saveMethod(String accstr,String contstr){

        String accid;
        Account record = (Account)JSON.deserialize(accstr.remove('[').remove(']'), Account.class);
        try{
            Insert record;
            accid = record.Id;
            list<Contact> contlist = (list<Contact>)JSON.deserialize(contstr, list<Contact>.class);
            if(!contlist.isEmpty()){
                for(Contact con: contlist){
                    con.Accountid = accid;
                }
                Insert contlist;
            }
        }catch(exception e){System.debug(e.getMessage());}
        return accid;
    }
}