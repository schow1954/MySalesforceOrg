@RestResource(urlMapping='/Booking/*')
global with sharing class CSC_App_Booking{

    public class AppInput{
        public String name;
        public String password;
    }
    public class Outers{
        public list<AppOut> val = new list<AppOut>();
    }

    public class AppOut{
        public String accName;
        public String accOthr;
        public list<inn> items = new list<inn>();
    }
    public class inn{
        public string contName;
        public string contid;
    }
    
    @HttpPost
    global static String doPost(){
        RestRequest request = RestContext.request;
system.debug('请求头:    '+request.headers.tostring());
system.debug('请求体:    '+request.requestBody.tostring());


        AppInput input = (CSC_App_Booking.AppInput)JSON.deserialize(request.requestBody.tostring(),CSC_App_Booking.AppInput.class);
        System.debug('请求内容： '+input);
        Company_Chop__c record =[select id,Remark__c from Company_Chop__c where id =: 'a042v000029oN4N'];
        record.Remark__c = input.name;
        update record;
        inn in1 = new inn();
        in1.contName = 'test1';
        in1.contid = '1';
        
        inn in2 = new inn();
        in1.contName = 'test2';
        in1.contid = '2';
        
        inn in3 = new inn();
        in1.contName = 'test3';
        in1.contid = '3';
        
        AppOut result = new AppOut();
        result.accName = 'sam';
        result.accOthr = 'ppppppp';
        result.items.add(in1);
        result.items.add(in2);
        
        AppOut result1 = new AppOut();
        result1.accName = 'sam1';
        result1.accOthr = 'ppppppp1';
        result1.items.add(in3);
        
        Outers data = new Outers();
        data.val.add(result);
        data.val.add(result1);
        
        return JSON.serialize(data);
    }
}