import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final Function(String) onTextChanged;

  const TextInput({Key? key, required this.onTextChanged}) : super(key: key);

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final TextEditingController _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onTextChanged(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    widget.onTextChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.text_fields,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: 12),
                Text(
                  'Text Input',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Describe the plant disease symptoms in detail',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          // Text Input Card
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
                    children: [
                      Icon(
                        Icons.edit_note,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Enter Description:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      if (_controller.text.isNotEmpty)
                        IconButton(
                          onPressed: _clearText,
                          icon: Icon(Icons.clear),
                          color: theme.colorScheme.error,
                          tooltip: 'Clear',
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: 10,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText:
                            'Example: My tomato plants have yellow spots on leaves and are wilting during the day. '
                            'The spots started small and are spreading. I noticed some white powder on the stems.',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),
          // Guidelines Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.tertiary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'What to include:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildGuidelineItem(
                    context,
                    Icons.eco,
                    'Crop type and variety',
                    theme,
                  ),
                  SizedBox(height: 8),
                  _buildGuidelineItem(
                    context,
                    Icons.visibility,
                    'Specific symptoms observed',
                    theme,
                  ),
                  SizedBox(height: 8),
                  _buildGuidelineItem(
                    context,
                    Icons.calendar_today,
                    'When symptoms started',
                    theme,
                  ),
                  SizedBox(height: 8),
                  _buildGuidelineItem(
                    context,
                    Icons.wb_sunny,
                    'Weather conditions',
                    theme,
                  ),
                  SizedBox(height: 8),
                  _buildGuidelineItem(
                    context,
                    Icons.medical_services,
                    'Any treatments already tried',
                    theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(
    BuildContext context,
    IconData icon,
    String text,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
