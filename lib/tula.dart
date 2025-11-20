import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_styles.dart';

const String _draftKey = 'tulaDraft';

class SanaysayPage extends StatefulWidget {
  final String pangalan;
  final String seksyon;

  const SanaysayPage({
    super.key,
    required this.pangalan,
    required this.seksyon,
  });

  @override
  State<SanaysayPage> createState() => _SanaysayPageState();
}

class _SanaysayPageState extends State<SanaysayPage> {
  final TextEditingController _essayController = TextEditingController();
  final ScreenshotController _screenshotController = ScreenshotController();
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

  Future<void> _saveTulaAsImage() async {
    if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
      }

      if (!status.isGranted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Kailangan ng access sa Photos para mag-save ng imahe.'),
            backgroundColor: errorRed,
          ),
        );
        return;
      }
    }

    try {
      final Uint8List? image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );

      if (image == null) throw Exception('Hindi ma-capture ang imahe.');
      final result = await ImageGallerySaverPlus.saveImage(
        image,
        quality: 95,
        name:
            'Tula_${widget.pangalan}_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        _showSaveSuccessModal(context, isImage: true);
      } else {
        throw Exception(result['errorMessage'] ?? 'Unknown error saving image');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nagka-error sa pag-save: $e'),
          backgroundColor: errorRed,
        ),
      );
    }
  }

  void _showSaveSuccessModal(BuildContext context, {bool isImage = false}) {
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
              decoration: BoxDecoration(
                color: Colors.green.shade400,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isImage ? 'Na-save ang Imahe!' : 'Na-save ang Tula!',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isImage
                  ? 'Ang iyong tula ay na-save sa gallery ng iyong device.'
                  : 'Ang iyong draft ay ligtas na na-save at patuloy na a-auto-save.',
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
                  'Tapos na',
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 700) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Screenshot(
                                  controller: _screenshotController,
                                  child: _buildEssayInputCard(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(width: 280, child: _buildTipsCard()),
                            ],
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Screenshot(
                                controller: _screenshotController,
                                child: _buildEssayInputCard(),
                              ),
                              const SizedBox(height: 20),
                              _buildTipsCard(),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildRubricTable(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.pangalan,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      widget.seksyon,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
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
                _saveTulaAsImage();
              },
              icon: const Icon(Icons.image, color: primaryBlue),
              label: const Text(
                'I-Save bilang Imahe',
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
