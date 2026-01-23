import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/note_model.dart';

class NotePage extends StatefulWidget {
  NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<Note> _notes = [];
  String? _editingNoteId;
  final String _storageKey = 'saved_notes';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_storageKey);
      if (notesJson != null && notesJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(notesJson) as List<dynamic>;
        if (mounted) {
          setState(() {
            _notes = decoded
                .map((item) => Note.fromJson(item as Map<String, dynamic>))
                .toList();
            // Sort by created date, newest first
            _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading notes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notes: $e')),
        );
      }
    }
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = json.encode(
        _notes.map((note) => note.toJson()).toList(),
      );
      await prefs.setString(_storageKey, notesJson);
    } catch (e) {
      debugPrint('Error saving notes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving notes: $e')),
        );
      }
    }
  }

  void _addOrUpdateNote() {
    if (_titleController.text.trim().isEmpty ||
        _noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Title and note cannot be empty')));
      return;
    }

    setState(() {
      if (_editingNoteId != null) {
        // Update existing note
        final index = _notes.indexWhere((note) => note.id == _editingNoteId);
        if (index != -1) {
          _notes[index] = _notes[index].copyWith(
            title: _titleController.text.trim(),
            content: _noteController.text.trim(),
            updatedAt: DateTime.now(),
          );
        }
        _editingNoteId = null;
      } else {
        // Add new note
        final newNote = Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          content: _noteController.text.trim(),
          createdAt: DateTime.now(),
        );
        _notes.insert(0, newNote);
      }
      _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });

    _titleController.clear();
    _noteController.clear();
    _saveNotes();
  }

  void _deleteNote(String noteId) {
    setState(() {
      _notes.removeWhere((note) => note.id == noteId);
    });
    _saveNotes();
  }

  void _editNote(Note note) {
    setState(() {
      _editingNoteId = note.id;
      _titleController.text = note.title;
      _noteController.text = note.content;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingNoteId = null;
      _titleController.clear();
      _noteController.clear();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      }
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header like about_us page
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(30, 60, 30, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0),
              ),
              color: Color(0xFF71A33F),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/images/back_button.svg',
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                      Color(0xFFFFFFFF),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(child: Container()),
                Image.asset(
                  'assets/images/willow_logo_white.png',
                  height: 30,
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: 0.35,
                    child: SvgPicture.asset(
                      'assets/images/willow_splashscreen.svg',
                      width: MediaQuery.of(context).size.width * 2,
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      // Title "Important Note"
                      Center(
                        
                        child: Text(
                          'Important Note',
                          style: TextStyle(color: Color (0xFF497844), fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 30),
                      // Input fields
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color(0xFFffffff),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title field
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                floatingLabelAlignment: FloatingLabelAlignment.start,
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                prefixIcon: Icon(
                                  Icons.title,
                                  color: Color(0xFF497844),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 15),
                            // Note field
                            TextField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                labelText: 'Note',
                                hintText: 'Write your notes here ...',
                                floatingLabelAlignment: FloatingLabelAlignment.start,
                                floatingLabelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  height: 2,
                                ),
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                                prefixIcon: Icon(
                                  Icons.note,
                                  color: Color(0xFF497844),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Color(0xffe0e0e0), width: 1),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      // Save/Update button
                      Row(
                        children: [
                          if (_editingNoteId != null)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _cancelEdit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ),
                          if (_editingNoteId != null) SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _addOrUpdateNote,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF71A33F),
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                _editingNoteId != null
                                    ? 'Update Note'
                                    : 'Save Note',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      // Notes list
                      if (_notes.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: Text(
                              'No notes yet. Create your first note above!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._notes.map(
                          (note) => _NoteItem(
                            note: note,
                            onTap: () {
                              setState(() {
                                // Toggle expansion handled in _NoteItem
                              });
                            },
                            onDelete: () => _deleteNote(note.id),
                            onEdit: () => _editNote(note),
                            formatDate: _formatDate,
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteItem extends StatefulWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final String Function(DateTime) formatDate;

  const _NoteItem({
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.formatDate,
  });

  @override
  State<_NoteItem> createState() => _NoteItemState();
}

class _NoteItemState extends State<_NoteItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E3E3E),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.formatDate(widget.note.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFFDFFEB9),
                      // hijau lebih gelap
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        _isExpanded ? Icons.south_west : Icons.north_east,
                        color: Color(0xFF497844),
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.note.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3E3E3E),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: widget.onEdit,
                        icon: Icon(
                          Icons.edit,
                          size: 18,
                          color: Color(0xFF497844),
                        ),
                        label: Text(
                          'Edit',
                          style: TextStyle(color: Color(0xFF497844)),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Note'),
                              content: Text(
                                'Are you sure you want to delete this note?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onDelete();
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: Icon(Icons.delete, size: 18, color: Colors.red),
                        label: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
