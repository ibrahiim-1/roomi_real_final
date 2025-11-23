import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../models/hostel_model.dart';
import '../../models/room_model.dart';
import '../../services/firebase_service.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import '../../core/constants.dart';

class AddHostelScreen extends StatefulWidget {
  final Hostel? hostel;

  const AddHostelScreen({super.key, this.hostel});

  @override
  State<AddHostelScreen> createState() => _AddHostelScreenState();
}

class _AddHostelScreenState extends State<AddHostelScreen> {
  final PageController _pageController = PageController();
  final FirebaseService _firebaseService = FirebaseService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();

  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1: Basic Info
  final _nameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();
  String _selectedGender = 'Unisex';
  List<String> _selectedUniversities = [];

  // Step 2: Rooms
  List<RoomData> _rooms = [];

  // Step 3: Photos
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];

  @override
  void initState() {
    super.initState();
    if (widget.hostel != null) {
      _loadHostelData();
    }
  }

  void _loadHostelData() async {
    final hostel = widget.hostel!;
    _nameController.text = hostel.name;
    _ownerNameController.text = hostel.ownerName;
    _phoneController.text = hostel.phone;
    _addressController.text = hostel.address;
    _descriptionController.text = hostel.description ?? '';
    _rulesController.text = hostel.rules ?? '';
    _selectedGender = hostel.gender;
    _selectedUniversities = List.from(hostel.nearbyUniversities);
    _existingImageUrls = List.from(hostel.photoUrls);

    // Load rooms
    final rooms = await _firebaseService.getRoomsOnce(hostel.id);
    setState(() {
      _rooms = rooms.map((r) => RoomData.fromRoom(r)).toList();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((img) => File(img.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<void> _submit() async {
    // Validate step 1
    if (_nameController.text.trim().isEmpty ||
        _ownerNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Validate step 2
    if (_rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one room')),
      );
      return;
    }

    // Validate step 3
    if (_selectedImages.isEmpty && _existingImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String hostelId = widget.hostel?.id ?? '';
      List<String> photoUrls = List.from(_existingImageUrls);

      // Upload new images
      if (_selectedImages.isNotEmpty) {
        final uploadedUrls = await _storageService.uploadHostelImages(
          _selectedImages,
          hostelId,
        );
        photoUrls.addAll(uploadedUrls);
      }

      // Calculate total seats
      final totalSeats = _rooms.fold<int>(0, (sum, room) => sum + room.totalSeats);
      final bookedSeats = _rooms.fold<int>(0, (sum, room) => sum + (room.totalSeats - room.availableSeats));

      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUserId = authService.currentUser?.uid ?? '';

      final hostel = Hostel(
        id: hostelId,
        name: _nameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gender: _selectedGender,
        nearbyUniversities: _selectedUniversities,
        totalSeats: totalSeats,
        bookedSeats: bookedSeats,
        photoUrls: photoUrls,
        averageRating: widget.hostel?.averageRating ?? 0.0,
        reviewCount: widget.hostel?.reviewCount ?? 0,
        createdAt: widget.hostel?.createdAt ?? DateTime.now(),
        createdBy: widget.hostel?.createdBy ?? currentUserId,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        rules: _rulesController.text.trim().isEmpty
            ? null
            : _rulesController.text.trim(),
      );

      if (widget.hostel == null) {
        // Create new hostel
        final newHostelId = await _firebaseService.addHostel(hostel);
        hostelId = newHostelId;
      } else {
        // Update existing hostel
        await _firebaseService.updateHostel(hostelId, hostel.toMap());
        
        // Delete old rooms
        final oldRooms = await _firebaseService.getRoomsOnce(hostelId);
        for (var room in oldRooms) {
          await _firebaseService.deleteRoom(hostelId, room.id);
        }
      }

      // Add/Update rooms
      for (var roomData in _rooms) {
        final room = Room(
          id: const Uuid().v4(),
          hostelId: hostelId,
          type: roomData.type,
          rentPerSeat: roomData.rentPerSeat,
          totalSeats: roomData.totalSeats,
          availableSeats: roomData.availableSeats,
          facilities: roomData.facilities,
        );
        await _firebaseService.addRoom(hostelId, room);
      }

      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.hostel == null
              ? 'Hostel added successfully!'
              : 'Hostel updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hostel == null ? 'Add Hostel' : 'Edit Hostel'),
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Basic Info'),
                Expanded(child: Container(height: 2, color: Colors.grey[300])),
                _buildStepIndicator(1, 'Rooms'),
                Expanded(child: Container(height: 2, color: Colors.grey[300])),
                _buildStepIndicator(2, 'Photos'),
              ],
            ),
          ),
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep < 2 ? _nextStep : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentStep < 2 ? 'Next' : 'Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted
                ? const Color(0xFFFF5722)
                : Colors.grey[300],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFFFF5722) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Hostel Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ownerNameController,
            decoration: const InputDecoration(
              labelText: 'Owner Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address *',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          const Text('Gender *'),
          Row(
            children: AppConstants.genderOptions.map((gender) {
              return Expanded(
                child: RadioListTile<String>(
                  title: Text(gender),
                  value: gender,
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Nearby Universities *'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.universities.map((uni) {
              final selected = _selectedUniversities.contains(uni);
              return FilterChip(
                label: Text(uni),
                selected: selected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedUniversities.add(uni);
                    } else {
                      _selectedUniversities.remove(uni);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _rulesController,
            decoration: const InputDecoration(
              labelText: 'Rules (Optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rooms',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _rooms.add(RoomData());
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Room'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._rooms.asMap().entries.map((entry) {
            final index = entry.key;
            final room = entry.value;
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
                          'Room ${index + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _rooms.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: room.type,
                      decoration: const InputDecoration(
                        labelText: 'Room Type',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.roomTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          room.type = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: room.rentPerSeat.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Rent per Seat (PKR)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        room.rentPerSeat = double.tryParse(value) ?? 0.0;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: room.totalSeats.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Total Seats',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              room.totalSeats = int.tryParse(value) ?? 1;
                              if (room.availableSeats > room.totalSeats) {
                                room.availableSeats = room.totalSeats;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: room.availableSeats.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Available Seats',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final available = int.tryParse(value) ?? 0;
                              room.availableSeats = available > room.totalSeats
                                  ? room.totalSeats
                                  : available;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Facilities'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.facilities.map((facility) {
                        final selected = room.facilities[facility] ?? false;
                        return FilterChip(
                          label: Text(facility),
                          selected: selected,
                          onSelected: (selected) {
                            setState(() {
                              room.facilities[facility] = selected;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hostel Photos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Pick Images'),
          ),
          const SizedBox(height: 16),
          if (_existingImageUrls.isNotEmpty) ...[
            const Text('Existing Photos'),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _existingImageUrls.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.network(
                      _existingImageUrls[index],
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _existingImageUrls.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          if (_selectedImages.isNotEmpty) ...[
            const Text('New Photos'),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.file(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class RoomData {
  String type = 'Single';
  double rentPerSeat = 0.0;
  int totalSeats = 1;
  int availableSeats = 1;
  Map<String, bool> facilities = {};

  RoomData();

  RoomData.fromRoom(Room room) {
    type = room.type;
    rentPerSeat = room.rentPerSeat;
    totalSeats = room.totalSeats;
    availableSeats = room.availableSeats;
    facilities = Map.from(room.facilities);
  }
}

