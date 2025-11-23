import 'package:flutter/material.dart';
import '../core/constants.dart';

class FilterSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterSheet({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          filters = {
                            'universities': <String>[],
                            'location': '',
                            'gender': '',
                            'minBudget': AppConstants.minBudget,
                            'maxBudget': AppConstants.maxBudget,
                            'roomTypes': <String>[],
                            'facilities': <String>[],
                          };
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Nearby Universities
                    _buildSectionTitle('Nearby Universities'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.universities.map((uni) {
                        final selected = (filters['universities'] as List<String>?)?.contains(uni) ?? false;
                        return FilterChip(
                          label: Text(uni),
                          selected: selected,
                          onSelected: (selected) {
                            setState(() {
                              final universities = List<String>.from(filters['universities'] ?? []);
                              if (selected) {
                                universities.add(uni);
                              } else {
                                universities.remove(uni);
                              }
                              filters['universities'] = universities;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Gender
                    _buildSectionTitle('Gender'),
                    Row(
                      children: AppConstants.genderOptions.map((gender) {
                        final selected = filters['gender'] == gender;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(gender),
                              selected: selected,
                              onSelected: (selected) {
                                setState(() {
                                  filters['gender'] = selected ? gender : '';
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Budget
                    _buildSectionTitle('Budget Range'),
                    RangeSlider(
                      values: RangeValues(
                        filters['minBudget']?.toDouble() ?? AppConstants.minBudget,
                        filters['maxBudget']?.toDouble() ?? AppConstants.maxBudget,
                      ),
                      min: AppConstants.minBudget,
                      max: AppConstants.maxBudget,
                      divisions: 45,
                      labels: RangeLabels(
                        'PKR ${((filters['minBudget'] ?? AppConstants.minBudget) as double).toInt()}',
                        'PKR ${((filters['maxBudget'] ?? AppConstants.maxBudget) as double).toInt()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          filters['minBudget'] = values.start;
                          filters['maxBudget'] = values.end;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Room Types
                    _buildSectionTitle('Room Types'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.roomTypes.map((type) {
                        final selected = (filters['roomTypes'] as List<String>?)?.contains(type) ?? false;
                        return FilterChip(
                          label: Text(type),
                          selected: selected,
                          onSelected: (selected) {
                            setState(() {
                              final roomTypes = List<String>.from(filters['roomTypes'] ?? []);
                              if (selected) {
                                roomTypes.add(type);
                              } else {
                                roomTypes.remove(type);
                              }
                              filters['roomTypes'] = roomTypes;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // Facilities
                    _buildSectionTitle('Facilities'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.facilities.map((facility) {
                        final selected = (filters['facilities'] as List<String>?)?.contains(facility) ?? false;
                        return FilterChip(
                          label: Text(facility),
                          selected: selected,
                          onSelected: (selected) {
                            setState(() {
                              final facilities = List<String>.from(filters['facilities'] ?? []);
                              if (selected) {
                                facilities.add(facility);
                              } else {
                                facilities.remove(facility);
                              }
                              filters['facilities'] = facilities;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              // Apply button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApplyFilters(filters);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

