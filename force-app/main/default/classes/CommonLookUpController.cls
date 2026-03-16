public with sharing class CommonLookUpController {
    public class RetrieveWrapper {
        //keyword:used to retrieve this
        @AuraEnabled
        public String retrieveKeyword{get;set;}
        //search group： values :(ALL FIELDS/EMAIL FIELDS/NAME FIELDS/PHONE FIELDS/SIDEBAR FIELDS)
        @AuraEnabled
        public String searchGroup{get;set;}
        //obj api name -> field    eg: account->Name
        @AuraEnabled
        public Map<String,String> objName2FieldMap{
        	get{
        		if(objName2FieldMap != null) {
        			Map<String,String> objLowerCaseName2FieldMap = new Map<String,String>();
        			for(String objName : objName2FieldMap.keySet()) {
        				objLowerCaseName2FieldMap.put(objName.toLowerCase(), objName2FieldMap.get(objName));
        			}
        			objName2FieldMap.clear();
        			objName2FieldMap = objLowerCaseName2FieldMap;
        		}
        		return objName2FieldMap;
        	}
        	set;
        }
        //obj api name -> condition eg : account -> where name like 'test%' order by name asc limit 10 offset 1
        @AuraEnabled
        public Map<String,String> objName2QueryConditionMap{get;set;}
    }


    public class SearchResultWrapper {
    	//sObject ID
        @AuraEnabled
    	public String objId { get; set; }
        //sobject api name  eg:Account
        @AuraEnabled
        public String objName{ get; set; }
        //sobject label name eg: Account
        @AuraEnabled
        public String objLabel { get; set; }
        //sObject Value
        @AuraEnabled
        public String objValue { get; set; }
    }

    @AuraEnabled
    public static List<SearchResultWrapper> search(RetrieveWrapper wrapper) {
        System.debug(LoggingLevel.INFO, '*** wrapper: ' + JSON.serialize(wrapper));
        String retrieveSQL = buildRetrieveSQL(wrapper);
        System.debug(LoggingLevel.INFO, '*** retrieveSQL: ' + retrieveSQL);
        List<SearchResultWrapper> searchResultWrappers = new List<SearchResultWrapper>();
        if(retrieveSQL == null || (!retrieveSQL.contains('FIND'))) {
            return null;
        }
        List<List<sObject>> searchResults = search.query(retrieveSQL);
        System.debug(LoggingLevel.INFO, '*** searchResults: ' + JSON.serialize(searchResults));
        if(searchResults.size() > 0) {
            for(List<sObject> objs : searchResults) {
                for(sObject obj : objs) {
                	SearchResultWrapper searchResultItem = new SearchResultWrapper();
                	searchResultItem.objId = obj.Id;
                	searchResultItem.objName = getAPINameByObjId(obj.Id);
                    searchResultItem.objLabel = getLabelNameByObjId(obj.Id);
                	String field2Fetch = wrapper.objName2FieldMap.get(searchResultItem.objName);
                	searchResultItem.objValue = (String)obj.get(field2Fetch);
                	searchResultWrappers.add(searchResultItem);
                }
            }
        }
        return searchResultWrappers;
    }


    private static String buildRetrieveSQL(RetrieveWrapper wrapper) {
        String fetchSQL;
        if(wrapper.retrieveKeyword != null && wrapper.retrieveKeyword.trim() != '') {
            String keyword = '\'' + wrapper.retrieveKeyword + '\'';
            fetchSQL = 'FIND ' + keyword;

            if(wrapper.searchGroup != null) {
                fetchSQL += ' IN ' + wrapper.searchGroup;
            } else {
                fetchSQL += ' IN ALL FIELDS';
            }

            if(wrapper.objName2FieldMap != null) {
                List<String> objToFieldsList = new List<String>();
                for(String key : wrapper.objName2FieldMap.keySet()) {
                    String objName = key;
                    String fieldStr;
                    if(wrapper.objName2FieldMap != null && wrapper.objName2FieldMap.get(objName) != null) {

                        fieldStr = wrapper.objName2FieldMap.get(objName);
                    } else {
                        fieldStr = String.join(getAvailableFields(objName), ',');
                    }
                    String filterStr;
                    if(wrapper.objName2QueryConditionMap != null) {
                        filterStr = wrapper.objName2QueryConditionMap.get(objName);
                    }

                    if(String.isNotEmpty(filterStr)){
                        fieldStr = '(' + fieldStr + ' WHERE ' + filterStr +')';
                    }
                    else{
                        if(fieldStr != null) {
                            fieldStr = '(' + fieldStr +')';
                        }
                    }
                    if(fieldStr != null) {
                        objName = key + fieldStr;
                    } else {
                        objName = key;
                    }
                    
                    objToFieldsList.add(objName);
                }

                if(objToFieldsList.size() > 0) {
                    fetchSQL += ' RETURNING ' + String.join(objToFieldsList, ',');
                }
            }
        }
        return fetchSQL;
    }

    private static String getAPINameByObjId(String objId) {
        String objPrefix = objId.left(3);
        return objId2APIName.get(objPrefix).toLowerCase();
    }

    private static String getLabelNameByObjId(String objId) {
        String objPrefix = objId.left(3);
        return objId2ObjName.get(objPrefix).toLowerCase();
    }


    private static Map<String,String> objId2APIName {
        get {
            if(objId2APIName == null) {
                objId2APIName = new Map<String,String>();
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                for(String objectName : gd.keySet()) {
                    Schema.SObjectType objectType = gd.get(objectName);
                    String prefix = objectType.getDescribe().getKeyPrefix();
                    if(prefix != null) {
                        objId2APIName.put(prefix, objectName);
                    }
                }
            }
            return objId2APIName;
        }
        set;
    }

    private static Map<String,String> objId2ObjName {
        get {
            if(objId2ObjName == null) {
                objId2ObjName = new Map<String,String>();
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                for(String objectName : gd.keySet()) {
                    Schema.SObjectType objectType = gd.get(objectName);
                    String prefix = objectType.getDescribe().getKeyPrefix();
                    if(prefix != null) {
                        objId2ObjName.put(prefix, objectType.getDescribe().getLabel());
                    }
                }
            }
            return objId2ObjName;
        }set;
    }

    private static List<String> getAvailableFields(String objName) {
        List<String> availableFields = new List<String>();
        List<Schema.DescribeSObjectResult> objDescribes = Schema.describeSObjects(new List<String>{objName});
        Schema.DescribeSObjectResult objDescribe;
        if(objDescribes != null && objDescribes.size() > 0) {
            objDescribe = objDescribes.get(0);
        } else {
            return null;
        }
        Map<String,SObjectField> sObjectFieldMaps = objDescribe.fields.getMap();
        for(String objField : sObjectFieldMaps.keySet()) {
            SObjectField field = sObjectFieldMaps.get(objField);
            DescribeFieldResult fieldResult = field.getDescribe();
            if(fieldResult.isAccessible()) {
                availableFields.add(fieldResult.getName());
            }
        }
        return availableFields;
    }
}