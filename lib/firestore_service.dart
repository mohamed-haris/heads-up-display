import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future registerNewUser(String? uid, String? name,String? mobile, List? emergencyContacts) async {
    return await usersCollection.doc(uid).set({
      'name': '$name',
      'mobile': '$mobile',
      'emergencyContacts': emergencyContacts
    });
  }

  Future? getEmergencyContacts(String uid) async {
    return await usersCollection.doc(uid).get().then((document) {
      return document['emergencyContacts'];
    });
  }

  Future? getName(String uid) async {
    return await usersCollection.doc(uid).get().then((document) {
      return document['name'];
    });
  }

}