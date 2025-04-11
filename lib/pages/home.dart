import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_town_hall/widgets/home/title_bar.dart';
import 'package:the_town_hall/widgets/home/map_and_search.dart';
import 'package:the_town_hall/widgets/home/representatives.dart';
import 'package:the_town_hall/widgets/location_notifier.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocationNotifier(),
      child: const HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          TitleBar(),
          MapAndSearch(),
          Representatives(),
        ],
      ),
    );
  }
}
