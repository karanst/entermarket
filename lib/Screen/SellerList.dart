import 'package:cached_network_image/cached_network_image.dart';
import 'package:entemarket_user/Helper/Color.dart';
import 'package:entemarket_user/Helper/Session.dart';
import 'package:entemarket_user/Helper/String.dart';
import 'package:entemarket_user/Model/Section_Model.dart';
import 'package:entemarket_user/Screen/starting_view/SubCategory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'HomePage.dart';
import 'Seller_Details.dart';

class SellerList extends StatefulWidget {
  final catId;
  final subId;
  final catName;
  final getByLocation;
  List<Product> sellerList;
   SellerList(
      {Key? key, this.catId, this.subId, this.catName, this.getByLocation,required this.sellerList})
      : super(key: key);

  @override
  _SellerListState createState() => _SellerListState();
}

class _SellerListState extends State<SellerList> {
  bool loading = true;
  List<Product> sellerList=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.sellerList.length>0){
      loading = false;
      sellerList=widget.sellerList.toList();
    }else{
      getSeller();
    }

  }
  void getSeller() {
    Map parameter = {
      "category_id":widget.catId,
    };
    if(latitudeHome!=null){
      parameter = {
        "category_id":widget.catId,
        "lat" : latitudeHome.toString(),
        "long":longitudeHome.toString(),
      };
    }
    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        setState(() {
          loading=false;
          sellerList =
              (data as List).map((data) => Product.fromSeller(data)).toList();
        });

      } else {
        // setSnackbar(msg!);
        Fluttertoast.showToast(
            msg: msg!,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: colors.primary,
            textColor: Colors.white,
            fontSize: 16.0
        );

      }
    }, onError: (error) {
      setSnackbar(error.toString());
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(widget.catName!=""?widget.catName:getTranslated(context, 'SHOP_BY_SELLER')!, context),
        body: !loading&&sellerList.length>0?ListView.builder(
          itemCount: sellerList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
                return listItem(index);
              },
            ):const Center(child: CircularProgressIndicator()));
  }
  Widget listItem(int index) {
    if (index < sellerList.length) {
      Product model = sellerList[index];
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
                              borderRadius: const BorderRadius.only(
                                  topLeft: const Radius.circular(10),
                                  bottomLeft: const Radius.circular(10)),
                              child: Stack(
                                children: [
                                  FadeInImage(
                                    image: CachedNetworkImageProvider(
                                        sellerList[index].seller_profile!),
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
                                sellerList[index].seller_name!,
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
                              const SizedBox(height: 5,),
                              Text(
                                calculateDistance(latitudeHome, longitudeHome, model.latitude, model.longitude),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,fontSize: 10.sp,),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5,),
                              Container(
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
                                ),
                              ),
                              const SizedBox(height: 5,),
                              Container(
                                child: sellerList[index].openCloseStatus! == 0
                                    ? Text(
                                   "Not Accepting Orders",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,),
                                  overflow: TextOverflow.ellipsis,
                                )
                                    : Text(
                                  "Open",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ]),
                onTap: () {
                  if(sellerList[index].openCloseStatus! == 1){
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
                              catId: widget.catId
                              // sellerList[index].category_ids!.contains(",")?sellerList[index].category_ids!.split(",")[0]:sellerList[index].category_ids!,
                            )));
                  } else{
                    setSnackbar("Seller Closed");
                  }
                },
              ),
            ),
          ],
        ),
      );
    } else
      return Container();
  }
  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.black),
      ),
      backgroundColor: Theme.of(context).colorScheme.white,
      elevation: 1.0,
    ));
  }

  Widget catItem(int index, BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: FadeInImage(
                    image: CachedNetworkImageProvider(
                        sellerList[index].seller_profile!),
                    fadeInDuration: const Duration(milliseconds: 150),
                    fit: BoxFit.fill,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        erroWidget(50),
                    placeholder: placeHolder(50),
                  )),
            ),
          ),
          Text(
            sellerList[index].seller_name! + "\n",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(color: Theme.of(context).colorScheme.fontColor),
          )
        ],
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SellerProfile(
                      sellerStoreName: sellerList[index].store_name ?? "",
                      sellerRating: sellerList[index].seller_rating ?? "",
                      sellerImage: sellerList[index].seller_profile ?? "",
                      sellerName: sellerList[index].seller_name ?? "",
                      sellerID: sellerList[index].seller_id,
                      storeDesc: sellerList[index].store_description,
                    )));
      },
    );
  }
}
