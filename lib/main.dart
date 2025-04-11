import 'package:flutter/material.dart';
import 'package:the_town_hall/pages/home.dart';
import 'package:the_town_hall/data/glossary_data.dart';
import 'package:the_town_hall/data/representative_data.dart';
import 'package:the_town_hall/utility/load_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AssetDataLoader.ensureAssetsInDocuments();
  await gRepresentativeDataManager.initRepresentatives();
  await gGlossaryManager.initGlossary();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomePage(),
    );
  }
}