import { LightningElement, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import CONTRACT_OBJECT from '@salesforce/schema/Contract';

const PREFERRED_FIELDS = [
    'AccountId',
    'StartDate',
    'ContractTerm',
    'Status',
    'Description',
    'SpecialTerms',
    'CustomerSignedTitle',
    'CompanySignedTitle',
    'CustomerSignedDate',
    'CompanySignedDate'
];

const STEP_CONFIG = [
    { value: 'contractInfo', label: '合同信息' },
    { value: 'draft', label: 'Draft' },
    { value: 'review', label: '审核中' },
    { value: 'activated', label: '激活' }
];

const STEP_STATUS_MAP = {
    Draft: 'draft',
    'In Approval Process': 'review',
    Activated: 'activated'
};

export default class ContractCreationWizard extends NavigationMixin(LightningElement) {
    @track displayFields = [];
    @track fieldValues = {};

    objectError;
    isLoading = true;
    currentStepValue = 'contractInfo';
    createdContractId;

    @wire(getObjectInfo, { objectApiName: CONTRACT_OBJECT })
    wiredObjectInfo({ data, error }) {
        if (data) {
            this.objectError = undefined;
            this.initializeFields(data.fields);
            this.isLoading = false;
        } else if (error) {
            this.objectError = error;
            this.isLoading = false;
        }
    }

    get hasObjectError() {
        return Boolean(this.objectError);
    }

    get objectErrorMessage() {
        return '无法加载 Contract 对象信息，请确认对象和字段权限。';
    }

    get filledFieldCount() {
        return this.displayFields.filter((field) => this.hasValue(field.value)).length;
    }

    get steps() {
        const currentIndex = STEP_CONFIG.findIndex((item) => item.value === this.currentStepValue);
        return STEP_CONFIG.map((step, index) => ({
            ...step,
            className: index <= currentIndex ? 'step-chip done' : 'step-chip pending'
        }));
    }

    initializeFields(allFields) {
        const preferredFields = PREFERRED_FIELDS
            .map((apiName) => ({ apiName, definition: allFields[apiName] }))
            .filter((item) => item.definition && this.isSupportedField(item.definition));

        const fallbackFields = Object.keys(allFields)
            .filter((apiName) => this.isSupportedField(allFields[apiName]))
            .map((apiName) => ({ apiName, definition: allFields[apiName] }));

        const chosenFields = (preferredFields.length >= 10 ? preferredFields : fallbackFields).slice(0, 10);

        this.displayFields = chosenFields.map((item) => ({
            apiName: item.apiName,
            label: item.definition.label,
            type: this.mapInputType(item.definition.dataType),
            value: '',
            valueOrPlaceholder: '（待填写）'
        }));

        this.fieldValues = {};
    }

    isSupportedField(fieldDefinition) {
        const unsupported = ['Address', 'Location', 'Base64', 'EncryptedString'];
        return (
            fieldDefinition.createable &&
            !fieldDefinition.calculated &&
            !fieldDefinition.autoNumber &&
            !unsupported.includes(fieldDefinition.dataType)
        );
    }

    mapInputType(dataType) {
        switch (dataType) {
            case 'Boolean':
                return 'checkbox';
            case 'Date':
                return 'date';
            case 'DateTime':
                return 'datetime';
            case 'Double':
            case 'Currency':
            case 'Percent':
            case 'Integer':
                return 'number';
            case 'Email':
                return 'email';
            case 'Phone':
                return 'tel';
            case 'Url':
                return 'url';
            default:
                return 'text';
        }
    }

    handleInputChange(event) {
        const fieldApiName = event.target.dataset.field;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

        this.fieldValues = {
            ...this.fieldValues,
            [fieldApiName]: value
        };

        this.displayFields = this.displayFields.map((field) =>
            field.apiName === fieldApiName
                ? {
                      ...field,
                      value,
                      valueOrPlaceholder: this.hasValue(value) ? value : '（待填写）'
                  }
                : field
        );
    }

    validateRequiredInputs() {
        const inputs = this.template.querySelectorAll('lightning-input');
        let isValid = true;

        inputs.forEach((input) => {
            if (!input.reportValidity()) {
                isValid = false;
            }
        });

        return isValid && this.filledFieldCount === 10;
    }

    async handleSave() {
        if (!this.validateRequiredInputs()) {
            this.showToast('请完整填写10个字段', '每个字段都需要输入后再保存。', 'error');
            return;
        }

        this.isLoading = true;

        const fields = { ...this.fieldValues };
        fields.Status = fields.Status || 'Draft';

        try {
            const result = await createRecord({ apiName: 'Contract', fields });
            this.createdContractId = result.id;
            this.syncStepByStatus(fields.Status);
            this.showToast('保存成功', '合同已创建并进入 Draft 状态。', 'success');
            this.navigateToRecord(result.id);
        } catch (error) {
            this.showToast('保存失败', this.getErrorMessage(error), 'error');
        } finally {
            this.isLoading = false;
        }
    }

    handleCancel() {
        this.fieldValues = {};
        this.displayFields = this.displayFields.map((field) => ({
            ...field,
            value: '',
            valueOrPlaceholder: '（待填写）'
        }));
        this.currentStepValue = 'contractInfo';
        this.showToast('已取消', '输入内容已清空。', 'info');
    }

    handleNextStep() {
        const currentIndex = STEP_CONFIG.findIndex((item) => item.value === this.currentStepValue);
        if (currentIndex < STEP_CONFIG.length - 1) {
            this.currentStepValue = STEP_CONFIG[currentIndex + 1].value;
            this.showToast('进入下一步', `当前步骤：${STEP_CONFIG[currentIndex + 1].label}`, 'success');
        }
    }

    syncStepByStatus(status) {
        this.currentStepValue = STEP_STATUS_MAP[status] || 'draft';
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                objectApiName: 'Contract',
                actionName: 'view'
            }
        });
    }

    hasValue(value) {
        return value !== '' && value !== null && value !== undefined;
    }

    getErrorMessage(error) {
        return error?.body?.message || '系统异常，请稍后重试。';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}