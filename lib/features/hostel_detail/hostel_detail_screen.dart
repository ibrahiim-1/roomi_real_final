import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/hostel_model.dart';
import '../../models/room_model.dart';
import '../../services/firebase_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../core/utils.dart';
import '../reviews/review_dialog.dart';
import '../reviews/review_list.dart';

class HostelDetailScreen extends StatefulWidget {
  final String hostelId;

  const HostelDetailScreen({super.key, required this.hostelId});

  @override
  State<HostelDetailScreen> createState() => _HostelDetailScreenState();
}

class _HostelDetailScreenState extends State<HostelDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Hostel? _hostel;
  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHostelData();
  }

  Future<void> _loadHostelData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hostel = await _firebaseService.getHostelById(widget.hostelId);
      final rooms = await _firebaseService.getRoomsOnce(widget.hostelId);

      setState(() {
        _hostel = hostel;
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _callHostel() async {
    if (_hostel == null) return;
    final uri = Uri.parse('tel:${_hostel!.phone}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _whatsappHostel() async {
    if (_hostel == null) return;
    final uri = Uri.parse('https://wa.me/${_hostel!.phone.replaceAll(RegExp(r'[^0-9]'), '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _showReviewDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => ReviewDialog(hostelId: widget.hostelId),
    );

    if (result == true) {
      _loadHostelData(); // Reload to get updated rating
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Details'),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading hostel details...')
          : _error != null
              ? ErrorDisplayWidget(
                  message: _error!,
                  onRetry: _loadHostelData,
                )
              : _hostel == null
                  ? const Center(child: Text('Hostel not found'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Carousel
                          if (_hostel!.photoUrls.isNotEmpty)
                            Stack(
                              children: [
                                CarouselSlider.builder(
                                  itemCount: _hostel!.photoUrls.length,
                                  itemBuilder: (context, index, realIndex) {
                                    return CachedNetworkImage(
                                      imageUrl: _hostel!.photoUrls[index],
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        height: 300,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        height: 300,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                    );
                                  },
                                  options: CarouselOptions(
                                    height: 300,
                                    viewportFraction: 1.0,
                                    autoPlay: true,
                                    onPageChanged: (index, reason) {
                                      setState(() {
                                        _currentImageIndex = index;
                                      });
                                    },
                                  ),
                                ),
                                // Image indicators
                                Positioned(
                                  bottom: 16,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _hostel!.photoUrls.asMap().entries.map((entry) {
                                      return Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _currentImageIndex == entry.key
                                              ? Colors.white
                                              : Colors.white70,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            )
                          else
                            Container(
                              height: 300,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 80),
                            ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name and Rating
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _hostel!.name,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < _hostel!.averageRating.round() ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 20,
                                            );
                                          }),
                                        ),
                                        Text(
                                          '${_hostel!.averageRating.toStringAsFixed(1)} (${_hostel!.reviewCount} reviews)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Location
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _hostel!.address,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Owner Info
                                Row(
                                  children: [
                                    Icon(Icons.person, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Owner: ${_hostel!.ownerName}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Available Seats
                                Row(
                                  children: [
                                    Icon(Icons.people, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_hostel!.totalSeats - _hostel!.bookedSeats} seats available',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Nearby Universities
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _hostel!.nearbyUniversities.map((uni) {
                                    return Chip(
                                      label: Text(uni),
                                      backgroundColor: Colors.orange[50],
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),
                                // Description
                                if (_hostel!.description != null) ...[
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _hostel!.description!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                // Rules
                                if (_hostel!.rules != null) ...[
                                  const Text(
                                    'Rules',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _hostel!.rules!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                // Rooms
                                const Text(
                                  'Available Rooms',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ..._rooms.map((room) => _buildRoomCard(room)),
                                const SizedBox(height: 24),
                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _callHostel,
                                        icon: const Icon(Icons.call),
                                        label: const Text('Call'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _whatsappHostel,
                                        icon: const Icon(Icons.chat),
                                        label: const Text('WhatsApp'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _showReviewDialog,
                                    icon: const Icon(Icons.rate_review),
                                    label: const Text('Write a Review'),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Reviews Section
                                const Text(
                                  'Reviews & Ratings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ReviewList(hostelId: widget.hostelId),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  room.type,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppUtils.formatCurrency(room.rentPerSeat),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5722),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${room.availableSeats} of ${room.totalSeats} seats available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: room.facilities.entries
                  .where((e) => e.value == true)
                  .map((e) => Chip(
                        label: Text(e.key),
                        labelStyle: const TextStyle(fontSize: 12),
                        padding: EdgeInsets.zero,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

