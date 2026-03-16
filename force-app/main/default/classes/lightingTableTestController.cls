public with sharing class lightingTableTestController {
    @AuraEnabled(cacheable=true)
   public static List<Opportunity> getOpps( String searchKey, String sortBy, String sortDirection) {
      
       String query = 'SELECT Id, Name,StageName,CloseDate FROM Opportunity';
       system.debug('query---'+query);
       if ( searchKey != null && searchKey != '' ) {
           String key = '%' + searchKey + '%';
           query += ' WHERE Name LIKE :key';
       }
       if ( sortBy != null && sortDirection != null ) {
           query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
       }
       return Database.query( query );
   }
}