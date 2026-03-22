import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:path/path.dart' as p;

import 'package:smart_student_ai/ai_service.dart';

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
    // For non-mobile platforms (Windows, macOS, Linux), use AI vision OCR immediately
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('Desktop platform detected. Using AI Vision OCR for better results.');
      return await _aiVisionFallback(filePath);
    }

    try {
      debugPrint('Starting Google ML Kit OCR for: $filePath');
      
      final file = File(filePath);
      if (!await file.exists()) {
        return 'File not found';
      }
      
      // Create text recognizer with Arabic support
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final InputImage visionImage = InputImage.fromFilePath(filePath);
      
      final RecognizedText recognizedText = await textRecognizer.processImage(visionImage);
      await textRecognizer.close();
      
      final extractedText = recognizedText.text;
      if (extractedText.trim().isNotEmpty) {
        return extractedText;
      }
      
      // If no text found, try Tesseract
      debugPrint('ML Kit found no text. Trying Tesseract...');
      return await _fallbackToTesseract(filePath);
    } catch (e) {
      debugPrint('Google ML Kit OCR failed: $e');
      // If ML Kit fails, try Tesseract
      return await _fallbackToTesseract(filePath);
    }
  }

  Future<String> _fallbackToTesseract(String filePath) async {
    try {
      final extractedText = await TesseractOcr.extractText(filePath);
      if (extractedText.trim().isNotEmpty) {
        return extractedText;
      }
      // If Tesseract also has no text, try AI
      return await _aiVisionFallback(filePath);
    } catch (e) {
      debugPrint('Tesseract OCR failed: $e');
      // Final fallback to AI for highest reliability
      return await _aiVisionFallback(filePath);
    }
  }

  Future<String> _aiVisionFallback(String filePath) async {
    try {
      debugPrint('Using AI Vision OCR as fallback/primary for: $filePath');
      final file = File(filePath);
      return await AIService.extractTextFromImage(file);
    } catch (e) {
      return 'OCR Error: All methods failed (ML Kit, Tesseract, and AI). ${e.toString()}';
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
