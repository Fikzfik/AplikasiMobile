import 'dart:convert';
import 'package:fikzuas/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PrivateChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String otherUserStatus;

  const PrivateChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.otherUserStatus,
  });

  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  String? _token;
  int? _currentUserId;
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _loadAuthData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not logged in')));
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _token = token;
      _currentUserId = userId;
    });
    await _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    if (_token == null || _currentUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    print('Fetching messages for otherUserId: ${widget.otherUserId}');
    try {
      final url = 'http://10.0.2.2:8000/api/messages?other_user_id=${widget.otherUserId}';
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
        _scrollToBottom();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: ${response.statusCode}')),
        );
        setState(() => _messages = []);
      }
    } catch (e) {
      print('Fetch Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
      setState(() => _messages = []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_token == null || _currentUserId == null) return;

    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    try {
      final url = 'http://10.0.2.2:8000/api/messages';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'id_receiver': widget.otherUserId,
          'message': content,
          'message_type': 'text',
        }),
      );

      if (response.statusCode == 201) {
        _messageController.clear();
        await _fetchMessages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Send Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online': return Colors.green;
      case 'away': return Colors.orange;
      case 'in-game': return Colors.blue;
      default: return Colors.grey;
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isSentByMe, int index) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final createdAt = message['created_at'] as String?;
    final status = message['status'] as String?;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSentByMe ? LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]) : null,
                color: isSentByMe ? null : (isDark ? Color(0xFF374151) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'] as String? ?? 'No message',
                    style: TextStyle(color: isSentByMe ? Colors.white : (isDark ? Colors.white : Colors.black), fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        createdAt != null ? DateFormat('HH:mm').format(DateTime.parse(createdAt)) : 'Unknown time',
                        style: TextStyle(
                          color: isSentByMe ? Colors.white.withOpacity(0.7) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          fontSize: 12,
                        ),
                      ),
                      if (isSentByMe)
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: status == 'read' ? Colors.blue : Colors.grey,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.3, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    print('Building PrivateChatScreen: isLoading=$_isLoading, messages.length=${_messages.length}, currentUserId=$_currentUserId');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? [Color(0xFF0F172A), Color(0xFF1E293B)] : [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? [Color(0xFF1F2937), Color(0xFF374151)] : [Colors.white, Color(0xFFF8FAFC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.otherUserName,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _messages.isEmpty
                              ? Center(child: Text('No messages yet', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])))
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.all(16),
                                  itemCount: _messages.length,
                                  itemBuilder: (context, index) {
                                    final message = _messages[index];
                                    final isSentByMe = _currentUserId != null && message['id_sender'] == _currentUserId;
                                    return _buildMessageBubble(message, isSentByMe, index);
                                  },
                                ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            filled: true,
                            fillColor: isDark ? Color(0xFF374151) : Colors.white,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Color(0xFF3B82F6)),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}