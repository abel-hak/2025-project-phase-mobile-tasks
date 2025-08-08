import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/src/dummies.dart';
import 'package:product_app/core/error/exceptions.dart';
import 'package:product_app/features/product/data/datasources/product_remote_data_source_impl.dart';
import 'package:product_app/features/product/data/models/product_model.dart';

import 'product_remote_data_source_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
  MockSpec<http.StreamedResponse>(),
])
const baseUrl = 'https://g5-flutter-learning-path-be.onrender.com/api/v2';

Map<String, String> _getHeaders(String? token) => {
  'Content-Type': 'application/json',
  if (token != null) 'Authorization': 'Bearer $token',
};

void main() {
  late ProductRemoteDataSourceImpl dataSource;
  late MockClient mockClient;
  late MockStreamedResponse mockStreamedResponse;

  setUp(() {
    mockClient = MockClient();
    mockStreamedResponse = MockStreamedResponse();
    dataSource = ProductRemoteDataSourceImpl(
      client: mockClient,
    );

    // Provide dummies for mocked responses
    provideDummy<http.ByteStream>(http.ByteStream.fromBytes(Uint8List(0)));
    provideDummy<http.BaseRequest>(
        http.Request('GET', Uri.parse('$baseUrl/products')));

    // Setup default successful responses for all HTTP methods
    final successResponse = {
      'data': {
        'id': '1',
        'name': 'Test Product',
        'description': 'Test Description',
        'price': 99.99,
        'category': 'Test',
        'rating': 4.5,
        'imageUrl': 'test.jpg'
      }
    };

    // GET requests
    // Default GET success response
    when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response(jsonEncode(successResponse), 200),
    );

    // GET error responses
    when(mockClient.get(
      Uri.parse('$baseUrl/products/error401'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('Unauthorized', 401));

    when(mockClient.get(
      Uri.parse('$baseUrl/products/error403'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('Forbidden', 403));

    when(mockClient.get(
      Uri.parse('$baseUrl/products/error500'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('Server Error', 500));

    // PUT requests
    // Default PUT success response with updated product
    final updatedResponse = {
      'data': {
        'id': '1',
        'name': 'Updated Product',
        'description': 'Updated Description',
        'price': 99.99,
        'category': 'Test',
        'rating': 4.5,
        'imageUrl': 'test.jpg'
      }
    };

    when(mockClient.put(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer(
      (_) async => http.Response(jsonEncode(updatedResponse), 200),
    );

    // PUT error responses
    when(mockClient.put(
      Uri.parse('$baseUrl/products/error401'),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response('Unauthorized', 401));

    when(mockClient.put(
      Uri.parse('$baseUrl/products/error403'),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response('Forbidden', 403));

    when(mockClient.put(
      Uri.parse('$baseUrl/products/error500'),
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response('Server Error', 500));

    // DELETE requests
    // Default DELETE success response
    when(mockClient.delete(
      any,
      headers: anyNamed('headers'),
    )).thenAnswer(
      (_) async => http.Response('', 204),
    );

    // DELETE error responses
    when(mockClient.delete(
      Uri.parse('$baseUrl/products/error401'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('Unauthorized', 401));

    when(mockClient.delete(
      Uri.parse('$baseUrl/products/error403'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('Forbidden', 403));

    when(mockClient.delete(
      Uri.parse('$baseUrl/products/error500'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('Server Error', 500));

    // Setup default successful multipart response
    when(mockStreamedResponse.statusCode).thenReturn(200);
    when(mockStreamedResponse.stream)
        .thenAnswer((_) => http.ByteStream.fromBytes(Uint8List(0)));
    when(mockStreamedResponse.request)
        .thenReturn(http.Request('POST', Uri.parse('$baseUrl/products')));
    when(mockClient.send(any)).thenAnswer((_) async => mockStreamedResponse);
  });

  group('getProduct', () {
    const tId = '1';
    const tToken = 'test_token';
    final tProductJson = {
      'id': '1',
      'name': 'Test Product',
      'description': 'Test Description',
      'price': 99.99,
      'imageUrl': 'test.jpg',
      'category': 'Test',
      'rating': 4.5,
    };

    test('should perform GET request with auth token', () async {
      // arrange
      when(
        mockClient.get(
          Uri.parse('$baseUrl/products/$tId'),
          headers: {'Authorization': 'Bearer $tToken'},
        ),
      ).thenAnswer((_) async => http.Response(json.encode(tProductJson), 200));

      // act
      await dataSource.getProduct(tId, token: tToken);

      // assert
      verify(
        mockClient.get(
          Uri.parse('$baseUrl/products/$tId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tToken'
          },
        ),
      );
    });

    test('should return ProductModel when status code is 200', () async {
      // arrange
      when(
        mockClient.get(
          Uri.parse('$baseUrl/products/$tId'),
          headers: {'Authorization': 'Bearer $tToken'},
        ),
      ).thenAnswer((_) async => http.Response(json.encode(tProductJson), 200));

      // act
      final result = await dataSource.getProduct(tId, token: tToken);

      // assert
      expect(result, isA<ProductModel>());
      expect(result.toJson(), tProductJson);
    });

    test(
      'should throw UnauthorizedException when status code is 401',
      () async {
        // arrange
        when(
          mockClient.get(
            Uri.parse('$baseUrl/products/error401'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $tToken'
            },
          ),
        ).thenAnswer((_) async => http.Response(
              json.encode({'message': 'Unauthorized'}),
              401,
            ));

        // act
        final call = dataSource.getProduct;

        // assert
        expect(
          () => call('error401', token: tToken),
          throwsA(isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            'Unauthorized access',
          )),
        );
      },
    );

    test('should throw ForbiddenException when status code is 403', () async {
      // arrange
      when(
        mockClient.get(
          Uri.parse('$baseUrl/products/error403'),
          headers: {'Authorization': 'Bearer $tToken'},
        ),
      ).thenAnswer((_) async => http.Response('Forbidden', 403));

      // act
      final call = dataSource.getProduct;

      // assert
      expect(
        () => call('error403', token: tToken),
        throwsA(isA<ForbiddenException>().having(
          (e) => e.message,
          'message',
          'Access forbidden',
        )),
      );
    });

    test(
      'should throw ServerException when status code is not 200/401/403',
      () async {
        // arrange
        when(
          mockClient.get(
            Uri.parse('$baseUrl/products/error500'),
            headers: {'Authorization': 'Bearer $tToken'},
          ),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        // act
        final call = dataSource.getProduct;

        // assert
        expect(() => call('error500', token: tToken), throwsA(isA<ServerException>()));
      },
    );
  });

  group('createProduct', () {
    const tToken = 'test_token';
    final tProductModel = ProductModel(
      id: '',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test',
      rating: 4.5,
    );

    final tCreatedProductJson = {
      'id': '1',
      'name': 'Test Product',
      'description': 'Test Description',
      'price': 99.99,
      'imageUrl': 'test.jpg',
      'category': 'Test',
      'rating': 4.5,
    };

    test('should perform multipart POST request with auth token', () async {
      // arrange
      final mockStreamedResponse = MockStreamedResponse();
      when(mockStreamedResponse.statusCode).thenReturn(201);
      when(mockStreamedResponse.stream).thenAnswer(
        (_) => http.ByteStream(
          Stream.value(
            Uint8List.fromList(
              utf8.encode(json.encode({'data': tCreatedProductJson})),
            ),
          ),
        ),
      );

      when(
        mockClient.send(any),
      ).thenAnswer((_) async => mockStreamedResponse);

      // act
      final result = await dataSource.createProduct(
        tProductModel,
        token: tToken,
      );

      // assert
      verify(mockClient.send(any));
      expect(result, isA<ProductModel>());
      expect(result.toJson(), tCreatedProductJson);
    });

    test('should throw ServerException when request fails', () async {
      // arrange
      final tProduct = ProductModel(
        id: '1',
        name: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        imageUrl: 'test.jpg',
        category: 'Test',
        rating: 4.5,
      );

      when(mockStreamedResponse.statusCode).thenReturn(500);
      when(mockStreamedResponse.stream)
          .thenAnswer((_) => http.ByteStream.fromBytes(Uint8List(0)));
      when(mockClient.send(any)).thenAnswer(
        (_) async => mockStreamedResponse,
      );

      // act
      final call = dataSource.createProduct;

      // assert
      expect(
        () => call(tProduct, token: tToken),
        throwsA(isA<ServerException>()),
      );
    });

    test('should verify multipart request fields', () async {
      // arrange
      final mockStreamedResponse = MockStreamedResponse();
      when(mockStreamedResponse.statusCode).thenReturn(201);
      when(mockStreamedResponse.stream).thenAnswer(
        (_) => http.ByteStream(
          Stream.value(
            Uint8List.fromList(
              utf8.encode(json.encode({'data': tCreatedProductJson})),
            ),
          ),
        ),
      );

      when(
        mockClient.send(any),
      ).thenAnswer((_) async => mockStreamedResponse);

      // act
      await dataSource.createProduct(tProductModel, token: tToken);

      // assert
      final verificationResult = verify(mockClient.send(captureAny));
      final request =
          verificationResult.captured.single as http.MultipartRequest;

      expect(request.method, 'POST');
      expect(request.url, Uri.parse('$baseUrl/products'));
      expect(request.fields['name'], tProductModel.name);
      expect(request.fields['description'], tProductModel.description);
      expect(request.fields['price'], tProductModel.price.toString());
    });

    test('should handle local image files', () async {
      // arrange
      final tImagePath = '${Directory.systemTemp.path}/test_image.jpg';
      final testImage = File(tImagePath);
      final productWithLocalImage = tProductModel.copyWith(
        imageUrl: tImagePath,
      );
      when(mockStreamedResponse.statusCode).thenReturn(201);
      when(mockStreamedResponse.stream).thenAnswer(
        (_) => http.ByteStream(
          Stream.value(
            Uint8List.fromList(
              utf8.encode(json.encode({'data': tCreatedProductJson})),
            ),
          ),
        ),
      );
      when(mockStreamedResponse.request)
          .thenReturn(http.Request('POST', Uri.parse('$baseUrl/products')));

      when(
        mockClient.send(any),
      ).thenAnswer((_) async => mockStreamedResponse);

      // Create a temporary test image file
      await testImage.writeAsBytes(Uint8List(0));

      try {
        await dataSource.createProduct(
          productWithLocalImage,
          token: tToken,
        );

        // Verify the request
        final verificationResult = verify(mockClient.send(captureAny));
        verificationResult.called(1);

        final request =
            verificationResult.captured.single as http.MultipartRequest;
        expect(request.files, hasLength(1));
        expect(request.files.first.field, 'image');
        expect(request.files.first.filename, endsWith('test_image.jpg'));
        expect(request.fields['name'], equals(tProductModel.name));
        expect(request.fields['description'], equals(tProductModel.description));
        expect(request.fields['price'], equals(tProductModel.price.toString()));
      } finally {
        // Clean up the temporary file
        if (await testImage.exists()) {
          await testImage.delete();
        }
      }
    });

    test(
      'should throw UnauthorizedException when status code is 401',
      () async {
        // arrange
        final mockStreamedResponse = MockStreamedResponse();
        when(mockStreamedResponse.statusCode).thenReturn(401);
        when(mockStreamedResponse.stream).thenAnswer(
          (_) => http.ByteStream(
            Stream.value(Uint8List.fromList(utf8.encode('Unauthorized'))),
          ),
        );

        when(
          mockClient.send(any),
        ).thenAnswer((_) async => mockStreamedResponse);

        // act & assert
        expect(
          () => dataSource.createProduct(tProductModel, token: tToken),
          throwsA(isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            'Unauthorized access',
          )),
        );
      },
    );

    test('should throw ForbiddenException when status code is 403', () async {
      // arrange
      final mockStreamedResponse = MockStreamedResponse();
      when(mockStreamedResponse.statusCode).thenReturn(403);
      when(mockStreamedResponse.stream).thenAnswer(
        (_) => http.ByteStream(
          Stream.value(Uint8List.fromList(utf8.encode('Forbidden'))),
        ),
      );

      when(
        mockClient.send(any),
      ).thenAnswer((_) async => mockStreamedResponse);

      // act & assert
      expect(
        () => dataSource.createProduct(tProductModel, token: tToken),
        throwsA(isA<ForbiddenException>().having(
          (e) => e.message,
          'message',
          'Access forbidden',
        )),
      );
    });
  });

  group('updateProduct', () {
    const tToken = 'test_token';
    final tProductModel = ProductModel(
      id: '1',
      name: 'Test Product',
      description: 'Test Description',
      price: 99.99,
      imageUrl: 'test.jpg',
      category: 'Test',
      rating: 4.5,
    );

    test('should perform PUT request with auth token', () async {
      // arrange
      when(
        mockClient.put(
          Uri.parse('$baseUrl/products/${tProductModel.id}'),
          body: json.encode(tProductModel.toJson()),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tToken',
          },
        ),
      ).thenAnswer(
        (_) async =>
            http.Response(json.encode({'data': tProductModel.toJson()}), 200),
      );

      // act
      final result = await dataSource.updateProduct(
        tProductModel.id,
        tProductModel,
        token: tToken,
      );

      // assert
      verify(
        mockClient.put(
          Uri.parse('$baseUrl/products/${tProductModel.id}'),
          body: json.encode(tProductModel.toJson()),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tToken',
          },
        ),
      );
      expect(result, isA<ProductModel>());
      expect(result.toJson(), tProductModel.toJson());
    });

    test(
      'should throw UnauthorizedException when status code is 401',
      () async {
        // arrange
        when(
          mockClient.put(
            Uri.parse('$baseUrl/products/error401'),
            body: json.encode(tProductModel.toJson()),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $tToken',
            },
          ),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        // act & assert
        expect(
          () => dataSource.updateProduct(
            'error401',
            tProductModel,
            token: tToken,
          ),
          throwsA(isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            'Unauthorized access',
          )),
        );
      },
    );

    test('should throw ForbiddenException when status code is 403', () async {
      // arrange
      when(
        mockClient.put(
          Uri.parse('$baseUrl/products/error403'),
          body: json.encode(tProductModel.toJson()),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tToken',
          },
        ),
      ).thenAnswer((_) async => http.Response('Forbidden', 403));

      // act & assert
      expect(
        () => dataSource.updateProduct(
          'error403',
          tProductModel,
          token: tToken,
        ),
        throwsA(isA<ForbiddenException>().having(
          (e) => e.message,
          'message',
          'Access forbidden',
        )),
      );
    });

    test(
      'should throw ServerException when status code is not 200/401/403',
      () async {
        // arrange
        when(
          mockClient.put(
            Uri.parse('$baseUrl/products/error500'),
            body: json.encode(tProductModel.toJson()),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $tToken',
            },
          ),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        // act
        final call = dataSource.updateProduct;

        // assert
        expect(
          () => call('error500', tProductModel, token: tToken),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Server error occurred',
          )),
        );
      },
    );

    test(
      'should return updated ProductModel when status code is 200',
      () async {
        // arrange
        final updatedJson = {
          'data': tProductModel
              .copyWith(
                name: 'Updated Product',
                description: 'Updated Description',
              )
              .toJson(),
        };

        when(
          mockClient.put(
            Uri.parse('$baseUrl/products/${tProductModel.id}'),
            body: json.encode(tProductModel.toJson()),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $tToken',
            },
          ),
        ).thenAnswer((_) async => http.Response(json.encode(updatedJson), 200));

        // act
        final result = await dataSource.updateProduct(
          tProductModel.id,
          tProductModel,
          token: tToken,
        );

        // assert
        expect(result, isA<ProductModel>());
        expect(result.name, 'Updated Product');
        expect(result.description, 'Updated Description');
        expect(result.id, tProductModel.id);
      },
    );

    test('should throw ServerException when id is empty', () async {
      // arrange
      final invalidProduct = tProductModel.copyWith(id: '');

      // act & assert
      expect(
        () => dataSource.updateProduct('', invalidProduct, token: tToken),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('deleteProduct', () {
    const tId = '1';
    const tToken = 'test_token';

    test('should perform DELETE request with auth token', () async {
      // arrange
      when(
        mockClient.delete(
          Uri.parse('$baseUrl/products/$tId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tToken'
          },
        ),
      ).thenAnswer((_) async => http.Response('', 204));

      // act
      await dataSource.deleteProduct(tId, token: tToken);

      // assert
      verify(
        mockClient.delete(
          Uri.parse('$baseUrl/products/$tId'),
          headers: _getHeaders(tToken),
        ),
      );
    });

    test(
      'should throw UnauthorizedException when status code is 401',
      () async {
        // arrange
        when(
          mockClient.delete(
            Uri.parse('$baseUrl/products/error401'),
            headers: _getHeaders(tToken),
          ),
        ).thenAnswer((_) async => http.Response('Unauthorized', 401));

        // act & assert
        expect(
          () => dataSource.deleteProduct('error401', token: tToken),
          throwsA(isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            'Unauthorized access',
          )),
        );
      },
    );

    test('should throw ForbiddenException when status code is 403', () async {
      // arrange
      when(
        mockClient.delete(
          Uri.parse('$baseUrl/products/error403'),
          headers: _getHeaders(tToken),
        ),
      ).thenAnswer((_) async => http.Response('Forbidden', 403));

      // act & assert
      expect(
        () => dataSource.deleteProduct('error403', token: tToken),
        throwsA(isA<ForbiddenException>().having(
          (e) => e.message,
          'message',
          'Access forbidden',
        )),
      );
    });

    test(
      'should throw ServerException when status code is not 204/401/403',
      () async {
        // arrange
        when(
          mockClient.delete(
            Uri.parse('$baseUrl/products/error500'),
            headers: _getHeaders(tToken),
          ),
        ).thenAnswer((_) async => http.Response('Server Error', 500));

        // act & assert
        expect(
          () => dataSource.deleteProduct('error500', token: tToken),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Server error occurred',
          )),
        );
      },
    );

    test('should throw ServerException when id is empty', () async {
      // act & assert
      expect(
        () => dataSource.deleteProduct('', token: tToken),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
