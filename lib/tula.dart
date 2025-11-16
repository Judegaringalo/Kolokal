import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_styles.dart';

const String _draftKey = 'tulaDraft';

class SanaysayPage extends StatefulWidget {
  const SanaysayPage({super.key});

  @override
  State<SanaysayPage> createState() => _SanaysayPageState();
}

class _SanaysayPageState extends State<SanaysayPage> {
  final TextEditingController _essayController = TextEditingController();
  int _wordCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _essayController.addListener(_updateAndSaveDraft);
  }

  @override
  void dispose() {
    _essayController.removeListener(_updateAndSaveDraft);
    _essayController.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDraft = prefs.getString(_draftKey) ?? '';
    _essayController.text = savedDraft;
    _updateWordCount();
    setState(() => _isLoading = false);
  }

  Future<void> _saveDraft(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, text);
  }

  void _updateAndSaveDraft() {
    final text = _essayController.text.trim();
    final newCount = text.isEmpty
        ? 0
        : text.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).length;
    if (newCount != _wordCount) setState(() => _wordCount = newCount);
    _saveDraft(_essayController.text);
  }

  void _updateWordCount() => _updateAndSaveDraft();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: accentYellow),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tula (Writing Prompt)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 34.5,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      'Sumulat ng maikling tula gamit ang mga pormal na salitang iyong natututunan.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ✅ Flexible layout to prevent overflow
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 700) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _buildEssayInputCard()),
                              const SizedBox(width: 16),
                              SizedBox(width: 280, child: _buildTipsCard()),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEssayInputCard(),
                              const SizedBox(height: 20),
                              _buildTipsCard(),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                    _buildRubricTable(), // ✅ Fixed responsive rubric
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEssayInputCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note, color: accentYellow, size: 24),
              SizedBox(width: 8),
              Text(
                'Iyong tula',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 260,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: white.withOpacity(0.2)),
            ),
            child: TextField(
              controller: _essayController,
              expands: true,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                color: white,
                fontFamily: 'Poppins',
                fontSize: 15,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Magsimula ng pagsulat dito...',
                hintStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_wordCount na salita',
                style: const TextStyle(color: white, fontFamily: 'Poppins'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accentYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Auto-save',
                  style: TextStyle(color: accentYellow, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ang Tula ay na-save!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.save, color: primaryBlue),
              label: const Text(
                'I-Save',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentYellow,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    final tips = [
      'Gumamit ng mga pormal na salita',
      'Iwasan ang mga balbal',
      'Suriin ang grammar',
      'Basahin muli bago i-submit',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: accentYellow),
              SizedBox(width: 8),
              Text(
                'Mga Tip',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final t in tips)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(color: accentYellow, fontSize: 14),
                  ),
                  Expanded(
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRubricTable() {
    final criteria = [
      {
        'title': 'Organisadong Paglalahad',
        'points': [
          'Maayos at malinaw ang paglalahad ng Tula.',
          'Hindi gaanong maayos ngunit malinaw ang ideya.',
          'Hindi tiyak ang pagkakasunod ng mga ideya.',
          'Hindi malinaw at walang lohikal na pagkakaayos.',
        ],
      },
      {
        'title': 'Paggamit ng wika',
        'points': [
          '46–60 na tamang paggamit sa pormal na salita',
          '31–45 na tamang paggamit sa pormal na salita',
          '16–30 na tamang paggamit sa pormal na salita',
          '1–15 na tamang paggamit sa pormal na salita',
        ],
      },
      {
        'title': 'Gramatika',
        'points': [
          'Tama at maayos ang paggamit ng gramatika at bantas.',
          'Tama ang paggamit ng gramatika ngunit may kaunting error.',
          'May ilang kamalian sa baybay at bantas.',
          'Hindi maayos ang gramatika at baybay.',
        ],
      },
      {
        'title': 'Nilalaman',
        'points': [
          'Malinaw at pasok sa tema.',
          'Pasok sa tema ngunit kulang sa detalye.',
          'Medyo malabo at may kaunting kamalian.',
          'Hindi malinaw at hindi pasok sa tema.',
        ],
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: accentYellow),
              SizedBox(width: 8),
              Text(
                'PAMANTAYAN SA PAGBUO NG TULA',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(primaryBlue),
              columnSpacing: 50,
              columns: const [
                DataColumn(
                  label: Text(
                    'KRAYTIRYA',
                    style: TextStyle(color: accentYellow, fontSize: 14),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '5 puntos',
                    style: TextStyle(color: accentYellow, fontSize: 14),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '4 puntos',
                    style: TextStyle(color: accentYellow, fontSize: 14),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '3 puntos',
                    style: TextStyle(color: accentYellow, fontSize: 14),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '2 puntos',
                    style: TextStyle(color: accentYellow, fontSize: 12),
                  ),
                ),
              ],
              rows: criteria.map((c) {
                final points = c['points'] as List<String>;
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        c['title'] as String,
                        style: const TextStyle(
                          color: white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    for (var p in points)
                      DataCell(
                        SizedBox(
                          width: 140,
                          child: Text(
                            p,
                            style: const TextStyle(
                              color: white,
                              fontSize: 12,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
