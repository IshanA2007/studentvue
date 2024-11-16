class StudentGradeData {
  List<SchoolClass> classes;
  String studentName;
  int quarter;
  String error;

  StudentGradeData({
    this.classes = const [],
    this.studentName = '',
    this.error = '',
    this.quarter = -1,
  });

  @override
  String toString() {
    return 'StudentGradeData{quarter: $quarter, classes: $classes, studentName: $studentName, error: $error}';
  }
}

class SchoolClass {
  String className;
  String classTeacher;
  String classTeacherEmail;
  String markingPeriod;
  String roomNumber;
  String? letterGrade;
  double earnedPoints;
  double possiblePoints;
  String? pctGrade;
  int period;
  List<AssignmentCategory> assignmentCategories;
  List<Assignment> assignments;

  SchoolClass({
    this.className = '',
    this.classTeacher = '',
    this.classTeacherEmail = '',
    this.markingPeriod = '',
    this.roomNumber = '',
    this.letterGrade,
    this.earnedPoints = 0.0,
    this.possiblePoints = 0.0,
    this.pctGrade,
    this.period = 0,
    this.assignmentCategories = const [],
    this.assignments = const [],
  });

  @override
  String toString() {
    return 'SchoolClass{className: $className, classTeacher: $classTeacher, classTeacherEmail: $classTeacherEmail, markingPeriod: $markingPeriod, roomNumber: $roomNumber, pctGrade: $pctGrade, earnedPoints: $earnedPoints, possiblePoints: $possiblePoints, period: $period, assignmentCategories: $assignmentCategories, assignments: $assignments}';
  }
}

class Assignment {
  String assignmentName;
  String date;
  String category;
  String notes;
  double earnedPoints;
  double possiblePoints;

  Assignment({
    this.assignmentName = '',
    this.date = '',
    this.category = '',
    this.notes = '',
    this.earnedPoints = 0.0,
    this.possiblePoints = 0.0,
  });

  // Override == operator for comparison based on attributes
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Assignment) return false;
    return assignmentName == other.assignmentName &&
        date == other.date &&
        category == other.category &&
        notes == other.notes &&
        earnedPoints == other.earnedPoints &&
        possiblePoints == other.possiblePoints;
  }

  // Override hashCode for consistent equality checks
  @override
  int get hashCode =>
      assignmentName.hashCode ^
      date.hashCode ^
      category.hashCode ^
      notes.hashCode ^
      earnedPoints.hashCode ^
      possiblePoints.hashCode;

  // Convert Assignment object to a Map
  Map<String, dynamic> toMap() {
    return {
      'assignmentName': assignmentName,
      'date': date,
      'category': category,
      'notes': notes,
      'earnedPoints': earnedPoints,
      'possiblePoints': possiblePoints,
    };
  }

  // Convert Map to an Assignment object
  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      assignmentName: map['assignmentName'] ?? '',
      date: map['date'] ?? '',
      category: map['category'] ?? '',
      notes: map['notes'] ?? '',
      earnedPoints: (map['earnedPoints'] ?? 0.0).toDouble(),
      possiblePoints: (map['possiblePoints'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Assignment{assignmentName: $assignmentName, date: $date, category: $category, earnedPoints: $earnedPoints, possiblePoints: $possiblePoints, notes: $notes}';
  }
}

class AssignmentCategory {
  double earnedPoints;
  double possiblePoints;
  double weight;
  String? name;

  AssignmentCategory({
    this.name,
    this.earnedPoints = 0.0,
    this.possiblePoints = 0.0,
    this.weight = 0.0,
  });

  // Convert AssignmentCategory object to a Map
  Map<String, dynamic> toMap() {
    return {
      'earnedPoints': earnedPoints,
      'possiblePoints': possiblePoints,
      'weight': weight,
      'name': name,
    };
  }

  // Convert Map to an AssignmentCategory object
  factory AssignmentCategory.fromMap(Map<String, dynamic> map) {
    return AssignmentCategory(
      earnedPoints: map['earnedPoints'] ?? 0.0,
      possiblePoints: map['possiblePoints'] ?? 0.0,
      weight: map['weight'] ?? 0.0,
      name: map['name'],
    );
  }

  @override
  String toString() {
    return 'AssignmentCategory{earnedPoints: $earnedPoints, possiblePoints: $possiblePoints, weight: $weight, name: $name}';
  }
}
