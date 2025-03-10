import 'package:dio/dio.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:studentvueclient/src/mockresponses.dart';
import 'package:studentvueclient/src/zip_code_result.dart';
import 'studentdata.dart';
import 'package:xml/xml.dart';
import 'studentgradedata.dart';

// void debugPrint(dynamic d) {
//   print(d);
// }

class StudentVueClient {
  final domain;
  String reqURL = "";

  final bool mock;
  final String username, password;
  final bool studentAccount;
  final int reportPeriod = 1;
  StudentVueClient(this.username, this.password, this.domain,
      {this.studentAccount = true, this.mock = false}) {
    reqURL = 'https://' + domain + '/SVUE/Service/PXPCommunication.asmx?WSDL';
  }

  final Dio _dio = Dio(BaseOptions(validateStatus: (_) => true));

  Future<int> getAbsences({required Function(double) callback}) async {
    String requestData = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
        <ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/">
            <userID>$username</userID>
            <password>$password</password>
            <skipLoginLog>1</skipLoginLog>
            <parent>${studentAccount ? '0' : '1'}</parent>
            <webServiceHandleName>PXPWebServices</webServiceHandleName>
            <methodName>Attendance</methodName>
            <paramStr>&lt;Parms&gt;&lt;ChildIntID&gt;0&lt;/ChildIntID&gt;&lt;/Parms&gt;</paramStr>
        </ProcessWebServiceRequest>
    </soap:Body>
  </soap:Envelope>''';

    var headers = <String, String>{'Content-Type': 'text/xml'};

    // Making the request
    var res = await _dio
        .post(reqURL, data: requestData, options: Options(headers: headers),
            onSendProgress: (int sent, int total) {
      callback((sent / total) * 0.5);
    }, onReceiveProgress: (int received, int total) {
      callback((received / total) * 0.5 + 0.5);
    });

    String resData = res.data;

    final document = XmlDocument.parse(HtmlUnescape().convert(resData));

    // Check if there's an error
    if (resData.contains('Invalid user id or password')) {
      throw Exception('Invalid user id or password');
    }

    // Collect distinct absence dates
    var absences = document.findAllElements('Absence');
    var absenceDates = <String>{}; // Using a Set to store unique dates

    for (var absence in absences) {
      var absenceDate = absence.getAttribute('AbsenceDate');
      if (absenceDate != null && absenceDate.isNotEmpty) {
        absenceDates.add(absenceDate);
      }
    }

    // Return the number of distinct absence dates
    return absenceDates.length;
  }

  Future<StudentGradeData> loadGradebook(
      {required Function(double) callback, int? reportPeriod}) async {
    String resData;
    if (!mock) {
      var requestData = reportPeriod != null
          ? '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
          <ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/">
              <userID>$username</userID>
              <password>$password</password>
              <skipLoginLog>1</skipLoginLog>
              <parent>${studentAccount ? '0' : '1'}</parent>
              <webServiceHandleName>PXPWebServices</webServiceHandleName>
              <methodName>Gradebook</methodName>
              <paramStr>&lt;Parms&gt;&lt;ChildIntID&gt;0&lt;/ChildIntID&gt;&lt;ReportPeriod&gt;$reportPeriod&lt;/ReportPeriod&gt;&lt;/Parms&gt;</paramStr>
          </ProcessWebServiceRequest>
      </soap:Body>
    </soap:Envelope>'''
          : '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
          <ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/">
              <userID>$username</userID>
              <password>$password</password>
              <skipLoginLog>1</skipLoginLog>
              <parent>${studentAccount ? '0' : '1'}</parent>
              <webServiceHandleName>PXPWebServices</webServiceHandleName>
              <methodName>Gradebook</methodName>
              <paramStr>&lt;Parms&gt;&lt;ChildIntID&gt;0&lt;/ChildIntID&gt;&lt;/Parms&gt;</paramStr>
          </ProcessWebServiceRequest>
      </soap:Body>
    </soap:Envelope>''';

      // Define headers with String values
      var headers = <String, String>{
        'Content-Type': 'text/xml',
      };

// Pass the headers to the Dio request
      var res = await _dio
          .post(reqURL, data: requestData, options: Options(headers: headers),
              onSendProgress: (int sent, int total) {
        callback((sent / total) * 0.5);
      }, onReceiveProgress: (int received, int total) {
        callback((received / total) * 0.5 + 0.5);
      });

      resData = res.data;
    } else {
      resData = MockResponses.GradebookResponse;
    }

    final document = XmlDocument.parse(HtmlUnescape().convert(resData));
    // await Future.delayed(const Duration(milliseconds: 1500));
//    final document = XmlDocument.parse(testData);
    if (resData.contains('Invalid user id or password')) {
      return StudentGradeData()..error = 'Invalid user id or password';
    }
    if (resData.contains('The user name or password is incorrect')) {
      return StudentGradeData()
        ..error = 'The user name or password is incorrect';
    }
    var currentMP = document
        .findAllElements('ReportingPeriod')
        .first
        .getAttribute('GradePeriod');

    var report_periods = document.findAllElements("ReportPeriod");
    // loop through report periods, find the one where it's GradePeriod = currentMP, get its Index, then index+1
    var quarter = -1;
    report_periods.forEach((rep_period) {
      if (rep_period.getAttribute("GradePeriod") == currentMP) {
        quarter = int.parse(rep_period.getAttribute('Index') ?? "-3") + 1;
      }
    });
    var svData = StudentGradeData();
    svData.quarter = quarter;

    var courses = document.findAllElements('Courses').first;
    var classes = <SchoolClass>[];
    for (var i = 0; i < courses.children.length; i++) {
      var current = courses.children[i];
//      debugPrint('adding: $current');
      if (current.getAttribute('Title') == null) continue;
      var _class = SchoolClass();
      // when regex in doubt
//      _class.className = current.getAttribute('Title').replaceAll(RegExp('\(([A-Z])\w+\)'), '');
      // take the easy way out
      _class.className = current
          .getAttribute('Title')!
          .substring(0, current.getAttribute('Title')?.indexOf('('));
      _class.period = int.tryParse(current.getAttribute('Period') ?? '0') ?? -1;
      _class.roomNumber = current.getAttribute('Room') ?? 'N/A';
      _class.classTeacher = current.getAttribute('Staff') ?? 'N/A';
      _class.classTeacherEmail = current.getAttribute('StaffEMail') ?? 'N/A';

      var mark = current.findAllElements('Mark').first;

      _class.pctGrade = mark.getAttribute('CalculatedScoreRaw');
      _class.letterGrade = mark.getAttribute('CalculatedScoreString');

      current = current.findAllElements('GradeCalculationSummary').first;

      _class.assignmentCategories = <AssignmentCategory>[];
      for (var i = 0; i < current.children.length; i++) {
        if (current.children[i].getAttribute('Type') == 'TOTAL') {
          _class.earnedPoints = double.tryParse(
              current.children[i].getAttribute('Points')?.replaceAll(",", "") ?? '')!;
          _class.earnedPoints = double.tryParse(
              current.children[i].getAttribute('PointsPossible')?.replaceAll(",", "") ?? '')!;
          _class.pctGrade ??= current.children[i]
              .getAttribute('WeightedPct'); // replace only if it's already null
        } // else {
        var category = AssignmentCategory();
        category.name = current.children[i].getAttribute('Type');
        category.weight = double.tryParse(
                (current.children[i].getAttribute('Weight') ?? '')
                    .replaceAll('%', '')) ??
            0.0;
        category.earnedPoints =
            double.tryParse(current.children[i].getAttribute('Points')?.replaceAll(",", "") ?? '') ??
                0.0;
        category.possiblePoints = double.tryParse(
                current.children[i].getAttribute('PointsPossible')?.replaceAll(",", "") ?? '') ??
            0.0;
        _class.assignmentCategories.add(category);
//          debugPrint('added category for class ${_class.className} : ${category}');
        // }
      }

      current = current.parent!.findAllElements('Assignments').first;

      _class.assignments = <Assignment>[];
      for (var i = 0; i < current.children.length; i++) {
        var ass = Assignment();
        ass.assignmentName =
            current.children[i].getAttribute('Measure') ?? 'Assignment';
        ass.notes = current.children[i].getAttribute('Notes') ?? '';
        ass.category =
            current.children[i].getAttribute('Type') ?? 'No Category';
        ass.date = current.children[i].getAttribute('DueDate') ?? '';
        ass.earnedPoints =
            current.children[i].getAttribute('Score') == 'Not Graded'
                ? -1
                : double.tryParse(
                        (current.children[i].getAttribute('Points') ?? 'N/A')
                            .replaceAll(' ', '')
                            .split('/')[0]) ??
                    -1;
        if (current.children[i].getAttribute('Score') == 'Not Graded') {
          ass.possiblePoints = double.tryParse(
              (current.children[i].getAttribute('Points') ?? '')
                  .replaceAll(' Points Possible', ''))!;
        } else {
//          ass.possiblePoints = double.tryParse(current.children[i].getAttribute('Score') ?? '') == null ? -1 : double.tryParse((current.children[i].getAttribute('Points') ?? 'N/A').replaceAll(' ', '').split('/').last) ?? -1;
          if (double.tryParse(
                  current.children[i].getAttribute('Score') ?? 'N/A') ==
              null) {
            var pointsStr =
                (current.children[i].getAttribute('Points') ?? 'N/A')
                    .replaceAll(' ', '')
                    .split('/');
            if (pointsStr.length < 2) {
              ass.possiblePoints = -1;
            } else {
              var pp = double.tryParse(pointsStr[1]);
              ass.possiblePoints = pp ?? -1;
            }
          } else {
            ass.possiblePoints = double.tryParse(
                current.children[i].getAttribute('Score') ?? 'N/A')!;
          }
        }
        _class.assignments.add(ass);
      }

      classes.add(_class);
    }
    svData.classes = classes;

    return svData;
  }

  Future<StudentData> loadStudentData(
      {required Function(double) callback}) async {
    String resData;
    if (!mock) {
      var requestData = '''<?xml version="1.0" encoding="utf-8"?>
  <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
          <ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/">
              <userID>$username</userID>
              <password>$password</password>
              <skipLoginLog>1</skipLoginLog>
              <parent>${studentAccount ? '0' : '1'}</parent>
              <webServiceHandleName>PXPWebServices</webServiceHandleName>
              <methodName>StudentInfo</methodName>
              <paramStr>&lt;Parms&gt;&lt;ChildIntID&gt;0&lt;/ChildIntID&gt;&lt;/Parms&gt;</paramStr>
          </ProcessWebServiceRequest>
      </soap:Body>
  </soap:Envelope>''';

      var headers = <String, String>{'Content-Type': 'text/xml'};

      var res = await _dio.post(reqURL,
          data: requestData,
          options: Options(headers: headers), onSendProgress: (one, two) {
        callback((one / two) * 0.5);
      }, onReceiveProgress: (one, two) {
        callback((one / two) * 0.5 + 0.5);
      });
      resData = res.data;
    } else {
      resData = MockResponses.StudentInfoResponse;
    }

    final document = XmlDocument.parse(HtmlUnescape().convert(resData));

    // the StudentInfo element is inside four other dumb elements
    final el = document.root.firstElementChild?.firstElementChild
        ?.firstElementChild?.firstElementChild?.firstElementChild;

    return StudentData(
      lockerInfo: el?.getElement('LockerInfoRecords')?.innerText,
      formattedName: el?.getElement('FormattedName')?.innerText,
      permId: el?.getElement('PermID')?.innerText,
      gender: el?.getElement('Gender')?.innerText,
      grade: el?.getElement('Grade')?.innerText,
      address: el?.getElement('Address')?.innerText,
      lastNameGoesBy: el?.getElement('LastNameGoesBy')?.innerText,
      nickname: el?.getElement('NickName')?.innerText,
      birthdate: el?.getElement('BirthDate')?.innerText,
      email: el?.getElement('EMail')?.innerText,
      phone: el?.getElement('Phone')?.innerText,
      homeLanguage: el?.getElement('HomeLanguage')?.innerText,
      currentSchool: el?.getElement('CurrentSchool')?.innerText,
      homeroomTeacher: el?.getElement('HomeRoomTch')?.innerText,
      homeroomTeacherEmail: el?.getElement('HomeRoomTchEMail')?.innerText,
      homeroom: el?.getElement('HomeRoom')?.innerText,
      counselorName: el?.getElement('CounselorName')?.innerText,
      photo: el?.getElement('Photo')?.innerText,
      physicianName: el?.getElement('Physician')?.getAttribute('Name'),
      physicianPhone: el?.getElement('Physician')?.getAttribute('Phone'),
      dentistName: el?.getElement('Dentist')?.getAttribute('Name'),
      dentistPhone: el?.getElement('Dentist')?.getAttribute('Phone'),
    );
  }

  // Report Card / Document Code
  Future<List<String>> listReportCards(
      {required Function(double) callback}) async {
    String requestData = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/">
          <userID>$username</userID>
          <password>$password</password>
          <skipLoginLog>1</skipLoginLog>
          <parent>${studentAccount ? '0' : '1'}</parent>
          <webServiceHandleName>PXPWebServices</webServiceHandleName>
          <methodName>GetReportCardInitialData</methodName>
          <paramStr>&lt;Parms&gt;&lt;/Parms&gt;</paramStr>
        </ProcessWebServiceRequest>
      </soap:Body>
    </soap:Envelope>''';

    var headers = {'Content-Type': 'text/xml'};
    var res = await _dio.post(reqURL,
        data: requestData, options: Options(headers: headers));
    var resData = res.data;

    // Log the full raw response to see what's being returned


    // Parse XML response
    final document = XmlDocument.parse(HtmlUnescape().convert(resData));
    var reportCards = <String>[];

    // Loop through each <ReportCard> element and extract relevant data
    var reportCardElements = document.findAllElements('ReportCard');
    for (var reportCard in reportCardElements) {
      var documentGUID = reportCard.getAttribute('DocumentGUID') ?? '';
      reportCards.add(documentGUID); // Add GUID to the list
    }

    return reportCards;
  }

