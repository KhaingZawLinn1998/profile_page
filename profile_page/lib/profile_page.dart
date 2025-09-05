import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zoom_widget/zoom_widget.dart';
import 'package:image/image.dart' as img;
import 'model/config.dart';
import 'model/img.dart';
import 'model/user_data.dart';
import 'widget/widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage(
      {super.key,
      UserData? userData,
      Config? config,
      required this.buttonTxt,
      required this.buttonCallBack})
      : userData = userData ?? const UserData(),
        config = config ?? const Config();

  final UserData userData;
  final Config config;
  final String buttonTxt;
  final Function(ButtonCallBack) buttonCallBack;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ValueNotifier<String> _profileImagePath = ValueNotifier<String>("");

  final ImagePicker imgpicker = ImagePicker();
  String imagebase64string = "";
  String imageName = "";
  bool isChoosedImage = false;
  XFile? _pickedFile;
  String imagePath = "";

  TextEditingController nameCtrl = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController dobCtrl = TextEditingController();
  TextEditingController addressCtrl = TextEditingController();
  String countryCode = "95";
  String phoneNo = "";
  final ValueNotifier<String> _genderValue = ValueNotifier<String>("1");
  CallbackUserData? userData = CallbackUserData(
      address: '', dob: '', email: '', gender: '', name: '', phone: '');
  List<DropdownMenuItem<String>> get genderItem {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(
          value: "1",
          child: Text("Male", style: Theme.of(context).textTheme.bodyMedium)),
      DropdownMenuItem(
          value: "2",
          child: Text("Female", style: Theme.of(context).textTheme.bodyMedium)),
      DropdownMenuItem(
          value: "0",
          child: Text("Other", style: Theme.of(context).textTheme.bodyMedium)),
    ];
    return menuItems;
  }

  @override
  void initState() {
    super.initState();

    nameCtrl.text = widget.userData.name;
    if (widget.userData.phoneNo.isNotEmpty) {
      seperatePhoneAndDialCode(widget.userData.phoneNo);
    }
    emailCtrl.text = widget.userData.email;
    dobCtrl.text = widget.userData.dob;
    addressCtrl.text = widget.userData.address;
    _genderValue.value = getGenderValue(widget.userData.gender);
    dobCtrl.text = widget.userData.dob;
    if (widget.userData.dob.isNotEmpty) {
      var date = DateTime.parse(widget.userData.dob);
      dobCtrl.text =
          '${date.day.toString()} ${DateFormat('MMM').format(date)} ${date.year.toString()}';
      userData = userData!.copyWith(
        dob: DateFormat('yyyy-MM-dd')
            .format(DateFormat("d MMM yyyy").parse(dobCtrl.text)),
      );
    }
    userData = userData!.copyWith(
        name: nameCtrl.text,
        email: emailCtrl.text,
        gender: _genderValue.value,
        address: addressCtrl.text);
  }

  String getGenderValue(String? value) {
    if (value == "Other") {
      return "0";
    } else if (value == "Male") {
      return "1";
    } else {
      return "2";
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    _profileImagePath.dispose();
    _genderValue.dispose();
    super.dispose();
  }

  void _fetchProfileImage() async {
    isChoosedImage = true;
    _pickedFile = await imgpicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
      maxWidth: 400,
      maxHeight: 400,
    );
    _cropImage();
  }

  Future<void> _cropImage() async {
    Uint8List imagebytes;
    if (_pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _pickedFile!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true,
              hideBottomControls: true),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: false,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        _profileImagePath.value = croppedFile.path;
        final imageBytes =
            img.decodeImage(File(_profileImagePath.value).readAsBytesSync())!;
        imagebytes = Uint8List.fromList(img.encodePng(imageBytes));
        imagebase64string = base64.encode(imagebytes);
        imagePath = croppedFile.path;
        imageName = _pickedFile!.name;
      }
    }
  }

  bool isBase64(String str) {
    try {
      base64.decode(str);
      if (str.length % 4 != 0) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  DateTime selectedDate = DateTime.now();
  DateTime currentDate = DateTime.now();

  _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      locale: Locale("en", "US"),
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2060),
      confirmText: "Ok",
      cancelText: "Cancel",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              bodyLarge: TextStyle(fontWeight: FontWeight.normal),
              bodyMedium: TextStyle(fontWeight: FontWeight.normal),
              bodySmall: TextStyle(fontWeight: FontWeight.normal),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Theme.of(context).cardTheme.color,
            ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                  surfaceTint: Colors.transparent,
                ),
          ),
          child: Center(child: child),
        );
      },
    );
    if (selected != null) {
      if (selected.isBefore(currentDate)) {
        selectedDate = selected;
        dobCtrl.text =
            '${selected.day.toString()} ${DateFormat('MMM').format(selected)} ${selected.year.toString()}';
        userData =
            userData!.copyWith(dob: DateFormat('yyyy-MM-dd').format(selected));
      } else {
        throw Exception("invalid_selected_date");
      }
    }
  }

  void seperatePhoneAndDialCode(String phoneNo) {
    Map<String, String> foundedCountry = {};
    for (var country in Countries.allCountries) {
      String dialCode = country["dial_code"].toString();
      if (phoneNo.contains(dialCode)) {
        foundedCountry = country;
      }
    }

    if (foundedCountry.isNotEmpty) {
      phoneCtrl.text = phoneNo.substring(
        foundedCountry["dial_code"]!.length,
      );
      countryCode = foundedCountry["dial_code"]!;
      countryCode = countryCode.replaceAll('+', '');
      userData = CallbackUserData(phone: '+$countryCode${phoneCtrl.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.symmetric(horizontal: 6),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    if (imagePath.isNotEmpty) {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          duration: Duration(milliseconds: 280),
                          reverseDuration: Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                          child: FullViewImage(imagePath, isBase64(imagePath)),
                        ),
                      );
                    }
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.13,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: _profileImagePath,
                        builder: (context, value, child) {
                          return value.isEmpty &&
                                  widget.userData.base64.isNotEmpty
                              ? Image.memory(
                                  base64Decode(widget.userData.base64),
                                  fit: BoxFit.cover,
                                )
                              : value.isNotEmpty
                                  ? Image.file(
                                      File(value),
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.person, size: 50);
                        },
                      )),
                ),
                Positioned(
                    bottom: -5,
                    right: -5,
                    child: GestureDetector(
                      onTap: () {
                        _fetchProfileImage();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    )),
              ],
            ),
            SizedBox(height: 26),
            Card(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 18),
              child: Column(children: [
                BuildTextFormField(
                    label: "Name",
                    controller: nameCtrl,
                    change: (nameVal) {
                      userData = CallbackUserData(name: nameVal ?? "");
                    }),
                AbsorbPointer(
                  absorbing: widget.config.readOnlyPhoneNo,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.059,
                      child: InputDecorator(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).focusColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                  color: Theme.of(context).focusColor),
                            ),
                            contentPadding: EdgeInsets.only(left: 12),
                            labelText: "phone",
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: IntlPhoneField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            disableLengthCheck: true,
                            initialCountryCode: "MM",
                            style: TextStyle(fontSize: 16),
                            dropdownIcon: const Icon(
                              Icons.keyboard_arrow_down_sharp,
                              color: Colors.grey,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp('[0-9]+')),
                              LengthLimitingTextInputFormatter(13),
                            ],
                            dropdownIconPosition: IconPosition.trailing,
                            decoration: InputDecoration(
                              hintText: "9XXXXXXXXX",
                              hintStyle: TextStyle(fontSize: 14),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            controller: phoneCtrl,
                            onChanged: (phone) {
                              phoneNo = phone.number;
                              if (countryCode == "95") {
                                userData = userData!.copyWith(phone: phoneNo);
                              } else {
                                userData = userData!
                                    .copyWith(phone: '+$countryCode$phoneNo');
                              }
                            },
                            onCountryChanged: (country) {
                              countryCode = country.dialCode;
                              if (countryCode == "95") {
                                userData = userData!.copyWith(phone: phoneNo);
                              } else {
                                userData = userData!
                                    .copyWith(phone: '+$countryCode$phoneNo');
                              }
                            },
                          )),
                    ),
                  ),
                ),
                BuildTextFormField(
                  label: "Email",
                  controller: emailCtrl,
                  change: (emailVal) {
                    userData = userData!.copyWith(email: emailVal);
                  },
                ),
                AbsorbPointer(
                  absorbing: widget.config.readOnlyGender,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.059,
                        child: ValueListenableBuilder(
                          valueListenable: _genderValue,
                          builder: (context, value, child) {
                            return DropdownButtonFormField(
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).focusColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).focusColor,
                                      ),
                                    ),
                                    labelText: "Gender",
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 12)),
                                value: _genderValue.value,
                                onChanged: (String? newValue) {
                                  _genderValue.value = newValue!;
                                  userData =
                                      userData!.copyWith(gender: newValue);
                                },
                                items: genderItem);
                          },
                        )),
                  ),
                ),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    absorbing: widget.config.readOnlyDob,
                    child: BuildTextFormField(
                        label: "Date Of Birth",
                        controller: dobCtrl,
                        readOnly: widget.config.readOnlyDob),
                  ),
                ),
                BuildTextFormField(
                    label: "Address",
                    controller: addressCtrl,
                    change: (addressVal) {
                      userData = userData!.copyWith(address: addressVal);
                    }),
              ]),
            )),
            BuildButton(
                txt: widget.buttonTxt,
                onTap: () {
                  FocusScopeNode currentScope = FocusScope.of(context);
                  if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                  if (countryCode == "95") {
                    userData = userData!
                        .copyWith(phone: userData!.phone.getPhoneFormat());
                  } else {
                    userData = userData!.copyWith(phone: userData!.phone);
                  }
                  widget.buttonCallBack(ButtonCallBack(
                      imgData: ImgData(
                          base64: imagebase64string.isEmpty
                              ? widget.userData.base64
                              : imagebase64string,
                          imgName: imageName,
                          imgPath: imagePath),
                      callbackUserData: userData!));
                })
          ],
        ),
      ),
    );
  }
}

