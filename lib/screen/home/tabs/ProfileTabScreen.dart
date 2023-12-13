import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rcare_2/Network/GlobalMethods.dart';
import 'package:rcare_2/network/ApiUrls.dart';
import 'package:rcare_2/screen/home/models/ProfileModel.dart';
import 'package:rcare_2/screen/login/ChangePassword.dart';
import 'package:rcare_2/utils/ColorConstants.dart';
import 'package:rcare_2/utils/Constants.dart';
import 'package:rcare_2/utils/ThemedWidgets.dart';
import 'package:rcare_2/utils/WidgetMethods.dart';

import '../../../Network/API.dart';
import '../../../utils/ConstantStrings.dart';
import '../../../utils/Preferences.dart';
import '../../../utils/methods.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  final GlobalKey<FormState> _keyFormField = GlobalKey<FormState>();

  ///  * [_keyForgotFormField], key of form of forgot dialog form.
  final GlobalKey<FormState> _keyForgotFormField = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  final TextEditingController _controllerFirstName = TextEditingController();
  final TextEditingController _controllerLastName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerAddress = TextEditingController();

  final TextEditingController _controllerSuburb = TextEditingController();
  final TextEditingController _controllerHomePhone = TextEditingController();
  final TextEditingController _controllerMobile = TextEditingController();
  final TextEditingController _controllerWorkPhone = TextEditingController();
  final TextEditingController _controllerUserName = TextEditingController();

  ProfileModel? _profileModel;

  Uint8List? profileImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProfileApiCall();
  }

  _getProfileApiCall() async {
    // String acctype=""+ await Preferences().getPrefString(Preferences.prefAccountType);
    var params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'accountType':
          (await Preferences().getPrefInt(Preferences.prefAccountType))
              .toString(),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
    };
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endEmployeeProfile, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          if (response != null && response != "") {
            List jResponse = json.decode(response);
            // ProfileModel responseModel = ProfileModel.fromJson(jResponse);
            print('Profile ${jResponse}');
            List<ProfileModel> dataList =
                jResponse.map((e) => ProfileModel.fromJson(e)).toList();

            print('res $dataList');

            if (dataList.isNotEmpty) {
              _profileModel = dataList[0];
              print("DATA : ${dataList[0].fullname}");
              // userName = _profileModel!.fullname ?? "";
              _controllerFirstName.text = _profileModel!.firstName ?? "";
              _controllerLastName.text = _profileModel!.lastName ?? "";
              _controllerEmail.text = _profileModel!.email ?? "";
              _controllerHomePhone.text = _profileModel!.homePhone ?? "";
              _controllerWorkPhone.text = _profileModel!.workPhone ?? "";
              _controllerSuburb.text =
                  "${_profileModel!.city ?? ""} ${_profileModel!.state ?? ""} ${_profileModel!.postalCode ?? ""}";
              _controllerAddress.text = _profileModel!.address ?? "";
              _controllerMobile.text = _profileModel!.mobileNo ?? "";
              _controllerUserName.text = _profileModel!.userName ?? "";
              try {
                profileImage = Base64Decoder().convert(
                    (_profileModel!.empProfilePic ?? "")
                        .replaceAll("data:image/png;base64,", ""));
              } catch (e) {
                log("IMAGECONVERTERROR : $e");
              }
            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, "Data Not Available!");
            }
            // if (responseModel.status == 1) {
            //   print('res success');
            //
            // } else {
            //   showSnackBarWithText(
            //       _keyScaffold.currentState, jResponse['Message']);
            // }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print('ERROR ${e}');
          removeOverlay();
        } finally {
          removeOverlay();
          setState(() {});
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
      appBar: buildAppBar(context, title: "Profile"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: colorLiteBlueBackGround,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: spaceHorizontal,
                              vertical: spaceVertical),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image =
                                            await picker.pickImage(
                                          source: ImageSource.gallery,
                                          imageQuality: 30,
                                        );
                                        if (image != null) {
                                          setState(() {
                                            _saveProfileImage(File(image.path));
                                          });
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1 / 1,
                                            child: profileImage != null
                                                ? Image.memory(
                                                    profileImage!,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                          color: colorGrey33);
                                                    },
                                                  )
                                                : const Center(
                                                    child: Icon(Icons.person),
                                                  ),
                                          ),
                                          ThemedText(
                                            text: "Upload",
                                            color: colorBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          ThemedText(
                                            text: "Picture",
                                            color: colorBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: spaceHorizontal),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: space),
                                        ThemedRichText(
                                          spanList: [
                                            getTextSpan(
                                              text: "First Name",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            getTextSpan(
                                              text: "*",
                                              fontSize: 14,
                                              fontColor: colorRed,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: spaceBetween),
                                        SizedBox(
                                            height: textFiledHeight,
                                            child: ThemedTextField(
                                              isAcceptCharOnly: true,
                                              borderColor: colorGreyBorderD3,
                                              controller: _controllerFirstName,
                                              backgroundColor: colorWhite,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal:
                                                          spaceHorizontal),
                                            )),
                                        const SizedBox(height: space),
                                        ThemedRichText(
                                          spanList: [
                                            getTextSpan(
                                              text: "Last Name",
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            getTextSpan(
                                              text: "*",
                                              fontSize: 14,
                                              fontColor: colorRed,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: spaceBetween),
                                        SizedBox(
                                          height: 45,
                                          child: ThemedTextField(
                                            isAcceptCharOnly: true,
                                            borderColor: colorGreyBorderD3,
                                            controller: _controllerLastName,
                                            backgroundColor: colorWhite,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: spaceHorizontal),
                                          ),
                                        ),
                                        const SizedBox(height: space),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "Email Address",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  keyBoardType: TextInputType.emailAddress,
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerEmail,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedRichText(
                                spanList: [
                                  getTextSpan(
                                    text: "Address",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  getTextSpan(
                                    text: "*",
                                    fontSize: 14,
                                    fontColor: colorRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerAddress,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedRichText(
                                spanList: [
                                  getTextSpan(
                                    text: "Suburb",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  getTextSpan(
                                    text: "*",
                                    fontSize: 14,
                                    fontColor: colorRed,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  controller: _controllerSuburb,
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "Home Phone",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  isAcceptNumbersOnly: true,
                                  keyBoardType: TextInputType.number,
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerHomePhone,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "Mobile No",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  isAcceptNumbersOnly: true,
                                  keyBoardType: TextInputType.number,
                                  borderColor: colorGreyBorderD3,
                                  controller: _controllerMobile,
                                  backgroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "Work Phone No",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  isAcceptNumbersOnly: true,
                                  keyBoardType: TextInputType.number,
                                  controller: _controllerWorkPhone,
                                  borderColor: colorGreyBorderD3,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  backgroundColor: colorWhite,
                                ),
                              ),
                              const SizedBox(height: space),
                              ThemedText(
                                text: "UserName",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              const SizedBox(height: spaceBetween),
                              SizedBox(
                                height: textFiledHeight,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: ThemedTextField(
                                        controller: _controllerUserName,
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorWhite,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                      ),
                                    ),
                                    const SizedBox(width: spaceHorizontal / 2),
                                    Expanded(
                                      flex: 4,
                                      child: ThemedButton(
                                        title: "Change Password",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        padding: EdgeInsets.zero,
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ChangePassword(),
                                              ));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: spaceVertical),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: spaceHorizontal,
                      ),
                      child: SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ThemedButton(
                                title: "Cancel",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                padding: EdgeInsets.zero,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            const SizedBox(width: spaceHorizontal / 2),
                            Expanded(
                              child: ThemedButton(
                                title: "Save",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                padding: EdgeInsets.zero,
                                onTap: () {
                                  if (_controllerFirstName.text
                                      .trim()
                                      .isEmpty) {
                                    showSnackBarWithText(
                                        _keyScaffold.currentState,
                                        "First name can not be blank!");
                                  } else if (_controllerLastName.text
                                      .trim()
                                      .isEmpty) {
                                    showSnackBarWithText(
                                        _keyScaffold.currentState,
                                        "Last name can not be blank!");
                                  } else if (_controllerAddress.text
                                      .trim()
                                      .isEmpty) {
                                    showSnackBarWithText(
                                        _keyScaffold.currentState,
                                        "Address can not be blank!");
                                  } else if (_controllerSuburb.text
                                      .trim()
                                      .isEmpty) {
                                    showSnackBarWithText(
                                        _keyScaffold.currentState,
                                        "Suburb filed can not be blank!");
                                  } else if (_controllerEmail.text
                                      .trim()
                                      .isEmpty) {
                                    showSnackBarWithText(
                                        _keyScaffold.currentState,
                                        "EmilId can not be blank!");
                                  } else if (!isValidateEmail(
                                      _controllerEmail.text)) {
                                    showSnackBarWithText(
                                        _keyScaffold.currentState,
                                        "Please enter valid email ID");
                                  } else {
                                    _saveProfileApiCall();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: spaceVertical),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _saveProfileApiCall() {
    if (_profileModel != null) {
      String body = json.encode({
        'auth_code': (_profileModel!.employeeID ?? 0).toString(),
        'EmployeeID': (_profileModel!.employeeID ?? 0).toString(),
        'Title': "null",
        'FirstName': _controllerFirstName.text,
        'LastName': _controllerLastName.text,
        'UnitNo': _profileModel!.unitNo ?? "null",
        'Address': _controllerAddress.text,
        'City': _profileModel!.city,
        'State': _profileModel!.state,
        'PostalCode': _profileModel!.postalCode,
        'HomePhone': _controllerHomePhone.text,
        'WorkPhone': _controllerWorkPhone.text,
        'MobileNo': _controllerMobile.text,
        'email': _controllerEmail.text,
        "Languages": _profileModel!.languages,
        "EmrgcyContactName": _profileModel!.emrgcyContactName,
        "EmrgcyContactPhone": _profileModel!.emrgcyContactPhone,
        "PrivateEmail": _profileModel!.privateEmail != null &&
                _profileModel!.contractorName!.isNotEmpty
            ? _profileModel!.privateEmail
            : "null",
        "ContractorName": _profileModel!.contractorName != null &&
                _profileModel!.contractorName!.isNotEmpty
            ? _profileModel!.contractorName
            : "null",
      });

      print(body);
      // log("URL ${getUrl(endSaveEmployeeProfile)}");
      isConnected().then((hasInternet) async {
        if (hasInternet) {
          // var response;
          // HttpRequestModel request = HttpRequestModel(
          //     url: getUrl(endSaveEmployeeProfile, params: params).toString(),
          //     //endSaveEmployeeProfile,
          //     authMethod: '',
          //     body: '',
          //     headerType: '',
          //     params: "",
          //     //params.toString(),
          //     method: 'GET');

          if (body.isEmpty) {
            return;
          }

          try {
            getOverlay(context);
            // response = await HttpService().init(request, _keyScaffold);
            Response response = await http.post(
                Uri.parse(
                    "https://mycare-web.mycaresoftware.com/MobileAPI/v1.asmx/$endSaveEmployeeProfile"),
                headers: {"Content-Type": "application/json"},
                body: body);
            print(
                "response $endSaveEmployeeProfile ${response.body} ${response.request!.url.toString()}");
            if (response != null && response != "") {
              var jResponse =
                  json.decode(stripHtmlIfNeeded(response.body.toString()));
              var dResponse = json.decode(jResponse["d"]);
              if (dResponse["status"] == 1) {
                showSnackBarWithText(_keyScaffold.currentState, "Success",
                    color: colorGreen);
              }
            } else {
              showSnackBarWithText(
                  _keyScaffold.currentState, stringSomeThingWentWrong);
            }
            removeOverlay();
          } catch (e) {
            log("SignUp$e");
            removeOverlay();
            throw e;
          } finally {
            removeOverlay();
          }
        } else {
          showSnackBarWithText(
              _keyScaffold.currentState, stringErrorNoInterNet);
        }
      });
    }
  }

  _saveProfileImage(File image) async {
    closeKeyboard();
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);
          Response response = await http.post(
            Uri.parse(
                "https://mycare-web.mycaresoftware.com/MobileAPI/v1.asmx/SaveProfilePic"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "EmployeeClientID": (_profileModel!.employeeID ?? 0).toString(),
              "tableName": 'user',
              "ProfilePic":
                  "data:image/png;base64, ${base64.encode(await image.readAsBytes())}",
            }),
          );
          print("responseImageUpload ${json.encode({
                "EmployeeClientId": (_profileModel!.employeeID ?? 0).toString(),
                "tableName": 'user',
                "ProfilePic":
                    "data:image/png;base64, ${base64.encode(await image.readAsBytes())}",
              })}");
          print("responseImageUpload ${response.body}");
          if (response.statusCode == 200 || response.statusCode == 201) {
            var jResponse = json.decode(response.body.toString());
            var jrs = json.decode(jResponse["d"]);
            if (jrs["status"] == 1) {
              print("UPLOADED : ${jrs} Success");
              _getProfileApiCall();
            }
          } else {
            // print("UPLOADED : ${image.path} failed");
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          log("SignUp$e");
          removeOverlay();
          // throw e;
        } finally {
          removeOverlay();
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }
}
