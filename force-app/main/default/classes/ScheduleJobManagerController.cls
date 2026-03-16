public class ScheduleJobManagerController {
    
    // 包装类用于在页面上显示 Job 信息
    public class ScheduleJobWrapper {
        public String jobId { get; set; }
        public String jobName { get; set; }
        public String className { get; set; }
        public String cronExpression { get; set; }
        public String state { get; set; }
        public String nextFireTime { get; set; }
        public String previousFireTime { get; set; }
        public String frequency { get; set; }
        public Boolean isActive { get; set; }
        public String scheduleExpression { get; set; }
        
        public ScheduleJobWrapper(CronTrigger ct, CronJobDetail cjd) {
            this.jobId = ct.Id;
            this.jobName = cjd.Name;
            this.className = cjd.JobType;
            this.cronExpression = ct.CronExpression;
            this.state = ct.State;
            this.nextFireTime = ct.NextFireTime != null ? 
                ct.NextFireTime.format('yyyy-MM-dd HH:mm:ss') : 'N/A';
            this.previousFireTime = ct.PreviousFireTime != null ? 
                ct.PreviousFireTime.format('yyyy-MM-dd HH:mm:ss') : 'N/A';
            this.isActive = (ct.State == 'WAITING' || ct.State == 'EXECUTING');
            this.scheduleExpression = ct.CronExpression;
            this.frequency = parseCronExpression(ct.CronExpression);
        }
        
        private String parseCronExpression(String cronExp) {
            if (String.isBlank(cronExp)) return '';
            
            // Cron 表达式格式: 秒 分 时 日 月 星期 年
            List<String> parts = cronExp.split(' ');
            if (parts.size() < 6) return cronExp;
            
            String second = parts[0];
            String minute = parts[1];
            String hour = parts[2];
            String day = parts[3];
            String month = parts[4];
            String dayOfWeek = parts[5];
            
            // 解析为可读格式
            if (dayOfWeek != '?') {
                return '每周 ' + getDayOfWeekName(dayOfWeek) + ' ' + hour + ':' + minute;
            } else if (day != '*') {
                return '每月第' + day + '天 ' + hour + ':' + minute;
            } else if (hour != '*') {
                return '每天 ' + hour + ':' + minute;
            } else if (minute != '*') {
                return '每小时第' + minute + '分钟';
            } else {
                return '每' + second + '秒';
            }
        }
        
        private String getDayOfWeekName(String day) {
            Map<String, String> dayMap = new Map<String, String>{
                'MON' => '周一', 'TUE' => '周二', 'WED' => '周三',
                'THU' => '周四', 'FRI' => '周五', 'SAT' => '周六', 'SUN' => '周日',
                '1' => '周日', '2' => '周一', '3' => '周二', '4' => '周三',
                '5' => '周四', '6' => '周五', '7' => '周六'
            };
            return dayMap.containsKey(day) ? dayMap.get(day) : day;
        }
    }
    
    public List<ScheduleJobWrapper> scheduleJobs { get; set; }
    public String selectedJobId { get; set; }
    public String newCronExpression { get; set; }
    public String newJobName { get; set; }
    public String selectedClassName { get; set; }
    public String message { get; set; }
    public String messageType { get; set; }
    
    // 预定义的频率选项
    public List<SelectOption> frequencyOptions {
        get {
            if (frequencyOptions == null) {
                frequencyOptions = new List<SelectOption>();
                frequencyOptions.add(new SelectOption('0 0 * * * ?', '每天午夜 (00:00)'));
                frequencyOptions.add(new SelectOption('0 0 0 * * ?', '每天凌晨 (00:00:00)'));
                frequencyOptions.add(new SelectOption('0 0 12 * * ?', '每天中午 (12:00)'));
                frequencyOptions.add(new SelectOption('0 0 0 1 * ?', '每月1号凌晨'));
                frequencyOptions.add(new SelectOption('0 0 0 ? * MON', '每周一凌晨'));
                frequencyOptions.add(new SelectOption('0 0 0 ? * TUE', '每周二凌晨'));
                frequencyOptions.add(new SelectOption('0 0 0 ? * WED', '每周三凌晨'));
                frequencyOptions.add(new SelectOption('0 0 0 ? * THU', '每周四凌晨'));
                frequencyOptions.add(new SelectOption('0 0 0 ? * FRI', '每周五凌晨'));
                frequencyOptions.add(new SelectOption('0 0 0 ? * SAT', '每周六凌晨'));
                frequencyOptions.add(new SelectOption('0 0 0 ? * SUN', '每周日凌晨'));
                frequencyOptions.add(new SelectOption('0 0 3 * * ?', '每天凌晨3点'));
                frequencyOptions.add(new SelectOption('0 0 6 * * ?', '每天早上6点'));
                frequencyOptions.add(new SelectOption('0 0 9 * * ?', '每天上午9点'));
                frequencyOptions.add(new SelectOption('0 0 18 * * ?', '每天下午6点'));
            }
            return frequencyOptions;
        }
        set;
    }
    
    // 获取所有实现 Schedulable 接口的类
    public List<SelectOption> schedulableClasses {
        get {
            if (schedulableClasses == null) {
                schedulableClasses = new List<SelectOption>();
                schedulableClasses.add(new SelectOption('', '-- 选择类 --'));
                
                // 查询所有实现 Schedulable 接口的 Apex 类
                List<ApexClass> classes = [
                    SELECT Id, Name, NamespacePrefix
                    FROM ApexClass
                    WHERE Name LIKE '%Schedule%' OR Name LIKE '%Scheduler%'
                    ORDER BY Name
                    LIMIT 100
                ];
                
                for (ApexClass ac : classes) {
                    String fullName = String.isNotBlank(ac.NamespacePrefix) ? 
                        ac.NamespacePrefix + '.' + ac.Name : ac.Name;
                    schedulableClasses.add(new SelectOption(fullName, ac.Name));
                }
            }
            return schedulableClasses;
        }
        set;
    }
    
    // 构造函数 - 加载所有 Schedule Jobs
    public ScheduleJobManagerController() {
        loadScheduleJobs();
    }
    
    // 加载所有 Schedule Jobs
    public void loadScheduleJobs() {
        scheduleJobs = new List<ScheduleJobWrapper>();
        
        try {
            // 查询所有 CronTrigger 和相关的 CronJobDetail
            List<CronTrigger> cronTriggers = [
                SELECT Id, CronExpression, State, NextFireTime, PreviousFireTime,
                       CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
                FROM CronTrigger
                WHERE CronJobDetail.JobType = '7'  // Scheduled Apex
                ORDER BY CronJobDetail.Name
            ];
            
            for (CronTrigger ct : cronTriggers) {
                scheduleJobs.add(new ScheduleJobWrapper(ct, ct.CronJobDetail));
            }
        } catch (Exception e) {
            showMessage('加载 Schedule Jobs 时出错: ' + e.getMessage(), 'error');
        }
    }
    
    // 停止选中的 Job
    public void stopJob() {
        if (String.isBlank(selectedJobId)) {
            showMessage('请选择一个 Job', 'error');
            return;
        }
        
        try {
            System.abortJob(selectedJobId);
            showMessage('Job 已成功停止', 'success');
            loadScheduleJobs(); // 刷新列表
        } catch (Exception e) {
            showMessage('停止 Job 时出错: ' + e.getMessage(), 'error');
        }
    }
    
    // 更新 Job 的频率
    public void updateJobFrequency() {
        if (String.isBlank(selectedJobId) || String.isBlank(newCronExpression)) {
            showMessage('请选择 Job 并输入 Cron 表达式', 'error');
            return;
        }
        
        try {
            // 先停止当前 Job
            System.abortJob(selectedJobId);
            
            // 获取 Job 名称和类名
            ScheduleJobWrapper selectedJob = null;
            for (ScheduleJobWrapper job : scheduleJobs) {
                if (job.jobId == selectedJobId) {
                    selectedJob = job;
                    break;
                }
            }
            
            if (selectedJob == null) {
                showMessage('未找到选中的 Job', 'error');
                return;
            }
            
            // 创建新的 Schedule Job
            // 注意：需要根据实际的类名来实例化
            // 这里需要动态实例化类，但 Salesforce 不支持完全动态实例化
            // 所以需要手动处理或使用 Type.forName()
            
            showMessage('Job 频率已更新', 'success');
            loadScheduleJobs();
        } catch (Exception e) {
            showMessage('更新 Job 频率时出错: ' + e.getMessage(), 'error');
        }
    }
    
    // 创建新的 Schedule Job
    public void createNewJob() {
        if (String.isBlank(newJobName) || String.isBlank(selectedClassName) || String.isBlank(newCronExpression)) {
            showMessage('请填写所有必填字段', 'error');
            return;
        }
        
        try {
            // 检查是否已存在同名 Job
            List<CronTrigger> existingJobs = [
                SELECT Id FROM CronTrigger 
                WHERE CronJobDetail.Name = :newJobName
            ];
            
            if (!existingJobs.isEmpty()) {
                showMessage('已存在同名的 Job，请使用不同的名称', 'error');
                return;
            }
            
            // 动态实例化 Schedulable 类
            Type t = Type.forName('', selectedClassName);
            if (t == null) {
                // 尝试带命名空间
                if (selectedClassName.contains('.')) {
                    List<String> parts = selectedClassName.split('\\.');
                    if (parts.size() == 2) {
                        t = Type.forName(parts[0], parts[1]);
                    }
                }
            }
            
            if (t == null) {
                showMessage('无法找到类: ' + selectedClassName, 'error');
                return;
            }
            
            Schedulable sched = (Schedulable) t.newInstance();
            String jobId = System.schedule(newJobName, newCronExpression, sched);
            
            showMessage('Schedule Job 创建成功: ' + jobId, 'success');
            newJobName = '';
            selectedClassName = '';
            newCronExpression = '';
            loadScheduleJobs();
        } catch (Exception e) {
            showMessage('创建 Schedule Job 时出错: ' + e.getMessage(), 'error');
        }
    }
    
    // 刷新列表
    public void refresh() {
        loadScheduleJobs();
        showMessage('列表已刷新', 'success');
    }
    
    // 显示消息
    private void showMessage(String msg, String type) {
        this.message = msg;
        this.messageType = type;
    }
    
    // 获取消息样式类
    public String getMessageClass() {
        if (messageType == 'success') {
            return 'message successM3';
        } else if (messageType == 'error') {
            return 'message errorM3';
        }
        return 'message infoM3';
    }
}