import 'api_client.dart';
import '../../models/doctor_model.dart';
import '../../models/pharmacist_model.dart';

class SearchService {
  final ApiClient _api = ApiClient();

  /// Universal search across doctors and pharmacists
  /// Returns a map with 'doctors' and 'pharmacists' lists
  Future<Map<String, dynamic>> search({
    required String query,
    String type = 'all', // 'all', 'doctor', 'pharmacist'
  }) async {
    try {
      final response = await _api.get(
        '/appointments/search/',
        queryParameters: {
          'q': query,
          'type': type,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return {
          'doctors': (data['doctors'] as List?)
                  ?.map((json) => Doctor.fromJson(json))
                  .toList() ??
              [],
          'pharmacists': (data['pharmacists'] as List?)
                  ?.map((json) => Pharmacist.fromJson(json))
                  .toList() ??
              [],
        };
      }
      return {'doctors': [], 'pharmacists': []};
    } catch (e) {
      print('❌ SearchService.search Error: $e');
      return {'doctors': [], 'pharmacists': []};
    }
  }
}

