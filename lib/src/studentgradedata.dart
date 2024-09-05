class StudentGradeData {
  List<SchoolClass> classes;
  String studentName;
  String error;

  StudentGradeData({
    this.classes = const [],
    this.studentName = '',
    this.error = '',
  });

  @override
  String toString() {
    return 'StudentGradeData{classes: $classes, studentName: $studentName, error: $error}';
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

  @override
  String toString() {
    return 'AssignmentCategory{earnedPoints: $earnedPoints, possiblePoints: $possiblePoints, weight: $weight, name: $name}';
  }
}
