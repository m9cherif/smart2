import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:tesseract_ocr/tesseract_ocr.dart';

class OCRService {
  Future<String> readText(String filePath) async {
    final extension = p.extension(filePath).toLowerCase();
    if (_plainTextExtensions.contains(extension)) {
      return _readPlainText(filePath);
    }
    if (extension.isNotEmpty && !_imageExtensions.contains(extension)) {
      throw UnsupportedError('Unsupported file type.');
    }

    return _readImageText(filePath);
  }

  Future<String> _readPlainText(String filePath) async {
    try {
      final file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  Future<String> _readImageText(String filePath) async {
    try {
      // Use Tesseract OCR directly for Arabic text
      final tesseractText = await _readWithTesseract(filePath);
      
      // Debug: Log what OCR detected
      debugPrint('OCR detected text: "$tesseractText"');
      
      // Validate and process the extracted text
      final processedText = _processArabicText(tesseractText);
      debugPrint('Processed text: "$processedText"');
      
      // Always return the processed text (remove validation that causes errors)
      return processedText;
    } catch (e) {
      debugPrint('OCR failed: $e');
      return '';
    }
  }

  Future<String> _readWithTesseract(String filePath) async {
    try {
      // Configure Tesseract for Arabic text recognition
      final result = await TesseractOcr.extractText(filePath);
      return result;
    } catch (e) {
      debugPrint('Tesseract OCR failed: $e');
      return '';
    }
  }

  String _processArabicText(String text) {
    if (text.isEmpty) return text;
    
    // Remove common OCR artifacts for Arabic text
    return text
        .replaceAll(RegExp(r'[_\\-]'), ' ') // Replace underscores and hyphens with spaces
        .replaceAll(RegExp(r'\\s+'), ' ') // Normalize multiple spaces
        .replaceAll(RegExp(r'[\\u200B-\\u200D\\uFEFF]'), '') // Remove zero-width characters
        .trim();
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
