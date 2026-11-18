// MR VOID: calorie and macro calculator.
// Plain, deterministic math. The AI never calculates nutrition.
// NOTE: safety limits below are conservative defaults. Have a qualified
// nutritionist or doctor review them before public launch.

enum Sex { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum Goal { fatLoss, leanBulk, maintain }

class Targets {
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final bool floorApplied; // true if the minimum calorie limit raised the target

  const Targets({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.floorApplied,
  });
}

const int minAge = 18; // under-18 users are not supported in v1
const int minCaloriesFemale = 1200;
const int minCaloriesMale = 1500;

const Map<ActivityLevel, double> activityMultiplier = {
  ActivityLevel.sedentary: 1.2,
  ActivityLevel.light: 1.375,
  ActivityLevel.moderate: 1.55,
  ActivityLevel.active: 1.725,
  ActivityLevel.veryActive: 1.9,
};

/// Mifflin-St Jeor equation.
double calculateBmr({
  required Sex sex,
  required double weightKg,
  required double heightCm,
  required int age,
}) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  return sex == Sex.male ? base + 5 : base - 161;
}

/// Total daily energy expenditure.
double calculateTdee(double bmr, ActivityLevel level) =>
    bmr * activityMultiplier[level]!;

Targets calculateTargets({
  required Sex sex,
  required double weightKg,
  required double heightCm,
  required int age,
  required ActivityLevel activity,
  required Goal goal,
}) {
  if (age < minAge) {
    throw ArgumentError('MR VOID currently supports users aged 18 and above.');
  }
  if (weightKg <= 0 || heightCm <= 0) {
    throw ArgumentError('Weight and height must be positive.');
  }

  final bmr = calculateBmr(
      sex: sex, weightKg: weightKg, heightCm: heightCm, age: age);
  final tdee = calculateTdee(bmr, activity);

  // Goal adjustment: moderate deficit or small surplus.
  final goalFactor = switch (goal) {
    Goal.fatLoss => 0.80, // 20% deficit (never more than this)
    Goal.leanBulk => 1.10, // 10% surplus
    Goal.maintain => 1.0,
  };
  var calories = tdee * goalFactor;

  // Safety floor.
  final floor = sex == Sex.male ? minCaloriesMale : minCaloriesFemale;
  var floorApplied = false;
  if (calories < floor) {
    calories = floor.toDouble();
    floorApplied = true;
  }

  // Macros: protein by body weight, fat 25% of calories, carbs the rest.
  final proteinPerKg = switch (goal) {
    Goal.fatLoss => 2.0,
    Goal.leanBulk => 1.8,
    Goal.maintain => 1.6,
  };
  final proteinG = weightKg * proteinPerKg;
  final fatG = calories * 0.25 / 9;
  final carbsG = (calories - proteinG * 4 - fatG * 9) / 4;

  return Targets(
    calories: calories.round(),
    proteinG: proteinG.round(),
    carbsG: carbsG < 0 ? 0 : carbsG.round(),
    fatG: fatG.round(),
    floorApplied: floorApplied,
  );
}