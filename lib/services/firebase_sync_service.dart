import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/scan_history.dart';
import '../services/database_service.dart';
import 'auth_service.dart';

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  /// Upload scan to Firebase
  Future<Map<String, dynamic>> uploadScan(ScanHistory scan) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      // Upload image to Firebase Storage
      String? imageUrl;
      if (File(scan.imagePath).existsSync()) {
        imageUrl = await _uploadImage(scan.imagePath, userId, scan.id.toString());
      }

      // Prepare scan data
      final scanData = {
        'userId': userId,
        'diseaseName': scan.diseaseName,
        'confidence': scan.confidence,
        'severity': scan.severity,
        'isHealthy': scan.isHealthy,
        'imagePath': imageUrl ?? '',
        'detectedAt': Timestamp.fromDate(scan.detectedAt),
        'additionalInfo': scan.additionalInfo,
        'syncedAt': FieldValue.serverTimestamp(),
      };

      // Upload to Firestore
      if (scan.id != null) {
        // Update existing scan
        await _firestore
            .collection('scans')
            .doc('${userId}_${scan.id}')
            .set(scanData, SetOptions(merge: true));
      } else {
        // Create new scan
        await _firestore.collection('scans').add(scanData);
      }

      // Update user stats
      await _authService.updateUserStats(
        totalScans: 1,
        diseasesDetected: scan.isHealthy ? 0 : 1,
      );

      return {'success': true, 'message': 'Scan uploaded successfully'};
    } catch (e) {
      print('Error uploading scan: $e');
      return {'success': false, 'message': 'Failed to upload scan: $e'};
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> _uploadImage(String localPath, String userId, String scanId) async {
    try {
      final file = File(localPath);
      if (!file.existsSync()) return null;

      final fileName = 'scan_${scanId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('scans/$userId/$fileName');

      // Upload file
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Download all scans from Firebase
  Future<Map<String, dynamic>> downloadScans() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      // Query scans from Firestore
      final querySnapshot = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: userId)
          .orderBy('detectedAt', descending: true)
          .get();

      final scans = <ScanHistory>[];
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();

          // Download image if needed
          String localPath = '';
          if (data['imagePath'] != null && data['imagePath'].isNotEmpty) {
            localPath = await _downloadImage(data['imagePath']) ?? data['imagePath'];
          }

          final scan = ScanHistory(
            id: int.tryParse(doc.id.split('_').last),
            diseaseName: data['diseaseName'] ?? 'Unknown',
            confidence: (data['confidence'] ?? 0.0).toDouble(),
            severity: data['severity'] ?? 'Unknown',
            isHealthy: data['isHealthy'] ?? false,
            imagePath: localPath,
            detectedAt: (data['detectedAt'] as Timestamp).toDate(),
            additionalInfo: data['additionalInfo'],
          );

          scans.add(scan);

          // Save to local database
          await _dbService.insertScan(scan);
        } catch (e) {
          print('Error processing scan ${doc.id}: $e');
        }
      }

      return {
        'success': true,
        'message': '${scans.length} scans downloaded',
        'count': scans.length,
      };
    } catch (e) {
      print('Error downloading scans: $e');
      return {'success': false, 'message': 'Failed to download scans: $e'};
    }
  }

  /// Download image from Firebase Storage
  Future<String?> _downloadImage(String imageUrl) async {
    try {
      // For now, just return the URL
      // In a real app, you might want to download and cache the image locally
      return imageUrl;
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  /// Sync all local scans to cloud
  Future<Map<String, dynamic>> syncLocalScansToCloud() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      // Get all local scans
      final localScans = await _dbService.getAllScans();

      int successCount = 0;
      int failCount = 0;

      for (var scan in localScans) {
        final result = await uploadScan(scan);
        if (result['success']) {
          successCount++;
        } else {
          failCount++;
        }
      }

      return {
        'success': true,
        'message': 'Sync complete',
        'uploaded': successCount,
        'failed': failCount,
      };
    } catch (e) {
      print('Error syncing scans: $e');
      return {'success': false, 'message': 'Failed to sync scans: $e'};
    }
  }

  /// Sync cloud scans to local
  Future<Map<String, dynamic>> syncCloudScansToLocal() async {
    try {
      final result = await downloadScans();
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Failed to sync: $e'};
    }
  }

  /// Full two-way sync
  Future<Map<String, dynamic>> performFullSync() async {
    try {
      // First, upload local scans that aren't in cloud
      final uploadResult = await syncLocalScansToCloud();

      // Then, download any cloud scans not in local
      final downloadResult = await syncCloudScansToLocal();

      return {
        'success': true,
        'message': 'Full sync complete',
        'uploaded': uploadResult['uploaded'] ?? 0,
        'downloaded': downloadResult['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to perform full sync: $e'};
    }
  }

  /// Delete scan from Firebase
  Future<Map<String, dynamic>> deleteScan(String scanId) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      // Get scan data to find image
      final doc = await _firestore
          .collection('scans')
          .doc('${userId}_$scanId')
          .get();

      if (doc.exists) {
        final data = doc.data();

        // Delete image from storage if exists
        if (data != null && data['imagePath'] != null) {
          try {
            final imageRef = _storage.refFromURL(data['imagePath']);
            await imageRef.delete();
          } catch (e) {
            print('Error deleting image: $e');
          }
        }

        // Delete document
        await doc.reference.delete();
      }

      return {'success': true, 'message': 'Scan deleted from cloud'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete scan: $e'};
    }
  }

  /// Delete all user scans from Firebase
  Future<Map<String, dynamic>> deleteAllScans() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      // Get all scans
      final querySnapshot = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete each scan
      for (var doc in querySnapshot.docs) {
        await deleteScan(doc.id.split('_').last);
      }

      return {
        'success': true,
        'message': '${querySnapshot.docs.length} scans deleted',
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete scans: $e'};
    }
  }

  /// Get cloud storage usage
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      final querySnapshot = await _firestore
          .collection('scans')
          .where('userId', isEqualTo: userId)
          .get();

      int totalScans = querySnapshot.docs.length;
      int totalSize = 0; // Would need to calculate actual size

      return {
        'success': true,
        'totalScans': totalScans,
        'totalSize': totalSize,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to get storage info: $e'};
    }
  }

  /// Listen to real-time scan updates
  Stream<List<ScanHistory>> streamScans() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('scans')
        .where('userId', isEqualTo: userId)
        .orderBy('detectedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ScanHistory(
          id: int.tryParse(doc.id.split('_').last),
          diseaseName: data['diseaseName'] ?? 'Unknown',
          confidence: (data['confidence'] ?? 0.0).toDouble(),
          severity: data['severity'] ?? 'Unknown',
          isHealthy: data['isHealthy'] ?? false,
          imagePath: data['imagePath'] ?? '',
          detectedAt: (data['detectedAt'] as Timestamp).toDate(),
          additionalInfo: data['additionalInfo'],
        );
      }).toList();
    });
  }

  /// Check if sync is enabled for user
  Future<bool> isSyncEnabled() async {
    try {
      final userData = await _authService.getUserData();
      return userData?['syncEnabled'] ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Enable/disable sync
  Future<void> setSyncEnabled(bool enabled) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return;

      await _firestore.collection('users').doc(userId).update({
        'syncEnabled': enabled,
      });

      if (enabled) {
        // Perform initial sync
        await performFullSync();
      }
    } catch (e) {
      print('Error setting sync enabled: $e');
    }
  }
}