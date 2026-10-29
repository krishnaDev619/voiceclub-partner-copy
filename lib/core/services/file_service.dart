import 'dart:io';

class FileService {
  static String getFileExtension(File file) {
    // Get the path of the file
    String filePath = file.path;

    // Find the last occurrence of a period (.) in the file path
    int lastIndex = filePath.lastIndexOf('.');

    if (lastIndex != -1 && lastIndex < filePath.length - 1) {
      // Extract the substring starting from the last period to the end
      String extension = filePath.substring(lastIndex + 1);
      return extension.toLowerCase(); // Optionally, convert to lowercase
    }

    // If no period was found, or it was the last character, return an empty string
    return '';
  }
}
