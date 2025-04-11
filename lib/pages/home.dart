import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_town_hall/data/glossary_data.dart';
import 'package:the_town_hall/data/representative_data.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:the_town_hall/models/glossary.dart';
import 'package:the_town_hall/widgets/email_generator_screen.dart';
import 'package:the_town_hall/models/representative_card.dart';
import 'package:the_town_hall/widgets/gpsmap.dart';
import 'package:the_town_hall/widgets/location_notifier.dart';
import 'package:the_town_hall/widgets/locationsearch.dart';
import 'package:the_town_hall/widgets/filter_bar.dart';

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

    Map<String, bool> _repFilters = {
    'local': false,
    'city': false,
    'county': false,
    'state': true,
    'national': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          titleBar(),
          mapAndSearch(),
          representatives(),
        ],
      ),
    );
  }

  Container representatives() {
    return Container(
      width: 402,
      height: 377,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [representativeFilterBar(), representativeList()],
      ),
    );
  }

  Expanded representativeList() {
    return Expanded(
      child: Consumer<LocationNotifier>(
        builder: (context, locationNotifier, child) {
          final userState = locationNotifier.targetUSState;
          final filteredRepresentatives = representativesData.where((rep) {
            String str = ('Filter for ${rep.positionLevel.toShortString()}: ${_repFilters[rep.positionLevel.toShortString()]}');
            print(str);
            String str2 =('Representative state: ${rep.state}, User state: $userState');
            print(str2);
            return _repFilters[rep.positionLevel.toShortString()] == true &&
                 (rep.state == userState || userState == null);
            }).toList();

          locationNotifier.updateFilteredRepresentativesLocations(filteredRepresentatives);

          return ListView.builder(
            itemCount: filteredRepresentatives.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Row(
                      children: [
                        representativeDetails(filteredRepresentatives, index),
                        questionAndHistory(index),
                        Spacer(flex: 5),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Column questionAndHistory(int index) {
    final representative = representativesData[index];
    return Column(
      spacing: 16,
      children: [
        GestureDetector(
          onTap: () {
            // Handle Question Mark icon tap
            final glossaryEntry = glossaryData.entries.firstWhere(
              (entry) => entry.term == representative.position,
              orElse: () => GlossaryEntry(
                term: 'Unknown',
                definition: 'No definition available.',
                whatTheyDo: 'No information available.',
              ),
            );

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(glossaryEntry.term),
                    IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    ),
                  ],
                  ),
                  content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    'Definition:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(glossaryEntry.definition),
                    if (glossaryEntry.whatTheyDo != null) ...[
                    SizedBox(height: 16),
                    Text(
                      'What They Do:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(glossaryEntry.whatTheyDo!),
                    ],
                  ],
                  ),
                );
              },
            );
            print('Question icon tapped');
          },
          child: Icon(Icons.question_mark_rounded, color: Colors.blue),
        ),
        GestureDetector(
          onTap: () {
            // Handle History icon tap
            print('History icon tapped');
          },
          child: Icon(Icons.history_edu, color: Colors.blue),
        ),
      ],
    );
  }

  Expanded representativeDetails(List<Representative> filteredRepresentatives, int index) {
    final representative = filteredRepresentatives[index];
    return Expanded(
      flex: 75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text(representative.name),
            subtitle: Text(representative.position),
          ),
          contactRepRow(representative),
        ],
      ),
    );
  }

  Row contactRepRow(Representative representative) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        actionCallRepresentative(representative),
        actionEmailRepresentative(representative),
        actionMailRepresentative(representative),
      ],
    );
  }

  GestureDetector actionMailRepresentative(Representative representative) {
    return GestureDetector(
        onTap: () {
          // Handle mailbox icon tap
          showDialog(
            context: context,
            builder: (BuildContext context) {
            return AlertDialog(
              title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Office Address'),
                IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                ),
              ],
              ),
              content: Text(representative.contactInfo.officeAddress),
            );
            },
          );
          print('Mailbox icon tapped');
        },
        child: Icon(Icons.markunread_mailbox, color: Colors.red),
      );
  }

  GestureDetector actionCallRepresentative(Representative representative) {
    return GestureDetector(
        onTap: () async {
          // Handle phone icon tap
          final Uri phoneUri = Uri(
            scheme: 'tel',
            path: representative.contactInfo.phone,
          );
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri);
          } else {
            print('Could not launch phone app: $phoneUri');
          }
        },
        child: Icon(Icons.phone, color: Colors.red),
      );
  }

  GestureDetector actionEmailRepresentative(Representative representative) {
    return GestureDetector(
        onTap: () async {
          // Handle email icon tap
          final generatedEmail = await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => EmailGeneratorScreen(
                    representative: representative,
                    onEmailGenerated: (email) {
                      // Handle the generated email
                      print('Callback: $email');
                    },
                  ),
            ),
          );
          if (generatedEmail != null) {
            String encodedBody = Uri.encodeComponent(generatedEmail);
            encodedBody = encodedBody
                        .replaceAll("%27", "'")
                        .replaceAll("%22", '"');
            print('Encoded body: $encodedBody');
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: representative.contactInfo.email,
              query:
                  'subject=${Uri.encodeComponent('Hello ${representative.name}')}'
                  '&body=$encodedBody',
            );
            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            } else {
              print('Could not launch email app: $emailUri');
            }
          }
          print('Email icon tapped');
        },
        child: Icon(Icons.email, color: Colors.red),
      );
  }

  Container representativeFilterBar() {
    return Container(
      width: double.infinity,
      height: 35,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F5686E1),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: FilterBar(
        filters: _repFilters,
        onFiltersChanged: (updatedFilters) {
            setState(() {
              _repFilters = updatedFilters;
            });
        },
      ),
    );
  }

  Column mapAndSearch() {
    return Column(
      children: [
        Stack(
          children: [
            SizedBox(
              height: 400, // Set a fixed height for the map
              child: GpsMap(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LocationSearchScreen(),
            ),
          ],
        ),
      ],
    );
  }

  Container titleBar() {
    return Container(
      width: 402,
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
      color: Colors.blue[50],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [menuButton(), Flexible(child: townHallName()), userIcon()],
      ),
    );
  }

  ConstrainedBox gpsSearchBar() {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 360, maxWidth: 720),
      child: Container(
        width: double.infinity,
        height: 56,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFECE6F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          spacing: 8,
                          children: [gpsIcon(), gpsTextBox()],
                        ),
                      ),
                    ),
                    gpsTrailingIcon(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox gpsTrailingIcon() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [searchIcon()],
            ),
          ),
        ],
      ),
    );
  }

  Container searchIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Stack(children: [Icon(Icons.search)]),
          ),
        ],
      ),
    );
  }

  Container gpsIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/gps_arrow.png"),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  SizedBox gpsTextBox() {
    return SizedBox(
      height: double.infinity,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.50,
            child: Text(
              'La Mesa, 92125',
              style: TextStyle(
                color: const Color(0xFF938E8E),
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.50,
                letterSpacing: 0.50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container userIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/user_icon.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  SizedBox townHallName() {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'THE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFF0000),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 0.92,
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Color(0xFF000000).withOpacity(0.30),
                ),
              ],
            ),
          ),
          ShaderMask(
            shaderCallback:
                (bounds) => SweepGradient(
                  colors: [
                    Color(0xFFFF0000),
                    Color(0xFFFFFFFF),
                    Color(0xFF5686E1),
                  ],
                  stops: [0.28, 0.42, 0.96],
                  transform: GradientRotation(0.90),
                ).createShader(bounds),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOWN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 0.92,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        color: Color(0xFF000000).withOpacity(0.30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'HALL',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF5686E1),
              fontSize: 24,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 0.92,
              shadows: [
                Shadow(
                  offset: Offset(0, 4),
                  blurRadius: 4,
                  color: Color(0xFF000000).withOpacity(0.30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container menuButton() {
    return Container(
      width: 28,
      height: 28,
      decoration: ShapeDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/home_button.png"),
          fit: BoxFit.contain,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFF5686E1)),
          borderRadius: BorderRadius.circular(5),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x3F5686E1),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }
}
