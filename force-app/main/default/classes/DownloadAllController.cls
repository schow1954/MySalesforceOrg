public with sharing class DownloadAllController{

    public static final String GENERALURL = '/sfc/servlet.shepherd/version/download/';

    public static String download(Id recordid){

        List<String> ids = new List<String>();
        String contverionidstr = '';
        String contenturl;
        
        if(String.isNotBlank(recordid))
        {
            List<ContentDocumentLink> doclinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recordid];
            if(!doclinks.isEmpty()){for(ContentDocumentLink cont: doclinks){ids.add(cont.ContentDocumentId);}}
            if(!ids.isEmpty())
            {
                List<ContentVersion> contents = [Select Id FROM ContentVersion WHERE ContentDocumentId In:ids and IsLatest = true ];
                if(!contents.isEmpty()){
                    for(ContentVersion cv: contents){contverionidstr += cv.Id +'/';}
                    contverionidstr = contverionidstr.substring(0,contverionidstr.length()-1);
                }
            }
            if(String.isNotBlank(contverionidstr))
            contenturl = GENERALURL + contverionidstr + '?';
        }
        return contenturl;
    }
}