import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

Future<String?> uploadFileToCloudinary(String filePath) async {
  print('File path: $filePath');
  final uri = Uri.parse('https://api.cloudinary.com/v1_1/htpfwx3jv/image/upload');
  final mimeTypeData = lookupMimeType(filePath, headerBytes: [0xFF, 0xD8])?.split('/');

  if (mimeTypeData == null) {
    print('Could not determine MIME type');
    return null;
  }

  final file = File(filePath);
  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = 'ml_api'
    ..files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      ),
    );

  try {
    final response = await request.send();
    print('Cloudinary response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      print('Cloudinary response data: $jsonResponse');
      return jsonResponse['secure_url'];
    } else {
      final responseData = await response.stream.bytesToString();
      print('File upload failed: ${response.reasonPhrase}, Response data: $responseData');
      return null;
    }
  } catch (e) {
    print('Exception during file upload: $e');
    return null;
  }
}
