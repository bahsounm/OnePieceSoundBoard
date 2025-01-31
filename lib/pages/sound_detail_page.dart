import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sound_item.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundDetailPage extends StatefulWidget {
  final SoundItem soundItem;
  final AudioPlayer audioPlayer;
  final VoidCallback? onLikeStatusChanged;

  SoundDetailPage({
    required this.soundItem,
    required this.audioPlayer,
    this.onLikeStatusChanged,
  });

  @override
  _SoundDetailPageState createState() => _SoundDetailPageState();
}

class _SoundDetailPageState extends State<SoundDetailPage> {
  bool isPlaying = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedSounds = prefs.getStringList('likedSounds');

    if (likedSounds != null) {
      setState(() {
        isLiked = likedSounds.contains(widget.soundItem.toJson());
      });
    }
  }

  void _togglePlayStop() async {
    if (isPlaying) {
      await widget.audioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    } else {
      await widget.audioPlayer.setSource(AssetSource('sounds/${widget.soundItem.soundFile}'));
      await widget.audioPlayer.resume();
      setState(() {
        isPlaying = true;
      });
    }
  }

  Future<void> _toggleLike() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedSounds = prefs.getStringList('likedSounds') ?? [];

    if (isLiked) {
      likedSounds.remove(widget.soundItem.toJson());
    } else {
      likedSounds.add(widget.soundItem.toJson());
    }

    await prefs.setStringList('likedSounds', likedSounds);

    setState(() {
      isLiked = !isLiked;
    });

    // Notify the parent page about the change
    if (widget.onLikeStatusChanged != null) {
      widget.onLikeStatusChanged!();
    }
  }

  @override
  void dispose() {
    widget.audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.05; // 5% of screen width

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.soundItem.name),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Image.asset(
                  'assets/avatars/${widget.soundItem.avatar}',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenWidth * 0.05), // 5% of screen width
              Text(
                widget.soundItem.name,
                style: TextStyle(fontSize: screenWidth * 0.07, fontWeight: FontWeight.bold), // 7% of screen width
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenWidth * 0.02), // 2% of screen width
              Text(
                widget.soundItem.tags.join(', '),
                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[600]), // 4% of screen width
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenWidth * 0.08), // 8% of screen width
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(isPlaying ? 'Stop' : 'Play'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: padding, vertical: screenWidth * 0.03), // Horizontal: 5% of screen width, Vertical: 3% of screen width
                      textStyle: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold), // 4.5% of screen width
                    ),
                    onPressed: _togglePlayStop,
                  ),
                  SizedBox(width: screenWidth * 0.05), // 5% of screen width
                  IconButton(
                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                    color: isLiked ? Colors.red : Colors.grey,
                    iconSize: screenWidth * 0.08, // 8% of screen width
                    onPressed: _toggleLike,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
