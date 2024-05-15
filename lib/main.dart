import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(StoryGeneratorApp());
}

class StoryGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Write Me A Story',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StoryGeneratorScreen(),
    );
  }
}

class StoryGeneratorScreen extends StatefulWidget {
  @override
  _StoryGeneratorScreenState createState() => _StoryGeneratorScreenState();
}

class _StoryGeneratorScreenState extends State<StoryGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _endingController = TextEditingController();
  final _wordsController = TextEditingController();
  List<TextEditingController> _characterControllers = [TextEditingController()];

  String _generatedStory = '';

  void _addCharacterField() {
    setState(() {
      _characterControllers.add(TextEditingController());
    });
  }

  void _removeCharacterField() {
    if (_characterControllers.length > 1) {
      setState(() {
        _characterControllers.removeLast();
      });
    }
  }

  Future<void> _generateStory() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://127.0.0.1:5000/generate_story');
      final headers = {'Content-Type': 'application/json'};
      final characters = _characterControllers.map((controller) => controller.text).toList();

      final body = json.encode({
        'title': _titleController.text,
        'genre': _genreController.text,
        'characters': characters,
        'ending': _endingController.text,
        'words': _wordsController.text,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        setState(() {
          _generatedStory = json.decode(response.body)['story'];
        });
      } else {
        setState(() {
          _generatedStory = 'Error generating story: ${response.body}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Me A Story'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Story Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a story title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _genreController,
                decoration: InputDecoration(labelText: 'Story Genre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a story genre';
                  }
                  return null;
                },
              ),
              ..._characterControllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(labelText: 'Character'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a character';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: _removeCharacterField,
                      ),
                    ],
                  ),
                );
              }).toList(),
              TextButton(
                onPressed: _addCharacterField,
                child: Text('Add Character'),
              ),
              TextFormField(
                controller: _endingController,
                decoration: InputDecoration(labelText: 'Story Ending'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a story ending';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _wordsController,
                decoration: InputDecoration(labelText: 'Number of Words'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of words';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateStory,
                child: Text('Generate Story'),
              ),
              SizedBox(height: 20),
              Text(_generatedStory),
            ],
          ),
        ),
      ),
    );
  }
}
