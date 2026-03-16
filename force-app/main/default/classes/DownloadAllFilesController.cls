public class DownloadAllFilesController {
   
    @AuraEnabled
	public static string doDownload(String myid){
        Map<String,String> maps = new Map<String,String>();
        Map<String,String> maps2 = new Map<String,String>();
        if(String.isNotBlank(myid)){
            Expenses_Management__c rcd = [SELECT Id,Name FROM Expenses_Management__c WHERE Id =:myid];
            String docname = rcd.Name+'_'+String.valueOf(Date.today())+'.zip';
            List<ContentDocumentLink> doclinks = [SELECT ContentDocumentId, ContentDocument.Title,ContentDocument.FileType
                                                  FROM ContentDocumentLink WHERE LinkedEntityId =: myid];
            if(!doclinks.isEmpty())
            {
                for(ContentDocumentLink clink:doclinks){ 
                    maps.put(clink.ContentDocumentId,clink.ContentDocument.Title);
                    maps2.put(clink.ContentDocumentId,clink.ContentDocument.FileType);
                }
            }else{
                return '1';
            }
            if(!maps.isEmpty())
            {
                List<ContentVersion> docs = [Select Id,Title,Description,ContentDocumentId,VersionData 
                                             from ContentVersion Where ContentDocumentId In:maps.keySet() and IsLatest = true ];
                if(!docs.isEmpty()){
                    Zippex sampleZip = new Zippex();
                    for(ContentVersion cont:docs){
                        sampleZip.addFile(maps.get(cont.ContentDocumentId)+'.'+maps2.get(cont.ContentDocumentId),cont.VersionData, null);
                    }
                    try{
                        Document doc = new Document();
                        doc.FolderId = UserInfo.getUserId();
                        doc.Name = docname;
                        doc.Body = sampleZip.getZipArchive();
                        Insert doc;	
                        return '/servlet/servlet.FileDownload?file='+doc.Id;
                    }catch(Exception e){System.debug(e.getMessage());}
                }
            }
        }
        return null;
    } 
}