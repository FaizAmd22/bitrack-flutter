// Envelope penolakan `{"status": false, "data": [], "error_msg": "..."}`.
//
// Sebelumnya empat endpoint Work Order membuang body response-nya, jadi
// penolakan yang datang dengan HTTP 200 lolos sebagai sukses dan user melihat
// toast "berhasil" padahal datanya tidak tersimpan.
import 'dart:convert';

import 'package:bitrack_core/base/network/api_client.dart';
import 'package:bitrack_core/base/network/api_response.dart';
import 'package:bitrack_core/screens/work_order/services/work_order_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

// Persis response yang dilaporkan dari lapangan.
const _simcardRejection = {
  'status': false,
  'data': <dynamic>[],
  'error_msg': 'Simcard Number tidak boleh kosong',
};

class _FixedAdapter implements HttpClientAdapter {
  _FixedAdapter(this.statusCode, this.body);

  final int statusCode;
  final Object body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void _respondWith(int statusCode, Object body) {
  final previous = ApiClient.dio.httpClientAdapter;
  ApiClient.dio.httpClientAdapter = _FixedAdapter(statusCode, body);
  addTearDown(() => ApiClient.dio.httpClientAdapter = previous);
}

void main() {
  setUpAll(
    () => dotenv.testLoad(fileInput: 'BASE_URL=https://example.invalid/api'),
  );

  group('throwIfRejected', () {
    test('status false: dilempar, membawa error_msg', () {
      expect(
        () => throwIfRejected(_simcardRejection),
        throwsA(
          isA<ApiRejectedException>().having(
            (e) => e.message,
            'message',
            'Simcard Number tidak boleh kosong',
          ),
        ),
      );
    });

    test('status false tanpa error_msg: tetap dilempar, pesannya null', () {
      for (final body in [
        {'status': false},
        {'status': false, 'error_msg': ''},
        {'status': false, 'error_msg': '   '},
        {'status': false, 'error_msg': null},
      ]) {
        expect(
          () => throwIfRejected(body),
          throwsA(
            isA<ApiRejectedException>().having(
              (e) => e.message,
              'message',
              null,
            ),
          ),
          reason: '$body tetap penolakan walau tanpa pesan',
        );
      }
    });

    test('nilai sukses apa pun TIDAK dianggap penolakan', () {
      // Bentuk `status` berubah-ubah antar-versi backend; yang dikenali hanya
      // boolean false eksplisit, jadi tidak ada nilai sukses yang terkunci.
      for (final body in <Object?>[
        {'status': true},
        {'status': 'success'},
        {'status': 'false'},
        {'status': 0},
        {'data': <dynamic>[]},
        null,
        'teks biasa',
      ]) {
        expect(() => throwIfRejected(body), returnsNormally, reason: '$body');
      }
    });
  });

  group('apiRejectionMessage', () {
    test('pesan dari ApiRejectedException', () {
      expect(apiRejectionMessage(const ApiRejectedException('X')), 'X');
      expect(apiRejectionMessage(const ApiRejectedException()), isNull);
    });

    test('error lain tanpa error_msg: null, pemanggil pakai pesan default', () {
      expect(apiRejectionMessage(Exception('boom')), isNull);
      expect(
        apiRejectionMessage(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        isNull,
      );
    });
  });

  group('WorkOrderApi.createWorkOrderDetail', () {
    const api = WorkOrderApi();

    test('HTTP 200 + status false: GAGAL, bukan diam-diam sukses', () async {
      _respondWith(200, _simcardRejection);

      Object? caught;
      try {
        await api.createWorkOrderDetail({'id': 'x'});
      } catch (e) {
        caught = e;
      }

      expect(caught, isA<ApiRejectedException>());
      expect(apiRejectionMessage(caught!), 'Simcard Number tidak boleh kosong');
    });

    test('HTTP 422 dengan error_msg: pesannya tetap terbaca', () async {
      _respondWith(422, _simcardRejection);

      Object? caught;
      try {
        await api.createWorkOrderDetail({'id': 'x'});
      } catch (e) {
        caught = e;
      }

      expect(caught, isA<DioException>());
      expect(apiRejectionMessage(caught!), 'Simcard Number tidak boleh kosong');
    });

    test('HTTP 200 sukses: tidak melempar', () async {
      _respondWith(200, {'status': 'success', 'data': <dynamic>[]});
      await expectLater(api.createWorkOrderDetail({'id': 'x'}), completes);
    });
  });
}
