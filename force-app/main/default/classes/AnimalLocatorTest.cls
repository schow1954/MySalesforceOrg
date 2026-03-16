@isTest
public class AnimalLocatorTest  {
    
    @isTest static void testGetCallout() {
        //Set mock callout class
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock());
        //This causes a fake response to be sent
        //from the class that implements HttpCalloutMock
        String result = AnimalLocator.getAnimalNameById(2);
       // String expectedValue = '{"animal":{"id":2,"name":"bear","eats":"berries, campers, adam seligman","says":"yum yum"}}'
        String expectedResult='bear';
        System.assertEquals(result, expectedResult);

    }   // end method
    
}   // end class