import { LightningElement, api } from 'lwc';

export default class TodoItem extends LightningElement {
    @api id;
    @api name;
    @api status;
    @api isFinished; // Notice the casing

    completeTask(e) {
        // TODO - Validate

        // Without passing data
        // this.dispatchEvent(new CustomEvent("completetask"));

        // With passing data
        const selectedEvent = new CustomEvent("completetask", { detail: {id: this.id, name: this.name, from: "Dan"} });
        this.dispatchEvent(selectedEvent);        
    }    
}