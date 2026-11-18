import 'package:flutter_test/flutter_test.dart';
import 'package:mr_void/calculator.dart';

void main() {
  test('BMR for 25y male, 70 kg, 175 cm', () {
    final bmr = calculateBmr(
        sex: Sex.male, weightKg: 70, heightCm: 175, age: 25);
    expect(bmr, closeTo(1673.75, 0.1));
  });

  test('BMR for 30y female, 60 kg, 165 cm', () {
    final bmr = calculateBmr(
        sex: Sex.female, weightKg: 60, heightCm: 165, age: 30);
    expect(bmr, closeTo(1320.25, 0.1));
  });

  test('Fat loss target for moderately active male', () {
    final t = calculateTargets(
      sex: Sex.male,
      weightKg: 70,
      heightCm: 175,
      age: 25,
      activity: ActivityLevel.moderate,
      goal: Goal.fatLoss,
    );
    expect(t.calories, 2075);
    expect(t.proteinG, 140);
    expect(t.floorApplied, false);
  });

  test('Safety floor stops unsafe low calories', () {
    final t = calculateTargets(
      sex: Sex.female,
      weightKg: 50,
      heightCm: 155,
      age: 40,
      activity: ActivityLevel.sedentary,
      goal: Goal.fatLoss,
    );
    expect(t.calories, 1200);
    expect(t.floorApplied, true);
  });

  test('Under-18 users are rejected', () {
    expect(
      () => calculateTargets(
        sex: Sex.male,
        weightKg: 60,
        heightCm: 170,
        age: 16,
        activity: ActivityLevel.light,
        goal: Goal.maintain,
      ),
      throwsArgumentError,
    );
  });
}