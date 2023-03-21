import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:entemarket_user/Helper/ApiBaseHelper.dart';
import 'package:entemarket_user/Helper/Color.dart';
import 'package:entemarket_user/Helper/Session.dart';
import 'package:entemarket_user/Helper/String.dart';
import 'package:entemarket_user/Model/Section_Model.dart';
import 'package:entemarket_user/Provider/FavoriteProvider.dart';
import 'package:entemarket_user/Screen/Login.dart';
import 'package:entemarket_user/Screen/ProductList.dart';
import 'package:entemarket_user/Screen/Product_Detail.dart';
import 'package:entemarket_user/Screen/Seller_Details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubCategory extends StatefulWidget {
  final String title;
  final sellerId;
  final catId;
  final sellerData;

  const SubCategory(
      {Key? key,
      required this.title,
      this.sellerId,
      this.sellerData,
      this.catId})
      : super(key: key);

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  dynamic subCatData = [];
  var recommendedProductsData = [];
  bool mount = false;
  var newData;
  StreamController<dynamic> productStream = StreamController();
  var imageBase = "https://entemarket.com/";
  List<TextEditingController> _controller = [];
  bool _isLoading = true, _isProgress = false;
  bool _isNetworkAvail = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.catId);
    print(widget.sellerId);
    getSubCategory(widget.sellerId, widget.catId);
  }

  @override
  void dispose() {
    super.dispose();
    productStream.close();
  }

  @override
  Widget build(BuildContext context) {
    print(imageBase);
    return Scaffold(
      appBar: getAppBar(widget.title, context),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 60,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width / 40,
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Category',
                style: TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 150,
            ),
            mount
                ? subCatData.isNotEmpty
                    ? Container(
                     margin: const EdgeInsets.all(10),
                      child: GridView.builder(
                          itemCount: subCatData.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: (){
                            /*  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SellerProfile(
                                        search: false,
                                        sellerID: widget.sellerId,
                                        subCatId: subCatData[index]["id"],
                                        sellerData: widget.sellerData,
                                        sellerImage: widget.sellerData.seller_profile,
                                        sellerName: widget.title,
                                        sellerStoreName: widget.sellerData.store_name,
                                        sellerRating: widget.sellerData.rating.toString(),
                                        storeDesc: widget.sellerData.store_description,
                                      )));*/
                            },
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(5),topLeft: const Radius.circular(5)),
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height*0.15,
                                      child: Image(
                                        height: MediaQuery.of(context).size.height*0.15,
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                            "$imageBase${subCatData[index]["image"] ?? ""}"),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10.0,),
                                  Text(subCatData[index]["name"] ?? ""),
                                ],
                              )
                            ),
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                          ),
                        ),
                    )
                    : const Center(child: Text("No Sub Category"))
                : const Text(""),
          ],
        ),
      ),
    );
  }

  List<SubModel> subList = [];
  getSubCategory(sellerId, catId) async {
    var parm = {};
    if (catId != null) {
      parm = {"seller_id": "$sellerId", "cat_id": "$catId"};
    } else {
      parm = {"seller_id": "$sellerId"};
    }

    apiBaseHelper.postAPICall(getSubCatBySellerId, parm).then((value) {
      setState(() {
        subCatData = value["data"];
        for(int i =0;i<subCatData.length;i++){
          setState(() {
            subList.add(SubModel(subCatData[i]['id'], subCatData[i]["name"]));
          });
        }
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProductList(
                name: widget.title,
                id: widget.sellerId,
                subCatId: widget.catId,
                subList: subList,
                tag: false,
                fromSeller: false,
              ),
            ));
       // imageBase = value["image_path"];
        mount = true;
      });
    });
  }

  onTapGoDetails({response, index}) {
    Product model = Product.fromJson(response["data"][0]);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetail(
              index: index,
              model: model,
              secPos: 0,
              list: false,
            )));
  }
}
class SubModel{
  String id,name;

  SubModel(this.id, this.name);
}