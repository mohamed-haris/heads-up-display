import 'package:firebase_auth/firebase_auth.dart';
import 'package:heads_up_display/fbase_user.dart';

class FirebaseAuthService{
  final FirebaseAuth auth = FirebaseAuth.instance;

  FBaseUser _userFromFirebaseUser(User? user) {
    return FBaseUser(uid: user?.uid);
  }

  Stream<FBaseUser> get user{
    return auth.authStateChanges().map(_userFromFirebaseUser);
  }
  
}