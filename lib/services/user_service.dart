import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/response_data_map.dart';
import '../models/user_login.dart';
import 'url.dart' as url;

class UserService {

  // ================= LOGIN =================

  Future loginUser(data) async {

    var uri = Uri.parse(url.baseUrl + "/auth");

    var response = await http.post(
      uri,

      headers: {
        "Content-Type": "application/json",
        "app-key": url.appKey,
      },

      body: jsonEncode(data),
    );

    print(response.body);

    if (response.statusCode == 200) {

      var data = json.decode(response.body);

      UserLogin userLogin = UserLogin(
        status: true,
        token: data["token"],
        message: "Login berhasil",
        id: data["data"]["id"],
        username: data["data"]["username"],
        role: data["data"]["role"],
        name: data["data"]["name"],
      );

      await userLogin.prefs();

      ResponseDataMap responseData =
          ResponseDataMap(
        status: true,
        message: "Sukses login",
        data: data,
      );

      return responseData;

    } else {

      ResponseDataMap responseData =
          ResponseDataMap(
        status: false,
        message: "Username atau password salah",
      );

      return responseData;
    }
  }

  // ================= REGISTER ADMIN =================

  Future registerAdmin(data) async {

    var uri = Uri.parse(url.baseUrl + "/admins");

    var response = await http.post(
      uri,

      headers: {
        "Content-Type": "application/json",
        "app-key": url.appKey,
      },

      body: jsonEncode(data),
    );

    print(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {

      var data = json.decode(response.body);

      ResponseDataMap responseData =
          ResponseDataMap(
        status: true,
        message: "Admin berhasil dibuat",
        data: data,
      );

      return responseData;

    } else {

      ResponseDataMap responseData =
          ResponseDataMap(
        status: false,
        message: "Gagal register admin",
      );

      return responseData;
    }
  }

  // ================= GET PROFILE =================

  Future getProfile(token) async {

    var uri = Uri.parse(url.baseUrl + "/profile");

    var response = await http.get(
      uri,

      headers: {
        "Authorization": "Bearer $token",
        "app-key": url.appKey,
      },
    );

    print(response.body);

    if (response.statusCode == 200) {

      var data = json.decode(response.body);

      ResponseDataMap responseData =
          ResponseDataMap(
        status: true,
        message: "Berhasil ambil profile",
        data: data,
      );

      return responseData;

    } else {

      ResponseDataMap responseData =
          ResponseDataMap(
        status: false,
        message: "Gagal ambil profile",
      );

      return responseData;
    }
  }

  // ================= LOGOUT =================

  Future logout() async {

    UserLogin user = UserLogin();

    await user.logout();
  }
}