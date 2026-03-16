/**************************************************************************************************
 * Name: ContracRequestController
 * Object: CustomContract
 * Author: zhou
 * Create Date: 2019-9-3
***************************************************************************************************/
public class ContracRequestController{

    @AuraEnabled
    public Static CustomContract__c doInit(String cid){
        if(String.isNotBlank(cid)){
            try{
                CustomContract__c applyinfo = [SELECT Id,ApplyUser__c,RequestDepartment__c,ContractNumber__c,Name,Signature_Target__c,ContactType__c,ContractAmountType__c,Files_Named__c,RequestDate__c FROM CustomContract__c WHERE Id =:cid];
                if(applyinfo.ContractAmountType__c == '合同金额 <= RMB 300,000')  applyinfo.ContractAmountType__c = '1';
                if(applyinfo.ContractAmountType__c == 'RMB 300,000 <= 合同金额 <= RMB 1,000,000')  applyinfo.ContractAmountType__c = '2';
                if(applyinfo.ContractAmountType__c == '合同金额 > 1,000,000')  applyinfo.ContractAmountType__c = '3';
                applyinfo.ApplyUser__c = Userinfo.getFirstName() +' '+Userinfo.getLastName();
                applyinfo.RequestDepartment__c = [SELECT Id,Department FROM User WHERE Id =:Userinfo.getUserId()].Department;
                applyinfo.ApplyUsers__c = Userinfo.getUserId();
                return applyinfo;
            }catch(Exception e){System.debug(e.getMessage());}
        }
        return null;
    }   
    public static Ques_Answer__c setAnswers(){
        Ques_Answer__c descinfo = new Ques_Answer__c();
        descinfo.QUES1__c = false;
        descinfo.QUES2__c = false;
        descinfo.QUES3__c = false;
        descinfo.QUES4__c = false;
        descinfo.QUES5__c = false;
        descinfo.QUES6__c = false;
        descinfo.QUES7__c = false;
        descinfo.QUES8__c = false;
        descinfo.QUES9__c = false;
        descinfo.QUES10__c = false;
        descinfo.QUES11__c = false;
        descinfo.Ba__c = false;
        descinfo.Bb__c = false;
        descinfo.Bc__c = false;
        descinfo.Bd__c = false;
        descinfo.Be__c = false;
        descinfo.Ca__c = false;
        descinfo.Cc__c = false;
        descinfo.Fa__c = false;
        descinfo.Fb__c = false;
        descinfo.Fc__c = false;
        descinfo.Fd__c = false;
        descinfo.Fe__c = false;
        descinfo.Ha__c = false;
        descinfo.Hb__c = false;
        descinfo.Hc__c = false;
        return descinfo;
    }
    public static Boolean setDescribe(String cont,String keystr){
        if(cont.contains(keystr)){return true;}
        return false;
    }
    public static Boolean setGeneralQuestions(String cont,String keystr){
        if(cont.contains(keystr)){return true;}
        return false;
    }
    @AuraEnabled
    public Static Ques_Answer__c descInit(String cid){
      Ques_Answer__c descinfo = new Ques_Answer__c();
      if(String.isNotBlank(cid)){
          try{
            Answers__c rcd = [SELECT Id,Answer__c,Name FROM Answers__c WHERE CustomContract__c =:cid order by CreateTime__c Desc limit 1];
            if(rcd.Name == '描述'){
                descinfo.QUES1__c = setDescribe(rcd.Answer__c,'1.1');
                descinfo.QUES2__c = setDescribe(rcd.Answer__c,'1.2');
                descinfo.QUES3__c = setDescribe(rcd.Answer__c,'2.1');
                descinfo.QUES4__c = setDescribe(rcd.Answer__c,'2.2');
                descinfo.QUES5__c = setDescribe(rcd.Answer__c,'2.3');
                descinfo.QUES6__c = setDescribe(rcd.Answer__c,'2.4');
                descinfo.QUES7__c = setDescribe(rcd.Answer__c,'2.5');
                descinfo.QUES8__c = setDescribe(rcd.Answer__c,'3.');
                descinfo.QUES9__c = setDescribe(rcd.Answer__c,'4.');
                descinfo.QUES10__c = setDescribe(rcd.Answer__c,'本项目已遵守');
                descinfo.QUES11__c = setDescribe(rcd.Answer__c,'本项目使用了');
            }else{
                descinfo = setAnswers();
            }
          }catch(Exception e){
              System.debug(e.getMessage());
              descinfo = setAnswers();
          }

          List<Id> dids = new List<Id>();
          String filename = '';
          List<ContentDocumentLink> doclist = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId =:cid];
          if(doclist.size()>0){
              for(ContentDocumentLink cd:doclist){
                dids.add(cd.ContentDocumentId);
              }
              List<ContentDocument> docs = [SELECT Title,Id from ContentDocument where Id In: dids];
              for(ContentDocument ct:docs){
                  filename += ct.Title;
              }
              if(String.isNotBlank(filename)){
                  if(setGeneralQuestions(filename,'直线经理确认邮件')) descinfo.Ab__c = '小于10个工作日'; 
                  descinfo.Ba__c = setGeneralQuestions(filename,'采购部审批意见');
                  descinfo.Bb__c = setGeneralQuestions(filename,'法律部审批意见');
                  if(setGeneralQuestions(filename,'合同副本')) descinfo.E__c = '是';
                  descinfo.Fa__c = setGeneralQuestions(filename,'医学部最终意见');
                  descinfo.Fb__c = setGeneralQuestions(filename,'OEC最终意见');
                  descinfo.Fc__c = setGeneralQuestions(filename,'公关部最终意见');
                  descinfo.Fd__c = setGeneralQuestions(filename,'质量部最终意见');
                  descinfo.Fe__c = setGeneralQuestions(filename,'其他部门最终意见');
                  if(setGeneralQuestions(filename,'合同副本')) descinfo.Gb__c = '是';
                  if(setGeneralQuestions(filename,'Third Party Screening')) {descinfo.Gf__c = '是';descinfo.Ge__c = '是';}
                  if(setGeneralQuestions(filename,'Enhanced due diligence'))descinfo.Gg__c = '是';
              }
          }
      }else{
          descinfo = setAnswers();
      }
	    return descinfo;
    } 

    @AuraEnabled
    public Static Boolean saveContract(String cid,String contracts,String answers){
       if(String.isNotBlank(cid) && String.isNotBlank(contracts) && String.isNotBlank(answers)){
            try{
                CustomContract__c item = (CustomContract__c)JSON.deserialize(contracts, CustomContract__c.class);
                if(item.ContractAmountType__c == '1') item.ContractAmountType__c = '合同金额 <= RMB 300,000';
                if(item.ContractAmountType__c == '2') item.ContractAmountType__c = 'RMB 300,000 <= 合同金额 <= RMB 1,000,000';
                if(item.ContractAmountType__c == '3') item.ContractAmountType__c = '合同金额 > 1,000,000';
                Database.Update(item);
                Ques_Answer__c subitem = (Ques_Answer__c)JSON.deserialize(answers, Ques_Answer__c.class);
                subitem.CustomContract__c = cid;
                List<Answers__c> answerlist = new List<Answers__c>();
                //Description
                Answers__c asw = new Answers__c();
                asw.CustomContract__c = cid;
                asw.Name = label.Decription;
                asw.Answer__c = '';
                if(subitem.QUES1__c <> false)  asw.Answer__c =  label.Decription1+ '<br/>';
                if(subitem.QUES2__c <> false)  asw.Answer__c += label.Decription2+ '<br/>';
                if(subitem.QUES3__c <> false)  asw.Answer__c += label.Decription3+ '<br/>';
                if(subitem.QUES4__c <> false)  asw.Answer__c += label.Decription4+ '<br/>';
                if(subitem.QUES5__c <> false)  asw.Answer__c += label.Decription5+ '<br/>';
                if(subitem.QUES6__c <> false)  asw.Answer__c += label.Decription6+ '<br/>';
                if(subitem.QUES7__c <> false)  asw.Answer__c += label.Decription7+ '<br/>';
                if(subitem.QUES8__c <> false)  asw.Answer__c += label.Decription8+ '<br/>';
                if(subitem.QUES9__c <> false)  asw.Answer__c += label.Decription9+ '<br/>';
                if(subitem.QUES10__c <> false) asw.Answer__c += label.Decription10+'<br/>';
                if(subitem.QUES11__c <> false) asw.Answer__c += label.Decription11+'<br/>';
                answerlist.add(asw);
                //Questions
                if(subitem.QUES1__c <> false || subitem.QUES2__c <> false 
                  || subitem.QUES3__c <> false || subitem.QUES4__c <> false 
                  || subitem.QUES5__c <> false || subitem.QUES6__c <> false 
                  || subitem.QUES7__c <> false || subitem.QUES8__c <> false 
                  || subitem.QUES9__c <> false || subitem.QUES10__c <> false || subitem.QUES11__c <> false){
                    if(subitem.Aa__c<>Null || subitem.Aa__c <> NuLL || subitem.Ac__c <> NuLL){
                        Answers__c answerA = new Answers__c();
                        answerA.CustomContract__c = cid;
                        answerA.Name = label.QuestionA;
                        answerA.Answer__c = label.QuestionAa +' : '+subitem.Aa__c+'<br/>'+label.QuestionAb+' : '+subitem.Ab__c+'<br/>'+label.QuestionAc+' : '+subitem.Ac__c;
                        answerlist.add(answerA);
                    }
                    if(subitem.Ba__c <> false || subitem.Bb__c <> false || subitem.Bc__c <> false || subitem.Bd__c <> false || subitem.Be__c <> false){
                        Answers__c answerB = new Answers__c();
                        answerB.CustomContract__c = cid;
                        answerB.Name = label.QuestionB;
                        answerB.Answer__c = '';
                        if(subitem.Ba__c <> false) answerB.Answer__c =label.QuestionBa+'<br/>';
                        if(subitem.Bb__c <> false) answerB.Answer__c +=label.QuestionBb+'<br/>';
                        if(subitem.Bc__c <> false) answerB.Answer__c +=label.QuestionBc+'<br/>';
                        if(subitem.Bd__c <> false) answerB.Answer__c +=label.QuestionBd+'<br/>';
                        if(subitem.Be__c <> false) answerB.Answer__c +=subitem.Bf__c+'<br/>';
                        answerlist.add(answerB);
                    }
                    if(subitem.Ca__c <> false || subitem.Cb__c <> Null || subitem.Cc__c <> false ){
                        Answers__c answerC = new Answers__c();
                        answerC.CustomContract__c = cid;
                        answerC.Name = label.QuestionC;
                        answerC.Answer__c = '';
                        if(subitem.Ca__c <> false) answerC.Answer__c = label.QuestionCa+'<br/>';
                        if(subitem.Cb__c <> Null)  answerC.Answer__c += subitem.Cb__c+'<br/>';
                        if(subitem.Cc__c <> false) answerC.Answer__c += label.QuestionCc+'<br/>';
                        answerlist.add(answerC);
                    }
                    if(subitem.Da__c <> Null || subitem.Db__c <> Null || subitem.Dc__c <> Null || subitem.Dd__c <> Null){
                        Answers__c answerD = new Answers__c();
                        answerD.CustomContract__c = cid;
                        answerD.Name = label.QuestionD;
                        answerD.Answer__c = '';
                        if(subitem.Da__c <> Null) answerD.Answer__c = label.QuestionDa+subitem.Da__c+'<br/>';
                        if(subitem.Db__c <> Null) answerD.Answer__c += label.QuestionDb+subitem.Db__c+'<br/>';
                        if(subitem.Dc__c <> Null) answerD.Answer__c += label.QuestionDc+subitem.Dc__c+'<br/>';
                        if(subitem.Dd__c <> Null) answerD.Answer__c += label.QuestionDd+subitem.Dd__c+'<br/>';
                        answerlist.add(answerD);
                    }
                    if(subitem.E__c <> '否' && subitem.E__c <> NuLL){
                        Answers__c answerE = new Answers__c();
                        answerE.CustomContract__c = cid;
                        answerE.Name = label.QuestionE;
                        if(subitem.Ea__c <> Null) answerE.Answer__c = label.QuestionEa+subitem.Ea__c;
                        answerlist.add(answerE);
                    }
                    if(subitem.Fa__c <> false || subitem.Fb__c <> false || subitem.Fc__c <> false || subitem.Fd__c <> false || subitem.Fe__c <> false){
                        Answers__c answerF = new Answers__c();
                        answerF.CustomContract__c = cid;
                        answerF.Name = label.QuestionF;
                        answerF.Answer__c = '';
                        if(subitem.Fa__c <> false) answerF.Answer__c = label.QuestionFa+'<br/>';
                        if(subitem.Fb__c <> false) answerF.Answer__c += label.QuestionFb+'<br/>';
                        if(subitem.Fc__c <> false) answerF.Answer__c += label.QuestionFc+'<br/>';
                        if(subitem.Fd__c <> false) answerF.Answer__c += label.QuestionFd+'<br/>';
                        if(subitem.Fe__c <> false) answerF.Answer__c += label.QuestionFe+'<br/>';
                        answerlist.add(answerF);
                    }
                    if((subitem.Ga__c <> '否' && subitem.Ga__c <> Null)
                      || (subitem.Gb__c <> '否' && subitem.Gb__c <> NuLL)
                      || (subitem.Gd__c <> '否' && subitem.Gd__c <> NuLL)
                      || (subitem.Ge__c <> '否' && subitem.Ge__c <> NuLL)
                      || (subitem.Gf__c <> '否' && subitem.Gf__c <> NuLL)
                      || (subitem.Gg__c <> '否' && subitem.Gf__c <> NuLL)){
                        Answers__c answerG = new Answers__c();
                        answerG.CustomContract__c = cid;
                        answerG.Name = label.QuestionG;
                        answerG.Answer__c = '';
                        if(subitem.Ga__c <> '否' && subitem.Ga__c <> NuLL) answerG.Answer__c = label.QuestionGa+subitem.Ga__c+'<br/>';
                        if(subitem.Gb__c <> '否' && subitem.Gb__c <> NuLL) answerG.Answer__c += label.QuestionGb+subitem.Gb__c+'<br/>';
                        if(subitem.Gd__c <> '否' && subitem.Gd__c <> NuLL) answerG.Answer__c += label.QuestionGd+subitem.Gd__c+'<br/>';
                        if(subitem.Ge__c <> '否' && subitem.Ge__c <> NuLL) answerG.Answer__c += label.QuestionGe+subitem.Ge__c+'<br/>';
                        if(subitem.Gf__c <> '否' && subitem.Gf__c <> NuLL) answerG.Answer__c += label.QuestionGf+subitem.Gf__c+'<br/>';
                        if(subitem.Gg__c <> '否' && subitem.Gg__c <> NuLL) answerG.Answer__c += label.QuestionGg+subitem.Gg__c+'<br/>';
                        answerlist.add(answerG);
                    }
                    if(subitem.Ha__c <> false || subitem.Hb__c <> false || subitem.Hc__c <> false || subitem.Hd__c <> Null){
                        Answers__c answerH = new Answers__c();
                        answerH.CustomContract__c = cid;
                        answerH.Name = label.QuestionH;
                        answerH.Answer__c = '';
                        if(subitem.Ha__c <> false) answerH.Answer__c = label.QuestionHa+'<br/>';
                        if(subitem.Hb__c <> false) answerH.Answer__c = label.QuestionHb+'<br/>';
                        if(subitem.Hc__c <> false) answerH.Answer__c = label.QuestionHc+'<br/>';
                        if(subitem.Hd__c <> Null)  answerH.Answer__c = subitem.Hd__c+'<br/>';
                        answerlist.add(answerH);
                    }
                }
                if(answerlist.size()>0){
                  List<Answers__c> alist = [SELECT Id FROM Answers__c WHERE CustomContract__c =:cid];
                  if(alist.size()>0) Delete alist;
                  Database.insert(answerlist);
                }
                return true;
            }catch(Exception e){System.debug(e.getMessage());}
       }
       return false;
    } 
   
    @AuraEnabled
    public Static Boolean handleUpload(String docid,String fname){
      try{
          ContentDocument doc = [SELECT Id,Title FROM ContentDocument WHERE Id =:docid];
          doc.Title = fname;
          Database.update(doc);
          List<ContentDocument> olddoc = [SELECT Id FROM ContentDocument WHERE Title =: fname And Id <>:docid];
          if(olddoc.size()>0)Database.delete(olddoc);
          return true;
      }catch(Exception e){System.debug(e.getMessage());}
       return false;
    }
}