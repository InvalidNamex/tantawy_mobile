import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../controllers/negative_visits_controller.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/app_background.dart';
import '../../../widgets/date_picker_field.dart';
import '../../../widgets/app_bottom_navigation.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../theme/app_colors_extension.dart';
import '../../settings/controllers/settings_controller.dart';

class NegativeVisitsView extends GetView<NegativeVisitsController> {
  const NegativeVisitsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Obx(
      () => Directionality(
        textDirection: settingsController.isArabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            centerTitle: true,
            title: Text('negative_visits'.tr),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          drawer: AppDrawer(),
          body: Stack(
            children: [
              AppBackground(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Date Filters
                        Row(
                          children: [
                            Expanded(
                              child: DatePickerField(
                                label: 'from_date'.tr,
                                onDateChanged: (date) {
                                  controller.setFromDate(date);
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DatePickerField(
                                label: 'to_date'.tr,
                                onDateChanged: (date) {
                                  controller.setToDate(date);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Visits List
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: controller.syncVisits,
                            child: controller.isLoading.value
                                ? Center(child: CircularProgressIndicator())
                                : controller.filteredVisits.isEmpty
                                ? EmptyStateWidget(
                                    icon: Icons.cancel_outlined,
                                    message: 'no_visits_found'.tr,
                                  )
                                : ListView.builder(
                                    itemCount: controller.filteredVisits.length,
                                    itemBuilder: (context, index) {
                                      final visit =
                                          controller.filteredVisits[index];
                                      return Card(
                                        margin: EdgeInsets.only(bottom: 12),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.all(16),
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      visit
                                                              .customerVendorName
                                                              .isNotEmpty
                                                          ? visit
                                                                .customerVendorName
                                                          : 'Unknown Customer',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'negative_visit'.tr,
                                                  style: TextStyle(
                                                    color: Colors.orange[700],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_today,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        DateFormat(
                                                          'yyyy-MM-dd HH:mm',
                                                        ).format(visit.date),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.location_on,
                                                      color: context
                                                          .colors
                                                          .primary,
                                                      size: 24,
                                                    ),
                                                    onPressed: () =>
                                                        controller.openMap(
                                                          visit.latitude,
                                                          visit.longitude,
                                                        ),
                                                    tooltip: 'view_location'.tr,
                                                    padding: EdgeInsets.all(8),
                                                    constraints:
                                                        BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                              if (visit.notes.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 8,
                                                      ),
                                                  child: Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                          Icons.note,
                                                          size: 14,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                        SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            visit.notes,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[700],
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AppBottomNavigation(
                  currentIndex: controller.currentIndex.value,
                  onIndexChanged: controller.changeIndex,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
