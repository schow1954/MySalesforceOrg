/**************************************************************************************************
 * Name: LookupSObjectController
 * Object: Tools
 * Author: zhou
 * Create Date: 2019-9-11
***************************************************************************************************/
public with sharing class LookupSObjectController {

    @AuraEnabled
    public static Result[] lookup(String searchString, 
                                        String sObjectAPIName, 
                                            String whereClause, 
                                                String rawSOQL,
                                                    String context) {
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        List<Result> results = new List<Result>();
        if(sanitizedSearchString.length() == 1) {
            String searchQuery = 'select Id, Name from ' + sanitizedSObjectAPIName + ' where Name like \'' + sanitizedSearchString + '%\' Limit 10';
            for(Sobject so : Database.query(searchQuery)){
                results.add(new Result((String)so.get('Name'), so.Id));  
            }
        } else {
            if(String.isBlank(rawSOQL)){
                String returningFields = '(id,name)';
                if(String.isNotBlank(whereClause)){
                    returningFields =' (id,name WHERE '+whereClause+') ';
                }

                String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName +returningFields+' Limit 20'; 
                System.debug('-->searchQuery'+searchQuery);
                List<List<SObject>> searchList = search.query(searchQuery);
                for (SObject so : searchList[0]) {
                    results.add(new Result((String)so.get('Name'), so.Id));
                }
            }else{

                System.debug('-->rawSOQL'+rawSOQL);
                rawSOQL = rawSOQL.replace('searchString', sanitizedSearchString);
                if(String.isNotBlank(context) && String.isNotBlank(rawSOQL)){
                }else{
                    for(Sobject so : Database.query(rawSOQL)){
                        results.add(new Result((String)so.get('Name'), so.Id));  
                    }
                }
            }
        }
        
        return results;
    }

    public class Result {
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}
        
        public Result(String sObjectLabel, Id sObjectId) {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
}