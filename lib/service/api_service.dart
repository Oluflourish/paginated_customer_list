import 'package:cognisto_test/models/contact_model.dart';
import 'package:cognisto_test/models/pagination_response.dart';
import 'package:cognisto_test/service/http_service.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static HttpService httpService = HttpService();

  static Future<PaginationResponse<List<ContactModel>>> fetchContacts({
    required int pageKey,
    int pageSize = 10,
  }) async {
    try {
      Map<String, dynamic> query = {'page': pageKey, 'limit': pageSize};
      final response = await httpService.get('users', query: query);

      return PaginationResponse<List<ContactModel>>.fromJson(
        response.data,
        (response.data['users'] as List)
            .map((contact) => ContactModel.fromJson(contact))
            .toList(),
      );
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      return PaginationResponse<List<ContactModel>>(
        items: [],
        total: 0,
        skip: 0,
        limit: pageSize,
      );
    }
  }

  static Future<PaginationResponse<List<ContactModel>>> searchContacts({
    int? pageKey,
    int pageSize = 10,
    required String query,
  }) async {
    try {
      Map<String, dynamic> param = {
        'q': query,
        'page': pageKey,
        'limit': pageSize,
      };
      final response = await httpService.get('users/search', query: param);

      return PaginationResponse<List<ContactModel>>.fromJson(
        response.data,
        (response.data['users'] as List)
            .map((contact) => ContactModel.fromJson(contact))
            .toList(),
      );
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      return PaginationResponse<List<ContactModel>>(
        items: [],
        total: 0,
        skip: 0,
        limit: pageSize,
      );
    }
  }
}
