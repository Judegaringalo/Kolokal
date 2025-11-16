import 'package:flutter/material.dart';
import 'student_info.dart';
import 'app_styles.dart';

// Global navigation key to control app flow
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Essential for reset flow
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/kolokal_logo.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    'Linggwistikong Laro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Marker',
                      color: white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Maligayang pagdating sa KOLOKAL!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: white70,
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    'Ang iyong katuwang sa pagpapakilala at paggamit ng pormal na wika na tutumbas sa mga balbal na wikang karaniwang ginagamit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: white70,
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudentInfo(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentYellow,
                        foregroundColor: primaryBlue,
                        elevation: 12,
                        shadowColor: const Color.fromARGB(95, 0, 0, 0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        'Simulan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Image.asset(
                'assets/kolokal_graphic.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
