import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heads_up_display/firebase_auth_service.dart';
import 'package:heads_up_display/home.dart';
import 'package:heads_up_display/register_view.dart';
import 'package:pinput/pin_put/pin_put.dart';

class OTPView extends StatefulWidget {
  final String mobileNumber;
  OTPView(this.mobileNumber);

  @override
  State<OTPView> createState() => OTPViewState();
}

@visibleForTesting
class OTPViewState extends State<OTPView> {

  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();

  final BoxDecoration pinPutDecoration = BoxDecoration(
    border: Border.all(width: 1.0, color: Colors.blue),
    borderRadius: const BorderRadius.all(
      const Radius.circular(5.0),
    ),
  );

  @override
  void initState() {
    super.initState();

    print(widget.mobileNumber);
    verifyPhone("+91${widget.mobileNumber}");
  }

  FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  String verificationCode = '';

  String _enteredPin = '';
  String get enteredPin => _enteredPin;
  void updateEnteredPin(String ep) {
    setState(() {
      _enteredPin = ep;
    });
  }

  bool _isTimerDone = false;
  bool get isTimerDone => _isTimerDone;
  void updateIsTimerDone(bool itd) {
    setState(() {
      _isTimerDone = itd;
    });
  }

  Future verifyPhone(String phoneNumber) async {
    await _firebaseAuthService.auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuthService.auth
              .signInWithCredential(credential)
              .then((value) async {
            bool newUser = value.additionalUserInfo!.isNewUser;
            if (value.user != null) {
              if (newUser) {
                navigateToRegister(value.user!.uid, phoneNumber);
              } else {
                var cameras = await availableCameras();
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(cameras)));
              }
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationID, int? resendToken) {
          setState(() {
            verificationCode = verificationID;  
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 100));
  }

  void navigateToRegister(String uid, String mobileNumber) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterView("+91${widget.mobileNumber}")));
  }

  Future signIntoFirebase(String phoneNum) async {
    await _firebaseAuthService.auth
        .signInWithCredential(PhoneAuthProvider.credential(
            verificationId: verificationCode, smsCode: _enteredPin))
        .then((value) async {
      bool newUser = value.additionalUserInfo!.isNewUser;
      if (value.user != null) {
        if (newUser) {
          navigateToRegister(value.user!.uid, phoneNum);
        } else {
          var cameras = await availableCameras();
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(cameras)));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text('OTP Verification'),
            centerTitle: true,
            backgroundColor: Colors.black,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Enter the OTP',
                        style: TextStyle(fontSize: 23, color: Colors.white),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'OTP sent to ${widget.mobileNumber}. Enter the OTP to get verified.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: PinPut(
                          fieldsCount: 6,
                          withCursor: true,
                          textStyle: const TextStyle(
                              fontSize: 25.0, color: Colors.white),
                          eachFieldWidth: 40.0,
                          eachFieldHeight: 50.0,
                          focusNode: _pinPutFocusNode,
                          controller: _pinPutController,
                          submittedFieldDecoration: pinPutDecoration,
                          selectedFieldDecoration: pinPutDecoration,
                          followingFieldDecoration: pinPutDecoration,
                          pinAnimationType: PinAnimationType.fade,
                          onSubmit: (pin) async {
                            updateEnteredPin(pin);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      buildTimer(updateIsTimerDone),
                      Visibility(
                        maintainAnimation: true,
                        maintainState: true,
                        visible: isTimerDone,
                        child: GestureDetector(
                          onTap: () {
                            print("OTP has been re-sent");
                            verifyPhone("+91${widget.mobileNumber}");
                          },
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                                color: Colors.white,
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      ),
                    ],
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
                      onPressed: enteredPin != ''
                          ? () async {
                              try {
                                await signIntoFirebase(widget.mobileNumber);
                              } catch (e) {
                                print("Invalid OTP");
                              }
                            }
                          : () => print("OTP cannot be empty"),
                      child: Text(
                        'Verify',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
  }

    Row buildTimer(updateVisibility) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "Timer: ",
          style: TextStyle(color: Colors.grey),
        ),
        TweenAnimationBuilder(
          tween: Tween(begin: 60.0, end: 0.0),
          duration: Duration(seconds: 60),
          builder: (_, double value, child) => Text(
            "00:${value.round()}",
            style: TextStyle(color: Colors.grey),
          ),
          onEnd: () => updateVisibility(true),
        ),
      ],
    );
  }

}