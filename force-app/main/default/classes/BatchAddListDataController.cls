public class BatchAddListDataController{
    
    @AuraEnabled
    public static list<Contact> initMethod(string accid){

        list<Contact> contlist = [Select Id,LastName,Email,Title,LeadSource,disab__c From Contact where Accountid =:accid order by CreatedDate asc];
        if(contlist.size() >0){
            for(Contact cont: contlist){
            	cont.disab__c = true;
        	}	
        }
        return contlist;
    }
	
    @AuraEnabled
    public static void deleteContact(string contid){
        try{
            delete [select id from contact where id =:contid];
        }catch(exception e){system.debug(e.getCause());}
    }
    
	@AuraEnabled
    public static void saveMethod(string accid,String contstr,String contstr2){

        try{
            list<Contact> contlist = (list<Contact>)JSON.deserialize(contstr, list<Contact>.class);
            list<Contact> contlist2 = (list<Contact>)JSON.deserialize(contstr2, list<Contact>.class);
            for(Contact cont:contlist){
                cont.Accountid = accid;
            }
            Upsert contlist2;
            if(!contlist.isEmpty()){Insert contlist;}
        }catch(exception e){System.debug(e.getMessage());}
    }
}