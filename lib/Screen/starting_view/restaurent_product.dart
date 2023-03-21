import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:entemarket_user/Helper/AppBtn.dart';
import 'package:entemarket_user/Helper/Color.dart';
import 'package:entemarket_user/Helper/Constant.dart';
import 'package:entemarket_user/Helper/Session.dart';
import 'package:entemarket_user/Helper/SimBtn.dart';
import 'package:entemarket_user/Helper/String.dart';
import 'package:entemarket_user/Model/Section_Model.dart';
import 'package:entemarket_user/Model/vendor_model.dart';
import 'package:entemarket_user/Provider/CartProvider.dart';
import 'package:entemarket_user/Provider/FavoriteProvider.dart';
import 'package:entemarket_user/Provider/UserProvider.dart';
import 'package:entemarket_user/Screen/HomePage.dart';
import 'package:entemarket_user/Screen/Login.dart';
import 'package:entemarket_user/Screen/ProductList.dart';
import 'package:entemarket_user/Screen/Product_Detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';


class RestProductList extends StatefulWidget {
  final String? name, id;
  final bool? tag, fromSeller;
  final int? dis;

  const RestProductList(
      {Key? key, this.id, this.name, this.tag, this.fromSeller, this.dis})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => StateProduct();
}

class StateProduct extends State<RestProductList> with TickerProviderStateMixin {
  bool _isLoading = true, _isProgress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<RestProductModel> RestProductList = [];
  List<RestProductModel> tempList = [];
  String sortBy = 'p.id', orderBy = "DESC";
  int offset = 0;
  int total = 0;
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
   // controller.addListener(_scrollListener);
    getProduct("0");

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

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getProduct("0");
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
        appBar: getAppBar(widget.name!, context),
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
                  getProduct("0");
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
    if (index < RestProductList.length) {
      RestProductModel model = RestProductList[index];
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
                                        "https://entemarket.com/"+model.image),
                                    height: 125.0,
                                    width: 135.0,
                                    fit: BoxFit.cover,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                        erroWidget(125),
                                    placeholder: placeHolder(125),
                                  ),
                                  Positioned.fill(
                                      child: model.availability == "0"
                                          ? Container(
                                        height: 55,
                                        color: Colors.white70,
                                        // width: double.maxFinite,
                                        padding: EdgeInsets.all(2),
                                        child: Center(
                                          child: Text(
                                            getTranslated(context,
                                                'OUT_OF_STOCK_LBL')!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .caption!
                                                .copyWith(
                                              color: Colors.red,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                          : Container()),

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
                              (model.rating == "0" || model.rating == "0.0")
                                  ? Container()
                                  : Row(
                                children: [
                                  RatingBarIndicator(
                                    rating: double.parse(model.rating),
                                    itemBuilder: (context, index) => Icon(
                                      Icons.star_rate_rounded,
                                      color: Colors.amber,
                                      //color: colors.primary,
                                    ),
                                    unratedColor:
                                    Colors.grey.withOpacity(0.5),
                                    itemCount: 5,
                                    itemSize: 18.0,
                                    direction: Axis.horizontal,
                                  ),
                                  Text(
                                    " (" + model.rating + ")",
                                    style: Theme.of(context)
                                        .textTheme
                                        .overline,
                                  )
                                ],
                              ),
                            /*  _controller[index].text != "0"
                                  ? Row(
                                children: [
                                  //Spacer(),
                                  model.availability == "0"
                                      ? Container()
                                      : cartBtnList
                                      ? Row(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          GestureDetector(
                                            child: Card(
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    50),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(
                                                    8.0),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            onTap: () {

                                            },
                                          ),
                                          Container(
                                            width: 37,
                                            height: 20,
                                            child: Stack(
                                              children: [
                                                Selector<
                                                    CartProvider,
                                                    Tuple2<
                                                        List<
                                                            String?>,
                                                        List<
                                                            String?>>>(
                                                  builder:
                                                      (context,
                                                      data,
                                                      child) {
                                                    _controller[
                                                    index]
                                                        .text = data
                                                        .item1
                                                        .contains(model
                                                        .id)
                                                        ? data
                                                        .item2[data.item1.indexWhere((element) =>
                                                    element ==
                                                        model.id)]
                                                        .toString()
                                                        : "0";
                                                    return TextField(
                                                      textAlign:
                                                      TextAlign
                                                          .center,
                                                      readOnly:
                                                      true,
                                                      style: TextStyle(
                                                          fontSize:
                                                          12,
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .fontColor),
                                                      controller:
                                                      _controller[
                                                      index],
                                                      // _controller[index],
                                                      decoration:
                                                      InputDecoration(
                                                        border:
                                                        InputBorder.none,
                                                      ),
                                                    );
                                                  },
                                                  selector: (_,
                                                      provider) =>
                                                      Tuple2(
                                                          provider
                                                              .cartIdList,
                                                          provider
                                                              .qtyList),
                                                ),
                                              ],
                                            ),
                                          ), // ),

                                          GestureDetector(
                                            child: Card(
                                              shape:
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    50),
                                              ),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(
                                                    8.0),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            onTap: () {

                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                      : Container(),
                                ],
                              )
                                  : Container(),*/
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  // model.availability == "0"
                  //     ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .subtitle2!
                  //             .copyWith(
                  //                 color: Colors.red,
                  //                 fontWeight: FontWeight.bold))
                  //     : Container(),
                ]),
                onTap: () {
                  RestProductModel model = RestProductList[index];
                 /* Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ProductDetail(
                          model: model,
                          index: index,
                          secPos: 0,
                          list: true,
                        )),
                  );*/
                },
              ),
            ),
          ],
        ),
      );
    } else
      return Container();
  }

  


