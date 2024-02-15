import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}
class HomeScreenState extends State<HomeScreen> {
  List<String> notes = [];
  List<String> deletedNotes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNoteScreen()),
          ).then((result) {
            if (result != null && result is Map<String, String>) {
              final String title = result['title'] ?? '';
              final String content = result['content'] ?? '';
              if (title.isNotEmpty && content.isNotEmpty) {
                notes.add('$title: $content');
                setState(() {});
              }
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              itemCount: notes.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return buildNoteItem(index);
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestoreNoteScreen(
                      deletedNotes: deletedNotes,
                      onRestore: _restoreDeletedNote,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Restore Deleted Items",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNoteItem(int index) {
    final noteParts = notes[index].split(':');
    final title = noteParts[0];
    final content = noteParts[1];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24, // Larger font size for the title
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 20, // Smaller font size for the content
              ),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _deleteNoteAt(index);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.red,
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNoteScreen(
                          initialTitle: title,
                          initialContent: content,
                        ),
                      ),
                    ).then((result) {
                      if (result != null && result is Map<String, String>) {
                        final String editedTitle = result['title'] ?? '';
                        final String editedContent = result['content'] ?? '';
                        if (editedTitle.isNotEmpty && editedContent.isNotEmpty) {
                          notes[index] = '$editedTitle: $editedContent';
                          setState(() {});
                        }
                      }
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteNoteAt(int index) {
    if (index >= 0 && index < notes.length) {
      deletedNotes.add(notes[index]);
      notes.removeAt(index);
      setState(() {});
    }
  }

  void _restoreDeletedNote(String deletedNote) {
    deletedNotes.remove(deletedNote);
    notes.add(deletedNote);
    setState(() {});
  }
}
class ElevatedButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  const ElevatedButtonWidget({
    Key? key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const StadiumBorder(),
        elevation: 2,
      ),
      child: Text(label),
    );
  }
}
class AddNoteScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  AddNoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 24), // Larger font size for the title
            ),
            const SizedBox(height: 20),
            TextField(
              controller: contentController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Note Content',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String title = titleController.text;
                final String content = contentController.text;
                if (title.isNotEmpty && content.isNotEmpty) {
                  Navigator.of(context).pop({'title': title, 'content': content});
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Change the background color to match the "Restore Deleted Items" button
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 0,
                minimumSize: Size(double.infinity, 0), // Set the button width to fill the available space
              ),
              child: const Text(
                "Add",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class EditNoteScreen extends StatefulWidget {
  final String initialTitle;
  final String initialContent;

  const EditNoteScreen({
    required this.initialTitle,
    required this.initialContent,
    Key? key,
  }) : super(key: key);

  @override
  EditNoteScreenState createState() => EditNoteScreenState();
}
class EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Note"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: contentController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                labelText: 'Note Content',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String title = titleController.text;
                final String content = contentController.text;
                if (title.isNotEmpty && content.isNotEmpty) {
                  Navigator.of(context).pop({'title': title, 'content': content});
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue, // Change the background color to match the "Restore Deleted Items" button
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 0,
                minimumSize: Size(double.infinity, 0), // Set the button width to fill the available space
              ),
              child: const Text(
                "update",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
class RestoreNoteScreen extends StatelessWidget {
  final List<String> deletedNotes;
  final Function(String) onRestore;

  const RestoreNoteScreen({
    Key? key,
    required this.deletedNotes,
    required this.onRestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restore Deleted Items"),
      ),
      body: ListView.builder(
        itemCount: deletedNotes.length,
        itemBuilder: (context, index) {
          final noteParts = deletedNotes[index].split(':');
          final title = noteParts[0];
          final content = noteParts[1];

          return ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () {
                onRestore(deletedNotes[index]);
                Navigator.of(context).pop();
              },
            ),
          );
        },
      ),
    );
  }
}
