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
  FindFriendsScreenState createState() => FindFriendsScreenState();
}

class FindFriendsScreenState extends State<FindFriendsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dialogSearchController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _dialogSearchController.addListener(_filterUsers);
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dialogSearchController.dispose();
    _animationController.dispose();
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
        print(
            'User API: Status ${response.statusCode}, Body: ${response.body}');
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
            SnackBar(
                content:
                    Text('Failed to load user data: ${response.statusCode}')),
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
          SnackBar(
              content: Text('Failed to load users: ${response.statusCode}')),
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
      print(
          'Friends API: Status ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _friends = List<Map<String, dynamic>>.from(responseData['data']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load friends: ${response.statusCode}')),
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
      print(
          'Requests API: Status ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _pendingRequests = data.cast<Map<String, dynamic>>();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load requests: ${response.statusCode}')),
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
      print(
          'Send Request API: Status ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request sent')),
        );
        await _fetchPendingRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to send friend request: ${response.statusCode}')),
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
      print(
          'Respond Request API: Status ${response.statusCode}, Body: ${response.body}');
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
          SnackBar(
              content: Text(
                  'Failed to update friend request: ${response.statusCode}')),
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
    print('Opening add friend dialog, current user ID: $_currentUserId');
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isDark = Provider.of<ThemeProvider>(context).isDark;
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Color(0xFF1F2937), Color(0xFF374151)]
                    : [Colors.white, Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person_add, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Discover Gamers',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: _dialogSearchController,
                      decoration: InputDecoration(
                        hintText: 'Search gamers...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor:
                            isDark ? Color(0xFF374151) : Colors.grey[100],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _filteredUsers.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off,
                                          size: 48, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text('No gamers found',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _filteredUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = _filteredUsers[index];
                                    final isFriend = _friends.any((friend) =>
                                        friend['id_user'] == user['id_user']);
                                    final isPending = _pendingRequests.any(
                                        (req) =>
                                            req['id_sender'] ==
                                            user['id_user']);
                                    return _buildUserCard(
                                        user, index, isFriend, isPending);
                                  },
                                ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: TextButton(
                      onPressed: () {
                        _dialogSearchController.clear();
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            isDark ? Color(0xFF374151) : Colors.grey[100],
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1))
            .fadeIn(duration: Duration(milliseconds: 300));
      },
    );
  }

  Widget _buildUserCard(
      Map<String, dynamic> user, int index, bool isFriend, bool isPending) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: isDark ? Color(0xFF374151) : Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  user['name'][0],
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (user['is_verified'] == 1)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.verified, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user['name'],
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(user['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user['status']?.toUpperCase() ?? 'OFFLINE',
                style: TextStyle(
                    color: _getStatusColor(user['status']),
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              user['email'],
              style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                    child: _buildInfoChip(
                        "Lv.${user['level'] ?? 1}", Colors.orange)),
                SizedBox(width: 8),
                Flexible(
                    child: _buildInfoChip(
                        user['rank'] ?? 'Unranked', Colors.purple)),
                SizedBox(width: 8),
                Flexible(
                    child: _buildInfoChip(
                        user['favorite_game'] ?? 'Unknown', Colors.blue)),
              ],
            ),
          ],
        ),
        trailing: isFriend
            ? Text('Friend', style: TextStyle(color: Colors.green))
            : isPending
                ? Text('Pending', style: TextStyle(color: Colors.orange))
                : IconButton(
                    icon: Icon(Icons.person_add, color: Color(0xFF3B82F6)),
                    onPressed: () => _sendFriendRequest(user['id_user']),
                  ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'away':
        return Colors.orange;
      case 'in-game':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Color(0xFF1F2937), Color(0xFF374151)]
                            : [Colors.white, Color(0xFFF8FAFC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: isDark ? Colors.white : Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Find Gaming Friends',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                'Connect with fellow gamers',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.person_add, color: Colors.white),
                            onPressed: _showAddFriendDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search your friends...',
                        prefixIcon: Icon(Icons.search,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? Color(0xFF374151) : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_pendingRequests.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Friend Requests',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _pendingRequests.length,
                              itemBuilder: (context, index) {
                                final request = _pendingRequests[index];
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF3B82F6).withOpacity(0.1),
                                        Color(0xFF8B5CF6).withOpacity(0.1)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color:
                                            Color(0xFF3B82F6).withOpacity(0.3)),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(16),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Color(0xFF3B82F6),
                                          Color(0xFF8B5CF6)
                                        ]),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          request['sender_name'][0],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      request['sender_name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            _buildInfoChip(
                                                "Lv.${request['sender_level'] ?? 1}",
                                                Colors.orange),
                                            SizedBox(width: 8),
                                            _buildInfoChip(
                                                request['sender_rank'] ??
                                                    'Unranked',
                                                Colors.purple),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "${request['mutual_friends'] ?? 0} mutual friends",
                                          style: TextStyle(
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : Colors.grey[600],
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.check,
                                              color: Colors.green),
                                          onPressed: () =>
                                              _respondToFriendRequest(
                                                  request['id_request'],
                                                  'accepted'),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _respondToFriendRequest(
                                                  request['id_request'],
                                                  'rejected'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    .animate()
                                    .fadeIn(
                                        delay:
                                            Duration(milliseconds: 100 * index))
                                    .slideX(begin: -0.3, end: 0);
                              },
                            ),
                            SizedBox(height: 24),
                          ],
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Your Gaming Squad',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          _friends.isEmpty
                              ? Container(
                                  margin: EdgeInsets.symmetric(horizontal: 16),
                                  padding: EdgeInsets.all(40),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Color(0xFF1F2937)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(Icons.people_outline,
                                          size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'No friends yet',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Start connecting with fellow gamers!',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _friends.length,
                                  itemBuilder: (context, index) {
                                    final friend = _friends[index];
                                    final lastMessage =
                                        friend['last_message'] ??
                                            'No messages yet';
                                    final lastMessageTime =
                                        friend['last_message_time'];
                                    final unreadCount =
                                        friend['unread_count'] ?? 0;
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Color(0xFF1F2937)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: isDark
                                                ? Colors.black.withOpacity(0.2)
                                                : Colors.black
                                                    .withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(16),
                                        leading: Stack(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    colors: [
                                                      Color(0xFF3B82F6),
                                                      Color(0xFF8B5CF6)
                                                    ]),
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  friend['name'][0],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                      friend['status']),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 2),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                friend['name'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black),
                                              ),
                                            ),
                                            if (unreadCount > 0)
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                child: Text(
                                                  '$unreadCount',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 4),
                                            if (lastMessage != null)
                                              Text(
                                                lastMessage,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                  fontSize: 13,
                                                  fontWeight: unreadCount > 0
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _buildInfoChip(
                                                    "Lv.${friend['level'] ?? 1}",
                                                    Colors.orange),
                                                SizedBox(width: 8),
                                                _buildInfoChip(
                                                    friend['rank'] ??
                                                        'Unranked',
                                                    Colors.purple),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.chat,
                                                  color: Color(0xFF3B82F6)),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PrivateChatScreen(
                                                      otherUserId:
                                                          friend['id_user'],
                                                      otherUserName:
                                                          friend['name'],
                                                      otherUserAvatar:
                                                          friend['avatar'] ??
                                                              friend['name'][0],
                                                      otherUserStatus:
                                                          friend['status'] ??
                                                              'offline',
                                                    ),
                                                  ),
                                                ).then((_) => _fetchFriends());
                                              },
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PrivateChatScreen(
                                                otherUserId: friend['id_user'],
                                                otherUserName: friend['name'],
                                                otherUserAvatar:
                                                    friend['avatar'] ??
                                                        friend['name'][0],
                                                otherUserStatus:
                                                    friend['status'] ??
                                                        'offline',
                                              ),
                                            ),
                                          ).then((_) => _fetchFriends());
                                        },
                                      ),
                                    )
                                        .animate()
                                        .fadeIn(
                                            delay: Duration(
                                                milliseconds: 150 * index))
                                        .slideX(begin: 0.3, end: 0);
                                  },
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
      ),
    );
  }
}
