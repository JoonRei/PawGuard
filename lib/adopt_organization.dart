import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:convert';

import 'package:pawguard/manage_pets.dart';

class AdoptOrganizationPage extends StatefulWidget {
  const AdoptOrganizationPage({Key? key}) : super(key: key);

  @override
  _AdoptOrganizationPageState createState() => _AdoptOrganizationPageState();
}

class _AdoptOrganizationPageState extends State<AdoptOrganizationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _otherTypeController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  TextEditingController _disabilityDescriptionController =
      TextEditingController();
  final TextEditingController _shelterDurationController =
      TextEditingController();
  final TextEditingController _pastExperienceController =
      TextEditingController();
  final TextEditingController _medicalHistoryController =
      TextEditingController();

  final primaryColor = const Color(0xFFEF6C00); // Deep Orange
  final secondaryColor = const Color(0xFFFF9800); // Orange
  final backgroundColor = const Color.fromARGB(255, 255, 255, 255);
  final errorColor = const Color(0xFFB71C1C); // Error Red
  final surfaceColor = Colors.white;
  final cardColor = Colors.white;
  final double borderRadius = 16.0;
  final double spacing = 20.0;

  String _selectedType = 'Dog';
  String _selectedGender = 'Male';
  String _selectedAgeUnit = 'Years';
  String _selectedShelterDurationUnit = 'Months';
  bool _spayed = false;
  bool _vaccinated = false;
  int _currentStep = 0;
  List<String> _selectedVaccines = [];
  List<File?> _images = List.generate(5, (index) => null);
  final picker = ImagePicker();
  bool _isDisabled = false;

  final List<String> _vaccines = [
    'Distemper',
    'Rabies',
    'Parvo',
    'Canine Influenza',
    'Feline Leukemia',
    'DAPPv',
    'Bordetella',
    'FVRCP',
    'FELV',
    'FVRCP booster',
    'FELV booster'
  ];

  String? selectedActivity; // Variable to hold the selected Description option
  String? selectedSize;

  final List<String> activityOptions = [
    'Playful',
    'Calm',
    'Energetic',
    'Loving',
  ];

  final List<String> sizeOptions = [
    'Small',
    'Medium',
    'Large',
  ];

  @override
  void initState() {
    super.initState();
    _populateOrganizationField();
  }

