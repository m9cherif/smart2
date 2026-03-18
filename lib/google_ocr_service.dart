import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:path/path.dart' as p;

class GoogleOCRService {
  Future<String> readText(String filePath) async {
    final extension = p.extension(filePath).toLowerCase();
    
    // Handle plain text files
    if (_plainTextExtensions.contains(extension)) {
      return _readPlainText(filePath);
    }
    
    // Check if file is supported image format
    if (extension.isNotEmpty && !_imageExtensions.contains(extension)) {
      throw UnsupportedError('Unsupported file type: $extension');
    }

    return _readImageText(filePath);
  }

  Future<String> _readPlainText(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      debugPrint('Error reading plain text file: $e');
      return '';
    }
  }

  Future<String> _readImageText(String filePath) async {
    // Check if platform supports Google ML Kit
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('Google ML Kit not supported on this platform. Falling back to Tesseract OCR.');
      return await _fallbackToTesseract(filePath);
    }

    try {
      debugPrint('Starting Google ML Kit OCR for: $filePath');
      
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('File does not exist: $filePath');
        return 'File not found';
      }
      
      // Check file size
      final fileSize = await file.length();
      debugPrint('File size: $fileSize bytes');
      if (fileSize == 0) {
        debugPrint('File is empty');
        return 'File is empty';
      }
      
      // Create text recognizer with Arabic support
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      debugPrint('Text recognizer created');
      
      // Create input image with error handling
      InputImage? visionImage;
      try {
        visionImage = InputImage.fromFilePath(filePath);
        debugPrint('InputImage created successfully');
      } catch (e) {
        debugPrint('Failed to create InputImage: $e');
        return 'Failed to process image';
      }
      
      if (visionImage == null) {
        debugPrint('InputImage is null');
        return 'Failed to load image';
      }
      
      // Process the image
      final RecognizedText recognizedText = await textRecognizer.processImage(visionImage!);
      debugPrint('Image processed successfully');
      
      // Close recognizer to free resources
      await textRecognizer.close();
      
      final extractedText = recognizedText.text;
      debugPrint('Google ML Kit detected text: "$extractedText"');
      debugPrint('Text length: ${extractedText.length}');
      debugPrint('Text blocks found: ${recognizedText.blocks.length}');
      
      // Return the extracted text
      if (extractedText.isNotEmpty) {
        return extractedText;
      } else if (recognizedText.blocks.isNotEmpty) {
        return 'Found ${recognizedText.blocks.length} text blocks but no readable text';
      } else {
        return 'No text detected in image';
      }
    } catch (e) {
      debugPrint('Google ML Kit OCR failed: $e');
      debugPrint('Error stack trace: ${StackTrace.current}');
      // Fallback to Tesseract if Google ML Kit fails
      debugPrint('Falling back to Tesseract OCR...');
      return await _fallbackToTesseract(filePath);
    }
  }

  Future<String> _fallbackToTesseract(String filePath) async {
    try {
      // Use Tesseract OCR static method
      final extractedText = await TesseractOcr.extractText(filePath);
      
      debugPrint('Tesseract OCR result: "$extractedText"');
      return extractedText.isNotEmpty ? extractedText : 'No text detected with Tesseract OCR';
    } catch (e) {
      debugPrint('Tesseract OCR failed: $e');
      return 'OCR Error: Both Google ML Kit and Tesseract failed. ${e.toString()}';
    }
  }

  static const Set<String> _imageExtensions = <String>{
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp',
    '.webp',
    '.heic',
  };

  static const Set<String> _plainTextExtensions = <String>{
    '.txt',
    '.md',
    '.csv',
    '.json',
  };
}
