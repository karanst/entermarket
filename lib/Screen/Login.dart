import 'dart:async';
import 'dart:convert';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:entemarket_user/Helper/ApiBaseHelper.dart';
import 'package:entemarket_user/Helper/String.dart';
import 'package:entemarket_user/Helper/app_assets.dart';
import 'package:entemarket_user/Helper/cropped_container.dart';
import 'package:entemarket_user/Provider/SettingProvider.dart';
import 'package:entemarket_user/Provider/UserProvider.dart';
import 'package:entemarket_user/Screen/SendOtp.dart';
import 'package:entemarket_user/Screen/SignUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';

class Login extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final mobileController1 = TextEditingController();
  final passwordController = TextEditingController();
  String? countryName;
  FocusNode? passFocus, monoFocus = FocusNode();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  String? password,
      mobile,
      username,
      email,
      id,
      mobileno,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getLoginUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        await buttonController!.reverse();
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(top: kToolbarHeight),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<void> getLoginUser() async {
    var data = {MOBILE: mobile, PASSWORD: password};

    Response response =
        await post(getUserLoginApi, body: data, headers: headers)
            .timeout(Duration(seconds: timeOut));
    var getdata = json.decode(response.body);
    print(response.body);
    bool error = getdata["error"];
    String? msg = getdata["message"];
    await buttonController!.reverse();
    if (!error) {
      setSnackbar(msg!);
      var i = getdata["data"][0];
      id = i[ID];
      username = i[USERNAME];
      email = i[EMAIL];
      mobile = i[MOBILE];
      city = i[CITY];
      area = i[AREA];
      address = i[ADDRESS];
      pincode = i[PINCODE];
      latitude = i[LATITUDE];
      longitude = i[LONGITUDE];
      image = i[IMAGE];
      loginFirebase(username,email);
      CUR_USERID = id;
      // CUR_USERNAME = username;

      UserProvider userProvider =
          Provider.of<UserProvider>(this.context, listen: false);
      userProvider.setName(username ?? "");
      userProvider.setEmail(email ?? "");
      userProvider.setProfilePic(image ?? "");

      SettingProvider settingProvider =
          Provider.of<SettingProvider>(context, listen: false);

      settingProvider.saveUserDetail(id!, username, email, mobile, city, area,
          address, pincode, latitude, longitude, image, context);

      Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
    } else {
      setSnackbar(msg!);
    }
  }
  // loginFb()async{
  //   await App.init();
  //   _isNetworkAvail = await isNetworkAvailable();
  //   if(_isNetworkAvail){
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signOut();
  //     print("login out fun");
  //     // UserCredential data = await signInWithFacebook();
  //     print("login fun");
  //     print(data.additionalUserInfo!.profile.toString());
  //     print(data.user!.uid);
  //     var newData = data.additionalUserInfo!.profile;
  //     String myName = newData!["given_name"].toString();
  //     String myEmail = newData["email"].toString();
  //     await FirebaseChatCore.instance.createUserInFirestore(
  //       types.User(
  //         firstName: myName,
  //         id: data.user!.uid,
  //         imageUrl: 'https://i.pravatar.cc/300?u=$myEmail',
  //         lastName: "",
  //       ),
  //     );
  //     Map params = {
  //       "name" : myName,
  //       "email" : myEmail,
  //       "app_id" : packageName,
  //       "google_login": "1",
  //     };
  //     var response = await apiBase.postAPICall(Uri.parse(baseUrl+"social_login"), params);
  //     setState(() {
  //       selected = !selected;
  //     });
  //     bool error = response["error"];
  //     String? msg = response["message"];
  //     await buttonController!.reverse();
  //   setSnackbar("Google Login Successfully");
  //   if (!error) {
  //   setSnackbar(msg!);
  //   var i = response["data"][0];
  //   id = i[ID];
  //   username = i[USERNAME];
  //   email = i[EMAIL];
  //   loginFirebase(username,email);
  //   mobile = i[MOBILE];
  //   city = i[CITY];
  //   area = i[AREA];
  //   address = i[ADDRESS];
  //   pincode = i[PINCODE];
  //   latitude = i[LATITUDE];
  //   longitude = i[LONGITUDE];
  //   image = i[IMAGE];
  //   App.localStorage.setString("firebaseUid", data.user!.uid.toString());
  //   CUR_USERID = id;
  //   // CUR_USERNAME = username;
  //
  //   UserProvider userProvider =
  //   Provider.of<UserProvider>(this.context, listen: false);
  //   userProvider.setName(username ?? "");
  //   userProvider.setEmail(email ?? "");
  //   userProvider.setProfilePic(image ?? "");
  //
  //   SettingProvider settingProvider =
  //   Provider.of<SettingProvider>(context, listen: false);
  //
  //   settingProvider.saveUserDetail(id!, username, email, mobile, city, area,
  //   address, pincode, latitude, longitude, image, context);
  //
  //   Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
  //   } else {
  //   setSnackbar(msg!);
  //   }
  //
  //   }else{
  //   setSnackbar("No Internet");
  //   }
  // }
  GoogleSignIn googleSignIn = GoogleSignIn(
    // Optional clientId
    // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
    scopes: <String>[
      'email',
    ],
  );
  bool selected = true;
  ApiBaseHelper apiBase = new ApiBaseHelper();


  addMobileBottom(uid,name,email){
    showModalBottomSheet(context: context,
        isScrollControlled: true,
        builder: (context){
          return Padding(
            padding: EdgeInsets.only(
              left: 15,right: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  SizedBox(height: 20,),
                Text(
                  'Add Mobile Number',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20,),
                setMobileNo1(),
                SizedBox(height: 20,),
                AppBtn(
                  title: getTranslated(context, 'SIGNIN_LBL'),
                  btnAnim: buttonSqueezeanimation,
                  btnCntrl: buttonController,
                  onBtnSelected: () async {
                      if(validateMob(
                          mobileController1.text,
                          getTranslated(context, 'MOB_REQUIRED'),
                          getTranslated(context, 'VALID_MOB'))!=null){
                        // Fluttertoast.showToast(msg:validateMob(
                        //     mobileController1.text,
                        //     getTranslated(context, 'MOB_REQUIRED'),
                        //     getTranslated(context, 'VALID_MOB'))!);
                        return;
                      }
                      Navigator.pop(context);
                      _playAnimation();
                      socialLogin(uid, name, email);
                  },
                ),
                SizedBox(height: 20,),
              ],
            ),
          );
    });
  }

  googleLogin() async{
    await App.init();
    _isNetworkAvail = await isNetworkAvailable();
    if(_isNetworkAvail){
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signOut();
      print("login out fun");
      UserCredential data = await signInWithGoogle();
      print("login fun");
      print(data.additionalUserInfo!.profile.toString());
      print(data.user!.uid);
      var newData = data.additionalUserInfo!.profile;
      String myName = newData!["given_name"].toString();
      String myEmail = newData["email"].toString();
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: myName,
          id: data.user!.uid,
          imageUrl: 'https://i.pravatar.cc/300?u=$myEmail',
          lastName: "",
        ),
      );
      addMobileBottom(data.user!.uid.toString(),myName,myEmail);
    }else{
      setSnackbar("No Internet");
    }
  }
  socialLogin(uid,myName,myEmail)async{
    Map params = {
      "name" : myName,
      "email" : myEmail,
      "app_id" : packageName,
      "mobile":mobileController1.text,
      "google_login": "1",
    };
    var response = await apiBase.postAPICall(Uri.parse(baseUrl+"social_login"), params);
    setState(() {
      selected = !selected;
    });
    bool error = response["error"];
    String? msg = response["message"];
    await buttonController!.reverse();
    setSnackbar("Google Login Successfully");
    if (!error) {
    setSnackbar(msg!);
    var i = response["data"][0];
    id = i[ID];
    username = i[USERNAME];
    email = i[EMAIL];
    //loginFirebase(username,email);
    mobile = i[MOBILE];
    city = i[CITY];
    area = i[AREA];
    address = i[ADDRESS];
    pincode = i[PINCODE];
    latitude = i[LATITUDE];
    longitude = i[LONGITUDE];
    image = i[IMAGE];
    App.localStorage.setString("firebaseUid", uid.toString());
    CUR_USERID = id;
    // CUR_USERNAME = username;

    UserProvider userProvider =
    Provider.of<UserProvider>(this.context, listen: false);
    userProvider.setName(username ?? "");
    userProvider.setEmail(email ?? "");
    userProvider.setProfilePic(image ?? "");

    SettingProvider settingProvider =
    Provider.of<SettingProvider>(context, listen: false);

    settingProvider.saveUserDetail(id!, username, email, mobile, city, area,
    address, pincode, latitude, longitude, image, context);

    Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
    } else {
    setSnackbar(msg!);
    }
  }
  loginFirebase(name,email)async{
    try {
    UserCredential data =
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: "12345678",
    );
    await FirebaseChatCore.instance.createUserInFirestore(
      types.User(
        firstName: email,
        id: data.user!.uid,
        imageUrl: 'https://i.pravatar.cc/300?u=$email',
        lastName: "",
      ),
    );}catch(e){
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: "12345678",
      );
      // App.localStorage.setString("firebaseUid", credential.user!.uid);
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: name,
          id: credential.user!.uid,
          imageUrl: 'https://i.pravatar.cc/300?u=$email',
          lastName: "",
        ),
      );
    }
  }
  // final fbLogin = FacebookLogin();
  final _firebaseAuth = FirebaseAuth.instance;
  /*Future<UserCredential> signInWithFacebook() async {
    final fb = FacebookLogin();
    final response = await fb.logIn(
        permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]
    );
    switch (response.status) {
      case FacebookLoginStatus.success:
        final accessToken = response.accessToken;
        final userCredential = await _firebaseAuth.signInWithCredential(
          FacebookAuthProvider.credential(accessToken!.token),
        );
        return userCredential;
      case FacebookLoginStatus.cancel:
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      case FacebookLoginStatus.error:
        throw FirebaseAuthException(
          code: 'ERROR_FACEBOOK_LOGIN_FAILED',
          message: response.error!.developerMessage!,
        );
      default:
        throw UnimplementedError();
    }
  }*/
 /* Future signInFB() async {
    final FacebookLoginResult result = await fbLogin.logIn(["email","public_profile"]);
    print(result.errorMessage);
    print(result.status);
    print(result.accessToken);
    final String token = result.accessToken!.token;
    final response = await     get(Uri.parse('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}'));
    final profile = jsonDecode(response.body);
    print(profile);
    return profile;
  }*/
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
    await googleUser?.authentication;
    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    print(googleAuth?.idToken);
    // Once signed in, return the UserCredential
    var data = await FirebaseAuth.instance.signInWithCredential(credential);

    return data;
  }

  _subLogo() {
    return Expanded(
      flex: 4,
      child: Center(
        child: Image.asset(MyAssets.login_logo),
        // child: SvgPicture.asset(
        //   'assets/images/homelogo.svg',
        // ),
      ),
    );
  }

  signInTxt() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 30.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: new Text(
            getTranslated(context, 'SIGNIN_LBL')!,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  setMobileNo() {
    return Container(
      padding: EdgeInsets.only(top: 30),
      width: MediaQuery.of(context).size.width * 0.85,
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.number,
        controller: mobileController,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal,
        ),
        focusNode: monoFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateMob(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.phone_android,
            color: Theme.of(context).colorScheme.fontColor,
            size: 20,
          ),
          hintText: "Mobile Number",
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.gray.withOpacity(0.4),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );

    return Container(
      width: deviceWidth! * 0.7,
      padding: EdgeInsetsDirectional.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.number,
        controller: mobileController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        focusNode: monoFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateMob(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.call_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'MOBILEHINT_LBL'),
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }
  setMobileNo1() {
    return Container(
      padding: EdgeInsets.only(top: 30),
      width: MediaQuery.of(context).size.width * 0.85,
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.number,
        controller: mobileController1,
        style: TextStyle(
          color: Theme.of(context).colorScheme.fontColor,
          fontWeight: FontWeight.normal,
        ),
       // focusNode: monoFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateMob(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.phone_android,
            color: Theme.of(context).colorScheme.fontColor,
            size: 20,
          ),
          hintText: "Mobile Number",
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.gray.withOpacity(0.4),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: 40,
            maxHeight: 20,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
            BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );

    return Container(
      width: deviceWidth! * 0.7,
      padding: EdgeInsetsDirectional.only(
        top: 30.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.number,
        controller: mobileController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        focusNode: monoFocus,
        textInputAction: TextInputAction.next,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (val) => validateMob(
            val!,
            getTranslated(context, 'MOB_REQUIRED'),
            getTranslated(context, 'VALID_MOB')),
        onSaved: (String? value) {
          mobile = value;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.call_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'MOBILEHINT_LBL'),
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          focusedBorder: OutlineInputBorder(
            borderSide:
            BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
            BorderSide(color: Theme.of(context).colorScheme.lightWhite),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }
  setPass() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      padding: EdgeInsets.only(
        top: 15.0,
      ),
      child: TextFormField(
        onFieldSubmitted: (v) {
          FocusScope.of(context).requestFocus(passFocus);
        },
        keyboardType: TextInputType.text,
        obscureText: true,
        controller: passwordController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        focusNode: passFocus,
        textInputAction: TextInputAction.next,
        validator: (val) => validatePass(
            val!,
            getTranslated(context, 'PWD_REQUIRED'),
            getTranslated(context, 'PWD_LENGTH')),
        onSaved: (String? value) {
          password = value;
        },
        decoration: InputDecoration(
          prefixIcon: SvgPicture.asset(
            "assets/images/password.svg",
            color: Theme.of(context).colorScheme.fontColor,
          ),

          // suffixIcon: InkWell(
          //   onTap: () {
          //     // SettingProvider settingsProvider =
          //     // Provider.of<SettingProvider>(this.context, listen: false);
          //     //
          //     // settingsProvider.setPrefrence(ID, id!);
          //     // settingsProvider.setPrefrence(MOBILE, mobile!);

          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => SendOtp(
          //                   title: getTranslated(context, 'FORGOT_PASS_TITLE'),
          //                 )));
          //   },
          //   child: Text(
          //     getTranslated(context, "FORGOT_LBL")!,
          //     style: TextStyle(
          //       color: colors.primary,
          //       fontSize: 12,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          hintText: getTranslated(context, "PASSHINT_LBL")!,
          hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          filled: true,
          fillColor: Theme.of(context).colorScheme.gray.withOpacity(0.4),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          suffixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 20),
          // focusedBorder: OutlineInputBorder(
          //     //   borderSide: BorderSide(color: fontColor),
          //     // borderRadius: BorderRadius.circular(7.0),
          //     ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
            borderRadius: BorderRadius.circular(7.0),
          ),
        ),
      ),
    );
  }

  forgetPass() {
    return Padding(
        padding: EdgeInsetsDirectional.only(start: 25.0, end: 25.0, top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              onTap: () {
                SettingProvider settingsProvider =
                    Provider.of<SettingProvider>(this.context, listen: false);

                settingsProvider.setPrefrence(ID, id!);
                settingsProvider.setPrefrence(MOBILE, mobile!);

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SendOtp(
                              title:
                                  getTranslated(context, 'FORGOT_PASS_TITLE'),
                            )));
              },
              child: Text(getTranslated(context, 'FORGOT_PASSWORD_LBL')!,
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.normal)),
            ),
          ],
        ));
  }

  termAndPolicyTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          bottom: 20.0, start: 25.0, end: 25.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'DONT_HAVE_AN_ACC')!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {
                print("==========");
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => SendOtp(
                    title: getTranslated(context, 'SEND_OTP_TITLE'),
                  ),
                ));
              },
              child: Text(
                getTranslated(context, 'SIGN_UP_LBL')!,
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: colors.secondary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }

  loginBtn() {
    return AppBtn(
      title: getTranslated(context, 'SIGNIN_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        setPrefrenceBool(ISFIRSTTIME, true);
        validateAndSubmit();
      },
    );
  }

  _expandedBottomView() {
    return Expanded(
      flex: 6,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsetsDirectional.only(
                      start: 20.0, end: 10.0, top: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      signInTxt(),
                      setMobileNo(),
                      setPass(),
                      forgetPass(),
                      Text("sdf"),
                      InkWell(
                        onTap: () {
                          // SettingProvider settingsProvider =
                          // Provider.of<SettingProvider>(this.context, listen: false);
                          //
                          // settingsProvider.setPrefrence(ID, id!);
                          // settingsProvider.setPrefrence(MOBILE, mobile!);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SendOtp(
                                        title: getTranslated(
                                            context, 'FORGOT_PASS_TITLE'),
                                      )));
                        },
                        child: Text(
                          getTranslated(context, "FORGOT_LBL")!,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      loginBtn(),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mysize = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? SafeArea(
                child: Container(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/login_option_bg.png',
                            height: mysize.height / 4,
                            width: mysize.width,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            transform: Matrix4.translationValues(
                                0.0, -mysize.height / 20, 0.0),
                            child: Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 25,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: 10,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: mysize.width / 11,
                                width: mysize.width / 11,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                        transform: Matrix4.translationValues(
                            0.0, -mysize.height / 10, 0.0),
                        child: getLoginContainer(),
                      ),
                      termAndPolicyTxt(),
                      // Column(children: [

                      // ],)
                    ],
                  ),
                ),
              )
            // ? Stack(
            //     children: [
            //       Container(
            //         width: double.infinity,
            //         height: double.infinity,
            //         decoration: back(),
            //       ),
            //       Image.asset(
            //         'assets/images/doodle.png',
            //         fit: BoxFit.fill,
            //         width: double.infinity,
            //         height: double.infinity,
            //       ),
            //       getLoginContainer(),
            //       getLogo(),
            //     ],
            //   )
            : noInternet(context));
  }

  getLoginContainer() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Theme.of(context).colorScheme.white,
      ),
      // height: MediaQuery.of(context).size.height * 0.7,
      width: MediaQuery.of(context).size.width * 0.95,
      child: Form(
        key: _formkey,
        child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // mainAxisSize: MainAxisSize.min,
            children: [
              // SizedBox(
              //   height: MediaQuery.of(context).size.height * 0.10,
              // ),
              // setSignInLabel(),
              setMobileNo(),
              setPass(),
              InkWell(
                onTap: () {
                  // SettingProvider settingsProvider =
                  // Provider.of<SettingProvider>(this.context, listen: false);
                  //
                  // settingsProvider.setPrefrence(ID, id!);
                  // settingsProvider.setPrefrence(MOBILE, mobile!);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SendOtp(
                                title:
                                    getTranslated(context, 'FORGOT_PASS_TITLE'),
                              )));
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  alignment: Alignment.centerRight,
                  child: Text(
                    getTranslated(context, "FORGOT_PASSWORD_LBL")!,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              loginBtn(),
              // Text("sdd"),
              SizedBox(height: 2.h,),
             //  Center(
             //    child: Container(
             //      child: Row(
             //        mainAxisAlignment: MainAxisAlignment.center,
             //        children: [
             //          Container(
             //              width: 15.86.w,
             //              child: Divider(
             //                color: Theme.of(context).colorScheme.fontColor,
             //              )),
             //          SizedBox(
             //            width: 2.w,
             //          ),
             //          Text(
             //            'OR',
             //            style: TextStyle(
             //              fontSize: 25,
             //              color: Theme.of(context).colorScheme.fontColor,
             //              fontWeight: FontWeight.w600,
             //            ),
             //          ),
             //          SizedBox(
             //            width: 2.w,
             //          ),
             //          Container(
             //              width: 15.86.w,
             //              child: Divider(
             //                color: Theme.of(context).colorScheme.fontColor,
             //              )),
             //        ],
             //      ),
             //    ),
             //  ),
             //  SizedBox(height: 2.h,),
             //  Container(
             // /*   height: 10.h,
             //    width: 42.w,*/
             //    child: Row(
             //      mainAxisSize: MainAxisSize.min,
             //      children: [
             //      /*  InkWell(
             //          onTap:(){
             //            loginFb();
             //  },
             //          child: Image.asset(
             //            "assets/logo/fb.png",
             //            width: 8.h,
             //            height: 8.h,
             //          ),
             //        ),
             //        SizedBox(width: 5.w,),*/
             //        InkWell(
             //          onTap: (){
             //            setPrefrenceBool(ISFIRSTTIME, true);
             //            googleLogin();
             //          },
             //          child: Image.asset(
             //            "assets/logo/google.png",
             //            width: 8.h,
             //            height: 8.h,
             //          ),
             //        ),
             //      ],
             //    ),
             //  ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      // textDirection: Directionality.of(context),
      left: (MediaQuery.of(context).size.width / 2) - 50,
      // right: ((MediaQuery.of(context).size.width /2)-55),

      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      //  bottom: height * 0.1,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.asset(MyAssets.login_logo),
        // child: SvgPicture.asset(
        //   'assets/images/loginlogo.svg',
        // ),
      ),
    );
  }

  Widget setSignInLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, 'SIGNIN_LBL')!,
          style: const TextStyle(
            color: colors.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
