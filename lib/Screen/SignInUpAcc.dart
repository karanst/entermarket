import 'package:entemarket_user/Helper/Session.dart';
import 'package:entemarket_user/Helper/String.dart';
import 'package:entemarket_user/Helper/app_assets.dart';
import 'package:entemarket_user/Screen/Dashboard.dart';
import 'package:entemarket_user/Screen/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Helper/Color.dart';
import 'SendOtp.dart';

class SignInUpAcc extends StatefulWidget {
  @override
  _SignInUpAccState createState() => new _SignInUpAccState();
}

class _SignInUpAccState extends State<SignInUpAcc> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    super.initState();
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   statusBarIconBrightness: Brightness.light,
    // ));
    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarBrightness: Brightness.dark,
    //   ),
    // );
  }

  _subLogo() {
    return Image.asset(
      MyAssets.normal_logo,
      height: 80,
    );
  }

  welcomeEshopTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0),
      child: new Text(
        getTranslated(context, 'WELCOME_ESHOP')!,
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  eCommerceforBusinessTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 5.0,
      ),
      child: new Text(
        getTranslated(context, 'ECOMMERCE_APP_FOR_ALL_BUSINESS')!,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  signInyourAccTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 10.0, bottom: 20),
      child: new Text(
        getTranslated(context, 'SIGNIN_ACC_LBL')!,
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  signInBtn() {
    return Container(
        width: deviceWidth! * 0.8,
        height: 45,
        alignment: FractionalOffset.center,
        decoration: new BoxDecoration(
          color: colors.primary,
          // gradient: LinearGradient(
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //     colors: [colors.grad1Color, colors.grad2Color],
          //     stops: [0, 1]),
          borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        ),
        child: Text(getTranslated(context, 'SIGNIN_LBL')!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: colors.whiteTemp, fontWeight: FontWeight.normal)));
  }

  createAccBtn() {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => SendOtp(
            title: getTranslated(context, 'SEND_OTP_TITLE'),
          ),
        ));
      },
      child: Container(
          width: deviceWidth! * 0.8,
          height: 45,
          margin: const EdgeInsets.symmetric(vertical: 20),
          alignment: FractionalOffset.center,
          decoration: new BoxDecoration(
            color: colors.primary,
            // gradient: LinearGradient(
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomRight,
            //     colors: [colors.grad1Color, colors.grad2Color],
            //     stops: [0, 1]),
            borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
          ),
          child: Text(getTranslated(context, 'CREATE_ACC_LBL')!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                  color: colors.whiteTemp, fontWeight: FontWeight.normal))),
    );
  }

  skipSignInBtn() {
    return Container(
        width: deviceWidth! * 0.8,
        height: 45,
        alignment: FractionalOffset.center,
        decoration: new BoxDecoration(
          color: colors.primary,
          // gradient: LinearGradient(
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //     colors: [colors.grad1Color, colors.grad2Color],
          //     stops: [0, 1]),
          borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        ),
        child: Text(getTranslated(context, 'SKIP_SIGNIN_LBL')!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: colors.whiteTemp, fontWeight: FontWeight.normal)));
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    var mysize = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
            color: Theme.of(context).colorScheme.lightWhite,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/login_option_bg.png',
                      width: mysize.width,
                      fit: BoxFit.cover,
                      height: mysize.height / 5,
                    ),
                    Image.asset(
                      MyAssets.white_logo,
                      height: mysize.height / 10,
                    )
                  ],
                ),
                // new
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: mysize.height / 60,
                  ),
                  child: const Text(
                    'Get The Full Experience',
                    style: TextStyle(
                        color: colors.secondary,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: mysize.width * 0.06),
                  child: const Text(
                    'In order to use Entemarket app, simply select from the options below. Happy shopping !\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // signInyourAccTxt(),
                InkWell(
                  onTap: () => onTapGoNextSignIN(),
                  child: signInBtn(),
                ),
                createAccBtn(),
                InkWell(
                  onTap: () => onTapGoNextHome(),
                  child: skipSignInBtn(),
                )
              ],
            )),
      ),
    ));
    // child: Center(
    //     child: SingleChildScrollView(
    //         child: Column(
    //   mainAxisAlignment: MainAxisAlignment.start,
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   // mainAxisSize: MainAxisSize.min,
    //   children: <Widget>[
    //     Image.asset(
    //       'assets/images/login_option_bg.png',
    //       width: mysize.width,
    //       // height: mysize.height / 5,
    //       fit: BoxFit.cover,
    //     ),
    //     _subLogo(),
    //     welcomeEshopTxt(),
    //     eCommerceforBusinessTxt(),
    // signInyourAccTxt(),
    // signInBtn(),
    // createAccBtn(),
    // skipSignInBtn(),
    //   ],
    // )))
  }

  onTapGoNextSignIN() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }

  onTapGoNextHome() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const Dashboard()));
  }
}
