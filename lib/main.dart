import 'package:flutter/material.dart';
import 'package:yt_dl/ytDl.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  final TextEditingController _controller = TextEditingController();

  Future<void> _download() async {
    final ytdl = YtDownloader();

    final isSucceed = await ytdl.downloadMp3FromYt(_controller.text);
    debugPrint(isSucceed.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(128),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
              ),
              const SizedBox(
                height: 32,
              ),
              TextButton(
                onPressed: _download, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download),
                    const SizedBox(
                      width: 8,
                    ),
                    Text("Download")
                  ],
                )
              )
            ],
          ),
        )
      ),
    );
  }
}
