public with sharing class ToDoController {
    
    //Method to return list of toDo records during component initialization
    @AuraEnabled
    public static List<ToDo__c> loadData(){
        return [SELECT ID,Reminder_Date__c,Due_Date__c,Description__c FROM ToDo__c ORDER BY Due_Date__c ASC NULLS LAST];
    }
    
    //Method to save the record in database and return error message
    @AuraEnabled
    public static String saveTodoRecord(ToDo__c toDoRecord){
        String message;
        Database.saveResult sr = Database.insert(toDoRecord,false);
        if(!sr.isSuccess()){
            for(Database.error err : sr.getErrors()){
                message += err.getMessage();
            }
        }
        return message;
    }
}