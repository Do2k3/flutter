import 'package:app1/ui/discovery/discovery.dart';
import 'package:app1/ui/home/viewmodel.dart';
import 'package:app1/ui/settings/settings.dart';
import 'package:app1/ui/user/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/model/song.dart';
import '../now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,

      ),
      home: MusicHomePage(),
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final List<Widget> _tabs =[
    const HomeTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingsTab(),
  ];
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Music App'),
      ),
      child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Discovery'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
            ],
          ),
          tabBuilder: (BuildContext context, int index){
            return _tabs[index];
          },
      ),
    );
  }
}


class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _ViewModel;

  @override
  void initState() {
    _ViewModel = MusicAppViewModel();
    _ViewModel.loadSongs();
    observerData();
    super.initState();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  @override
  void dispose() {
    _ViewModel.songStream.close();
    super.dispose();
  }

  void observerData() {
    _ViewModel.songStream.stream.listen((songList){
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  Widget getBody() {
    bool showLoading = songs.isEmpty;
    if(showLoading){
      return getProgressBar();
    }else{
      return getListView();
    }
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  ListView getListView() {
    return ListView.separated(
        itemBuilder: (context, position){
          return getRow(position);
        },
        separatorBuilder: (context, index){
          return const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 24,
            endIndent: 24,
          );
        },
        itemCount: songs.length,
        shrinkWrap: true,
    );
  }

  Widget getRow(int index) {
    return _songItemSection(
        paremt: this,
        song: songs[index]);

  }

  void showBottomSheet()
  {

  }
  void navigate(Song song){
    Navigator.push(context,
      CupertinoPageRoute(builder: (context){
        return NowPlaying(
          songs: songs,
          playingSong: song,
        );
      })
    );
  }
}

class _songItemSection extends StatelessWidget{
  _songItemSection({
    required this.paremt,
    required this.song,
  });
  final _HomeTabPageState paremt;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/ve_i_tune_1.jpg',
          image: song.image,
          imageErrorBuilder:(context, error, strackTrace){
            return Image.asset('assets/ve_i_tune_1.jpg' , width: 48, height: 48,);
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: (){
          paremt.showBottomSheet();
        },
      ),
      onTap: (){
        paremt.navigate(song);
      }
      ,
    );
  }
}