import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart';
import '../../extensions/LiveStream.dart';
import '../../extensions/extension_util/int_extensions.dart';
import '../../extensions/extension_util/string_extensions.dart';
import '../../extensions/extension_util/widget_extensions.dart';
import '../../main/models/VehicleModel.dart';
import '../../main/utils/Widgets.dart';
import '../../extensions/app_button.dart';
import '../../extensions/app_text_field.dart';
import '../../extensions/common.dart';
import '../../extensions/shared_pref.dart';
import '../../extensions/system_utils.dart';
import '../../extensions/text_styles.dart';
import '../../main.dart';
import '../../main/components/CommonScaffoldComponent.dart';
import '../../main/models/DeliverymanVehicleListModel.dart';
import '../../main/models/VehicleSavedResponse.dart';
import '../../main/network/NetworkUtils.dart';
import '../../main/network/RestApis.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Constants.dart';
import '../../main/utils/dynamic_theme.dart';

class AddDeliverymanVehicleScreen extends StatefulWidget {
  final VehicleInfo? vehicle;
  final bool? isUpdate;

  AddDeliverymanVehicleScreen({this.vehicle, this.isUpdate = false});

  @override
  AddDeliverymanVehicleScreenState createState() => AddDeliverymanVehicleScreenState();
}

class AddDeliverymanVehicleScreenState extends State<AddDeliverymanVehicleScreen> {
  ScrollController scrollController = ScrollController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<VehicleData> vehicleList = [];
  int? selectedVehicle;
  bool isReadOnly = false;

