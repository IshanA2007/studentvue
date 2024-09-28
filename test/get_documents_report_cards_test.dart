import 'package:studentvueclient/studentvueclient.dart';
import 'dart:convert';
import 'dart:io';

void saveDocumentAsPdf(String documentContent, String documentGUID) async {
  // Trim any extra whitespace from the document content
  documentContent = documentContent.trim();

  // Base64 decode the document content
  List<int> decodedBytes = base64.decode(documentContent);

  // Create a file to save the PDF
  String filePath =
      './$documentGUID.pdf'; // Save the file with the document GUID as the name
  File pdfFile = File(filePath);

  // Write the decoded bytes to the PDF file
  await pdfFile.writeAsBytes(decodedBytes);

  print('PDF saved to: $filePath');
}

void main() async {
  // Replace with real credentials for actual testing
  String username = "1620426";
  String password = "";
  String domain = 'sisstudent.fcps.edu';

  // Initialize the StudentVueClient
  var client = StudentVueClient(username, password, domain);

  // Test listDocuments
  print('Fetching student documents...');
  var documents = await client.loadGradebook(
      reportPeriod: 1,
      callback: (progress) {
        print('Progress: $progress');
      });

  print(documents);
  var documents2 = await client.loadGradebook(callback: (progress) {
    print('Progress: $progress');
  });
  print(documents2);

  var absences = await client.getAbsences(callback: (progress) {
    print('Progress: $progress');
  });

  print(absences);
}
