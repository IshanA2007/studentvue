import 'package:studentvueclient/studentvueclient.dart';
import 'dart:convert';
import 'dart:io';

void saveDocumentAsPdf(String documentContent, String documentGUID) async {
  // Trim any extra whitespace from the document content
  documentContent = documentContent.trim();

  // Base64 decode the document content
  List<int> decodedBytes = base64.decode(documentContent);

  // Create a file to save the PDF
  String filePath = './$documentGUID.pdf';  // Save the file with the document GUID as the name
  File pdfFile = File(filePath);

  // Write the decoded bytes to the PDF file
  await pdfFile.writeAsBytes(decodedBytes);

  print('PDF saved to: $filePath');
}
void main() async {
  // Replace with real credentials for actual testing
  String username = "username";
  String password = "password";
  String domain = 'sisstudent.fcps.edu';

  // Initialize the StudentVueClient
  var client = StudentVueClient(username, password, domain);

  // Test listDocuments
  print('Fetching student documents...');
  var documents = await client.listDocuments();
  print('Documents: $documents');

  // Test getDocument (assuming a valid document GUID)
  if (documents.isNotEmpty) {
    documents.forEach((documentGUID) async {
      print('Fetching document content for GUID: $documentGUID...');
      var documentContent = await client.getDocument(documentGUID);
      documentContent = documentContent.trim(); // Trim any whitespace
      saveDocumentAsPdf(documentContent, documentGUID);
    });
  }
}