  TextEditingController makeCont = TextEditingController();
  TextEditingController modelCont = TextEditingController();
  TextEditingController colorCont = TextEditingController();
  TextEditingController manufactureYearCont = TextEditingController();
  TextEditingController vehicleIdCont = TextEditingController();
  TextEditingController licenceNoCont = TextEditingController();
  TextEditingController currentMileageCont = TextEditingController();
  TextEditingController fuelTypeCont = TextEditingController();
  TextEditingController transmissionTypeCont = TextEditingController();
  TextEditingController ownerNameCont = TextEditingController();
  TextEditingController addressCont = TextEditingController();
  TextEditingController ownerNumberCont = TextEditingController();
  TextEditingController registrationDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
    if (widget.vehicle != null) {
      isReadOnly = true;
      selectedVehicle = int.parse(widget.vehicle!.vehicleId.validate());
      makeCont.text = widget.vehicle!.make.validate();
      modelCont.text = widget.vehicle!.model.validate();
      colorCont.text = widget.vehicle!.color.validate();
      manufactureYearCont.text = widget.vehicle!.yearOfManufacture.validate();
      vehicleIdCont.text = widget.vehicle!.vehicleIdentificationNumber.validate();
      licenceNoCont.text = widget.vehicle!.licensePlateNumber.validate();
      currentMileageCont.text = widget.vehicle!.currentMileage.validate();
      fuelTypeCont.text = widget.vehicle!.fuelType.validate();
      transmissionTypeCont.text = widget.vehicle!.transmissionType.validate();
      ownerNameCont.text = widget.vehicle!.ownerName.validate();
      addressCont.text = widget.vehicle!.address.validate();
      ownerNumberCont.text = widget.vehicle!.ownerNumber.validate();
      registrationDateController.text = widget.vehicle!.registrationAte.toString();
    }
    if (widget.isUpdate == true) {
      isReadOnly = false;
    }
  }

  getVehicleApiCall({String? name}) async {
    appStore.setLoading(true);
    await getVehicleList().then((value) {
      appStore.setLoading(false);
      vehicleList.clear();
      vehicleList = value.data!;
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error);
    });
  }

  void init() async {
    getVehicleApiCall();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  saveVehicle() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);

      MultipartRequest multiPartRequest = await getMultiPartRequest('deliverymanvehiclehistory-save');
      multiPartRequest.fields['make'] = makeCont.text;
      multiPartRequest.fields['model'] = modelCont.text;
      multiPartRequest.fields['color'] = colorCont.text;
      multiPartRequest.fields['year_of_manufacture'] = manufactureYearCont.text;
      multiPartRequest.fields['vehicle_identification_number'] = vehicleIdCont.text;
      multiPartRequest.fields['license_plate_number'] = licenceNoCont.text;
      multiPartRequest.fields['current_mileage'] = currentMileageCont.text;
      multiPartRequest.fields['fuel_type'] = fuelTypeCont.text;
      multiPartRequest.fields['transmission_type'] = transmissionTypeCont.text;
      multiPartRequest.fields['owner_name'] = ownerNumberCont.text;
      multiPartRequest.fields['address'] = addressCont.text;
      multiPartRequest.fields['registration_date'] = registrationDateController.text;
      multiPartRequest.fields['owner_number'] = ownerNumberCont.text;
      multiPartRequest.fields['vehicle_id'] = selectedVehicle.toString();
      multiPartRequest.headers.addAll(buildHeaderTokens());
      sendMultiPartRequest(
        multiPartRequest,
        onSuccess: (data) async {
          if (data != null) {
            VehicleSavedResponse res = VehicleSavedResponse.fromJson(data);
            toast(res.message.toString());
            setValue(VEHICLE, res.data!.toJson());
            LiveStream().emit("VehicleInfo");
            appStore.setLoading(false);
            finish(context);
          }
        },
        onError: (error) {
          toast(error.toString(), print: true);
          appStore.setLoading(false);
        },
      ).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffoldComponent(
      appBar: commonAppBarWidget(
        widget.isUpdate == true
            ? language.updateVehicle
            : isReadOnly
                ? language.vehicleInfo
                : language.addVehicle,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Text(language.selectVehicle, style: primaryTextStyle()),
                    8.height,
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: selectedVehicle,
                      decoration: commonInputDecoration(),
                      dropdownColor: Theme.of(context).cardColor,
                      style: primaryTextStyle(),
                      items: vehicleList.map<DropdownMenuItem<int>>((item) {
                        return DropdownMenuItem(
                          value: item.id,
                          child: Row(
                            children: [
                              commonCachedNetworkImage(item.vehicleImage.validate(), height: 40, width: 40),
                              SizedBox(width: 16),
                              Text("${item.title.validate()}", style: primaryTextStyle()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: isReadOnly
                          ? null
                          : (value) {
                              selectedVehicle = value;
                              setState(() {});
                            },
                      validator: (value) {
                        if (selectedVehicle == null) return language.fieldRequiredMsg;
                        return null;
                      },
                    ),
                    16.height,
                    Text(language.name, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: makeCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.name),
                    ),
                    16.height,
                    Text(language.model, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: modelCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.model),
                    ),
                    16.height,
                    Text(language.color, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: colorCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.color),
                    ),
                    16.height,
                    Text(language.yearOfManufacturing, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: manufactureYearCont,
                      textFieldType: TextFieldType.NUMBER,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.yearOfManufacturing),
                    ),
                    16.height,
                    Text(language.vehicleIdentificationNumber, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: vehicleIdCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.vehicleIdentificationNumber),
                    ),
                    16.height,
                    Text(language.licensePlateNumber, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: licenceNoCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.licensePlateNumber),
                    ),
                    16.height,
                    Text(language.currentMileage, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: currentMileageCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.currentMileage),
                    ),
                    16.height,
                    Text(language.fuelType, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: fuelTypeCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.fuelType),
                    ),
                    16.height,
                    Text(language.transmissionType, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: transmissionTypeCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.transmissionType),
                    ),
                    16.height,
                    Text(language.ownerName, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: ownerNameCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.ownerName),
                    ),
                    16.height,
                    Text(language.address, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: addressCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.address),
                    ),
                    16.height,
                    Text(language.registrationDate, style: primaryTextStyle()),
                    8.height,
                    DateTimePicker(
                      controller: registrationDateController,
                      readOnly: isReadOnly,
                      type: DateTimePickerType.date,
                      fieldHintText: language.from,
                      lastDate: DateTime(2050),
                      firstDate: DateTime(2010),
                      onChanged: (value) {
                        registrationDateController.text = value;
                        setState(() {});
                      },
                      validator: (value) {
                        if (registrationDateController.text.isEmptyOrNull) {
                          return language.mustSelectStartDate;
                        }
                        return null;
                      },
                      decoration: commonInputDecoration(suffixIcon: Ionicons.calendar_outline, hintText: language.from),
                    ),
                    16.height,
                    Text(language.ownerNumber, style: primaryTextStyle()),
                    8.height,
                    AppTextField(
                      isValidationRequired: true,
                      controller: ownerNumberCont,
                      textFieldType: TextFieldType.NAME,
                      readOnly: isReadOnly,
                      errorThisFieldRequired: language.fieldRequiredMsg,
                      decoration: commonInputDecoration(hintText: language.ownerNumber),
                    ),
                  ],
                )),
          ),
          Observer(builder: (context) => loaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: !isReadOnly
          ? AppButton(
              color: ColorUtils.colorPrimary,
              textColor: Colors.white,
              text: language.save,
              onTap: () {
                saveVehicle();
              }).paddingAll(16)
          : null,
    );
  }
}
