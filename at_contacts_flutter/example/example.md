<img width=250px src="https://atsign.dev/assets/img/@platform_logo_grey.svg?sanitize=true">

# at_contacts_flutter Example

In this example, Let us see how to use add, delete, block, unblock an user in real-time applications.

> **NOTE**: Make sure you have read the documentation to understand the example.

## Get Started

Create a new at_app using [at_app](https://pub.dev/packages/at_app) package.

  ### Generate a new at_app

  ```bash
  at_app create --sample=<package ID> -n=<YOUR NAME SPACE> <APP NAME>
  ```

  > There are 2 more arguments called root-domain (-r) and api-key (-k) which are currently not required. For more details head over to [at_app Flags](https://pub.dev/packages/at_app#:~:text=options%5D%20%3Coutput%20directory%3E-,Flags,-at_app%20create%20includes) documentation.

  **What will be this doing?**
  - This command will generate a simple skeleton of your at_app.
  - Go to the `.env` file and add your namespace if you haven't passed it as an argument.

  ### Run your project

  ```bash
  flutter run
  ```

  ### Start Coding

  By default, there will be at_onboarding_flutter widget implemented in your project. But, we need to make little changes to it.

  #### Login Screen

  - Select the whole Scaffold widget (including body) and hit `Ctrl + .`(Windows/Linux) or `⌘ + .`(Mac) and select **Extract Widget**.
  - Name that widget `LoginScreen` and hit Enter.
  - Now, you will see a new widget called `LoginScreen` in your project.
  - Now let us add some properties values to onboarding widget.

  > **NOTE :** If you using [VisualStudio Code](https://code.visualstudio.com/), You will be catching an Exception called *AtSign not found*. This is because, `Uncaught Exceptions` is checked by default.
  > Ignore this line in debug console - `I/flutter (20332): SEVERE|2021-12-20 19:21:25.593804|AtClientService|Atsign not found`. This is because you don't have `AtSign` in your project initially.

- Create a new file called `client_sdk_services.dart` in `lib/` directory.

> **NOTE :** Please handle the currentAtSign by reading the [`at_client_mobile`](https://pub.dev/packages/at_client_mobile) documentation.

- Now let's write some app logic. Create a class with instance called ClientSdkService.

```dart
class ClientSdkService {
  static final ClientSdkService _singleton = ClientSdkService._internal();

  ClientSdkService._internal();
  factory ClientSdkService.getInstance() {
    return _singleton;
  }
}
```

- Create a function to initialize contacts services in that `ClientSdkServices` class.

```dart
class ClientSdkServices{
  void initializeContactsService() async => 
    initializeContactsService(rootDomain: AtEnv.rootDomain);
}
```

- Now call this function in `initState()` of HomePage.

- Write a function to get current atSign.

```dart
AtClient atClientInstance = AtClientManager.getInstance().atClient;

Future<String?> getCurrentAtSign() async => atClientInstance.getCurrentAtSign();
```

- Now, Let's write a function to add an atSign to our contacts.

- To use adding a contact, we should add [`at_contact`](https://pub.dev/packages/at_contact) package to our project.ß

```dart
AtContactsImpl _atContact = AtContactsImpl(atClientInstance, atClientInstance.getCurrentAtSign()!);

Future<void> addContact(String atSign, AtContactsImpl atContact) async {
  AtContact contact = AtContact()
    ..atSign = atSign
    ..createdOn = DateTime.now()
    ..type = ContactType.Individual;
  bool isContactAdded = await atContact.add(contact);
  debugPrint(isContactAdded
      ? 'Contact added successfully'
      : 'Failed to add contact');
}
```

- Now, Let's write a function to delete an atSign from our contacts.

```dart
Future<void> deleteContact(String atSign, AtContactsImpl atContact) async {
  bool isContactAdded = await atContact.delete(atSign);
  debugPrint(isContactAdded
      ? 'Contact deleted successfully'
      : 'Failed to delete contact');
}
```

- Now let us write the whole functionality of adding contact and deleting contact.

- Create a customDialog funtion to show a dialog for add or delete an atSign.

```dart
class Dialogs {
  static Future<dynamic> customDialog(
      BuildContext context, String title, String body, VoidCallback? onPressed,
      {required String? buttonText, Widget? childContent}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              body,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (childContent != null) const SizedBox(height: 10),
            if (childContent != null) childContent,
            if (childContent != null) const SizedBox(height: 10),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed,
            child: Text(
              buttonText!,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.blue[400],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Add a contact**

```dart
Future<void> addContactDialog(BuildContext context) async {
  await Dialogs.customDialog(
    context,
    'Add contact?',
    'Enter the @sign to add as a contact',
    () async {
      await clientSdkService.addContact(pickedAtSign!, _atContact);
      Navigator.pop(context);
    },
    childContent: TextField(
      onChanged: (value) {
        setState(() {
          pickedAtSign = value;
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '@sign',
      ),
    ),
    buttonText: 'Add',
  );
}

ElevatedButton(
  onPressed: () async => addContactDialog(context),
  child: const Text('Add contact'),
),
```

**Delete a contact**

```dart
Future<void> deleteContactDialog(BuildContext context) async {
  await Dialogs.customDialog(
    context,
    'Delete contact?',
    'Enter the @sign to delete as a contact',
    () async {
      await clientSdkService.deleteContact(pickedAtSign!, _atContact);
      Navigator.pop(context);
    },
    childContent: TextField(
      onChanged: (value) {
        setState(() {
          pickedAtSign = value;
        });
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '@sign',
      ),
    ),
    buttonText: 'Delete',
  );
}

ElevatedButton(
  onPressed: () async => deleteContactDialog(context),
  child: const Text('Delete contact'),
),
```

**Navigate to all contacts screen**

```dart
ElevatedButton(
  onPressed: () {
    // any logic
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => const ContactsScreen(),
    ));
  },
  child: const Text('Show contacts'),
),
```

- In `ContactsScreen`, If you have already added some contacts, then you can see them.

- To block a contact, you need to slide the contact card, and click on the `block` button.

**Navigate to blocked contacts screen**

```dart
ElevatedButton(
  onPressed: () {
    // any logic
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => BlockedScreen(),
    ));
  },
  child: const Text('Show blocked contacts'),
),
```

- In `BlockedScreen`, If you have already blocked some contacts, then you can see them.

- To unblock the contact, you need to click on the `unblock` button.

For more reference, please head over to our [example code](https://github.com/atsign-foundation/at_widgets/tree/trunk/at_contacts_flutter/example). In case of any queries, please feel free to reach out to us at [Discord](https://discord.com/invite/55sHTQFxfz) or [Github](https://github.com/atsign-foundation/at_widgets/discussions).