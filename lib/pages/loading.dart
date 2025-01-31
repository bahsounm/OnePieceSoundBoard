import 'package:flutter/material.dart';
import '../services/sound_item.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  late List<SoundItem> soundInfo = [];
  double _opacity = 1.0;

  void loadSoundInfo() async {
    try {
      // Load the file
      final fileContent = await rootBundle.loadString('assets/sounds.txt');
      // Read the file and split it
      final lines = fileContent.split('\n');

      // Iterate through each line
      for (final line in lines) {
        // Line is a list string, turn into list
        final temp = line.replaceAll("'", '"');
        final lineList = jsonDecode(temp);

        // Assign each piece of info
        final name = lineList[0] as String;
        final avatar = lineList[1] as String;
        final tags = (lineList[2] as List).cast<String>();
        final soundFile = lineList[3] as String;
        
        // Create a sound item using that line's information
        SoundItem soundItem = SoundItem(name: name, avatar: avatar, tags: tags, soundFile: soundFile);
        soundInfo.add(soundItem);
      }

      // Add a delay before starting the fade-out animation
      await Future.delayed(const Duration(seconds: 2));

      // Start the fade-out animation
      setState(() {
        _opacity = 0.0;
      });

      // Wait for the animation to complete
      await Future.delayed(const Duration(seconds: 1));

      // Pass soundInfo to the home page
      Navigator.pushReplacementNamed(context, '/home', arguments: {'soundInfo': soundInfo});

    } catch (e) {
      print("Caught this Error in 'loading.dart' - $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadSoundInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(seconds: 3),
        child: Center(
          child: Transform.scale(
            scale: 0.9, // Zoom out by scaling
            child: Image.asset(
              'assets/appIcon/One_Piece_Loading.jpeg', // Replace with your image path
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
