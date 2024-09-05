class StudentData {
  String? lockerInfo,
      formattedName,
      permId,
      gender,
      grade,
      address,
      lastNameGoesBy,
      nickname,
      birthdate,
      email,
      phone,
      homeLanguage,
      currentSchool,
      homeroomTeacher,
      homeroomTeacherEmail,
      homeroom,
      counselorName,
      photo,
      physicianName,
      physicianPhone,
      dentistName,
      dentistPhone;

  StudentData({required this.lockerInfo, required this.formattedName, required this.permId, required this.gender, required this.grade, required this.address, required this.lastNameGoesBy, required this.nickname, required this.birthdate, required this.email, required this.phone, required this.homeLanguage, required this.currentSchool, required this.homeroomTeacher, required this.homeroomTeacherEmail, required this.homeroom, required this.counselorName, required this.photo, required this.physicianName, required this.physicianPhone, required this.dentistName, required this.dentistPhone});

  @override
  String toString() {
    return 'StudentData{lockerInfo: $lockerInfo, formattedName: $formattedName, permId: $permId, gender: $gender, grade: $grade, address: $address, lastNameGoesBy: $lastNameGoesBy, nickname: $nickname, birthdate: $birthdate, email: $email, phone: $phone, homeLanguage: $homeLanguage, currentSchool: $currentSchool, homeroomTeacher: $homeroomTeacher, homeroomTeacherEmail: $homeroomTeacherEmail, homeroom: $homeroom, counselorName: $counselorName, photo: $photo, physicianName: $physicianName, physicianPhone: $physicianPhone, dentistName: $dentistName, dentistPhone: $dentistPhone}';
  }
}