import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import '../../data/analysis_service.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isRecording = false;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _history = context.read<AnalysisService>().getAnalysisHistory().reversed.toList();
    });
  }

  void _toggleRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _textController.text =
            "Akhir-akhir ini saya merasa sangat lelah dengan pekerjaan, sering terbangun di malam hari, dan kadang merasa cemas tanpa alasan yang jelas saat mau berangkat ke kantor.";
      });
    } else {
      setState(() {
        _isRecording = true;
        _textController.clear();
        _analysisResult = null;
      });
    }
  }

  void _handleAnalyze() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key tidak ditemukan di .env');
      }

      final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);

      final prompt =
          '''
        Sebagai AI analitik kesehatan mental "Safea", analisis keluhan berikut:
        "${_textController.text}"

        Berikan hasil analisis dalam format JSON dengan struktur:
        {
          "summary": "Ringkasan 1 kalimat",
          "detectedConditions": [{"name": "Kecemasan/Burnout/PTSD", "confidence": 0-100}],
          "indicators": ["indikator 1", "indikator 2"],
          "recommendation": "Saran langkah selanjutnya"
        }
        Pastikan outputnya BUKAN markdown, HANYA JSON.
      ''';

      final response = await model.generateContent([Content.text(prompt)]);

      final responseText = response.text ?? '{}';
      final cleanedJSON = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final parsedJSON = json.decode(cleanedJSON) as Map<String, dynamic>;

      await context.read<AnalysisService>().saveAnalysisRecord({
        'text': _textController.text,
        'analysisResult': parsedJSON,
      });

      setState(() {
        _analysisResult = parsedJSON;
        _isAnalyzing = false;
        _loadHistory();
      });
    } catch (e) {
      debugPrint('Error calling Gemini API: \$e');
      // Fallback to dummy data on error
      final fallbackRes = {
        'summary':
            'Terdeteksi indikasi kelelahan kerja (burnout) yang disertai kecemasan ringan.',
        'detectedConditions': [
          {'name': 'Burnout', 'confidence': 85},
          {'name': 'Kecemasan (Anxiety)', 'confidence': 60},
        ],
        'indicators': [
          'Kelelahan berlebih',
          'Gangguan tidur',
          'Kecemasan terkait pekerjaan',
        ],
        'recommendation':
            'Disarankan untuk mengambil jeda sejenak dari rutinitas kerja dan melakukan sesi relaksasi mendalam.',
      };

      await context.read<AnalysisService>().saveAnalysisRecord({
        'text': _textController.text,
        'analysisResult': fallbackRes,
      });

      setState(() {
        _analysisResult = fallbackRes;
        _isAnalyzing = false;
        _loadHistory();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildInputSection(context)),
                      const SizedBox(width: 32),
                      Expanded(child: _buildResultSection(context)),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildInputSection(context),
                    const SizedBox(height: 32),
                    _buildResultSection(context),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            'AI Intelligence',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Analisis Kesehatan Mental',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ceritakan apa yang kamu rasakan lewat suara atau tulisan. Safea akan mendeteksi tingkat stres, kecemasan, atau indikasi burnout.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sesi Bercerita',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              enabled: !_isRecording && !_isAnalyzing,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText:
                    'Bagaimana perasaanmu hari ini? Ceritakan dengan bebas...',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : _toggleRecording,
                    icon: Icon(
                      _isRecording ? LucideIcons.stopCircle : LucideIcons.mic,
                    ),
                    label: Text(
                      _isRecording ? 'Stop Merekam (SER)' : 'Mulai Bicara',
                    ),
                    style: _isRecording
                        ? OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _isRecording ||
                            _isAnalyzing ||
                            _textController.text.trim().isEmpty
                        ? null
                        : _handleAnalyze,
                    child: Text(
                      _isAnalyzing ? 'Menganalisis...' : 'Analisis Sekarang',
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

  Widget _buildResultSection(BuildContext context) {
    if (_isAnalyzing) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('NLP sedang memproses ceritamu...'),
            ],
          ),
        ),
      );
    }

    if (_analysisResult != null) {
      return Card(
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hasil Deteksi AI',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kesimpulan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _analysisResult!['summary'],
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kondisi Terdeteksi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...(_analysisResult!['detectedConditions'] as List).map((cond) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cond['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${cond['confidence']}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: cond['confidence'] / 100,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                        minHeight: 8,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              const Text(
                'Indikator',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: (_analysisResult!['indicators'] as List).map((ind) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.checkCircle2,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ind,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          LucideIcons.alertTriangle,
                          size: 16,
                          color: Color(0xFF818CF8),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Rekomendasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _analysisResult!['recommendation'],
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.activity, size: 32, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Hasil analisis akan muncul di sini',
              style: TextStyle(color: Colors.grey),
            ),
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Riwayat Analisis Terakhir',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final record = _history[index];
                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 8,
                        left: 16,
                        right: 16,
                      ),
                      child: ListTile(
                        title: Text(
                          record['text'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          record['date'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        trailing: const Icon(
                          LucideIcons.chevronRight,
                          color: Colors.grey,
                          size: 16,
                        ),
                        onTap: () {
                          setState(() {
                            _textController.text = record['text'];
                            _analysisResult = record['analysisResult'];
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
