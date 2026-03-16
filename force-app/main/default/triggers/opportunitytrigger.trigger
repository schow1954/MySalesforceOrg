trigger opportunitytrigger on Opportunity (after insert,after delete) {

     if(Trigger.isAfter && Trigger.isUpdate){
         for(Id oid: Trigger.newMap.keySet()){
             if(Trigger.newMap.get(oid).Agree_Status__c == 'Yes' && Trigger.newMap.get(oid).Agree_Status__c <> Trigger.oldMap.get(oid).Agree_Status__c){
                 if(Trigger.newMap.get(oid).Country__c == 'Chile'){
                     Trigger.newMap.get(oid).addError('chile can not be approval!');
                 }
             }
         }
     }
    /*
    if(trigger.isafter && trigger.isInsert){
        map<string,string> maps = new map<string,string>();
        list<ContentDocumentLink> data = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId In:trigger.newMap.keySet()];
        for(ContentDocumentLink r:data){
            maps.put(r.LinkedEntityId, r.ContentDocumentId);
        }
        list<ContentDocumentLink> updatedata = new list<ContentDocumentLink>();
        for(Opportunity record:trigger.new){
            if(string.valueOf(maps.keySet()).contains(record.Id)){
                ContentDocumentLink link = new ContentDocumentLink();
                link.LinkedEntityId = record.Accountid;
                link.ContentDocumentId = maps.get(record.Id);
                link.ShareType  = 'V';
                updatedata.add(link);
            }
        }
        if(!updatedata.isEmpty()){
            insert updatedata;
        }
    }

    if(trigger.isafter && trigger.isDelete){

    }*/
}