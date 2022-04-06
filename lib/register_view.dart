import 'package:camera/camera.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:heads_up_display/fbase_user.dart';
import 'package:heads_up_display/firestore_service.dart';
import 'package:heads_up_display/home.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatefulWidget {
  final String mobileNumber;
  RegisterView(this.mobileNumber);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String get name => _name;
  void setName(String s) {
    setState(() {
      _name = s;
    });
  }

  List<ContactList> contacts = [];
  List<String> emergencyContacts = [];

  @override
  void initState() {
    initContactLists();

    super.initState();
  }

  void initContactLists() async {
    List<ContactList> contactsList = await fetchContactsWithName();
    
      setState(() {
        contacts = contactsList;
      });
    
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FBaseUser>(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Register'),
        centerTitle: true,
      ),
      body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Your Registered Mobile Number:',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () => print("Cannot edit this field"),
                      child: TextFormField(
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.lock, color: Colors.grey.shade700),
                          enabled: false,
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          hintText: '${widget.mobileNumber}',
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(5.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Name:',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          hintText: 'Name',
                          hintStyle: TextStyle(color: Colors.grey.shade700),
                          isDense: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(5.0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade600, width: 1.0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(5.0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 1.0),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(5.0),
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val!.isEmpty) {
                            return 'Field must not be empty';
                          } else {
                            return null;
                          }
                        },
                        onChanged: (val) {
                          setName(val);
                        }),
                    Divider(color: Colors.white, height: 50),
                    Text('Select Your Emergency Contacts', style: TextStyle(color: Colors.white)),
                    Container(
                      height: (contacts.length) * 60.0,
                      margin: const EdgeInsets.only(top:15, bottom:100),
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: contacts.length,
                        itemBuilder: (_, index) {
                          return _buildContactsList(contacts[index], index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.all(18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      onPressed: () async {
                        registerCall(user.uid!);
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
    );
  }

  Future registerCall(uid) async {
    await FirestoreService().registerNewUser(uid,_name, widget.mobileNumber, emergencyContacts);
    var cameras = await availableCameras();
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(cameras)));
  }

  void toggleSelection(idx) {
    setState(() {
      if(emergencyContacts.contains(contacts[idx].number)){
      emergencyContacts.remove(contacts[idx].number);
      contacts[idx].isSelected = false;
    }else{
      emergencyContacts.add(contacts[idx].number);
      contacts[idx].isSelected = true;
    }
    });
  }

  Widget _buildContactsList(contact, idx) {
    return GestureDetector(
      onTap: () => toggleSelection(idx),
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        child: Container(
          margin: EdgeInsets.only(left: 10.0),
          child: Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle),
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                  )),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    contact.number,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Spacer(),
              contact.isSelected ? Icon(Icons.check, color: Colors.green,) : Container()
            ],
          ),
        ),
      ),
    );
  }

  Future<List<ContactList>> fetchContactsWithName() async {
    final List<ContactList> contactsWithName = [];

    final nativeContacts = await ContactsService.getContacts(
      withThumbnails: false,
    );

    nativeContacts.forEach((contact) {
      contact.phones!.forEach((phoneNum) {
        contactsWithName
            .add(ContactList(contact.displayName!, phoneNum.value!, false));
      });
    });

    return contactsWithName;
  }
}

class ContactList {
  String name;
  String number;
  bool isSelected;
  ContactList(this.name, this.number, this.isSelected);
}
