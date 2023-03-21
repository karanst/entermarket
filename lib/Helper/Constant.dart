import 'package:shared_preferences/shared_preferences.dart';

const String appName = 'Entemarket';

const String packageName = 'com.ente_market';
const String androidLink = "https://play.google.com/store/apps/details?id=com.entemarket.user";
    //'https://play.google.com/store/apps/details?id=';

const String iosPackage = 'com.ente_market';
const String iosLink = 'your ios link here';
const String appStoreId = '123456789';

const String deepLinkUrlPrefix = 'https://alpha.ecommerce.link';
const String deepLinkName = 'alpha.ecommerce.link';

const int timeOut = 100;
const int perPage = 10;
String razorPayKey="rzp_test_UUBtmcArqOLqIY";
String razorPaySecret="NTW3MUbXOtcwUrz5a4YCshqk";
//final String baseUrl = 'https://alphawizztest.tk/ENTEMARKET/app/v1/api/';
const String baseUrl = 'https://entemarket.com/app/v1/api/';
const String imageUrl = 'https://entemarket.com/';
const String jwtKey = "78084f1698c9fcff5a668b68dcd103db39be2605";
class App {
  static late SharedPreferences localStorage;
  static Future init() async {
    localStorage = await SharedPreferences.getInstance();
  }
}
