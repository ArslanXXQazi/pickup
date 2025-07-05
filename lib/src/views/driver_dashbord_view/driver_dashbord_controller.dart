import 'package:cloud_firestore/cloud_firestore.dart';

class DriverDashboardController {
  Future<void> fetchAssignedChildren() async {
    try {
      // Fetch child documents from Firestore
      QuerySnapshot childDocs = await FirebaseFirestore.instance.collection('addChild').get();

      for (var doc in childDocs.docs) {
        var data = doc.data() as Map<String, dynamic>?;
        String childName = data?['childName'] ?? "N/A";
        String status = data?['status'] ?? "Not Picked Up";

        // Check and reset driverResetAt if needed
        if (data != null && data['driverResetAt'] != null) {
          DateTime driverResetAt = DateTime.tryParse(data['driverResetAt']) ?? DateTime.now();
          if (DateTime.now().isAfter(driverResetAt)) {
            await FirebaseFirestore.instance.collection('addChild').doc(doc.id).update({
              'status': 'Not Picked Up',
              'updatedAt': Timestamp.now(),
              'dropMarker': null,
              'driverResetAt': null,
              'droppedOffAt': null,
            });
            status = 'Not Picked Up';
          }
        }

        // Process the child data as needed
        // For example, you can print the child's name and status
        print('Child Name: $childName, Status: $status');
      }
    } catch (e) {
      print('Error fetching assigned children: $e');
    }
  }

  /// Fetch driver notifications for the current user (last 1 minute)
  Future<void> fetchDriverNotifications(String driverId) async {
    try {
      final oneMinuteAgo = DateTime.now().subtract(Duration(minutes: 1));
      // Delete notifications older than 1 minute
      final oldSnapshot = await FirebaseFirestore.instance
          .collection('driverNotifications')
          .where('driverId', isEqualTo: driverId)
          .where('timestamp', isLessThan: oneMinuteAgo.toIso8601String())
          .get();
      for (var doc in oldSnapshot.docs) {
        await doc.reference.delete();
      }
      // Fetch only notifications from the last 1 minute
      final snapshot = await FirebaseFirestore.instance
          .collection('driverNotifications')
          .where('driverId', isEqualTo: driverId)
          .where('timestamp', isGreaterThan: oneMinuteAgo.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();
      // You can update your notification list here if needed
      // driverNotificationsList.value = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching driver notifications: $e');
    }
  }
} 