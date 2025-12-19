import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../featureflags/feature_flags.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'side_menu.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

enum UnitSystem { metric, imperial }

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalWeightController = TextEditingController();

  String? _selectedGender;
  File? _profileImage;

  int? _selectedBirthDay;
  int? _selectedBirthMonth;
  int? _selectedBirthYear;

  String? _mainFocus;
  String? _activityIntensity;

  final _editProfileFormKey = GlobalKey<FormState>();
  UnitSystem _selectedUnitSystem = UnitSystem.imperial;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final profile = userProvider.profile;
      
      if (profile != null) {
        // Load name
        if (profile.name != null && _nameController.text.isEmpty) {
          _nameController.text = profile.name!;
        }
        
        // Load gender
        if (profile.gender != null) {
          _selectedGender = profile.gender;
        }
        
        // Load date of birth
        if (profile.dateOfBirth != null) {
          _selectedBirthDay = profile.dateOfBirth!.day;
          _selectedBirthMonth = profile.dateOfBirth!.month;
          _selectedBirthYear = profile.dateOfBirth!.year;
        }
        
        // Load height (backend uses inches)
        if (profile.heightIn != null && _heightController.text.isEmpty) {
          _heightController.text = profile.heightIn.toString();
          _selectedUnitSystem = UnitSystem.imperial;
        }
        
        // Load weight (backend uses pounds)
        if (profile.weightLb != null && _weightController.text.isEmpty) {
          _weightController.text = profile.weightLb.toString();
          _selectedUnitSystem = UnitSystem.imperial;
        }
        
        // Load main focus
        if (profile.mainFocus != null) {
          _mainFocus = profile.mainFocus;
        }
        
        // Load fitness level as activity intensity
        if (profile.fitnessLevel != null) {
          _activityIntensity = profile.fitnessLevel;
        }
        
        // Trigger rebuild to reflect updated state
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

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
    if (!_editProfileFormKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating profile...')),
    );

    final request = http.MultipartRequest('PUT', Uri.parse(ApiService.me()));

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
      return;
    }

    request.headers['Authorization'] = 'Bearer $token';

    // Format date as YYYY-MM-DD (matching database format)
    final dateOfBirth = DateTime(_selectedBirthYear!, _selectedBirthMonth!, _selectedBirthDay!);
    final dobString = '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}';

    request.fields['name'] = _nameController.text;
    request.fields['dob'] = dobString;
    request.fields['gender'] = _selectedGender!;
    request.fields['unit_system'] = _selectedUnitSystem.name;
    request.fields['height'] = _heightController.text;
    request.fields['weight'] = _weightController.text;
    request.fields['goal_weight'] = _goalWeightController.text;
    request.fields['main_focus'] = _mainFocus!;
    request.fields['activity_intensity'] = _activityIntensity!;

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        String errorMessage = 'Failed to update profile.';
        try {
          final responseBody = json.decode(response.body);
          errorMessage = responseBody['message'] ?? errorMessage;
        } catch (e) {
          // Response is not JSON, use status code as error
          errorMessage = 'Server returned error ${response.statusCode}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
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

  Widget _buildDropdown({
    required String hint,
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      style: const TextStyle(color: Colors.white),
      dropdownColor: Colors.grey.shade800,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFBBF18))),
        errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.toString()))).toList(),
      onChanged: onChanged,
      validator: (val) {
        if (val == null) {
          return '';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      menuMaxHeight: 300,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SideMenu(currentScreen: 'Edit Profile'),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.lexend(color: const Color(0xFFFBBF18)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFBBF18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.orange,
            height: 4.0,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: Form(
        key: _editProfileFormKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
                
                // Profile Picture
                const SizedBox(height: 20),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C2C2C),
                    foregroundColor: const Color(0xFFFBBF18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Choose Profile Picture'),
                ),
                const SizedBox(height: 30),

                // Name Input
                Text(
                  'Personal Information',
                  style: GoogleFonts.lexend(
                    color: const Color(0xFFFBBF18),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF2C2C2C),
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFBBF18)),
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
                    final nameRegExp = RegExp(r"^[a-zA-Z\s'-]+$");
                    if (!nameRegExp.hasMatch(value)) {
                      return 'Name can only contain letters and spaces';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Date of Birth
                Text(
                  'Date of Birth',
                  style: GoogleFonts.kanit(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: _buildDropdown(
                        hint: 'Month',
                        value: _selectedBirthMonth,
                        items: List.generate(12, (i) => i + 1),
                        onChanged: (val) => setState(() => _selectedBirthMonth = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 1,
                      child: _buildDropdown(
                        hint: 'Day',
                        value: _selectedBirthDay,
                        items: List.generate(31, (i) => i + 1),
                        onChanged: (val) => setState(() => _selectedBirthDay = val),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 2,
                      child: _buildDropdown(
                        hint: 'Year',
                        value: _selectedBirthYear,
                        items: List.generate(88, (i) => DateTime.now().year - 13 - i), // Minimum age: 13, maximum age: 100
                        onChanged: (val) => setState(() => _selectedBirthYear = val),
                      ),
                    ),
                  ],
                ),
                FormField<bool>(
                  initialValue: true,
                  validator: (_) {
                    if (_selectedBirthYear == null || _selectedBirthMonth == null || _selectedBirthDay == null) {
                      return 'Please select a full date of birth.';
                    }
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
                    fillColor: Color(0xFF2C2C2C),
                    labelText: 'Gender',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFBBF18)),
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
                        (gender) => DropdownMenuItem(value: gender, child: Text(gender)),
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
                const SizedBox(height: 30),

                // Physical Measurements Section
                Text(
                  'Physical Measurements',
                  style: GoogleFonts.lexend(
                    color: const Color(0xFFFBBF18),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Unit System
                SegmentedButton<UnitSystem>(
                  segments: const <ButtonSegment<UnitSystem>>[
                    ButtonSegment<UnitSystem>(
                      value: UnitSystem.imperial,
                      label: Text('Imperial (in / lb)'),
                    ),
                    ButtonSegment<UnitSystem>(
                      value: UnitSystem.metric,
                      label: Text('Metric (cm / kg)'),
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
                    selectedForegroundColor: Colors.black,
                    selectedBackgroundColor: const Color(0xFFFBBF18),
                  ),
                ),
                const SizedBox(height: 20),

                // Height
                TextFormField(
                  controller: _heightController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    labelText: _selectedUnitSystem == UnitSystem.metric
                        ? 'Height (cm)'
                        : 'Height (in)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFBBF18)),
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

                // Weight
                TextFormField(
                  controller: _weightController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    labelText: _selectedUnitSystem == UnitSystem.metric
                        ? 'Weight (kg)'
                        : 'Weight (lb)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFBBF18)),
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
                const SizedBox(height: 20),

                // Goal Weight
                TextFormField(
                  controller: _goalWeightController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    labelText: 'Goal Weight (${_selectedUnitSystem == UnitSystem.metric ? "kg" : "lb"})',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFBBF18)),
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
                const SizedBox(height: 30),

                // Fitness Goals Section
                Text(
                  'Fitness Goals',
                  style: GoogleFonts.lexend(
                    color: const Color(0xFFFBBF18),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Main Focus
                DropdownButtonFormField<String>(
                  initialValue: _mainFocus,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey.shade800,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF2C2C2C),
                    labelText: 'Main Focus',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFBBF18)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  items: ['Strength', 'Cardio']
                      .map(
                        (focus) => DropdownMenuItem(value: focus, child: Text(focus)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _mainFocus = value),
                  validator: (value) =>
                      value == null ? 'Please select a main focus' : null,
                ),
                const SizedBox(height: 20),

                // Activity Intensity
                DropdownButtonFormField<String>(
                  initialValue: _activityIntensity,
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey.shade800,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF2C2C2C),
                    labelText: 'Desired Activity Intensity',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFFBBF18)),
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
                const SizedBox(height: 40),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF18),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}