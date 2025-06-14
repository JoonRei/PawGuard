import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawguard/login.dart';

class ProfileOrganizationPage extends StatefulWidget {
  const ProfileOrganizationPage({super.key});

  @override
  State<ProfileOrganizationPage> createState() => _ProfileOrganizationPageState();
}

class _ProfileOrganizationPageState extends State<ProfileOrganizationPage> {
  bool isLoading = false;
  final user = FirebaseAuth.instance.currentUser;

  final Color primaryColor = const Color(0xFFEF6B39);
  final Color secondaryColor = const Color(0xFFF8F9FC);
  final Color textColor = const Color(0xFF333333);
  final Color subtextColor = const Color(0xFF6B7280);
  final double borderRadius = 12.0;

Widget _buildProfileImage(Map<String, dynamic>? userData) {
  return GestureDetector(
    onTap: () {
      // Show image preview dialog when the image is tapped
      showDialog(
        context: context,
        barrierDismissible: true, // Allow dismiss by tapping outside the dialog
        builder: (BuildContext context) {
          return CupertinoPageScaffold(
            backgroundColor: Colors.black, // Dark background for image preview
            navigationBar: CupertinoNavigationBar(
              backgroundColor: Colors.transparent, // Make the nav bar transparent
              leading: Container(), // Remove the back arrow
            ),
            child: Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Dismiss the preview when tapped
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85, // Limit width for better design
                      height: MediaQuery.of(context).size.height * 0.7, // Limit height for better design
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color for the image container
                        borderRadius: BorderRadius.circular(20), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12, // Soft shadow for iOS look
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: userData != null && userData['image'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20), // Rounded corners for image
                              child: Image.memory(
                                base64Decode(userData['image']),
                                fit: BoxFit.contain, // Preserve aspect ratio
                                width: double.infinity, // Allow it to scale within the container
                                height: double.infinity, // Allow it to scale within the container
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person, // Default icon if image fails
                                    size: 100,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.person, // Default icon if no image is available
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  // Exit (X) button in the top-right corner
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Dismiss the preview when tapping on the close (X) button
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.8), // Light background for close button
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.black, // Close button color
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
    child: Container(
      height: 150, // Height of the image container
      width: 150,  // Width of the image container
      decoration: BoxDecoration(
        shape: BoxShape.circle, // Circular shape for the profile picture
        color: Colors.white, // Background color of the container
        border: Border.all(
          color: Colors.white, // Border color (white)
          width: 4, // Border width
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Soft shadow for floating effect
            blurRadius: 12, // Blur effect for the shadow
            spreadRadius: 2, // Spread effect for the shadow
            offset: Offset(0, 4), // Shadow position
          ),
        ],
      ),
      child: ClipOval(
        child: userData != null && userData['image'] != null
            ? Image.memory(
                base64Decode(userData['image']),
                fit: BoxFit.cover, // Make the image cover the circle
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person, // Default icon if image fails
                    size: 60,
                    color: Colors.grey,
                  );
                },
              )
            : const Icon(
                Icons.person, // Default icon if no image is available
                size: 60,
                color: Colors.grey,
              ),
      ),
    ),
  );
}


  Widget _buildNavigationButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF6B39).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFEF6B39),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: subtextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            if (!mounted) return;

                            Navigator.of(context).pop();

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Failed to logout. Please try again.'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEF6B39)),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No user data found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildProfileImage(userData),
                      const SizedBox(height: 16),
                      Text(
                        userData['name'] ?? 'User',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildNavigationButton(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        onTap: () => Navigator.pushNamed(
                            context, '/profile/personal-info',
                            arguments: userData),
                      ),
                      _buildNavigationButton(
                        title: 'Events',
                        icon: Icons.event,
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/events',
                            arguments: FirebaseAuth.instance.currentUser?.uid,
                          );
                        },
                      ),
                      _buildNavigationButton(
                        title: 'Adoption Applications',
                        icon: Icons.pets_outlined,
                        onTap: () => Navigator.pushNamed(
                            context, '/profile/applications'),
                      ),
                      _buildNavigationButton(
                        title: 'About',
                        icon: Icons.info_outline,
                        onTap: () =>
                            Navigator.pushNamed(context, '/profile/about'),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF6B39).withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _handleLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF6B39),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
