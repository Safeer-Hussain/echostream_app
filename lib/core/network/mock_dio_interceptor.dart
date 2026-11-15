import 'dart:math';

import 'package:dio/dio.dart';

class MockDioInterceptor extends Interceptor {
  int minLatencyMs;
  int maxLatencyMs;
  bool forceHttp503Error;
  bool simulateOffline;

  final Random _random = Random();

  MockDioInterceptor({
    this.minLatencyMs = 400,
    this.maxLatencyMs = 850,
    this.forceHttp503Error = false,
    this.simulateOffline = false,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final latency =
        minLatencyMs +
        (maxLatencyMs > minLatencyMs
            ? _random.nextInt(maxLatencyMs - minLatencyMs)
            : 0);
    await Future.delayed(Duration(milliseconds: latency));

    if (simulateOffline) {
      handler.reject(
        DioException(
          requestOptions: options,
          error:
              'Simulated Network Offline: Falling back to SQLite Vault cache',
          type: DioExceptionType.connectionError,
        ),
      );
      return;
    }

    if (forceHttp503Error && options.path.contains('/api/')) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            statusMessage: 'Service Unavailable (Recruiter Debug Simulation)',
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    handler.next(options);
  }
}
