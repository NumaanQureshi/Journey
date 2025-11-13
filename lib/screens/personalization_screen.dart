import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';
import '../featureflags/feature_flags.dart';
import '../authentication/authentication.dart';
import 'package:flutter/foundation.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

enum UnitSystem { metric, imperial }

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final AuthService _authService = AuthService();
  // Controllers for text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalWeightController = TextEditingController();

  // For gender selection
  String? _selectedGender;

  // For profile picture storage (optional)
  File? _profileImage;

  // For DOB dropdowns
  int? _selectedBirthDay;
  int? _selectedBirthMonth;
  int? _selectedBirthYear;

  String? _mainFocus;
  String? _activityIntensity;

  // Form keys for validation
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _healthInfoFormKey = GlobalKey<FormState>();
  final _planningFormKey = GlobalKey<FormState>();

  UnitSystem _selectedUnitSystem = UnitSystem.metric;

  final List<String> _promptTitles = [
    'Personal Info',
    'Health Info',
    'Planning',
  ];

  String get _baseUrl {
    const String path = '/api/auth/me';
    if (kIsWeb) {
      // For web browsers
      return 'http://127.0.0.1:5000$path';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // For Android emulators
      return 'http://10.0.2.2:5000$path';
    }
    // For iOS simulators and other platforms
    return 'http://localhost:5000$path';
  }

  // dispose info after done.
  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
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

  Future<void> _submitProfile() async {
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating profile...')),
    );

    // 1. Construct the request
    final request = http.MultipartRequest('PUT', Uri.parse(_baseUrl));

    // 2. Add headers (including authentication)
    String? token;
    if (kSkipAuthentication) {
      token = kDebugAuthToken;
    } else {
      token = await _authService.getToken();
    }

    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error. Please log in again.')),
      );
      return; // Stop the submission
    }

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';

    // // 3. Add the image file if one was selected
    // if (_profileImage != null) {
    //   request.files.add(
    //     await http.MultipartFile.fromPath(
    //       'profile_picture', // This key must match what your backend expects
    //       _profileImage!.path,
    //     ),
    //   );
    // }

    // 4. Add the text fields
    final dob = DateTime(_selectedBirthYear!, _selectedBirthMonth!, _selectedBirthDay!).toIso8601String();

    request.fields['name'] = _nameController.text;
    request.fields['dob'] = dob;
    request.fields['gender'] = _selectedGender!;
    request.fields['unit_system'] = _selectedUnitSystem.name; // 'metric' or 'imperial'
    request.fields['height'] = _heightController.text;
    request.fields['weight'] = _weightController.text;
    request.fields['goal_weight'] = _goalWeightController.text;
    request.fields['main_focus'] = _mainFocus!;
    request.fields['activity_intensity'] = _activityIntensity!;

    try {
      // 5. Send the request
      final streamedResponse = await request.send();

      // 6. Get the response
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      // Hide the "Updating..." snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // 7. Handle the response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Navigate to the home screen on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Show an error message
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? 'Failed to update profile.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}. $errorMessage')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
            backgroundImage: _profileImage != null
                ? FileImage(_profileImage!)
                : null,
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
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(150, 0, 0, 0),
              labelText: 'Name',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
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

          // Date of Birth Dropdowns
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Date of Birth',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdown(
                  hint: 'Month',
                  value: _selectedBirthMonth,
                  items: List.generate(12, (i) => i + 1),
                  onChanged: (val) => setState(() => _selectedBirthMonth = val),
                ),
              ),
              const SizedBox(width: 12),
              // Day Dropdown
              Expanded(
                flex: 1,
                child: _buildDropdown(
                  hint: 'Day',
                  value: _selectedBirthDay,
                  items: List.generate(31, (i) => i + 1),
                  onChanged: (val) => setState(() => _selectedBirthDay = val),
                ),
              ),
              const SizedBox(width: 12),
              // Year Dropdown
              Expanded(
                flex: 2,
                child: _buildDropdown(
                  hint: 'Year',
                  value: _selectedBirthYear,
                  items: List.generate(DateTime.now().year - 1899, (i) => DateTime.now().year - i),
                  onChanged: (val) => setState(() => _selectedBirthYear = val),
                ),
              ),
            ],
          ),
          // Combined validator for all three date fields
          FormField<bool>(
            initialValue: true,
            validator: (_) {
              if (_selectedBirthYear == null || _selectedBirthMonth == null || _selectedBirthDay == null) {
                return 'Please select a full date of birth.';
              }
              // Check for valid date (e.g., not Feb 30)
              try {
                final date = DateTime(_selectedBirthYear!, _selectedBirthMonth!, _selectedBirthDay!);
                if (date.year != _selectedBirthYear || date.month != _selectedBirthMonth || date.day != _selectedBirthDay) {
                  return 'Invalid date selected.';
                }
              } catch (e) {
                return 'Invalid date selected.';
              }
              return null;
            },
            builder: (state) {
              if (state.hasError) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 20),

          // Gender Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedGender,
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey.shade800,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(150, 0, 0, 0),
              labelText: 'Gender',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
            ),
            items: ['Male', 'Female', 'Other', 'Prefer not to say']
                .map(
                  (gender) =>
                      DropdownMenuItem(value: gender, child: Text(gender)),
                )
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

  // Reusable dropdown builder for DOB
  Widget _buildDropdown({
    required String hint,
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      hint: Text(hint, style: const TextStyle(color: Colors.white70)),
      style: const TextStyle(color: Colors.white),
      dropdownColor: Colors.grey.shade800,
      decoration: const InputDecoration(
        filled: true,
        fillColor: Color.fromARGB(150, 0, 0, 0),        
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList(),
      onChanged: onChanged,
      validator: (val) {
        // Individual validation is handled by the combined FormField below the Row
        if (val == null) {
          // This message won't be shown, but it triggers the error state
          return '';
        }
        return null;
      },
      // Hide the default error text to use our custom one
      autovalidateMode: AutovalidateMode.onUserInteraction,
      menuMaxHeight: 300,
    );
  }

  // Build Step 2: Health Info (Height, Weight, Unit System)
  Widget _buildHealthInfoStep() {
    return Form(
      key: _healthInfoFormKey,
      child: Column(
        children: [
          SegmentedButton<UnitSystem>(
            segments: const <ButtonSegment<UnitSystem>>[
              ButtonSegment<UnitSystem>(
                value: UnitSystem.metric,
                label: Text('Metric (cm / kg)'),
              ),
              ButtonSegment<UnitSystem>(
                value: UnitSystem.imperial,
                label: Text('Imperial (in / lb)'),
              ),
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
          TextFormField(
            controller: _heightController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(150, 0, 0, 0),
              labelText: _selectedUnitSystem == UnitSystem.metric
                  ? 'Height (cm)'
                  : 'Height (in)',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.trim().isEmpty || double.tryParse(v) == null)
                ? 'Enter a valid height'
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _weightController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(150, 0, 0, 0),
              labelText: _selectedUnitSystem == UnitSystem.metric
                  ? 'Weight (kg)'
                  : 'Weight (lb)',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.trim().isEmpty || double.tryParse(v) == null)
                ? 'Enter a valid weight'
                : null,
          ),
        ],
      ),
    );
  }

  // Build Step 3: Planning Info
  Widget _buildPlanningInfoStep() {
    return Form(
      key: _planningFormKey,
      child: Column(
        children: [
          // Main Focus Dropdown
          DropdownButtonFormField<String>(
            initialValue: _mainFocus,
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey.shade800,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(150, 0, 0, 0),
              labelText: 'Main Focus',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
            ),
            items:
                [
                      'Strength',
                      'Cardio',
                    ]
                    .map(
                      (focus) =>
                          DropdownMenuItem(value: focus, child: Text(focus)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => _mainFocus = value),
            validator: (value) =>
                value == null ? 'Please select a main focus' : null,
          ),
          const SizedBox(height: 20),

          // Goal Weight Input
          TextFormField(
            controller: _goalWeightController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(150, 0, 0, 0),
              labelText:
                  'Goal Weight (${_selectedUnitSystem == UnitSystem.metric ? "kg" : "lb"})',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                (v == null || v.trim().isEmpty || double.tryParse(v) == null)
                ? 'Enter a valid goal weight'
                : null,
          ),
          const SizedBox(height: 20),

          // Desired Activity Intensity Dropdown
          DropdownButtonFormField<String>(
            initialValue: _activityIntensity,
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey.shade800,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(150, 0, 0, 0),
              labelText: 'Desired Activity Intensity',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
              ),
            ),
            items: ['Light', 'Moderate', 'Intense']
                .map(
                  (intensity) => DropdownMenuItem(
                    value: intensity,
                    child: Text(intensity),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _activityIntensity = value),
            validator: (value) =>
                value == null ? 'Please select an intensity level' : null,
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
          curve: Curves.ease,
        );
      } else {
        _submitProfile();
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset('assets/images/blur_bg_dark.png', fit: BoxFit.cover),
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
                title: 'Personal Info',
                child: _buildPersonalInfoStep(),
              ),

              // Step 2: Health Info (placeholder for now)
              _buildStep(
                title: 'Health Info',
                child: _buildHealthInfoStep(),
              ),
              _buildStep(
                title: 'Planning',
                child: _buildPlanningInfoStep(),
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
                        curve: Curves.ease,
                      );
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  const SizedBox(),
                ElevatedButton(
                  onPressed: _goToNextPage, // Updated button to use validation
                  child: Text(
                    _currentPage < _promptTitles.length - 1 ? 'Next' : 'Finish',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
