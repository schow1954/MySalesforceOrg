// 示例：UserPermissionSetGroupController.cls

public with sharing class UserPermissionSetGroupController {

    // 搜索活跃用户（按 Name 或 Username 模糊匹配）
    @AuraEnabled(cacheable=true)
    public static List<User> searchActiveUsers(String searchTerm) {
        searchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
        return [
            SELECT Id, Name, Username, Profile.Name
            FROM User
            WHERE IsActive = true
            AND (Name LIKE :searchTerm OR Username LIKE :searchTerm)
            LIMIT 50
        ];
    }

    // 获取某用户已分配的 Permission Set（仅 Permission Set，不含 Permission Set Group 等）
    @AuraEnabled(cacheable=true)
    public static List<PermissionSetWrapper> getPermissionSetsForUser(Id userId) {
        List<PermissionSetAssignment> psas = [
            SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.Label
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId
            AND PermissionSet.IsOwnedByProfile = false
        ];
        List<PermissionSetWrapper> result = new List<PermissionSetWrapper>();
        for (PermissionSetAssignment psa : psas) {
            result.add(new PermissionSetWrapper(
                psa.PermissionSetId,
                psa.PermissionSet.Name,
                psa.PermissionSet.Label
            ));
        }
        return result;
    }

    // 获取某用户所属的 Public Group（Group.Type = 'Regular'）
    @AuraEnabled(cacheable=true)
    public static List<GroupWrapper> getPublicGroupsForUser(Id userId) {
        List<GroupMember> gms = [
            SELECT Id, GroupId, Group.Name, Group.DeveloperName
            FROM GroupMember
            WHERE UserOrGroupId = :userId
            AND Group.Type = 'Regular'
        ];
        List<GroupWrapper> result = new List<GroupWrapper>();
        for (GroupMember gm : gms) {
            result.add(new GroupWrapper(
                gm.GroupId,
                gm.Group.Name,
                gm.Group.DeveloperName
            ));
        }
        return result;
    }

    // 批量分配：将选中的 Permission Set 和 Public Group 分配给目标用户
    @AuraEnabled
    public static AssignmentResult assignToUser(Id targetUserId, List<Id> permissionSetIds, List<Id> groupIds) {
        AssignmentResult res = new AssignmentResult();
        res.permissionSetSuccess = new List<String>();
        res.permissionSetErrors = new List<String>();
        res.groupSuccess = new List<String>();
        res.groupErrors = new List<String>();

        if (permissionSetIds != null && !permissionSetIds.isEmpty()) {
            List<PermissionSetAssignment> toInsert = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                toInsert.add(new PermissionSetAssignment(
                    PermissionSetId = psId,
                    AssigneeId = targetUserId
                ));
            }
            Database.SaveResult[] srList = Database.insert(toInsert, false);
            for (Integer i = 0; i < srList.size(); i++) {
                if (srList[i].isSuccess()) {
                    res.permissionSetSuccess.add(permissionSetIds[i]);
                } else {
                    String err = srList[i].getErrors()[0].getMessage();
                    res.permissionSetErrors.add(permissionSetIds[i] + ': ' + err);
                }
            }
        }

        if (groupIds != null && !groupIds.isEmpty()) {
            List<GroupMember> toInsert = new List<GroupMember>();
            for (Id gId : groupIds) {
                toInsert.add(new GroupMember(
                    GroupId = gId,
                    UserOrGroupId = targetUserId
                ));
            }
            Database.SaveResult[] srList = Database.insert(toInsert, false);
            for (Integer i = 0; i < srList.size(); i++) {
                if (srList[i].isSuccess()) {
                    res.groupSuccess.add(groupIds[i]);
                } else {
                    String err = srList[i].getErrors()[0].getMessage();
                    res.groupErrors.add(groupIds[i] + ': ' + err);
                }
            }
        }

        return res;
    }

    public class PermissionSetWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        public PermissionSetWrapper(Id id, String name, String label) {
            this.id = id; this.name = name; this.label = label;
        }
    }
    public class GroupWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String developerName;
        public GroupWrapper(Id id, String name, String developerName) {
            this.id = id; this.name = name; this.developerName = developerName;
        }
    }
    public class AssignmentResult {
        @AuraEnabled public List<String> permissionSetSuccess;
        @AuraEnabled public List<String> permissionSetErrors;
        @AuraEnabled public List<String> groupSuccess;
        @AuraEnabled public List<String> groupErrors;
    }
}