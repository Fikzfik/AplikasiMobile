import 'package:fikzuas/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  _FindFriendsScreenState createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _friendRequests = [];
  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = false;
  String? _token;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadAuthData();
  }

  Future<void> _loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('id_user');
    print('Attempting to load auth data: token_key="token", user_id_key="id_user"');
    print('Loaded auth data: token=${token ?? 'null'}, user_id=$userId');

    if (token == null || token.isEmpty || userId == null) {
      print('No valid token or user ID found. Clearing SharedPreferences and redirecting to login.');
      await prefs.clear();
      _showLoginPrompt();
      return;
    }

    setState(() {
      _token = token;
      _currentUserId = userId;
    });

    // Verify token validity
    final isValidToken = await _verifyToken();
    if (!isValidToken) {
      print('Invalid or expired token. Clearing SharedPreferences and redirecting to login.');
      await prefs.clear();
      _showLoginPrompt();
      return;
    }

    await _fetchFriendData();
  }

  Future<bool> _verifyToken() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      print('Token verification response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying token: $e');
      return false;
    }
  }

  void _showLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sesi kadaluarsa atau belum login. Silakan login kembali.'),
        action: SnackBarAction(
          label: 'Login',
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          },
        ),
      ),
    );
  }

  Future<void> _fetchFriendData() async {
    setState(() {
      _isLoading = true;
      print('Fetching friend data with token: $_token, user_id: $_currentUserId');
    });

    try {
      final requestsResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/friend_requests?status=pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      print('Friend requests response: ${requestsResponse.statusCode} ${requestsResponse.body}');

      final friendsResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/friends?user_id=$_currentUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      print('Friends response: ${friendsResponse.statusCode} ${friendsResponse.body}');

      if (requestsResponse.statusCode == 200) {
        final List<dynamic> requestsData = jsonDecode(requestsResponse.body);
        setState(() {
          _friendRequests = requestsData
              .map((req) => {
                    'id_request': req['id_request'],
                    'id_sender': req['id_sender'],
                    'sender_name': req['sender_name'],
                  })
              .toList();
          print('Loaded ${_friendRequests.length} friend requests');
        });
      } else if (requestsResponse.statusCode == 401) {
        print('401 Unauthorized for friend requests. Token may be invalid.');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _showLoginPrompt();
      } else {
        print('Failed to load friend requests: ${requestsResponse.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat permintaan pertemanan')),
        );
      }

      if (friendsResponse.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(friendsResponse.body);
        final List<dynamic> friendsData = responseData['data'] ?? [];
        setState(() {
          _friends = friendsData
              .map((friend) => {
                    'id_user': friend['id_user'],
                    'name': friend['name'],
                  })
              .toList();
          print('Loaded ${_friends.length} friends');
        });
      } else if (friendsResponse.statusCode == 401) {
        print('401 Unauthorized for friends. Token may be invalid.');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _showLoginPrompt();
      } else {
        final errorData = jsonDecode(friendsResponse.body);
        print('Failed to load friends: ${friendsResponse.statusCode} ${errorData['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat teman: ${errorData['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      print('Error fetching friend data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat memuat data teman')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        print('Finished fetching friend data');
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      print('Searching users with query: $query');
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/users/search?name=$query&exclude_id=$_currentUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      print('Search users response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> tempResults = data
            .map((user) => {
                  'id_user': user['id_user'],
                  'name': user['name'],
                  'email': user['email'],
                  'is_friend': _friends.any((friend) => friend['id_user'] == user['id_user']),
                  'has_pending_request': _friendRequests.any((req) => req['id_sender'] == user['id_user']),
                })
            .toList();

        for (var user in tempResults) {
          if (!user['has_pending_request']) {
            final hasSentRequest = await _checkSentRequest(user['id_user']);
            user['has_pending_request'] = user['has_pending_request'] || hasSentRequest;
          }
        }

        setState(() {
          _searchResults = tempResults;
          print('Search results: $tempResults');
        });
      } else if (response.statusCode == 401) {
        print('401 Unauthorized for user search. Token may be invalid.');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _showLoginPrompt();
      } else {
        print('Failed to search users: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mencari pengguna')),
        );
      }
    } catch (e) {
      print('Error searching users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat mencari pengguna')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        print('Finished searching users');
      });
    }
  }

  Future<bool> _checkSentRequest(int receiverId) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/friend_requests?sender_id=$_currentUserId&receiver_id=$receiverId&status=pending'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      print('Check sent request response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.isNotEmpty;
      } else if (response.statusCode == 401) {
        print('401 Unauthorized for checking sent request. Token may be invalid.');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _showLoginPrompt();
      }
    } catch (e) {
      print('Error checking sent request: $e');
    }
    return false;
  }

  Future<void> _sendFriendRequest(int receiverId) async {
    if (receiverId == _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat mengirim permintaan ke diri sendiri')),
      );
      return;
    }

    if (_token == null || _token!.isEmpty) {
      print('No token found for sending friend request.');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _showLoginPrompt();
      return;
    }

    print('Sending friend request to receiverId: $receiverId with token: $_token');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/friend_requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'id_receiver': receiverId,
        }),
      );

      print('Send friend request response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permintaan pertemanan terkirim')),
        );
        await _searchUsers(_searchController.text);
      } else if (response.statusCode == 401) {
        print('401 Unauthorized for sending friend request. Token may be invalid.');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _showLoginPrompt();
      } else {
        String errorMessage = 'Gagal mengirim permintaan';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['errors'] != null) {
            errorMessage = errorData['errors']['id_receiver']?.join(', ') ?? errorMessage;
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (_) {
          errorMessage = 'Server error: ${response.statusCode}';
        }
        print('Friend request failed: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      print('Error sending friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat mengirim permintaan')),
      );
    }
  }

  Future<void> _acceptFriendRequest(int requestId, int senderId) async {
    print('Accepting friend request: requestId=$requestId, senderId=$senderId');

    if (_token == null || _token!.isEmpty) {
      print('No token found for accepting friend request.');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _showLoginPrompt();
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/friend_requests/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': 'accepted'}),
      );
      print('Accept friend request response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final friendResponse = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/friends'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'id_user1': _currentUserId! < senderId ? _currentUserId : senderId,
            'id_user2': _currentUserId! > senderId ? _currentUserId : senderId,
          }),
        );
        print('Create friendship response: ${friendResponse.statusCode} ${friendResponse.body}');

        if (friendResponse.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permintaan pertemanan diterima')),
          );
          await _fetchFriendData();
        } else {
          final errorData = jsonDecode(friendResponse.body);
          print('Failed to create friendship: ${friendResponse.statusCode} ${errorData['error']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambah teman: ${errorData['error'] ?? 'Unknown error'}')),
          );
        }
      } else if (response.statusCode == 401) {
        print('401 Unauthorized for accepting friend request. Token may be invalid.');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _showLoginPrompt();
      } else {
        final errorData = jsonDecode(response.body);
        print('Failed to accept friend request: ${response.statusCode} ${errorData['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menerima permintaan: ${errorData['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      print('Error accepting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat menerima permintaan')),
      );
    }
  }

  Future<void> _rejectFriendRequest(int requestId) async {
    print('Rejecting friend request: requestId=$requestId');

    if (_token == null || _token!.isEmpty) {
      print('No token found for rejecting friend request.');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _showLoginPrompt();
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/api/friend_requests/$requestId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': 'rejected'}),
      );
      print('Reject friend request response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permintaan pertemanan ditolak')),
        );
        await _fetchFriendData();
      } else if (response.statusCode == 401) {
        print('401 Unauthorized for rejecting friend request. Token may be invalid.');
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        _showLoginPrompt();
      } else {
        final errorData = jsonDecode(response.body);
        print('Failed to reject friend request: ${response.statusCode} ${errorData['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menolak permintaan: ${errorData['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      print('Error rejecting friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat menolak permintaan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cari Teman',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ada ${_friendRequests.length} permintaan pertemanan tertunda')),
                  );
                },
                tooltip: 'Permintaan Pertemanan',
              ),
              if (_friendRequests.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_friendRequests.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Cari pengguna berdasarkan nama...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: _searchUsers,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Teman Anda',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                _isLoading && _friends.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _friends.isEmpty
                        ? const Center(child: Text('Belum ada teman'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _friends.length,
                            itemBuilder: (context, index) {
                              final friend = _friends[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  child: Text(
                                    friend['name'][0],
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(friend['name']),
                                trailing: const Icon(Icons.chat, color: Colors.blue),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrivateChatScreen(
                                        otherUserId: friend['id_user'],
                                        otherUserName: friend['name'],
                                      ),
                                    ),
                                  );
                                },
                              ).animate().fadeIn(delay: Duration(milliseconds: 100 * index));
                            },
                          ),
                const SizedBox(height: 16),
                _isLoading && !_friends.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          if (_friendRequests.isNotEmpty) ...[
                            const Text(
                              'Permintaan Pertemanan Tertunda',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            ..._friendRequests.map((request) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.withOpacity(0.2),
                                    child: Text(
                                      request['sender_name'][0],
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(request['sender_name']),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () => _acceptFriendRequest(
                                            request['id_request'], request['id_sender']),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () => _rejectFriendRequest(request['id_request']),
                                      ),
                                    ],
                                  ),
                                )).toList(),
                            const SizedBox(height: 16),
                          ],
                          if (_searchResults.isNotEmpty) ...[
                            const Text(
                              'Hasil Pencarian',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                            ..._searchResults.map((user) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.withOpacity(0.2),
                                    child: Text(
                                      user['name'][0],
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(user['name']),
                                  subtitle: Text(user['email']),
                                  trailing: user['is_friend']
                                      ? const Text('Teman', style: TextStyle(color: Colors.green))
                                      : user['has_pending_request']
                                          ? const Text('Permintaan Tertunda',
                                              style: TextStyle(color: Colors.grey))
                                          : ElevatedButton(
                                              onPressed: () => _sendFriendRequest(user['id_user']),
                                              child: const Text('Tambah Teman'),
                                            ),
                                )).toList(),
                          ],
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrivateChatScreen extends StatelessWidget {
  final int otherUserId;
  final String otherUserName;

  const PrivateChatScreen({super.key, required this.otherUserId, required this.otherUserName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(otherUserName)),
      body: const Center(child: Text('Private Chat Not Implemented')),
    );
  }
}