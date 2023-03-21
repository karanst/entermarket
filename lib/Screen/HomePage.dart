import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:entemarket_user/Helper/ApiBaseHelper.dart';
import 'package:entemarket_user/Helper/AppBtn.dart';
import 'package:entemarket_user/Helper/Color.dart';
import 'package:entemarket_user/Helper/Constant.dart';
import 'package:entemarket_user/Helper/Session.dart';
import 'package:entemarket_user/Helper/SimBtn.dart';
import 'package:entemarket_user/Helper/String.dart';
import 'package:entemarket_user/Helper/app_assets.dart';
import 'package:entemarket_user/Helper/location_details.dart';
import 'package:entemarket_user/Model/HealthCategoryModel.dart';
import 'package:entemarket_user/Model/Model.dart';
import 'package:entemarket_user/Model/Section_Model.dart';
import 'package:entemarket_user/Model/city_model.dart';
import 'package:entemarket_user/Provider/CartProvider.dart';
import 'package:entemarket_user/Provider/CategoryProvider.dart';
import 'package:entemarket_user/Provider/FavoriteProvider.dart';
import 'package:entemarket_user/Provider/HomeProvider.dart';
import 'package:entemarket_user/Provider/SettingProvider.dart';
import 'package:entemarket_user/Provider/UserProvider.dart';
import 'package:entemarket_user/Screen/NotificationLIst.dart';
import 'package:entemarket_user/Screen/Search.dart';
import 'package:entemarket_user/Screen/SellerList.dart';
import 'package:entemarket_user/Screen/Seller_Details.dart';
import 'package:entemarket_user/Screen/starting_view/SubCategory.dart';

