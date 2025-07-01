import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'parent_track_pickup_controller.dart';
import '../../controller/constant/linkers/linkers.dart';
import 'package:location/location.dart';

class TrackPickup extends StatelessWidget {
  const TrackPickup({super.key});

  @override
  Widget build(BuildContext context) {
    // Add location permission check
    final String? childId = Get.arguments != null ? Get.arguments['childId'] : null;
    return FutureBuilder<bool>(
      future: _checkLocationPermission(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.data!) {
          return const Scaffold(
            body: Center(child: Text('Location permission is required to track the driver. Please enable location permission in your device settings.')),
          );
        }
        if (childId == null) {
          return const Scaffold(
            body: Center(child: Text('No child selected for tracking.')),
          );
        }
        final ParentTrackPickupController controller = Get.put(ParentTrackPickupController(childId));
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        return Scaffold(
          body: Obx(() {
            // Show loading if child info not loaded yet
            if (controller.childName.value.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            // Show loading if driver location is not available yet
            if (controller.latitude.value == 0.0 && controller.longitude.value == 0.0) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!controller.locationSharing.value) {
              return const Center(child: Text('Driver is not sharing location right now.'));
            }
            return Stack(
              children: [
                // Always show map if driver location is available
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(controller.latitude.value, controller.longitude.value),
                    zoom: 16,
                  ),
                  markers: {
                    if (controller.driverMarker.value != null) controller.driverMarker.value!,
                    ...controller.dropMarkers,
                  },
                  polylines: controller.polylines.value,
                  trafficEnabled: true,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreenText(
                        text: "Track Pickup",
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ProfileContainer(
                              radius: 25,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GreenText(
                                    text: controller.childName.value,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(height: 5),
                                  YellowButton(
                                    text: controller.status.value,
                                    width: 120,
                                    height: 35,
                                    borderRadius: 10,
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                                child: Row(
                              children: [
                                Container(
                                  height: screenHeight * 0.055,
                                  width: screenHeight * 0.055,
                                  decoration: BoxDecoration(
                                    color: AppColors.yellowColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.darkBlue, width: 2),
                                  ),
                                  child: Center(
                                    child: ImageIcon(
                                      AssetImage(AppImages.bus),
                                      color: AppColors.darkBlue,
                                      size: screenWidth * 0.07,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GreenText(
                                      text: controller.bus.value.isNotEmpty ? controller.bus.value : 'No Bus',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ],
                                ),
                              ],
                            ))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Future<bool> _checkLocationPermission() async {
    Location location = Location();
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
}