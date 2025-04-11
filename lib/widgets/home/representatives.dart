import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:the_town_hall/data/glossary_data.dart';
import 'package:the_town_hall/data/representative_data.dart';
import 'package:the_town_hall/models/glossary.dart';
import 'package:the_town_hall/models/representative_card.dart';
import 'package:the_town_hall/widgets/email_generator_screen.dart';
import 'package:the_town_hall/widgets/filter_bar.dart';
import 'package:the_town_hall/widgets/location_notifier.dart';

class Representatives extends StatefulWidget {
  const Representatives({super.key});

  @override
  _RepresentativesState createState() => _RepresentativesState();
}

class _RepresentativesState extends State<Representatives> {
  Map<String, bool> _repFilters = {
    'local': false,
    'city': false,
    'county': false,
    'state': true,
    'national': true,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 402,
      height: 377,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildFilterBar(),
          _buildRepresentativeList(),
        ],
      ),
    );
  }

  // Filter Bar
  Widget _buildFilterBar() {
    return Container(
      width: double.infinity,
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x3F5686E1),
            blurRadius: 4,
            offset: const Offset(0, 4),
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

  // Representative List
  Widget _buildRepresentativeList() {
    return Expanded(
      child: Consumer<LocationNotifier>(
        builder: (context, locationNotifier, child) {
          final userState = locationNotifier.targetUSState;
          final filteredRepresentatives = _getFilteredRepresentatives(userState);

          locationNotifier.updateFilteredRepresentativesLocations(filteredRepresentatives);

          return ListView.builder(
            itemCount: filteredRepresentatives.length,
            itemBuilder: (context, index) {
              return _buildRepresentativeCard(filteredRepresentatives, index);
            },
          );
        },
      ),
    );
  }

  List<Representative> _getFilteredRepresentatives(String? userState) {
    return gRepresentativeDataManager.representatives.where((rep) {
      return _repFilters[rep.positionLevel.toShortString()] == true &&
          (rep.state == userState || userState == null);
    }).toList();
  }

  // Representative Card
  Widget _buildRepresentativeCard(List<Representative> representatives, int index) {
    final representative = representatives[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: Card(
          color: Colors.white,
          elevation: 2,
          child: Row(
            children: [
              _buildRepresentativeDetails(representative),
              _buildActionsColumn(representative),
              const Spacer(flex: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepresentativeDetails(Representative representative) {
    return Expanded(
      flex: 75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(representative.name),
            subtitle: Text(representative.position),
          ),
          _buildContactRow(representative),
        ],
      ),
    );
  }

  Widget _buildContactRow(Representative representative) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionIcon(
          icon: Icons.phone,
          color: Colors.red,
          onTap: () => _callRepresentative(representative),
        ),
        _buildActionIcon(
          icon: Icons.email,
          color: Colors.red,
          onTap: () => _emailRepresentative(representative),
        ),
        _buildActionIcon(
          icon: Icons.markunread_mailbox,
          color: Colors.red,
          onTap: () => _showMailAddress(representative),
        ),
      ],
    );
  }

  Widget _buildActionsColumn(Representative representative) {
    return Column(
      children: [
        _buildActionIcon(
          icon: Icons.question_mark_rounded,
          color: Colors.blue,
          onTap: () => _showGlossaryEntry(representative),
        ),
        _buildActionIcon(
          icon: Icons.history_edu,
          color: Colors.blue,
          onTap: () => _showHistory(),
        ),
      ],
    );
  }

  Widget _buildActionIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color),
    );
  }

  // Actions
  Future<void> _callRepresentative(Representative representative) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: representative.contactInfo.phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print('Could not launch phone app: $phoneUri');
    }
  }

  Future<void> _emailRepresentative(Representative representative) async {
    final generatedEmail = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailGeneratorScreen(
          representative: representative,
          onEmailGenerated: (email) {
            print('Callback: $email');
          },
        ),
      ),
    );
    if (generatedEmail != null) {
      final encodedBody = Uri.encodeComponent(generatedEmail)
          .replaceAll("%27", "'")
          .replaceAll("%22", '"');
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: representative.contactInfo.email,
        query: 'subject=${Uri.encodeComponent('Hello ${representative.name}')}&body=$encodedBody',
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        print('Could not launch email app: $emailUri');
      }
    }
  }

  void _showMailAddress(Representative representative) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Office Address'),
              IconButton(
                icon: const Icon(Icons.close),
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
  }

  void _showGlossaryEntry(Representative representative) {
    final glossaryEntry = gGlossaryManager.glossaryData.entries.firstWhere(
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
                icon: const Icon(Icons.close),
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
              const Text(
                'Definition:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(glossaryEntry.definition),
              if (glossaryEntry.whatTheyDo != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'What They Do:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(glossaryEntry.whatTheyDo!),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showHistory() {
    print('History icon tapped');
  }
}
