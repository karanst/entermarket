import 'dart:async';

import 'package:entemarket_user/Helper/app_assets.dart';
import 'package:entemarket_user/Helper/my_new_helper.dart';
import 'package:entemarket_user/Screen/starting_view/welcome_two.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Helper/String.dart';
import '../../Provider/SettingProvider.dart';

class WelcomeOneView extends StatefulWidget {
  const WelcomeOneView({Key? key}) : super(key: key);

  @override
  State<WelcomeOneView> createState() => _WelcomeOneViewState();
}

class _WelcomeOneViewState extends State<WelcomeOneView> {
  @override
  void initState() {
    super.initState();

    timar();
  }

  @override
  Widget build(BuildContext context) {
    var mysize = MediaQuery.of(context).size;
    deviceWidth =MediaQuery.of(context).size.width;
    deviceHeight =MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: mysize.height / 20,
              ),
              Image.asset(
                MyAssets.normal_logo,
                height: mysize.height / 8,
              ),
              SizedBox(
                height: mysize.height / 20,
              ),
              Image.asset(
                'assets/images/welcom_banner_img.png',
                height: mysize.height / 5,
                fit: BoxFit.contain,
                width: mysize.width,
              ),
              SizedBox(
                height: mysize.height / 50,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: mysize.width / 10),
                child: Text(
                  "Welcome To Kerala's Largest Online Shopping Arcade",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600,color: Colors.black),
                ),
              ),
              SizedBox(
                height: mysize.height / 50,
              ),
              Image.asset(
                'assets/images/social_login.png',
                height: mysize.height / 10,
              )
            ],
          ),
          width: mysize.width,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/welcome_one_bg.png'),
                  fit: BoxFit.cover)),
        ),
      ),
    );
  }

  void timar() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      Timer(Duration(seconds: 2), () async {
     navigationPage();
      });
    });
  }
  Future<void> navigationPage() async {
    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(this.context, listen: false);

    bool isFirstTime = await settingsProvider.getPrefrenceBool(ISFIRSTTIME);
    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => WelcomeTwoView()));
    }
  }

}
