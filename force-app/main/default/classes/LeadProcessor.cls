global class LeadProcessor implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT ID, LeadSource FROM Lead');
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope){
        for(Lead l:scope){
            l.LeadSource = 'Dreamforce';
        }
        Update scope;
    }
    
     public void finish(Database.BatchableContext bc){}
}