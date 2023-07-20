import { LightningElement } from 'lwc';

export default class TodoList extends LightningElement {

    myTasks = [{"id": 1, "name": "Laundry", "status": "In Progress", "isFinished": false},
               {"id": 2, "name": "Homework", "status": "Not Started", "isFinished": false},
               {"id": 3, "name": "Go Shopping", "status": "Not Started", "isFinished": false}
    ];

    removeTask(e) {
        console.log("In removeTask on the parent component");
        console.log(e);
        console.log(JSON.parse(JSON.stringify(e.detail)));        
    }

}