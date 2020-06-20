import React, { Component } from 'react';
import { form } from 'reactstrap';
import { setGlobalCssModule } from 'reactstrap/lib/utils';

class Form extends Component {
    constructor () {
        super ();
        this.state = {
            name : '',
            age : '',
            designation : '',
            sex : ''
        };
        this.handleChange = this.handleChange.bind (this);
        this.handleSubmit = this.handleSubmit.bind (this);
    }

    handleChange (event) {
        const {name, value} = event.target
        this.setState({
            [name]: value            
        });
    }

    handleSubmit(event) {
        console.log('Current State is: ' + JSON.stringify(this.state));
        alert('Current State is: ' + JSON.stringify(this.state));
    }

    render () {
        return (
            <div className = 'container'>  
                <form onSubmit = {this.handleSubmit}>
                    <div className = "form-group row">
                        <label>Name</label>
                        <input 
                            name = "name"
                            type = "text" 
                            value = { this.state.name }
                            onChange = { this.handleChange }
                            className = "form-control" 
                            id = "fullName"  
                            placeholder = "Enter your name"
                            required 
                        />
                        <small className = "form-text text-muted">Please enter your full name as in your ID</small>
                    </div>
                    <div className = "form-group row">
                        <label>Age</label>
                        <input
                            type = "number"
                            name = "age"
                            value = { this.state.address }
                            onChange = { this.handleChange }
                            className = "form-control"
                            id = "userAge"
                            placeholder = "Enter your age"
                            required
                        />
                    </div>
                    <div className = "form-group row">
                        <label>Designation</label>
                        <input
                            type = "text"
                            name = "designation"
                            className = "form-control"
                            value = { this.state.mobile }
                            onChange = { this.handleChange }
                            id = "designation"
                            placeholder = "Enter your designation"
                            required
                        />
                    </div>
                    <div className = "form-group row">
                        <label>Sex</label>
                        <input 
                            name = "sex"
                            type = "text" 
                            value = { this.state.idno }
                            onChange = { this.handleChange }
                            className = "form-control" 
                            id = "gender" 
                            placeholder = "M/F" 
                            required
                        />
                    </div>
                    <button type = "submit" className = "btn btn-danger">Submit</button>
                </form>
            </div>
        );
    }
}

export default Form;