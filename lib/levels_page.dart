import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_styles.dart';
import 'student_info.dart';
import 'tula.dart';
import 'quiz_page.dart';

class LevelsPage extends StatefulWidget {
  final String pangalan;
  final String seksyon;

  const LevelsPage({
    super.key,
    required this.pangalan,
    required this.seksyon,
  });

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage> {
  late String _currentPangalan;
  late String _currentSeksyon;
  int _currentHearts = 7;
  bool _katamtamanLocked = true;
  bool _mahirapLocked = true;
  String? _madaliCompleteStatus;
  String? _katamtamanCompleteStatus;
  String? _mahirapCompleteStatus;
  bool _isLoading = true;

  static const String _hasCompletedOnboardingKey = 'hasCompletedOnboarding';
  static const String _heartsKey = 'userHearts';
  static const String _katamtamanLockedKey = 'katamtamanLocked';
  static const String _mahirapLockedKey = 'mahirapLocked';
  static const String _madaliCompleteKey = 'madaliCompleteStatus';
  static const String _katamtamanCompleteKey = 'katamtamanCompleteStatus';
  static const String _mahirapCompleteKey = 'mahirapCompleteStatus';
  static const String _indexKeyPrefix = 'quizIndex_';
  static const String _answerKeyPrefix = 'quizAnswer_';
  static const String _submittedKeyPrefix = 'quizSubmitted_';
  static const String _resultsKeyPrefix = 'quizResults_';

  @override
  void initState() {
    super.initState();
    _currentPangalan = widget.pangalan;
    _currentSeksyon = widget.seksyon;
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentHearts = prefs.getInt(_heartsKey) ?? 7;
      _katamtamanLocked = prefs.getBool(_katamtamanLockedKey) ?? true;
      _mahirapLocked = prefs.getBool(_mahirapLockedKey) ?? true;
      _madaliCompleteStatus = prefs.getString(_madaliCompleteKey);
      _katamtamanCompleteStatus = prefs.getString(_katamtamanCompleteKey);
      _mahirapCompleteStatus = prefs.getString(_mahirapCompleteKey);
      _isLoading = false;
    });
  }

  Future<void> _updateUserInfo(String newPangalan, String newSeksyon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pangalan', newPangalan);
    await prefs.setString('seksyon', newSeksyon);

    setState(() {
      _currentPangalan = newPangalan;
      _currentSeksyon = newSeksyon;
    });
  }

  Future<void> _saveLevelProgress(String completedLevel, int finalHearts,
      bool success, bool fullResetLock, String? finalScoreStatus) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Update hearts
    await prefs.setInt(_heartsKey, finalHearts);

    if (fullResetLock) {
      await prefs.setBool(_katamtamanLockedKey, true);
      await prefs.setBool(_mahirapLockedKey, true);
      await prefs.remove(_madaliCompleteKey);
      await prefs.remove(_katamtamanCompleteKey);
      await prefs.remove(_mahirapCompleteKey);

      setState(() {
        _katamtamanLocked = true;
        _mahirapLocked = true;
        _madaliCompleteStatus = null;
        _katamtamanCompleteStatus = null;
        _mahirapCompleteStatus = null;
      });
    } else if (success) {
      if (completedLevel == 'Madali' && finalScoreStatus != null) {
        await prefs.setString(_madaliCompleteKey, finalScoreStatus);
        setState(() {
          _madaliCompleteStatus = finalScoreStatus;
          _katamtamanLocked = false;
        });
        await prefs.setBool(_katamtamanLockedKey, false);
      } else if (completedLevel == 'Katamtaman' && finalScoreStatus != null) {
        await prefs.setString(_katamtamanCompleteKey, finalScoreStatus);
        setState(() {
          _katamtamanCompleteStatus = finalScoreStatus;
          _mahirapLocked = false;
        });
        await prefs.setBool(_mahirapLockedKey, false);
      } else if (completedLevel == 'Mahirap' && finalScoreStatus != null) {
        await prefs.setString(_mahirapCompleteKey, finalScoreStatus);
        setState(() {
          _mahirapCompleteStatus = finalScoreStatus;
        });
      }
      // **END NEW**
    }

    // 3. Update hearts state on current page
    if (mounted) {
      setState(() => _currentHearts = finalHearts);
    }

    // REMOVED: ScaffoldMessenger.of(context).showSnackBar
  }

  // --- NEW Helper Function to Navigate to Results Page for Review ---
  Future<void> _navigateToResultsForReview(
      String level, String scoreStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final resultsKey = _resultsKeyPrefix + level;

    // 1. Load the simple results (QuestionResult)
    final savedResultsJson = prefs.getString(resultsKey);
    if (savedResultsJson == null) {
      // REMOVED: ScaffoldMessenger.of(context).showSnackBar for error
      return;
    }

    try {
      final List<dynamic> list = json.decode(savedResultsJson);
      final List<QuestionResult> simpleResults =
          list.map((e) => QuestionResult.fromJson(e)).toList();

      // 2. Map simple results back to full results with explanations
      final List<FullQuestionResult> finalFullResults =
          simpleResults.map((simpleResult) {
        // Find the corresponding Question object and create FullQuestionResult
        final question = Question.fromText(simpleResult.questionText, level) ??
            Question(
              questionText: simpleResult.questionText,
              options: [],
              correctAnswer: '',
              explanation:
                  'Hindi mahanap ang orihinal na tanong para sa review.',
            );

        return FullQuestionResult(
          question: question,
          userAnswer: simpleResult.userAnswer,
          isCorrect: simpleResult.isCorrect,
        );
      }).toList();

      // 3. Extract score from scoreStatus
      final parts = scoreStatus.split('/');
      final int finalScore = int.tryParse(parts[0]) ?? 0;
      final int maxScore = int.tryParse(parts[1]) ?? 0;

      // 4. Navigate to the QuizResultPage
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizResultPage(
            level: level,
            finalScore: finalScore,
            maxScore: maxScore,
            results: finalFullResults,
            onReturnToLevels: () {
              // Simply pop back, no need to update state on LevelsPage
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } catch (e) {
      // REMOVED: ScaffoldMessenger.of(context).showSnackBar for error
    }
  }
  // --- END NEW Helper Function ---

  // --- NEW: Modal for Locked Levels ---
  void _showLockedLevelModal(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        title: null,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: accentYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: primaryBlue,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ang Antas ay Naka-lock',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Kailangan mo munang kumpletuhin ang naunang antas para ma-unlock ang $title.',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        title: null,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: errorRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ulitin?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Ang lahat ng iyong progreso ay mawawala (kabilang ang mga na-unlock na antas, puso, at Tula draft) at babalik ka sa pahina ng impormasyon.',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Kanselahin',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorRed,
                      foregroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('pangalan');
                      await prefs.remove('seksyon');
                      await prefs.remove(_hasCompletedOnboardingKey);
                      await prefs.remove('tulaDraft');

                      await prefs.remove(_heartsKey);
                      await prefs.remove(_katamtamanLockedKey);
                      await prefs.remove(_mahirapLockedKey);

                      await prefs.remove(_madaliCompleteKey);
                      await prefs.remove(_katamtamanCompleteKey);
                      await prefs.remove(_mahirapCompleteKey);

                      const List<String> quizLevels = [
                        'Madali',
                        'Katamtaman',
                        'Mahirap'
                      ];
                      for (final level in quizLevels) {
                        await prefs.remove(_indexKeyPrefix + level);
                        await prefs.remove(_answerKeyPrefix + level);
                        await prefs.remove(_submittedKeyPrefix + level);
                        await prefs.remove(_resultsKeyPrefix + level);
                      }

                      if (!mounted) return;
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const StudentInfo()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Kumpirmahin',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSettingsSheet(BuildContext context) {
    final TextEditingController nameCtrl = TextEditingController(
      text: _currentPangalan,
    );
    final TextEditingController sectionCtrl = TextEditingController(
      text: _currentSeksyon,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Mga Setting',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Pangalan', style: poppinsWhiteW600_16),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: white),
              ),
              const SizedBox(height: 16),
              const Text('Seksyon', style: poppinsWhiteW600_16),
              const SizedBox(height: 6),
              TextField(
                controller: sectionCtrl,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: white),
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
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: () {
                    final newName = nameCtrl.text.trim();
                    final newSection = sectionCtrl.text.trim();
                    if (newName.isNotEmpty && newSection.isNotEmpty) {
                      _updateUserInfo(newName, newSection);
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text(
                    'I-Save',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: errorRed),
                    foregroundColor: white,
                    backgroundColor: errorRed,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showResetConfirmation(context);
                  },
                  child: const Text(
                    'Ulitin',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double topSafeArea = MediaQuery.of(context).padding.top;
          final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

          return SizedBox(
            height: constraints.maxHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/kolokal_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - topSafeArea,
                      ),
                      child: Column(
                        children: [
                          _buildProfileHeader(context),
                          const SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                _buildPlayerItem(
                                  'Madali',
                                  '5 tanong para sa mga nagsisimula',
                                  Icons.menu_book_rounded,
                                  primaryBlue,
                                  locked: false,
                                  completionStatus: _madaliCompleteStatus,
                                  onTap: () {
                                    if (_madaliCompleteStatus != null) {
                                      _navigateToResultsForReview(
                                          'Madali', _madaliCompleteStatus!);
                                      return;
                                    }
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => QuizPage(
                                          level: 'Madali',
                                          onQuizComplete: (finalHearts,
                                                  success,
                                                  fullResetLock,
                                                  finalScoreStatus) =>
                                              _saveLevelProgress(
                                                  'Madali',
                                                  finalHearts,
                                                  success,
                                                  fullResetLock,
                                                  finalScoreStatus),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _buildPlayerItem(
                                  'Katamtaman',
                                  '5 tanong na mas hamon',
                                  _katamtamanLocked
                                      ? Icons.lock_outline_rounded
                                      : Icons.menu_book_rounded,
                                  _katamtamanLocked
                                      ? accentYellow.withOpacity(0.6)
                                      : accentYellow,
                                  locked: _katamtamanLocked,
                                  completionStatus: _katamtamanCompleteStatus,
                                  onTap: () {
                                    if (_katamtamanLocked) return;
                                    if (_katamtamanCompleteStatus != null) {
                                      _navigateToResultsForReview('Katamtaman',
                                          _katamtamanCompleteStatus!);
                                      return;
                                    }
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => QuizPage(
                                          level: 'Katamtaman',
                                          onQuizComplete: (finalHearts,
                                                  success,
                                                  fullResetLock,
                                                  finalScoreStatus) =>
                                              _saveLevelProgress(
                                                  'Katamtaman',
                                                  finalHearts,
                                                  success,
                                                  fullResetLock,
                                                  finalScoreStatus),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _buildPlayerItem(
                                  'Mahirap',
                                  '5 tanong para sa mga dalubhasa',
                                  _mahirapLocked
                                      ? Icons.lock_outline_rounded
                                      : Icons.menu_book_rounded,
                                  _mahirapLocked
                                      ? Colors.redAccent.withOpacity(0.6)
                                      : errorRed,
                                  locked: _mahirapLocked,
                                  completionStatus: _mahirapCompleteStatus,
                                  onTap: () {
                                    if (_mahirapLocked) return;
                                    if (_mahirapCompleteStatus != null) {
                                      _navigateToResultsForReview(
                                          'Mahirap', _mahirapCompleteStatus!);
                                      return;
                                    }
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (ctx) => QuizPage(
                                          level: 'Mahirap',
                                          onQuizComplete: (finalHearts,
                                                  success,
                                                  fullResetLock,
                                                  finalScoreStatus) =>
                                              _saveLevelProgress(
                                                  'Mahirap',
                                                  finalHearts,
                                                  success,
                                                  fullResetLock,
                                                  finalScoreStatus),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // --- MODIFIED: Tula Page tap ---
                                _buildPlayerItem(
                                  'Tula',
                                  'Sumulat gamit ang iyong natutunayan na pormal na salita',
                                  Icons.edit_note_rounded,
                                  primaryBlue,
                                  locked: false,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        // OLD: builder: (ctx) => const SanaysayPage(),
                                        // NEW: Pass the user info
                                        builder: (ctx) => SanaysayPage(
                                          pangalan: _currentPangalan,
                                          seksyon: _currentSeksyon,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // --- END MODIFIED ---
                              ],
                            ),
                          ),
                          SizedBox(height: 100 + bottomSafeArea),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildIconBadge(
                icon: Icons.settings_rounded,
                isScore: false,
                onTap: () => _openSettingsSheet(context),
              ),
            ],
          ),
        ),
        _buildUserInfo(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildIconBadge({
    IconData? icon,
    String? text,
    String? imageAsset,
    required bool isScore,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isScore ? 12 : 8,
          vertical: isScore ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, color: primaryBlue, size: 20),
            if (imageAsset != null)
              Image.asset(imageAsset, height: 20, width: 20),
            if (text != null)
              Padding(
                padding: EdgeInsets.only(left: icon != null ? 6.0 : 0),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: black87,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: accentYellow,
            image: DecorationImage(
              image: AssetImage('assets/kolokal_graphic1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _currentPangalan,
          style: const TextStyle(
            color: black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        Text(
          _currentSeksyon,
          style: const TextStyle(
            color: black54,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _currentHearts,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                child: Image.asset(
                  'assets/kolokal_heart_icon.png',
                  height: 18,
                  width: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerItem(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    required bool locked,
    VoidCallback? onTap,
    String? completionStatus,
  }) {
    final bool isCompletedQuiz = completionStatus != null && title != 'Tula';
    final Color itemColor = isCompletedQuiz ? Colors.green.shade50 : white;
    final Color titleColor = isCompletedQuiz ? Colors.green.shade700 : black87;
    final Color subtitleColor =
        isCompletedQuiz ? Colors.green.shade500 : black54;

    return GestureDetector(
      onTap: locked ? () => _showLockedLevelModal(context, title) : onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: itemColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.2),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: locked ? Colors.grey : titleColor,
                    ),
                  ),
                  Text(
                    locked
                        ? 'Nakalock'
                        : (completionStatus != null
                            ? 'Kumpleto: $completionStatus'
                            : subtitle),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: locked ? Colors.grey : subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              locked
                  ? Icons.lock_outline
                  : (isCompletedQuiz
                      ? Icons.check_circle_outline
                      : Icons.arrow_forward_ios_rounded),
              color: locked
                  ? Colors.grey.shade400
                  : (isCompletedQuiz ? Colors.green.shade700 : primaryBlue),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
