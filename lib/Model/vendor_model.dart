import 'dart:convert';

class VendorModel {
  VendorModel({
    required this.id,
    required this.userId,
    required this.slug,
    required this.categoryIds,
    required this.storeName,
    required this.storeDescription,
    required this.logo,
    required this.storeUrl,
    required this.noOfRatings,
    required this.rating,
    required this.sellerRating,
    required this.bankName,
    required this.bankCode,
    required this.accountName,
    required this.accountNumber,
    required this.crossedCheque,
    required this.nationalIdentityCard,
    required this.addressProof,
    required this.idProof,
    required this.gstImage,
    required this.gstNumber,
    required this.foodLicenseImgae,
    required this.panNumber,
    required this.taxName,
    required this.taxNumber,
    required this.permissions,
    required this.commission,
    required this.minimumOrderAmount,
    required this.status,
    required this.dateAdded,
    required this.ipAddress,
    required this.username,
    required this.password,
    required this.email,
    required this.mobile,
    required this.image,
    required this.balance,
    required this.activationSelector,
    required this.activationCode,
    required this.forgottenPasswordSelector,
    required this.forgottenPasswordCode,
    required this.forgottenPasswordTime,
    required this.rememberSelector,
    required this.rememberCode,
    required this.createdOn,
    required this.lastLogin,
    required this.active,
    required this.company,
    required this.address,
    required this.bonus,
    required this.cashReceived,
    required this.dob,
    required this.countryCode,
    required this.city,
    required this.area,
    required this.street,
    required this.pincode,
    required this.serviceableZipcodes,
    required this.apikey,
    required this.referralCode,
    required this.friendsCode,
    required this.fcmId,
    required this.latitude,
    required this.longitude,
    required this.landmark,
    required this.nearByLocation,
    required this.createdAt,
    required this.cityName,
    required this.openClose,
    required this.deliveryTime
  });
  late final String id;
  late final String userId;
  late final String slug;
  late final String categoryIds;
  late final String storeName;
  late final String storeDescription;
  late final String logo;
  late final String storeUrl;
  late final String noOfRatings;
  late final String rating;
  late final String sellerRating;
  late final String bankName;
  late final String bankCode;
  late final String accountName;
  late final String accountNumber;
  late final String crossedCheque;
  late final String nationalIdentityCard;
  late final String addressProof;
  late final String idProof;
  late final String gstImage;
  late final String gstNumber;
  late final String foodLicenseImgae;
  late final String panNumber;
  late final String taxName;
  late final String taxNumber;
  late final Map permissions;
  late final String commission;
  late final String minimumOrderAmount;
  late final String status;
  late final String dateAdded;
  late final String ipAddress;
  late final String username;
  late final String password;
  late final String email;
  late final String mobile;
  late final String image;
  late final String balance;
  late final String activationSelector;
  late final String activationCode;
  late final String forgottenPasswordSelector;
  late final String forgottenPasswordCode;
  late final String forgottenPasswordTime;
  late final String rememberSelector;
  late final String rememberCode;
  late final String createdOn;
  late final String lastLogin;
  late final String active;
  late final String company;
  late final String address;
  late final String bonus;
  late final String cashReceived;
  late final String dob;
  late final String countryCode;
  late final String city;
  late final String area;
  late final String street;
  late final String pincode;
  late final String serviceableZipcodes;
  late final String apikey;
  late final String referralCode;
  late final String friendsCode;
  late final String fcmId;
  late final String latitude;
  late final String longitude;
  late final String landmark;
  late final String nearByLocation;
  late final String createdAt;
  late final String cityName;
  late final int openClose;
  late final String sellerId;
  late final String deliveryTime;

  VendorModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    userId = json['user_id'];
    slug = json['slug'];
    sellerId = json["seller_id"];
    categoryIds = json['category_ids'];
    storeName = json['store_name'];
    storeDescription = json['store_description'];
    logo = json['seller_profile'];
    storeUrl = json['store_url'];
    noOfRatings = json['no_of_ratings'];
    sellerRating = json['seller_rating'];
    rating = json['rating'];
    bankName = json['bank_name'];
    bankCode = json['bank_code'];
    accountName = json['account_name'];
    accountNumber = json['account_number'];
    crossedCheque = json['crossed_cheque'];
    nationalIdentityCard = json['national_identity_card'];
    addressProof = json['address_proof'];
    idProof = json['id_proof'];
    gstImage = json['gst_image'];
    gstNumber = json['gst_number'];
    foodLicenseImgae = json['food_license_imgae'];
    panNumber = json['pan_number'];
    taxName = json['tax_name'];
    taxNumber = json['tax_number'];
    // permissions = jsonDecode(json['permissions']);
    commission = json['commission'];
    minimumOrderAmount = json['minimum_order_amount'];
    status = json['status'];
    dateAdded = json['date_added'];
    ipAddress = json['ip_address'];
    username = json['username'];
    password = json['password'];
    email = json['email'];
    mobile = json['mobile'];
    image = json['image'];
    balance = json['balance'];
    activationSelector = json['activation_selector'];
    activationCode = json['activation_code'];
    forgottenPasswordSelector = json['forgotten_password_selector'];
    forgottenPasswordCode = json['forgotten_password_code'];
    forgottenPasswordTime = json['forgotten_password_time'];
    rememberSelector = json['remember_selector'];
    rememberCode = json['remember_code'];
    createdOn = json['created_on'];
    lastLogin = json['last_login'];
    active = json['active'];
    company = json['company'];
    address = json['address'];
    bonus = json['bonus'];
    cashReceived = json['cash_received'];
    dob = json['dob'];
    countryCode = json['country_code'];
    city = json['city'];
    area = json['area'];
    street = json['street'];
    pincode = json['pincode'];
    serviceableZipcodes = json['serviceable_zipcodes'];
    apikey = json['apikey'];
    referralCode = json['referral_code'];
    friendsCode = json['friends_code'];
    fcmId = json['fcm_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    landmark = json['landmark'];
    nearByLocation = json['near_by_location'];
    createdAt = json['created_at'];
    cityName = json['city_name'];
    openClose = json['open_close_status'];
    deliveryTime = json['delivery_tiem'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['slug'] = slug;
    _data['category_ids'] = categoryIds;
    _data['store_name'] = storeName;
    _data['store_description'] = storeDescription;
    _data['seller_profile'] = logo;
    _data['store_url'] = storeUrl;
    _data['no_of_ratings'] = noOfRatings;
    _data['seller_rating'] = sellerRating;
    _data['rating'] = rating;
    _data['bank_name'] = bankName;
    _data['bank_code'] = bankCode;
    _data['account_name'] = accountName;
    _data['account_number'] = accountNumber;
    _data['crossed_cheque'] = crossedCheque;
    _data['national_identity_card'] = nationalIdentityCard;
    _data['address_proof'] = addressProof;
    _data['id_proof'] = idProof;
    _data['gst_image'] = gstImage;
    _data['gst_number'] = gstNumber;
    _data['food_license_imgae'] = foodLicenseImgae;
    _data['pan_number'] = panNumber;
    _data['tax_name'] = taxName;
    _data['tax_number'] = taxNumber;
    _data['permissions'] = permissions;
    _data['commission'] = commission;
    _data['minimum_order_amount'] = minimumOrderAmount;
    _data['status'] = status;
    _data['date_added'] = dateAdded;
    _data['ip_address'] = ipAddress;
    _data['username'] = username;
    _data['password'] = password;
    _data['email'] = email;
    _data['mobile'] = mobile;
    _data['seller_id'] = sellerId;
    _data['image'] = image;
    _data['balance'] = balance;
    _data['activation_selector'] = activationSelector;
    _data['activation_code'] = activationCode;
    _data['forgotten_password_selector'] = forgottenPasswordSelector;
    _data['forgotten_password_code'] = forgottenPasswordCode;
    _data['forgotten_password_time'] = forgottenPasswordTime;
    _data['remember_selector'] = rememberSelector;
    _data['remember_code'] = rememberCode;
    _data['created_on'] = createdOn;
    _data['last_login'] = lastLogin;
    _data['active'] = active;
    _data['company'] = company;
    _data['address'] = address;
    _data['bonus'] = bonus;
    _data['cash_received'] = cashReceived;
    _data['dob'] = dob;
    _data['country_code'] = countryCode;
    _data['city'] = city;
    _data['area'] = area;
    _data['street'] = street;
    _data['pincode'] = pincode;
    _data['serviceable_zipcodes'] = serviceableZipcodes;
    _data['apikey'] = apikey;
    _data['referral_code'] = referralCode;
    _data['friends_code'] = friendsCode;
    _data['fcm_id'] = fcmId;
    _data['latitude'] = latitude;
    _data['longitude'] = longitude;
    _data['landmark'] = landmark;
    _data['near_by_location'] = nearByLocation;
    _data['created_at'] = createdAt;
    _data['city_name'] = cityName;
    _data['delivery_tiem'] = deliveryTime;
    _data['open_close_status'] = openClose;
    return _data;
  }
}
class PharmacyOrderModel {
  PharmacyOrderModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.description,
    required this.image,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.amount,
    required this.status,
    required this.address,
    required this.rating,
    required this.userId,
  });
  late final String id;
  late final String sellerId;
  late final String name;
  late final String email;
  late final String phone;
  late final String description;
  late final String image;
  late final String message;
  late final String createdAt;
  late final String updatedAt;
  late final String amount;
  late final String status;
  late final String address;
  late final String rating;
  late final String userId;

  PharmacyOrderModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    sellerId = json['seller_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    description = json['description'];
    image = json['image'];
    message = json['message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    amount = json['amount'];
    status = json['status'];
    address = json['address'];
    rating = json['rating'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['seller_id'] = sellerId;
    _data['name'] = name;
    _data['email'] = email;
    _data['phone'] = phone;
    _data['description'] = description;
    _data['image'] = image;
    _data['message'] = message;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['amount'] = amount;
    _data['status'] = status;
    _data['address'] = address;
    _data['user_id'] = userId;
    _data['rating'] = rating;
    return _data;
  }
}
class FeatureProductModel {
  FeatureProductModel({
    required this.id,
    required this.name,
    required this.productId,
    required this.startDate,
    required this.endDate,
    required this.productName,
    required this.price,
    required this.description,
    required this.productImage,
    required this.store_name,
  });
  late final String id;
  late final String name;
  late final String productId;
  late final String startDate;
  late final String endDate;
  late final String productName;
  late final String price;
  late final String description;
  late final String productImage;
  late final String store_name;

  FeatureProductModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    productId = json['product_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    productName = json['product_name'];
    price = json['price'];
    description = json['description'];
    productImage = json['product_image'];
    store_name = json['store_name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['product_id'] = productId;
    _data['start_date'] = startDate;
    _data['end_date'] = endDate;
    _data['product_name'] = productName;
    _data['price'] = price;
    _data['description'] = description;
    _data['product_image'] = productImage;
    return _data;
  }
}
class FeatureOrderModel {
  FeatureOrderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.description,
    required this.phone,
    required this.productId,
    required this.createdAt,
    required this.userId,
    required this.qty,
    required this.startDate,
    required this.endDate,
    required this.productName,
    required this.price,
    required this.productImage,
    required this.total_amount,
  });
  late final String id;
  late final String name;
  late final String email;
  late final String description;
  late final String phone;
  late final String productId;
  late final String createdAt;
  late final String userId;
  late final String qty;
  late final String startDate;
  late final String endDate;
  late final String productName;
  late final String price;
  late final String productImage;
  late final String total_amount;
  FeatureOrderModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    email = json['email'];
    description = json['description'];
    phone = json['phone'];
    productId = json['product_id'];
    createdAt = json['created_at'];
    userId = json['user_id'];
    qty = json['qty'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    productName = json['product_name'];
    price = json['price'];
    productImage = json['product_image'];
    total_amount = json['total_amount'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['email'] = email;
    _data['description'] = description;
    _data['phone'] = phone;
    _data['product_id'] = productId;
    _data['created_at'] = createdAt;
    _data['user_id'] = userId;
    _data['qty'] = qty;
    _data['start_date'] = startDate;
    _data['end_date'] = endDate;
    _data['product_name'] = productName;
    _data['price'] = price;
    _data['product_image'] = productImage;
    return _data;
  }
}
class RestProductModel {
  RestProductModel({
    required this.id,
    this.productIdentity,
    required this.categoryId,
    required this.sellerId,
    required this.tax,
    required this.rowOrder,
    required this.type,
    this.stockType,
    required this.name,
    required this.shortDescription,
    required this.slug,
    required this.indicator,
    required this.codAllowed,
    required this.minimumOrderQuantity,
    required this.quantityStepSize,
    this.totalAllowedQuantity,
    required this.isPricesInclusiveTax,
    required this.isReturnable,
    required this.isCancelable,
    required this.cancelableTill,
    required this.image,
    required this.otherImages,
    required this.videoType,
    required this.video,
    required this.tags,
    required this.warrantyPeriod,
    required this.guaranteePeriod,
    required this.madeIn,
    this.sku,
    this.stock,
    this.availability,
    required this.sellerRating,
    required this.rating,
    required this.noOfRatings,
    required this.description,
    required this.deliverableType,
    this.deliverableZipcodes,
    required this.status,
    required this.isFeatured,
    required this.dateAdded,
  });
  late final String id;
  late final Null productIdentity;
  late final String categoryId;
  late final String sellerId;
  late final String tax;
  late final String rowOrder;
  late final String type;
  late final Null stockType;
  late final String name;
  late final String shortDescription;
  late final String slug;
  late final String indicator;
  late final String codAllowed;
  late final String minimumOrderQuantity;
  late final String quantityStepSize;
  late final Null totalAllowedQuantity;
  late final String isPricesInclusiveTax;
  late final String isReturnable;
  late final String isCancelable;
  late final String cancelableTill;
  late final String image;
  late final String otherImages;
  late final String videoType;
  late final String video;
  late final String tags;
  late final String warrantyPeriod;
  late final String guaranteePeriod;
  late final String madeIn;
  late final Null sku;
  late final Null stock;
  late final Null availability;
  late final String sellerRating;
  late final String rating;
  late final String noOfRatings;
  late final String description;
  late final String deliverableType;
  late final Null deliverableZipcodes;
  late final String status;
  late final String isFeatured;
  late final String dateAdded;

  RestProductModel.fromJson(Map<String, dynamic> json){
    id = json['id'];
    productIdentity = null;
    categoryId = json['category_id'];
    sellerId = json['seller_id'];
    tax = json['tax'];
    rowOrder = json['row_order'];
    type = json['type'];
    stockType = null;
    name = json['name'];
    shortDescription = json['short_description'];
    slug = json['slug'];
    indicator = json['indicator'];
    codAllowed = json['cod_allowed'];
    minimumOrderQuantity = json['minimum_order_quantity'];
    quantityStepSize = json['quantity_step_size'];
    totalAllowedQuantity = null;
    isPricesInclusiveTax = json['is_prices_inclusive_tax'];
    isReturnable = json['is_returnable'];
    isCancelable = json['is_cancelable'];
    cancelableTill = json['cancelable_till'];
    image = json['image'];
    otherImages = json['other_images'];
    videoType = json['video_type'];
    video = json['video'];
    tags = json['tags'];
    warrantyPeriod = json['warranty_period'];
    guaranteePeriod = json['guarantee_period'];
    madeIn = json['made_in'];
    sku = null;
    stock = null;
    availability = null;
    sellerRating = json['seller_rating'];
    rating = json['rating'];
    noOfRatings = json['no_of_ratings'];
    description = json['description'];
    deliverableType = json['deliverable_type'];
    deliverableZipcodes = null;
    status = json['status'];
    isFeatured = json['is_featured'];
    dateAdded = json['date_added'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['product_identity'] = productIdentity;
    _data['category_id'] = categoryId;
    _data['seller_id'] = sellerId;
    _data['tax'] = tax;
    _data['row_order'] = rowOrder;
    _data['type'] = type;
    _data['stock_type'] = stockType;
    _data['name'] = name;
    _data['short_description'] = shortDescription;
    _data['slug'] = slug;
    _data['indicator'] = indicator;
    _data['cod_allowed'] = codAllowed;
    _data['minimum_order_quantity'] = minimumOrderQuantity;
    _data['quantity_step_size'] = quantityStepSize;
    _data['total_allowed_quantity'] = totalAllowedQuantity;
    _data['is_prices_inclusive_tax'] = isPricesInclusiveTax;
    _data['is_returnable'] = isReturnable;
    _data['is_cancelable'] = isCancelable;
    _data['cancelable_till'] = cancelableTill;
    _data['image'] = image;
    _data['other_images'] = otherImages;
    _data['video_type'] = videoType;
    _data['video'] = video;
    _data['tags'] = tags;
    _data['warranty_period'] = warrantyPeriod;
    _data['guarantee_period'] = guaranteePeriod;
    _data['made_in'] = madeIn;
    _data['sku'] = sku;
    _data['stock'] = stock;
    _data['availability'] = availability;
    _data['seller_rating'] = sellerRating;
    _data['no_of_ratings'] = noOfRatings;
    _data['description'] = description;
    _data['deliverable_type'] = deliverableType;
    _data['deliverable_zipcodes'] = deliverableZipcodes;
    _data['status'] = status;
    _data['is_featured'] = isFeatured;
    _data['date_added'] = dateAdded;
    _data['rating'] = rating;
    return _data;
  }
}
