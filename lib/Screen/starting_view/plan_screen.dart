import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:entemarket_user/Helper/ApiBaseHelper.dart';
import 'package:entemarket_user/Helper/Razorpay.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:http/http.dart' as http;

import '../../Helper/Session.dart';
import '../../Helper/String.dart';
import '../../Helper/my_new_helper.dart';
import '../../Model/plan_model.dart';

class PlanScreen extends StatefulWidget {
  final String? name, id;
  // final bool? tag, fromSeller;
  // final int? dis;

  const PlanScreen(
      {Key? key, this.id, this.name})
      : super(key: key);


  @override
  _PlanScreenState createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  bool isSwitched = false;
  List<PlanModel> planList = [];
  List<PlanModel> currentList = [];
  String? start, end;
  bool _isNetworkAvail = true, loading = true;
  Future<Null> getPlan() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {

      setState(() {
        planList.clear();
      });
      var response = await http
          .get(Uri.parse("https://entemarket.com/app/v1/api/get_customer_plan"));

      Map data = jsonDecode(response.body);
      bool error = data["error"];
      String? msg = data["message"];
      setState(() {
        loading = false;
      });
      if (!error) {
        for (var v in data["data"]) {
          setState(() {
            planList.add(new PlanModel(
                v['id'],
                v['name'],
                "",
                "",
                v['image'],
                v['price'],
                v['deliverycharge'],
                "",
                "",
               "",
                "","",""));
          });
        }
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          loading = false;
        });
    }

    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPlan();
    getCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getSimpleAppBar(widget.name!, context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            width: deviceWidth,
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              children: [
                Container(
                  height: 80.h,
                  margin: EdgeInsets.only(top: 1.87.h),
                  alignment: Alignment.center,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 70.h,
                      viewportFraction: 0.8,
                      enableInfiniteScroll: false,
                    ),
                    items: planList.map((e) {
                      return Container(
                        width: 80.w,
                        decoration: boxDecoration(
                          radius: 10.0,
                          showShadow: true,
                          bgColor: Theme.of(context).cardColor,
                        ),
                        margin: EdgeInsets.only(bottom: 5.w, right: 5.w),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: new LinearGradient(
                                      colors: [
                                        Color(0xff8B7C3E),
                                        Color(0xffFDF188),
                                        Color(0xffA68E46),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.w, vertical: 2.h),
                                  child: text(getString(e.name),
                                      fontFamily: fontBold,
                                      fontSize: 14.sp,
                                      textColor: Color(0xffA26F15))),
                              CachedNetworkImage(
                                imageUrl: e.image,
                                height: 50.w,
                                width: 80.w,
                                fit: BoxFit.fill,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                              ),
                              Divider(),
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.w, vertical: 1.h),
                                  child: Column(
                                    children: [
                                      text("Delivery Charges",
                                          fontSize: 14.sp,
                                          fontFamily: fontRegular,
                                          textColor: Color(0xff000000)),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      text("₹${e.deliverycharge}",
                                          fontSize: 10.sp,
                                          fontFamily: fontMedium,
                                          textColor: Color(0xff828282)),
                                    ],
                                  )),
                              Divider(),
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.w, vertical: 1.h),
                                  child: Column(
                                    children: [
                                      text("Price",
                                          fontSize: 14.sp,
                                          fontFamily: fontRegular,
                                          textColor: Color(0xff000000)),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      text("₹${e.deliverycharge}",
                                          fontSize: 10.sp,
                                          fontFamily: fontMedium,
                                          textColor: Color(0xff828282)),
                                    ],
                                  )),
                              currentList.length>0&&currentList[currentList.length-1].plan_id==e.id?Divider():SizedBox(),
                              currentList.length>0&&currentList[currentList.length-1].plan_id==e.id?Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.w, vertical: 1.h),
                                  child: Column(
                                    children: [
                                      text("Expiry On",
                                          fontSize: 14.sp,
                                          fontFamily: fontRegular,
                                          textColor: Color(0xff000000)),
                                      SizedBox(
                                        height: 1.h,
                                      ),
                                      text("${currentList[0].end_date}",
                                          fontSize: 10.sp,
                                          fontFamily: fontMedium,
                                          textColor: Color(0xff828282)),
                                    ],
                                  )):SizedBox(),
                              InkWell(
                                onTap: (){
                                  if(currentList.length>0&&currentList[currentList.length-1].status=="0"){
                                    setSnackbar("Already Activated", context);
                                    return;
                                  }
                                  RazorPayHelper razorHelper = new RazorPayHelper(
                                      e.price,
                                      context,
                                      (result) {
                                        if(result!="error"){
                                          addPlan(e.id,e.price);
                                        }
                                  });
                                  razorHelper.init();
                                },
                                child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: new LinearGradient(
                                        colors: [
                                          Color(0xff8B7C3E),
                                          Color(0xffFDF188),
                                          Color(0xffA68E46),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5.w, vertical: 2.h),
                                    child: text(currentList.length>0&&currentList[currentList.length-1].plan_id==e.id?"Activated":"BUY",
                                        fontFamily: fontBold,
                                        fontSize: 14.sp,
                                        textColor: Color(0xffA26F15))),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<Null> addPlan(id,price) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      var parameter = {"user_id": CUR_USERID,"plan_id":id,'amount':price};
      apiBaseHelper.postAPICall(Uri.parse("https://entemarket.com/app/v1/api/purchase_plan_cust"), parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          print(getdata);
          if (!error) {
            getCurrent();
            setSnackbar(msg!, context);
          }
        },
        onError: (error) {
          setSnackbar(error.toString(),context);
        },
      );
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;

        });
    }

    return null;
  }
  Future<Null> getCurrent() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setState(() {
        currentList.clear();
      });
      var parameter = {"user_id": CUR_USERID!};
      apiBaseHelper.postAPICall(Uri.parse("https://entemarket.com/app/v1/api/get_plan_purchasebyuser"), parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          print(getdata);
          if (!error) {
            for (var v in getdata["data"]) {
              setState(() {
                currentList.add(new PlanModel(
                    v['id'],
                    v['name'],
                    v['plan_id'],
                    v['user_id'],
                    "https://entemarket.com/"+v['image'],
                    v['price'],
                    v['deliverycharge'],
                    "",
                    "",
                    "",
                    "",v['start_date'],v['end_date']));
              });
            }
          }
        },
        onError: (error) {
          setSnackbar(error.toString(),context);
        },
      );
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;

        });
    }

    return null;
  }
}
