public without sharing class SchemaUtil{
    
    /*
        通过sObjectName和指定字段获取PickList的value值
    */
    public static Map<String, object> getPicklistValues(String sObjectName, String sFieldName){
        Map<String, String> picValues= new Map<String, String>();
        Map<String, Schema.SObjectType> sObjectDescribeMap = Schema.getGlobalDescribe();
        if (sObjectDescribeMap.containsKey(sObjectName)) {
            Map<String, Schema.SobjectField> sObjectFieldsMap =
               sObjectDescribeMap.get(sObjectName).getDescribe().fields.getMap();
            if (sObjectFieldsMap.containsKey(sFieldName)) {
                Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFieldsMap.get(sFieldName).getDescribe();
                List<Schema.PicklistEntry> lPickEntryList = sObjectFieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry tPicklistEntry : lPickEntryList) {
                    picValues.put(tPicklistEntry.getValue(),tPicklistEntry.getValue());
                }
            } else {
                //TODO 不存在此字段的执行
            }
        } else {
            // TODO 不存在此sObject的执行
        }
        return picValues;
    }
}