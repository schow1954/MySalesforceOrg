trigger UserTrigger on User (After Update) {

    for(string uid:Trigger.newMap.keySet()){
        if(Trigger.newMap.get(uid).MobilePhone <> Trigger.oldMap.get(uid).MobilePhone){
            Trigger.newMap.get(uid).addError('手机号无法修改！');
        }
    }
}