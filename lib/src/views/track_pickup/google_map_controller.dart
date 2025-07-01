import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import '../driver_dashbord_view/driver_controller/driver_dashbord_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class GoogleMapControllerX extends GetxController {
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var isLoading = true.obs;
  var mapController = Rxn<GoogleMapController>();
  var marker = Rxn<Marker>();

  // Driver info for marker info window
  var driverName = ''.obs;
  var bus = ''.obs;

  // Polyline tracking
  var routePoints = <LatLng>[].obs;
  var polylines = <Polyline>{}.obs;

  // Drop markers (for dropped students)
  var dropMarkers = <Marker>[].obs;
  Timer? _cleanupTimer;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
    fetchDropMarkersFromFirestore(); // Fetch drop markers on init
  }

  // Call this to set driver info and update marker
  void setDriverInfo({required String name, required String busName}) {
    driverName.value = name;
    bus.value = busName;
    _updateMarker();
  }

  Future<void> getCurrentLocation() async {
    print('getCurrentLocation called');
    isLoading.value = true;
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    print('Service enabled: \u001b[32m$_serviceEnabled\u001b[0m');
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      print('Service requested: \u001b[32m$_serviceEnabled\u001b[0m');
      if (!_serviceEnabled) {
        isLoading.value = false;
        print('Service not enabled, returning');
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    print('Permission status: \u001b[32m$_permissionGranted\u001b[0m');
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      print('Permission requested: \u001b[32m$_permissionGranted\u001b[0m');
      if (_permissionGranted != PermissionStatus.granted) {
        isLoading.value = false;
        print('Permission not granted, returning');
        return;
      }
    }

    _locationData = await location.getLocation();
    print('Location: \u001b[34m${_locationData.latitude}, ${_locationData.longitude}\u001b[0m');
    latitude.value = _locationData.latitude ?? 0.0;
    longitude.value = _locationData.longitude ?? 0.0;
    _addRoutePoint(LatLng(latitude.value, longitude.value));
    _updateMarker();
    // Firestore update for parent tracking
    if (Get.isRegistered<DriverController>()) {
      Get.find<DriverController>().updateDriverLocation(latitude.value, longitude.value);
    }
    isLoading.value = false;
  }

  void _updateMarker() {
    marker.value = Marker(
      markerId: MarkerId('driver_location'),
      position: LatLng(latitude.value, longitude.value),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: driverName.value.isNotEmpty ? driverName.value : 'Driver',
        snippet: bus.value.isNotEmpty ? 'Bus: ${bus.value}' : '',
      ),
      onTap: () {},
    );
  }

  void _addRoutePoint(LatLng point) {
    routePoints.add(point);
    polylines.value = {
      Polyline(
        polylineId: PolylineId('driver_route'),
        color: const Color(0xFF1976D2), // blue
        width: 5,
        points: List<LatLng>.from(routePoints),
      ),
    };
    // Firestore mein routePoints bhi update karo agar DriverController registered hai
    if (Get.isRegistered<DriverController>()) {
      final userId = Get.find<DriverController>().userIdController.userId.value;
      FirebaseFirestore.instance.collection('userData').doc(userId).update({
        'routePoints': routePoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      });
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController.value = controller;
  }

  // Optionally, add a method to update location in real-time
  void startLocationUpdates() {
    Location location = Location();
    location.onLocationChanged.listen((LocationData currentLocation) {
      latitude.value = currentLocation.latitude ?? 0.0;
      longitude.value = currentLocation.longitude ?? 0.0;
      _addRoutePoint(LatLng(latitude.value, longitude.value));
      _updateMarker();
      // Firestore update for parent tracking
      if (Get.isRegistered<DriverController>()) {
        Get.find<DriverController>().updateDriverLocation(latitude.value, longitude.value);
      }
    });
  }

  // Add a yellow drop marker for a dropped student
  void addDropMarker({
    required double lat,
    required double lng,
    required String childName,
  }) {
    final markerId = MarkerId('drop_${DateTime.now().millisecondsSinceEpoch}');
    final dropMarker = Marker(
      markerId: markerId,
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow: InfoWindow(
        title: 'Child Dropped',
        snippet: childName,
      ),
    );
    dropMarkers.add(dropMarker);
    _startCleanupTimer();
  }

  // Start or reset the cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer(const Duration(seconds: 60), () {
      clearAllOverlays();
    });
  }

  // Remove all markers and polylines
  void clearAllOverlays() {
    marker.value = null;
    dropMarkers.clear();
    routePoints.clear();
    polylines.value = {};
  }

  // Get all markers for the map
  Set<Marker> get allMarkers {
    final set = <Marker>{};
    if (marker.value != null) set.add(marker.value!);
    set.addAll(dropMarkers);
    return set;
  }

  // Fetch drop markers for all assigned children from Firestore
  Future<void> fetchDropMarkersFromFirestore() async {
    try {
      // Get driver userId and assigned bus
      final driverController = Get.isRegistered<DriverController>() ? Get.find<DriverController>() : null;
      if (driverController == null) return;
      await driverController.userIdController.getUserIdAndRole();
      String userId = driverController.userIdController.userId.value;
      var driverDoc = await FirebaseFirestore.instance.collection('userData').doc(userId).get();
      String assignedBus = driverDoc.data()?['busses'] ?? '';
      if (assignedBus.isEmpty) return;
      // Get all children for this bus
      var childDocs = await FirebaseFirestore.instance.collection('addChild').where('bus', isEqualTo: assignedBus).get();
      List<Marker> drops = [];
      for (var doc in childDocs.docs) {
        var data = doc.data();
        if (data.containsKey('dropMarker') && data['dropMarker'] != null) {
          var dropMarkerData = data['dropMarker'];
          DateTime droppedAt = DateTime.tryParse(dropMarkerData['droppedAt'] ?? '') ?? DateTime.now().subtract(Duration(minutes: 2));
          if (DateTime.now().difference(droppedAt).inSeconds < 60) {
            // Format time for info window
            String formattedTime = DateFormat('hh:mm a').format(droppedAt);
            drops.add(Marker(
              markerId: MarkerId('drop_marker_${doc.id}'),
              position: LatLng((dropMarkerData['lat'] as num).toDouble(), (dropMarkerData['lng'] as num).toDouble()),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
              infoWindow: InfoWindow(
                title: 'Child Dropped',
                snippet: '${dropMarkerData['childName'] ?? ''} - $formattedTime',
              ),
            ));
          }
        }
      }
      dropMarkers.value = drops;
    } catch (e) {
      print('[DEBUG] Error fetching drop markers: $e');
    }
  }
}