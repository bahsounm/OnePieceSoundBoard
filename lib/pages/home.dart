import 'package:flutter/material.dart';
import '../services/sound_item.dart';
import 'package:audioplayers/audioplayers.dart';
import 'sound_detail_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late List<SoundItem> _soundInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _stopSound();
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _stopSound() {
    _audioPlayer.stop();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopSound();
    } else if (state == AppLifecycleState.resumed) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _soundInfo = args['soundInfo'];
    _soundInfo.sort((a, b) => a.name.compareTo(b.name));

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 10; // Two columns with some padding
    final cardHeight = cardWidth / 2 ; // Adjust the height as needed

    return Scaffold(
      appBar: AppBar(
  title: Text("Home Page of Sounds"),
  centerTitle: true,
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {
        Navigator.pushNamed(context, '/search', arguments: {'allItems': _soundInfo});
      },
    ),
    IconButton(
      icon: Icon(Icons.favorite),
      onPressed: () {
        Navigator.pushNamed(context, '/favorite');
      },
    ),
  ],
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Colors.blue,
        ]
      )
    ),
  ),
  elevation: 0,
),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red,
              Colors.white,
            ],
          ),
        ),
        child: GridView.builder(
          padding: EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: cardWidth / cardHeight,
          ),
          itemCount: _soundInfo.length,
          itemBuilder: (context, index) {
            final soundItem = _soundInfo[index];
            return GestureDetector(
              onTap: () {
                _playSound('sounds/${soundItem.soundFile}');
              },
              onDoubleTap: () {
                _stopSound();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SoundDetailPage(soundItem: soundItem, audioPlayer: _audioPlayer),
                  ),
                );
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

