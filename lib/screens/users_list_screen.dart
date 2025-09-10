import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../glassmorphism_container.dart';
import '../user_model.dart';


class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _launchWhatsApp(String phone) async {
    final cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    String whatsAppNumber;

    if (cleanedPhone.startsWith('+')) {
      whatsAppNumber = cleanedPhone;
    } else if (cleanedPhone.startsWith('92')) {
      whatsAppNumber = '+$cleanedPhone';
    } else if (cleanedPhone.startsWith('0')) {
      whatsAppNumber = '+92${cleanedPhone.substring(1)}';
    } else {
      whatsAppNumber = '+92$cleanedPhone';
    }

    final url = 'https://wa.me/$whatsAppNumber';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Registered Volunteers'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + 70,
                left: 16,
                right: 16,
              ),
              child: GlassmorphismContainer(
                borderRadius: 25,
                blur: 15,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search volunteers...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('public_users')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: GlassmorphismContainer(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text('Error: ${snapshot.error}',
                                style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: GlassmorphismContainer(
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No volunteers found',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      );
                    }

                    final users = snapshot.data!.docs
                        .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
                        .where((user) =>
                    user.name.toLowerCase().contains(_searchQuery) ||
                        user.phone.contains(_searchQuery) ||
                        user.email.toLowerCase().contains(_searchQuery))
                        .toList();

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GlassmorphismContainer(
                            borderRadius: 15,
                            blur: 15,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Phone: ${user.phone}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Email: ${user.email}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.chat, color: Colors.green),
                                onPressed: () => _launchWhatsApp(user.phone),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}