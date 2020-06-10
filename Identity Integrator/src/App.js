import React, { Component, useEffect, useState } from 'react';
import './App.css';
import Form from './components/form';
import { Navbar, NavbarBrand } from 'reactstrap';
import PopupComponent from './components/popup';
import fetch from 'node-fetch';
import { initialize } from 'zokrates-js';
import ipInt from 'ip-to-int';

class App extends Component {
  constructor () {
    super ();
    this.state = {
        ip : null,
        action : null, 
        time : null,
        modal : true,
        a : null,
        k : null,
        c : null,
        v : null,
        p : null
    }
    this.agreeToPolicy = this.agreeToPolicy.bind (this);
  }

  async agreeToPolicy () {
    await fetch (`https://geolocation-db.com/json/`)
      .then (res => res.json())
      .then (json => this.setState({ip: json.IPv4}))
    this.setState ({ 
      action : "agreed to policy", 
      modal : false 
    });
    var d = new Date ();
    this.setState ({
      time:d.getTime ()
    })

      initialize ().then ((provider) => {

        // Compilation
        let artifacts = provider.compile ("def main(private field a, field b) -> (field): return a * b", "main", () => { });

        // Generate setup keypair
        let keypair = provider.setup (artifacts.program);

        // Computation
        let computationResult = provider.computeWitness (artifacts, [JSON.stringify(ipInt(this.state.ip).toInt()), JSON.stringify(this.state.time)]);

        // Export verifier
        let verifier = provider.exportSolidityVerifier (keypair.vk, true);

        // Generate proof
        let proof = provider.generateProof (artifacts.program, computationResult.witness, keypair.pk);

        this.setState ({
          a : artifacts,
          k : keypair,
          c : computationResult,
          v : verifier,
          p : proof
        })      

        console.log ("artifacts "+artifacts);
        console.log ("keypair "+keypair);
        console.log ("computationResult "+computationResult);
        console.log ("verifier "+verifier);
        console.log ("proof "+proof);  
        
    });
    console.log (JSON.stringify (this.state));
  }

  render() {
    return (
      <div className="App">
        <Navbar dark color="dark">
          <div className="container">
            <NavbarBrand href="/">
              <img src="assets/logo1.jpg" height = "40" width = "50" alt = "Error While Loading" />
              <b>  Identity Verifier</b>
            </NavbarBrand>
          </div>
        </Navbar>
        <br></br>
        <h1>
          Enter your details
        </h1>
        <PopupComponent mod = {this.state.modal} click = {this.agreeToPolicy}/>
        <Form />
      </div>
    );
  }
}

export default App;