  Future<String> getReportCard(String documentGUID) async {
    String requestData = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/">
          <userID>$username</userID>
          <password>$password</password>
          <skipLoginLog>1</skipLoginLog>
          <parent>${studentAccount ? '0' : '1'}</parent>
          <webServiceHandleName>PXPWebServices</webServiceHandleName>
          <methodName>GetReportCardDocumentData</methodName>
          <paramStr>&lt;Parms&gt;&lt;DocumentGU&gt;$documentGUID&lt;/DocumentGU&gt;&lt;/Parms&gt;</paramStr>
        </ProcessWebServiceRequest>
      </soap:Body>
    </soap:Envelope>''';

    var headers = {'Content-Type': 'text/xml'};
    var res = await _dio.post(reqURL,
        data: requestData, options: Options(headers: headers));
    var resData = res.data;

    // Parse XML response and extract report card data (likely in a <Document> element)
    final document = XmlDocument.parse(HtmlUnescape().convert(resData));
    var reportCardContent = document.rootElement
        .innerText; // Assuming it's in the root or a specific element
    return reportCardContent;
  }

  Future<List<String>> listDocuments() async {
    String requestData = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/">
          <userID>$username</userID>
          <password>$password</password>
          <skipLoginLog>1</skipLoginLog>
          <parent>${studentAccount ? '0' : '1'}</parent>
          <webServiceHandleName>PXPWebServices</webServiceHandleName>
          <methodName>GetStudentDocumentInitialData</methodName>
          <paramStr>&lt;Parms&gt;&lt;/Parms&gt;</paramStr>
        </ProcessWebServiceRequest>
      </soap:Body>
    </soap:Envelope>''';

    var headers = {'Content-Type': 'text/xml'};
    var res = await _dio.post(reqURL,
        data: requestData, options: Options(headers: headers));
    var resData = res.data;

    // First, unescape the content inside <ProcessWebServiceRequestResult>
    final document = XmlDocument.parse(resData);
    var result =
        document.findAllElements('ProcessWebServiceRequestResult').first.text;
    var unescapedResult = HtmlUnescape().convert(result);

    // Now, parse the unescaped result as XML
    final unescapedDocument = XmlDocument.parse(unescapedResult);
    var documents = <String>[];

    // Loop through <StudentDocumentData> elements and extract DocumentGU
    var documentElements =
        unescapedDocument.findAllElements('StudentDocumentData');
    for (var doc in documentElements) {
      var documentGUID = doc.getAttribute('DocumentGU') ?? '';
      documents.add(documentGUID); // Add GUID to list
    }

    return documents;
  }

