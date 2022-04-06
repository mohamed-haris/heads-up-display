import 'package:flutter/material.dart';
import 'package:heads_up_display/otp_view.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class MobileNumberView extends StatefulWidget {

  final bool isSignup;
  MobileNumberView(this.isSignup);

  @override
  State<MobileNumberView> createState() => _MobileNumberViewState();
}

class _MobileNumberViewState extends State<MobileNumberView> {
  
  String? _mobileNumber = '';
  String? get mobileNumber => _mobileNumber;
  void updateMobileNumber(String? mn) {
    setState(() {
      _mobileNumber = mn;
    });
  }

  String? _countryCode = '';
  String? get countryCode => _countryCode;
  void updateCountryCode(String? cc) {
    setState(() {
      _countryCode = cc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
                    title: Text(widget.isSignup ? 'Sign Up' : 'Log in'),
                    centerTitle: true,
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
                              'Enter Your Mobile Number',
                              style: TextStyle(fontSize: 23, color: Colors.white),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'A 4 - digit code will be sent to the entered number.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            IntlPhoneField(
                              dropDownIcon: Icon(Icons.arrow_drop_down_rounded, color: Colors.white,),
                              countryCodeTextColor: Colors.white,
                              style: TextStyle(color: Colors.white),
                              // countries: ["IN","US"],
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: TextStyle(color: Colors.grey.shade700),
                                filled: true,
                                fillColor: Colors.grey.shade900,
                                contentPadding:
                                    EdgeInsets.fromLTRB(30, 20, 0, 20),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(5.0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade600, width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(5.0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blue, width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(5.0),
                                  ),
                                ),
                              ),
                              initialCountryCode: 'IN',
                              onChanged: (phone) {
                                updateMobileNumber(phone.number);
                                updateCountryCode(phone.countryCode);
                              },
                            ),
                            SizedBox(
                              height: 100,
                            )
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: mobileNumber!.length == 10 ? Colors.blue : Colors.grey,
                              padding: EdgeInsets.all(18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                            onPressed: () {
                              if(mobileNumber!.length != 10) {
                                print("Please enter a valid number.");
                              }else{
                                FocusScope.of(context).unfocus();
                                Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OTPView(mobileNumber!)),
                    );
                              }
                            },
                            child: Text(
                              'Next',
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
}