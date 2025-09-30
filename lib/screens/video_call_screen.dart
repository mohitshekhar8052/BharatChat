import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/webrtc_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String callId;
  final String calleeId;
  final String calleeName;
  final bool isIncoming;
  final bool isVideo;

  const VideoCallScreen({
    Key? key,
    required this.callId,
    required this.calleeId,
    required this.calleeName,
    required this.isIncoming,
    required this.isVideo,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final WebRTCService _webrtcService = WebRTCService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  bool _isCallConnected = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  bool _isCallStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    // Initialize renderers
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // Set up WebRTC callbacks
    _webrtcService.onLocalStream = (stream) {
      setState(() {
        _localRenderer.srcObject = stream;
      });
    };

    _webrtcService.onRemoteStream = (stream) {
      setState(() {
        _remoteRenderer.srcObject = stream;
        _isCallConnected = true;
      });
    };

    _webrtcService.onCallEnded = () {
      Navigator.of(context).pop();
    };

    _webrtcService.onError = (error) {
      _showErrorDialog(error);
    };

    // Start the call
    if (widget.isIncoming) {
      // For incoming calls, show answer/reject buttons first
      setState(() {
        _isCallStarted = false;
      });
    } else {
      // For outgoing calls, start immediately
      await _startCall();
    }
  }

  Future<void> _startCall() async {
    if (widget.isIncoming) {
      await _webrtcService.answerCall(widget.callId);
    } else {
      // Call was already created when navigating to this screen
      await _webrtcService.getUserMedia(video: widget.isVideo, audio: true);
    }
    setState(() {
      _isCallStarted = true;
    });
  }

  Future<void> _endCall() async {
    await _webrtcService.endCall(widget.callId);
    Navigator.of(context).pop();
  }

  Future<void> _rejectCall() async {
    await _webrtcService.rejectCall(widget.callId);
    Navigator.of(context).pop();
  }

  void _toggleMute() {
    _webrtcService.toggleMute();
    setState(() {
      _isMuted = _webrtcService.isMuted;
    });
  }

  void _toggleVideo() {
    _webrtcService.toggleVideo();
    setState(() {
      _isVideoEnabled = _webrtcService.isVideoEnabled;
    });
  }

  void _switchCamera() {
    _webrtcService.switchCamera();
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    // Implement speaker toggle logic here
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote video (full screen)
            if (_isCallConnected && widget.isVideo)
              Positioned.fill(
                child: RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),

            // Audio call interface
            if (!widget.isVideo || !_isCallConnected)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade900, Colors.purple.shade900],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Profile picture placeholder
                    CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(Icons.person, size: 80, color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    // Callee name
                    Text(
                      widget.calleeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Call status
                    Text(
                      _getCallStatusText(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

            // Local video (small overlay)
            if (_isCallConnected && widget.isVideo && _isVideoEnabled)
              Positioned(
                top: 50,
                right: 20,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: RTCVideoView(
                      _localRenderer,
                      mirror: true,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ),

            // Top app bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _endCall,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Spacer(),
                    if (widget.isVideo)
                      IconButton(
                        onPressed: _switchCamera,
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: _buildBottomControls(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    if (!_isCallStarted && widget.isIncoming) {
      // Incoming call controls
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reject call
          Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _rejectCall,
              icon: const Icon(Icons.call_end, color: Colors.white, size: 30),
              padding: const EdgeInsets.all(20),
            ),
          ),

          // Accept call
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _startCall,
              icon: Icon(
                widget.isVideo ? Icons.videocam : Icons.call,
                color: Colors.white,
                size: 30,
              ),
              padding: const EdgeInsets.all(20),
            ),
          ),
        ],
      );
    }

    // Active call controls
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute button
        Container(
          decoration: BoxDecoration(
            color: _isMuted ? Colors.red : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _toggleMute,
            icon: Icon(
              _isMuted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
            ),
          ),
        ),

        // Video toggle (if video call)
        if (widget.isVideo)
          Container(
            decoration: BoxDecoration(
              color: !_isVideoEnabled
                  ? Colors.red
                  : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _toggleVideo,
              icon: Icon(
                _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                color: Colors.white,
              ),
            ),
          ),

        // Speaker button
        Container(
          decoration: BoxDecoration(
            color: _isSpeakerOn ? Colors.blue : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _toggleSpeaker,
            icon: Icon(
              _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
              color: Colors.white,
            ),
          ),
        ),

        // End call button
        Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _endCall,
            icon: const Icon(Icons.call_end, color: Colors.white),
            padding: const EdgeInsets.all(15),
          ),
        ),
      ],
    );
  }

  String _getCallStatusText() {
    if (!_isCallStarted && widget.isIncoming) {
      return 'Incoming ${widget.isVideo ? 'video' : 'voice'} call...';
    } else if (!_isCallConnected) {
      return widget.isIncoming ? 'Connecting...' : 'Calling...';
    } else {
      return 'Connected';
    }
  }
}
