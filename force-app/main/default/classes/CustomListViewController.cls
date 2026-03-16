/**************************************************************************************************
* Name           : CustomListViewController
* Object         : Approval Request
* Target         : EVENT-4886 Manage All审批列表显示不正确问题
* Author         : Sam zhou
* Create Date    : 2022-01-20
* Modify History :
*********************************************************** ***************************************/
public with sharing class CustomListViewController {
    
    @AuraEnabled( cacheable = true )  
    public static List < sObject > fetchRecs( String listValues ) {  
        
system.debug( 'values are ' + listValues );  
        List < String > strList = listValues.split( '-' );  
system.debug( 'values are ' + strList );   
        String strObject = strList.get( 0 );
        String strFields = strList.get( 1 );
        String strRelatedField = strList.get( 2 );
        String strAccountId;
        if ( strList.size() == 4)
            strAccountId = strList.get( 3 );
        List < sObject > listRecs = new List < sObject >();
        String strSOQL = 'SELECT Id, ' + strFields + ' FROM ' + strObject;

        if ( String.isNotBlank( strAccountId ) )
            strSOQL  += ' WHERE ' + strRelatedField+ ' = \'' + strAccountId + '\'';
        
        strSOQL += ' LIMIT 25';
system.debug( 'SOQL is ' + strSOQL );
        listRecs = Database.query( strSOQL );
        return listRecs;
          
    }  

}