  Future<String> getDocument(String documentGUID) async {
    String requestData = '''<?xml version="1.0" encoding="utf-8"?>
    <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
      <soap:Body>
        <ProcessWebServiceRequest xmlns="http://edupoint.com/webservices/">
          <userID>$username</userID>
          <password>$password</password>
          <skipLoginLog>1</skipLoginLog>
          <parent>${studentAccount ? '0' : '1'}</parent>
          <webServiceHandleName>PXPWebServices</webServiceHandleName>
          <methodName>GetContentOfAttachedDoc</methodName>
          <paramStr>&lt;Parms&gt;&lt;DocumentGU&gt;$documentGUID&lt;/DocumentGU&gt;&lt;/Parms&gt;</paramStr>
        </ProcessWebServiceRequest>
      </soap:Body>
    </soap:Envelope>''';

    var headers = {'Content-Type': 'text/xml'};
    var res = await _dio.post(reqURL,
        data: requestData, options: Options(headers: headers));
    var resData = res.data;

    // Parse XML response and extract document content
    final document = XmlDocument.parse(HtmlUnescape().convert(resData));
    var documentContent = document
        .rootElement.innerText; // Extract the actual content of the document
    return documentContent;
  }

  static Future<List<ZipCodeResult>> loadDistrictsFromZip(String zip,
      {required Function(double) callback, bool mock = false}) async {
    String resData;
    if (!mock) {
      var requestData = '''<?xml version="1.0" encoding="utf-8"?>
<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">
    <v:Header />
    <v:Body>
        <ProcessWebServiceRequestMultiWeb xmlns="http://edupoint.com/webservices/" id="o0" c:root="1">
            <userID i:type="d:string">EdupointDistrictInfo</userID>
            <password i:type="d:string">Edup01nt</password>
            <skipLoginLog i:type="d:string">false</skipLoginLog>
            <parent i:type="d:string">false</parent>
            <webServiceHandleName i:type="d:string">HDInfoServices</webServiceHandleName>
            <methodName i:type="d:string">GetMatchingDistrictList</methodName>
            <paramStr i:type="d:string">&lt;Parms&gt;&lt;Key&gt;5E4B7859-B805-474B-A833-FDB15D205D40&lt;/Key&gt;&lt;MatchToDistrictZipCode&gt;$zip&lt;/MatchToDistrictZipCode&gt;&lt;/Parms&gt;</paramStr>
            <webDBName i:type="d:string"></webDBName>
        </ProcessWebServiceRequestMultiWeb>
    </v:Body>
</v:Envelope>''';

      var headers = <String, List<String>>{
        'Content-Type': ['text/xml']
      };

      final _dio = Dio(BaseOptions(validateStatus: (_) => true));
      var res = await _dio.post(
          'https://support.edupoint.com/Service/HDInfoCommunication.asmx',
          data: requestData,
          options: Options(headers: headers), onSendProgress: (one, two) {
        callback((one / two) * 0.5);
      }, onReceiveProgress: (one, two) {
        callback((one / two) * 0.5 + 0.5);
      });
      resData = res.data;
    } else {
      resData = MockResponses.ZipCodeResponse;
    }

    final document = XmlDocument.parse(HtmlUnescape().convert(resData));

    // print('${document.firstElementChild.firstElementChild.firstElementChild.firstElementChild.firstElementChild.firstElementChild.children[1].toString()}');

    return document.firstElementChild!.firstElementChild!.firstElementChild!
        .firstElementChild!.firstElementChild!.firstElementChild!.children
        .map((e) => ZipCodeResult(
            districtName: e.getAttribute('Name'),
            districtUrl: e.getAttribute('PvueURL')))
        .where((e) => e.districtUrl != null)
        .toList();
  }
}
