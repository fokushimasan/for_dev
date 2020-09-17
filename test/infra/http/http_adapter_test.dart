import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

import 'package:for_dev/data/http/http.dart';

class HttpAdapter implements IHttpClient {
  final Client client;

  HttpAdapter({@required this.client});

  Future<Map> request({
    @required String url,
    @required String method,
    Map body,
  }) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    final jsonBody =
        (body != null && body.isNotEmpty) ? jsonEncode(body) : null;
    final response = await client.post(
      url,
      headers: headers,
      body: jsonBody,
    );
    return jsonDecode(response.body);
  }
}

class ClientSpy extends Mock implements Client {}

void main() {
  HttpAdapter sut;
  ClientSpy client;
  String url;

  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client: client);
    url = faker.internet.httpUrl();
  });
  group('POST', () {
    test('should call POST with correct values', () async {
      // arrange
      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => Response('{"any_key":"any_value"}', 200));

      // act
      await sut.request(
        url: url,
        method: 'POST',
        body: {'any_key': 'any_value'},
      );

      // assert
      verify(client.post(
        url,
        headers: {
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: '{"any_key":"any_value"}',
      ));
    });

    test('should call POST without body', () async {
      // arrange
      when(client.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => Response('{"any_key":"any_value"}', 200));

      // act
      await sut.request(
        url: url,
        method: 'POST',
      );

      // assert
      verify(client.post(
        any,
        headers: anyNamed('headers'),
      ));
    });

    test('should return data if POST returns 200', () async {
      // arrange
      when(client.post(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => Response('{"any_key":"any_value"}', 200));
      // act
      final response = await sut.request(url: url, method: 'POST');

      // assert
      expect(response, {'any_key': 'any_value'});
    });
  });
}
