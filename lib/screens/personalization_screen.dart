import 'package:flutter/material.dart';
import 'package:journey_application/screens/home_screen.dart';

class PersonalizationScreen extends StatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _promptTitles = [
    'Personal Info',
    'Health Info',
    'Planning',
  ];

  // Dispose of info after done with it.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  // TODO: @@TAWHIDUL - Title of the Section goes first, then you can return a Widget that will build text boxes.

  // For example, Widget _buildStep(title: 'Step 1: Personal Info', child: const Text('Fields for personal info go here.', style: TextStyle(color: Colors.white70)))
  Widget _buildStep({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
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
          SizedBox.expand(
            child: Image.asset(
              'assets/images/blur_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildStep(
                title: 'Step 1: Personal Info', 
                child: const Text('ADD FIELDS FOR PERSONAL INFO (Name, Profile Picture, DOB, Gender)', 
                style: TextStyle(color: Colors.white70))
              ),
              _buildStep(
                title: 'Step 2: Health Info', 
                child: const Text('ADD FIELDS FOR HEALTH INFO (Height, Weight)', 
                style: TextStyle(color: Colors.white70))
              ),
              _buildStep(
                title: 'Step 3: Planning', 
                child: const Text('ADD FIELDS FOR PLANNING INFO (Main Focus, Goal Weight, Desired Activity Intensity)', 
                style: TextStyle(color: Colors.white70))
              ),
            ],
          ),
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
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    },
                    child: const Text('Back', style: TextStyle(color: Colors.white)),
                  )
                else
                  const SizedBox(), // Keep spacing consistent
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _promptTitles.length - 1) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    } else {
                      // if personalization done, go to Home.
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    }
                  },
                  child: Text(_currentPage < _promptTitles.length - 1 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
