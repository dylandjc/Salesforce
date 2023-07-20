import { LightningElement, api} from 'lwc';
import getVehicleForOpportunity from "@salesforce/apex/VehicleDetailsController.getVehicleForOpportunity";
export default class VehicleDetails extends LightningElement {
    @api recordId;
    vehicle;
    similarVehicle1;
    similarVehicle2;
    dataLoaded = false;
    connectedCallback() {
        this.loadData();
    }
    //get similarvehicle for opportunity 
    // make it a wrapper 
    loadData() {
        getVehicleForOpportunity({ opportunityId : this.recordId })
            .then((result) => {
                this.vehicle = result.currentVehicle;
                this.similarVehicle1 = result.similarVehicles1;
                this.similarVehicle2 = result.similarVehicles2;
                this.dataLoaded = true;
                //set values/boolean here
            })
            .catch((error) => {
                this.showError(error, "Error loading Product Details");
            })
    }
    showError(error) {
        console.error(error);
    }

    navigateToRecord(e) {
        // TODO 
    }
}