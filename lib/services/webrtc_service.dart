import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Callback functions
  Function(MediaStream stream)? onLocalStream;
  Function(MediaStream stream)? onRemoteStream;
  Function()? onCallEnded;
  Function(String error)? onError;

  // STUN servers for NAT traversal
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ],
      },
    ],
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
    'optional': [],
  };

  // Initialize WebRTC
  Future<void> initialize() async {
    try {
      _peerConnection = await createPeerConnection(_iceServers, _config);

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        log('ICE candidate: ${candidate.toMap()}');
      };

      _peerConnection!.onAddStream = (MediaStream stream) {
        log('Remote stream added');
        _remoteStream = stream;
        onRemoteStream?.call(stream);
      };

      _peerConnection!.onRemoveStream = (MediaStream stream) {
        log('Remote stream removed');
      };

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        log('ICE connection state: $state');
        if (state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
            state == RTCIceConnectionState.RTCIceConnectionStateClosed) {
          onCallEnded?.call();
        }
      };

      log('WebRTC initialized successfully');
    } catch (e) {
      log('Error initializing WebRTC: $e');
      onError?.call('Failed to initialize WebRTC: $e');
    }
  }

  // Get user media (camera and microphone)
  Future<MediaStream?> getUserMedia({
    bool video = true,
    bool audio = true,
  }) async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': audio,
        'video': video
            ? {
                'mandatory': {
                  'minWidth': '640',
                  'minHeight': '480',
                  'minFrameRate': '30',
                },
                'facingMode': 'user',
                'optional': [],
              }
            : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );

      if (_peerConnection != null && _localStream != null) {
        await _peerConnection!.addStream(_localStream!);
      }

      onLocalStream?.call(_localStream!);
      return _localStream;
    } catch (e) {
      log('Error getting user media: $e');
      onError?.call('Failed to access camera/microphone: $e');
      return null;
    }
  }

  // Create a new call
  Future<String?> createCall({
    required String callerId,
    required String calleeId,
    required bool isVideo,
  }) async {
    try {
      await initialize();
      await getUserMedia(video: isVideo, audio: true);

      // Create offer
      RTCSessionDescription offer = await _peerConnection!.createOffer(
        _dcConstraints,
      );
      await _peerConnection!.setLocalDescription(offer);

      // Generate unique call ID
      final callDoc = _firestore.collection('calls').doc();
      final callId = callDoc.id;

      // Store call data in Firestore
      await callDoc.set({
        'callerId': callerId,
        'calleeId': calleeId,
        'isVideo': isVideo,
        'status': 'calling',
        'offer': {'sdp': offer.sdp, 'type': offer.type},
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Listen for answer
      callDoc.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          if (data['answer'] != null && data['status'] == 'answered') {
            _handleAnswer(data['answer']);
          } else if (data['status'] == 'rejected' ||
              data['status'] == 'ended') {
            endCall(callId);
          }
        }
      });

      // Listen for ICE candidates
      _listenForIceCandidates(callId, 'callerCandidates');

      log('Call created with ID: $callId');
      return callId;
    } catch (e) {
      log('Error creating call: $e');
      onError?.call('Failed to create call: $e');
      return null;
    }
  }

  // Answer an incoming call
  Future<void> answerCall(String callId) async {
    try {
      await initialize();
      await getUserMedia(video: true, audio: true);

      final callDoc = await _firestore.collection('calls').doc(callId).get();
      if (!callDoc.exists) {
        throw Exception('Call not found');
      }

      final callData = callDoc.data()!;
      final offer = callData['offer'];

      // Set remote description
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      // Create answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer(
        _dcConstraints,
      );
      await _peerConnection!.setLocalDescription(answer);

      // Update call with answer
      await _firestore.collection('calls').doc(callId).update({
        'answer': {'sdp': answer.sdp, 'type': answer.type},
        'status': 'answered',
      });

      // Listen for ICE candidates
      _listenForIceCandidates(callId, 'calleeCandidates');

      log('Call answered: $callId');
    } catch (e) {
      log('Error answering call: $e');
      onError?.call('Failed to answer call: $e');
    }
  }

  // Reject a call
  Future<void> rejectCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'status': 'rejected',
      });
      log('Call rejected: $callId');
    } catch (e) {
      log('Error rejecting call: $e');
    }
  }

  // End a call
  Future<void> endCall(String callId) async {
    try {
      // Update call status in Firestore
      await _firestore.collection('calls').doc(callId).update({
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });

      // Close peer connection and streams
      await _cleanup();

      onCallEnded?.call();
      log('Call ended: $callId');
    } catch (e) {
      log('Error ending call: $e');
    }
  }

  // Handle incoming answer
  Future<void> _handleAnswer(Map<String, dynamic> answer) async {
    try {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(answer['sdp'], answer['type']),
      );
      log('Answer handled successfully');
    } catch (e) {
      log('Error handling answer: $e');
      onError?.call('Failed to handle answer: $e');
    }
  }

  // Listen for ICE candidates
  void _listenForIceCandidates(String callId, String collection) {
    _firestore
        .collection('calls')
        .doc(callId)
        .collection(collection)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data()!;
              _peerConnection!.addCandidate(
                RTCIceCandidate(
                  data['candidate'],
                  data['sdpMid'],
                  data['sdpMLineIndex'],
                ),
              );
            }
          }
        });

    // Add local ICE candidates to Firestore
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _firestore
          .collection('calls')
          .doc(callId)
          .collection(
            collection == 'callerCandidates'
                ? 'calleeCandidates'
                : 'callerCandidates',
          )
          .add({
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          });
    };
  }

  // Toggle mute/unmute audio
  Future<void> toggleMute() async {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      for (var track in audioTracks) {
        track.enabled = !track.enabled;
      }
    }
  }

  // Toggle video on/off
  Future<void> toggleVideo() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      for (var track in videoTracks) {
        track.enabled = !track.enabled;
      }
    }
  }

  // Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        await Helper.switchCamera(videoTracks.first);
      }
    }
  }

  // Clean up resources
  Future<void> _cleanup() async {
    try {
      await _localStream?.dispose();
      await _remoteStream?.dispose();
      await _peerConnection?.dispose();

      _localStream = null;
      _remoteStream = null;
      _peerConnection = null;

      log('WebRTC cleanup completed');
    } catch (e) {
      log('Error during cleanup: $e');
    }
  }

  // Get local stream
  MediaStream? get localStream => _localStream;

  // Get remote stream
  MediaStream? get remoteStream => _remoteStream;

  // Check if audio is muted
  bool get isMuted {
    if (_localStream != null) {
      final audioTracks = _localStream!.getAudioTracks();
      return audioTracks.isEmpty || !audioTracks.first.enabled;
    }
    return true;
  }

  // Check if video is enabled
  bool get isVideoEnabled {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      return videoTracks.isNotEmpty && videoTracks.first.enabled;
    }
    return false;
  }
}
