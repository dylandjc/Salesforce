import { LightningElement } from 'lwc';
import getTopVehicles from "@salesforce/apex/TopPerformers.getTopVehicles";
import getTopSalesReps from "@salesforce/apex/TopPerformers.getTopSalesReps";
export default class TopPerformers extends LightningElement {
    firstLoaded = false;
    first;
    firstVal;
    second;
    third;
    secondVal;
    thirdVal;
    fourth
    fourthVal;
    fifth;
    fifthVal;
    sixthVal;
    sixth;
    secondLoaded = false;
    thirdLoaded = false;
    fourthLoaded = false;
    fifthLoaded = false;
    sixthLoaded = false;
    comboBoxValue = 'Sales Representative';
    connectedCallback(){
        this.loadData();
    }
    get options() {
        return [
            {label: 'Sales Rep', value: 'Sales Representative'},
            {label: 'Manufacturer', value: 'Vehicle Manufacturer'},
            {label: 'Vehicle Models', value: 'Vehicle Model'}
        ];
    }
    loadData() {
        if(this.comboBoxValue == 'Sales Representative'){
            getTopSalesReps({isProfit : false}).then((result)=>{
                this.first = result[0].name;
                this.firstVal = result[0].sales;
                this.firstLoaded = true;
                this.second = result[1].name;
                this.secondVal = result[1].sales;
                this.third = result[2].name;
                this.thirdVal = result[2].sales;
            }).catch((error) => {
                this.showError(error, "Error loading Sales Info");
            })

            getTopSalesReps({isProfit : true}).then((result)=>{
                this.fourth = result[0].name;
                this.fourthVal = result[0].profits;
                this.fifth = result[1].name;
                this.fifthVal = result[1].profits;
                this.sixth = result[2].name;
                this.sixthVal = result[2].profits;
            }).catch((error) => {
                this.showError(error, "Error loading Profit Info");
            })
        }
        else{
            getTopVehicles({isProfit : false, isMake: this.comboBoxValue == 'Vehicle Manufacturer'}).then((result)=>{
                this.first = result[0].name;
                this.firstVal = result[0].sales;
                this.firstLoaded = true;
                this.second = result[1].name;
                this.secondVal = result[1].sales;
                this.third = result[2].name;
                this.thirdVal = result[2].sales;
            }).catch((error) => {
                this.showError(error, "Error loading Sales Info");
            })

            getTopVehicles({isProfit : true , isMake: this.comboBoxValue == 'Vehicle Manufacturer'}).then((result)=>{
                this.fourth = result[0].name;
                this.fourthVal = result[0].profits;
                this.fifth = result[1].name;
                this.fifthVal = result[1].profits;
                this.sixth = result[2].name;
                this.sixthVal = result[2].profits;
            }).catch((error) => {
                this.showError(error, "Error loading ProfitInfo");
            })


        }
    }
    handleChange(event){
        this.comboBoxValue = event.detail.value;
        this.loadData();
    }

    showError(error) {
        console.error(error);
    }


}