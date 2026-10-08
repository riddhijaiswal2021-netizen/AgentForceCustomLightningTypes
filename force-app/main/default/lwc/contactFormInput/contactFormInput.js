import { LightningElement, api } from 'lwc';

export default class ContactFormInput extends LightningElement {
    @api value = {
        accountName: '',
        firstName: '',
        lastName: '',
        email: ''
    };

    handleInputChange(event) {
        event.stopPropagation();

        const { name, value } = event.target;

        this.value = {
            ...this.value,
            [name]: value
        };

        this.dispatchEvent(
            new CustomEvent('valuechange', {
                detail: {
                    value: this.value
                }
            })
        );
    }
}