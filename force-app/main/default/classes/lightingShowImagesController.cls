public with sharing class lightingShowImagesController {

	@AuraEnabled(cacheable=true)
    public static List<List<Contact>> getData(String phototype){
        List<List<Contact>> results = new List<List<Contact>>();
        List<String> accsIds = new List<String>();
        
        if(phototype == '会场'){
            accsIds.add('0012v00002zqYZAAA2');
        }
        if(phototype == '讲者'){
            accsIds.add('0012v00002zqYZjAAM');
        }
        
        list<Account> acclist = [select Id from Account where Id In: accsIds];
        if(!acclist.isEmpty()){
            Set<String> accIds = new Set<String>();
            for(Account acc : acclist){ accIds.add(acc.Id);}
            if(!accIds.isEmpty()){
                List<Contact> opplist = [Select Id,Name,AccountId from Contact where AccountId In : accIds order by CreatedDate];
                if(!opplist.isEmpty()){
                    Integer count = opplist.size() / 5;
                    Integer num = opplist.size() - count * 5;
                    if(num <> 0){ count += 1;}
                    Integer temp = 0;
                    for(Integer i = 0; i< count; i++){
                        List<Contact> oppline = new List<Contact>();
                        for(Integer j = 0; j < 5;j++){
                            Integer temp1 = temp * 5 + j;
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

    @AuraEnabled(cacheable=true)
    public static List<String> getSessions(String prno){
        Set<String> resultSet = new Set<String>();
        List<String> results = new List<String>();
        if(String.isNotBlank(prno)){
            List<Account> acclist = [Select Id,Name From Account limit 5];
            if(!acclist.isEmpty()){
                for(Account acc : acclist){
                    resultSet.add(acc.Name);
                }
                if(resultSet.size() > 0){
                    for(String str : resultSet){
                        results.add(str);
                    }
                }
            }
        }
        return results;
    }
    

    @AuraEnabled(cacheable=true)
    public static List<List<Contact>> loadMore(Integer thislimit){
        List<List<Contact>> results = new List<List<Contact>>();
        List<String> accsIds = new List<String>();
        accsIds.add('0012v00002zqYZAAA2');
        accsIds.add('0012v00002zqYZjAAM');
        list<Account> acclist = [Select Id From Account Where Id In: accsIds Limit: thislimit]; 
        if(!acclist.isEmpty()){
            Set<String> accIds = new Set<String>();
            for(Account acc : acclist){ accIds.add(acc.Id);}
            if(!accIds.isEmpty()){
                List<Contact> opplist = [Select Id,Name,AccountId From Contact where AccountId In : accIds order by CreatedDate];
                if(!opplist.isEmpty()){
                    Integer count = opplist.size() / 5;
                    Integer num = opplist.size() - count * 5;
                    if(num <> 0){ count += 1;}
                    Integer temp = 0;
                    for(Integer i = 0; i< count; i++){
                        List<Contact> oppline = new List<Contact>();
                        for(Integer j = 0; j < 5;j++){
                            Integer temp1 = temp * 5 + j;
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