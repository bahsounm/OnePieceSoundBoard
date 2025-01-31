import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/favourite_sounds.dart';
import 'pages/loading.dart';
import 'pages/search_page.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  initialRoute: '/',
  routes: {
    '/' : (context) => Loading(),
    '/home' : (context) => Home(),
    '/favorite' : (context) => FavouriteSounds(),
    '/search' : (context) => SearchPage(),
  },
));

