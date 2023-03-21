import 'dart:convert';
/// error : true
/// message : "Category does not exist"
/// data : [{"id":"9","name":"Health & Wellness","parent_id":"0","slug":"health-wellness","image":"uploads/media/2022/Health_Wellness.jpg","banner":null,"row_order":"0","status":"1","clicks":"33"}]

HealthCategoryModel healthCategoryModelFromJson(String str) => HealthCategoryModel.fromJson(json.decode(str));
String healthCategoryModelToJson(HealthCategoryModel data) => json.encode(data.toJson());
class HealthCategoryModel {
  HealthCategoryModel({
      bool? error, 
      String? message, 
      List<Data>? data,}){
    _error = error;
    _message = message;
    _data = data;
}

  HealthCategoryModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _error;
  String? _message;
  List<Data>? _data;
HealthCategoryModel copyWith({  bool? error,
  String? message,
  List<Data>? data,
}) => HealthCategoryModel(  error: error ?? _error,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get error => _error;
  String? get message => _message;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : "9"
/// name : "Health & Wellness"
/// parent_id : "0"
/// slug : "health-wellness"
/// image : "uploads/media/2022/Health_Wellness.jpg"
/// banner : null
/// row_order : "0"
/// status : "1"
/// clicks : "33"

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());
class Data {
  Data({
      String? id, 
      String? name, 
      String? parentId, 
      String? slug, 
      String? image, 
      dynamic banner, 
      String? rowOrder, 
      String? status, 
      String? clicks,}){
    _id = id;
    _name = name;
    _parentId = parentId;
    _slug = slug;
    _image = image;
    _banner = banner;
    _rowOrder = rowOrder;
    _status = status;
    _clicks = clicks;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _parentId = json['parent_id'];
    _slug = json['slug'];
    _image = json['image'];
    _banner = json['banner'];
    _rowOrder = json['row_order'];
    _status = json['status'];
    _clicks = json['clicks'];
  }
  String? _id;
  String? _name;
  String? _parentId;
  String? _slug;
  String? _image;
  dynamic _banner;
  String? _rowOrder;
  String? _status;
  String? _clicks;
Data copyWith({  String? id,
  String? name,
  String? parentId,
  String? slug,
  String? image,
  dynamic banner,
  String? rowOrder,
  String? status,
  String? clicks,
}) => Data(  id: id ?? _id,
  name: name ?? _name,
  parentId: parentId ?? _parentId,
  slug: slug ?? _slug,
  image: image ?? _image,
  banner: banner ?? _banner,
  rowOrder: rowOrder ?? _rowOrder,
  status: status ?? _status,
  clicks: clicks ?? _clicks,
);
  String? get id => _id;
  String? get name => _name;
  String? get parentId => _parentId;
  String? get slug => _slug;
  String? get image => _image;
  dynamic get banner => _banner;
  String? get rowOrder => _rowOrder;
  String? get status => _status;
  String? get clicks => _clicks;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['parent_id'] = _parentId;
    map['slug'] = _slug;
    map['image'] = _image;
    map['banner'] = _banner;
    map['row_order'] = _rowOrder;
    map['status'] = _status;
    map['clicks'] = _clicks;
    return map;
  }

}