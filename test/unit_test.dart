import 'package:flutter_test/flutter_test.dart';
import 'package:heads_up_display/home.dart';
import 'package:heads_up_display/hud.dart';
import 'package:heads_up_display/mobileNum_view.dart';
import 'package:heads_up_display/otp_view.dart';

void main() {
  test('Setting Name on the Home Page', () {
    var widget = HomePage([]);
    final element = widget.createElement();
    final state = element.state as HomePageState;
    state.setName('Haris');
    expect(state.name, "Haris");
  });
  test('Initial recognitions', () {
    var widget = HomePage([]);
    final element = widget.createElement();
    final state = element.state as HomePageState;
    expect(state.recognitions, null);
  });
  test('Initial image Width', () {
    var widget = HomePage([]);
    final element = widget.createElement();
    final state = element.state as HomePageState;
    expect(state.imageWidth, 0);
  });
  test('Initial image Height', () {
    var widget = HomePage([]);
    final element = widget.createElement();
    final state = element.state as HomePageState;
    expect(state.imageHeight, 0);
  });
  test('Setting Recognitions and verify recognition list', () {
    var widget = HomePage([]);
    final element = widget.createElement();
    final state = element.state as HomePageState;
    state.setRecognitions([1,2], 0, 0);
    expect(state.recognitions, [1,2]);
  });
  test('Setting Recognitions and verify image Width', () {
    var widget = HomePage([]);
    final element = widget.createElement();
    final state = element.state as HomePageState;
    state.setRecognitions([1,2], 0, 1);
    expect(state.imageWidth, 1);
  });
  test('Setting Recognitions and verify image Height', () {
    var widget = HomePage([]);
    final element = widget.createElement();
    final state = element.state as HomePageState;
    state.setRecognitions([1,2], 2, 1);
    expect(state.imageHeight, 2);
  });
  test('Initialize Mobile Number Page with Sign up mode', () {
    var widget = MobileNumberView(true);
    expect(widget.isSignup, true);
  });
  test('Initialize Mobile Number Page with Log in mode', () {
    var widget = MobileNumberView(false);
    expect(widget.isSignup, false);
  });
  test('Set Mobile Number on Signup/Login', () {
    var widget = MobileNumberView(false);
    final element = widget.createElement();
    final state = element.state as MobileNumberViewState;
    state.updateMobileNumber('7401529298');
    expect(state.mobileNumber, '7401529298');
  });
  test('Set Country Code on Signup/Login', () {
    var widget = MobileNumberView(false);
    final element = widget.createElement();
    final state = element.state as MobileNumberViewState;
    state.updateCountryCode('+91');
    expect(state.countryCode, '+91');
  });
}