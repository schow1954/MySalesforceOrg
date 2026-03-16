public with sharing class ProjectBoardController {
    public String searchTerm { get; set; }
    public String selectedOwnerId { get; set; }

    private static final Integer MAX_RECORDS = 200;
    private static final List<String> STATUS_ORDER = new List<String>{
        'Not Started',
        'In Progress',
        'Completed',
        'Delayed',
        'Cancelled'
    };

    private BoardConfig config;

    public ProjectBoardController() {
        config = resolveConfig();
    }

    public List<SelectOption> getOwnerOptions() {
        List<SelectOption> result = new List<SelectOption>{
            new SelectOption('', 'All Owners')
        };

        if (!config.hasOwnerField) {
            return result;
        }

        String soql = 'SELECT Id, Name FROM User WHERE Id IN (SELECT ' + config.ownerField + ' FROM ' + config.objectApiName + ') ORDER BY Name LIMIT 200';
        for (User u : Database.query(soql)) {
            result.add(new SelectOption(u.Id, u.Name));
        }
        return result;
    }

    public List<ColumnVM> getColumns() {
        Map<String, List<CardVM>> cardsByStatus = new Map<String, List<CardVM>>();
        for (String statusName : STATUS_ORDER) {
            cardsByStatus.put(statusName, new List<CardVM>());
        }

        for (CardVM card : queryCards()) {
            String normalizedStatus = STATUS_ORDER.contains(card.statusLabel) ? card.statusLabel : 'Not Started';
            cardsByStatus.get(normalizedStatus).add(card);
        }

        List<ColumnVM> columns = new List<ColumnVM>();
        for (String statusName : STATUS_ORDER) {
            columns.add(new ColumnVM(statusName, cardsByStatus.get(statusName)));
        }
        return columns;
    }

    private List<CardVM> queryCards() {
        List<String> selectParts = new List<String>{
            'Id',
            config.nameField,
            config.statusField,
            config.progressField
        };

        if (config.hasOwnerField) {
            selectParts.add(config.ownerField);
            selectParts.add(config.ownerField.replace('Id', '.Name'));
        }

        String soql = 'SELECT ' + String.join(selectParts, ',') +
            ' FROM ' + config.objectApiName +
            ' WHERE ' + config.statusField + ' != null';

        if (String.isNotBlank(searchTerm)) {
            String escapedSearch = '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';
            soql += ' AND ' + config.nameField + ' LIKE \'' + escapedSearch + '\'';
        }

        if (String.isNotBlank(selectedOwnerId) && config.hasOwnerField) {
            soql += ' AND ' + config.ownerField + ' = \'' + String.escapeSingleQuotes(selectedOwnerId) + '\'';
        }

        soql += ' ORDER BY ' + config.nameField + ' ASC LIMIT ' + MAX_RECORDS;

        List<CardVM> cards = new List<CardVM>();
        for (SObject recordRow : Database.query(soql)) {
            String statusLabel = (String) recordRow.get(config.statusField);
            String ownerName = 'Unassigned';
            if (config.hasOwnerField) {
                SObject ownerRow = recordRow.getSObject(config.ownerField.replace('Id', ''));
                if (ownerRow != null && ownerRow.get('Name') != null) {
                    ownerName = String.valueOf(ownerRow.get('Name'));
                }
            }

            Object rawProgress = recordRow.get(config.progressField);
            Decimal progress = rawProgress == null ? 0 : Decimal.valueOf(String.valueOf(rawProgress));
            cards.add(new CardVM(
                (Id) recordRow.get('Id'),
                String.valueOf(recordRow.get(config.nameField)),
                statusLabel,
                ownerName,
                progress == null ? 0 : progress
            ));
        }
        return cards;
    }

    public class CardVM {
        public Id recordId { get; private set; }
        public String name { get; private set; }
        public String statusLabel { get; private set; }
        public String ownerName { get; private set; }
        public Decimal progressPct { get; private set; }

        public CardVM(Id recordId, String name, String statusLabel, String ownerName, Decimal progressPct) {
            this.recordId = recordId;
            this.name = name;
            this.statusLabel = statusLabel;
            this.ownerName = ownerName;
            this.progressPct = progressPct;
        }

        public String getRecordUrl() {
            return '/' + recordId;
        }

        public String getProgressLabel() {
            return progressPct.setScale(2) + '%';
        }
    }

    public class ColumnVM {
        public String statusLabel { get; private set; }
        public List<CardVM> cards { get; private set; }

        public ColumnVM(String statusLabel, List<CardVM> cards) {
            this.statusLabel = statusLabel;
            this.cards = cards;
        }

        public Integer getCount() {
            return cards.size();
        }
    }

    private BoardConfig resolveConfig() {
        return new BoardConfig().resolve();
    }

    private class BoardConfig {
        public String objectApiName;
        public String nameField;
        public String statusField;
        public String progressField;
        public String ownerField;
        public Boolean hasOwnerField;

        public BoardConfig resolve() {
            List<String> preferredObjects = new List<String>{ 'Project__c', 'PM_Project__c', 'Account' };
            Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();

            for (String objectName : preferredObjects) {
                if (!globalMap.containsKey(objectName)) {
                    continue;
                }

                Schema.DescribeSObjectResult d = globalMap.get(objectName).getDescribe();
                Map<String, Schema.SObjectField> fields = d.fields.getMap();
                BoardConfig config = new BoardConfig();
                config.objectApiName = objectName;
                config.nameField = fields.containsKey('Name') ? 'Name' : null;
                config.statusField = fields.containsKey('Status__c') ? 'Status__c' : 'Type';
                config.progressField = fields.containsKey('Progress__c') ? 'Progress__c' : (fields.containsKey('NumberOfEmployees') ? 'NumberOfEmployees' : null);
                config.ownerField = fields.containsKey('OwnerId') ? 'OwnerId' : null;
                config.hasOwnerField = config.ownerField != null;

                if (config.nameField != null && config.statusField != null && config.progressField != null) {
                    return config;
                }
            }

            throw new AuraHandledException('No supported project object was found. Please add Project__c with Name, Status__c, and Progress__c fields.');
        }
    }
}