import 'package:entemarket_user/Screen/starting_view/feature_product.dart';
import 'package:entemarket_user/Screen/starting_view/seller_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:place_picker/entities/location_result.dart';
//import 'package:place_picker/widgets/place_picker.dart' as picker;
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'Login.dart';
import 'ProductList.dart';
import 'Product_Detail.dart';
import 'SectionList.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List<SectionModel> sectionList = [];
List<Product> catList = [];
List<Product> popularList = [];
ApiBaseHelper apiBaseHelper = ApiBaseHelper();
List<String> tagList = [];
List<Product> sellerList = [];
int count = 1;
List<Model> homeSliderList = [];
List<Widget> pages = [];
List<Widget> pages1 = [];
List<Widget> pages2 = [];
var latitudeHome;
var longitudeHome;
class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  bool _isNetworkAvail = true;

  final _controller = PageController();
  final _controller1 = PageController();
  final _controller2 = PageController();
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<Model> offerImages = [];
  var pinController = TextEditingController();
  var currentAddress = TextEditingController();


  Future<Null> getCurrentLoc() async {
    GetLocation location = GetLocation((result)async{
      if(mounted) {
        if (currentAddress.text == "") {
          currentAddress.text = result.first.addressLine;
          latitudeHome = result.first.coordinates.latitude;
          longitudeHome = result.first.coordinates.longitude;
          pinController.text = result.first.postalCode;
          callApi();
        }
      }
    });
    location.getLoc();
    callApi();
  /*  Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high).then((position)async {
      latitudeHome = position.latitude.toString();
      longitudeHome = position.longitude.toString();
      List<Placemark> placemark = await placemarkFromCoordinates(
          double.parse(latitudeHome!), double.parse(longitudeHome!),
          localeIdentifier: "en");
      pinController.text = placemark[0].postalCode!;
      if (mounted) {
        setState(() {
          pinController.text = placemark[0].postalCode!;
          currentAddress.text =
          "${placemark[0].subLocality} , ${placemark[0].locality}";
          latitudeHome = position.latitude.toString();
          longitudeHome = position.longitude.toString();

          */
    /*     loc.lng = position.longitudeHome.toString();
        loc.lat = position.latitudeHome.toString();*/
    /*

        });
      }
    },onError:(error){
      callApi();
    });*/
  //  var loc = Provider.of<LocationProvider>(context, listen: false);
  }

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  getLocation() async {
    print(latitudeHome);
    print(longitudeHome);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: Platform.isAndroid
              ? "AIzaSyAzWKOX71IubaSG0BhDPsPermCzIuZaOHs"
              : "AIzaSyAzWKOX71IubaSG0BhDPsPermCzIuZaOHs",
          onPlacePicked: (result) {
            print(result.formattedAddress);
            setState(() {
              currentAddress.text = result.formattedAddress.toString();
              latitudeHome = result.geometry!.location.lat;
              longitudeHome = result.geometry!.location.lng;

            });
            Navigator.of(context).pop();
            callApi();
          },
          initialPosition: latitudeHome!=null?LatLng(double.parse(latitudeHome.toString()), double.parse(longitudeHome.toString())):const LatLng(20.5937,78.9629),
          useCurrentLocation: true,
        ),
      ),
    );
  /*  LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlacePicker(
          "AIzaSyCqQW9tN814NYD_MdsLIb35HRY65hHomco",
        )));

    setState(() {
      currentAddress.text =  "${result.subLocalityLevel1.name} , ${result.city.name}";
      latitudeHome = result.latLng.latitude.toString();
      longitudeHome = result.latLng.longitude.toString();
    });*/

  }
  //String? curPin;
  void requestPermission(BuildContext context) async{
    if (await Permission.location.isPermanentlyDenied||await Permission.location.isPermanentlyDenied) {

      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }
    else{
      Map<Permission, PermissionStatus> statuses = await [
        Permission.locationAlways,
        Permission.location,
      ].request();
// You can request multiple permissions at once.

      if(statuses[Permission.location]==PermissionStatus.granted&&statuses[Permission.locationAlways]==PermissionStatus.granted){
        getLocation();
      }else{
        if (await Permission.location.isDenied||await Permission.location.isDenied) {
          openAppSettings();
        }else{
          setSnackbar("Oops you just denied the permission", context);
        }

      }
    }

  }
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getCurrentLoc();
    // getHealthCat();
    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _animateSlider();
      _animateSlider1();
      _animateSlider2();
    });
  }

  @override
  Widget build(BuildContext context) {
    var mysize = MediaQuery.of(context).size;
    return Scaffold(
      body: _isNetworkAvail
          ? RefreshIndicator(
              color: colors.primary,
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _homeAppbar(),
                    // _deliverPincode(),
                    Container(
                      transform: Matrix4.translationValues(
                          0.0, -mysize.height / 60, 0.0),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: [
                          const SizedBox(height: 10,),
                          pages.length>0?_slider(pages,0,_controller):const SizedBox(),
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5),
                            child: Row(
                              children: const [
                                Text(
                                  'Categories',
                                  style: TextStyle(fontWeight: FontWeight.w600,color: colors.primary,),
                                ),
                                Spacer(),
                               /* Text(
                                  "View All",
                                  style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w600),
                                )*/
                              ],
                            ),
                          ),
                          _catList(),
                          const SizedBox(height: 10,),
                        ],
                      ),
                    ),
                    pages1.length>0?_slider(pages1,1,_controller1):const SizedBox(),
                    Container(
                      transform: Matrix4.translationValues(
                          0.0, -mysize.height / 60, 0.0),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5),
                            child: Row(
                              children: const [
                                Text(
                                  'Health & wellness',
                                  style: TextStyle(fontWeight: FontWeight.w600,color: colors.primary,),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                          healthCatList != null
                              ? Container(
                            height: 17.h,
                            padding: const EdgeInsets.only(top: 10, left: 10),
                            child: ListView.builder(
                              itemCount: healthCatList.length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsetsDirectional.only(end: 10),
                                    child: GestureDetector(
                                      onTap: () async {
                                        if(healthCatList[index].name.toString().toLowerCase().contains("health")){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => SellerView(
                                                  name: healthCatList[index].name,
                                                  id: healthCatList[index].id,
                                                  /*  tag: false,
                                          fromSeller: false,*/
                                                ),
                                              ));
                                          return;
                                        }
                                        // if(catList[index].name.toString().toLowerCase().contains("rest")){
                                        //   Navigator.push(
                                        //       context,
                                        //       MaterialPageRoute(
                                        //         builder: (context) => SellerView(
                                        //           name: catList[index].name,
                                        //           id: catList[index].id,
                                        //           /*  tag: false,
                                        //   fromSeller: false,*/
                                        //         ),
                                        //       ));
                                        //   return;
                                        // }
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) => SellerList(
                                        //           catId: catList[index].id,
                                        //           catName: catList[index].name,
                                        //           subId: catList[index].subList,
                                        //           getByLocation: false,
                                        //           sellerList: const [],
                                        //         )));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(color:  Theme.of(context)
                                            .colorScheme.black,borderRadius: BorderRadius.circular(8.0)),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsetsDirectional.only(
                                                  bottom: 5.0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: FadeInImage(
                                                  fadeInDuration: const Duration(milliseconds: 150),
                                                  image: CachedNetworkImageProvider(
                                                    "$imageUrl${healthCatList[index].image}",
                                                  ),
                                                  height: 11.h,
                                                  width: 11.h,
                                                  fit: BoxFit.cover,
                                                  imageErrorBuilder:
                                                      (context, error, stackTrace) =>
                                                      erroWidget(50),
                                                  placeholder: placeHolder(50),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              child: Text(
                                                healthCatList[index].name!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption!
                                                    .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 10),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                              width: 50,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                              },
                            ),
                          )
                              : SizedBox(),
                          // _catList(),
                          const SizedBox(height: 10,),
                        ],
                      ),
                    ),

                   saveButton("Feature Products", () {
                      if(CUR_USERID != null){
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FeatureProduct(
                                name: "Feature Product",
                                /*  tag: false,
                    fromSeller: false,*/
                              ),
                            ));
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            // title: const Text("Alert Dialog Box"),
                            content: const Text("Please Login first to Use This Features."),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Login(),
                                      ));
                                },
                                child: Container(
                                  color: Colors.green,
                                  padding: const EdgeInsets.all(10),
                                  child: const Text("okay",
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }),

                    _section(),
                    const SizedBox(height: 10,),
                    _seller(),
                    pages2.length>0?_slider(pages2,1,_controller2):const SizedBox(),
                  ],
                ),
              ),
            )
          : noInternet(context),
    );
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
  String cityId= "";
  Container _homeAppbar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  InkWell(
                    onTap: (){
                     // setSnackbar("Please Allow Location Permission", context);
                      requestPermission(context);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(TextSpan(children: [
                          const TextSpan(
                              text: "Delivery Location",
                              style:
                                  TextStyle(fontSize: 12.0, color: Colors.white)),
                          WidgetSpan(
                              child: Container(
                            transform: Matrix4.translationValues(0.0, 5, 0.0),
                            child: const Icon(
                              Icons.arrow_drop_up,
                              color: Colors.black,
                            ),
                          ))
                        ])),
                        SizedBox(
                          width: 70.w,
                          child: Text(currentAddress.text.toString() ,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 12.0, color: Colors.black)),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Text(
                  //   'Delivery Location',
                  //   style: TextStyle(color: Colors.white),
                  // ),
                  //new
     /*             cityList.length>0?Container(
                    child: DropdownButton<String>(
                      underline: SizedBox(),
                      iconSize: 3.h,
                      isDense: true,
                      value: cityId!=""?cityId:null,
                      hint: Text("Serviceable Location",style: TextStyle(fontSize: 10.sp, color: Theme.of(context).colorScheme.fontColor)),
                      icon: Icon(Icons.keyboard_arrow_down_outlined),
                      iconEnabledColor: Theme.of(context).colorScheme.fontColor,
                      items: cityList.map((p) {
                        return DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(
                              getString(p
                                  .name),
                              style: TextStyle(fontSize: 10.sp, color: Theme.of(context).colorScheme.fontColor)),
                        );
                      }).toList(),
                      //buttonElevation: 2,
                      //itemHeight: 40,
                     *//* itemPadding: const EdgeInsets.only(left: 10, right: 10),
                      dropdownPadding: null,
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black,
                      ),
                      dropdownElevation: 8,
                      dropdownWidth: 30.w,
                      scrollbarRadius: const Radius.circular(40),
                      scrollbarThickness: 6,
                      scrollbarAlwaysShow: true,
                      offset: const Offset(0, 0),*//*
                      onChanged: (value) {
                        setState(() {
                          cityId =value.toString();
                          zipId = cityList[cityList.indexWhere((element) => element.id==value)].zipcode_id;
                        });
                        callApi();
                      },
                    ),
                  ):SizedBox(),*/
                  const SizedBox(width: 10,),
                  InkWell(
                    onTap: (){
                      CUR_USERID != null
                          ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationList(),
                          ))
                          : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ));
                    },
                    child: Image.asset(
                      'assets/icons/notification_icon.png',
                      height: 30.0,
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: TextFormField(
                  readOnly: true,
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Search(),
                        ));
                  },
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,color: Theme.of(context).colorScheme.black,),
                      hintText: "Search",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: InputBorder.none),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 30.0,
            )
          ],
        ),
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/new_img/login_option.png'),
                fit: BoxFit.cover)),
      );

  Future<Null> _refresh() {
    context.read<HomeProvider>().setCatLoading(true);
    context.read<HomeProvider>().setSecLoading(true);
    context.read<HomeProvider>().setSliderLoading(true);

    return getCurrentLoc();
  }
  int current = 0;
  Widget _slider(pages,data,_controller) {
    double height = deviceWidth! / 2.2;

    return Stack(
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          // margin: EdgeInsetsDirectional.only(top: 10),
          child: PageView.builder(
            itemCount: pages.length,
            scrollDirection: Axis.horizontal,
            controller: _controller,

            physics: const AlwaysScrollableScrollPhysics(),
            onPageChanged: (index) {
              if(data ==0){
                setState(() {
                  current =index;
                });
              }
            },
            itemBuilder: (BuildContext context, int index) {
              return pages[index];
            },
          ),
        ),
        data==0?Positioned(
          bottom: 0,
          height: 40,
          left: 0,
          width: deviceWidth,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>(
              pages,
                  (index, url) {
                return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: current ==
                          index
                          ? Theme.of(context).colorScheme.fontColor
                          : Theme.of(context).colorScheme.primary,
                    ));
              },
            ),
          ),
        ):const SizedBox(),
      ],
    );
  }

  void _animateSlider() {
    Future.delayed(const Duration(seconds: 30)).then(
      (_) {
        if (mounted) {
          int nextPage = _controller.hasClients
              ? _controller.page!.round() + 1
              : _controller.initialPage;

          if (nextPage == homeSliderList.length) {
            nextPage = 0;
          }
          if (_controller.hasClients) {
            _controller
                .animateToPage(nextPage,
                    duration: const Duration(milliseconds: 200), curve: Curves.linear)
                .then((_) => _animateSlider());
          }
        }
      },
    );
  }
  void _animateSlider1() {
    Future.delayed(const Duration(seconds: 30)).then(
          (_) {
        if (mounted) {
          int nextPage = _controller1.hasClients
              ? _controller1.page!.round() + 1
              : _controller1.initialPage;

          if (nextPage == homeSliderList.length) {
            nextPage = 0;
          }
          if (_controller1.hasClients) {
            _controller1
                .animateToPage(nextPage,
                duration: const Duration(milliseconds: 200), curve: Curves.linear)
                .then((_) => _animateSlider1());
          }
        }
      },
    );
  }
  void _animateSlider2() {
    Future.delayed(const Duration(seconds: 30)).then(
          (_) {
        if (mounted) {
          int nextPage = _controller2.hasClients
              ? _controller2.page!.round() + 1
              : _controller2.initialPage;

          if (nextPage == homeSliderList.length) {
            nextPage = 0;
          }
          if (_controller2.hasClients) {
            _controller2
                .animateToPage(nextPage,
                duration: const Duration(milliseconds: 200), curve: Curves.linear)
                .then((_) => _animateSlider2());
          }
        }
      },
    );
  }
  _singleSection(int index) {
    Color back;
    int pos = index % 5;
    if (pos == 0) {
      back = Theme.of(context).colorScheme.back1;
    } else if (pos == 1) {
      back = Theme.of(context).colorScheme.back2;
    } else if (pos == 2) {
      back = Theme.of(context).colorScheme.back3;
    } else if (pos == 3) {
      back = Theme.of(context).colorScheme.back4;
    } else {
      back = Theme.of(context).colorScheme.back5;
    }

    return sectionList[index].productList!.length > 0
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _getHeading(sectionList[index].title ?? "", index),
                    _getSection(index),
                  ],
                ),
              ),
              offerImages.length > index ? _getOfferImage(index) : Container(),
            ],
          )
        : Container();
  }

  _getHeading(String title, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerRight,
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                  ),
                  color: colors.yellow,
                ),
                padding: const EdgeInsetsDirectional.only(
                    start: 10, bottom: 3, top: 3, end: 10),
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: colors.blackTemp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              /*   Positioned(
                  // clipBehavior: Clip.hardEdge,
                  // margin: EdgeInsets.symmetric(horizontal: 20),

                  right: -14,
                  child: SvgPicture.asset("assets/images/eshop.svg"))*/
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(sectionList[index].shortDesc ?? "",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    minimumSize: Size.zero, // <
                    backgroundColor: (Theme.of(context).colorScheme.white),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                child: Text(
                  getTranslated(context, 'SHOP_NOW')!,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  SectionModel model = sectionList[index];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SectionList(
                        index: index,
                        section_model: model,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  _getOfferImage(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        child: FadeInImage(
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 150),
            image: CachedNetworkImageProvider(offerImages[index].image.toString()),
            width: double.maxFinite,
            imageErrorBuilder: (context, error, stackTrace) => erroWidget(50),

            // errorWidget: (context, url, e) => placeHolder(50),
            placeholder: const AssetImage(MyAssets.slider_loding)),
        onTap: () {
          if (offerImages[index].type == "products") {
            Product? item = offerImages[index].list;

            Navigator.push(
              context,
              PageRouteBuilder(
                  //transitionDuration: Duration(seconds: 1),
                  pageBuilder: (_, __, ___) =>
                      ProductDetail(model: item, secPos: 0, index: 0, list: true
                          //  title: sectionList[secPos].title,
                          )),
            );
          } else if (offerImages[index].type == "categories") {
            Product item = offerImages[index].list;
            if (item.subList == null || item.subList!.length == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    subCatId: catList[index].categoryId,
                    subList: const [],
                    fromSeller: false,
                  ),
                ),
              );
            } else {
             /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategory(
                    title: item.name!,
                    subList: item.subList,
                  ),
                ),
              );*/
            }
          }
        },
      ),
    );
  }

  _getSection(int i) {
    var orient = MediaQuery.of(context).orientation;

    return sectionList[i].style == DEFAULT
        ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: GridView.count(
              // mainAxisSpacing: 12,
              // crossAxisSpacing: 12,
              padding: const EdgeInsetsDirectional.only(top: 5),
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 0.750,

              //  childAspectRatio: 1.0,
              physics: const NeverScrollableScrollPhysics(),
              children:
                  //  [
                  //   Container(height: 500, width: 1200, color: Colors.red),
                  //   Text("hello"),
                  //   Container(height: 10, width: 50, color: Colors.green),
                  // ]
                  List.generate(
                sectionList[i].productList!.length < 4
                    ? sectionList[i].productList!.length
                    : 4,
                (index) {
                  // return Container(
                  //   width: 600,
                  //   height: 50,
                  //   color: Colors.red,
                  // );

                  return productItem(i, index, index % 2 == 0 ? true : false);
                },
              ),
            ),
          )
        : sectionList[i].style == STYLE1
            ? sectionList[i].productList!.length > 0
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: SizedBox(
                                height: orient == Orientation.portrait
                                    ? deviceHeight! * 0.4
                                    : deviceHeight!,
                                child: productItem(i, 0, true))),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 1, false)),
                              SizedBox(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 2, false)),
                            ],
                          ),
                        ),
                      ],
                    ))
                : Container()
            : sectionList[i].style == STYLE2
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 0, true)),
                              SizedBox(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 1, true)),
                            ],
                          ),
                        ),
                        Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: SizedBox(
                                height: orient == Orientation.portrait
                                    ? deviceHeight! * 0.4
                                    : deviceHeight,
                                child: productItem(i, 2, false))),
                      ],
                    ))
                : sectionList[i].style == STYLE3
                    ? Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                                flex: 1,
                                fit: FlexFit.loose,
                                child: SizedBox(
                                    height: orient == Orientation.portrait
                                        ? deviceHeight! * 0.3
                                        : deviceHeight! * 0.6,
                                    child: productItem(i, 0, false))),
                            SizedBox(
                              height: orient == Orientation.portrait
                                  ? deviceHeight! * 0.2
                                  : deviceHeight! * 0.5,
                              child: Row(
                                children: [
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: productItem(i, 1, true)),
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: productItem(i, 2, true)),
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: productItem(i, 3, false)),
                                ],
                              ),
                            ),
                          ],
                        ))
                    : sectionList[i].style == STYLE4
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: SizedBox(
                                        height: orient == Orientation.portrait
                                            ? deviceHeight! * 0.25
                                            : deviceHeight! * 0.5,
                                        child: productItem(i, 0, false))),
                                SizedBox(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: Row(
                                    children: [
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: productItem(i, 1, true)),
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: productItem(i, 2, false)),
                                    ],
                                  ),
                                ),
                              ],
                            ))
                        : Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: GridView.count(
                                padding: const EdgeInsetsDirectional.only(top: 5),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.2,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 0,
                                children: List.generate(
                                  sectionList[i].productList!.length < 6
                                      ? sectionList[i].productList!.length
                                      : 6,
                                  (index) {
                                    return productItem(i, index,
                                        index % 2 == 0 ? true : false);
                                  },
                                )));
  }

  Widget productItem(int secPos, int index, bool pad) {
    if (sectionList[secPos].productList!.length > index) {
      String? offPer;
      double price = double.parse(
          sectionList[secPos].productList![index].prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(
            sectionList[secPos].productList![index].prVarientList![0].price!);
      } else {
        double off = double.parse(sectionList[secPos]
                .productList![index]
                .prVarientList![0]
                .price!) -
            price;
        offPer = ((off * 100) /
                double.parse(sectionList[secPos]
                    .productList![index]
                    .prVarientList![0]
                    .price!))
            .toStringAsFixed(2);
      }

      double width = deviceWidth! * 0.5;

      return Card(
        elevation: 0.0,

        margin: const EdgeInsetsDirectional.only(bottom: 2, end: 2),
        //end: pad ? 5 : 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                /*       child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5)),
                    child: Hero(
                      tag:
                      "${sectionList[secPos].productList![index].id}$secPos$index",
                      child: FadeInImage(
                        fadeInDuration: Duration(milliseconds: 150),
                        image: NetworkImage(
                            sectionList[secPos].productList![index].image!),
                        height: double.maxFinite,
                        width: double.maxFinite,
                        fit: extendImg ? BoxFit.fill : BoxFit.contain,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            erroWidget(width),

                        // errorWidget: (context, url, e) => placeHolder(width),
                        placeholder: placeHolder(width),
                      ),
                    )),*/
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        transitionOnUserGestures: true,
                        tag: "${sectionList[secPos].productList![index].id}$secPos$index",
                        child: FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 150),
                          image: CachedNetworkImageProvider(
                              sectionList[secPos].productList![index].image.toString()),
                          height: double.maxFinite,
                          width: double.maxFinite,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(double.maxFinite),
                          fit: BoxFit.contain,
                          placeholder: placeHolder(width),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 5.0,
                  top: 3,
                ),
                child: Text(
                  sectionList[secPos].productList![index].name!,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                " " + CUR_CURRENCY! + " " + price.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                    start: 5.0, bottom: 5, top: 3),
                child: double.parse(sectionList[secPos]
                            .productList![index]
                            .prVarientList![0]
                            .disPrice!) !=
                        0
                    ? Row(
                        children: <Widget>[
                          Text(
                            double.parse(sectionList[secPos]
                                        .productList![index]
                                        .prVarientList![0]
                                        .disPrice!) !=
                                    0
                                ? CUR_CURRENCY! +
                                    "" +
                                    sectionList[secPos]
                                        .productList![index]
                                        .prVarientList![0]
                                        .price!
                                : "",
                            style: Theme.of(context)
                                .textTheme
                                .overline!
                                .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    letterSpacing: 0),
                          ),
                          Flexible(
                            child: Text(" | " + "-$offPer%",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .overline!
                                    .copyWith(
                                        color: colors.primary,
                                        letterSpacing: 0)),
                          ),
                        ],
                      )
                    : Container(
                        height: 5,
                      ),
              )
            ],
          ),
          onTap: () {
            Product model = sectionList[secPos].productList![index];
            Navigator.push(
              context,
              PageRouteBuilder(
                // transitionDuration: Duration(milliseconds: 150),
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: model, secPos: secPos, index: index, list: false
                    //  title: sectionList[secPos].title,
                    ),
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  _section() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.simmerBase,
                  highlightColor: Theme.of(context).colorScheme.simmerHigh,
                  child: sectionLoading(),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: sectionList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  print("here");
                  return _singleSection(index);
                },
              );
      },
      selector: (_, homeProvider) => homeProvider.secLoading,
    );
  }

  _catList() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: catLoading()))
            : Container(
                height: 18.h,
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: ListView.builder(
                  itemCount: catList.length ,
                      //< 10 ? catList.length : 10,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container();
                    } else {
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: GestureDetector(
                          onTap: () async {
                            /*if(catList[index].name.toString().toLowerCase().contains("health")){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SellerView(
                                      name: catList[index].name,
                                      id: catList[index].id,
                                      *//*  tag: false,
                                          fromSeller: false,*//*
                                    ),
                                  ));
                              return;
                            }*/
                            if(catList[index].name.toString().toLowerCase().contains("rest")){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SellerView(
                                      name: catList[index].name,
                                      id: catList[index].id,
                                      /*  tag: false,
                                          fromSeller: false,*/
                                    ),
                                  ));
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SellerList(
                                      catId: catList[index].id,
                                      catName: catList[index].name,
                                      subId: catList[index].subList,
                                      getByLocation: false,
                                      sellerList: const [],
                                    )));
                          },
                          child: Container(
                            decoration: BoxDecoration(color:  Theme.of(context)
                                .colorScheme.black,borderRadius: BorderRadius.circular(8.0)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      bottom: 5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: FadeInImage(
                                      fadeInDuration: const Duration(milliseconds: 150),
                                      image: CachedNetworkImageProvider(
                                        catList[index].image!,
                                      ),
                                      height: 11.h,
                                      width: 11.h,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) =>
                                              erroWidget(50),
                                      placeholder: placeHolder(50),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Text(
                                    catList[index].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  width: 50,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
      },
      selector: (_, homeProvider) => homeProvider.catLoading,
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Future<Null> callApi() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
        Provider.of<SettingProvider>(context, listen: false);

    user.setUserId(setting.userId);
    CUR_USERID = setting.userId;
    setState(() {
      sellerList.clear();
      sectionList.clear();
    });
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if(cityList.length==0){
        getCity();
      }
      if(CUR_USERID!=null){
        getCurrentFid();
        inputData();
      }

      getSetting();
      getHealthCat();
      getSlider();
      getSecondSlider();
      getThirdSlider();
      getCat();
      getSeller();
      getSection();
      getOfferImages();
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
    return null;
  }

  Future _getFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        Map parameter = {
          USER_ID: CUR_USERID,
        };
        apiBaseHelper.postAPICall(getFavApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            List<Product> tempList = (data as List)
                .map((data) => Product.fromJson(data))
                .toList();

            context.read<FavoriteProvider>().setFavlist(tempList);
          } else {
            if (msg != 'No Favourite(s) Product Are Added') {
              setSnackbar(msg!, context);
            }
          }

          context.read<FavoriteProvider>().setLoading(false);
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          context.read<FavoriteProvider>().setLoading(false);
        });
      } else {
        context.read<FavoriteProvider>().setLoading(false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  void getOfferImages() {
    Map parameter = Map();

    apiBaseHelper.postAPICall(getOfferImageApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        offerImages.clear();
        offerImages =
            (data as List).map((data) => Model.fromSlider(data)).toList();
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setOfferLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setOfferLoading(false);
    });
  }

  void getSection() {
    Map parameter = {PRODUCT_LIMIT: "6", PRODUCT_OFFSET: "0"};

    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
    String curPin = context.read<UserProvider>().curPincode;
    if(zipId!="") {
      parameter[ZIPCODE] = zipId;
    }
    apiBaseHelper.postAPICall(getSectionApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      sectionList.clear();
      if (!error) {
        var data = getdata["data"];

        sectionList = (data as List)
            .map((data) => SectionModel.fromJson(data))
            .toList();
      } else {
        if (curPin != '') context.read<UserProvider>().setPincode('');
      //  setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSecLoading(false);
    }, onError: (error) {
      //setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSecLoading(false);
    });
  }

  void getSetting() {
    CUR_USERID = context.read<SettingProvider>().userId;
    //print("")
    Map parameter = Map();
    if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};

    apiBaseHelper.postAPICall(getSettingApi, parameter).then((getdata) async {
      bool error = getdata["error"];
      String? msg = getdata["message"];

      if (!error) {
        var data = getdata["data"]["system_settings"][0];
        cartBtnList = data["cart_btn_on_list"] == "1" ? true : false;
        refer = data["is_refer_earn_on"] == "1" ? true : false;
        CUR_CURRENCY = data["currency"];
        RETURN_DAYS = data['max_product_return_days'];
        MAX_ITEMS = data["max_items_cart"];
        MIN_AMT = data['min_amount'];
        vendorChat = data['vendor_chat'];
        driverChat = data['driver_chat'];
        CUR_DEL_CHR = data['delivery_charge'];
        String? isVerion = data['is_version_system_on'];
        extendImg = data["expand_product_images"] == "1" ? true : false;
        String? del = data["area_wise_delivery_charge"];
        MIN_ALLOW_CART_AMT = data[MIN_CART_AMT];

        if (del == "0") {
          ISFLAT_DEL = true;
        } else {
          ISFLAT_DEL = false;
        }

        if (CUR_USERID != null) {
          REFER_CODE = getdata['data']['user_data'][0]['referral_code'];

          context
              .read<UserProvider>()
              .setPincode(getdata["data"]["user_data"][0][PINCODE]);

          if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE!.isEmpty) {
            generateReferral();
          }

          context.read<UserProvider>().setCartCount(
              getdata["data"]["user_data"][0]["cart_total_items"].toString());
          context
              .read<UserProvider>()
              .setBalance(getdata["data"]["user_data"][0]["balance"]);

          _getFav();
          _getCart("0");
        }

        UserProvider user = Provider.of<UserProvider>(context, listen: false);
        SettingProvider setting =
            Provider.of<SettingProvider>(context, listen: false);
        user.setMobile(setting.mobile);
        user.setName(setting.userName);
        user.setEmail(setting.email);
        user.setProfilePic(setting.profileUrl);

        Map<String, dynamic> tempData = getdata["data"];
        if (tempData.containsKey(TAG)) {
          tagList = List<String>.from(getdata["data"][TAG]);
        }

        if (isVerion == "1") {
          String? verionAnd = data['current_version'];
          String? verionIOS = data['current_version_ios'];

          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          String version = packageInfo.version;

          final Version currentVersion = Version.parse(version);
          final Version latestVersionAnd = Version.parse(verionAnd);
          final Version latestVersionIos = Version.parse(verionIOS);

          if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
              (Platform.isIOS && latestVersionIos > currentVersion)) {
            updateDailog();
          }
        }
      } else {
       // setSnackbar(msg!, context);
      }
    }, onError: (error) {
     // setSnackbar(error.toString(), context);
    });
  }

  Future<void> _getCart(String save) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};

        Response response =
            await post(getCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<SectionModel> cartList = (data as List)
              .map((data) => SectionModel.fromCart(data))
              .toList();
          context.read<CartProvider>().setCartlist(cartList);
        }
      } on TimeoutException catch (_) {}
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
        });
      }
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<Null> generateReferral() async {
    String refer = getRandomString(8);

    //////

    Map parameter = {
      REFERCODE: refer,
    };

    apiBaseHelper.postAPICall(validateReferalApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        REFER_CODE = refer;

        Map parameter = {
          USER_ID: CUR_USERID,
          REFERCODE: refer,
        };

        apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
      } else {
        if (count < 5) generateReferral();
        count++;
      }

      context.read<HomeProvider>().setSecLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSecLoading(false);
    });
  }

  updateDailog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(5.0))),
        title: Text(getTranslated(context, 'UPDATE_APP')!),
        content: Text(
          getTranslated(context, 'UPDATE_AVAIL')!,
          style: Theme.of(this.context)
              .textTheme
              .subtitle1!
              .copyWith(color: Theme.of(context).colorScheme.fontColor),
        ),
        actions: <Widget>[
          TextButton(
              child: Text(
                getTranslated(context, 'NO')!,
                style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              }),
          TextButton(
              child: Text(
                getTranslated(context, 'YES')!,
                style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context).pop(false);

                String _url = '';
                if (Platform.isAndroid) {
                  _url = androidLink + packageName;
                } else if (Platform.isIOS) {
                  _url = iosLink;
                }

                if (await canLaunch(_url)) {
                  await launch(_url);
                } else {
                  throw 'Could not launch $_url';
                }
              })
        ],
      );
    }));
  }

  Widget homeShimmer() {
    return SizedBox(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            catLoading(),
            sliderLoading(),
            sectionLoading(),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: height,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget _buildImagePageItem(Model slider) {
    double height = deviceWidth! / 0.5;

    return GestureDetector(
      child: FadeInImage(
          fadeInDuration: const Duration(milliseconds: 150),
          image: CachedNetworkImageProvider(slider.image.toString()),
          height: height,
          width: double.maxFinite,
          fit: BoxFit.fill,
          imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                MyAssets.slider_loding,
                fit: BoxFit.contain,
                height: height,
                color: colors.primary,
              ),
          placeholderErrorBuilder: (context, error, stackTrace) => Image.asset(
                MyAssets.slider_loding,
                fit: BoxFit.contain,
                height: height,
                color: colors.primary,
              ),
          placeholder: const AssetImage(MyAssets.slider_loding)),
      onTap: () async {
        int curSlider = context.read<HomeProvider>().curSlider;

        if (homeSliderList[curSlider].type == "products") {
          Product? item = homeSliderList[curSlider].list;

          Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: item, secPos: 0, index: 0, list: true)),
          );
        } else if (homeSliderList[curSlider].type == "categories") {
          Product item = homeSliderList[curSlider].list;
          if (item.subList == null || item.subList!.length == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    subCatId: catList[0].categoryId,
                    fromSeller: false,
                    subList: const [],
                  ),
                ));
          } else {
           /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategory(
                    title: item.name!,
                    subList: item.subList,
                  ),
                ));*/
          }
        }
      },
    );
  }

  Widget deliverLoading() {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            shape: BoxShape.circle,
                          ),
                          width: 50.0,
                          height: 50.0,
                        ))
                    .toList()),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
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
              context.read<HomeProvider>().setCatLoading(true);
              context.read<HomeProvider>().setSecLoading(true);
              context.read<HomeProvider>().setSliderLoading(true);
              _playAnimation();

              Future.delayed(const Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  if (mounted) {
                    setState(() {
                      _isNetworkAvail = true;
                    });
                  }
                  callApi();
                } else {
                  await buttonController.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  _deliverPincode() {
    // String curpin = context.read<UserProvider>().curPincode;
    return GestureDetector(
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 8),
        color: Theme.of(context).colorScheme.white,
        child: ListTile(
          dense: true,
          minLeadingWidth: 10,
          leading: const Icon(
            Icons.location_pin,
          ),
          title: Selector<UserProvider, String>(
            builder: (context, data, child) {
              return Text(
                data == ''
                    ? getTranslated(context, 'SELOC')!
                    : getTranslated(context, 'DELIVERTO')! + data,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.fontColor),
              );
            },
            selector: (_, provider) => provider.curPincode,
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
        ),
      ),
      onTap: _pincodeCheck,
    );
  }

  void _pincodeCheck() {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), topRight: const Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: ListView(shrinkWrap: true, children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, bottom: 40, top: 30),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(Icons.close),
                                ),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) => validatePincode(val!,
                                    getTranslated(context, 'PIN_REQUIRED')),
                                onSaved: (String? value) {
                                  context
                                      .read<UserProvider>()
                                      .setPincode(value!);
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                                decoration: InputDecoration(
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.location_on),
                                  hintText:
                                      getTranslated(context, 'PINCODEHINT_LBL'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      margin:
                                          const EdgeInsetsDirectional.only(start: 20),
                                      width: deviceWidth! * 0.35,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          context
                                              .read<UserProvider>()
                                              .setPincode('');

                                          context
                                              .read<HomeProvider>()
                                              .setSecLoading(true);
                                          getSection();
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                            getTranslated(context, 'All')!),
                                      ),
                                    ),
                                    const Spacer(),
                                    SimBtn(
                                        size: 0.35,
                                        title: getTranslated(context, 'APPLY'),
                                        onBtnSelected: () async {
                                          if (validateAndSave()) {
                                            // validatePin(curPin);
                                            context
                                                .read<HomeProvider>()
                                                .setSecLoading(true);
                                            getSection();

                                            context
                                                .read<HomeProvider>()
                                                .setSellerLoading(true);
                                            getSeller();

                                            Navigator.pop(context);
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ))
              ]),
            );
            //});
          });
        });
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  void getSlider() {
    Map map = Map();

    apiBaseHelper.postAPICall(getSliderApi, map).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        homeSliderList =
            (data as List).map((data) => Model.fromSlider(data)).toList();
    setState(() {
      pages = homeSliderList.map((slider) {
        return _buildImagePageItem(slider);
      }).toList();
    });

      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSliderLoading(false);
    }, onError: (error) {
      //setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSliderLoading(false);
    });
  }
  void getSecondSlider() {
    Map map = Map();

    apiBaseHelper.postAPICall(getSecondSliderApi, map).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        homeSliderList =
            (data as List).map((data) => Model.fromSlider(data)).toList();
setState(() {
  pages1 = homeSliderList.map((slider) {
    return _buildImagePageItem(slider);
  }).toList();
});

      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSliderLoading(false);
    }, onError: (error) {
      //setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSliderLoading(false);
    });
  }
  void getThirdSlider() {
    Map map = Map();

    apiBaseHelper.postAPICall(getThirdSliderApi, map).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        homeSliderList =
            (data as List).map((data) => Model.fromSlider(data)).toList();
        setState(() {
          pages2 = homeSliderList.map((slider) {
            return _buildImagePageItem(slider);
          }).toList();
        });

      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSliderLoading(false);
    }, onError: (error) {
     // setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSliderLoading(false);
    });
  }
  List<CityModel> cityList = [];
  void getCity() {
    Map map = Map();

    apiBaseHelper.postAPICall(getCityApi, map).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        for(var v in data){
          setState(() {
            cityList.add(CityModel(v['id'], v['name'], v['city_id'], v['zipcode_id'], v['minimum_free_delivery_order_amount'], v['delivery_charges']));
          });
        }
        /*setState(() {
          cityId= cityList[0].city_id;
          zipId = cityList[0].zipcode_id;
        });*/
       // callApi();
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSliderLoading(false);
    }, onError: (error) {
     // setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSliderLoading(false);
    });
  }
  void getCat() {
    Map parameter = {
      CAT_FILTER: "false",
    };
    apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        catList =
            (data as List).map((data) => Product.fromCat(data)).toList();

        if (getdata.containsKey("popular_categories")) {
          var data = getdata["popular_categories"];
          popularList =
              (data as List).map((data) => Product.fromCat(data)).toList();

          if (popularList.length > 0) {
            Product pop =
                Product.popular("Popular", imagePath + "popular.svg");
            catList.insert(0, pop);
            context.read<CategoryProvider>().setSubList(popularList);
          }
        }
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      setSnackbar("cat"+error.toString(), context);
      context.read<HomeProvider>().setCatLoading(false);
    });
  }
  List healthCatList = [];
  Future getHealthCat() async{

    var request = http.Request('POST', getHealthCatApi);

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      var data = HealthCategoryModel.fromJson(json.decode(str));
      if(data.error == true){
        setState(() {
          healthCatList = data.data!;
        });
        print(healthCatList);
      return HealthCategoryModel.fromJson(json.decode(str));
    }
  }
    else {
      return null;
    }

  }

  sectionLoading() {
    return Column(
        children: [0, 1, 2, 3, 4]
            .map((_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 40),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: double.infinity,
                                height: 18.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              GridView.count(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.0,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                children: List.generate(
                                  4,
                                  (index) {
                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color:
                                          Theme.of(context).colorScheme.white,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    sliderLoading()
                    //offerImages.length > index ? _getOfferImage(index) : Container(),
                  ],
                ))
            .toList());
  }
  String zipId="";
  void getSeller() {
    String pin = context.read<UserProvider>().curPincode;
    Map parameter = {
    };
    print(parameter);
    if(zipId!=""){
      parameter = {
        ZIPCODE: zipId,
      };
    }
    if(latitudeHome!=null){
      parameter = {
        "lat" : latitudeHome.toString(),
        "long":longitudeHome.toString(),
      };
    }

    print("GET SELLER === $parameter");

    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        sellerList =
            (data as List).map((data) => Product.fromSeller(data)).toList();
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      setSnackbar("seller"+error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }

  _seller() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? SizedBox(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: catLoading()))
            : sellerList.length>0?Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(getTranslated(context, 'SHOP_BY_SELLER')!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold)),
                        GestureDetector(
                          child: Text(getTranslated(context, 'VIEW_ALL')!),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SellerList(
                                      catId: "",
                                      catName: "",
                                      subId: "",
                                      sellerList: sellerList,
                                    )));
                           /* Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SellerList()));*/
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 260,
                    padding: const EdgeInsets.only(top: 10, left: 10,bottom: 20),
                    child: ListView.builder(
                      itemCount: sellerList.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsetsDirectional.only(end: 5),
                          child: Card(
                            child: GestureDetector(
                              onTap: () {
                                if(sellerList[index].openCloseStatus == 1){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SubCategory(
                                            title: sellerList[index]
                                                .store_name
                                                .toString(),
                                            sellerId: sellerList[index]
                                                .seller_id
                                                .toString(),
                                            sellerData: sellerList[index],
                                            catId: sellerList[index].category_ids!.contains(",")?sellerList[index].category_ids!.split(",")[0]:sellerList[index].category_ids!,
                                          )));
                                } else {
                                  setSnackbar("Store is Closed", context);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                     ClipRRect(
                                      borderRadius: BorderRadius.circular(100.0),
                                      child: Container(
                                        color: Colors.white,
                                        alignment: Alignment.center,
                                        child:  Center(
                                          child: FadeInImage(
                                            fadeInDuration:
                                                const Duration(milliseconds: 150),
                                            image: CachedNetworkImageProvider(
                                              sellerList[index].seller_profile!,
                                            ),
                                            height: 120.0,
                                            width: 120.0,
                                            fit: BoxFit.contain,
                                            imageErrorBuilder:
                                                (context, error, stackTrace) =>
                                                    erroWidget(120),
                                            placeholder: placeHolder(120),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    SizedBox(
                                      child: Text(
                                        sellerList[index].seller_name!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.w600,),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      width: 100,
                                    ),
                                    const SizedBox(height: 5,),
                                    SizedBox(
                                      child: Text(
                                        calculateDistance(latitudeHome, longitudeHome, sellerList[index].latitude, sellerList[index].longitude),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontWeight: FontWeight.w600,),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      width: 100,
                                    ),
                                    SizedBox(
                                      child: Text(
                                        "Delivery Time : ${sellerList[index].delivery_tiem!}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.w500,),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      width: 100,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ):const SizedBox();
      },
      selector: (_, homeProvider) => homeProvider.sellerLoading,
    );
  }

  getCurrentFid()async{
    await App.init();
    Map parameter = {};
    parameter = {
      "user_id": CUR_USERID,
    };
    print(parameter);
    print("thus");
    apiBaseHelper.postAPICall(getUserApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      print(msg);
      if (!error) {
        var data = getdata["data"];
        if( App.localStorage.setString("firebaseUid", data[0]['fuid'])==null){
          App.localStorage.setString("firebaseUid", data[0]['fuid']);
        }
        print("checkdata"+data.toString());
      } else {
        setSnackbar(msg!, context);
      }
    });
  }
  updateCurrentFid(fid)async{
    await App.init();
    Map parameter = {};
    parameter = {
      "user_id": CUR_USERID,
      "fuid": fid,
    };
    apiBaseHelper.postAPICall(getUpdateApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        App.localStorage.setString("firebaseUid", fid.toString());
      } else {
        setSnackbar(msg!, context);
      }

    }, onError: (error) {
      setSnackbar(error.toString(), context);
    });
  }
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> inputData() async {
    if(auth.currentUser!=null){
      final User user = await auth.currentUser!;
      final uid = user.uid;
      print(uid);
      updateCurrentFid(uid);
    }

    // here you write the codes to input the data into firestore
  }
}
