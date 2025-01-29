import 'dart:io';
import 'package:cloudinary/cloudinary.dart';

Future<String?> uploadImageToCloudinary(String filePath) async {
  final cloudinary = Cloudinary.signedConfig(
    apiKey: "564924757461558",
    apiSecret: "U_cfXbrL7sGK1tfBkYggRmPqU94",
    cloudName: "dwno7g81o",
  );

  final response = await cloudinary.upload(
    file: filePath,
    resourceType: CloudinaryResourceType.image,
    folder: "flutter_uploads", // Optional: Cloudinary folder name
  );

  return response.secureUrl; // Returns the uploaded image URL
}