// Fetch the logged-in user's organization name from Firestore
  Future<void> _populateOrganizationField() async {
    try {
      // Get the currently logged-in user
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the user's document from Firestore
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Check if the document exists and has a `name` field
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          final String? organizationName =
              data['name']; // Replace `name` with your actual field

          if (organizationName != null && organizationName.isNotEmpty) {
            // Set the organization's name in the text field
            setState(() {
              _organizationController.text = organizationName;
            });
          } else {
            _organizationController.text = 'No Organization Name Set';
          }
        } else {
          _organizationController.text = 'No Organization Name Set';
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching organization name: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Add Pet for Adoption',
    style: TextStyle(
      fontFamily: 'San Francisco', // iOS-like font
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color.fromARGB(255, 255, 255, 255),
    ),
  ),
  backgroundColor: Colors.orange,
  automaticallyImplyLeading: false,
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 16.0), // Add padding to the right
      child: IconButton(
        icon: const Icon(Icons.dashboard), // Pet management icon
        tooltip: 'Manage Added Pets',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ManagePetsPage(), // Replace with your page
            ),
          );
        },
      ),
    ),
  ],
),

      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: Colors.orange,
              ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step; // Set the tapped step as the current step
            });
          },
          onStepContinue: () {
            if (_currentStep < _buildSteps().length - 1) {
              setState(() => _currentStep += 1);
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          controlsBuilder: (context, ControlsDetails details) {
            final isLastStep = _currentStep == _buildSteps().length - 1;
            return Row(
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: details.onStepCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.grey.shade300, // Neutral color for Back button
                      foregroundColor: Colors.black87, // Text color
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Highlighted color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(isLastStep ? 'Submit' : 'Next'),
                ),
              ],
            );
          },
          steps: _buildSteps(),
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text(
          'Pet Photo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: const Text('Add cute photo of the pet'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload high-quality photo to attract potential adopters.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _buildImageSection(),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text(
          'Basic Information',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: const Text('Provide the pet\'s basic details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This information will help adopters understand the pet.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _buildBasicInfoSection(),
          ],
        ),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: const Text('Add specific details about the pet'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Include details like breed, age, and size to give a better idea.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _buildDetailsSection(),
          ],
        ),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Text(
          'Health',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: const Text('Share health information'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add medical history, vaccination status, and other health info.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _buildHealthSection(),
          ],
        ),
        isActive: _currentStep >= 3,
      ),
      Step(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: const Text('Describe the pet\'s background'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Include information about the pet\'s origin and experiences.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            _buildHistorySection(),
          ],
        ),
        isActive: _currentStep >= 4,
      ),
    ];
  }

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Pet Photo', Icons.photo_library),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => _pickImage(0),
              child: Container(
                width: 140, // Reduced size for a neater appearance
                height: 140,
                decoration: BoxDecoration(
                  color:
                      Colors.orange.withOpacity(0.1), // Light orange background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _images[0] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _images[0]!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Add Photo',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Information', Icons.info_outline),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            label: 'Pet Name',
            icon: Icons.pets,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _organizationController,
            label: 'Organization',
            icon: Icons.business,
            readOnly: true, // This makes the field read-only
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            'Pet Type',
            _selectedType,
            ['Dog', 'Cat'],
            (value) => setState(() => _selectedType = value!),
          ),
          if (_selectedType == 'Other') ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _otherTypeController,
              label: 'Specify Pet Type',
              icon: Icons.help_outline,
            ),
          ],
          const SizedBox(height: 16),
          _buildDropdownField(
            'Gender',
            _selectedGender,
            ['Male', 'Female'],
            (value) => setState(() => _selectedGender = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Pet Details', Icons.pets),
          const SizedBox(height: 20),

          // Breed Text Field
          _buildTextField(
            controller: _breedController,
            label: 'Breed',
          ),
          const SizedBox(height: 16),

          // Age Input Section
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      // Trigger a rebuild on age change to update the unit text
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  value: _selectedAgeUnit,
                  items: _getAgeUnits(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAgeUnit = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Activity Level Section
          const Text(
            'Activity Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityButtons(),
          const SizedBox(height: 16),

          // Size Section
          const Text(
            'Size',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSizeButtons(),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getAgeUnits() {
    final int age = int.tryParse(_ageController.text) ?? 0;

    return [
      DropdownMenuItem(
        value: 'Months',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              age == 1 ? 'Month' : 'Months',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'Years',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              age == 1 ? 'Year' : 'Years',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildActivityButtons() {
    return Wrap(
      spacing: 8.0, // Horizontal space between buttons
      runSpacing: 8.0, // Vertical space between rows of buttons
      children: activityOptions.map((option) {
        final isSelected = selectedActivity == option;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedActivity = isSelected ? null : option; // Toggle selection
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF9800) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFFFF9800) : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeButtons() {
    return Wrap(
      spacing: 8.0, // Horizontal space between buttons
      runSpacing: 8.0, // Vertical space between rows of buttons
      children: sizeOptions.map((option) {
        final isSelected = selectedSize == option;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedSize = isSelected ? null : option; // Toggle selection
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF9800) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFFFF9800) : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Health Information', Icons.medical_services),
          const SizedBox(height: 20),

          // Spayed/Neutered Switch
          _buildSwitchTile(
            'Spayed/Neutered',
            _spayed,
            (value) => setState(() => _spayed = value),
          ),
          const SizedBox(height: 5),

          // Vaccinated Switch
          _buildSwitchTile(
            'Vaccinated',
            _vaccinated,
            (value) => setState(() => _vaccinated = value),
          ),

          if (_vaccinated) ...[
            const SizedBox(height: 5),
            const Text(
              'Select Vaccines',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Updated Vaccine Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _vaccines.map((vaccine) {
                final isSelected = _selectedVaccines.contains(vaccine);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedVaccines.remove(vaccine);
                      } else {
                        _selectedVaccines.add(vaccine);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16), // Uniform padding
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withOpacity(0.9)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : Colors.grey.shade300, // Dynamic border color
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Text(
                      vaccine,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 5),

          // **Disability Section After Vaccines**
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Is this pet disabled?',
            _isDisabled,
            (value) => setState(() => _isDisabled = value),
          ),

          if (_isDisabled) ...[
            const SizedBox(height: 5),
            const Text(
              'What disability does the pet have?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: _disabilityDescriptionController,
              label: 'Disability Description',
              icon: null, // Optional icon for this text field
              maxLines: 3,
            ),
          ],

          const SizedBox(height: 16),

          // Medical History Text Field
          _buildTextField(
            controller: _medicalHistoryController,
            label: 'Medical History',
            icon: null, // Removed the icon for a cleaner look
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Background History', Icons.history),
          const SizedBox(height: 20),

          // Origin/Background Field
          _buildTextField(
            controller: _originController,
            label: 'Origin/Background',
            icon: null, // Removed the icon for a cleaner look
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // How Long in Shelter Section
          const Text(
            'How Long in Shelter?', // Updated text
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _shelterDurationController,
            decoration: InputDecoration(
              labelText: 'Enter duration (e.g., 6)', // Helpful hint for input
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.orange, width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                // Trigger rebuild to update unit dynamically
              });
            },
          ),
          const SizedBox(height: 16),

// Duration Unit Dropdown
          const Text(
            'Duration Unit', // Updated text
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedShelterDurationUnit,
            items: _getDurationUnits(),
            onChanged: (value) {
              setState(() {
                _selectedShelterDurationUnit = value!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.orange, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Past Experiences Field
          _buildTextField(
            controller: _pastExperienceController,
            label: 'Past Experiences',
            icon: null, // Removed the icon for a cleaner look
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDurationUnits() {
    final int duration = int.tryParse(_shelterDurationController.text) ?? 0;

    return [
      DropdownMenuItem(
        value: 'Weeks',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              duration == 1 ? 'Week' : 'Weeks',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'Months',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              duration == 1 ? 'Month' : 'Months',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      DropdownMenuItem(
        value: 'Years',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              duration == 1 ? 'Year' : 'Years',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              readOnly: readOnly,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
        dropdownColor: const Color.fromARGB(255, 255, 255, 255),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        isExpanded: true,
        items: items.map((String item) {
          final bool isSelected = value == item;
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? primaryColor : Colors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: primaryColor, // Primary color for the active thumb
      activeTrackColor: primaryColor.withOpacity(0.4), // Softer active track
      inactiveThumbColor: Colors.grey.shade500, // Light grey for inactive thumb
      inactiveTrackColor:
          Colors.grey.shade300, // Softer grey for inactive track
      contentPadding: EdgeInsets.zero,
      tileColor: Colors.white, // Ensures a clean background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: value ? primaryColor : Colors.grey.shade400, // Dynamic border
          width: 1,
        ),
      ),
    );
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final tempDir = Directory.systemTemp;
        final targetPath =
            '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          pickedFile.path,
          targetPath,
          quality: 85,
          minWidth: 1024,
          minHeight: 1024,
        );

        if (compressedFile != null) {
          setState(() {
            _images[index] = File(compressedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    // Validation: Check if all required fields are filled
    List<String> errors = [];

    // Add validation for all required fields
    if (_nameController.text.trim().isEmpty) errors.add('Pet Name');
    if (_selectedType.trim().isEmpty) errors.add('Pet Type');
    if (_selectedGender.trim().isEmpty) errors.add('Gender');
    if (_breedController.text.trim().isEmpty) errors.add('Breed');
    if (_ageController.text.trim().isEmpty) errors.add('Age');
    if (_selectedAgeUnit.trim().isEmpty) errors.add('Age Unit');
    if (selectedActivity == null || selectedActivity!.trim().isEmpty) {
      errors.add('Activity Level');
    }
    if (selectedSize == null || selectedSize!.trim().isEmpty) {
      errors.add('Size');
    }
    if (_medicalHistoryController.text.trim().isEmpty) {
      errors.add('Medical History');
    }
    if (_originController.text.trim().isEmpty) {
      errors.add('Origin/Background');
    }
    if (_shelterDurationController.text.trim().isEmpty) {
      errors.add('How Long in Shelter?');
    }
    if (_selectedShelterDurationUnit.trim().isEmpty) {
      errors.add('Duration Unit');
    }
    if (_pastExperienceController.text.trim().isEmpty) {
      errors.add('Past Experiences ');
    }
    if (_images[0] == null) errors.add('Pet Photo');

    // Show errors if any field is invalid
    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Smooth corners
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.orange, size: 28), // Error icon
                const SizedBox(width: 8),
                const Text(
                  'Missing Fields',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: errors
                  .map((error) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle,
                              size: 8, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ))
                  .toList(),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );

      return; // Stop submission if validation fails
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Process images for upload (if any)
      final List<String> base64Images = await _processImagesForUpload();
      String finalType = _selectedType;
      if (_selectedType == 'Other') finalType = _otherTypeController.text;

      // Get the age and ageUnit from the input fields
      final int age = int.tryParse(_ageController.text) ?? 0;
      final String ageUnit = age == 1
          ? (_selectedAgeUnit == 'Years' ? 'Year' : 'Month')
          : (_selectedAgeUnit == 'Years' ? 'Years' : 'Months');

      // Get the shelter duration and unit dynamically
      final int shelterDuration =
          int.tryParse(_shelterDurationController.text) ?? 0;
      final String shelterDurationUnit = shelterDuration == 1
          ? (_selectedShelterDurationUnit == 'Years'
              ? 'Year'
              : _selectedShelterDurationUnit == 'Months'
                  ? 'Month'
                  : 'Week')
          : _selectedShelterDurationUnit;

      // Prepare disability data
      String? disabilityDescription;
      if (_isDisabled) {
        disabilityDescription = _disabilityDescriptionController.text.trim();
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection('animals').add({
        'name': _nameController.text,
        'type': finalType,
        'age': age.toString(),
        'ageUnit': ageUnit,
        'breed': _breedController.text,
        'gender': _selectedGender,
        'origin': _originController.text,
        'shelterDuration': shelterDuration.toString(),
        'shelterDurationUnit': shelterDurationUnit,
        'organization': _organizationController.text,
        'pastExperience': _pastExperienceController.text,
        'medicalHistory': _medicalHistoryController.text,
        'spayed': _spayed,
        'vaccinated': _vaccinated,
        'vaccines': _selectedVaccines,
        'activityLevel': selectedActivity,
        'size': selectedSize,
        'images': base64Images,
        'isDisabled': _isDisabled, // Add the disabled status
        'disabilityDescription': disabilityDescription,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.of(context).pop(); // Dismiss loading dialog

      // Reset the form after submission
      _clearForm();
      setState(() {
        _currentStep = 0; // Reset to the first step
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Smooth rounded corners
            ),
            backgroundColor: Colors.white,
            title: Column(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 48), // Success icon
                const SizedBox(height: 8),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Pet added successfully!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5, // Improved readability
              ),
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss success dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<String>> _processImagesForUpload() async {
    List<String> base64Images = [];
    for (var image in _images) {
      if (image != null) {
        List<int> imageBytes = await image.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        base64Images.add('data:image/jpeg;base64,$base64Image');
      }
    }
    return base64Images;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Pet profile has been successfully saved!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _ageController.clear();
    _breedController.clear();
    _otherTypeController.clear();
    _originController.clear();
    _shelterDurationController.clear();
    _pastExperienceController.clear();
    _medicalHistoryController.clear();
    setState(() {
      _selectedType = 'Dog';
      _selectedGender = 'Male';
      _selectedAgeUnit = 'Years';
      _selectedShelterDurationUnit = 'Months';
      _spayed = false;
      _vaccinated = false;
      _selectedVaccines = [];
      _images = List.generate(5, (index) => null);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _organizationController.dispose();
    _otherTypeController.dispose();
    _originController.dispose();
    _shelterDurationController.dispose();
    _pastExperienceController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }
}
