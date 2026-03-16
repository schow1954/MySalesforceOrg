import { api, LightningElement, track, wire } from 'lwc';  
import fetchRecs from '@salesforce/apex/CustomListViewController.fetchRecs';   
import { NavigationMixin } from 'lightning/navigation';
 
export default class customListViewComponent extends NavigationMixin( LightningElement ) {  
 
    @track listRecs;  
    @track initialListRecs;
    @track error;  
    @track columns;  
    @api AccountId;
    @api RelatedObject;
    @api Fields;
    @api RelatedField;
    @api TableColumns;
    @api Title;
    sortedBy;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';

    connectedCallback() {

        //this.columns = JSON.parse( this.TableColumns.replace( /([a-zA-Z0-9]+?):/g, '"$1":' ).replace( /'/g, '"' ) );
        this.columns = JSON.parse( this.TableColumns);

    }

    get vals() {  

        return this.RelatedObject + '-' + this.Fields + '-' +   
               this.RelatedField + '-' + this.AccountId;  

    }

    @wire(fetchRecs, { listValues: '$vals' })  
    wiredRecs( { error, data } ) {

        if ( data ) {

            console.log( 'Records are ' + JSON.stringify( data ) );
            this.listRecs = data;
            this.initialListRecs = data;

        } else if ( error ) {

            this.listRecs = null;
            this.initialListRecs = null;
            this.error = error;

        }
        
    }

    onHandleSort( event ) {

        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.listRecs];
        cloneData.sort( this.sortBy( sortedBy, sortDirection === 'asc' ? 1 : -1 ) );
        this.listRecs = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;

    }

    sortBy( field, reverse, primer ) {

        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            return reverse * ( ( a > b ) - ( b > a ) );
        };

    }

    handleRowAction( event ) {

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch ( actionName ) {
            case 'view':
                this[NavigationMixin.GenerateUrl]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        actionName: 'view',
                    },
                }).then(url => {
                     window.open(url);
                });
                break;
            case 'edit':
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: row.Id,
                        objectApiName: this.RelatedObject,
                        actionName: 'edit'
                    }
                });
                break;
            default:
        }

    }
}