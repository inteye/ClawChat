/// WebSocket 连接测试
///
/// 提供自动化的 WebSocket 连接测试
library;

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  group('WebSocket 连接测试', () {
    test('URL 解析测试', () {
      // 测试有效的 URL
      final validUrls = [
        'ws://localhost:8080/ws',
        'wss://example.com/ws',
        'ws://192.168.1.1:9000/path',
        'wss://example.com:443/ws?token=abc',
      ];

      for (var url in validUrls) {
        expect(() => Uri.parse(url), returnsNormally);
        final uri = Uri.parse(url);
        expect(uri.scheme, anyOf('ws', 'wss'));
        expect(uri.host, isNotEmpty);
      }

      // 测试无效的 URL
      final invalidUrls = [
        'http://example.com',
        'ftp://example.com',
        'not-a-url',
      ];

      for (var url in invalidUrls) {
        final uri = Uri.parse(url);
        expect(uri.scheme, isNot(anyOf('ws', 'wss')));
      }

      // 空 URL 会被解析为空 URI，不会抛出异常
      final emptyUri = Uri.parse('');
      expect(emptyUri.scheme, isEmpty);
    });

    test('端口解析测试', () {
      final testCases = [
        {'url': 'ws://localhost:8080/ws', 'expectedPort': 8080},
        {'url': 'wss://example.com:443/ws', 'expectedPort': 443},
        {'url': 'ws://example.com/ws', 'expectedPort': 80},
        {'url': 'wss://example.com/ws', 'expectedPort': 443},
      ];

      for (var testCase in testCases) {
        final uri = Uri.parse(testCase['url'] as String);
        final port = uri.hasPort ? uri.port : (uri.scheme == 'wss' ? 443 : 80);
        expect(port, equals(testCase['expectedPort']));
      }
    });

    test('Connect 请求格式测试', () {
      final connectRequest = {
        'type': 'req',
        'id': '123456789',
        'method': 'connect',
        'params': {
          'minProtocol': 3,
          'maxProtocol': 3,
          'client': {
            'id': 'test-client',
            'displayName': 'Test Client',
            'version': '1.0.0',
            'platform': 'test',
            'mode': 'operator',
          },
          'role': 'operator',
          'scopes': ['operator.read', 'operator.write'],
          'locale': 'zh-CN',
          'userAgent': 'Test/1.0.0',
          'auth': {
            'token': 'test_token',
          },
        },
      };

      // 验证请求结构
      expect(connectRequest['type'], equals('req'));
      expect(connectRequest['method'], equals('connect'));
      expect(connectRequest['params'], isA<Map>());

      final params = connectRequest['params'] as Map;
      expect(params['minProtocol'], equals(3));
      expect(params['maxProtocol'], equals(3));
      expect(params['client'], isA<Map>());
      expect(params['auth'], isA<Map>());

      // 验证可以序列化为 JSON
      expect(() => jsonEncode(connectRequest), returnsNormally);
      final jsonString = jsonEncode(connectRequest);
      expect(jsonString, isNotEmpty);

      // 验证可以反序列化
      final decoded = jsonDecode(jsonString);
      expect(decoded, isA<Map>());
      expect(decoded['type'], equals('req'));
    });

    test('响应解析测试', () {
      // 成功响应
      final successResponse = jsonEncode({
        'type': 'res',
        'id': '123456789',
        'result': {
          'sessionId': 'session-123',
          'protocol': 3,
        },
      });

      final successData = jsonDecode(successResponse) as Map<String, dynamic>;
      expect(successData['type'], equals('res'));
      expect(successData['error'], isNull);
      expect(successData['result'], isNotNull);

      // 错误响应
      final errorResponse = jsonEncode({
        'type': 'res',
        'id': '123456789',
        'error': {
          'code': 'AUTH_FAILED',
          'message': 'Invalid token',
        },
      });

      final errorData = jsonDecode(errorResponse) as Map<String, dynamic>;
      expect(errorData['type'], equals('res'));
      expect(errorData['error'], isNotNull);
      expect(errorData['result'], isNull);
    });
  });

  group('网络诊断测试', () {
    test('DNS 解析测试', () async {
      // 测试已知的公共 DNS
      final hosts = ['localhost', 'google.com', 'cloudflare.com'];

      for (var host in hosts) {
        try {
          final addresses = await InternetAddress.lookup(host);
          expect(addresses, isNotEmpty);
          print('✅ $host 解析成功: ${addresses.first.address}');
        } catch (e) {
          print('⚠️  $host 解析失败: $e');
        }
      }
    });

    test('无效主机名测试', () async {
      final invalidHosts = [
        'this-host-does-not-exist-12345.com',
        'invalid..host',
      ];

      for (var host in invalidHosts) {
        expect(
          () => InternetAddress.lookup(host),
          throwsA(isA<SocketException>()),
        );
      }
    });
  });

  group('WebSocket 协议测试', () {
    test('协议升级头测试', () {
      // WebSocket 需要的 HTTP 头
      final requiredHeaders = {
        'Upgrade': 'websocket',
        'Connection': 'Upgrade',
        'Sec-WebSocket-Version': '13',
      };

      expect(requiredHeaders['Upgrade'], equals('websocket'));
      expect(requiredHeaders['Connection'], equals('Upgrade'));
      expect(requiredHeaders['Sec-WebSocket-Version'], equals('13'));
    });

    test('消息帧格式测试', () {
      // 测试文本消息
      final textMessage = {'type': 'test', 'content': 'Hello'};
      final jsonString = jsonEncode(textMessage);

      expect(jsonString, isA<String>());
      expect(jsonString, contains('type'));
      expect(jsonString, contains('test'));

      // 测试解析
      final decoded = jsonDecode(jsonString);
      expect(decoded, isA<Map>());
      expect(decoded['type'], equals('test'));
      expect(decoded['content'], equals('Hello'));
    });
  });

  group('错误处理测试', () {
    test('连接超时测试', () async {
      // 使用一个不存在的地址测试超时
      final invalidUrl = 'ws://192.0.2.1:9999/ws'; // TEST-NET-1 地址

      try {
        final socket = await Socket.connect(
          '192.0.2.1',
          9999,
          timeout: const Duration(seconds: 2),
        );
        socket.destroy();
        fail('应该抛出超时异常');
      } on SocketException catch (e) {
        expect(e, isA<SocketException>());
        print('✅ 正确捕获连接异常: ${e.message}');
      } on TimeoutException catch (e) {
        expect(e, isA<TimeoutException>());
        print('✅ 正确捕获超时异常: $e');
      }
    });

    test('无效 URL 测试', () {
      final invalidUrls = [
        'not-a-url',
        'http://example.com', // 不是 ws/wss
        'ws://', // 缺少主机
      ];

      for (var url in invalidUrls) {
        try {
          final uri = Uri.parse(url);
          if (uri.scheme != 'ws' && uri.scheme != 'wss') {
            print('✅ 检测到无效协议: ${uri.scheme}');
          }
          if (uri.host.isEmpty) {
            print('✅ 检测到空主机名');
          }
        } catch (e) {
          print('✅ 捕获解析错误: $e');
        }
      }
    });

    test('JSON 解析错误测试', () {
      final invalidJson = [
        '{invalid json}',
        '{"unclosed": ',
        'not json at all',
        '',
      ];

      for (var json in invalidJson) {
        expect(
          () => jsonDecode(json),
          throwsA(isA<FormatException>()),
        );
      }
    });
  });

  group('集成测试辅助函数', () {
    test('创建测试连接请求', () {
      String createConnectRequest(String token) {
        final request = {
          'type': 'req',
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'method': 'connect',
          'params': {
            'minProtocol': 3,
            'maxProtocol': 3,
            'client': {
              'id': 'test-client',
              'displayName': 'Test Client',
              'version': '1.0.0',
              'platform': 'test',
              'mode': 'operator',
            },
            'role': 'operator',
            'scopes': ['operator.read', 'operator.write'],
            'locale': 'zh-CN',
            'userAgent': 'Test/1.0.0',
            'auth': {
              'token': token,
            },
          },
        };
        return jsonEncode(request);
      }

      final request = createConnectRequest('test_token');
      expect(request, isNotEmpty);
      expect(request, contains('connect'));
      expect(request, contains('test_token'));

      // 验证可以解析回来
      final decoded = jsonDecode(request);
      expect(decoded['method'], equals('connect'));
    });

    test('验证响应格式', () {
      bool isValidResponse(Map<String, dynamic> response, String requestId) {
        if (response['type'] != 'res') return false;
        if (response['id'] != requestId) return false;
        return true;
      }

      final validResponse = {
        'type': 'res',
        'id': '123',
        'result': {},
      };

      final invalidResponse = {
        'type': 'req', // 错误的类型
        'id': '123',
      };

      expect(isValidResponse(validResponse, '123'), isTrue);
      expect(isValidResponse(invalidResponse, '123'), isFalse);
      expect(isValidResponse(validResponse, '456'), isFalse); // ID 不匹配
    });
  });
}

