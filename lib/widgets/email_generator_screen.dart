import 'package:flutter/material.dart';
import 'package:the_town_hall/classes/ai_service.dart';
import 'package:the_town_hall/models/representative_card.dart';

class EmailGeneratorScreen extends StatefulWidget {
  final Representative representative;
  final ValueChanged<String> onEmailGenerated;

  const EmailGeneratorScreen({
    super.key,
    required this.representative,
    required this.onEmailGenerated,});
  
  @override
  // ignore: library_private_types_in_public_api
  _EmailGeneratorScreenState createState() => _EmailGeneratorScreenState();
}

class _EmailGeneratorScreenState extends State<EmailGeneratorScreen> {
  final AiService _deepAiService = AiService();
  String _generatedEmail = '';
  String _topic = ''; // Replace with actual topic
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _deepAiService.init();
  }
  Future<void> _generateEmail(String topic) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = await _deepAiService.generateEmail(
        'Write the body of a professional email to a ${widget.representative.position}'
        '${widget.representative.name} about $topic.'
        'Make it short and to the point.',
      );

      widget.onEmailGenerated(email);

      // Close the screen and return the generated email
      if (mounted) {
        Navigator.pop(context, email);
      }
    } catch (e) {
      setState(() {
        _generatedEmail = 'Error generating email: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: const Text('Email Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
          decoration: InputDecoration(
            labelText: 'Enter topic',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
            _topic = value;
            });
          },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
          onPressed: _isLoading || _topic.isEmpty
            ? null
            : () => _generateEmail(_topic),
          child: const Text('Generate Email'),
          ),
          const SizedBox(height: 16),
          _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Text(
              _generatedEmail,
              style: const TextStyle(fontSize: 16),
            ),
        ],
        ),
      ),
      );
    }
  }