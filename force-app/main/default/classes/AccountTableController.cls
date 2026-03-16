public with sharing class AccountTableController {
    // 每页固定展示 20 条数据
    public Integer pageSize { get; private set; }
    // 当前页码（从 1 开始）
    public Integer currentPage { get; private set; }
    // 总页数
    public Integer totalPages { get; private set; }
    // 当前排序字段
    public String sortField { get; private set; }
    // 当前是否升序
    public Boolean sortAscending { get; private set; }

    // 保存完整的 100 条模拟数据
    private List<AccountRow> allRows;

    // 提供给页面渲染的分页数据
    public List<AccountRow> pageRows { get; private set; }

    public AccountTableController() {
        pageSize = 20;
        currentPage = 1;
        sortField = 'sequenceNo';
        sortAscending = true;

        generateMockData();
        applySort();
        refreshPagination();
    }

    /**
     * 生成 100 条虚拟 Account 数据（不依赖数据库）。
     */
    private void generateMockData() {
        allRows = new List<AccountRow>();

        for (Integer i = 1; i <= 100; i++) {
            AccountRow row = new AccountRow();
            row.sequenceNo = i;
            row.accountNumber = 'ACC-' + String.valueOf(i).leftPad(4, '0');
            row.name = '示例客户 ' + i;
            row.industry = getIndustryByIndex(i);
            row.phone = '1380000' + String.valueOf(i).leftPad(4, '0');
            allRows.add(row);
        }

        totalPages = Integer.valueOf(Math.ceil((Decimal)allRows.size() / pageSize));
    }

    /**
     * 点击表头时触发排序逻辑：
     * - 若点击同一字段则切换升降序
     * - 若点击新字段则默认升序
     */
    public PageReference sortBy() {
        String requestedField = ApexPages.currentPage().getParameters().get('field');
        if (String.isBlank(requestedField)) {
            return null;
        }

        if (sortField == requestedField) {
            sortAscending = !sortAscending;
        } else {
            sortField = requestedField;
            sortAscending = true;
        }

        applySort();
        currentPage = 1;
        refreshPagination();
        return null;
    }

    /**
     * 上一页。
     */
    public PageReference previousPage() {
        if (currentPage > 1) {
            currentPage--;
            refreshPagination();
        }
        return null;
    }

    /**
     * 下一页。
     */
    public PageReference nextPage() {
        if (currentPage < totalPages) {
            currentPage++;
            refreshPagination();
        }
        return null;
    }

    /**
     * 按当前页码刷新页面数据。
     */
    private void refreshPagination() {
        Integer startIndex = (currentPage - 1) * pageSize;
        Integer endExclusive = Math.min(startIndex + pageSize, allRows.size());

        pageRows = new List<AccountRow>();
        for (Integer i = startIndex; i < endExclusive; i++) {
            pageRows.add(allRows[i]);
        }
    }

    /**
     * 应用排序设置。
     */
    private void applySort() {
        for (AccountRow row : allRows) {
            row.sortFieldRuntime = sortField;
            row.sortAscendingRuntime = sortAscending;
        }
        allRows.sort();
    }

    /**
     * 根据索引返回不同的行业，增强数据可读性。
     */
    private String getIndustryByIndex(Integer i) {
        List<String> industries = new List<String>{'科技', '金融', '教育', '医疗', '制造'};
        Integer index = Math.mod(i, industries.size());
        return industries[index];
    }

    /**
     * 页面行对象，承载展示字段并实现可排序能力。
     */
    public class AccountRow implements Comparable {
        // 运行时排序上下文（实例级，避免 inner class 使用 static 报错）
        public String sortFieldRuntime { get; set; }
        public Boolean sortAscendingRuntime { get; set; }

        public Integer sequenceNo { get; set; }
        public String accountNumber { get; set; }
        public String name { get; set; }
        public String industry { get; set; }
        public String phone { get; set; }

        public Integer compareTo(Object compareToObj) {
            AccountRow other = (AccountRow)compareToObj;
            Integer result = compareValues(getSortValue(), other.getSortValue());
            return sortAscendingRuntime ? result : -result;
        }

        // 根据当前排序字段动态返回对应值
        private Object getSortValue() {
            if (sortFieldRuntime == 'accountNumber') {
                return accountNumber;
            }
            if (sortFieldRuntime == 'name') {
                return name;
            }
            if (sortFieldRuntime == 'industry') {
                return industry;
            }
            if (sortFieldRuntime == 'phone') {
                return phone;
            }
            return sequenceNo;
        }

        // 统一比较方法，兼容数字与字符串
        private Integer compareValues(Object left, Object right) {
            if (left == null && right == null) {
                return 0;
            }
            if (left == null) {
                return -1;
            }
            if (right == null) {
                return 1;
            }

            if (left instanceof Integer && right instanceof Integer) {
                Integer l = (Integer)left;
                Integer r = (Integer)right;
                return l == r ? 0 : (l < r ? -1 : 1);
            }

            String lText = String.valueOf(left).toLowerCase();
            String rText = String.valueOf(right).toLowerCase();
            if (lText == rText) {
                return 0;
            }
            return lText < rText ? -1 : 1;
        }
    }
}