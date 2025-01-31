import 'package:flutter/material.dart';
import '../services/sound_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'sound_detail_page.dart';

class FavouriteSounds extends StatefulWidget {
  @override
  _FavouriteSoundsState createState() => _FavouriteSoundsState();
}

class _FavouriteSoundsState extends State<FavouriteSounds> {
  List<SoundItem> _likedSounds = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadLikedSounds();
  }

  Future<void> _loadLikedSounds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedSoundsData = prefs.getStringList('likedSounds');

    if (likedSoundsData != null) {
      setState(() {
        _likedSounds = likedSoundsData.map((data) {
          try {
            return SoundItem.fromJson(data);
          } catch (e) {
            print("Error parsing liked sound data: $e");
            return null;
          }
        }).whereType<SoundItem>().toList();
      });
    }
  }

  void _playSound(String soundFile) async {
    try {
      // Stop the currently playing sound
      await _audioPlayer.stop();
      // Set the new sound source
      await _audioPlayer.setSource(AssetSource(soundFile));
      // Start playing the new sound
      await _audioPlayer.resume();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _stopSound() {
    _audioPlayer.stop();
  }

  Future<void> _navigateToSoundDetail(SoundItem soundItem) async {
    // Navigate to SoundDetailPage and wait for the result
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SoundDetailPage(
          soundItem: soundItem,
          audioPlayer: _audioPlayer,
          onLikeStatusChanged: _loadLikedSounds, // Refresh the list on like status change
        ),
      ),
    );

    // Refresh the list after returning from SoundDetailPage
    _loadLikedSounds();
  }

  @override
  void dispose() {
    _stopSound();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 10;
    final cardHeight = cardWidth / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favourite Sounds'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.blue],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.red],
          ),
        ),
        child: _likedSounds.isEmpty
            ? Center(child: Text('No favourite sounds yet.'))
            : GridView.builder(
                padding: EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: cardWidth / cardHeight,
                ),
                itemCount: _likedSounds.length,
                itemBuilder: (context, index) {
                  final soundItem = _likedSounds[index];
                  return GestureDetector(
                    onTap: () {
                      _playSound('sounds/${soundItem.soundFile}');
                    },
                    onDoubleTap: () {
                      _stopSound();
                      _navigateToSoundDetail(soundItem);
                    },
                    child: Card(
                      elevation: 15,
                      color: Colors.grey[100],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/avatars/${soundItem.avatar}'),
                            radius: 30.0,
                          ),
                          SizedBox(height: 10),
                          Text(soundItem.name, style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
