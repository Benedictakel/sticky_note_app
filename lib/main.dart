import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

void main() => runApp(StickyNotesApp());

class StickyNotesApp extends StatelessWidget {
  const StickyNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Notes',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: StickyNotesScreen(),
    );
  }
}

class StickyNotesScreen extends StatefulWidget {
  const StickyNotesScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StickyNotesScreenState createState() => _StickyNotesScreenState();
}

class _StickyNotesScreenState extends State<StickyNotesScreen> {
  List<Map<String, String>> notes = [];

  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final List<Color> noteColors = [
    Colors.yellow[200]!,
    Colors.pink[100]!,
    Colors.lightGreen[200]!,
    Colors.cyan[100]!,
    Colors.orange[100]!,
    Colors.purple[100]!,
  ];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  void loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? notesData = prefs.getString('notes');
    if (notesData != null) {
      List decoded = jsonDecode(notesData);
      setState(() {
        notes = List<Map<String, String>>.from(decoded);
      });
    }
  }

  void saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(notes));
  }

  void addNote(String title, String content) {
    setState(() {
      notes.add({'title': title, 'content': content});
    });
    saveNotes();
    titleController.clear();
    contentController.clear();
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
    });
    saveNotes();
  }

  void showAddNoteDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('New Note'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  titleController.clear();
                  contentController.clear();
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: Text('Add'),
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      contentController.text.isNotEmpty) {
                    addNote(titleController.text, contentController.text);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final random = Random();

    return Scaffold(
      appBar: AppBar(title: Text('Sticky Notes')),
      body:
          notes.isEmpty
              ? Center(child: Text('No notes yet. Tap + to add one!'))
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: notes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final color = noteColors[index % noteColors.length];

                    return GestureDetector(
                      onLongPress: () => deleteNote(index),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  note['content']!,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddNoteDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
