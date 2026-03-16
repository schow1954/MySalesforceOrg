/*********************************************************************************
 * Name: AccountUpdateBatch 
 * Description: Batch 类用于批量更新 Account 记录
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * Created
*********************************************************************************/

global class AccountUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    // 用于记录处理统计
    private Integer totalProcessed = 0;
    private Integer totalUpdated = 0;
    private Integer totalErrors = 0;
    
    // 查询需要更新的 Account
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // 示例：更新所有需要更新的 Account
        // 您可以根据实际需求修改查询条件
        String query = 'SELECT Id, Name, LastModifiedDate, Description ' +
                      'FROM Account ' +
                      'WHERE LastModifiedDate < LAST_N_DAYS:30 ' + // 示例条件：30天内未修改的
                      'LIMIT 10000';
        
        System.debug('AccountUpdateBatch 查询: ' + query);
        return Database.getQueryLocator(query);
    }
    
    // 执行更新逻辑
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        List<Account> accountsToUpdate = new List<Account>();
        
        for (Account acc : scope) {
            // 示例更新逻辑：更新 Description 字段
            // 您可以根据实际需求修改更新逻辑
            Account accountToUpdate = new Account(
                Id = acc.Id,
                Description = '最后更新于: ' + Datetime.now().format('yyyy-MM-dd HH:mm:ss')
                // 可以添加更多需要更新的字段
                // 例如：Account.LastActivityDate = Date.today();
            );
            accountsToUpdate.add(accountToUpdate);
        }
        
        if (!accountsToUpdate.isEmpty()) {
            // 使用部分更新模式，即使某些记录失败也继续处理其他记录
            Database.SaveResult[] results = Database.update(accountsToUpdate, false);
            
            // 统计更新结果
            for (Integer i = 0; i < results.size(); i++) {
                totalProcessed++;
                if (results[i].isSuccess()) {
                    totalUpdated++;
                } else {
                    totalErrors++;
                    // 记录错误
                    for (Database.Error error : results[i].getErrors()) {
                        System.debug('Account ID: ' + accountsToUpdate[i].Id + 
                                   ', 错误: ' + error.getMessage());
                    }
                }
            }
        }
    }
    
    // 完成后的处理
    global void finish(Database.BatchableContext bc) {
        // 发送通知或记录日志
        System.debug('AccountUpdateBatch 完成');
        System.debug('总处理数: ' + totalProcessed);
        System.debug('成功更新: ' + totalUpdated);
        System.debug('失败数: ' + totalErrors);
        
        // 可以在这里发送邮件通知
        // sendEmailNotification();
    }
    
    // 可选：发送邮件通知
    private void sendEmailNotification() {
        // 实现邮件通知逻辑
    }
}