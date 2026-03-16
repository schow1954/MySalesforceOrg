public without sharing class BaseObjectNamesGetFieldsetQuery{
    
    public static String getQuery(String objectName,String fieldsetName, String whereStr){
        String query = '';
        if(String.isNotBlank(objectName) && String.isNotBlank(fieldsetName)){
            query += 'Select ';
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Schema.FieldSet fieldsetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldsetName);
            Integer count = 0;
            for(Schema.FieldSetMember field: fieldSetObj.getFields()){
                if(count < fieldSetObj.getFields().size() - 1){
                    query += field.getFieldPath()+ ',';
                }else{
                    query += field.getFieldPath()+ ' ';
                }
                count++;
            }
            query += 'From '+objectname+' '+whereStr;
        }
        return query;
    }
}