public with sharing class LeadReportDashboardController {
    public class StatusMetric {
        public String label { get; set; }
        public String statusValue { get; set; }
        public Integer countValue { get; set; }
        public Decimal percentage { get; set; }

        public StatusMetric(String label, String statusValue, Integer countValue, Integer total) {
            this.label = label;
            this.statusValue = statusValue;
            this.countValue = countValue;
            this.percentage = total == 0
                ? 0
                : ((Decimal) countValue * 100) / total;
        }

        public String getPercentageText() {
            return String.valueOf(percentage.setScale(1)) + '%';
        }
    }

    public class OwnerMetric {
        public Id ownerId { get; set; }
        public String ownerName { get; set; }
        public Integer countValue { get; set; }
        public Decimal percentage { get; set; }

        public OwnerMetric(Id ownerId, String ownerName, Integer countValue, Integer maxValue) {
            this.ownerId = ownerId;
            this.ownerName = ownerName;
            this.countValue = countValue;
            this.percentage = maxValue == 0
                ? 0
                : ((Decimal) countValue * 100) / maxValue;
        }

        public String getBarStyle() {
            return 'width:' + String.valueOf(percentage.setScale(1)) + '%;';
        }
    }

    public List<StatusMetric> statusMetrics { get; private set; }
    public List<OwnerMetric> ownerMetrics { get; private set; }
    public List<Lead> detailLeads { get; private set; }

    public Integer totalLeads { get; private set; }
    public Integer draftCount { get; private set; }
    public Integer submittedCount { get; private set; }
    public Integer finalCount { get; private set; }
    public Integer detailLimit { get; set; }

    public String selectedStatus { get; private set; }
    public Id selectedOwnerId { get; private set; }
    public String selectedOwnerName { get; private set; }

    public LeadReportDashboardController() {
        detailLimit = 20;
        detailLeads = new List<Lead>();
        loadStatusMetrics();
        loadOwnerMetrics();
    }

    public Boolean getHasOwnerData() {
        return ownerMetrics != null && !ownerMetrics.isEmpty();
    }

    public Boolean getHasDetails() {
        return detailLeads != null && !detailLeads.isEmpty();
    }

    public String getCurrentDetailTitle() {
        if (String.isNotBlank(selectedStatus)) {
            return '状态明细：' + selectedStatus;
        }
        if (selectedOwnerId != null) {
            return 'Owner 明细：' + selectedOwnerName;
        }
        return '点击状态或 Owner 查看明细';
    }

    public List<SelectOption> getDetailLimitOptions() {
        return new List<SelectOption>{
            new SelectOption('20', '20 条'),
            new SelectOption('50', '50 条'),
            new SelectOption('100', '100 条')
        };
    }

    public PageReference showStatusDetails() {
        selectedOwnerId = null;
        selectedOwnerName = null;
        selectedStatus = ApexPages.currentPage().getParameters().get('status');
        loadDetailLeads();
        return null;
    }

    public PageReference showOwnerDetails() {
        selectedStatus = null;
        String ownerIdParam = ApexPages.currentPage().getParameters().get('ownerId');
        selectedOwnerName = ApexPages.currentPage().getParameters().get('ownerName');
        if (String.isNotBlank(ownerIdParam)) {
            selectedOwnerId = (Id) ownerIdParam;
        }
        loadDetailLeads();
        return null;
    }

    public PageReference refreshDetailByLimit() {
        if (String.isNotBlank(selectedStatus) || selectedOwnerId != null) {
            loadDetailLeads();
        }
        return null;
    }

    private void loadStatusMetrics() {
        Map<String, Integer> countsByStatus = new Map<String, Integer>{
            'Draft' => 0,
            'submitted' => 0,
            'final' => 0
        };

        for (AggregateResult ar : [
            SELECT Status statusLabel, COUNT(Id) totalCount
            FROM Lead
            WHERE Status IN ('Draft', 'submitted', 'final')
            GROUP BY Status
        ]) {
            String label = (String) ar.get('statusLabel');
            countsByStatus.put(label, (Integer) ar.get('totalCount'));
        }

        draftCount = countsByStatus.get('Draft');
        submittedCount = countsByStatus.get('submitted');
        finalCount = countsByStatus.get('final');
        totalLeads = draftCount + submittedCount + finalCount;

        statusMetrics = new List<StatusMetric>{
            new StatusMetric('Draft', 'Draft', draftCount, totalLeads),
            new StatusMetric('Submitted', 'submitted', submittedCount, totalLeads),
            new StatusMetric('Final', 'final', finalCount, totalLeads)
        };
    }

    private void loadOwnerMetrics() {
        List<AggregateResult> ownerResults = [
            SELECT OwnerId ownerId, Owner.Name ownerName, COUNT(Id) totalCount
            FROM Lead
            GROUP BY OwnerId, Owner.Name
            ORDER BY COUNT(Id) DESC
            LIMIT 8
        ];

        Integer maxValue = 0;
        for (AggregateResult ar : ownerResults) {
            Integer currentCount = (Integer) ar.get('totalCount');
            if (currentCount > maxValue) {
                maxValue = currentCount;
            }
        }

        ownerMetrics = new List<OwnerMetric>();
        for (AggregateResult ar : ownerResults) {
            ownerMetrics.add(new OwnerMetric(
                (Id) ar.get('ownerId'),
                (String) ar.get('ownerName'),
                (Integer) ar.get('totalCount'),
                maxValue
            ));
        }
    }

    private void loadDetailLeads() {
        Integer safeLimit = detailLimit == null ? 20 : detailLimit;
        if (safeLimit > 100) {
            safeLimit = 100;
        }
        if (safeLimit < 1) {
            safeLimit = 20;
        }

        if (String.isNotBlank(selectedStatus)) {
            detailLeads = [
                SELECT Id, Name, Company, Status, Owner.Name, CreatedDate
                FROM Lead
                WHERE Status = :selectedStatus
                ORDER BY CreatedDate DESC
                LIMIT :safeLimit
            ];
            return;
        }

        if (selectedOwnerId != null) {
            detailLeads = [
                SELECT Id, Name, Company, Status, Owner.Name, CreatedDate
                FROM Lead
                WHERE OwnerId = :selectedOwnerId
                ORDER BY CreatedDate DESC
                LIMIT :safeLimit
            ];
            return;
        }

        detailLeads = new List<Lead>();
    }
}