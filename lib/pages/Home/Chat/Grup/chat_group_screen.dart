import 'dart:async';
import 'dart:convert';
import 'package:fikzuas/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../main.dart';

class ChatGroupScreen extends StatefulWidget {
  final String game;
  final int idGame;
  final Map<String, dynamic> category;

  const ChatGroupScreen({
    required this.game,
    required this.idGame,
    required this.category,
  });

  @override
  _ChatGroupScreenState createState() => _ChatGroupScreenState();
}

class _ChatGroupScreenState extends State<ChatGroupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _animationController;
  late AnimationController _messageAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _onlineUsers = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _token;
  int? _currentUserId;
  String? _currentUserName;
  late Timer _pollTimer;

  // Fallback data for errors
  final List<Map<String, dynamic>> fallbackMessages = [
    {
      'id_user': 1,
      'username': 'User1',
      'avatar': 'U',
      'level': 10,
      'rank': 'Bronze',
      'message': 'Hey, anyone up for a match?',
      'created_at': '2025-06-14 20:00:00',
      'message_type': 'text',
      'reactions': {},
    },
  ];

  final List<Map<String, dynamic>> fallbackOnlineUsers = [
    {'username': 'User1', 'avatar': 'U', 'level': 10, 'status': 'online'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _messageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    _messageAnimationController.dispose();
    _pollTimer.cancel();
    super.dispose();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token') ?? 'your-token';
      _currentUserId = prefs.getInt('user_id') ?? 1;
      _currentUserName = prefs.getString('user_name') ?? 'User$_currentUserId';
    });
    if (_token != null && _currentUserId != null) {
      await _fetchMessages();
      await _fetchOnlineUsers();
      _startPolling();
    } else {
      _loadFallbackData();
    }
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_token != null) {
        _fetchMessages();
        _fetchOnlineUsers();
      }
    });
  }

  Future<void> _fetchMessages() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/community-chats?game_id=${widget.idGame}'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _messages = data.map((msg) => {
            'id_user': msg['id_user'],
            'username': msg['username'] ?? 'User${msg['id_user']}',
            'avatar': msg['username']?.substring(0, 1).toUpperCase() ?? 'U',
            'level': msg['level'] ?? 1,
            'rank': msg['rank'] ?? 'Bronze',
            'message': msg['message'],
            'created_at': msg['created_at'],
            'message_type': msg['message_type'] ?? 'text',
            'reactions': msg['reactions'] ?? {},
          }).toList();
        });
        _scrollToBottom();
      } else {
        _loadFallbackData();
      }
    } catch (e) {
      print('Fetch Messages Error: $e');
      _loadFallbackData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchOnlineUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/online-users?game_id=${widget.idGame}'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _onlineUsers = data.map((user) => {
            'username': user['username'] ?? 'User${user['id_user']}',
            'avatar': user['username']?.substring(0, 1).toUpperCase() ?? 'U',
            'level': user['level'] ?? 1,
            'status': user['status'] ?? 'online',
          }).toList();
        });
      } else {
        _onlineUsers = fallbackOnlineUsers;
      }
    } catch (e) {
      print('Fetch Online Users Error: $e');
      _onlineUsers = fallbackOnlineUsers;
    }
  }

  void _loadFallbackData() {
    setState(() {
      _messages = fallbackMessages;
      _onlineUsers = fallbackOnlineUsers;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/community-chats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'id_game': widget.idGame,
          'message': message,
          'message_type': 'text',
          'status': 'sent',
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showOnlineUsers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1F2937) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.people, color: widget.category["color"]),
                    SizedBox(width: 12),
                    Text(
                      'Online Players (${_onlineUsers.length})',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _onlineUsers.length,
                  itemBuilder: (context, index) {
                    final user = _onlineUsers[index];
                    return ListTile(
                      leading: Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.category["gradient"] ?? [Colors.blue, Colors.lightBlue],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                user['avatar'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: user['status'] == 'online' ? Colors.green : Colors.blue,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        user['username'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Level ${user['level']} • ${user['status']}',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [Color(0xFF0F172A), Color(0xFF1E293B)]
                : [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Enhanced Header
                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.category["gradient"] ?? [Colors.blue, Colors.lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.category["color"] ?? Colors.blue).withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.category["icon"] ?? Icons.chat,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${widget.game} Chat",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "${_messages.length} messages • ${_onlineUsers.length} online",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.people, color: Colors.white),
                              onPressed: _showOnlineUsers,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Messages
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF1F2937) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: _isLoading && _messages.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(widget.category["color"] ?? Colors.blue),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Loading messages...',
                                          style: TextStyle(
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _messages.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.chat_bubble_outline,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'No messages yet',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Be the first to start the conversation!',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        controller: _scrollController,
                                        padding: EdgeInsets.all(16),
                                        itemCount: _messages.length,
                                        itemBuilder: (context, index) {
                                          final message = _messages[index];
                                          final isMe = message['id_user'] == _currentUserId;
                                          final showAvatar = index == 0 || 
                                              _messages[index - 1]['id_user'] != message['id_user'];
                                          return _buildMessageBubble(message, isDark, isMe, showAvatar, index);
                                        },
                                      ),
                          ),
                          // Typing indicator
                          if (_isTyping)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? Color(0xFF374151) : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Someone is typing',
                                          style: TextStyle(
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              widget.category["color"] ?? Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Message Input
                Container(
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onSubmitted: (_) => _sendMessage(_messageController.text),
                            onChanged: (text) {
                              if (text.isNotEmpty && !_isTyping) {
                                setState(() => _isTyping = true);
                                Timer(Duration(seconds: 2), () {
                                  if (mounted) setState(() => _isTyping = false);
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.category["gradient"] ?? [Colors.blue, Colors.lightBlue],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                            onPressed: _isLoading
                                ? null
                                : () => _sendMessage(_messageController.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isDark, bool isMe, bool showAvatar, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: showAvatar ? 16 : 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe && showAvatar) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.category["gradient"] ?? [Colors.blue, Colors.lightBlue],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  message['avatar'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
          ] else if (!isMe) ...[
            SizedBox(width: 40),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (showAvatar && !isMe)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message['username'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: widget.category["color"] ?? Colors.blue,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (widget.category["color"] ?? Colors.blue).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Lv.${message['level']}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: widget.category["color"] ?? Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? LinearGradient(
                            colors: widget.category["gradient"] ?? [Colors.blue, Colors.lightBlue],
                          )
                        : null,
                    color: isMe ? null : (isDark ? Color(0xFF374151) : Colors.grey[200]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['message'],
                        style: TextStyle(
                          color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatTimestamp(message['created_at']),
                        style: TextStyle(
                          color: isMe 
                              ? Colors.white.withOpacity(0.7)
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Reactions
                if (message['reactions'].isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 4,
                      children: message['reactions'].entries.map<Widget>((entry) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xFF374151) : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.key} ${entry.value}',
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index))
        .slideY(begin: 0.3, end: 0);
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}