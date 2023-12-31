import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rcare_2/screen/home/notes/NotesDetails.dart';

import '../../appconstant/API.dart';
import '../../appconstant/ApiUrls.dart';
import '../../utils/ColorConstants.dart';
import '../../utils/ConstantStrings.dart';
import '../../utils/Constants.dart';
import '../../utils/LabeledCheckbox.dart';
import '../../utils/Preferences.dart';
import '../../utils/ThemedWidgets.dart';
import '../../utils/WidgetMethods.dart';
import '../../utils/methods.dart';
import '../home/models/ConfirmedResponseModel.dart';
import 'ClientHomeScreen.dart';

class ServiceForm extends StatefulWidget {
  final TimeShiteModel model;
  final int indexSelectedFrom;

  const ServiceForm(
      {super.key, required this.model, required this.indexSelectedFrom});

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final GlobalKey<ScaffoldState> _keyScaffold = GlobalKey<ScaffoldState>();

  int fromHour = 0;
  int fromMin = 0;
  int toHour = 0;
  int toMin = 0;
  int totalWorkMin = 0;
  double diffHours = 0;
  int breakMin = 0;

  int origionalMins = 0;

  int startBreakMin = 0;
  int endBrakMin = 0;
  int travelMin = 0;
  DateTime? sDate;
  String fromHourService = "00";
  final TextEditingController _controllerFromService = TextEditingController();
  String fromMinuteService = "00";

  // final TextEditingController _controllerFromMinuteService = TextEditingController();
  String toHourService = "00";
  final TextEditingController _controllerToService = TextEditingController();
  String toMinuteService = "00";

  // final TextEditingController _controllerToMinuteService = TextEditingController();

  String hourLaunch = "00";
  final TextEditingController _controllerHourLaunch = TextEditingController();
  String minuteLaunch = "00";

  // final TextEditingController _controllerMinuteLaunch = TextEditingController();

  String fromHourLaunch = "00";
  final TextEditingController _controllerFromLaunch = TextEditingController();
  String fromMinuteLaunch = "00";

  // final TextEditingController _controllerFromMinuteLaunch = TextEditingController();

  String toHourLaunch = "00";
  final TextEditingController _controllerToLaunch = TextEditingController();
  String toMinuteLaunch = "00";

  // final TextEditingController _controllerToMinuteLaunch = TextEditingController();

  final TextEditingController _controllerServiceType = TextEditingController();
  final TextEditingController _controllerServiceTypeDesc =
      TextEditingController();
  final TextEditingController _controllerServiceDate = TextEditingController();
  final TextEditingController _controllerHours = TextEditingController();
  final TextEditingController _controllerHoursDifference =
      TextEditingController();
  final TextEditingController _controllerTravelTime = TextEditingController();
  final TextEditingController _controllerTravelDistance =
      TextEditingController();
  final TextEditingController _controllerTravelDistanceMax =
      TextEditingController();
  final TextEditingController _controllerClientTravelDistance =
      TextEditingController();
  final TextEditingController _controllerTimeSheetComments =
      TextEditingController();

  bool isIncludeLaunchBrake = false;
  bool isClientFunding = false;
  bool isRecurringService = false;

  List<String> hourList =
      List.generate(23, (index) => index.toString().padLeft(2, '0'));
  List<String> minuteList =
      List.generate(60, (index) => index.toString().padLeft(2, '0'));

