import 'dart:convert';

import 'package:flutter_clean_architecture/core/errors/exceptions.dart';
import 'package:flutter_clean_architecture/core/utils/constants.dart';
import 'package:flutter_clean_architecture/src/authentication/data/datasources/authentication_remote_data_source.dart';
import 'package:flutter_clean_architecture/src/authentication/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late http.Client client;
  late AuthenticationRemoteDataSource remoteDataSource;

  setUpAll(
    () {
      registerFallbackValue(Uri());
    },
  );

  setUp(
    () {
      client = MockClient();
      remoteDataSource = AuthRemoteDataScrImpl(client);
    },
  );

  group(
    'createUser',
    () {
      test(
        'should complete successfully when the status code is 200 or 201',
        () async {
          // Arrange
          when(
            () => client.post(any(), body: any(named: 'body')),
          ).thenAnswer(
              (_) async => http.Response('User created successfully', 201));

          final methodCall = remoteDataSource.createUser;

          // Assert
          expect(
              methodCall(
                  createdAt: 'createdAt', name: 'name', avatar: 'avatar'),
              completes);

          verify(
            () => client.post(
              Uri.https(kBaseUrl, kCreateUserEndpoint),
              body: jsonEncode({
                'createdAt': 'createdAt',
                'name': 'name',
                'avatar': 'avatar'
              }),
            ),
          ).called(1);
          verifyNoMoreInteractions(client);
        },
      );
      test(
        'should throw [APIException] when the status code is not 200 or 201',
        () async {
          // Arrange
          when(
            () => client.post(any(), body: any(named: 'body')),
          ).thenAnswer(
              (_) async => http.Response('Invalid email address', 400));

          // Act
          final methodCall = remoteDataSource.createUser;

          // Assert
          expect(
              () async => methodCall(
                  createdAt: 'createdAt', name: 'name', avatar: 'avatar'),
              throwsA(const APIException(
                  message: 'Invalid email address', statusCode: 400)));

          verify(
            () => client.post(
              Uri.https(kBaseUrl, kCreateUserEndpoint),
              body: jsonEncode({
                'createdAt': 'createdAt',
                'name': 'name',
                'avatar': 'avatar'
              }),
            ),
          ).called(1);
          verifyNoMoreInteractions(client);
        },
      );
    },
  );
  group(
    'getUsers',
    () {
      const tUsers = [UserModel.empty()];
      test(
        'should return [List<User>] when the status code is 200',
        () async {
          // Arrange
          when(() => client.get(any())).thenAnswer(
            (_) async => http.Response(jsonEncode([tUsers.first.toMap()]), 200),
          );

          // Act
          final result = await remoteDataSource.getUsers();

          // Assert
          expect(result, equals(tUsers));
          verify(
            () => client.get(Uri.https(kBaseUrl, kGetUsersEndpoint)),
          ).called(1);
          verifyNoMoreInteractions(client);
        },
      );
      test(
        'should throw [APIException] when the status code is not 200',
        () async {
          // Arrange
          const tMessage = 'Server down';
          when(() => client.get(any())).thenAnswer(
            (_) async => http.Response(tMessage, 500),
          );

          // Act
          final methodCall = remoteDataSource.getUsers;

          // Assert
          expect(() => methodCall(),
              throwsA(const APIException(message: tMessage, statusCode: 500)));

          verify(
            () => client.get(Uri.https(kBaseUrl, kGetUsersEndpoint)),
          ).called(1);
          verifyNoMoreInteractions(client);
        },
      );
    },
  );
}
