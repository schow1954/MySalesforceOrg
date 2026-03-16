import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getData from '@salesforce/apex/lightingShowImagesController.getData';
import getSessions from '@salesforce/apex/lightingShowImagesController.getSessions';
import loadMore from '@salesforce/apex/lightingShowImagesController.loadMore';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';



const appstatus = [
    {label:'审核通过',value:'审核通过'},
    {label:'审核拒绝',value:'审核拒绝'},
    {label:'待审核',value:'待审核'}
  ];

export default class showImagesComponent extends NavigationMixin(LightningElement){

  @api searchPRNo;
  @api searchPRSessionNo;
  @api searchPRStartDate;
  @track searchPREndDate;

  @api PRTypes;
  @track PRSessions;
  @api searchPRMeetingType;
  @api searchPROrganizer;

  @api searchPRCharger;
  @api searchPRReviewer;
  @api searchPRApprovalStatus;
  @api searchPhototype;

  @api IsOpen = false;
  @api totallimit = 1;
  @track showmoredata = false;
  @track showusesearch = false;

  @track objects = [];
  @track ApprovalStatus =appstatus;
  @track phototypes = [];
  @track showimageid;
  @api currentimageid;

  @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
  accountMetadata;

  @wire(getPicklistValues,
      {
        recordTypeId: '$accountMetadata.data.defaultRecordTypeId', 
        fieldApiName: INDUSTRY_FIELD
      }
  )
  industryPicklist;

  @track myvalue;
  handleChange(event){
    this.myvalue = event.target.value;
  }

  @wire(getData,{phototype: '$searchPhototype'})
    wiredDatas({ error, data }) {
      if (data) {
        this.objects = [];
        this.showmoredata = true;
      	for (let i = 0; i < data.length; i++) {
      		this.objects = [...this.objects, {key: i, data: data[i]}];
      	}
      } else if (error) {
          this.error = error;
          this.data = undefined;
      }
      this.currentimageid = "/servlet/servlet.FileDownload?file=00P2v00002UOdh8";
      this.showusesearch = false;
      /*
      let astatus = [];
      astatus.push({label:'审核通过',value:'审核通过'});
      astatus.push({label:'审核拒绝',value:'审核拒绝'});
      astatus.push({label:'待审核',value:'待审核'});
      */
      //this.ApprovalStatus = appstatus;

      let ptypes = [];
      ptypes.push({label:'会场',value:'会场'});
      ptypes.push({label:'讲者',value:'讲者'});
      ptypes.push({label:'其他',value:'其他'});
      this.phototypes = ptypes;
  }

  @wire(getSessions, {prno: '$searchPRNo'})
  wireSessions({ error, data }) {
      if (data) {
        let prsession = [];
        for(let i=0; i < data.length; i++){
            prsession.push({label:data[i],value:data[i]});
        }
        this.PRSessions = prsession;
      } else if (error) {
          this.error = error;
          this.data = undefined;
      }
  }

  
  @wire(loadMore, {thislimit: '$totallimit'})
  wireloadMore({ error, data }) {
        this.objects = [];
        if (data) {
          if(this.totallimit > 1){
            for (let i = 0; i < data.length; i++) {
              this.objects = [...this.objects, {key: i, data: data[i]}];
            }
          }
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
  }

  doClear(){
    this.searchPRNo = '';
    this.searchPRSessionNo = '请选择';
    this.searchPRStartDate = null;
    this.searchPREndDate = null;
    this.searchPRMeetingType = '请选择';
    this.searchPROrganizer = '';
    this.searchPRCharger = '';
    this.searchPRReviewer = '';
    this.searchPRApprovalStatus = '请选择';
  }

  doSearch(event){

  }

  handlePRNoChange(event){
    this.searchPRNo = event.target.value;
    return refreshApex(this.PRSessions);
  }

  handleStartDateChange(event){

    this.searchPRStartDate = event.target.value;
    if(this.searchPREndDate != "" && this.searchPREndDate != undefined){
      
       if(this.searchPREndDate < this.searchPRStartDate){
          const evt = new ShowToastEvent({
              title: "警告",
              message: "会议开始时间不能大于结束时间！",
              variant: "warning",
          });
          this.dispatchEvent(evt);
       }
    }
  }

  handleEndDateChange(event){

    this.searchPREndDate = event.target.value;
    if(this.searchPRStartDate != "" && this.searchPRStartDate != undefined){
       if(this.searchPREndDate < this.searchPRStartDate){
          const evt = new ShowToastEvent({
              title: "警告",
              message: "会议开始时间不能大于结束时间！",
              variant: "warning",
          });
          this.dispatchEvent(evt);
       }
    }
  }

  handleOrganizerChange(event){
    this.searchPROrganizer = event.target.value;
  }

  handleChargerChange(event){
    this.searchPRCharger = event.target.value;
  }

  handleReviewerChange(event){
    this.searchPRReviewer = event.target.value;
  }

  handleStatusChange(event){
    this.searchPRApprovalStatus = event.target.value;
  }

  handlephotoChange(event){
      this.searchPhototype = event.target.value;
      return refreshApex(this.objects);
  }

  doRedirect(){
	this[NavigationMixin.Navigate]({
    type: 'standard__webPage',
        attributes: {
            url: '/lightning/n/LWCPhotos'
        },
    });
  }

  openModal(event){
    //"/servlet/servlet.FileDownload?file=00P2v00002UOdh8"
    //this.showimageid = event.currentTarget.dataset.value;
    this.showimageid = "/servlet/servlet.FileDownload?file=00P2v00002UOdh8";
  	this.IsOpen = true;
  }

  closeModal(){
  	this.IsOpen = false;
  }

  async loadMoreImages(event){
     this.totallimit += 1;
     if(this.totallimit < 6){
      /*
        let data = await loadMore({thislimit : this.totallimit});
        if (data.length > 0) {
          for (let i = 0; i < data.length; i++) {
            this.objects = [...this.objects, {key: i, data: data[i]}];
          }
        }*/
        return refreshApex(this.objects);
     }else{
        const evt = new ShowToastEvent({
              title: "警告",
              message: "请示用搜索功能！",
              variant: "warning",
          });
          this.dispatchEvent(evt);
     }
  }
}