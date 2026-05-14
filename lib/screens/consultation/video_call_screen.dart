import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String token;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.token,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // In a real app using agora_uikit, you would initialize an AgoraClient here
  // e.g.,
  // late final AgoraClient client;
  // @override
  // void initState() {
  //   super.initState();
  //   initAgora();
  // }
  // void initAgora() async {
  //   client = AgoraClient(
  //     agoraConnectionData: AgoraConnectionData(
  //       appId: "your_app_id",
  //       channelName: widget.channelName,
  //       tempToken: widget.token,
  //     ),
  //   );
  //   await client.initialize();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesi Konsultasi'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mock remote video view
          Center(child: Icon(Icons.person, size: 120, color: Colors.grey[700])),
          // Mock local video view
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 100,
              height: 150,
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          // Mock controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white24,
                  child: IconButton(
                    icon: const Icon(Icons.mic, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 20),
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 20),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white24,
                  child: IconButton(
                    icon: const Icon(Icons.videocam, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
