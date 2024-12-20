import 'package:campuslink/screens/dashboard/attendance_report.dart';
import 'package:campuslink/screens/dashboard/event_detail_screen.dart';
import 'package:campuslink/screens/dashboard/event_list_screen.dart';
import 'package:campuslink/screens/dashboard/chatbot_manage.dart';
import 'package:campuslink/screens/dashboard/student_management_screen.dart';
import 'package:campuslink/screens/dashboard/teacher_management_screen.dart';
import 'package:flutter/material.dart';
import '../profile.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
// Import other necessary screens based on roles

class UserDashboard extends StatefulWidget {
  final String userId;
  final String userRole;
  
  const UserDashboard({
    Key? key,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

  static final StreamController<void> eventUpdateController = StreamController<void>.broadcast();
  
  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String eventTitle = 'Loading...';
  String? eventDate;
  late StreamSubscription eventUpdateSubscription;
  Map<String, dynamic> upcomingEvent = {};

  @override
  void initState() {
    super.initState();
    fetchUpcomingEvent();
    eventUpdateSubscription = UserDashboard.eventUpdateController.stream.listen((_) {
      fetchUpcomingEvent();
    });
  }

  @override
  void dispose() {
    eventUpdateSubscription.cancel();
    super.dispose();
  }

  Future<void> fetchUpcomingEvent() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.78/upcoming_event.php'));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          setState(() {
            eventTitle = 'No upcoming events';
            eventDate = null;
            upcomingEvent = {};
          });
          return;
        }

        final data = jsonDecode(response.body);
        setState(() {
          upcomingEvent = data;
          eventTitle = data['title'] ?? 'No title';
          eventDate = data['event_date'];
        });
      } else {
        setState(() {
          eventTitle = 'Error loading event';
          eventDate = null;
          upcomingEvent = {};
        });
      }
    } catch (e) {
      setState(() {
        eventTitle = 'Error loading event';
        eventDate = null;
        upcomingEvent = {};
      });
      print('Error: $e');
    }
  }

  List<Widget> _getQuickActionsByRole() {
    switch (widget.userRole.toLowerCase()) {
      case 'admin':
        return [
          _buildActionCard(
            'Manage Students',
            Icons.people_outline,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageStudentsScreen()),
            ),
          ),
          _buildActionCard(
            'Manage Teachers',
            Icons.person,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageTeachersScreen()),
            ),
          ),
          _buildActionCard(
            'Attendance',
            Icons.check_circle_outline,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminAttendanceReport()),
            ),
          ),
          _buildActionCard(
            'Manage Chatbot',
            Icons.smart_toy,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatbotManagementScreen(adminId: widget.userId)),
            ),
          ),
          _buildActionCard(
            'Manage Events',
            Icons.event_note,
            Colors.indigo,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventListScreen()),
            ),
          ),
        ];
      
      case 'teacher':
        return [
          _buildActionCard(
            'Manage Students',
            Icons.people_outline,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManageStudentsScreen()),
            ),
          ),
          _buildActionCard(
            'Attendance',
            Icons.check_circle_outline,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminAttendanceReport()),
            ),
          ),
          _buildActionCard(
            'Manage Events',
            Icons.event_note,
            Colors.indigo,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventListScreen()),
            ),
          ),
        ];
      
      case 'student':
        return [
          _buildActionCard(
            'Attendance',
            Icons.check_circle_outline,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminAttendanceReport()),
            ),
          ),
        ];
      
      case 'guest':
        return []; // No quick actions for guests
      
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 39, 46, 58)),
              child: Center(
                child: Text(
                  "${widget.userRole} Menu",
                  style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About', style: TextStyle(color: Colors.black)),
              onTap: () {
                // Implement your navigation logic
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 39, 46, 58),
        title: Text('${widget.userRole} Dashboard', 
          style: const TextStyle(color: Colors.white)
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back, ${widget.userId}!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here\'s what\'s happening today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Stats Section (show only for admin and teacher)
              if (widget.userRole.toLowerCase() == 'admin' || widget.userRole.toLowerCase() == 'teacher')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildQuickStatCard(
                        'Total Students',
                        '1,234',
                        Icons.school,
                        Colors.blue,
                      ),
                      const SizedBox(width: 15),
                      if (widget.userRole.toLowerCase() == 'admin')
                        _buildQuickStatCard(
                          'Total Teachers',
                          '89',
                          Icons.person,
                          Colors.green,
                        ),
                    ],
                  ),
                ),

              // Upcoming Events Section
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.event, color: Colors.white, size: 30),
                            SizedBox(width: 10),
                            Text(
                              'Upcoming Event',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      eventTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, 
                            color: Colors.white.withOpacity(0.9), 
                            size: 16),
                        const SizedBox(width: 8),
                        Text(
                          eventDate == null 
                              ? 'Loading...'
                              : DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(eventDate!)),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (widget.userRole.toLowerCase() != 'guest')
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailScreen(
                                eventId: upcomingEvent['id']?.toString() ?? '1',
                                onEventUpdated: () {
                                  fetchUpcomingEvent();
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('View Details'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Quick Actions Grid (not shown for guests)
              if (widget.userRole.toLowerCase() != 'guest')
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 15),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        children: _getQuickActionsByRole(),
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

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}