public class CalloutClass {
     
    public static HttpResponse getInfoFromExternalService() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('<a class="vglnk" href="http://api.salesforce.com/foo/bar" rel="nofollow"><span>http</span><span>://</span><span>api</span><span>.</span><span>salesforce</span><span>.</span><span>com</span><span>/</span><span>foo</span><span>/</span><span>bar</span></a>');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
}