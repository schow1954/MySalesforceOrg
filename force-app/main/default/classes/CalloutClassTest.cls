@isTest
private class CalloutClassTest {
     @isTest static void testCallout() {
          
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator1());
        HttpResponse res = CalloutClass.getInfoFromExternalService();
    }
}