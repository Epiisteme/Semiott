import React, { Component } from 'react';
import { Button, Modal, ModalHeader, ModalBody, ModalFooter } from 'reactstrap';

class PopupComponent extends Component {

    render() {
        return (
            <Modal isOpen = {this.props.mod}>
                <ModalHeader>Warning</ModalHeader>
                <ModalBody>
                    This site reads your data.. Click agree to continue
                </ModalBody>
                <ModalFooter >
                    <Button color="danger" onClick = {this.props.click}>Agree</Button>
                </ModalFooter>
            </Modal >
        );
    }
}

export default PopupComponent;