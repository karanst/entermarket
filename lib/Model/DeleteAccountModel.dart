/// error : false
/// message : "Account deleted success!"
/// date : []

class DeleteAccountModel {
  DeleteAccountModel({
      bool? error, 
      String? message, 
      List<dynamic>? date,}){
    _error = error;
    _message = message;
    _date = date;
}

  DeleteAccountModel.fromJson(dynamic json) {
    _error = json['error'];
    _message = json['message'];
    if (json['date'] != null) {
      _date = [];
      json['date'].forEach((v) {
        _date?.add(v.fromJson(v));
      });
    }
  }
  bool? _error;
  String? _message;
  List<dynamic>? _date;
DeleteAccountModel copyWith({  bool? error,
  String? message,
  List<dynamic>? date,
}) => DeleteAccountModel(  error: error ?? _error,
  message: message ?? _message,
  date: date ?? _date,
);
  bool? get error => _error;
  String? get message => _message;
  List<dynamic>? get date => _date;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['error'] = _error;
    map['message'] = _message;
    if (_date != null) {
      map['date'] = _date?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}