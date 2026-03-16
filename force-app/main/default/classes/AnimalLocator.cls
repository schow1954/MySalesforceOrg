public class AnimalLocator {
    
    public static String getAnimalNameById(Integer id) {
        Http http = new Http();
        HttpRequest request = new HTTPRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/' + id);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        String strRes = '';
        
        //If the response is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            System.debug(response.getBody());
            Map<String, Object> animal = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> animalInfo= (Map<String, Object>) animal.get('animal');
            System.debug(animalInfo);
            Object myAnimal = (Object) animalInfo.get('name');
            System.debug(myAnimal);
            strres = (String) myAnimal;
        }   // end if
        System.debug(strRes);
        return strRes;
    }   // end method
}   // end class