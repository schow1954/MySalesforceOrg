/**************************************************************************************************
 * Name: CompanyChopHandler
 * Object: Company_Chop__c
 * Purpose: CompanyChopTrigger handler
 * Author_Date: zhou 2019-10-18
***************************************************************************************************/
public with sharing class CompanyChopHandler{

    public static Company_Chop__c setApprover(Company_Chop__c chop)
    {
        //证照文件类型
        if(chop.Files_Type__c == '证照')
        {
            chop.Approver1__c = ApproverCandidates.getDepHead(chop.OwnerId,3)[0]; //Dep. Head
            if(chop.Legal_Entity__c == '艾伯维医药贸易(上海)有限公司')
            {
                if(chop.Certification_Doc__c == '进口药品注册证'){
                    chop.Approver2__c = null; //Lv Qi
                }
                if(chop.Certification_Doc__c == '法人身份证' || chop.Certification_Doc__c == '回乡证'){
                    chop.Approver2__c = null; //Tony Au
                }
            }
            if(chop.Legal_Entity__c == '北京分公司')
            {
                if(chop.Certification_Doc__c == '法人身份证'){
                    chop.Approver2__c = null; //Cheery Chen
                }
            }
            if(chop.Legal_Entity__c == '广州分公司')
            {
                if(chop.Certification_Doc__c == '法人身份证'){
                    chop.Approver2__c = null; //Luo Xuemei
                }
            }
            if(chop.Legal_Entity__c == '杭州分公司')
            {
                if(chop.Certification_Doc__c == '法人身份证'){
                    chop.Approver2__c = null; //Yu Peng
                }
            }
            if(chop.Legal_Entity__c == '成都分公司')
            {
                if(chop.Certification_Doc__c == '法人身份证'){
                    chop.Approver2__c = null; //Huang Haikuo
                }
            }
            if(chop.Legal_Entity__c == '静安分公司')
            {
                if(chop.Certification_Doc__c == '法人身份证'){
                    chop.Approver2__c = null; //Jeslin Wang
                }
            }
        }
        
        //合同类型
        if(chop.Files_Type__c == '合同')
        {
            chop.Approver3__c = null; //FD
            if(chop.Contract_Type__c == '采购相关协议')
            {
                chop.Approver2__c = null; //Starry
            }
            if(chop.Contract_Type__c == '临床研究相关协议')
            {	
                chop.Approver2__c = ApproverCandidates.getDepHead(chop.OwnerId,3)[0];//Dep. Head
                if(chop.Contract_Types__c == 'Global Review'){
                    chop.Approver1__c = ApproverCandidates.getDepHead(chop.OwnerId,3)[0];//Dep. Head
                }
            }
            if(chop.Contract_Type__c == 'OEC相关协议')
            {
                chop.Approver2__c = ApproverCandidates.getDepHead(chop.OwnerId,4)[0]; //BUD
            }
            if(chop.Contract_Type__c == 'HR相关协议')
            {
                chop.Approver1__c = ApproverCandidates.getDepHead(chop.OwnerId,4)[0]; //HRD
                if(chop.Contract_Types__c == '其他与政府合同' || chop.Contract_Types__c == '其他与HR部门相关或发起的协议'){
                    chop.Approver2__c = ApproverCandidates.getDepHead(chop.OwnerId,2)[0]; //HRD
                }
            }
            if(chop.Contract_Type__c == 'HIV招标相关协议')
            {
                chop.Approver2__c = ApproverCandidates.getDepHead(chop.OwnerId,4)[0]; //BUD
            }
            if(chop.Contract_Type__c == '商务部相关协议')
            {
                chop.Approver1__c = null; //Wayne Lu
            }
            if(chop.Contract_Type__c == '办公室租赁协议')
            {
                chop.Approver2__c = null; //Starry
            }
            if(chop.Contract_Type__c == '质量部相关协议')
            {
                chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
            }
            if(chop.Contract_Type__c == '医学相关协议')
            {
                chop.Approver2__c = ApproverCandidates.getDepHead(chop.OwnerId,4)[0]; //BUD
            }
            if(chop.Contract_Type__c == '注册部相关协议')
            {
                if(chop.Contract_Types__c == '委托检验合同'){
                    chop.Approver1__c = null; //Cheery Chen
                }
            }
            if(chop.Contract_Type__c == 'MA')
            {
                chop.Approver2__c = ApproverCandidates.getDepHead(chop.OwnerId,3)[0]; //Dep. Head
            }
        }
        
        //其他类型
        if(chop.Files_Type__c == '其他')
        {
            chop.Approver3__c = null; //FD
            chop.Approver4__c = null; //Admin
            if(chop.Files_Types__c == 'HR相关文件')
            {
                chop.Approver1__c = ApproverCandidates.getQueueUsers('HR')[0]; //HR
                if(chop.Files_Content__c == '其他'){
                    chop.Approver1__c = null; //Elaine Lu
                }
            }
            if(chop.Files_Types__c == '财务相关文件')
            {
                if(chop.Files_Content__c == '公司信用卡申请'){
                    chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
                }else{
                    chop.Approver1__c = null; //Teresa Liang
                }
            }
            if(chop.Files_Types__c == 'RA注册相关文件')
            {
                if(chop.Files_Content__c == '注册申请表' || chop.Files_Content__c == '其他'){
                    chop.Approver1__c = null; //Cheery Chen
                }else{
                    chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
                }
            }
            if(chop.Files_Types__c == 'Trade相关招标资料')
            {
                chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
                chop.Approver2__c = null; //Wayne Lu
            }
            if(chop.Files_Types__c == 'BU相关文件')
            {   
                if(chop.Files_Content__c == '进药资料'){
                    chop.Approver2__c = ApproverCandidates.getDepHead(chop.OwnerId,4)[0]; //BUD
                }
                if(chop.Files_Content__c == '授权委托书'){
                    chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
                    chop.Approver2__c = ApproverCandidates.getDepHead(chop.OwnerId,4)[0]; //BUD
                }
            }
            if(chop.Files_Types__c == 'Legal相关文件')
            {
                chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
                chop.Approver2__c = ApproverCandidates.getQueueUsers('Legal')[0]; //Legal
            }
            if(chop.Files_Types__c == 'GSP相关文件')
            {
                chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
                chop.Approver2__c = null; //Li Bing
            }
            if(chop.Files_Types__c == '市场准入相关文件')
            {   
                if(chop.Files_Content__c == '医保药学协会入会申请表'){
                    chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
                    chop.Approver2__c = null; //Lily Chen
                }
                else if(chop.Files_Content__c == '其他市场准入相关文件'){
                    chop.Approver1__c = null; //Lily Chen
                }else{
                    chop.Approver1__c = null; //Li Yi
                    chop.Approver2__c = null; //Lily Chen
                }
            }
            if(chop.Files_Types__c == '报关相关文件')
            {
                chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
                chop.Approver2__c = ApproverCandidates.getQueueUsers('GTC')[0]; //GTC
            }
            if(chop.Files_Types__c == '临床研究相关文件')
            {
                if(chop.Files_Content__c == '其他'){
                    chop.Approver1__c = null; //Rachel Tang
                }else{
                    chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId); //Line Mgr
                }
            }
            if(chop.Files_Types__c == 'VISA相关文件')
            {
                chop.Approver1__c = ApproverCandidates.getDepHead(chop.OwnerId,3)[0]; //Dep. Head
            }
            if(chop.Files_Types__c == '行政相关文件')
            {
                chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId);//Line Mgr
            }
            if(chop.Files_Types__c == 'PA相关文件')
            {
                chop.Approver1__c = ApproverCandidates.getLineManager(chop.OwnerId);//Line Mgr
                chop.Approver2__c = null; //Vivian Wang
            }
            if(chop.Files_Types__c == '超过系统容量的超大文件')
            {
                chop.Approver1__c = ApproverCandidates.getDepHead(chop.OwnerId,3)[0]; //Dep. Head
            }
        }
    return chop;
    }
}