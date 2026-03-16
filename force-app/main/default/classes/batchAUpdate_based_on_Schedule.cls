global class batchAUpdate_based_on_Schedule implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Name FROM account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<account> scope)
    {
        for (account child : scope){

         
          update child;

        }
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}