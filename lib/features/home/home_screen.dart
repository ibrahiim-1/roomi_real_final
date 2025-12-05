import 'package:flutter/material.dart';
import '../../models/hostel_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/hostel_card.dart';
import '../../widgets/filter_sheet.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../core/constants.dart';
import '../hostel_detail/hostel_detail_screen.dart';
import '../admin/admin_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();
  
  Map<String, dynamic> _filters = {
    'universities': <String>[],
    'location': '',
    'gender': '',
    'minBudget': AppConstants.minBudget,
    'maxBudget': AppConstants.maxBudget,
    'roomTypes': <String>[],
    'facilities': <String>[],
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Hostel> _applyFilters(List<Hostel> hostels) {
    return hostels.where((hostel) {
      // University filter
      if (_filters['universities'] != null && 
          (_filters['universities'] as List).isNotEmpty) {
        final hasUniversity = (hostel.nearbyUniversities).any(
          (uni) => (_filters['universities'] as List).contains(uni),
        );
        if (!hasUniversity) return false;
      }

      // Gender filter
      if (_filters['gender'] != null && _filters['gender'].toString().isNotEmpty) {
        if (hostel.gender != _filters['gender']) return false;
      }

      // Location filter
      if (_filters['location'] != null && _filters['location'].toString().isNotEmpty) {
        final location = _filters['location'].toString().toLowerCase();
        if (!hostel.address.toLowerCase().contains(location)) return false;
      }

      // Search filter
      if (_searchController.text.isNotEmpty) {
        final search = _searchController.text.toLowerCase();
        if (!hostel.name.toLowerCase().contains(search) &&
            !hostel.address.toLowerCase().contains(search)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(
        currentFilters: _filters,
        onApplyFilters: (filters) {
          setState(() {
            _filters = filters;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ROOMI'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
              );
            },
            child: const Text(
              'Login as Admin',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search hostels...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: _showFilterSheet,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          // Hostels grid
          Expanded(
            child: StreamBuilder<List<Hostel>>(
              stream: _firebaseService.getHostels(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Loading hostels...');
                }

                if (snapshot.hasError) {
                  return ErrorDisplayWidget(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(() {}),
                  );
                }

                final allHostels = snapshot.data ?? [];
                final filteredHostels = _applyFilters(allHostels);

                if (filteredHostels.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No hostels found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: filteredHostels.length,
                  itemBuilder: (context, index) {
                    final hostel = filteredHostels[index];
                    return HostelCard(
                      hostel: hostel,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HostelDetailScreen(hostelId: hostel.id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFilterSheet,
        child: const Icon(Icons.filter_list),
      ),
    );
  }
}

