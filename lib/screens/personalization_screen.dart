import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

enum UnitSystem { metric, imperial }

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Controllers for text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // For gender selection
  String? _selectedGender;

  // For profile picture storage (optional)
  File? _profileImage;

  // Form keys for validation
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _healthInfoFormKey = GlobalKey<FormState>();
  final _planningFormKey = GlobalKey<FormState>();

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  UnitSystem _selectedUnitSystem = UnitSystem.metric;

  final List<String> _promptTitles = [
    'Personal Info',
    'Health Info',
    'Planning',
  ];

  // dispose info after done.
  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Pick an image from gallery for profile picture
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Reusable step builder
  Widget _buildStep({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            child,
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Build Step 1: Personal Info (Name, Profile Picture, DOB, Gender)
  // Need implement backend logic to save information and display it
  Widget _buildPersonalInfoStep() {
    return Form(
      key: _personalInfoFormKey, // Added form key for validation
      child: Column(
        children: [
          // Profile Picture Picker (optional)
          CircleAvatar(
            radius: 50,
            backgroundImage:
                _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null
                ? const Icon(Icons.person, size: 50, color: Colors.white70)
                : null,
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Choose Profile Picture'),
          ),
          const SizedBox(height: 30),

          // Name Input
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              filled: true,
              fillColor: Colors.white70,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your name';
              }
              // Only allow letters, spaces, hyphens, and apostrophes
              final nameRegExp = RegExp(r"^[a-zA-Z\s'-]+$");
              if (!nameRegExp.hasMatch(value)) {
                return 'Name can only contain letters and spaces';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Birthday Input (MM/DD/YYYY) with stricter validation
          TextFormField(
            controller: _dobController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Birthday (MM/DD/YYYY)',
              filled: true,
              fillColor: Colors.white70,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your birthday';
              }

              // Allow only digits and slashes
              final validChars = RegExp(r'^[0-9/]+$');
              if (!validChars.hasMatch(value)) {
                return 'Use only numbers and slashes';
              }

              try {
                final parts = value.split('/');
                if (parts.length != 3) return 'Enter date as MM/DD/YYYY';

                final month = int.parse(parts[0]);
                final day = int.parse(parts[1]);
                final year = int.parse(parts[2]);

                // Month and day must be valid (not zero)
                if (month < 1 || month > 12) return 'Enter a valid month (1-12)';
                if (day < 1 || day > 31) return 'Enter a valid day (1-31)';
                if (year < 1930 || year > DateTime.now().year) {
                  return 'Enter a valid year';
                }

                // Check invalid combinations like 02/30/2020
                final date = DateTime(year, month, day);
                if (date.month != month || date.day != day) return 'Invalid date';

              } catch (_) {
                return 'Enter a valid date';
              }

              return null;
            },
          ),
          const SizedBox(height: 20),

          // Gender Dropdown
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              filled: true,
              fillColor: Colors.white70,
              border: OutlineInputBorder(),
            ),
            items: ['Male', 'Female', 'Other', 'Prefer not to say']
                .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a gender';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Method to handle validation and move to next page
  void _goToNextPage() {
    bool canProceed = false;

    if (_currentPage == 0) {
      canProceed = _personalInfoFormKey.currentState?.validate() ?? false;
      // Profile image is optional, no check needed
    } else if (_currentPage == 1) {
      canProceed = _healthInfoFormKey.currentState?.validate() ?? false;
    } else if (_currentPage == 2) {
      canProceed = _planningFormKey.currentState?.validate() ?? false;
    }

    if (canProceed) {
      if (_currentPage < _promptTitles.length - 1) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease);
      } else {
        // When finished, go to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // Optional: scroll to top to show errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_promptTitles[_currentPage]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/blur_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // PageView for multi-step personalization
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // Step 1: Personal Info
              _buildStep(
                title: 'Step 1: Personal Info',
                child: _buildPersonalInfoStep(),
              ),

              // Step 2: Health Info (placeholder for now)
              _buildStep(
                title: 'Step 2: Health Info', 
                child: Column(
                  children: [
                    SegmentedButton<UnitSystem>(
                      segments: const <ButtonSegment<UnitSystem>>[
                        ButtonSegment<UnitSystem>(
                            value: UnitSystem.metric,
                            label: Text('Metric (cm / kg)')),
                        ButtonSegment<UnitSystem>(
                            value: UnitSystem.imperial,
                            label: Text('Imperial (in / lb)')),
                      ],
                      selected: <UnitSystem>{_selectedUnitSystem},
                      onSelectionChanged: (Set<UnitSystem> newSelection) {
                        setState(() {
                          _selectedUnitSystem = newSelection.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: Colors.white,
                        selectedForegroundColor: Colors.white,
                        selectedBackgroundColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _heightController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: _selectedUnitSystem == UnitSystem.metric ? 'Height (cm)' : 'Height (in)',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _weightController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: _selectedUnitSystem == UnitSystem.metric ? 'Weight (kg)' : 'Weight (lb)',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              _buildStep(
                title: 'Step 3: Planning',
                child: Form(
                  key: _planningFormKey, // Added form key for validation
                  child: const Text(
                    'ADD FIELDS FOR PLANNING INFO (Main Focus, Goal Weight, Desired Activity Intensity)',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),

          // Navigation buttons
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease);
                    },
                    child: const Text('Back', style: TextStyle(color: Colors.white)),
                  )
                else
                  const SizedBox(),
                ElevatedButton(
                  onPressed: _goToNextPage, // Updated button to use validation
                  child: Text(
                      _currentPage < _promptTitles.length - 1 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}