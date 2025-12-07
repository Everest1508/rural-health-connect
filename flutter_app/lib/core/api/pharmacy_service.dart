import 'api_client.dart';
import '../../models/pharmacist_model.dart';
import '../../models/prescription_model.dart';
import '../../models/order_model.dart';
import 'package:dio/dio.dart';

class PharmacyService {
  final ApiClient _api = ApiClient();

  Future<List<Pharmacist>> getPharmacists({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();

      final response = await _api.get('/pharmacy/pharmacists/', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final data = response.data is List ? response.data : (response.data['results'] ?? []);
        return (data as List).map((json) => Pharmacist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ PharmacyService.getPharmacists Error: $e');
      return [];
    }
  }

  Future<List<Pharmacist>> getNearestPharmacists({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _api.get(
        '/pharmacy/pharmacists/nearest/',
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data is List ? response.data : [];
        return (data as List).map((json) => Pharmacist.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ PharmacyService.getNearestPharmacists Error: $e');
      return [];
    }
  }

  Future<Pharmacist?> getPharmacist(int id) async {
    try {
      final response = await _api.get('/pharmacy/pharmacists/$id/');
      if (response.statusCode == 200) {
        return Pharmacist.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('❌ PharmacyService.getPharmacist Error: $e');
      return null;
    }
  }

  Future<Pharmacist?> getPharmacistProfile() async {
    try {
      final response = await _api.get('/pharmacy/pharmacists/profile/');
      if (response.statusCode == 200) {
        return Pharmacist.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('❌ PharmacyService.getPharmacistProfile Error: $e');
      return null;
    }
  }

  Future<Pharmacist?> updatePharmacistProfile({
    required String storeName,
    required String storeAddress,
    required double latitude,
    required double longitude,
    String? phone,
  }) async {
    try {
      // Round to 6 decimal places
      final roundedLat = double.parse(latitude.toStringAsFixed(6));
      final roundedLon = double.parse(longitude.toStringAsFixed(6));
      
      final response = await _api.put(
        '/pharmacy/pharmacists/profile/',
        data: {
          'store_name': storeName,
          'store_address': storeAddress,
          'latitude': roundedLat.toString(),
          'longitude': roundedLon.toString(),
          if (phone != null) 'phone': phone,
        },
      );
      if (response.statusCode == 200) {
        return Pharmacist.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('❌ PharmacyService.updatePharmacistProfile Error: $e');
      rethrow;
    }
  }

  // Prescription methods
  Future<List<Prescription>> getPrescriptions() async {
    try {
      final response = await _api.get('/pharmacy/prescriptions/');
      if (response.statusCode == 200) {
        final data = response.data is List ? response.data : (response.data['results'] ?? []);
        return (data as List).map((json) => Prescription.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ PharmacyService.getPrescriptions Error: $e');
      return [];
    }
  }

  Future<Prescription?> createPrescription({
    required String title,
    String? imagePath,
    String? notes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        if (notes != null) 'notes': notes,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(imagePath, filename: 'prescription.jpg'),
      });

      final response = await _api.post(
        '/pharmacy/prescriptions/',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Prescription.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('❌ PharmacyService.createPrescription Error: $e');
      rethrow;
    }
  }

  Future<bool> deletePrescription(int id) async {
    try {
      final response = await _api.delete('/pharmacy/prescriptions/$id/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('❌ PharmacyService.deletePrescription Error: $e');
      return false;
    }
  }

  // Order methods
  Future<List<Order>> getOrders() async {
    try {
      final response = await _api.get('/pharmacy/orders/');
      if (response.statusCode == 200) {
        final data = response.data is List ? response.data : (response.data['results'] ?? []);
        return (data as List).map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ PharmacyService.getOrders Error: $e');
      return [];
    }
  }

  Future<Order?> createOrder({
    required int pharmacistId,
    int? prescriptionId,
    int? appointmentId,
    required String prescriptionText,
    required String deliveryAddress,
    required double latitude,
    required double longitude,
    String? notes,
  }) async {
    try {
      // Round to 6 decimal places
      final roundedLat = double.parse(latitude.toStringAsFixed(6));
      final roundedLon = double.parse(longitude.toStringAsFixed(6));
      
      final response = await _api.post(
        '/pharmacy/orders/',
        data: {
          'pharmacist': pharmacistId,
          if (prescriptionId != null) 'prescription': prescriptionId,
          if (appointmentId != null) 'appointment': appointmentId,
          'prescription_text': prescriptionText,
          'delivery_address': deliveryAddress,
          'patient_latitude': roundedLat.toString(),
          'patient_longitude': roundedLon.toString(),
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Order.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('❌ PharmacyService.createOrder Error: $e');
      rethrow;
    }
  }

  Future<Order?> updateOrderStatus(int orderId, OrderStatus status) async {
    try {
      final response = await _api.patch(
        '/pharmacy/orders/$orderId/',
        data: {'status': status.name},
      );

      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('❌ PharmacyService.updateOrderStatus Error: $e');
      rethrow;
    }
  }

  Future<Order?> getOrder(int id) async {
    try {
      final response = await _api.get('/pharmacy/orders/$id/');
      if (response.statusCode == 200) {
        return Order.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('❌ PharmacyService.getOrder Error: $e');
      return null;
    }
  }
}

