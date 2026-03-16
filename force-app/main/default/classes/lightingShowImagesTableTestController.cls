public with sharing class lightingShowImagesTableTestController {
    
	@AuraEnabled
    public static List<List<Contact>> getData(){
        List<List<Contact>> results = new List<List<Contact>>();
        List<String> accsIds = new List<String>();
        accsIds.add('0012v00002zqYZAAA2');
        accsIds.add('0012v00002zqYZjAAM');
        list<Account> acclist = [select Id from Account where Id In: accsIds]; 
        if(!acclist.isEmpty()){
            Set<String> accIds = new Set<String>();
            for(Account acc : acclist){ accIds.add(acc.Id);}
            if(!accIds.isEmpty()){
                List<Contact> opplist = [Select Id,Name,AccountId from Contact where AccountId In : accIds order by CreatedDate];
                if(!opplist.isEmpty()){
                    Integer count = opplist.size() / 6;
                    Integer num = opplist.size() - count * 6;
                    if(num <> 0){ count += 1;}
                    Integer temp = 0;
                    for(Integer i = 0; i< count; i++){
                        List<Contact> oppline = new List<Contact>();
                        for(Integer j = 0; j < 6;j++){
                            Integer temp1 = temp * 6 + j;
                            if(opplist.size() > temp1){
								oppline.add(opplist[temp1]); 
                            }else{
                                oppline.add(New Contact()); 
                            }
                        }
                        results.add(oppline);
                        temp++;
                    }
                }
            }
        }
        return results;
    }
}