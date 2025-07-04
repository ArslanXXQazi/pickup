import 'package:cloud_firestore/cloud_firestore.dart';

class DriverDashboardController {
  Future<void> fetchAssignedChildren() async {
    try {
      // Fetch child documents from Firestore
      QuerySnapshot childDocs = await FirebaseFirestore.instance.collection('addChild').get();

      for (var doc in childDocs.docs) {
        var data = doc.data();
        String childName = data['childName'] ?? "N/A";
        String status = data['status'] ?? "Not Picked Up";

        // Check and reset driverResetAt if needed
        if (data['driverResetAt'] != null) {
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
} 