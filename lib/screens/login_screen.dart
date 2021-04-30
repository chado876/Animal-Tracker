import 'dart:io';

import 'package:animal_tracker/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:animal_tracker/providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../utilities/constants.dart';
import '../models/http_exception.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';
import './intro_screen.dart';

enum AuthMode { Signup, Login }

class LoginScreen extends StatelessWidget {
  // @override
  // _LoginScreenState createState() => _LoginScreenState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // SizedBox.expand(
        //   child: CustomPaint(
        //     painter: BackgroundPainter2(),
        //   ),
        // ),   not working
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white,
                ),
                Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.0,
                      vertical: 120.0,
                    ),
                    child: LoginCard(),
                  ),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class LoginCard extends StatefulWidget {
  const LoginCard({
    Key key,
  }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginCard> {
  bool _rememberMe = false;
  bool err = false;
  bool authErr = false;
  var authErrMsg = '';
  var errorMessage = '';
  bool _obscureText = true;
  bool _loginBtnDisabled = false;
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthMode _authMode = AuthMode.Login;

  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'confirmationPassword': ''
  };
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirmPass = TextEditingController();
  final _passwordController = TextEditingController();

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text('An Error Occurred!'),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      }),
                ]));
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
        print("Auth mode switched TO SIGNUP");
      });
    } else {
      setState(() {
        print("Auth mode switched TO LOGIN");
        _authMode = AuthMode.Login;
      });
    }
  }

  Future<void> _submit() async {
    _loginBtnDisabled = true;

    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signUp(
          _authData['email'],
          _authData['password'],
        );
      }
      Navigator.pushNamed(context, '/main');
    } on PlatformException catch (error) {
      err = true;
      print(error.toString());
      errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This passwordi s too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      print(error.toString());
      var errorMessage = 'Could not authenticate. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
      _loginBtnDisabled = true;
    });
  }

  Future<void> _submitV2() async {
    _loginBtnDisabled = true;

    final isValid = _formKey.currentState.validate();

    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }

    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        print(_authData['email']);
        // Log user in
        await _auth.signInWithEmailAndPassword(
          email: _authData['email'],
          password: _authData['password'],
        );

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('firstName', 'Chad');

        Navigator.pushReplacementNamed(context, '/intro');
      } else {
        // Sign user up
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userEmail: _authData['email'],
              userPassword: _authData['password'],
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      authErrMsg = e.message;
      authErr = true;
    } on PlatformException catch (error) {
      err = true;
      errorMessage = error.message;
      print(authErrMsg);
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This passwordi s too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      // _showErrorDialog(error.message);
    } catch (error) {
      print(error.toString());
      print(error);
      var errorMessage = error.toString();
      // _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
      _loginBtnDisabled = true;
    });
  }

  Widget _buildErrorBox() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Text(
        authErrMsg,
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildEmailTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          err ? errorMessage : '',
          style: kLabelStyle.copyWith(
            color: Colors.redAccent,
          ),
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            validator: (value) {
              if (value.isEmpty || !value.contains('@')) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            controller: _passwordController,
            decoration: InputDecoration(
              // border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.email,
                color: Colors.black,
              ),
              border: InputBorder.none,
              labelText: 'Email Address',
              hintStyle: kHintTextStyle,
            ),
            onSaved: (value) {
              _authData['email'] = value;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Text(
        //   'Password',
        //   style: kLabelStyle,
        // ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            controller: _pass,
            validator: (value) {
              if (value.isEmpty || value.length < 6) {
                return 'Please enter a valid password';
              }
              return null;
            },
            obscureText: _obscureText,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.black,
              ),
              suffixIcon: FlatButton(
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
                onPressed: _toggle,
              ),
              labelText: 'Password',
              hintStyle: kHintTextStyle,
            ),
            onSaved: (value) {
              _authData['password'] = value;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Text(
        //   'Confirm Password',
        //   style: kLabelStyle,
        // ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            obscureText: _obscureText,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.black,
              ),
              suffixIcon: FlatButton(
                child: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
                onPressed: _toggle,
              ),
              labelText: 'Confirmation Password',
              hintStyle: kHintTextStyle,
            ),
            validator: (value) {
              if (value.isEmpty)
                return 'Please enter your confirmation password';
              if (value != _pass.text) return 'Passwords do not match';
              return null;
            },
            onSaved: (value) {
              _authData['confirmationPassword'] = value;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
          style: kLabelStyle,
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.black),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                });
              },
            ),
          ),
          Text(
            'Remember me',
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    var btnTxt = '';

    if (_authMode == AuthMode.Login) {
      btnTxt = 'LOGIN';
    } else {
      btnTxt = 'SIGN UP';
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        // onPressed: () => _submit(),
        // onPressed: () => Navigator.pushNamed(context, '/profile'),
        onPressed: () => _submitV2(),
        // onPressed: () {
        //   Navigator.push(
        //     context,
        //     PageTransition(
        //       type: PageTransitionType.leftToRightWithFade,
        //       // duration: Duration(seconds: 1),
        //       child: AdditionalInfoScreen(),
        //     ),
        //   );
        // },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              btnTxt,
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            // _loginBtnDisabled
            //     ? SpinKitSquareCircle(color: Colors.white, size: 10),
          ],
        ),
      ),
    );
  }

  Function authRequest() {
    if (_loginBtnDisabled) {
      return null;
    } else {
      _submit();
    }
  }

  Widget _buildSignInWithText() {
    return Column(
      children: <Widget>[
        Text(
          '- OR -',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.0),
        Text(
          'Sign in with',
          style: kLabelStyle,
        ),
      ],
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
            () => print('Login with Facebook'),
            AssetImage(
              'assets/logos/facebook.jpg',
            ),
          ),
          _buildSocialBtn(
            () => print('Login with Google'),
            AssetImage(
              'assets/logos/google.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupBtn() {
    return GestureDetector(
      onTap: () => _switchAuthMode(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Don\'t have an Account? ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInTxt() {
    return GestureDetector(
      onTap: () => _switchAuthMode(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Already have an Account? ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/logos/templogo.png', height: 180, width: 180),
              if (_authMode == AuthMode.Login)
                Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'OpenSans',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_authMode == AuthMode.Signup)
                Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'OpenSans',
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 10),
              if (authErr) _buildErrorBox(),
              _buildEmailTF(),
              SizedBox(
                height: 5.0,
              ),
              _buildPasswordTF(),
              SizedBox(height: 5.0),
              if (_authMode == AuthMode.Signup) _buildConfirmPasswordTF(),
              if (_authMode == AuthMode.Login) _buildForgotPasswordBtn(),
              if (_authMode == AuthMode.Login) _buildRememberMeCheckbox(),
              _buildLoginBtn(),
              // if (_authMode == AuthMode.Login) _buildSignInWithText(),
              // if (_authMode == AuthMode.Login) _buildSocialBtnRow(),
              if (_authMode == AuthMode.Login) _buildSignupBtn(),
              if (_authMode == AuthMode.Signup) _buildSignInTxt(),
            ],
          ),
        ),
      ),
    );
  }
}
