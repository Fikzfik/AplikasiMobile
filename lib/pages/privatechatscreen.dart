import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:intl/intl.dart';

class PrivateChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;

  const PrivateChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _token;
  int? _currentUserId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAuthData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    print('Auth: token=$token, userId=$userId');

    if (token != null && userId != null) {
      setState(() {
        _token = token;
        _currentUserId = userId;
      });
      await _fetchMessages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not logged in')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _fetchMessages() async {
    if (_token == null || _currentUserId == null) {
      print('Cannot fetch: token or userId is null');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final url = 'http://10.0.2.2:8000/api/messages?other_user_id=${widget.otherUserId}';
      print('GET $url, Headers: {Authorization: Bearer $_token}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Fetch Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _messages = data.cast<Map<String, dynamic>>();
        });
        print('Messages: $_messages');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        String errorMessage = response.statusCode.toString();
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ??
              errorData['errors']?.toString() ??
              response.body;
        } catch (e) {
          print('JSON Parse Error: $e, Raw Body: ${response.body}');
          errorMessage = response.body.isNotEmpty ? response.body : 'Unknown error';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: $errorMessage'),
          ),
        );
      }
    } catch (e) {
      print('Fetch Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_token == null || _currentUserId == null) {
      print('Cannot send: token or userId is null');
      return;
    }

    final content = _messageController.text.trim();
    if (content.isEmpty) {
      print('Empty message');
      return;
    }

    try {
      final url = 'http://10.0.2.2:8000/api/messages';
      final body = jsonEncode({
        'id_receiver': widget.otherUserId,
        'message': content,
        'message_type': 'text',
      });
      print('POST $url, Body: $body, Headers: {Authorization: Bearer $_token}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: body,
      );

      print('Send Status: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 201) {
        _messageController.clear();
        await _fetchMessages();
      } else {
        String errorMessage = response.statusCode.toString();
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ??
              errorData['errors']?.toString() ??
              response.body;
        } catch (e) {
          print('JSON Parse Error: $e, Raw Body: ${response.body}');
          errorMessage = response.body.isNotEmpty ? response.body : 'Unknown error';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $errorMessage'),
          ),
        );
      }
    } catch (e) {
      print('Send Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.otherUserName,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? const Center(child: Text('No messages yet'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isSentByMe =
                                message['id_sender'] == _currentUserId;
                            return Align(
                              alignment: isSentByMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: isSentByMe
                                      ? (isDark
                                          ? Colors.blue[700]
                                          : Colors.blue[500])
                                      : (isDark
                                          ? const Color(0xFF374151)
                                          : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: isSentByMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message['message'],
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('HH:mm').format(
                                          DateTime.parse(
                                              message['created_at'])),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF374151) : Colors.grey[200],
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send,
                        color: isDark ? Colors.blueAccent : Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
