public with sharing class RemoteActionDemoCls{
    // Get Account by Id
    @RemoteAction
    public static SObject getAccount(String sfdcId) {
        return [SELECT Id, Name, OwnerId, Owner.Name FROM Account WHERE Id = :sfdcId LIMIT 1];
    }
}