String imageUrl = "";
  void getProduct(String top) {
    //_currentRangeValues.start.round().toString(),
    // _currentRangeValues.end.round().toString(),
    Map parameter = {
      SORT: sortBy,
      ORDER: orderBy,
      LIMIT: perPage.toString(),
      OFFSET: offset.toString(),
      TOP_RETAED: top,
    };
    if (selId != null && selId != "") {
      parameter[ATTRIBUTE_VALUE_ID] = selId;
    }
    if (widget.tag!) parameter[TAG] = widget.name!;
    if (widget.fromSeller!) {
      parameter["seller_id"] = widget.id!;
    } else {
      parameter[CATID] = widget.id ?? '';
    }
    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

    if (widget.dis != null) parameter[DISCOUNT] = widget.dis.toString();

    if (_currentRangeValues != null &&
        _currentRangeValues!.start.round().toString() != "0") {
      parameter[MINPRICE] = _currentRangeValues!.start.round().toString();
    }

    if (_currentRangeValues != null &&
        _currentRangeValues!.end.round().toString() != "0") {
      parameter[MAXPRICE] = _currentRangeValues!.end.round().toString();
    }

    apiBaseHelper.postAPICall(getRestProductApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {

        tempList.clear();

        var data = getdata["data"];
        imageUrl = getdata["image_url"];
        RestProductList =
            (data as List).map((data) => new RestProductModel.fromJson(data)).toList();

        if (getdata.containsKey(TAG)) {
          List<String> tempList = List<String>.from(getdata[TAG]);
          if (tempList != null && tempList.length > 0) tagList = tempList;
        }


        offset = offset + perPage;
      } else {
        isLoadingmore = false;
        if (msg != "Products Not Found !") setSnackbar(msg!, context);
      }

      setState(() {
        _isLoading = false;
      });
      // context.read<RestProductListProvider>().setProductLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      setState(() {
        _isLoading = false;
      });
      //context.read<RestProductListProvider>().setProductLoading(false);
    });
  }




  Widget productItem(int index, bool pad) {
    if (index < RestProductList.length) {
      RestProductModel model = RestProductList[index];

      return InkWell(
        child: Card(
          elevation: 4,
          margin: EdgeInsetsDirectional.only(
              bottom: 10, end: 10, start: pad ? 10 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        tag: "ProGrid$index${model.id}",
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: CachedNetworkImageProvider("https://entemarket.com/"+model.image),
                          height: double.maxFinite,
                          width: double.maxFinite,
                          fit: BoxFit.cover,
                          placeholder: placeHolder(deviceWidth!),
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(deviceWidth!),
                        ),
                      ),
                    ),
                    Positioned.fill(
                        child: model.availability == "0"
                            ? Container(
                          height: 55,
                          color: Colors.white70,
                          // width: double.maxFinite,
                          padding: EdgeInsets.all(2),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                            : Container()),
                    Divider(
                      height: 1,
                    ),
                  ],
                ),
              ),
              (model.rating == "0" || model.rating == "0.0")
                  ? Container()
                  : Row(
                children: [
                  RatingBarIndicator(
                    rating: double.parse(model.rating),
                    itemBuilder: (context, index) => Icon(
                      Icons.star_rate_rounded,
                      color: Colors.amber,
                      //color: colors.primary,
                    ),
                    unratedColor: Colors.grey.withOpacity(0.5),
                    itemCount: 5,
                    itemSize: 12.0,
                    direction: Axis.horizontal,
                    itemPadding: EdgeInsets.all(0),
                  ),
                  Text(
                    " (" + model.noOfRatings + ")",
                    style: Theme.of(context).textTheme.overline,
                  )
                ],
              ),
              Padding(
                padding:
                const EdgeInsetsDirectional.only(start: 5.0, bottom: 5),
                child: Text(
                  model.name,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      color: Theme.of(context).colorScheme.lightBlack),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          //),
        ),
        onTap: () {

        },
      );
    } else
      return Container();
  }

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
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
              return SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                            padding:
                            EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                            child: Text(
                              getTranslated(context, 'SORT_BY')!,
                              style: Theme.of(context).textTheme.headline6,
                            )),
                      ),
                      InkWell(
                        onTap: () {
                          sortBy = '';
                          orderBy = 'DESC';
                          if (mounted)
                            setState(() {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              RestProductList.clear();
                            });
                          getProduct("1");
                          Navigator.pop(context, 'option 1');
                        },
                        child: Container(
                          width: deviceWidth,
                          color: sortBy == ''
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Text(getTranslated(context, 'TOP_RATED')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: sortBy == ''
                                      ? Theme.of(context).colorScheme.white
                                      : Theme.of(context)
                                      .colorScheme
                                      .fontColor)),
                        ),
                      ),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'p.date_added' && orderBy == 'DESC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(getTranslated(context, 'F_NEWEST')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                      color: sortBy == 'p.date_added' &&
                                          orderBy == 'DESC'
                                          ? Theme.of(context).colorScheme.white
                                          : Theme.of(context)
                                          .colorScheme
                                          .fontColor))),
                          onTap: () {
                            sortBy = 'p.date_added';
                            orderBy = 'DESC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                RestProductList.clear();
                              });
                            getProduct("0");
                            Navigator.pop(context, 'option 1');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'p.date_added' && orderBy == 'ASC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(
                                getTranslated(context, 'F_OLDEST')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'p.date_added' &&
                                        orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'p.date_added';
                            orderBy = 'ASC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                RestProductList.clear();
                              });
                            getProduct("0");
                            Navigator.pop(context, 'option 2');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'pv.price' && orderBy == 'ASC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: new Text(
                                getTranslated(context, 'F_LOW')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'pv.price' &&
                                        orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'pv.price';
                            orderBy = 'ASC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                RestProductList.clear();
                              });
                            getProduct("0");
                            Navigator.pop(context, 'option 3');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'pv.price' && orderBy == 'DESC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: new Text(
                                getTranslated(context, 'F_HIGH')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'pv.price' &&
                                        orderBy == 'DESC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'pv.price';
                            orderBy = 'DESC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                RestProductList.clear();
                              });
                            getProduct("0");
                            Navigator.pop(context, 'option 4');
                          }),
                    ]),
              );
            });
      },
    );
  }

