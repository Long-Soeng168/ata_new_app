// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/my_search.dart';
import 'package:ata_new_app/models/dtc.dart';
import 'package:ata_new_app/services/dtc_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DtcPage extends StatefulWidget {
  const DtcPage({super.key});

  @override
  State<DtcPage> createState() => _DtcPageState();
}

class _DtcPageState extends State<DtcPage> {
  Dtc? dtcDetail; // Make dtcDetail nullable
  bool isLoadingDtcDetail = false; // Start with no loading indicator
  bool isLoadingDtcDetailError = false;
  TextEditingController searchController = TextEditingController();

  Future<void> getDtcDetail(String dtcCode) async {
    try {
      // Fetch dtcDetail based on the search input
      final fetchedDtcDetail = await DtcService.fetchDtcById(dtcCode: dtcCode);
      // Update the state
      setState(() {
        dtcDetail = fetchedDtcDetail;
        isLoadingDtcDetail = false; // Stop loading after fetching data
        isLoadingDtcDetailError = false; // Reset error state if successful
      });
      // print(dtcDetail);
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingDtcDetail = false;
        isLoadingDtcDetailError = true;
      });
      print('Failed to load Dtc Detail: $error');
    }
  }

  void onSearchSubmit() {
    String searchText = searchController.text.trim();
    if (searchText.isNotEmpty) {
      setState(() {
        isLoadingDtcDetail =
            true; // Show loading indicator when search is submitted
        isLoadingDtcDetailError = false; // Reset error state
      });
      getDtcDetail(searchText); // Perform the search with the input DTC code
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
          title: Text(
            'DTC'.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Start Search
              MySearch(
                searchController: searchController,
                onSearchSubmit: onSearchSubmit,
                placeholder: "Search DTC".tr() + ' (កូដកំហូច)...',
              ),
              // End Search

              SizedBox(height: 8),

              // Start dtcDetail Grid
              if (isLoadingDtcDetail)
                SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!isLoadingDtcDetail &&
                  !isLoadingDtcDetailError &&
                  dtcDetail != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        dtcDetail!.dtcCode, // Use ! to access non-null value
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        dtcDetail!.descriptionKh,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        dtcDetail!.descriptionEn,
                        style: TextStyle(fontSize: 16),
                      ),
                      Visibility(
                        visible: dtcDetail!.dtcCode.isEmpty,
                        child: Center(
                          child: Text('No Data for this CODE'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              if (isLoadingDtcDetailError)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Center(
                    child: Text('Error Loading Resources'.tr()),
                  ),
                ),

              // End dtcDetail Grid

              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
