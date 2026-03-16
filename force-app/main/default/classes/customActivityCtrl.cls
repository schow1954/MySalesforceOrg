public class customActivityCtrl {
    @AuraEnabled 
    public static List<task> fetchTask(){
        return [SELECT Id,Subject,Description,ActivityDate,Who.Name,WhoId,Priority
                FROM Task
                LIMIT 20];
    }
}