public with sharing class AgentContactForm {

    public class ContactInput {

        @InvocableVariable(required=true)
        public String accountName;

        @InvocableVariable(required=true)
        public String firstName;

        @InvocableVariable(required=true)
        public String lastName;

        @InvocableVariable(required=true)
        public String email;
    }

    public class ContactOutput {

        @InvocableVariable
        public String contactName;

        @InvocableVariable
        public String accountName;

        @InvocableVariable
        public String message;
    }

    @InvocableMethod(label='Create Contact From Form')
    public static List<ContactOutput> createContact(
        List<ContactInput> requests
    ) {

        List<ContactOutput> results = new List<ContactOutput>();
        Set<String> accountNames = new Set<String>();

        for (ContactInput request : requests) {
            if (request != null && !String.isBlank(request.accountName)) {
                accountNames.add(request.accountName.trim());
            }
        }

        Map<String, Account> accountsByName = new Map<String, Account>();

        if (!accountNames.isEmpty()) {
            for (Account account : [
                SELECT Id, Name
                FROM Account
                WHERE Name IN :accountNames
            ]) {
                accountsByName.put(account.Name, account);
            }
        }

        List<Contact> contactsToInsert = new List<Contact>();
        List<ContactOutput> pendingOutputs = new List<ContactOutput>();

        for (ContactInput request : requests) {

            ContactOutput result = new ContactOutput();

            if (request == null || String.isBlank(request.accountName)) {
                result.message = 'Account Name is required.';
                results.add(result);
                continue;
            }

            String accountName = request.accountName.trim();
            Account account = accountsByName.get(accountName);

            if (account == null) {
                result.accountName = accountName;
                result.message = 'Account not found.';
                results.add(result);
                continue;
            }

            Contact contact = new Contact(
                AccountId = account.Id,
                FirstName = request.firstName,
                LastName = request.lastName,
                Email = request.email
            );

            contactsToInsert.add(contact);
            pendingOutputs.add(result);
        }

        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }

        for (Integer i = 0; i < contactsToInsert.size(); i++) {

            Contact contact = contactsToInsert[i];
            ContactOutput result = pendingOutputs[i];

            result.contactName = contact.Name;
            result.accountName = contact.Account.Name;
            result.message = 'Contact created successfully.';

            results.add(result);
        }

        return results;
    }
}