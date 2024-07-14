import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

Future<String?> uploadFileToCloudinary(String filePath) async {
  final uri = Uri.parse('https://api.cloudinary.com/v1_1/htpfwx3jv/image/upload');
  final mimeTypeData = lookupMimeType(filePath, headerBytes: [0xFF, 0xD8])?.split('/');

  final file = File(filePath);
  final request = http.MultipartRequest('POST', uri)
    ..fields['upload_preset'] = 'ml_default'
    ..files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
        contentType: MediaType(mimeTypeData![0], mimeTypeData[1]),
      ),
    );

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);
    return jsonResponse['secure_url'];
  } else {
    print('File upload failed: ${response.reasonPhrase}');
    return null;
  }
}
