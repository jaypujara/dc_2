import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rcare_2/screen/ClinetHome/ClientHomeScreen.dart';
import 'package:rcare_2/screen/login/ForgotPassword.dart';
import 'package:rcare_2/utils/ConstantStrings.dart';
import 'package:rcare_2/utils/Preferences.dart';


import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/Constants.dart';
import '../../utils/Constants.dart';
import '../../utils/Images.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/methods.dart';
import '../home/HomeScreen.dart';
import 'model/LoginResponseModel.dart';

class Login extends StatefulWidget {
  bool isLoginForBooking = false;

  Login({super.key, this.isLoginForBooking = false});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  ///  * [_keyFormField], key of form of sign form.
  final GlobalKey<FormState> _keyFormField = GlobalKey<FormState>();

  ///  * [_keyForgotFormField], key of form of forgot dialog form.
  final GlobalKey<FormState> _keyForgotFormField = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  String? firebaseToken;
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerCompanyCode = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    _controllerUsername.text =
        (await FlutterKeychain.get(key: "username") ?? "");
    _controllerPassword.text =
        (await FlutterKeychain.get(key: "password") ?? "");
    _controllerCompanyCode.text =
        (await FlutterKeychain.get(key: "companycode") ?? "");
  }

  _loginApiCall(String username, String password, String comapanyCode) {
    closeKeyboard();

    if(comapanyCode == "nhc"){
      String cName = "nhc-northside";
      baseUrlWithHttp ="https://$cName-web.mycaresoftware.com/";
      baseUrl = '$cName-web.mycaresoftware.com';
      nestedUrl = 'MobileAPI/v1.asmx/';
      masterURL = "https://$cName-web.mycaresoftware.com/MobileAPI/v1.asmx/";
    }
    else{
      baseUrlWithHttp ="https://$comapanyCode-web.mycaresoftware.com/";
      baseUrl = '$comapanyCode-web.mycaresoftware.com';
      nestedUrl = 'MobileAPI/v1.asmx/';
      masterURL = "https://$comapanyCode-web.mycaresoftware.com/MobileAPI/v1.asmx/";
    }


    print(baseUrlWithHttp);
    print(baseUrl);
    print(masterURL);

    var params = {
      'username': username,
      'password': password,
      'companycode': comapanyCode,
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endLogin, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          if (response != null && response != "") {
            print('res ${response}');

            final jResponse = json.decode(response);
            LoginResponseModel responseModel =
                LoginResponseModel.fromJson(jResponse);
            print('res ${jResponse['status']}');
            if (responseModel.status == 1 ) {
              print('res success');
              Preferences().setPrefString(
                  Preferences.prefAuthCode, responseModel.authcode ?? "");
              Preferences().setPrefInt(
                  Preferences.prefAccountType, responseModel.accountType ?? 0);
              Preferences().setPrefInt(
                  Preferences.prefUserID, responseModel.userid ?? 0);
              Preferences().setPrefString(
                  Preferences.prefUserFullName, responseModel.fullName ?? "");
              Preferences().setPrefString(
                  Preferences.prefComepanyCode, comapanyCode ?? "");
              await FlutterKeychain.put(key: "username", value: username);
              await FlutterKeychain.put(key: "password", value: password);
              await FlutterKeychain.put(key: "companycode", value: comapanyCode);

              if(comapanyCode == "nhc"){
                String cName = "nhc-northside";
                baseUrlWithHttp ="https://$cName-web.mycaresoftware.com/";
                baseUrl = '$cName-web.mycaresoftware.com';
                nestedUrl = 'MobileAPI/v1.asmx/';
                masterURL = "https://$cName-web.mycaresoftware.com/MobileAPI/v1.asmx/";
              }
              else{
                baseUrlWithHttp ="https://$comapanyCode-web.mycaresoftware.com/";
                baseUrl = '$comapanyCode-web.mycaresoftware.com';
                nestedUrl = 'MobileAPI/v1.asmx/';
                masterURL = "https://$comapanyCode-web.mycaresoftware.com/MobileAPI/v1.asmx/";
              }


              print(baseUrlWithHttp);
              print(baseUrl);
              print(masterURL);

              if(responseModel.accountType == 2) {
                sendToHome();
              }
              else if(responseModel.accountType == 3) {
                sendToClientHome();
               /*showSnackBarWithText(
                    _keyScaffold.currentState, "Clent can not login");*/
              }
            }
            else if (responseModel.status == 1 && responseModel.accountType != 2) {
              showSnackBarWithText(
                  _keyScaffold.currentState, "User can not login");
            }
            else {
              showSnackBarWithText(
                  _keyScaffold.currentState, jResponse['message']);
            }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          removeOverlay();
        } finally {
          removeOverlay();
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              child: Image.asset(
                '${Constants.imagePath}login_bg.png',
                fit: BoxFit.fitHeight,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // width: double/.infinity,
                      child: Image.asset(
                        '${Constants.imagePath}login_top.png',
                        fit: BoxFit.contain,
                        // height: MediaQuery.of(context).size.height ,
                        width: MediaQuery.of(context).size.width * .5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        color: Colors.white,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: spaceHorizontal),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 40, horizontal: spaceHorizontal),
                            child: AutofillGroup(

                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                              children: [
                                Form(
                                  key: _keyFormField,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.grey.shade50,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ThemedTextField(
                                          borderColor: colorGreyBorderD3,
                                          controller: _controllerUsername,
                                          // hintText: "Username",
                                          autofillHints: [AutofillHints.username],
                                          labelText: "Username",
                                          labelFontWeight: FontWeight.w500,
                                          preFix: const FaIcon(
                                              FontAwesomeIcons.solidCircleUser,
                                              color: colorPrimary),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.trim().isEmpty) {
                                              return "Please enter Username!";
                                            }
                                          },
                                          backgroundColor:
                                              colorGreyExtraLightBackGround,
                                        ),
                                        const SizedBox(height: spaceVertical),
                                        ThemedTextField(
                                          borderColor: colorGreyBorderD3,
                                          controller: _controllerPassword,
                                          // hintText: "Password",
                                          autofillHints: [AutofillHints.password],
                                          labelText: "Password",
                                          labelFontWeight: FontWeight.w500,
                                          preFix: const FaIcon(
                                              FontAwesomeIcons.lock,
                                              color: colorPrimary),
                                          isPasswordTextField: true,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.trim().isEmpty) {
                                              return "Please enter password!";
                                            }
                                            if (value.length < 5 ||
                                                value.length > 15) {
                                              return "Please enter valid length(between 5 to 15) password!";
                                            }
                                          },
                                          backgroundColor:
                                              colorGreyExtraLightBackGround,
                                        ),
                                        const SizedBox(height: spaceVertical),
                                        ThemedTextField(
                                          borderColor: colorGreyBorderD3,
                                          controller: _controllerCompanyCode,
                                          // hintText: "Company Code",
                                          labelText: "Company Code",
                                          labelFontWeight: FontWeight.w500,
                                          preFix: const FaIcon(
                                              FontAwesomeIcons.key,
                                              color: colorPrimary),
                                          isPasswordTextField: false,
                                          onChanged: (value) {
                                            _controllerCompanyCode.value =
                                                TextEditingValue(
                                                    text: value.toLowerCase(),
                                                    selection:
                                                        _controllerCompanyCode
                                                            .selection);
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty ||
                                                value.trim().isEmpty) {
                                              return "Please enter company code!";
                                            }
                                          },
                                          backgroundColor:
                                              colorGreyExtraLightBackGround,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: spaceVertical),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 60,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: MaterialButton(
                                      color: colorGreen,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const FaIcon(
                                              FontAwesomeIcons.powerOff,
                                              color: Colors.white),
                                          const SizedBox(width: 10),
                                          ThemedText(
                                            text: "Log In",
                                            color: colorWhite,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                      onPressed: () {
                                        if (_keyFormField.currentContext !=
                                                null &&
                                            _keyFormField.currentState!
                                                .validate()) {
                                          _loginApiCall(
                                              _controllerUsername.text.trim(),
                                              _controllerPassword.text.trim(),
                                              _controllerCompanyCode.text.trim());
                                        }
                                        // sendToHome();
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Column(
                    //   mainAxisSize: MainAxisSize.min,
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     GestureDetector(
                    //       onTap: () {
                    //         // _buildForgotPassWordDialog();
                    //         Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //               builder: (context) => const ForgotPassword(),
                    //             ));
                    //       },
                    //       child: const Text(
                    //         'FORGOT YOUR PASSWORD ?',
                    //         style: TextStyle(
                    //           fontSize: 16.0,
                    //           fontWeight: FontWeight.w500,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(height: 20),
                    //   ],
                    // ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  static String stripHtmlIfNeeded(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
  }

  sendToHome() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ));
  }
  sendToClientHome() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ClientHomeScreen(),
        ));
  }
}
