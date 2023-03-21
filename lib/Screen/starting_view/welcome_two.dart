import 'package:entemarket_user/Helper/Session.dart';
import 'package:entemarket_user/Helper/String.dart';
import 'package:entemarket_user/Helper/app_assets.dart';
import 'package:entemarket_user/Screen/SignInUpAcc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class WelcomeTwoView extends StatelessWidget {
  const WelcomeTwoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mysize = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
              SizedBox(
                height: mysize.height / 10,
              ),
              Image.asset(
                MyAssets.normal_logo,
                height: mysize.height / 7,
              ),
              SizedBox(
                height: mysize.height / 20,
              ),
              Image.asset(
                'assets/images/welcome_2_shop.png',
                height: mysize.height / 3,
                fit: BoxFit.contain,
                width: mysize.width,
              ),
              SizedBox(
                height: mysize.height / 30,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: mysize.width / 10),
                child: Text(
                  "Welcome To Entemarket",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                height: mysize.height / 40,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: mysize.width / 10),
                child: Text(
                  "Entemarket.com is a multivendor on-demand marketplace. Our services include the buying and selling of - Groceries, Food,  Pet supplies, Electronics, Furniture, Gifts, Fashion and more.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w400),
                ),
              ),
              SizedBox(
                height: mysize.height / 40,
              ),
              InkWell(
                onTap: () => onTapNevigtion(context),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/button.png',
                      height: mysize.height / 12,
                    ),
                    Positioned(
                      left: 10,
                      // right: 5,
                      child: Text(
                        'Get started',
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  onTapNevigtion(context) {
    setPrefrenceBool(ISFIRSTTIME, true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInUpAcc()),
    );
  }
}
