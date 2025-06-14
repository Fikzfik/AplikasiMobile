import 'package:fikzuas/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For token storage

class ChatGroupScreen extends StatefulWidget {
  final String game;
  final int idGame;

  const ChatGroupScreen({required this.game, required this.idGame});

  @override
  _ChatGroupScreenState createState() => _ChatGroupScreenState();
}

class _ChatGroupScreenState extends State<ChatGroupScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _token; // Store Sanctum token
  int? _currentUserId; // Store current user ID
  String? _currentUserName; // Store current username

  @override
  void initState() {
    super.initState();
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('auth_token');
      _currentUserId = prefs.getInt('user_id') ?? 1; // Fallback to 1 if not set
      _currentUserName = prefs.getString('user_name') ?? 'User1'; // Fallback
    });
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/community_chats?game_id=${widget.idGame}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _messages = data.map((msg) => {
            'id_user': msg['id_user'],
            'username': msg['username'] ?? 'User${msg['id_user']}',
            'message': msg['message'],
            'created_at': msg['created_at'],
          }).toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages')),
        );
        // Fallback data
        setState(() {
          _messages = [
            {
              'id_user': 1,
              'username': 'User1',
              'message': 'Hey, anyone up for a ${widget.game} match?',
              'created_at': '2025-06-14 10:30:00',
            },
            {
              'id_user': 2,
              'username': 'User2',
              'message': 'Count me in! What rank are you?',
              'created_at': '2025-06-14 10:32:00',
            },
          ];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages')),
      );
      setState(() {
        _messages = [
          {
            'id_user': 1,
            'username': 'User1',
            'message': 'Hey, anyone up for a ${widget.game} match?',
            'created_at': '2025-06-14 10:30:00',
          },
          {
            'id_user': 2,
            'username': 'User2',
            'message': 'Count me in! What rank are you?',
            'created_at': '2025-06-14 10:32:00',
          },
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/community_chats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'id_user': _currentUserId,
          'id_game': widget.idGame,
          'message': message,
          'message_type': 'text',
          'status': 'sent',
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _messages.add({
            'id_user': _currentUserId,
            'username': _currentUserName,
            'message': message,
            'created_at': DateTime.now().toString(),
          });
          _messageController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.game} Chat Group",
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                        ? Center(child: Text('No messages yet'))
                        : ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  child: Text(
                                    message['username'][0],
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  message['username'],
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(message['message']),
                                trailing: Text(
                                  _formatTimestamp(message['created_at']),
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
                            },
                          ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF374151) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => _sendMessage(_messageController.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}