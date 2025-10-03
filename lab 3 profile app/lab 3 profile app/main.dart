import 'package:flutter/material.dart';

void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage('assets/profile.jpg'),
                ),
                const SizedBox(height: 20),
                // Name
                Text(
                  'Waqas Shah',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  'Flutter Developer',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[300],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                // Divider
                Divider(
                  thickness: 1,
                  color: Colors.grey[800],
                  indent: 40,
                  endIndent: 40,
                ),
                const SizedBox(height: 24),
                // Info Cards
                Card(
                  elevation: 0,
                  color: const Color(0xFF353535),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.email_outlined,
                      color: Colors.grey[300],
                    ),
                    title: Text(
                      'waqas.shah@email.com',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: const Color(0xFF353535),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.phone_outlined,
                      color: Colors.grey[300],
                    ),
                    title: Text(
                      '+92 300 1234567',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: const Color(0xFF353535),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey[300],
                    ),
                    title: Text(
                      'Vehari, Pakistan',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Social Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.facebook, color: Colors.grey[300]),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.linked_camera, color: Colors.grey[300]),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.web, color: Colors.grey[300]),
                      onPressed: () {},
                    ),
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
