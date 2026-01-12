import 'package:flutter/material.dart';
import '../app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInput extends StatefulWidget {
  final Function(String) onTextReceived;

  const VoiceInput({Key? key, required this.onTextReceived}) : super(key: key);

  @override
  _VoiceInputState createState() => _VoiceInputState();
}

class _VoiceInputState extends State<VoiceInput> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  void _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done') {
          _stopListening();
        }
      },
      onError: (error) {
        print('Speech error: $error');
        _stopListening();
      },
    );

    if (!available) {
      final appLocalizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                appLocalizations.translate('speechRecognitionUnavailable'))),
      );
    }
  }

  void _startListening() async {
    if (await _speech.hasPermission) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() => _text = result.recognizedWords);
          widget.onTextReceived(result.recognizedWords);
        },
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _clearText() {
    setState(() => _text = '');
    widget.onTextReceived('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.tertiary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.mic,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: 12),
                Text(
                  'Voice Input',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Describe the plant disease symptoms by speaking',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          // Microphone Button
          GestureDetector(
            onTap: _isListening ? _stopListening : _startListening,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [
                          theme.colorScheme.error,
                          theme.colorScheme.error.withOpacity(0.7),
                        ]
                      : [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 70,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Builder(builder: (context) {
                    final appLocalizations = AppLocalizations.of(context);
                    return Text(
                      _isListening
                          ? appLocalizations.translate('listening')
                          : appLocalizations.translate('tapToSpeak'),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          SizedBox(height: 40),
          // Recorded Text
          if (_text.isNotEmpty) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.text_fields,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('recordedText'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: _clearText,
                          color: theme.colorScheme.error,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        _text,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 24),
          // Tips Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.tertiary,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).translate('voiceInput_tip'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
