import 'package:dio/dio.dart';

class ErrorHandler {
  /// Convert technical errors to user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    
    if (error is String) {
      return _parseStringError(error);
    }
    
    // Handle generic exceptions
    final errorString = error.toString().toLowerCase();
    
    // Connection errors
    if (errorString.contains('connection') || 
        errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('failed host lookup')) {
      return 'Unable to connect to server. Please check your internet connection.';
    }
    
    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    // Generic error
    return 'Something went wrong. Please try again.';
  }
  
  /// Handle Dio-specific errors
  static String _handleDioError(DioException error) {
    // Network/Connection errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection and try again.';
      
      case DioExceptionType.connectionError:
        return 'Unable to connect to server. Please make sure the server is running and check your internet connection.';
      
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Failed host lookup') == true) {
          return 'Unable to connect to server. Please check your internet connection.';
        }
        return 'Network error occurred. Please try again.';
      
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  
  /// Handle HTTP response errors
  static String _handleResponseError(Response? response) {
    if (response == null) {
      return 'Server error occurred. Please try again.';
    }
    
    final statusCode = response.statusCode;
    final data = response.data;
    
    // Try to extract error message from response
    String? errorMessage;
    if (data is Map) {
      // Check common error message fields first
      if (data['error'] != null) {
        if (data['error'] is List && data['error'].isNotEmpty) {
          errorMessage = data['error'][0].toString();
        } else {
          errorMessage = data['error'].toString();
        }
      } else if (data['message'] != null) {
        if (data['message'] is List && data['message'].isNotEmpty) {
          errorMessage = data['message'][0].toString();
        } else {
          errorMessage = data['message'].toString();
        }
      } else if (data['detail'] != null) {
        if (data['detail'] is List && data['detail'].isNotEmpty) {
          errorMessage = data['detail'][0].toString();
        } else {
          errorMessage = data['detail'].toString();
        }
      } else if (data['non_field_errors'] != null) {
        // Handle non_field_errors (list of errors) - Django REST Framework format
        if (data['non_field_errors'] is List && data['non_field_errors'].isNotEmpty) {
          errorMessage = data['non_field_errors'][0].toString();
        } else {
          errorMessage = data['non_field_errors'].toString();
        }
      }
      
      // Handle Django REST Framework validation errors (field-specific)
      // These come as a map with field names as keys and lists of errors as values
      if (errorMessage == null) {
        final errors = <String>[];
        data.forEach((key, value) {
          if (key != 'error' && key != 'message' && key != 'detail' && key != 'non_field_errors') {
            if (value is List && value.isNotEmpty) {
              // Take the first error message for each field
              errors.add(value[0].toString());
            } else if (value is String && value.isNotEmpty) {
              errors.add(value);
            }
          }
        });
        if (errors.isNotEmpty) {
          // Join all error messages, but prefer the first one for cleaner UI
          errorMessage = errors[0];
        }
      }
      
      // Special handling for common appointment booking errors
      if (errorMessage != null) {
        final lowerMessage = errorMessage.toLowerCase();
        if (lowerMessage.contains('not available') || 
            lowerMessage.contains('not generally available')) {
          return 'Doctor is not available at this time. Please choose another time slot.';
        }
        if (lowerMessage.contains('not available on')) {
          return errorMessage; // Keep the specific day message
        }
        if (lowerMessage.contains('must be between')) {
          return errorMessage; // Keep the time range message
        }
        if (lowerMessage.contains('conflicts') || 
            lowerMessage.contains('overlap') ||
            lowerMessage.contains('existing appointment')) {
          return 'This time slot is already booked. Please choose another time.';
        }
        if (lowerMessage.contains('past')) {
          return 'Cannot book appointments in the past. Please select a future date and time.';
        }
      }
    }
    
    // Status code specific messages
    switch (statusCode) {
      case 400:
        return errorMessage ?? 'Invalid request. Please check your input and try again.';
      case 401:
        return 'Your session has expired. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return errorMessage ?? 'This action conflicts with existing data.';
      case 422:
        return errorMessage ?? 'Invalid data provided. Please check your input.';
      case 500:
        return 'Server error occurred. Please try again later.';
      case 502:
      case 503:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return errorMessage ?? 'An error occurred. Please try again.';
    }
  }
  
  /// Parse string errors to user-friendly messages
  static String _parseStringError(String error) {
    final lowerError = error.toLowerCase();
    
    // Common error patterns
    if (lowerError.contains('email')) {
      if (lowerError.contains('already') || lowerError.contains('exists')) {
        return 'This email is already registered. Please use a different email.';
      }
      if (lowerError.contains('invalid')) {
        return 'Please enter a valid email address.';
      }
    }
    
    if (lowerError.contains('password')) {
      if (lowerError.contains('short') || lowerError.contains('minimum')) {
        return 'Password must be at least 6 characters long.';
      }
      if (lowerError.contains('match') || lowerError.contains('don\'t')) {
        return 'Passwords do not match. Please try again.';
      }
      if (lowerError.contains('incorrect') || lowerError.contains('wrong')) {
        return 'Incorrect password. Please try again.';
      }
    }
    
    if (lowerError.contains('username')) {
      if (lowerError.contains('already') || lowerError.contains('exists')) {
        return 'This username is already taken. Please choose another.';
      }
    }
    
    if (lowerError.contains('phone')) {
      return 'Please enter a valid phone number.';
    }
    
    if (lowerError.contains('required')) {
      return 'Please fill in all required fields.';
    }
    
    // Return original if no pattern matches (might be user-friendly already)
    return error;
  }
}

