import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_styles.dart';

// --- Data Model for a Quiz Question ---
class Question {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation; // ADDED

  const Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation, // ADDED
  });

  // Method to find the matching Question from quizData based on questionText
  static Question? fromText(String questionText, String level) {
    return quizData[level]?.firstWhere((q) => q.questionText == questionText,
        orElse: () => Question(
              questionText: questionText,
              options: [],
              correctAnswer: '',
              explanation: 'Hindi mahanap ang orihinal na tanong.',
            ));
  }
}

// --- Question Result Model ---
class QuestionResult {
  final String questionText; // Store text instead of object for serialization
  final String? userAnswer;
  final bool isCorrect;

  const QuestionResult({
    required this.questionText,
    required this.userAnswer,
    required this.isCorrect,
  });

  // Serialization to JSON map
  Map<String, dynamic> toJson() => {
        'questionText': questionText,
        'userAnswer': userAnswer,
        'isCorrect': isCorrect,
      };

  // Deserialization from JSON map
  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionText: json['questionText'] as String,
      userAnswer: json['userAnswer'] as String?,
      isCorrect: json['isCorrect'] as bool,
    );
  }
}

// --- Quiz Questions Data ---
const Map<String, List<Question>> quizData = {
  'Madali': [
    Question(
      questionText: 'Ano ang pormal na salita para sa "Chikadora"?',
      options: ['Matabil', 'Masalita', 'Mapag-usap', 'Masungit'],
      correctAnswer: 'Masalita',
      explanation:
          'Ang "Masalita" ay tumutukoy sa taong mahilig magsalita o marami ang sinasabi, na siyang pormal na katumbas ng balbal na "Chikadora".',
    ),
    Question(
      questionText: 'Ang "Palamuti" ay pormal na salita para sa:',
      options: ['Dekorasyon', 'Gayak', 'Kagamitan', 'Amulet'],
      correctAnswer: 'Dekorasyon',
      explanation:
          'Ang "Dekorasyon" ay pormal na salita na ginagamit upang tukuyin ang mga bagay na pampaganda o palamuti (Palamuti).',
    ),
    Question(
      questionText: 'Pormal na katumbas ng "Haybol".',
      options: ['Tirahan', 'Bahay', 'Tahanan', 'Kuta'],
      correctAnswer: 'Tahanan',
      explanation:
          'Ang "Tahanan" ay ang mas pormal at malalim na salita para sa simpleng "Bahay" o balbal na "Haybol".',
    ),
    Question(
      questionText: 'Ano ang pormal na salita ng "Datung"?',
      options: ['Salapi', 'Pera', 'Krimen', 'Pag-ibig'],
      correctAnswer: 'Salapi',
      explanation:
          'Ang "Salapi" ay ang pormal na terminolohiya para sa pera o balbal na "Datung".',
    ),
    Question(
      questionText: 'Pormal na salita ng "Sikmura".',
      options: ['Tiyan', 'Kalooban', 'Apo', 'Puso'],
      correctAnswer: 'Tiyan',
      explanation:
          'Ang "Tiyan" ay ang bahagi ng katawan kung saan matatagpuan ang "Sikmura".',
    ),
  ],
  'Katamtaman': [
    Question(
      questionText: 'Pormal na salita para sa "Ate".',
      options: ['Kapatid', 'Manang', 'Nakakatandang Kapatid na Babae', 'Sis'],
      correctAnswer: 'Nakakatandang Kapatid na Babae',
      explanation:
          'Ang "Nakakatandang Kapatid na Babae" ay ang direktang pormal na katumbas ng "Ate".',
    ),
    Question(
      questionText: 'Ano ang pormal na salita para sa "Meron"?',
      options: ['Mayroon', 'Dito', 'Wala', 'Kasama'],
      correctAnswer: 'Mayroon',
      explanation:
          'Ang "Mayroon" ay ang tamang pormal na salita para sa impormal na "Meron".',
    ),
    Question(
      questionText: 'Pormal na katumbas ng "Libangan".',
      options: ['Hobby', 'Kasiyahan', 'Pampalipas-oras', 'Aliwan'],
      correctAnswer: 'Aliwan',
      explanation:
          'Ang "Aliwan" o "Libangan" ay tumutukoy sa mga gawain para sa katuwaan at pagpapahinga.',
    ),
    Question(
      questionText: 'Ang "Kasangkapan" ay pormal na salita para sa:',
      options: ['Gamit', 'Utensil', 'Tool', 'Armas'],
      correctAnswer: 'Gamit',
      explanation:
          'Ang "Kasangkapan" ay pormal na salita para sa anumang bagay na ginagamit, o "Gamit".',
    ),
    Question(
      questionText: 'Pormal na salita ng "Kalsada".',
      options: ['Daan', 'Lansangan', 'Kanto', 'Tulay'],
      correctAnswer: 'Lansangan',
      explanation:
          'Ang "Lansangan" ay mas pormal na salita kaysa "Daan" para sa "Kalsada".',
    ),
  ],
  'Mahirap': [
    Question(
      questionText: 'Pormal na salita para sa "Balikbayan box".',
      options: ['Kahong Laman', 'Padala', 'Kargamento', 'Bagahe'],
      correctAnswer: 'Kargamento',
      explanation:
          'Ang "Kargamento" ay tumutukoy sa mga kalakal na dinadala sa ibang bansa, na mas pormal kaysa "Balikbayan box".',
    ),
    Question(
      questionText: 'Ano ang pormal na salita para sa "Tindi"?',
      options: ['Lakas', 'Sidhi', 'Galit', 'Bigat'],
      correctAnswer: 'Sidhi',
      explanation: 'Ang "Sidhi" ay nangangahulugang tindi, lakas, o kasidhian.',
    ),
    Question(
      questionText: 'Pormal na katumbas ng "Huwag".',
      options: ['Hindi', 'Ayaw', 'Bawal', 'Huwag'],
      correctAnswer: 'Huwag',
      explanation:
          'Ang "Huwag" ay nananatiling pormal na salita, na ginagamit upang magpahiwatig ng pagbabawal o pagpigil.',
    ),
    Question(
      questionText: 'Ang "Aswang" ay pormal na salita para sa:',
      options: ['Multo', 'Pangit', 'Halimaw', 'Nilalang'],
      correctAnswer: 'Halimaw',
      explanation:
          'Ang "Halimaw" ay tumutukoy sa mga nilalang na may nakakatakot na anyo, na siyang pangkalahatang pormal na kategorya ng "Aswang".',
    ),
    Question(
      questionText: 'Pormal na salita ng "Sulat".',
      options: ['Liham', 'Papel', 'Mensaje', 'Text'],
      correctAnswer: 'Liham',
      explanation:
          'Ang "Liham" ay ang pormal na katumbas ng sulat na ipinadala sa isang tao.',
    ),
  ],
};

