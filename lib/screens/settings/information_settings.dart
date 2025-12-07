import 'package:flutter/material.dart';

class InformationSettingsPage extends StatelessWidget {
  const InformationSettingsPage({super.key});

  // ------------------------------------------------------------
  // Section Header Widget 
  // ------------------------------------------------------------
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFBBF18),
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'OCR A Extended',
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // Policy Text Block
  // ------------------------------------------------------------
  Widget _buildPolicySection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFBBF18),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'OCR A Extended',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontFamily: 'Itim',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------------
    // ABOUT SECTION CONTENT
    // ------------------------------------------------------------
    const aboutContent =
        'Journey is an **AI-powered fitness app** designed to help users set realistic goals, '
        'maintain safe workout routines, and stay motivated. '
        'Unlike traditional fitness apps, Journey uses a custom-trained AI to provide personalized '
        'advice and fitness insights tailored to each user. The app also features interactive challenges '
        'and a leaderboard system that encourages friendly competition.\n\n'
        '**A Note on Safety:** Journey is not a substitute for professional medical advice. '
        'If you ever feel pain, dizziness, numbness, or discomfort during exercise, **stop immediately** '
        'and consult a doctor. Your health always comes first.';

    // ------------------------------------------------------------
    // PRIVACY POLICY CONTENT 
    // ------------------------------------------------------------
    const policyContent = [
      {
        'title': '1. Information We Collect',
        'content':
            'We collect information you provide directly to us such as your name, email, date of birth, '
            'height, and weight. This allows the app to personalize your fitness recommendations. '
            'We also store workout history, achievements, and challenge performance.'
      },
      {
        'title': '2. How We Use Your Information',
        'content':
            'Your data is used solely to operate and improve Journey. This includes AI-generated insights, '
            'progress tracking, and personalized routines. '
            'We do not sell your data. Anonymized usage data may be used to improve AI accuracy.'
      },
      {
        'title': '3. Data Security',
        'content':
            'Journey uses strong encryption and security practices to protect your information. '
            'We encourage all users to choose strong, unique passwords for maximum account safety.'
      },
      {
        'title': '4. Data Sharing',
        'content':
            'We will **never sell your personal information**. Some trusted third-party services '
            '(cloud hosting, analytics, and security tools) may receive limited anonymized data '
            'strictly for app functionality and safety.'
      },
      {
        'title': '5. Your Rights',
        'content':
            'You may view, update, or delete your account information at any time through the Settings page. '
            'Deleting your account permanently removes your personal data from our servers.'
      }
    ];

    // ------------------------------------------------------------
    // AI DISCLAIMER
    // ------------------------------------------------------------
    const aiDisclaimer =
        'Journey uses artificial intelligence to create fitness recommendations, insights, and daily goals. '
        'AI predictions may not always be accurate and should not be relied on for any medical or health-critical decisions.\n\n'
        '**AI Limitations:**\n'
        '• The AI does not fully understand your medical history.\n'
        '• The AI cannot detect injuries or physical limitations.\n'
        '• All guidance is informational only.\n\n'
        'Always use your own judgment. If something feels wrong or unsafe, stop and consult a healthcare professional.';

    // ------------------------------------------------------------
    // TERMS OF USE
    // ------------------------------------------------------------
    const termsOfUse =
        'By using Journey, you agree to:\n'
        '• Use the app responsibly and safely.\n'
        '• Avoid pushing your body past safe limits.\n'
        '• Not misuse or attempt to manipulate leaderboard scores.\n'
        '• Not use Journey as a medical tool.\n\n'
        'We reserve the right to update these terms as Journey evolves and expands.';

    // ------------------------------------------------------------
    // DATA RETENTION POLICY
    // ------------------------------------------------------------
    const dataRetention =
        'We retain your account data for as long as your Journey account remains active. '
        'If you delete your account, all personal data will be permanently removed within 30 days. '
        'Anonymous fitness statistics may be retained to improve AI models, but this data is not linked to your identity.';

    // ------------------------------------------------------------
    // CONTACT INFO
    // ------------------------------------------------------------
    const contactInfo =
        'If you have any questions, concerns, or privacy requests, please contact us at:\n'
        'journeycapstoneproject@gmail.com';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Information',
          style: TextStyle(color: Color(0xFFFBBF18), fontFamily: 'OCR A Extended'),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFBBF18)),
      ),

      // Scrollable Content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ABOUT SECTION
            _buildSectionHeader("About Journey"),
            Text(
              aboutContent,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
                fontSize: 16,
                fontFamily: 'Itim',
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Icon(Icons.shield_outlined, size: 80, color: Color(0xFF667DB5)),
            ),

            // PRIVACY POLICY SECTION
            _buildSectionHeader("Privacy Policy"),
            ...policyContent.map((item) =>
                _buildPolicySection(context, item['title']!, item['content']!)),

            // AI DISCLAIMER
            _buildSectionHeader("AI Disclaimer"),
            _buildPolicySection(context, "AI Usage Notice", aiDisclaimer),

            // TERMS OF USE
            _buildSectionHeader("Terms of Use"),
            _buildPolicySection(context, "User Agreement", termsOfUse),

            // DATA RETENTION
            _buildSectionHeader("Data Retention"),
            _buildPolicySection(context, "How Long We Keep Your Data", dataRetention),

            // CONTACT INFO
            _buildSectionHeader("Contact Us"),
            _buildPolicySection(context, "Support & Help", contactInfo),

            const SizedBox(height: 40),
            Center(
              child: Text(
                'Journey v1.0.0 — Protecting your progress and your privacy.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white38,
                  fontStyle: FontStyle.italic,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
