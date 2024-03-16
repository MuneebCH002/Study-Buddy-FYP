import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  //keys
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";

  // saving the data to SF

  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSF(String userName) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userNameKey, userName);
  }

  static Future<bool> saveUserEmailSF(String userEmail) async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return await sf.setString(userEmailKey, userEmail);
  }

  // getting the data from SF

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getBool(userLoggedInKey);
  }

  static Future<String?> getUserEmailFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userEmailKey);
  }

  static Future<String?> getUserNameFromSF() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey);
  }

  static Future<bool> nameExist() async {
    SharedPreferences sf = await SharedPreferences.getInstance();
    return sf.getString(userNameKey) != null;
  }

  static bool validateEmail(String email) {
    final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  static bool validatePassword(String password) {

    // Check for at least one uppercase letter
    bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    if (!hasUppercase) {
      return false;
    }

    // Check for at least one lowercase letter
    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    if (!hasLowercase) {
      return false;
    }

    // Check for at least one digit
    bool hasDigit = password.contains(new RegExp(r'[0-9]'));
    if (!hasDigit) {
      return false;
    }

    // Check for at least one special character
    bool hasSpecialChar = password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (!hasSpecialChar) {
      return false;
    }

    // Password passed all checks
    return true;
  }


}
