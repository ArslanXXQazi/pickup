import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class ParentTrackPickupController extends GetxController {
  final String childId;
  ParentTrackPickupController(this.childId);

  // Child info
  var childName = ''.obs;
  var bus = ''.obs;
  var status = ''.obs;

  // Driver info
  var driverId = ''.obs;
  var driverName = ''.obs;

  // Map data
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var polylines = <Polyline>{}.obs;
  var dropMarkers = <Marker>[].obs;
  var driverMarker = Rxn<Marker>();
  var locationSharing = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToChildDoc();
  }

  void _listenToChildDoc() {
    FirebaseFirestore.instance.collection('addChild').doc(childId).snapshots().listen((doc) {
      if (doc.exists) {
        var data = doc.data()!;
        childName.value = data['childName'] ?? '';
        bus.value = data['bus'] ?? '';
        status.value = data['status'] ?? '';
        driverId.value = data['assignedDriverId'] ?? '';
        print('[DEBUG] childName: [32m${childName.value}[0m, bus: [32m${bus.value}[0m, status: [32m${status.value}[0m, driverId: [32m${driverId.value}[0m');
        // dropMarker logic
        if (data.containsKey('dropMarker') && data['dropMarker'] != null) {
          var dropMarkerData = data['dropMarker'];
          print('[DEBUG] dropMarker Firestore se mila: $dropMarkerData');
          DateTime droppedAt = DateTime.tryParse(dropMarkerData['droppedAt'] ?? '') ?? DateTime.now().subtract(Duration(minutes: 2));
          print('[DEBUG] droppedAt: $droppedAt, abhi: ${DateTime.now()}');
          print('[DEBUG] difference: ${DateTime.now().difference(droppedAt).inSeconds} seconds');
          if (DateTime.now().difference(droppedAt).inSeconds < 60) {
            // Show yellow marker for 1 minute
            dropMarkers.value = [
              Marker(
                markerId: MarkerId('drop_marker'),
                position: LatLng((dropMarkerData['lat'] as num).toDouble(), (dropMarkerData['lng'] as num).toDouble()),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
                infoWindow: InfoWindow(
                  title: 'Child Dropped',
                  snippet: dropMarkerData['childName'] ?? '',
                ),
              ),
            ];
          } else {
            // 1 minute se zyada ho gaya, Firestore se bhi hata do
            FirebaseFirestore.instance.collection('addChild').doc(childId).update({'dropMarker': null});
            dropMarkers.clear();
          }
        } else {
          dropMarkers.clear();
        }
        // Driver ki location sunne ke liye _listenToDriver() call karo agar driverId mile
        if (driverId.value.isNotEmpty) {
          print('[DEBUG] Calling _listenToDriver for driverId: [34m${driverId.value}[0m');
          _listenToDriver();
        } else {
          print('[DEBUG] No driverId assigned to this child.');
        }
      } else {
        print('[DEBUG] No child document found for childId: $childId');
      }
    });
  }

  void _listenToDriver() {
    print('[DEBUG] _listenToDriver started for driverId: ${driverId.value}');
    FirebaseFirestore.instance.collection('userData').doc(driverId.value).snapshots().listen((doc) {
      if (doc.exists) {
        var data = doc.data()!;
        driverName.value = data['name'] ?? '';
        locationSharing.value = data['locationSharing'] ?? true;
        latitude.value = data['latitude'] ?? 0.0;
        longitude.value = data['longitude'] ?? 0.0;
        // Polyline points Firestore se read karo
        if (data.containsKey('routePoints') && data['routePoints'] is List) {
          List<dynamic> points = data['routePoints'];
          List<LatLng> polyPoints = points.map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble())).toList();
          polylines.value = {
            Polyline(
              polylineId: PolylineId('driver_route'),
              color: Colors.blue,
              width: 5,
              points: polyPoints,
            ),
          };
        }
        print('[DEBUG] Driver Location: [33m${latitude.value}, ${longitude.value}[0m, driverName: [32m${driverName.value}[0m');
        driverMarker.value = Marker(
          markerId: MarkerId('driver_location'),
          position: LatLng(latitude.value, longitude.value),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: driverName.value,
            snippet: bus.value,
          ),
        );
      } else {
        print('[DEBUG] No driver document found for driverId: ${driverId.value}');
      }
    });
    // TODO: Listen to drop markers and polyline if stored in Firestore
  }
} 