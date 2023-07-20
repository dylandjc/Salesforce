import { LightningElement} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import initializeLotData from "@salesforce/apex/DanDemoController.initializeLotData";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import parkingLotLandingPage from "@salesforce/apex/DanDemoController.parkingLotLandingPage";
import lotSectionsPage from "@salesforce/apex/DanDemoController.lotSectionsPage";
// Convert our literal Vehicle__c.Color__c color strings into modern-looking colors
// TODO - Need a few others, I think


export default class DanDemo extends NavigationMixin(LightningElement) {
    rowsSelected = [];
    allRows = [];
    lots = [];
    needToRefresh = false;
    opp = 'Opportunity';
    rows = [];
    vehicle;
    fullLots = '';
    allLots = [];
    selectionMade = false;
    parkingLot = [];
    index = -1;
    dataLoaded = false;
    constructor() {
        super();
        console.log("Initialize Parking Lot info");
        this.initializeApexData();
        window.setInterval(this.initializeApexData, 10000);
        //window.setInterval(this.refreshPage, 10000);
    }

    connectedCallback() {
        this.initializeApexData();
        console.log("hello world - second");
    }

    handleClick(event) {
        this.value = event.target.checked;
        console.log(event.target.checked);
        if(event.target.checked){
            this.rowsSelected.push(event.target.value);
        }
        else{
            this.index = this.rowsSelected.indexOf(event.target.value);
            if(this.index > -1){
                this.rowsSelected.splice(this.index, 1);
            }
        }
        this.rowsSelected.sort();
        console.log(this.rowsSelected);
        //console.log(this.value);
        //console.log(this.rowsSelected);
        this.buildRowData();   
    }

    buildRowData(){
        console.log('We have entered load data');
        if(this.rowsSelected.length > 0){
            this.selectionMade = true;
            this.rows = [];
            console.log(this.allRows);
            for(const element of this.rowsSelected){
                this.rows.push({id:element, values: this.allRows[element]});
            }
            console.log(this.rows);
        }
        else{
            this.selectionMade = false;
            //call the ParkingLotSummary
        }
        //check which rows have been selected 
        //if no rows selected

    }
    initializeApexData(){
        console.log('Entered initialized');
        parkingLotLandingPage().then((result)=>{
            if(this.parkingLot != [] && this.parkingLot != null){
                if(this.parkingLot.percentFull != result.percentFull){
                    //console.log('YES YES YES YES YESY EYESY YES YESY ESYYESYES');
                    this.needToRefresh = true; 
                }
            }
            this.parkingLot = result;
        }).catch((error)=>{
            this.showError(error, 'Error loading the landing page');
        })

        lotSectionsPage().then((result)=>{
            this.allLots = result;
            this.dataLoaded = true;
            this.fullLots = '';
            this.lots = [];
            for(const element1 of this.allLots){
                this.lots.push({id:element1.name, values:element1});
                if(element1.isFull){
                    if(this.fullLots == ''){
                        this.fullLots = element1.name;
                    }else{
                        this.fullLots = this.fullLots + ' ' + element1.name;
                    }
                }
            }
            this.fullLots = this.fullLots.replaceAll(' ', ', ');
        }).catch((error)=>{
            this.showError(error, 'Error loading the landing page');
        })

        initializeLotData().then((result)=>{
            this.allRows = result;
            console.log(this.allRows);
        }).catch((error) => {
            this.showError(error, "Error loading Profit Info");
        })
    }
    showError(error) {
        console.error(error);
    }
    
    createNewOpportunity(event){
        console.log('Entered the correct on click method');
        this.vehicle = event.currentTarget.getAttribute("data-record-id");
        //this.vehicle = (event.currentTarget.id).substring(0,(event.currentTarget.id).length-4);
        //const vehicle = event.target.id;
        //console.log(this.vehicle);
        //console.log(typeof this.vehicle);
        const defaultValues = encodeDefaultFieldValues({
            //'Vehicle__c': 'a028X000011S87zQAC'
            Vehicle__c: this.vehicle
            //Name: this.vehicle
         });
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'new'
            },
            state:{
                defaultFieldValues: defaultValues
            }
        });
    }
    //refreshPage(){
    //    if(this.needToRefresh){
    //        eval("$A.get('e.force:refreshView').fire();");
    //        this.needToRefresh = false;
    //    }
    //}
    
}