extension PhoneFormat on String {
  String getPhoneFormat() {
    if (length >= 8 && length <= 13) {
      if (indexOf("+") == 0 && (length == 12 || length == 13 || length == 11)) {
        return this;
      } else if (indexOf("09") == 0 &&
          (length == 10 || length == 11 || length == 9)) {
        return '+959${substring(2)}';
      } else if (indexOf("7") == 0 && length == 9) {
        return '+959$this';
      } else if (indexOf("9") == 0 && length == 9) {
        return '+959${substring(1)}';
      } else if (indexOf("9") == 0 &&
          indexOf("959") != 0 &&
          (length == 8 || length == 10)) {
        return '+959${substring(1)}';
      } else if (indexOf("7") != 0 &&
          indexOf("9") != 0 &&
          (length == 6 || length == 9 || length == 7)) {
        return '+959$this';
      } else if (indexOf("959") == 0 &&
          (length == 11 || length == 12 || length == 10)) {
        return '+959${substring(3)}';
      } else {
        return "";
      }
    } else {
      return "";
    }
  }
}

class FullViewImage extends StatelessWidget {
  final dynamic _image;
  final bool isBase64Image;

  const FullViewImage(this._image, this.isBase64Image, {super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: true,
        ),
        body: Zoom(
          initTotalZoomOut: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          canvasColor: Theme.of(context).scaffoldBackgroundColor,
          scrollWeight: 5,
          child: Center(
              child: isBase64Image == true
                  ? Image.memory(
                      base64Decode(_image),
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.contain,
                    )
                  : CachedNetworkImage(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.contain,
                      imageUrl: _image,
                      placeholder: (context, url) =>
                          Container(color: Theme.of(context).disabledColor),
                      errorWidget: (context, url, error) => NoImageView())),
        ),
      ),
    );
  }
}

class NoImageView extends StatelessWidget {
  const NoImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, size: 30));
  }
}
