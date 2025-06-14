
import 'dart:convert';
import 'package:fikzuas/main.dart';
import 'package:fikzuas/pages/CommunityPage.dart';
import 'package:fikzuas/pages/privatechatscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class FindFriendsScreen extends StatefulWidget {
  @override
  _FindFriendsScreenState createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dialogSearchController = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _pendingRequests = [];
  bool _isLoading = false;
  String? _token;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadAuthData();
    _dialogSearchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dialogSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    print('Auth: token=$token');

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8000/api/user'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('User API: Status ${response.statusCode}, Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final userId = data['user']['id_user'] ?? data['user']['id'];
          final userName = data['user']['name'];

          await prefs.setInt('user_id', userId);
          await prefs.setString('user_name', userName);

          setState(() {
            _token = token;
            _currentUserId = userId;
          });

          await Future.wait([
            _fetchAllUsers(),
            _fetchFriends(),
            _fetchPendingRequests(),
          ]);
        } else {
          setState(() {
            _currentUserId = null;
            _token = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load user data: ${response.statusCode}')),
          );
        }
      } catch (e) {
        print('Load Auth Error: $e');
        setState(() {
          _currentUserId = null;
          _token = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    } else {
      setState(() {
        _currentUserId = null;
        _token = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Not logged in')),
      );
    }
  }

  Future<void> _fetchAllUsers() async {
  if (_currentUserId == null || _token == null) {
    print('Cannot fetch users: userId or token is null');
    return;
  }

  setState(() => _isLoading = true);
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/users?exclude_id=$_currentUserId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print('Users API: Status ${response.statusCode}, Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _allUsers = data.cast<Map<String, dynamic>>();
        _filteredUsers = _allUsers;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: ${response.statusCode}')),
      );
    }
  } catch (e) {
    print('Fetch Users Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error loading users: $e')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  Future<void> _fetchFriends() async {
    if (_currentUserId == null || _token == null) {
      print('Cannot fetch friends: userId or token is null');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/friends'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Friends API: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _friends = List<Map<String, dynamic>>.from(responseData['data']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load friends: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Fetch Friends Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading friends: $e')),
      );
    }
  }

  Future<void> _fetchPendingRequests() async {
    if (_currentUserId == null || _token == null) {
      print('Cannot fetch requests: userId or token is null');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/friend_requests?status=pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Requests API: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _pendingRequests = data.cast<Map<String, dynamic>>();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load requests: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Fetch Requests Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pending requests: $e')),
      );
    }
  }

  Future<void> _sendFriendRequest(int receiverId) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/friend_requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'id_receiver': receiverId}),
      );

      print('Send Request API: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request sent')),
        );
        await _fetchPendingRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send friend request: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Send Request Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending friend request: $e')),
      );
    }
  }

  Future<void> _respondToFriendRequest(int requestId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/friend_requests/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({'status': status}),
      );

      print('Respond Request API: Status ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request $status')),
        );
        if (status == 'accepted') {
          await Future.wait([_fetchFriends(), _fetchPendingRequests()]);
        } else {
          await _fetchPendingRequests();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update friend request: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Respond Request Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating friend request: $e')),
      );
    }
  }

  void _filterUsers() {
    final query = _dialogSearchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return user['name'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Provider.of<ThemeProvider>(context).isDark;
        return AlertDialog(
          title: Text(
            'Add Friend',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: isDark ? Color(0xFF1F2937) : Colors.white,
          content: Container(
            width: double.maxFinite,
            height: 400, // Adjust height as needed
            child: Column(
              children: [
                TextField(
                  controller: _dialogSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search,
                        color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark ? Color(0xFF374151) : Colors.grey[200],
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _filteredUsers.isEmpty
                          ? Text('No users found')
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                final isFriend = _friends.any(
                                    (friend) => friend['id_user'] == user['id_user']);
                                final isPending = _pendingRequests.any(
                                    (req) => req['id_sender'] == user['id_user']);
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.withOpacity(0.2),
                                    child: Text(
                                      user['name'][0],
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(
                                    user['name'],
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    user['email'],
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                  trailing: isFriend
                                      ? Text('Friend',
                                          style: TextStyle(color: Colors.green))
                                      : isPending
                                          ? Text('Pending',
                                              style: TextStyle(color: Colors.orange))
                                          : IconButton(
                                              icon: Icon(Icons.person_add,
                                                  color: Colors.blue),
                                              onPressed: () {
                                                _sendFriendRequest(user['id_user']);
                                              },
                                            ),
                                ).animate().fadeIn(
                                    delay: Duration(milliseconds: 100 * index));
                              },
                            ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _dialogSearchController.clear();
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: isDark ? Colors.blueAccent : Colors.blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find Friends',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search friends...',
                  prefixIcon: Icon(Icons.search,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Color(0xFF374151) : Colors.grey[200],
                ),
                onChanged: (query) {
                  setState(() {
                    _friends = _friends.where((friend) {
                      return friend['name']
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase());
                    }).toList();
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                'Pending Friend Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 8),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _pendingRequests.isEmpty
                      ? Text('No pending requests')
                      : Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _pendingRequests.length,
                            itemBuilder: (context, index) {
                              final request = _pendingRequests[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  child: Text(
                                    request['sender_name'][0],
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(request['sender_name']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () => _respondToFriendRequest(
                                          request['id_request'], 'accepted'),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _respondToFriendRequest(
                                          request['id_request'], 'rejected'),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(
                                  delay: Duration(milliseconds: 100 * index));
                            },
                          ),
                        ),
              SizedBox(height: 16),
              Text(
                'Your Friends',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 8),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _friends.isEmpty
                      ? Text('No friends yet')
                      : Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _friends.length,
                            itemBuilder: (context, index) {
                              final friend = _friends[index];
                              final lastMessage = friend['last_message'] ?? 'No messages yet';
                              final lastMessageTime = friend['last_message_time'];
                              final unreadCount = friend['unread_count'] ?? 0;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  child: Text(
                                    friend['name'][0],
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(friend['name']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    if (lastMessageTime != null)
                                      Text(
                                        DateFormat('MMM d, HH:mm').format(
                                            DateTime.parse(lastMessageTime)),
                                        style: TextStyle(
                                          color: isDark ? Colors.grey[500] : Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: unreadCount > 0
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'New Message ($unreadCount)',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  print('Navigating to chat with user ID: ${friend['id_user']}');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrivateChatScreen(
                                        otherUserId: friend['id_user'],
                                        otherUserName: friend['name'],
                                      ),
                                    ),
                                  ).then((_) {
                                    print('Returned to FindFriendsScreen, refreshing friends');
                                    _fetchFriends();
                                  });
                                },
                              ).animate().fadeIn(
                                  delay: Duration(milliseconds: 100 * index));
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        child: Icon(Icons.person_add),
        backgroundColor: isDark ? Colors.blueAccent : Colors.blue,
      ),
    );
  }
}
