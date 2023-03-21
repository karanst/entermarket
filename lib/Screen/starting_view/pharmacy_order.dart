import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:entemarket_user/Helper/AppBtn.dart';
import 'package:entemarket_user/Helper/SimBtn.dart';
import 'package:entemarket_user/Provider/CartProvider.dart';
import 'package:entemarket_user/Provider/FavoriteProvider.dart';
import 'package:entemarket_user/Provider/UserProvider.dart';
import 'package:entemarket_user/Screen/Cart.dart';
import 'package:entemarket_user/Screen/HomePage.dart';
import 'package:entemarket_user/Screen/Login.dart';
import 'package:entemarket_user/Screen/Manage_Address.dart';
import 'package:entemarket_user/Screen/Product_Detail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;
import '../../Helper/Color.dart';
import '../../Helper/Constant.dart';
import '../../Helper/Session.dart';
import '../../Helper/String.dart';
import '../../Model/Section_Model.dart';
import '../../Model/User.dart';
import '../../Model/vendor_model.dart';
import '../../Provider/SettingProvider.dart';
import '../Add_Address.dart';

class PharmacyOrder extends StatefulWidget {
  final String? name, id;
  // final bool? tag, fromSeller;
  // final int? dis;

  const PharmacyOrder(
      {Key? key, this.id, this.name})
      : super(key: key);
/*  const PharmacyOrder(
      {Key? key, this.id, this.name, this.tag, this.fromSeller, this.dis})
      : super(key: key);*/
  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<PharmacyOrder> with TickerProviderStateMixin {
  bool _isLoading = true, _isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<PharmacyOrderModel> orderList = [];
  List<PharmacyOrderModel> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  int offset = 0;
  int total = 0;

//List<SectionModel> cartList = [];
  List<Promo> promoList = [];
  double totalPrice = 0, oriPrice = 0, delCharge = 0, taxPer = 0;
  int? selectedAddress = 0;
  String? selAddress, payMethod = '', selTime, selDate, promocode;
  String? totalProduct;
  bool isLoadingmore = true;
  ScrollController controller = new ScrollController();
  var filterList;
  String minPrice = "0", maxPrice = "0";
  List<String>? attnameList;
  List<String>? attsubList;
  List<String>? attListId;
  bool _isNetworkAvail = true;
  List<String> selectedId = [];
  bool _isFirstLoad = true;

  String selId = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool listType = true;
  List<TextEditingController> _controller = [];
  List<String>? tagList = [];
  ChoiceChip? tagChip, choiceChip;
  RangeValues? _currentRangeValues;

  // late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    controller.addListener(_scrollListener);
    getOrder("0");

    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);
    //_getAddress();
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

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getOrder("0");
          });
      }
    }
  }

  @override
  void dispose() {
    buttonController!.dispose();
    controller.removeListener(() {});
    for (int i = 0; i < _controller.length; i++) _controller[i].dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  @override
  Widget build(BuildContext context) {
    // userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
        appBar: getSimpleAppBar("Pharmacy Order", context,show: "data"),
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? _isLoading
            ? shimmer(context)
            : Stack(
          children: <Widget>[
            _showForm(context),
            showCircularProgress(_isProgress, colors.primary),
          ],
        )
            : noInternet(context));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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
                  offset = 0;
                  total = 0;
                  getOrder("0");
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

  noIntBtn(BuildContext context) {
    double width = deviceWidth!;
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: 10.0, top: 50.0),
        child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: colors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => super.widget));
              },
              child: Ink(
                child: Container(
                  constraints: BoxConstraints(maxWidth: width / 1.2, minHeight: 45),
                  alignment: Alignment.center,
                  child: Text(getTranslated(context, 'TRY_AGAIN_INT_LBL')!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Theme.of(context).colorScheme.white,
                          fontWeight: FontWeight.normal)),
                ),
              ),
            )));
  }

  Widget listItem(int index) {
    if (index < orderList.length) {
      PharmacyOrderModel model = orderList[index];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                child: Stack(children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Hero(
                          tag: "ProList$index${model.id}",
                          child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10)),
                              child: Stack(
                                children: [
                                  FadeInImage(
                                    image: CachedNetworkImageProvider(
                                        image_url+model.image),
                                    height: 125.0,
                                    width: 135.0,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                        erroWidget(125),
                                    placeholder: placeHolder(125),
                                  ),
                                ],
                              ))),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                model.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Order ID #"+model.id,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 10,),
                              Text(
                               model.phone,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 10,),
                              Text(
                                model.address,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightBlack),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ]),
                onTap: () {
                },
              ),
            ),
          ],
        ),
      );
    } else
      return Container();
  }
  TextEditingController mobileCon = new TextEditingController();
  TextEditingController emailCon = new TextEditingController();
  TextEditingController nameCon = new TextEditingController();
  TextEditingController desCon = new TextEditingController();

  void formDialog(id) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              checkoutState = setState;
              return Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9),
                child: Scaffold(
                  key: _checkscaffoldKey,
                  body:  SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Padding(
                                padding:
                                EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                                child: Text(
                                  //getTranslated(context, 'SORT_BY')!,
                                  "Add Details",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme.lightBlack),
                                )),
                          ),
                          SizedBox(height: 20,),
                          Container(width: deviceWidth!*0.95,child: address(),),
                          SizedBox(height: 10,),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: getUserImage("", _imgFromGallery),
                          ),
                          Center(
                            child: Padding(
                                padding:
                                EdgeInsetsDirectional.only(top: 10.0, bottom: 16.0),
                                child: Text(
                                  //getTranslated(context, 'SORT_BY')!,
                                  "Prescription Image",
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme.lightBlack),
                                )),
                          ),
                          Container(
                            width: deviceWidth!*0.95,
                            child: TextFormField(
                              controller: nameCon,
                              keyboardType: TextInputType.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme.lightBlack) ,
                              decoration: InputDecoration(
                                filled: false,
                                label: Text("Full Name", style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme.lightBlack),),
                              ),
                            ),
                          ),
                          SizedBox(height:10),
                          Container(
                            width: deviceWidth!*0.95,
                            child: TextFormField(
                              controller: emailCon,
                              keyboardType: TextInputType.emailAddress,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme.lightBlack) ,
                              decoration: InputDecoration(
                                filled: false,
                                label: Text("Email Address",style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme.lightBlack),),
                              ),
                            ),
                          ),
                          SizedBox(height:10),
                          Container(
                            width: deviceWidth!*0.95,
                            child: TextFormField(
                              controller: mobileCon,
                              maxLength: 10,
                              keyboardType: TextInputType.phone,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme.lightBlack) ,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp("[0-9-]")),
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                filled: false,
                                counterText: "",
                                label: Text("Mobile Number",style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme.lightBlack),),
                              ),
                            ),
                          ),
                          SizedBox(height:10),
                          Container(
                            width: deviceWidth!*0.95,
                            child: TextFormField(
                              controller: desCon,
                              keyboardType: TextInputType.text,
                              minLines: 5,
                              maxLines: 5,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme.lightBlack) ,
                              decoration: InputDecoration(
                                filled: false,
                                alignLabelWithHint: true,
                                label: Text("Description",style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme.lightBlack),),
                              ),
                            ),
                          ),
                          SizedBox(height:20),
                          !loading?saveButton(getTranslated(context, "SAVE_LBL")!, () {
                            if (validateField(nameCon.text, "Please Enter Full Name") !=
                                null) {
                              setSnackbar1("Please Enter Full Name", _checkscaffoldKey);
                              return;
                            }
                            if (validateEmail(emailCon.text, "Please Enter Email",
                                "Please Enter Valid Email") !=
                                null) {
                              setSnackbar1(
                                  validateEmail(emailCon.text, "Please Enter Email",
                                      "Please Enter Valid Email")
                                      .toString(),
                                  _checkscaffoldKey);
                              return;
                            }
                            if (validateMob(
                                mobileCon.text,
                                "Please Enter Mobile Number",
                                "Please Enter Valid Mobile Number") !=
                                null) {
                              setSnackbar1(
                                  validateMob(
                                      mobileCon.text,
                                      "Please Enter Mobile Number",
                                      "Please Enter Valid Mobile Number")
                                      .toString(),
                                  _checkscaffoldKey);
                              return;
                            }
                            if(image==null){
                              setSnackbar1(
                                  "Please Add Prescription Image",
                                  _checkscaffoldKey);
                              return;
                            }
                            setState((){
                              loading = true;
                            });
                            setProfilePic(image, id);
                          }):CircularProgressIndicator(),
                          SizedBox(height: 10,),
                        ]),
                  ),
                ),
              );
            });
      },
    );
  }
  bool loading = false;
  Widget getUserImage(String profileImage, VoidCallback? onBtnSelected) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (mounted) {
              onBtnSelected!();
            }
          },
          child: Container(
            margin: EdgeInsetsDirectional.only(end: 20),
            height: 132,
            width: 132,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    width: 1.0, color: Theme.of(context).colorScheme.white)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: image != null
                  ? new FadeInImage(
                fadeInDuration: Duration(milliseconds: 150),
                image:
                FileImage(image),
                height: 96.0,
                width: 96.0,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) =>
                    erroWidget(64),
                placeholder: placeHolder(96),
              )
                  : imagePlaceHolder(96, context),
            ),
          ),
        ),
        /*CircleAvatar(
      radius: 40,
      backgroundColor: colors.primary,
      child: profileImage != ""
          ? ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: FadeInImage(
                fadeInDuration: Duration(milliseconds: 150),
                image: NetworkImage(profileImage),
                height: 100.0,
                width: 100.0,
                fit: BoxFit.cover,
                placeholder: placeHolder(100),
                imageErrorBuilder: (context, error, stackTrace) =>
                    erroWidget(100),
              ))
          : Icon(
              Icons.account_circle,
              size: 80,
              color: Theme.of(context).colorScheme.white,
            ),
    ),*/
        if (CUR_USERID != null)
          Positioned.directional(
              textDirection: Directionality.of(context),
              end: 20,
              bottom: 20,
              child: Container(
                height: 20,
                width: 20,
                child: InkWell(
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.white,
                    size: 10,
                  ),
                  onTap: () {
                    if (mounted) {
                      onBtnSelected!();
                    }
                  },
                ),
                decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                    border: Border.all(color: colors.primary)),
              )),
      ],
    );
  }
  var image;
  void _imgFromGallery() async {
    var result = await FilePicker.platform.pickFiles();
    if (result != null) {
      checkoutState!(() {
        loading=false;
        image = File(result.files.single.path!);
      });
      if (mounted) {
        //   await setProfilePic(image);
      }
    } else {
      // User canceled the picker
    }
  }

  Future<void> setProfilePic(File _image,String id) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var image;
        var request = http.MultipartRequest("POST", (getUpdatePreApi));
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID!;
        request.fields["name"] = nameCon.text;
        request.fields["email"] = emailCon.text;
        request.fields["phone"] = mobileCon.text;
        request.fields["description"] = desCon.text;
        request.fields["seller_id"] = id;
        request.fields["address"] = addressList[selectedAddress!].address! +
            ", " +
            addressList[selectedAddress!].area! +
            ", " +
            addressList[selectedAddress!].city! +
            ", " +
            addressList[selectedAddress!].state! +
            ", " +
            addressList[selectedAddress!].country! +
            ", " +
            addressList[selectedAddress!].pincode!;
        var pic = await http.MultipartFile.fromPath("file", _image.path);
        request.files.add(pic);
        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String? msg = getdata['message'];
        print("msg :$msg");
        print(
            " detail : ${pic.field}, ${pic.length} , ${pic.filename} , ${pic.contentType} , ${pic.toString()}");
        if (!error) {
          checkoutState!((){
            loading =false;
          });
          Navigator.pop(context);
          setSnackbar(msg!,context);
        } else {
          checkoutState!((){
            loading =false;
          });
          setSnackbar(msg!,context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!,context);
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  Widget saveButton(String title, VoidCallback? onBtnSelected) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: MaterialButton(
              height: 45.0,
              textColor: Theme.of(context).colorScheme.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              onPressed: onBtnSelected,
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }

  bool deliverable = false;
  address() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.location_on),
                Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0),
                    child: Text(
                      getTranslated(context, 'SHIPPING_DETAIL') ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.fontColor),
                    )),
              ],
            ),
            Divider(),
            addressList.length > 0
                ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child:
                          Text(addressList[selectedAddress!].name!)),
                      InkWell(
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            getTranslated(context, 'CHANGE')!,
                            style: TextStyle(
                              color: colors.primary,
                            ),
                          ),
                        ),
                        onTap: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ManageAddress(
                                        home: false,
                                      )));

                          checkoutState!(() {
                            deliverable = false;
                          });
                        },
                      ),
                    ],
                  ),
                  Text(
                    addressList[selectedAddress!].address! +
                        ", " +
                        addressList[selectedAddress!].area! +
                        ", " +
                        addressList[selectedAddress!].city! +
                        ", " +
                        addressList[selectedAddress!].state! +
                        ", " +
                        addressList[selectedAddress!].country! +
                        ", " +
                        addressList[selectedAddress!].pincode!,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Text(
                          addressList[selectedAddress!].mobile!,
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .lightBlack),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
                : Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0),
              child: GestureDetector(
                child: Text(
                  getTranslated(context, 'ADDADDRESS')!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                  ),
                ),
                onTap: () async {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddAddress(
                          update: false,
                          index: addressList.length,
                        )),
                  );
                  if (mounted) setState(() {});
                },
              ),
            )
          ],
        ),
      ),
    );
  }
  StateSetter? checkoutState;
  final GlobalKey<ScaffoldMessengerState> _checkscaffoldKey =
  new GlobalKey<ScaffoldMessengerState>();
  Future<void> _getAddress() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
        };
        Response response =
        await post(getAddressApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          // String msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            addressList = (data as List)
                .map((data) => new User.fromAddress(data))
                .toList();

            if (addressList.length == 1) {
              selectedAddress = 0;
              selAddress = addressList[0].id;
              if (!ISFLAT_DEL) {
                if (totalPrice < double.parse(addressList[0].freeAmt!))
                  delCharge = double.parse(addressList[0].deliveryCharge!);
                else
                  delCharge = 0;
              }
            } else {
              for (int i = 0; i < addressList.length; i++) {
                if (addressList[i].isDefault == "1") {
                  selectedAddress = i;
                  selAddress = addressList[i].id;
                  if (!ISFLAT_DEL) {
                    if (totalPrice < double.parse(addressList[i].freeAmt!))
                      delCharge = double.parse(addressList[i].deliveryCharge!);
                    else
                      delCharge = 0;
                  }
                }
              }
            }

            if (ISFLAT_DEL) {
              if ((oriPrice) < double.parse(MIN_AMT!))
                delCharge = double.parse(CUR_DEL_CHR!);
              else
                delCharge = 0;
            }
            totalPrice = totalPrice + delCharge;
          } else {
            if (ISFLAT_DEL) {
              if ((oriPrice) < double.parse(MIN_AMT!))
                delCharge = double.parse(CUR_DEL_CHR!);
              else
                delCharge = 0;
            }
            totalPrice = totalPrice + delCharge;
          }
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }

          if (checkoutState != null) checkoutState!(() {});
        } else {
          setSnackbar1(
              getTranslated(context, 'somethingMSg')!, _checkscaffoldKey);
          if (mounted)
            setState(() {
              _isLoading = false;
            });
        }
      } on TimeoutException catch (_) {}
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }
  setSnackbar1(
      String msg, GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      duration: Duration(seconds: 1),
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }
  String image_url = "";
  void getOrder(String top) {
    var parameter = {
      USER_ID: CUR_USERID,
    };
    print("okay"+widget.id.toString());
    //  if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

    //if (widget.dis != null) parameter[DISCOUNT] = widget.dis.toString();

    apiBaseHelper.postAPICall(getPharmacyOrderApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      image_url = getdata["image_url"];
      if (!error) {
        tempList.clear();

        var data = getdata["data"];
        for(var v in data){
          tempList.add(new PharmacyOrderModel.fromJson(v));
        }

        if (getdata.containsKey(TAG)) {
          List<String> tempList = List<String>.from(getdata[TAG]);
          if (tempList != null && tempList.length > 0) tagList = tempList;
        }
        orderList.addAll(tempList);
        print(orderList.length);
        offset = offset + perPage;
      } else {
        isLoadingmore = false;
        if (msg != "Products Not Found !") setSnackbar(msg!, context);
      }

      setState(() {
        _isLoading = false;
      });
      // context.read<orderListProvider>().setProductLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      setState(() {
        _isLoading = false;
      });
      //context.read<orderListProvider>().setProductLoading(false);
    });
  }



  _showForm(BuildContext context) {
    return /*RefreshIndicator(
        key: _refreshIndicatorKey,
        //onRefresh: _refresh,
        child: */
      Column(
        children: [
          Expanded(
            child: orderList.length == 0
                ? getNoItem(context)
                : ListView.builder(
              controller: controller,
              itemCount: (offset < total)
                  ? orderList.length + 1
                  : orderList.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return (index == orderList.length && isLoadingmore)
                    ? singleItemSimmer(context)
                    : listItem(index);
              },
            ),),
        ],
      );
  }

}
