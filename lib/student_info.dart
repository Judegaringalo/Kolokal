import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'levels_page.dart';
import 'app_styles.dart';
import 'main.dart';

class StudentInfo extends StatefulWidget {
  const StudentInfo({super.key});

  @override
  State<StudentInfo> createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  final TextEditingController _pangalanController = TextEditingController();
  final TextEditingController _seksyonController = TextEditingController();
  bool _isLoading = true;

  static const String _hasCompletedOnboardingKey = 'hasCompletedOnboarding';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompleted = prefs.getBool(_hasCompletedOnboardingKey) ?? false;

    if (hasCompleted) {
      final pangalan = prefs.getString('pangalan');
      final seksyon = prefs.getString('seksyon');
      if (pangalan != null && seksyon != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                LevelsPage(pangalan: pangalan, seksyon: seksyon),
          ),
        );
        return;
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserInfo(String pangalan, String seksyon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pangalan', pangalan);
    await prefs.setString('seksyon', seksyon);
    await prefs.setBool(_hasCompletedOnboardingKey, true);
  }

  @override
  void dispose() {
    _pangalanController.dispose();
    _seksyonController.dispose();
    super.dispose();
  }

  void _showErrorModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 15,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    color: errorRed, shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded,
                    color: white, size: 36),
              ),
              const SizedBox(height: 16),
              const Text('Kailangan ng Input',
                  textAlign: TextAlign.center,
                  style: poppinsPrimaryBlueBold_22),
              const SizedBox(height: 12),
              const Text(
                'Ang Pangalan at Seksyon ay kinakailangan bago magpatuloy sa laro. Paki-fill up ang lahat ng patlang.',
                textAlign: TextAlign.center,
                style: poppinsBlack87_14,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentYellow,
                    foregroundColor: primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    elevation: 5,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('NAIINTINDIHAN',
                      style: poppinsPrimaryBlueW800_17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationModal(
      BuildContext context, String pangalan, String seksyon) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 15,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Kumpirmahin ang Iyong Detalye',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                    fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Pangalan: ', pangalan),
              _buildInfoRow('Seksyon: ', seksyon),
              const SizedBox(height: 16),
              const Text(
                'Sigurado ka bang ito ang iyong detalye? Magpatuloy para magsimula sa laro.',
                textAlign: TextAlign.center,
                style: poppinsBlack54_13,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentYellow,
                  foregroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  elevation: 5,
                ),
                onPressed: () async {
                  await _saveUserInfo(pangalan, seksyon);
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) =>
                            LevelsPage(pangalan: pangalan, seksyon: seksyon)),
                  );
                },
                child: const Text('SIMULAN ANG LARO',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins')),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Baguhin ang Detalye',
                    style:
                        TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: black87,
                  fontFamily: 'Poppins')),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                  fontFamily: 'Poppins'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: primaryBlue,
        body: Center(child: CircularProgressIndicator(color: accentYellow)),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height * 0.45),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Pangalan', style: poppinsWhiteW600_16),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _pangalanController,
                        decoration: InputDecoration(
                          hintText: 'Halimbawa: Sheena Cruz',
                          hintStyle: const TextStyle(
                              color: white70, fontFamily: 'Poppins'),
                          filled: true,
                          fillColor: white.withOpacity(0.1),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                        ),
                        style: const TextStyle(color: white),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      const Text('Baitang at Seksyon',
                          style: poppinsWhiteW600_16),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _seksyonController,
                        decoration: InputDecoration(
                          hintText: 'Halimbawa: Grade 8-Albay',
                          hintStyle: const TextStyle(
                              color: white70, fontFamily: 'Poppins'),
                          filled: true,
                          fillColor: white.withOpacity(0.1),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                        ),
                        style: const TextStyle(color: white),
                      ),
                      SizedBox(height: screenSize.height * 0.020),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 2.0,
                              runSpacing: 4.0,
                              children: List.generate(
                                7,
                                (i) => Image.asset(
                                  'assets/kolokal_heart_icon.png',
                                  height: isSmallScreen ? 20 : 26,
                                  width: isSmallScreen ? 20 : 26,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Mayroon kang 7 puso bilang life saver sa larong ito. Pag-ingatan ang laro para mapagtagumpayan at matuto.',
                              style: TextStyle(
                                  color: white,
                                  fontFamily: 'Poppins',
                                  height: 1.5,
                                  fontSize: isSmallScreen ? 14 : 15),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final pangalan = _pangalanController.text.trim();
                            final seksyon = _seksyonController.text.trim();
                            if (pangalan.isEmpty || seksyon.isEmpty) {
                              _showErrorModal(context);
                              return;
                            }
                            _showConfirmationModal(context, pangalan, seksyon);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentYellow,
                            foregroundColor: primaryBlue,
                            elevation: 12,
                            shadowColor: const Color.fromARGB(95, 0, 0, 0),
                            padding: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.02),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                          ),
                          child: Text(
                            'Magpatuloy',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.04),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenSize.height * 0.45,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/kolokal_graphic1.png'),
                    fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: screenSize.width * 0.06,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 3))
                          ],
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: primaryBlue, size: 26),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(8.0, 0.0),
                    child: Image.asset('assets/kolokal_logo.png',
                        height: screenSize.height * 0.11, fit: BoxFit.contain),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
