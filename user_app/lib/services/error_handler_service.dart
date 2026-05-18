import 'package:flutter/material.dart';

class ErrorHandlerService {
  static void showError(BuildContext context, String error) {
    String userFriendlyMessage = _getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(userFriendlyMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String _getUserFriendlyMessage(String error) {
    final errorLower = error.toLowerCase();
    
    // Network errors
    if (errorLower.contains('connection') || errorLower.contains('network')) {
      return 'Please check your internet connection and try again.';
    }
    
    // Authentication errors
    if (errorLower.contains('unauthorized') || errorLower.contains('401')) {
      return 'Please login again to continue.';
    }
    
    if (errorLower.contains('forbidden') || errorLower.contains('403')) {
      return 'You don\'t have permission to perform this action.';
    }
    
    // Validation errors
    if (errorLower.contains('validation') || errorLower.contains('invalid')) {
      return 'Please check your input and try again.';
    }
    
    // Server errors
    if (errorLower.contains('server') || errorLower.contains('500')) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    
    // Timeout errors
    if (errorLower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    // Not found errors
    if (errorLower.contains('not found') || errorLower.contains('404')) {
      return 'The requested resource was not found.';
    }
    
    // Medicine/booking specific errors
    if (errorLower.contains('out of stock')) {
      return 'This medicine is currently out of stock.';
    }
    
    if (errorLower.contains('not available') && errorLower.contains('doctor')) {
      return 'Doctor is not available at the selected time. Please choose a different slot.';
    }
    
    if (errorLower.contains('sunday') && errorLower.contains('available')) {
      return 'Doctor is not available on Sundays. Please select a weekday.';
    }
    
    // Location errors
    if (errorLower.contains('location') && errorLower.contains('permission')) {
      return 'Please enable location access to find nearby services.';
    }
    
    // Payment errors
    if (errorLower.contains('payment')) {
      return 'Payment processing failed. Please try again or use a different payment method.';
    }
    
    // Generic fallback
    if (error.length > 100) {
      return 'An error occurred. Please try again or contact support if the problem persists.';
    }
    
    return error;
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}