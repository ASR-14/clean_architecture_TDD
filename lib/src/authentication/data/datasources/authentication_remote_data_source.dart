import 'dart:convert';

import 'package:flutter_clean_architecture/core/errors/exceptions.dart';
import 'package:flutter_clean_architecture/core/utils/constants.dart';
import 'package:flutter_clean_architecture/src/authentication/data/models/user_model.dart';
import 'package:http/http.dart' as http;

abstract class AuthenticationRemoteDataSource {
  Future<void> createUser(
      {required String createdAt,
      required String name,
      required String avatar});

  Future<List<UserModel>> getUsers();
}

const kCreateUserEndpoint = '/users';
const kGetUsersEndpoint = '/user';

class AuthRemoteDataScrImpl implements AuthenticationRemoteDataSource {
  const AuthRemoteDataScrImpl(this._client);

  final http.Client _client;
  @override
  Future<void> createUser(
      {required String createdAt,
      required String name,
      required String avatar}) async {
    try {
      final response =
          await _client.post(Uri.parse('$kBaseUrl$kCreateUserEndpoint'),
              body: jsonEncode({
                'createdAt': createdAt,
                'name': name,
                'avatar': avatar,
              }));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw APIException(
            message: response.body, statusCode: response.statusCode);
      }
    } catch (e) {
      throw APIException(message: e.toString(), statusCode: 505);
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    // TODO: implement getUsers
    throw UnimplementedError();
  }
}