/*  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getProduct("0");
          });
      }
    }
  }*/




  _showForm(BuildContext context) {
    return /*RefreshIndicator(
        key: _refreshIndicatorKey,
        //onRefresh: _refresh,
        child: */
      Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.white,
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Column(
              children: [
                if (widget.fromSeller!) Container() else _tags(),
                filterOptions(),
              ],
            ),
          ),
          Expanded(
            child: RestProductList.length == 0
                ? getNoItem(context)
                : listType
                ? ListView.builder(
              //controller: controller,
              itemCount: (offset < total)
                  ? RestProductList.length + 1
                  : RestProductList.length,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return (index == RestProductList.length && isLoadingmore)
                    ? singleItemSimmer(context)
                    : listItem(index);
              },
            )
                : GridView.count(
                padding: EdgeInsetsDirectional.only(top: 5),
                crossAxisCount: 2,
               // controller: controller,
                childAspectRatio: 0.78,
                physics: AlwaysScrollableScrollPhysics(),
                children: List.generate(
                  (offset < total)
                      ? RestProductList.length + 1
                      : RestProductList.length,
                      (index) {
                    return (index == RestProductList.length && isLoadingmore)
                        ? simmerSingleProduct(context)
                        : productItem(
                        index, index % 2 == 0 ? true : false);
                  },
                )),
          ),
        ],
      );
  }

  Widget _tags() {
    if (tagList != null && tagList!.length > 0) {
      List<Widget> chips = [];
      for (int i = 0; i < tagList!.length; i++) {
        tagChip = ChoiceChip(
          selected: false,
          label: Text(tagList![i],
              style: TextStyle(color: Theme.of(context).colorScheme.white)),
          backgroundColor: colors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25))),
          onSelected: (bool selected) {
            if (selected) if (mounted)
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductList(
                      name: tagList![i],
                      tag: true,
                      subList: [],
                      fromSeller: false,
                    ),
                  ));
          },
        );

        chips.add(Padding(
            padding: EdgeInsets.symmetric(horizontal: 5), child: tagChip));
      }

      return Container(
        height: 50,
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: chips),
      );
    } else {
      return Container();
    }
  }

  filterOptions() {
    return Container(
      color: Theme.of(context).colorScheme.gray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: filterDialog,
            icon: Icon(
              Icons.filter_list,
              color: colors.primary,
            ),
            label: Text(
              getTranslated(context, 'FILTER')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: sortDialog,
            icon: Icon(
              Icons.swap_vert,
              color: colors.primary,
            ),
            label: Text(
              getTranslated(context, 'SORT_BY')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
          InkWell(
            child: Icon(
              listType ? Icons.grid_view : Icons.list,
              color: colors.primary,
            ),
            onTap: () {
              RestProductList.length != 0
                  ? setState(() {
                listType = !listType;
              })
                  : null;
            },
          ),
        ],
      ),
    );
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                    padding: const EdgeInsetsDirectional.only(top: 30.0),
                    child: AppBar(
                      title: Text(
                        getTranslated(context, 'FILTER')!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                      ),
                      centerTitle: true,
                      elevation: 5,
                      backgroundColor: Theme.of(context).colorScheme.white,
                      leading: Builder(builder: (BuildContext context) {
                        return Container(
                          margin: EdgeInsets.all(10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () => Navigator.of(context).pop(),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(end: 4.0),
                              child: Icon(Icons.arrow_back_ios_rounded,
                                  color: colors.primary),
                            ),
                          ),
                        );
                      }),
                    )),
                Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.lightWhite,
                      padding:
                      EdgeInsetsDirectional.only(start: 7.0, end: 7.0, top: 7.0),
                      child: filterList != null
                          ? ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsetsDirectional.only(top: 10.0),
                          itemCount: filterList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                children: [
                                  Container(
                                      width: deviceWidth,
                                      child: Card(
                                          elevation: 0,
                                          child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Price Range',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle1!
                                                    .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .lightBlack,
                                                    fontWeight:
                                                    FontWeight.normal),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              )))),
                                  RangeSlider(
                                    values: _currentRangeValues!,
                                    min: double.parse(minPrice),
                                    max: double.parse(maxPrice),
                                    divisions: 10,
                                    labels: RangeLabels(
                                      _currentRangeValues!.start.round().toString(),
                                      _currentRangeValues!.end.round().toString(),
                                    ),
                                    onChanged: (RangeValues values) {
                                      setState(() {
                                        _currentRangeValues = values;
                                      });
                                    },
                                  ),
                                ],
                              );
                            } else {
                              index = index - 1;
                              attsubList =
                                  filterList[index]['attribute_values'].split(',');

                              attListId = filterList[index]['attribute_values_id']
                                  .split(',');

                              List<Widget?> chips = [];
                              List<String> att =
                              filterList[index]['attribute_values']!.split(',');

                              List<String> attSType =
                              filterList[index]['swatche_type'].split(',');

                              List<String> attSValue =
                              filterList[index]['swatche_value'].split(',');

                              for (int i = 0; i < att.length; i++) {
                                Widget itemLabel;
                                if (attSType[i] == "1") {
                                  String clr = (attSValue[i].substring(1));

                                  String color = "0xff" + clr;

                                  itemLabel = Container(
                                    width: 25,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(int.parse(color))),
                                  );
                                } else if (attSType[i] == "2") {
                                  itemLabel = ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.network(attSValue[i],
                                          width: 80,
                                          height: 80,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                              erroWidget(80)));
                                } else {
                                  itemLabel = Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(att[i],
                                        style: TextStyle(
                                            color:
                                            selectedId.contains(attListId![i])
                                                ? Theme.of(context)
                                                .colorScheme
                                                .white
                                                : Theme.of(context)
                                                .colorScheme
                                                .fontColor)),
                                  );
                                }

                                choiceChip = ChoiceChip(
                                  selected: selectedId.contains(attListId![i]),
                                  label: itemLabel,
                                  labelPadding: EdgeInsets.all(0),
                                  selectedColor: colors.primary,
                                  backgroundColor:
                                  Theme.of(context).colorScheme.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        attSType[i] == "1" ? 100 : 10),
                                    side: BorderSide(
                                        color: selectedId.contains(attListId![i])
                                            ? colors.primary
                                            : colors.black12,
                                        width: 1.5),
                                  ),
                                  onSelected: (bool selected) {
                                    attListId = filterList[index]
                                    ['attribute_values_id']
                                        .split(',');

                                    if (mounted)
                                      setState(() {
                                        if (selected == true) {
                                          selectedId.add(attListId![i]);
                                        } else {
                                          selectedId.remove(attListId![i]);
                                        }
                                      });
                                  },
                                );

                                chips.add(choiceChip);
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: deviceWidth,
                                    child: Card(
                                      elevation: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: new Text(
                                          filterList[index]['name'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.normal),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  chips.length > 0
                                      ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: new Wrap(
                                      children:
                                      chips.map<Widget>((Widget? chip) {
                                        return Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: chip,
                                        );
                                      }).toList(),
                                    ),
                                  )
                                      : Container()

                                  /*    (filter == filterList[index]["name"])
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      NeverScrollableScrollPhysics(),
                                  itemCount: attListId!.length,
                                  itemBuilder: (context, i) {

                                    */ /*       return CheckboxListTile(
                                  dense: true,
                                  title: Text(attsubList![i],
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1!
                                          .copyWith(
                                              color: Theme.of(context).colorScheme.lightBlack,
                                              fontWeight:
                                                  FontWeight.normal)),
                                  value: selectedId
                                      .contains(attListId![i]),
                                  activeColor: colors.primary,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (bool? val) {
                                    if (mounted)
                                      setState(() {
                                        if (val == true) {
                                          selectedId.add(attListId![i]);
                                        } else {
                                          selectedId
                                              .remove(attListId![i]);
                                        }
                                      });
                                  },
                                );*/ /*
                                  })
                              : Container()*/
                                ],
                              );
                            }
                          })
                          : Container(),
                    )),
                Container(
                  color: Theme.of(context).colorScheme.white,
                  child: Row(children: <Widget>[
                    Container(
                      margin: EdgeInsetsDirectional.only(start: 20),
                      width: deviceWidth! * 0.4,
                      child: OutlinedButton(
                        onPressed: () {
                          if (mounted)
                            setState(() {
                              selectedId.clear();
                            });
                        },
                        child: Text(getTranslated(context, 'DISCARD')!),
                      ),
                    ),
                    Spacer(),
                    SimBtn(
                        size: 0.4,
                        title: getTranslated(context, 'APPLY'),
                        onBtnSelected: () {
                          if (selectedId != null) {
                            selId = selectedId.join(',');
                          }

                          if (mounted)
                            setState(() {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              RestProductList.clear();
                            });
                          getProduct("0");
                          Navigator.pop(context, 'Product Filter');
                        }),
                  ]),
                )
              ]);
            });
      },
    );
  }
}
