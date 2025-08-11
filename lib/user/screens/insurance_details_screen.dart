import 'package:flutter/material.dart';
import '../../main.dart';
import '../../main/components/HtmlWidgtet.dart';
import '../../main/models/PageResponse.dart';
import '../../main/utils/Common.dart';
import '../../main/utils/Widgets.dart';

import '../../main/network/RestApis.dart';

class InsuranceDetailsScreen extends StatefulWidget {
  String insuranceDescription;
  InsuranceDetailsScreen(this.insuranceDescription, {super.key});

  @override
  State<InsuranceDetailsScreen> createState() => _InsuranceDetailsScreenState();
}

class _InsuranceDetailsScreenState extends State<InsuranceDetailsScreen> {
  PageResponse? data;
  String title = '';
  String description = '';

  @override
  void initState() {
    super.initState();
    getInsuranceDetails();
  }

  getInsuranceDetails() async {
    appStore.setLoading(true);
    await getPageDetailsById(id: widget.insuranceDescription).then((value) {
      title = value.data!.title!;
      description = value.data!.description!;
      appStore.setLoading(false);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: commonAppBarWidget((title.isNotEmpty) ? title.toString() : ""),
        body: Stack(
          children: [
            description.isNotEmpty
                ? SingleChildScrollView(child: HtmlWidget(postContent: description))
                : !appStore.isLoading
                    ? emptyWidget()
                    : SizedBox(),
            if (appStore.isLoading)
              Center(
                child: loaderWidget(),
              )
          ],
        ));
  }
}
