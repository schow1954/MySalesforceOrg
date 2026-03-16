/**************************************************************************************************
 * Name: ApproverCandidates
 * Object: User
 * Purpose: get line manager id or DepHead id base on userid/get queue members base on name
 * Author_Date: zhou 2019-10-17
***************************************************************************************************/
public with sharing class ApproverCandidates{
    
    public class Role{
        public String BU;
        public String Department;
        public String Region;
        public String District;
    }

    public static List<String> getQueueUsers(String qname){

        List<String> uids = new List<String>();
        Group g = [SELECT Id,Name,DeveloperName FROM Group WHERE Type = 'Queue' And DeveloperName =:qname];
        List<GroupMember> userlist = [Select UserOrGroupId From GroupMember where GroupId =:g.Id And Group.Type = 'Queue'];
        if(!userlist.isEmpty()){
            for(GroupMember member:userlist){
                uids.add(member.UserOrGroupId);
            }
        }
        return uids;
    }

    public static String getLineManager(String uid){

        User u = [SELECT Id,Manager.Id FROM User WHERE Id =:uid];
        return u.Manager.Id;
    }

    public static List<String> getDepHead(String uid,Integer plevel){

        List<String> uids = new List<String>();
        User u = [SELECT Id,UserRole.DeveloperName,UserRole.Name FROM User WHERE Id =:uid];
        Role ro = new Role();
        List<String> devname = u.UserRole.Name.split(' - ');
        if(plevel <= 2){
            uids.add(ApproverCandidates.getLineManager(uid));
            return uids;
        }
        if(plevel >2)
        {
            if(devname.size()>0)
            {
                if(devname.size() == 1){ro.BU = devname[0];}
                if(devname.size() == 2){
                    ro.BU = devname[0];
                    ro.Department = devname[1];
                }
                if(devname.size() == 3){
                    ro.BU = devname[0];
                    ro.Department = devname[1];
                    ro.Region = devname[2];
                }
                if(devname.size() >= 4){
                    ro.BU = devname[0];
                    ro.Department = devname[1];
                    ro.Region = devname[2];
                    ro.District = devname[3];
                }
            }
            String querystr = '';
            if(plevel == 3){querystr += devname[0]+' - '+devname[1];}
            if(plevel >= 4){querystr += devname[0];}
            if(String.isNotBlank(querystr)){
                List<User> ulist = [select Id,Name from User where UserRole.Name =: querystr];
                if(ulist.size()>0){for(User uu:ulist){uids.add(uu.Id);}}
            }
        }
        return uids;
    }
}