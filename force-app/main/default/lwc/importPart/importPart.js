import { LightningElement, wire,track } from 'lwc';
import getPartsList from '@salesforce/apex/ImportPartController.SyncParts';
	
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ImportPart extends LightningElement {
    @track showSpinner = false;

    handleClick(){
        this.showSpinner = true
        getPartsList()
        .then(result =>{
            if(result == 'Success'){
                this.showSpinner = false
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Parts Sync Complete',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
            }else{
                this.showSpinner = false
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
            }
        })
        .catch(error =>{
        })
    }
}