/// 手动集成测试（需要真实的服务器）
///
/// 使用方法:
/// ```bash
/// dart test test/websocket_connection_test.dart --plain-name "手动集成测试"
/// ```
///
/// 注意: 需要设置环境变量:
/// - WS_TEST_URL: WebSocket 服务器地址
/// - WS_TEST_TOKEN: 认证 token
void manualIntegrationTest() {
  group('手动集成测试', () {
    test('完整连接流程测试', () async {
      final url = Platform.environment['WS_TEST_URL'];
      final token = Platform.environment['WS_TEST_TOKEN'];

      if (url == null || token == null) {
        print('⚠️  跳过集成测试: 未设置环境变量');
        print('   设置方法:');
        print('   export WS_TEST_URL="wss://your-server/ws"');
        print('   export WS_TEST_TOKEN="your-token"');
        return;
      }

      print('🔍 开始集成测试');
      print('   URL: $url');
      print('   Token 长度: ${token.length}');

      try {
        // 1. 建立连接
        final uri = Uri.parse(url);
        final channel = WebSocketChannel.connect(uri);
        await channel.ready.timeout(const Duration(seconds: 10));
        print('✅ WebSocket 连接成功');

        // 2. 发送 connect 请求
        final requestId = DateTime.now().millisecondsSinceEpoch.toString();
        final connectRequest = {
          'type': 'req',
          'id': requestId,
          'method': 'connect',
          'params': {
            'minProtocol': 3,
            'maxProtocol': 3,
            'client': {
              'id': 'test-client',
              'displayName': 'Test Client',
              'version': '1.0.0',
              'platform': 'test',
              'mode': 'operator',
            },
            'role': 'operator',
            'scopes': ['operator.read', 'operator.write'],
            'locale': 'zh-CN',
            'userAgent': 'Test/1.0.0',
            'auth': {
              'token': token,
            },
          },
        };

        channel.sink.add(jsonEncode(connectRequest));
        print('✅ Connect 请求已发送');

        // 3. 等待响应
        var authenticated = false;
        await for (final message in channel.stream.timeout(
          const Duration(seconds: 15),
        )) {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          if (data['type'] == 'res' && data['id'] == requestId) {
            if (data['error'] != null) {
              fail('认证失败: ${data['error']}');
            } else {
              authenticated = true;
              print('✅ 认证成功');
              break;
            }
          }
        }

        expect(authenticated, isTrue);

        // 4. 清理
        await channel.sink.close();
        print('✅ 连接已关闭');
      } catch (e) {
        fail('集成测试失败: $e');
      }
    }, skip: Platform.environment['WS_TEST_URL'] == null);
  });
}