// NEW model for the result page to hold full Question data (Moved up for use in LevelsPage)
class FullQuestionResult {
  final Question question;
  final String? userAnswer;
  final bool isCorrect;

  const FullQuestionResult({
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
  });
}

// --- QUIZ PAGE ---
class QuizPage extends StatefulWidget {
  final String level;
  // MODIFIED: Added finalScoreStatus parameter to the function type
  final Function(int finalHearts, bool success, bool fullResetLock,
      String? finalScoreStatus) onQuizComplete;

  const QuizPage({
    super.key,
    required this.level,
    required this.onQuizComplete,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  final List<Question> _questions = [];
  List<QuestionResult> _results = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  int _currentHearts = 7;
  final int _maxHearts = 7;
  bool _isLoading = true;
  bool _isAnswerSubmitted = false;

  late AnimationController _feedbackController;
  late Animation<double> _scaleAnimation;
  bool _showCorrectFeedback = false;

  // Keys for persistence
  static const String _heartsKey = 'userHearts';
  static const String _indexKeyPrefix = 'quizIndex_';
  static const String _answerKeyPrefix = 'quizAnswer_';
  static const String _submittedKeyPrefix = 'quizSubmitted_';
  static const String _resultsKeyPrefix = 'quizResults_';

  @override
  void initState() {
    super.initState();
    _questions.addAll(quizData[widget.level] ?? []);

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _feedbackController,
        curve: Curves.elasticOut,
      ),
    );

    _loadState();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // --- Persistence Logic ---

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    _currentHearts = prefs.getInt(_heartsKey) ?? _maxHearts;

    final indexKey = _indexKeyPrefix + widget.level;
    final answerKey = _answerKeyPrefix + widget.level;
    final submittedKey = _submittedKeyPrefix + widget.level;
    final resultsKey = _resultsKeyPrefix + widget.level;

    _currentQuestionIndex = prefs.getInt(indexKey) ?? 0;
    _selectedAnswer = prefs.getString(answerKey);
    _isAnswerSubmitted = prefs.getBool(submittedKey) ?? false;

    // Load existing results
    final savedResultsJson = prefs.getString(resultsKey);
    if (savedResultsJson != null) {
      try {
        final List<dynamic> list = json.decode(savedResultsJson);
        _results = list.map((e) => QuestionResult.fromJson(e)).toList();
      } catch (e) {
        // print('Error loading results: $e');
        _results = [];
      }
    } else {
      _results = [];
    }

    if (_currentQuestionIndex >= _questions.length) {
      // If index is out of bounds, it means the quiz was completed but the completion
      // status wasn't reset (which should only happen if the user didn't return to levels page)
      // Reset locally but keep the completion status in prefs to allow review.
      _currentQuestionIndex = 0;
      _isAnswerSubmitted = false;
      _selectedAnswer = null;
      // DO NOT call _clearLevelProgress here, as it would delete the review data.
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveHearts(int hearts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_heartsKey, hearts);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final indexKey = _indexKeyPrefix + widget.level;
    final answerKey = _answerKeyPrefix + widget.level;
    final submittedKey = _submittedKeyPrefix + widget.level;
    final resultsKey = _resultsKeyPrefix + widget.level;

    await prefs.setInt(indexKey, _currentQuestionIndex);

    if (_selectedAnswer != null) {
      await prefs.setString(answerKey, _selectedAnswer!);
    } else {
      await prefs.remove(answerKey);
    }
    await prefs.setBool(submittedKey, _isAnswerSubmitted);

    // Save the results list
    final resultsJson = json.encode(_results.map((r) => r.toJson()).toList());
    await prefs.setString(resultsKey, resultsJson);
  }

  Future<bool> _onWillPop() async {
    // Save current selection and index when leaving the page
    await _saveProgress();
    return true;
  }

  // --- Quiz Logic ---

  void _showCorrectFeedbackOverlay() async {
    if (!mounted) return;

    setState(() {
      _showCorrectFeedback = true;
    });
    _feedbackController.forward(from: 0.0);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _showCorrectFeedback = false;
      });
      _feedbackController.reset();
    }
  }

  void _checkAnswer() {
    if (_isAnswerSubmitted) {
      _moveToNextQuestion();
      return;
    }

    if (_selectedAnswer == null) return;

    setState(() {
      _isAnswerSubmitted = true;
    });
    // Call _saveProgress *after* recording the result below

    bool isCorrect =
        _selectedAnswer == _questions[_currentQuestionIndex].correctAnswer;

    // Record the result for the current question
    final currentQuestion = _questions[_currentQuestionIndex];

    // Remove any existing result for this question (for safety/re-submission)
    _results.removeWhere((r) => r.questionText == currentQuestion.questionText);

    // Add the new result
    _results.add(
      QuestionResult(
        questionText: currentQuestion.questionText, // Save only the text
        userAnswer: _selectedAnswer,
        isCorrect: isCorrect,
      ),
    );

    // Now save state including the results list
    _saveProgress();

    if (isCorrect) {
      _showCorrectFeedbackOverlay();
    } else {
      _currentHearts = _currentHearts - 1;
      _saveHearts(_currentHearts);
      if (_currentHearts <= 0) {
        Future.delayed(const Duration(seconds: 1), _showGameOverModal);
      }
    }
  }

  void _moveToNextQuestion() {
    if (_currentHearts <= 0) return;

    if (!mounted) return;
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswerSubmitted = false;
      });
      _saveProgress();
    } else {
      // Quiz finished successfully - Navigate to QuizResultPage

      // Calculate final score: 4 points per correct question
      int maxScore = _questions.length * 4;
      int finalScore = _results.where((r) => r.isCorrect).length * 4;
      String finalScoreStatus = '$finalScore/$maxScore';

      // Clear non-result progress keys for this level upon completion
      _clearLevelProgress();

      // Map simplified results back to full results with explanations
      final List<FullQuestionResult> finalFullResults =
          _results.map((simpleResult) {
        final question =
            Question.fromText(simpleResult.questionText, widget.level)!;
        return FullQuestionResult(
          question: question,
          userAnswer: simpleResult.userAnswer,
          isCorrect: simpleResult.isCorrect,
        );
      }).toList();

      // Navigate to the new results page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultPage(
            level: widget.level,
            finalScore: finalScore,
            maxScore: maxScore,
            results: finalFullResults,
            onReturnToLevels: () {
              // 1. Notify parent (LevelsPage) to save hearts, unlock next level, and save score
              widget.onQuizComplete(
                  _currentHearts, true, false, finalScoreStatus);
              // 2. Since QuizPage was replaced by QuizResultPage, we need to pop to reveal LevelsPage
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    }
  }

  Future<void> _clearLevelProgress({bool clearResults = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_indexKeyPrefix + widget.level);
    await prefs.remove(_answerKeyPrefix + widget.level);
    await prefs.remove(_submittedKeyPrefix + widget.level);

    if (clearResults) {
      await prefs.remove(_resultsKeyPrefix + widget.level);
    }
  }

  // --- UI Modals ---

  void _showGameOverModal() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sentiment_dissatisfied,
                  color: errorRed, size: 48),
              const SizedBox(height: 16),
              const Text('Game Over!', style: poppinsPrimaryBlueBold_22),
              const SizedBox(height: 8),
              const Text(
                  'Naubos ang iyong mga puso. Subukan ulit ang pagsusulit.',
                  textAlign: TextAlign.center,
                  style: poppinsBlack87_14),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await _saveHearts(_maxHearts);
                  // Clear all progress and results upon game over
                  await _clearLevelProgress(clearResults: true);
                  // Pass null for the score status on failure/game over
                  widget.onQuizComplete(_maxHearts, false, true, null);
                  if (!mounted) return;

                  // FIX: Use a double pop to return to LevelsPage (Pop Modal, then Pop QuizPage)
                  Navigator.of(context).pop(); // Pop the Game Over modal
                  Navigator.of(context)
                      .pop(); // Pop the QuizPage, revealing LevelsPage
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentYellow,
                  foregroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                ),
                child: const Text('Bumalik sa Antas',
                    style: poppinsPrimaryBlueW800_17),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Builders and Build method ---

  Widget _buildOptionButton(String option) {
    bool isSelected = _selectedAnswer == option;
    Color buttonColor = cardBlue;
    Color textColor = white;
    Color iconColor = white;
    IconData? icon;
    BorderSide borderSide = BorderSide.none;

    if (_isAnswerSubmitted) {
      if (option == _questions[_currentQuestionIndex].correctAnswer) {
        // Correct Answer
        buttonColor = const Color.fromARGB(255, 0, 189, 9);
        textColor = const Color.fromARGB(255, 0, 189, 9);
        icon = Icons.check_circle;
        borderSide = BorderSide(
            color: const Color.fromARGB(255, 0, 189, 9),
            width: 4); // Green border
      } else if (isSelected) {
        // User's Wrong Answer
        buttonColor = errorRed;
        textColor = const Color.fromARGB(255, 233, 117, 117);
        icon = Icons.close_rounded;
        borderSide = const BorderSide(
            color: errorRed, width: 4); // White border for wrong answer
      } else {
        // Unselected, incorrect answers
        buttonColor = cardBlue.withOpacity(0.5);
        textColor = white70;
      }
    } else if (isSelected) {
      // Pre-submission, selected answer
      buttonColor = accentYellow;
      textColor = primaryBlue;
      borderSide = const BorderSide(color: primaryBlue, width: 3);
    }
    // else: Pre-submission, unselected answer (default values apply)

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        onPressed: _isAnswerSubmitted
            ? null
            : () {
                setState(() {
                  if (isSelected) {
                    _selectedAnswer = null;
                  } else {
                    _selectedAnswer = option;
                  }
                });
                _saveProgress();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          side: borderSide, // Use the dynamically calculated border
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: poppinsWhiteW600_16.copyWith(color: textColor),
                textAlign: TextAlign.start,
              ),
            ),
            if (_isAnswerSubmitted && icon != null)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(icon, color: iconColor),
              ),
          ],
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

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    String buttonText;
    final bool isLastQuestion = _currentQuestionIndex == _questions.length - 1;

    if (_isAnswerSubmitted) {
      buttonText =
          isLastQuestion ? 'Tapusin ang Pagsusulit' : 'Susunod na Tanong';
    } else {
      buttonText = 'Tingnan ang Sagot';
    }

    final bool isButtonEnabled = _selectedAnswer != null || _isAnswerSubmitted;
    final void Function()? submitAction = isButtonEnabled ? _checkAnswer : null;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: primaryBlue,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: white),
            onPressed: () async {
              await _onWillPop();
              if (mounted) Navigator.pop(context);
            },
          ),
          title: Text(
            widget.level,
            style: poppinsWhiteBold_24.copyWith(fontSize: 20),
          ),
          centerTitle: true,
          actions: const [],
        ),
        body: Stack(
          children: [
            // Layer 1: The main quiz UI
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEARTS
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _currentHearts,
                          (index) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Image.asset(
                              'assets/kolokal_heart_icon.png',
                              height: 25,
                              width: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: white.withOpacity(0.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(accentYellow),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Question Count
                    Text(
                      'Tanong ${_currentQuestionIndex + 1} / ${_questions.length}',
                      style: poppinsWhite70_14,
                    ),
                    const SizedBox(height: 20),

                    // Question Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBlue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        currentQuestion.questionText,
                        style: poppinsWhiteBold_24.copyWith(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Options
                    ...currentQuestion.options.map(_buildOptionButton).toList(),
                    const Spacer(),

                    // Check Answer Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentYellow,
                          foregroundColor: primaryBlue,
                          elevation: 10,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style:
                              poppinsPrimaryBlueW800_17.copyWith(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Layer 2: The "Mahusay!" feedback overlay (conditional)
            if (_showCorrectFeedback)
              Positioned.fill(
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0.0, -100.0),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          'Mahusay!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                            color: const Color.fromARGB(255, 0, 204, 7),
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- QUIZ RESULT PAGE (NEW WIDGET) ---

class QuizResultPage extends StatelessWidget {
  final String level;
  final int finalScore;
  final int maxScore;
  final List<FullQuestionResult> results; // Use FullQuestionResult
  final VoidCallback onReturnToLevels;

  const QuizResultPage({
    super.key,
    required this.level,
    required this.finalScore,
    required this.maxScore,
    required this.results,
    required this.onReturnToLevels,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '$level - Tapos Na!',
                    textAlign: TextAlign.center,
                    style: poppinsWhiteBold_24.copyWith(
                        fontSize: 26, color: accentYellow),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Iskor: $finalScore/$maxScore',
                    textAlign: TextAlign.center,
                    style: poppinsWhiteBold_24.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mga Tamang Sagot at Paliwanag',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: white),
                  ),
                ],
              ),
            ),

            // Results List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: List.generate(
                    results.length,
                    (index) => _ResultQuestionTile(
                      questionNumber: index + 1,
                      result: results[index],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Trigger state update and navigation back to LevelsPage
                    // The onReturnToLevels callback now handles the navigation (pop).
                    onReturnToLevels();

                    // This pop was removed to fix double-pop issue when reviewing a completed quiz.
                    // Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentYellow,
                    foregroundColor: primaryBlue,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Bumalik sa Mga Antas',
                    style: poppinsPrimaryBlueW800_17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for a single question review tile
class _ResultQuestionTile extends StatelessWidget {
  final int questionNumber;
  final FullQuestionResult result; // Use FullQuestionResult

  const _ResultQuestionTile({
    required this.questionNumber,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    // Color for the checkmark/cross icon
    final iconColor = result.isCorrect ? Colors.green.shade400 : errorRed;

    // Determine the user's selected answer text for display
    final String userAnswerText = result.userAnswer ?? 'Walang Sagot';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardBlue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          collapsedIconColor: white,
          iconColor: accentYellow,
          title: Row(
            children: [
              Icon(
                result.isCorrect
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Tanong #$questionNumber',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: white,
                ),
              ),
            ],
          ),
          children: [
            // Body of the question tile
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Text
                  Text(
                    result.question.questionText,
                    style: const TextStyle(
                        fontFamily: 'Poppins', fontSize: 15, color: white70),
                  ),
                  const SizedBox(height: 12),

                  // User's Answer vs Correct Answer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: result.isCorrect
                          ? Colors.green.shade700
                          : errorRed.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.isCorrect
                              ? 'Tamang Sagot: ${result.question.correctAnswer}'
                              : 'Iyong Sagot: $userAnswerText',
                          style: poppinsWhiteW600_16.copyWith(fontSize: 14),
                        ),
                        if (!result.isCorrect)
                          Text(
                            'Tamang Sagot: ${result.question.correctAnswer}',
                            style: poppinsWhiteW600_16.copyWith(
                                fontSize: 14, color: accentYellow),
                          ),
                      ],
                    ),
                    // Explanation Header
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Paliwanag:',
                    style: poppinsWhiteW600_16.copyWith(
                        color: accentYellow, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  // Explanation Body
                  Text(
                    result.question.explanation,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: white70,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
