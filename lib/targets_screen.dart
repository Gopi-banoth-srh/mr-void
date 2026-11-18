import 'package:material_ui/material_ui.dart';
import 'package:mr_void/calculator.dart';

class TargetsScreen extends StatefulWidget {
  const TargetsScreen({super.key});

  @override
  State<TargetsScreen> createState() => _TargetsScreenState();
}

class _TargetsScreenState extends State<TargetsScreen> {
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();

  Sex _sex = Sex.male;
  ActivityLevel _activity = ActivityLevel.moderate;
  Goal _goal = Goal.fatLoss;

  Targets? _targets;
  String? _error;

  @override
  void dispose() {
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  void _calculate() {
    final age = int.tryParse(_age.text.trim());
    final weight = double.tryParse(_weight.text.trim());
    final height = double.tryParse(_height.text.trim());

    if (age == null || weight == null || height == null) {
      setState(() {
        _targets = null;
        _error = 'Please enter valid numbers for age, weight and height.';
      });
      return;
    }

    try {
      final t = calculateTargets(
        sex: _sex,
        weightKg: weight,
        heightCm: height,
        age: age,
        activity: _activity,
        goal: _goal,
      );
      setState(() {
        _targets = t;
        _error = null;
      });
    } on ArgumentError catch (e) {
      setState(() {
        _targets = null;
        _error = e.message.toString();
      });
    }
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) text,
    required ValueChanged<T> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label)),
        Expanded(
          child: DropdownButton<T>(
            isExpanded: true,
            value: value,
            items: [
              for (final i in items)
                DropdownMenuItem(value: i, child: Text(text(i))),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _targets;
    return Scaffold(
      appBar: AppBar(title: const Text('MR VOID')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Your daily targets',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          _dropdown<Sex>(
            label: 'Sex',
            value: _sex,
            items: Sex.values,
            text: (s) => s == Sex.male ? 'Male' : 'Female',
            onChanged: (v) => setState(() => _sex = v),
          ),
          TextField(
            controller: _age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Age (years)'),
          ),
          TextField(
            controller: _weight,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
          ),
          TextField(
            controller: _height,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Height (cm)'),
          ),
          const SizedBox(height: 8),
          _dropdown<ActivityLevel>(
            label: 'Activity',
            value: _activity,
            items: ActivityLevel.values,
            text: (a) => switch (a) {
              ActivityLevel.sedentary => 'Sedentary',
              ActivityLevel.light => 'Light',
              ActivityLevel.moderate => 'Moderate',
              ActivityLevel.active => 'Active',
              ActivityLevel.veryActive => 'Very active',
            },
            onChanged: (v) => setState(() => _activity = v),
          ),
          _dropdown<Goal>(
            label: 'Goal',
            value: _goal,
            items: Goal.values,
            text: (g) => switch (g) {
              Goal.fatLoss => 'Fat loss',
              Goal.leanBulk => 'Lean bulk',
              Goal.maintain => 'Maintain',
            },
            onChanged: (v) => setState(() => _goal = v),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _calculate,
            child: const Text('Calculate'),
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Text(_error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (t != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${t.calories} kcal per day',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Protein: ${t.proteinG} g'),
                    Text('Carbs: ${t.carbsG} g'),
                    Text('Fat: ${t.fatG} g'),
                    if (t.floorApplied) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Your target was raised to a minimum safe level.',
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      'Estimates only, not medical advice.',
                      style: TextStyle(fontSize: 12),
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