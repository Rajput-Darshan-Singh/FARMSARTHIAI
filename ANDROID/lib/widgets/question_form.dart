import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../app_localizations.dart';

class QuestionForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const QuestionForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _QuestionFormState createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final Map<String, dynamic> _answers = {};
  int _currentQuestionIndex = 0;

  final List<Question> _questions = diagnosticQuestions;

  void _answerQuestion(String questionId, dynamic answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _submitForm();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    }
  }

  void _submitForm() {
    if (_answers.length >= 3) {
      // Require at least 3 answers
      widget.onSubmit(_answers);
      Navigator.pop(context);
    } else {
      final appLocalizations = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appLocalizations.translate('answerAtLeast3'))),
      );
    }
  }

  Widget _buildQuestion(Question question) {
    final currentAnswer = _answers[question.id];

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context).translate('question')} ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              question.text,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (question.type == 'single')
              ...question.options.map((option) =>
                  _buildSingleOption(question.id, option, currentAnswer)),
            if (question.type == 'multiple')
              ...question.options.map((option) =>
                  _buildMultipleOption(question.id, option, currentAnswer)),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleOption(
      String questionId, String option, dynamic currentAnswer) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Radio<String>(
          value: option,
          groupValue: currentAnswer,
          onChanged: (value) => _answerQuestion(questionId, value),
        ),
        title: Text(option),
        onTap: () => _answerQuestion(questionId, option),
      ),
    );
  }

  Widget _buildMultipleOption(
      String questionId, String option, dynamic currentAnswer) {
    final List<String> selected =
        currentAnswer is List ? List<String>.from(currentAnswer) : [];
    final isSelected = selected.contains(option);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (checked) {
            final newSelected = List<String>.from(selected);
            if (checked == true) {
              newSelected.add(option);
            } else {
              newSelected.remove(option);
            }
            _answerQuestion(questionId, newSelected);
          },
        ),
        title: Text(option),
        onTap: () {
          final newSelected = List<String>.from(selected);
          if (isSelected) {
            newSelected.remove(option);
          } else {
            newSelected.add(option);
          }
          _answerQuestion(questionId, newSelected);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          AppBar(
            title: Text(
                AppLocalizations.of(context).translate('additionalQuestions')),
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SizedBox(height: 16),
          Expanded(child: _buildQuestion(currentQuestion)),
          SizedBox(height: 16),
          Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    child: Text(
                        AppLocalizations.of(context).translate('previous')),
                  ),
                ),
              if (_currentQuestionIndex > 0) SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _answers.containsKey(currentQuestion.id)
                      ? _nextQuestion
                      : null,
                  child: Text(_currentQuestionIndex == _questions.length - 1
                      ? AppLocalizations.of(context).translate('submit')
                      : AppLocalizations.of(context).translate('next')),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
          ),
        ],
      ),
    );
  }
}