  String timeSheetValidation = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.model.serviceDate != null) {
      sDate = DateTime.fromMillisecondsSinceEpoch(int.parse(widget
          .model.serviceDate!
          .replaceAll("/Date(", "")
          .replaceAll(")/", "")));
      _controllerServiceType.text = widget.model.serviceName ?? "";
      if (widget.model.tSConfirm == false &&
          widget.model.timeFrom != null &&
          widget.model.timeFrom!.split(":").isNotEmpty) {
        _controllerFromService.text = widget.model.timeFrom!;
        var list = widget.model.timeFrom!.split(":");
        fromHour = int.parse(list.first);
        fromMin = int.parse(list.last);
      }
      if (widget.model.tSConfirm == true &&
          widget.model.tSFrom != null &&
          widget.model.tSFrom!.split(":").isNotEmpty) {
        _controllerFromService.text = widget.model.tSFrom!;
        var list = widget.model.tSFrom!.split(":");
        fromHour = int.parse(list.first);
        fromMin = int.parse(list.last);
      }

      if (widget.model.tSConfirm == false &&
          widget.model.timeUntil != null &&
          widget.model.timeUntil!.split(":").isNotEmpty) {
        _controllerToService.text = widget.model.timeUntil!;
        var list = widget.model.timeUntil!.split(":");
        toHour = int.parse(list.first);
        toMin = int.parse(list.last);
      }
      if (widget.model.tSConfirm == true &&
          widget.model.tSUntil != null &&
          widget.model.tSUntil!.split(":").isNotEmpty) {
        _controllerToService.text = widget.model.tSUntil!;
        var list = widget.model.tSUntil!.split(":");
        toHour = int.parse(list.first);
        toMin = int.parse(list.last);
      }
      if (widget.model.tSHours != null) {
        totalWorkMin = (widget.model.tSHours!.toDouble() * 60).toInt();
      }

      isIncludeLaunchBrake = widget.model.tSLunchBreakSetting ?? false;
      if (widget.model.tSLunchBreak != null &&
          widget.model.tSLunchBreak!.split(":").isNotEmpty) {
        _controllerHourLaunch.text = widget.model.tSLunchBreak!;
        if (widget.model.tSLunchBreak!.split(":").length > 1) {
          // _controllerMinuteLaunch.text = widget.model.tSLunchBreak!.split(":")[1];
        }
      }
      if (widget.model.tSLunchBreakFrom != null &&
          widget.model.tSLunchBreakFrom!.split(":").isNotEmpty) {
        _controllerFromLaunch.text = widget.model.tSLunchBreakFrom!;
      } else {
        _controllerFromLaunch.text = "00:00";
      }
      if (widget.model.tSLunchBreakTo != null &&
          widget.model.tSLunchBreakTo!.split(":").isNotEmpty) {
        _controllerToLaunch.text = widget.model.tSLunchBreakTo!;
      } else {
        _controllerToLaunch.text = "00:00";
      }

      if (widget.model.tSHours != null) {
        _controllerHours.text =
            getTimeStringFromDouble(widget.model.tSHours!.toDouble());
        origionalMins = (widget.model.tSHours! * 60).toInt();
      }
      if (widget.model.tSHoursDiff != null) {
        diffHours = widget.model.tSHoursDiff!.toDouble();
      }
      if (widget.model.tSConfirm == true) {
        timeSheetValidation =
            "Timesheet Submitted.Only comments can be updated!";
      }
      _controllerHoursDifference.text = widget.model.tSHoursDiff.toString();
      _controllerTravelTime.text = getTimeStringFromDouble(
          double.tryParse(widget.model.tSTravelTime.toString()) ?? 0.0);

      _controllerTravelDistance.text =
          widget.model.tSTravelDistance!.toDouble().toString();
      if (widget.model.tSTravelDistance! <= 0.0) {
        _controllerTravelDistance.text = "";
      }

      _controllerTravelDistanceMax.text =
          widget.model.maxTravelDistance!.toDouble().toString();

      _controllerTravelDistanceMax.text =
          widget.model.maxTravelDistance!.toDouble().toString();

      _controllerClientTravelDistance.text =
          widget.model.clienttraveldistance!.toDouble().toString();
      if (widget.model.clienttraveldistance! <= 0.0) {
        _controllerClientTravelDistance.text = "";
      }
      //  isRecurring = false;
      _controllerTimeSheetComments.text = widget.model.tSComments ?? "";
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffold,
      backgroundColor: colorLiteBlueBackGround,
      appBar: buildAppBar(context, title: "Timesheet Form"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: spaceHorizontal, vertical: spaceVertical),
          child: Column(
            children: [
              Container(
                color: colorWhite,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      height: textFiledHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!(widget.model.completeCW ?? false))
                          const SizedBox(width: spaceHorizontal),
                          if (!(widget.model.completeCW ?? false))
                            Expanded(
                              child: ThemedButton(
                                padding: EdgeInsets.zero,
                                title: "Save",
                                fontSize: 14,
                                onTap: () async {
                                  if (widget.model.tSConfirm == false) {
                                    int startMinTs = (fromHour * 60) + fromMin;
                                    int endMinTs = (toHour * 60) + toMin;
                                    if (endMinTs < startMinTs) {
                                      endMinTs = endMinTs + 1440;
                                    }

                                    if (startMinTs == endMinTs) {
                                      showSnackBarWithText(
                                          _keyScaffold.currentState,
                                          "Please enter valid Untile Time",
                                          color: colorRed);
                                      return;
                                    }

                                    if (isIncludeLaunchBrake &&
                                        endBrakMin == 0) {
                                      showSnackBarWithText(
                                          _keyScaffold.currentState,
                                          "Please enter valid lunch break",
                                          color: colorRed);
                                      return;
                                    }
                                    if (diffHours != 0.0 &&
                                        widget.model.tSConfirm == false &&
                                        _controllerTimeSheetComments
                                            .text.isEmpty) {
                                      showSnackBarWithText(
                                          _keyScaffold.currentState,
                                          "Comments are required if hours are differemt",
                                          color: colorRed);
                                      return;
                                    }
                                  }
                                },
                              ),
                            ),
                          if (widget.indexSelectedFrom == 1)
                          const SizedBox(width: spaceHorizontal),
                          if (widget.indexSelectedFrom == 1)
                            Expanded(
                              // height: textFiledHeight,
                              child: ThemedButton(
                                padding: EdgeInsets.zero,
                                title: "Delete",
                                fontSize: 14,
                                onTap: () async {
                                  //implement delete service
                                },
                              ),
                            ),
                          const SizedBox(width: spaceHorizontal),
                          Expanded(
                            // height: textFiledHeight,
                            child: ThemedButton(
                              padding: EdgeInsets.zero,
                              title: "Cancel",
                              fontSize: 14,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: spaceHorizontal),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    timeSheetValidation.isNotEmpty
                        ? SizedBox(
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              color: colorRed,
                              child: ThemedText(
                                text: timeSheetValidation,
                                fontSize: 14,
                                maxLine: 2,
                                color: colorWhite,
                              ),
                            ),
                          )
                        : Container(),
                    ////DO NOT SHOW FOR NEW SERVICE
                    if (widget.indexSelectedFrom >= 0)
                      Column(children: [
                        const SizedBox(height: 20),
                        ThemedText(
                          text: widget.model.resName ?? "",
                          color: colorBlack,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: spaceVertical / 2),
                        ThemedText(
                          text: widget.model.serviceName ?? "",
                          color: colorBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        const SizedBox(height: spaceVertical / 2),
                        Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width * .9,
                            color: colorDivider),
                        const SizedBox(height: spaceVertical / 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.calendarDays,
                              color: colorGreen,
                              size: 14,
                            ),
                            const SizedBox(width: spaceHorizontal),
                            Text(
                              formatServiceDate(widget.model.serviceDate),
                              style: const TextStyle(
                                color: colorBlack,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                                height: 20,
                                width: dividerWidth,
                                color: colorDivider),
                            const SizedBox(width: 5),
                            Container(
                                height: 20,
                                width: dividerWidth,
                                color: colorDivider),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.timer,
                              color: colorGreen,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.model.shift ?? "",
                              style: const TextStyle(
                                  color: colorBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 5),
                            // Container(height: 20, width: 1, color: colorDivider),
                            // const SizedBox(width: 5),
                            // const Icon(
                            //   CupertinoIcons.time,
                            //   color: colorGreen,
                            //   size: 14,
                            // ),
                            // const SizedBox(width: 5),
                            // Text(
                            //   "${widget.model.totalHours}hrs",
                            //   style: const TextStyle(
                            //       color: colorBlack,
                            //       fontSize: 12,
                            //       fontWeight: FontWeight.w500),
                            // ),
                          ],
                        ),
                        const SizedBox(height: spaceVertical / 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.time,
                              color: colorGreen,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${widget.model.totalHours}hrs",
                              style: const TextStyle(
                                  color: colorBlack,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 5),
                            Container(
                                height: 20,
                                width: dividerWidth,
                                color: colorDivider),
                            const SizedBox(width: 5),
                            const SizedBox(width: spaceHorizontal),
                            ThemedText(
                              text:
                                  "Lunch Break : ${widget.model.tSLunchBreak ?? ""}",
                              color: colorBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            const SizedBox(width: 5),
                            Container(
                                height: 20,
                                width: dividerWidth,
                                color: colorDivider),
                            const SizedBox(width: 5),
                            ThemedText(
                              text:
                                  "Travel Dist.: ${widget.model.tSTravelDistance?.toDouble().toString() ?? "0.00"}",
                              color: colorBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                        const SizedBox(height: spaceVertical),
                        Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width * .9,
                            color: colorDivider),
                        const SizedBox(height: spaceVertical),
                      ])
                    /*  SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .85,
                      child: ThemedButton(
                        title: "Cancel",
                        padding: EdgeInsets.zero,
                        fontSize: 16,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: spaceVertical / 1.5),*/
                  ],
                ),
              ),
              const SizedBox(height: spaceVertical),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ThemedText(
                      text: "Service Date",
                      fontSize: 14,
                      color: colorBlack,
                    ),
                    SizedBox(
                      height: textFiledHeight,
                      child: ThemedTextField(
                        padding: const EdgeInsets.symmetric(
                            horizontal: spaceHorizontal),
                        borderColor: colorGreyBorderD3,
                        backgroundColor: colorWhite,
                        sufFix: const Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Colors.grey,
                          size: 30.0,
                        ),
                        isReadOnly: true,
                        hintText: "Select Date",
                        controller: _controllerServiceDate,
                      ),
                    ),
                    const SizedBox(height: spaceBetween),
                    ThemedText(
                      text: "Service Type",
                      fontSize: 14,
                      color: colorBlack,
                    ),
                    SizedBox(
                      height: textFiledHeight,
                      child: ThemedTextField(
                        padding: const EdgeInsets.symmetric(
                            horizontal: spaceHorizontal),
                        borderColor: colorGreyBorderD3,
                        backgroundColor: colorWhite,
                        isReadOnly: true,
                        sufFix: const Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Colors.grey,
                          size: 30.0,
                        ),
                        controller: _controllerServiceType,
                      ),
                    ),
                    const SizedBox(height: spaceBetween),
                    SizedBox(
                      height: textFiledHeight,
                      child: ThemedTextField(
                        padding: const EdgeInsets.symmetric(
                            horizontal: spaceHorizontal),
                        borderColor: colorGreyBorderD3,
                        backgroundColor: colorWhite,
                        isReadOnly: false,
                        controller: _controllerServiceTypeDesc,
                      ),
                    ),
                    const SizedBox(height: spaceBetween),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedText(
                                text: "From Time*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  sufFix: const Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    color: Colors.grey,
                                    size: 30.0,
                                  ),
                                  controller: _controllerFromService,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  onTap: () async {
                                    if (widget.indexSelectedFrom < 0) {
                                      showTimePickerDialog(
                                        initialTimeText:
                                            _controllerFromService.text,
                                        onTimePick: (hours, minutes) {
                                          fromHour = hours;
                                          fromMin = minutes;
                                          calculateHours();
                                          _controllerFromService.text =
                                              "${get2CharString(hours)}:${get2CharString(minutes)}";

                                          setState(() {});
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: spaceHorizontal / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedText(
                                text: "Until Time*",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  sufFix: const Icon(
                                    Icons.keyboard_arrow_down_outlined,
                                    color: Colors.grey,
                                    size: 30.0,
                                  ),
                                  controller: _controllerToService,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  onTap: () async {
                                    if (widget.indexSelectedFrom < 0) {
                                      showTimePickerDialog(
                                        initialTimeText:
                                            _controllerToService.text,
                                        onTimePick: (hours, minutes) {
                                          toHour = hours;
                                          toMin = minutes;
                                          calculateHours();
                                          _controllerToService.text =
                                              "${get2CharString(hours)}:${get2CharString(minutes)}";
                                          setState(() {});
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: spaceHorizontal / 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ThemedText(
                                text: "Hours(hh:mm)",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: textFiledHeight,
                                child: ThemedTextField(
                                  controller: _controllerToService,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: spaceHorizontal),
                                  borderColor: colorGreyBorderD3,
                                  backgroundColor: colorWhite,
                                  isReadOnly: true,
                                  onTap: () async {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: spaceBetween),
                    ThemedText(
                      text: "Service",
                      fontSize: 14,
                      color: colorBlack,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(
                      height: textFiledHeight,
                      child: ThemedTextField(
                        sufFix: const Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Colors.grey,
                          size: 30.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: spaceHorizontal),
                        borderColor: colorGreyBorderD3,
                        backgroundColor: colorWhite,
                        isReadOnly: true,
                        controller: _controllerServiceDate,
                      ),
                    ),
                    const SizedBox(height: spaceBetween),
                    if (widget.indexSelectedFrom >= 0)
                      Row(
                        children: [
                          ThemedText(
                            text: "TS Lunch Break*",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          Radio<bool>(
                            value: true,
                            groupValue: isIncludeLaunchBrake,
                            activeColor: colorGreen,
                            onChanged: widget.model.tSConfirm == true
                                ? null
                                : (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        isIncludeLaunchBrake = value;
                                      });
                                    }
                                  },
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isIncludeLaunchBrake = true;
                              });
                            },
                            child: ThemedText(
                              text: "Yes",
                              color: colorBlack,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          Radio<bool>(
                            value: false,
                            groupValue: isIncludeLaunchBrake,
                            activeColor: colorGreen,
                            onChanged: widget.model.tSConfirm == true
                                ? null
                                : (bool? value) {
                                    if (value != null) {
                                      setState(() {
                                        isIncludeLaunchBrake = value;
                                      });
                                    }
                                  },
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isIncludeLaunchBrake = false;
                              });
                            },
                            child: ThemedText(
                              text: "No",
                              color: colorBlack,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: spaceBetween),
                    if (isIncludeLaunchBrake)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ThemedRichText(spanList: [
                                      getTextSpan(
                                        text: "TS Launch Break",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorBlack,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorRed,
                                      ),
                                    ]),
                                    const SizedBox(height: spaceBetween),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedTextField(
                                        controller: _controllerHourLaunch,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorGreyE8,
                                        isReadOnly: true,
                                        onTap: () {},
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              /* const SizedBox(width: spaceHorizontal / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ThemedText(
                                      text: "",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedTextField(
                                        controller: _controllerMinuteLaunch,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorWhite,
                                        isReadOnly: true,
                                        onTap: () {},
                                      ),
                                    ),
                                  ],
                                ),
                              )*/
                            ],
                          ),
                          const SizedBox(height: spaceBetween),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ThemedRichText(spanList: [
                                      getTextSpan(
                                        text: "TS Launch From",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorBlack,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorRed,
                                      ),
                                    ]),
                                    const SizedBox(height: spaceBetween),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedTextField(
                                        sufFix: const Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          color: Colors.grey,
                                          size: 30.0,
                                        ),
                                        controller: _controllerFromLaunch,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorWhite,
                                        isReadOnly: true,
                                        onTap: widget.model.tSConfirm == true
                                            ? () {}
                                            : () async {
                                                showTimePickerDialog(
                                                  initialTimeText:
                                                      _controllerFromLaunch
                                                          .text,
                                                  onTimePick: (hours, minutes) {
                                                    int tempstartBreakMin =
                                                        (hours * 60) + minutes;
                                                    int startMinTs =
                                                        (fromHour * 60) +
                                                            fromMin;
                                                    int endMinTs =
                                                        (toHour * 60) + toMin;
                                                    if (endMinTs < startMinTs) {
                                                      endMinTs =
                                                          endMinTs + 1440;
                                                      if (tempstartBreakMin <
                                                          startMinTs) {
                                                        tempstartBreakMin +=
                                                            1440;
                                                      }
                                                    }

                                                    print(
                                                        startMinTs.toString());
                                                    print(endMinTs.toString());
                                                    print(tempstartBreakMin
                                                        .toString());

                                                    if (tempstartBreakMin <
                                                            startMinTs ||
                                                        tempstartBreakMin >
                                                            endMinTs) {
                                                      showSnackBarWithText(
                                                          _keyScaffold
                                                              .currentState,
                                                          "Please enter valid lunch break time",
                                                          color: colorRed);
                                                      return;
                                                    } else {
                                                      startBreakMin =
                                                          tempstartBreakMin;
                                                    }

                                                    _controllerFromLaunch.text =
                                                        "${get2CharString(hours)}:${get2CharString(minutes)}";
                                                    String diff =
                                                        findDurationDifference(
                                                            _controllerFromLaunch
                                                                .text,
                                                            _controllerToLaunch
                                                                .text);
                                                    _controllerHourLaunch.text =
                                                        diff;
                                                    setState(() {});
                                                  },
                                                );
                                              },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: spaceHorizontal / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ThemedRichText(spanList: [
                                      getTextSpan(
                                        text: "TS Launch To",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorBlack,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorRed,
                                      ),
                                    ]),
                                    const SizedBox(height: spaceBetween),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedTextField(
                                        sufFix: const Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          color: Colors.grey,
                                          size: 30.0,
                                        ),
                                        controller: _controllerToLaunch,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorWhite,
                                        isReadOnly: true,
                                        onTap: widget.model.tSConfirm == true
                                            ? () {}
                                            : () async {
                                                showTimePickerDialog(
                                                  initialTimeText:
                                                      _controllerToLaunch.text,
                                                  onTimePick: (hours, minutes) {
                                                    int teampendBrakMin =
                                                        (hours * 60) + minutes;
                                                    int startMinTs =
                                                        (fromHour * 60) +
                                                            fromMin;

                                                    int endMinTs =
                                                        (toHour * 60) + toMin;
                                                    if (endMinTs < startMinTs) {
                                                      endMinTs =
                                                          endMinTs + 1440;
                                                    }
                                                    if (teampendBrakMin <
                                                        startBreakMin) {
                                                      teampendBrakMin =
                                                          teampendBrakMin +
                                                              1440;
                                                    }
                                                    print(startBreakMin
                                                        .toString());
                                                    print(endMinTs.toString());
                                                    print(teampendBrakMin
                                                        .toString());

                                                    if (startBreakMin == 0 &&
                                                        endMinTs > 1440) {
                                                      showSnackBarWithText(
                                                          _keyScaffold
                                                              .currentState,
                                                          "Please enter start lunch break time",
                                                          color: colorRed);
                                                      return;
                                                    }

                                                    print(startBreakMin
                                                        .toString());
                                                    print(endMinTs.toString());
                                                    print(teampendBrakMin
                                                        .toString());
                                                    print(
                                                        startMinTs.toString());

                                                    if (teampendBrakMin <
                                                            startBreakMin ||
                                                        teampendBrakMin <
                                                            startMinTs) {
                                                      showSnackBarWithText(
                                                          _keyScaffold
                                                              .currentState,
                                                          "Please enter valid lunch break time",
                                                          color: colorRed);
                                                      return;
                                                    } else {
                                                      endBrakMin =
                                                          teampendBrakMin;
                                                    }

                                                    _controllerToLaunch.text =
                                                        "${get2CharString(hours)}:${get2CharString(minutes)}";
                                                    breakMin = endBrakMin -
                                                        startBreakMin;
                                                    print(breakMin.toString());
                                                    int h =
                                                        (breakMin / 60).toInt();
                                                    int m =
                                                        (breakMin % 60).toInt();
                                                    print(h.toString());
                                                    print(m.toString());
                                                    _controllerHourLaunch.text =
                                                        "${get2CharString(h)}:${get2CharString(m)}";
                                                    /* String diff =
                                                        findDurationDifference(
                                                            _controllerFromLaunch
                                                                .text,
                                                            _controllerToLaunch
                                                                .text);*/
                                                    calculateHours();

                                                    setState(() {});
                                                  },
                                                );
                                              },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: spaceHorizontal / 2),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ThemedRichText(spanList: [
                                      getTextSpan(
                                        text: "TS Launch Break",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorBlack,
                                      ),
                                      getTextSpan(
                                        text: "*",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontColor: colorRed,
                                      ),
                                    ]),
                                    const SizedBox(height: spaceBetween),
                                    SizedBox(
                                      height: textFiledHeight,
                                      child: ThemedTextField(
                                        controller: _controllerToLaunch,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: spaceHorizontal),
                                        borderColor: colorGreyBorderD3,
                                        backgroundColor: colorWhite,
                                        isReadOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: spaceBetween),
                    LabeledCheckbox(
                        value: false,
                        label: "Client Funding",
                        leadingCheckbox: false,
                        onChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              isClientFunding = value;
                            });
                          }
                        }),
                    if(isClientFunding)
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ThemedText(
                            text: "Funding Service*",
                            fontSize: 14,
                            color: colorBlack,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(
                            height: textFiledHeight,
                            child: ThemedTextField(
                              sufFix: const Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: Colors.grey,
                                size: 30.0,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: spaceHorizontal),
                              borderColor: colorGreyBorderD3,
                              backgroundColor: colorWhite,
                              isReadOnly: true,
                              controller: _controllerServiceDate,
                            ),
                          ),
                        ]),
                    LabeledCheckbox(
                        value: false,
                        label: "Recurring",
                        leadingCheckbox: false,
                        onChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              isRecurringService = value;
                            });
                          }
                        }),
                    if (isRecurringService)
                      Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ThemedRichText(spanList: [
                              getTextSpan(
                                text: "Interval (Single Choice)",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontColor: colorBlack,
                              )
                            ]),
                            SizedBox(height: spaceBetween),
                            SingleChoice(),
                            const SizedBox(height: spaceBetween*2),
                            ThemedRichText(spanList: [
                              getTextSpan(
                                text: "Days (Multiple Choice)",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontColor: colorBlack,
                              )
                            ]),
                            SizedBox(height: spaceBetween),
                            MultipleChoice(),
                            const SizedBox(height: spaceBetween),
                            ThemedText(
                              text: "Service End",
                              fontSize: 14,
                              color: colorBlack,
                              fontWeight: FontWeight.w500,
                            ),
                            SizedBox(
                              height: textFiledHeight,
                              child: ThemedTextField(
                                sufFix: const Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Colors.grey,
                                  size: 30.0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: spaceHorizontal),
                                borderColor: colorGreyBorderD3,
                                backgroundColor: colorWhite,
                                isReadOnly: true,
                                controller: _controllerServiceDate,
                              ),
                            ),
                          ]),
                    const SizedBox(height: spaceBetween),
                    ThemedRichText(spanList: [
                      getTextSpan(
                        text: "Shift Comments",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontColor: colorBlack,
                      ),
                    ]),
                    const SizedBox(height: spaceBetween),
                    ThemedTextField(
                      padding: const EdgeInsets.symmetric(
                          horizontal: spaceHorizontal),
                      borderColor: colorGreyBorderD3,
                      backgroundColor: colorWhite,
                      maxLine: 5,
                      minLine: 5,
                      controller: _controllerTimeSheetComments,
                    ),
                    const SizedBox(height: spaceBetween),
                    /* SizedBox(
                      height: 50,
                      child: ThemedButton(
                        title: "Save",
                        padding: EdgeInsets.zero,
                        onTap: () {
                          saveTimeSheet();
                        },
                      ),
                    ),
                    const SizedBox(height: spaceBetween),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  calculateHours() {
    print(fromHour);
    print(fromMin);
    print(toHour);
    print(toMin);
    print(origionalMins);
    print(breakMin);

    int diff = ((toHour * 60) + toMin) - ((fromHour * 60) + fromMin);
    if (diff < 0) {
      diff = diff + 1440;
    }
    totalWorkMin = diff;
    print(diff);
    int totalHours = (diff / 60).toInt();
    int totalMin = (diff % 60).toInt();
    _controllerHours.text =
        "${get2CharString(totalHours)}:${get2CharString(totalMin)}";
    print(diff);
    print(origionalMins);
    double diffMin = ((((diff - breakMin) - origionalMins) * 100) / 60) / 100;
    print(diffMin);
    String stdiffMin = diffMin.toStringAsFixed(2);
    diffHours = double.parse(stdiffMin);
    _controllerHoursDifference.text = "$diffHours";
  }

  showTimePickerDialog(
      {required String? initialTimeText,
      required void Function(int hours, int minutes) onTimePick}) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: initialTimeText != null
            ? int.tryParse(initialTimeText.split(":").first) ??
                TimeOfDay.now().hour
            : TimeOfDay.now().hour,
        minute: initialTimeText != null
            ? int.tryParse(initialTimeText.split(":").last) ??
                TimeOfDay.now().minute
            : TimeOfDay.now().minute,
      ),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (newTime != null) {
      onTimePick(newTime.hour, newTime.minute);
    }
  }

  String findDurationDifference(String dataFromString, String dataToString) {
    int fromHourLaunch = dataFromString.isNotEmpty
        ? int.tryParse(dataFromString.split(":").first) ?? TimeOfDay.now().hour
        : TimeOfDay.now().hour;
    int fromMinuteLaunch = dataFromString.isNotEmpty
        ? int.tryParse(dataFromString.split(":").last) ?? TimeOfDay.now().minute
        : TimeOfDay.now().minute;
    int toHourLaunch = dataToString.isNotEmpty
        ? int.tryParse(dataToString.split(":").first) ?? TimeOfDay.now().hour
        : TimeOfDay.now().hour;
    int toMinuteLaunch = dataToString.isNotEmpty
        ? int.tryParse(dataToString.split(":").last) ?? TimeOfDay.now().minute
        : TimeOfDay.now().minute;

    Duration difference = DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, toHourLaunch, toMinuteLaunch)
        .difference(DateTime(DateTime.now().year, DateTime.now().month,
            DateTime.now().day, fromHourLaunch, fromMinuteLaunch));
    int hour = difference.inHours;
    int minute = difference.inMinutes;
    breakMin = (hour * 60) + minute;

    setState(() {
      if (hour >= 0) {
        hourLaunch = hour < 10 ? "0$hour" : hour.toString();
        if (minute >= 0) {
          minuteLaunch = (minute % 60) < 10
              ? "0${(minute % 60)}"
              : (minute % 60).toString();
        } else {
          minuteLaunch = "00";
        }
      } else {
        hourLaunch = "00";
        minuteLaunch = "00";
      }
    });
    print("Launch : $hourLaunch:$minuteLaunch");
    return "$hourLaunch:$minuteLaunch";
  }

  get2CharString(int data) {
    return data > 9 ? data.toString() : "0$data";
  }

  sendRiskAlert() async {
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);

          int tsconfirm = 0;
          if (widget.model.tSConfirm != null) {
            tsconfirm = widget.model.tSConfirm! ? 1 : 0;
          }

          String body = json.encode({
            'auth_code':
                (await Preferences().getPrefString(Preferences.prefAuthCode)),
            'rosterId': widget.model.rosterID != null
                ? widget.model.rosterID.toString()
                : "0",
            'clientId': widget.model.rESID != null
                ? widget.model.rESID.toString()
                : "0",
            'userId':
                widget.model.empID != null ? widget.model.empID.toString() : 0,
            'shiftComments': _controllerTimeSheetComments.text + " ",
            'riskAlert': isRecurringService.toString(),
            'tsId': widget.model.timesheetID != null
                ? widget.model.timesheetID.toString()
                : "0",
          });
          print(body);

          Response response = await http.post(
              Uri.parse("$masterURL$updateShiftCommentsAndSendRiskAlert"),
              headers: {"Content-Type": "application/json"},
              body: body);
          // response = await HttpService().init(request, _keyScaffold);
          log("Response $updateShiftCommentsAndSendRiskAlert : ${response.body}");
          if (response != null) {
            var jResponse = json.decode(response.body.toString());
            var jres = json.decode(jResponse["d"]);
            if (jres["status"] == 1) {
              showSnackBarWithText(_keyScaffold.currentState, "Success",
                  color: colorGreen);
              Navigator.pop(context, 0);
            }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          log("SignUp $e");
          removeOverlay();
          throw e;
        } finally {
          removeOverlay();
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  saveTimeSheet(String address, String sSEID, bool isToday) async {
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        try {
          getOverlay(context);

          int tsconfirm = 0;
          if (widget.model.tSConfirm != null) {
            tsconfirm = widget.model.tSConfirm! ? 1 : 0;
          }

          String body = json.encode({
            'auth_code':
                (await Preferences().getPrefString(Preferences.prefAuthCode)),
            'timesheetID': widget.model.timesheetID != null
                ? widget.model.timesheetID.toString()
                : "0",
            'RosterID': widget.model.rosterID != null
                ? widget.model.rosterID.toString()
                : "0",
            'TSFrom': "1899-12-30 ${_controllerFromService.text}",
            'TSUntil': "1899-12-30 ${_controllerToService.text}",
            'TSLunchBreakSetting': isIncludeLaunchBrake.toString(),
            'TSLunchBreak': isIncludeLaunchBrake
                ? "${_controllerHourLaunch.text}"
                : "00.00",
            'TSLBFrom': isIncludeLaunchBrake
                ? "1899-12-30 ${_controllerFromLaunch.text}"
                : "1899-12-30 00:00",
            'TSLBTo': isIncludeLaunchBrake
                ? "1899-12-30 ${_controllerToLaunch.text}"
                : "1899-12-30 00:00",
            'TSHours': timeToDecimal(totalWorkMin),
            'TSTravelDistance': _controllerTravelDistance.text.isEmpty
                ? "0.0"
                : _controllerTravelDistance.text,
            'TSComments': _controllerTimeSheetComments.text + " ",
            'TSConfirm': tsconfirm,
            'TSHoursDiff': 0.0, //not in use
            'TSTravelDistanceDiff': "0.0", //not in use
            'TSTravelTime': timeToDecimal(travelMin),
            'tsHoursDifference': diffHours,
            'empID':
                widget.model.empID != null ? widget.model.empID.toString() : 0,
            'RosterDate': DateFormat("dd/MM/yyyy")
                .format(getDateTimeFromEpochTime(widget.model.serviceDate!)!),
            'RiskAlert': isRecurringService.toString(),
            'clientID': widget.model.rESID != null
                ? widget.model.rESID.toString()
                : "0",
            'TSClientTravelDistance':
                _controllerClientTravelDistance.text.isEmpty
                    ? "0.0"
                    : _controllerClientTravelDistance.text,
            'ssEmployeeID': widget.model.servicescheduleemployeeID != null
                ? widget.model.servicescheduleemployeeID.toString()
                : "0",
            'servicetypeid': widget.model.tsservicetype != null
                ? widget.model.tsservicetype.toString()
                : "0",
            'fundingSourceName': widget.model.fundingsourcename,
          });
          print(body);

          if (body.isEmpty) {
            return;
          }

          Response response = await http.post(
              Uri.parse("$masterURL$endSaveTimesheet"),
              headers: {"Content-Type": "application/json"},
              body: body);
          // response = await HttpService().init(request, _keyScaffold);
          log("Response $endSaveTimesheet : ${response.body}");
          if (response != null) {
            var jResponse = json.decode(response.body.toString());
            var jres = json.decode(jResponse["d"]);
            if (jres["status"] == 1) {
              if (isToday) {
                saveLocationTime(address, sSEID);
              } else {
                showSnackBarWithText(_keyScaffold.currentState, "Success",
                    color: colorGreen);
                Navigator.pop(context, 0);
              }
            }
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          log("SignUp $e");
          removeOverlay();
          throw e;
        } finally {
          removeOverlay();
        }
      } else {
        showSnackBarWithText(_keyScaffold.currentState, stringErrorNoInterNet);
      }
    });
  }

  Future<String?> getAddress() async {
    try {
      getOverlay(context);
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showSnackBarWithText(
            _keyScaffold.currentState, "Please Enable the Location!");
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showSnackBarWithText(
              _keyScaffold.currentState, "We need Location Permission!");
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        showSnackBarWithText(
            _keyScaffold.currentState, "We need Location Permission!");
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> addressList =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark placeMark = addressList[0];
      String address = "";

      void appendIfNotEmpty(String value) {
        if (value.trim().isNotEmpty) {
          address += "$value, ";
        }
      }

      appendIfNotEmpty(placeMark.name ?? "");
      appendIfNotEmpty(placeMark.subLocality ?? "");
      appendIfNotEmpty(placeMark.locality ?? "");
      appendIfNotEmpty(placeMark.administrativeArea ?? "");
      appendIfNotEmpty(placeMark.postalCode ?? "");
      appendIfNotEmpty(placeMark.country ?? "");

      address = address.trim();
      if (address.isNotEmpty) {
        address = address.substring(0, address.length - 1);
      }
      return address;
    } catch (e) {
      showSnackBarWithText(_keyScaffold.currentState, stringSomeThingWentWrong);
      print(e);
    } finally {
      removeOverlay();
      // setState(() {});
    }
    // return null;
  }

  saveLocationTime(String address, String sSEID) async {
    Map<String, dynamic> params = {
      'auth_code':
          (await Preferences().getPrefString(Preferences.prefAuthCode)),
      'userid':
          (await Preferences().getPrefInt(Preferences.prefUserID)).toString(),
      'servicescheduleemployeeID': sSEID,
      'Location': address,
      'SaveTimesheet': "true",
    };
    print("params : ${params}");
    isConnected().then((hasInternet) async {
      if (hasInternet) {
        HttpRequestModel request = HttpRequestModel(
            url: getUrl(endSaveLocationTime, params: params).toString(),
            authMethod: '',
            body: '',
            headerType: '',
            params: '',
            method: 'GET');
        getOverlay(context);
        try {
          String response = await HttpService().init(request, _keyScaffold);
          removeOverlay();
          if (response != null && response != "") {
            // print('res ${response}');

            if (json.decode(response)["status"] == 1) {
              showSnackBarWithText(_keyScaffold.currentState, "Success",
                  color: colorGreen);
              Navigator.pop(context, 0);
            }
            setState(() {});
          } else {
            showSnackBarWithText(
                _keyScaffold.currentState, stringSomeThingWentWrong);
          }
          removeOverlay();
        } catch (e) {
          print("ERROR : $e");
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
}

enum Calendar { day, week, month, year }

class SingleChoice extends StatefulWidget {
  const SingleChoice({super.key});

  @override
  State<SingleChoice> createState() => _SingleChoiceState();
}

class _SingleChoiceState extends State<SingleChoice> {
  Calendar calendarView = Calendar.day;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Calendar>(
      showSelectedIcon: false,
      segments: const <ButtonSegment<Calendar>>[
        ButtonSegment<Calendar>(
          value: Calendar.day,
          label: Text('Daily'),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.week,
          label: Text('Weekly'),
        ),
        ButtonSegment<Calendar>(
          value: Calendar.month,
          label: Text('Fortnightly'),
        ),
      ],
      selected: <Calendar>{calendarView},
      onSelectionChanged: (Set<Calendar> newSelection) {
        setState(() {
          // By default there is only a single segment that can be
          // selected at one time, so its value is always the first
          // item in the selected set.
          calendarView = newSelection.first;
        });
      },
    );
  }
}

enum Day { mon, tue, wed, thu, fri, sat, sun }

class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key});

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  Set<Day> selection = <Day>{Day.mon};

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Day>(
      segments: const <ButtonSegment<Day>>[
        ButtonSegment<Day>(value: Day.mon, label: Text('M')),
        ButtonSegment<Day>(value: Day.tue, label: Text('T')),
        ButtonSegment<Day>(value: Day.wed, label: Text('W')),
        ButtonSegment<Day>(
          value: Day.thu,
          label: Text('T'),
        ),
        ButtonSegment<Day>(value: Day.fri, label: Text('F')),
        ButtonSegment<Day>(
          value: Day.sat,
          label: Text('S'),
        ),
        ButtonSegment<Day>(value: Day.sun, label: Text('S')),
      ],
      selected: selection,
      showSelectedIcon: false,
      onSelectionChanged: (Set<Day> newSelection) {
        setState(() {
          selection = newSelection;
        });
      },
      multiSelectionEnabled: true,
    );
  }
}

String timeToDecimal(int minute) {
  double value = ((minute * 100) / 60) / 100;
  return value.toStringAsFixed(2);
}

String getTimeStringFromDouble(double value) {
  if (value < 0) return 'Invalid Value';
  int totalMin = (value * 60).round();
  int hour = (totalMin / 60).toInt();
  int min = totalMin % 60;
  String hourValue = getHourString(hour);
  String minuteString = getMinuteString(min);

  return '$hourValue:$minuteString';
}

String getMinuteString(int decimalValue) {
  return '$decimalValue'.padLeft(2, '0');
}

String getHourString(int flooredValue) {
  return '$flooredValue'.padLeft(2, '0');
}

/*
void main() {
  TimeOfDay range1StartTime = TimeOfDay(hour: 22, minute: 0); // Range 1: 10:00 PM
  TimeOfDay range1EndTime = TimeOfDay(hour: 6, minute: 0);    // Range 1: 6:00 AM next day

  TimeOfDay range2StartTime = TimeOfDay(hour: 23, minute: 0); // Range 2: 11:00 PM
  TimeOfDay range2EndTime = TimeOfDay(hour: 2, minute: 0);   // Range 2: 2:00 AM next day

  if (isSubPartOfTimeRange(range2StartTime, range2EndTime, range1StartTime, range1EndTime)) {
    print('Range 2 is a sub-part of Range 1.');
  } else {
    print('Range 2 is not a sub-part of Range 1.');
  }
}

bool isSubPartOfTimeRange(TimeOfDay range2StartTime, TimeOfDay range2EndTime, TimeOfDay range1StartTime, TimeOfDay range1EndTime) {
  int startComparison = TimeOfDayExtension.compare(range2StartTime, range1StartTime);
  int endComparison = TimeOfDayExtension.compare(range2EndTime, range1EndTime);

  if (startComparison >= 0 && endComparison <= 0) {
    return true;
  }

  // Check for overnight scenario
  TimeOfDay endOfDay = TimeOfDay(hour: 23, minute: 59);
  TimeOfDay startOfDay = TimeOfDay(hour: 0, minute: 0);

  int startComparisonOvernight = TimeOfDayExtension.compare(range2StartTime, startOfDay);
  int endComparisonOvernight = TimeOfDayExtension.compare(range2EndTime, endOfDay);

  return startComparisonOvernight >= 0 && endComparisonOvernight <= 0;
}

extension TimeOfDayExtension on TimeOfDay {
  static int compare(TimeOfDay a, TimeOfDay b) {
    if (a.hour < b.hour) {
      return -1;
    } else if (a.hour > b.hour) {
      return 1;
    } else {
      return a.minute.compareTo(b.minute);
    }
  }
}


 */
