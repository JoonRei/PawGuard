import 'dart:convert';
import 'package:flutter/material.dart';

class PetDetailsPage extends StatelessWidget {
  final Map<String, dynamic> pet;

  const PetDetailsPage({Key? key, required this.pet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Light iOS-style background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          pet['name'] ?? 'Pet Details',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView( // Allow scrolling for entire body
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildImageSection(),
            const SizedBox(height: 20),

            // General Info Section
            _buildSection(
              title: 'General Information',
              content: [
                _buildDetailRow('Type', pet['type'], Icons.pets),
                _buildDetailRow('Breed', pet['breed'], Icons.category),
                _buildDetailRow('Age', '${pet['age']} ${pet['ageUnit']}', Icons.cake),
                _buildDetailRow('Gender', pet['gender'], Icons.male),
                _buildDetailRow('Size', pet['size'], Icons.straighten),
                _buildDetailRow('Activity Level', pet['activityLevel'], Icons.sports),
              ],
            ),
            const SizedBox(height: 16),

            // Medical Info Section
            _buildSection(
              title: 'Medical Information',
              content: [
                _buildDetailRow('Vaccinated', pet['vaccinated'] == true ? 'Yes' : 'No', Icons.health_and_safety),
                _buildDetailRow('Spayed/Neutered', pet['spayed'] == true ? 'Yes' : 'No', Icons.medical_services),
                _buildDetailRow('Medical History', pet['medicalHistory'], Icons.history),
                if (pet['vaccines'] != null && pet['vaccines'].isNotEmpty)
                  _buildDetailRow('Vaccines', pet['vaccines'].join(', '), Icons.vaccines),
              ],
            ),
            const SizedBox(height: 16),

            // Shelter Info Section
            _buildSection(
              title: 'Shelter Information',
              content: [
                _buildDetailRow('Organization', pet['organization'], Icons.home_work),
                _buildDetailRow('Duration at Shelter', '${pet['shelterDuration']} ${pet['shelterDurationUnit']}', Icons.access_time),
                _buildDetailRow('Origin', pet['origin'], Icons.location_on),
                _buildDetailRow('Past Experience', pet['pastExperience'], Icons.timeline),
              ],
            ),
            const SizedBox(height: 16),

            // Description Section
            if (pet['description'] != null)
              _buildSection(
                title: 'Description',
                content: [
                  Text(
                    pet['description'],
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    softWrap: true, // Allow text to wrap
                    overflow: TextOverflow.visible, // Ensure long text continues to the next line
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: pet['images'] != null && pet['images'].isNotEmpty
          ? Image.memory(
              base64Decode(pet['images'][0].split(',')[1]),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 250,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 250,
      color: Colors.grey.shade300,
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }

  Widget _buildSection({required String title, required List<Widget> content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...content,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures label and value are on opposite sides
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          // Title - fixed width and doesn't wrap
          SizedBox(
            width: 120, // Set a fixed width for the label (title)
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis, // Truncate the label if it's too long
            ),
          ),
          const SizedBox(width: 8),
          // Value - aligned to the right and can wrap to next line
          Expanded(
            child: Text(
              value ?? 'Unknown',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              softWrap: true, // Allow value to wrap
              overflow: TextOverflow.visible, // Ensure value continues onto next line if needed
              textAlign: TextAlign.right, // Align value to the right
            ),
          ),
        ],
      ),
    );
  }
}
