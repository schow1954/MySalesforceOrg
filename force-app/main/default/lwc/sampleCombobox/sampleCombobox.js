import { 
    LightningElement,
    track,
    wire,
    api
     
} from 'lwc';
 
import Objects_Type from "@salesforce/apex/Sample_Controller.f_Get_Types";
 
export default class sampleCombobox extends LightningElement {
    @track l_All_Types;
    @track TypeOptions;
 
    @wire(Objects_Type, {})
    WiredObjects_Type({ error, data }) {
 
        if (data) {
            try {
                this.l_All_Types = data; 
                let options = [];
                 
                for (var key in data) {
                    // Here key will have index of list of records starting from 0,1,2,....
                    options.push({ label: data[key].Name, value: data[key].Id  });
 
                    // Here Name and Id are fields from sObject list.
                }
                this.TypeOptions = options;
                 
            } catch (error) {
                console.error('check error here', error);
            }
        } else if (error) {
            console.error('check error here', error);
        }
 
    }
 
    handleTypeChange(event){
        var Picklist_Value = event.target.value; 
        // Do Something.
    }
}