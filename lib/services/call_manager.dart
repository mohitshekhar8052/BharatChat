import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/video_call_screen.dart';
import '../services/webrtc_service.dart';

class CallManager {
  static final CallManager _instance = CallManager._internal();
  factory CallManager() => _instance;
  CallManager._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final WebRTCService _webrtcService = WebRTCService();

  BuildContext? _context;

  // Initialize call listening
  void initialize(BuildContext context) {
    _context = context;
    _listenForIncomingCalls();
  }

  // Listen for incoming calls
  void _listenForIncomingCalls() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    _firestore
        .collection('calls')
        .where('calleeId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'calling')
        .snapshots()
        .listen((snapshot) {
          for (var doc in snapshot.docs) {
            final callData = doc.data();
            _handleIncomingCall(doc.id, callData);
          }
        });
  }

  // Handle incoming call
  void _handleIncomingCall(String callId, Map<String, dynamic> callData) async {
    if (_context == null) return;

    try {
      // Get caller information
      final callerId = callData['callerId'];
      final callerDoc = await _firestore
          .collection('users')
          .doc(callerId)
          .get();

      if (!callerDoc.exists) {
        log('Caller document not found');
        return;
      }

      final callerData = callerDoc.data()!;
      final callerName =
          callerData['displayName'] ?? callerData['email'] ?? 'Unknown';
      final isVideo = callData['isVideo'] ?? false;

      // Show incoming call dialog or navigate to call screen
      _showIncomingCallDialog(
        callId: callId,
        callerName: callerName,
        callerId: callerId,
        isVideo: isVideo,
      );
    } catch (e) {
      log('Error handling incoming call: $e');
    }
  }

  // Show incoming call dialog
  void _showIncomingCallDialog({
    required String callId,
    required String callerName,
    required String callerId,
    required bool isVideo,
  }) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('${isVideo ? 'Video' : 'Voice'} Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                callerName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$callerName is calling...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              rejectCall(callId);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _acceptCall(
                callId: callId,
                callerId: callerId,
                callerName: callerName,
                isVideo: isVideo,
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  // Accept incoming call
  void _acceptCall({
    required String callId,
    required String callerId,
    required String callerName,
    required bool isVideo,
  }) {
    if (_context == null) return;

    Navigator.of(_context!).push(
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          callId: callId,
          calleeId: callerId,
          calleeName: callerName,
          isIncoming: true,
          isVideo: isVideo,
        ),
      ),
    );
  }

  // Make a video call
  Future<void> makeVideoCall({
    required String calleeId,
    required String calleeName,
  }) async {
    await _makeCall(calleeId: calleeId, calleeName: calleeName, isVideo: true);
  }

  // Make a voice call
  Future<void> makeVoiceCall({
    required String calleeId,
    required String calleeName,
  }) async {
    await _makeCall(calleeId: calleeId, calleeName: calleeName, isVideo: false);
  }

  // Make a call (video or voice)
  Future<void> _makeCall({
    required String calleeId,
    required String calleeName,
    required bool isVideo,
  }) async {
    if (_context == null) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showErrorDialog('You must be logged in to make a call');
      return;
    }

    try {
      // Create call using WebRTC service
      final callId = await _webrtcService.createCall(
        callerId: currentUser.uid,
        calleeId: calleeId,
        isVideo: isVideo,
      );

      if (callId != null) {
        // Navigate to call screen
        Navigator.of(_context!).push(
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(
              callId: callId,
              calleeId: calleeId,
              calleeName: calleeName,
              isIncoming: false,
              isVideo: isVideo,
            ),
          ),
        );
      } else {
        _showErrorDialog('Failed to create call');
      }
    } catch (e) {
      log('Error making call: $e');
      _showErrorDialog('Failed to make call: $e');
    }
  }

  // Reject a call
  Future<void> rejectCall(String callId) async {
    try {
      await _webrtcService.rejectCall(callId);
      log('Call rejected: $callId');
    } catch (e) {
      log('Error rejecting call: $e');
    }
  }

  // End a call
  Future<void> endCall(String callId) async {
    try {
      await _webrtcService.endCall(callId);
      log('Call ended: $callId');
    } catch (e) {
      log('Error ending call: $e');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      builder: (context) => AlertDialog(
        title: const Text('Call Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Get call history for current user
  Stream<QuerySnapshot> getCallHistory() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('calls')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Check if user is currently in a call
  Future<bool> isInCall() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final activeCalls = await _firestore
          .collection('calls')
          .where('participants', arrayContains: currentUser.uid)
          .where('status', whereIn: ['calling', 'answered'])
          .get();

      return activeCalls.docs.isNotEmpty;
    } catch (e) {
      log('Error checking call status: $e');
      return false;
    }
  }

  // Dispose resources
  void dispose() {
    _context = null;
  }
}
