/// 连接诊断工具
///
/// 提供 WebSocket 连接问题的诊断和分析功能
library;

import 'dart:io';
import 'dart:async';

/// 连接诊断工具类
class ConnectionDiagnostics {
  ConnectionDiagnostics._();

  /// 验证 URL 格式
  static String? validateUrl(String url) {
    if (url.isEmpty) {
      return 'URL 不能为空';
    }

    // 支持 ws://, wss://, http://, https://
    if (!url.startsWith('ws://') &&
        !url.startsWith('wss://') &&
        !url.startsWith('http://') &&
        !url.startsWith('https://')) {
      return 'URL 必须以 ws://, wss://, http:// 或 https:// 开头';
    }

    // 验证 URL 格式
    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) {
        return 'URL 格式错误：缺少主机名';
      }
      return null; // 验证通过
    } catch (e) {
      return 'URL 格式错误: $e';
    }
  }

  /// 解析 URL 并返回详细信息
  static Map<String, dynamic> parseUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final isSecure = uri.scheme == 'wss' || uri.scheme == 'https';
      final defaultPort = isSecure ? 443 : 80;

      return {
        'valid': true,
        'scheme': uri.scheme,
        'host': uri.host,
        'port': uri.hasPort ? uri.port : defaultPort,
        'path': uri.path.isEmpty ? '/' : uri.path,
        'query': uri.query,
        'hasToken': uri.queryParameters.containsKey('token'),
        'queryParams': uri.queryParameters,
        'isSecure': isSecure,
        'isTailscale': uri.host.contains('.ts.net'),
      };
    } catch (e) {
      return {
        'valid': false,
        'error': e.toString(),
      };
    }
  }

  /// 生成诊断信息
  static String getDiagnostics(String url, dynamic error) {
    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🔍 连接诊断信息');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();

    // URL 信息
    buffer.writeln('📍 URL 信息:');
    buffer.writeln('   $url');
    buffer.writeln();

    // 解析 URL
    final parsed = parseUrl(url);
    if (parsed['valid'] == true) {
      buffer.writeln('✅ URL 格式正确');
      buffer.writeln('   协议: ${parsed['scheme']}');
      buffer.writeln('   主机: ${parsed['host']}');
      buffer.writeln('   端口: ${parsed['port']}');
      buffer.writeln('   路径: ${parsed['path']}');
      if (parsed['query'] != null && (parsed['query'] as String).isNotEmpty) {
        buffer.writeln('   查询参数: ${parsed['query']}');
      }
      buffer.writeln('   安全连接: ${parsed['isSecure'] ? '是 (wss)' : '否 (ws)'}');
      buffer.writeln('   包含 Token: ${parsed['hasToken'] ? '是' : '否'}');
    } else {
      buffer.writeln('❌ URL 格式错误');
      buffer.writeln('   错误: ${parsed['error']}');
    }
    buffer.writeln();

    // 错误信息
    buffer.writeln('❌ 错误详情:');
    buffer.writeln('   $error');
    buffer.writeln();

    // 错误类型分析
    buffer.writeln('🔎 错误分析:');
    if (error is SocketException) {
      buffer.writeln('   类型: 网络连接错误 (SocketException)');
      buffer.writeln();
      buffer.writeln('💡 可能的原因:');
      buffer.writeln('   1. 服务器未启动或不可访问');
      buffer.writeln('   2. 主机地址或端口配置错误');
      buffer.writeln('   3. 防火墙阻止了连接');
      buffer.writeln('   4. 网络连接问题（无网络或网络不稳定）');
      buffer.writeln('   5. 服务器拒绝连接（可能需要认证）');
      buffer.writeln();
      buffer.writeln('🔧 建议的解决方案:');
      buffer.writeln('   1. 检查服务器是否正在运行');
      buffer.writeln('   2. 验证 URL 中的主机地址和端口是否正确');
      buffer.writeln('   3. 尝试在浏览器中访问服务器地址');
      buffer.writeln('   4. 检查设备的网络连接');
      buffer.writeln('   5. 确认防火墙设置允许该连接');
      buffer.writeln('   6. 如果使用 wss://，确保服务器有有效的 SSL 证书');
    } else if (error is TimeoutException) {
      buffer.writeln('   类型: 连接超时 (TimeoutException)');
      buffer.writeln();
      buffer.writeln('💡 可能的原因:');
      buffer.writeln('   1. 服务器响应缓慢');
      buffer.writeln('   2. 网络延迟过高');
      buffer.writeln('   3. 服务器负载过高');
      buffer.writeln();
      buffer.writeln('🔧 建议的解决方案:');
      buffer.writeln('   1. 检查网络连接质量');
      buffer.writeln('   2. 稍后重试');
      buffer.writeln('   3. 联系服务器管理员');
    } else if (error is HandshakeException) {
      buffer.writeln('   类型: SSL/TLS 握手失败 (HandshakeException)');
      buffer.writeln();
      buffer.writeln('💡 可能的原因:');
      buffer.writeln('   1. SSL 证书无效或过期');
      buffer.writeln('   2. 证书域名不匹配');
      buffer.writeln('   3. 使用了自签名证书');
      buffer.writeln();
      buffer.writeln('🔧 建议的解决方案:');
      buffer.writeln('   1. 确认服务器使用有效的 SSL 证书');
      buffer.writeln('   2. 如果是开发环境，考虑使用 ws:// 而非 wss://');
      buffer.writeln('   3. 联系服务器管理员更新证书');
    } else if (error is FormatException) {
      buffer.writeln('   类型: 数据格式错误 (FormatException)');
      buffer.writeln();
      buffer.writeln('💡 可能的原因:');
      buffer.writeln('   1. URL 格式不正确');
      buffer.writeln('   2. 服务器返回了无效的数据');
      buffer.writeln();
      buffer.writeln('🔧 建议的解决方案:');
      buffer.writeln('   1. 检查 URL 格式是否正确');
      buffer.writeln('   2. 确认服务器地址是否正确');
    } else {
      buffer.writeln('   类型: ${error.runtimeType}');
      buffer.writeln();
      buffer.writeln('💡 这是一个未知类型的错误');
      buffer.writeln('🔧 建议联系技术支持并提供完整的错误信息');
    }

    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return buffer.toString();
  }

  /// 生成简短的错误提示
  static String getShortErrorMessage(dynamic error) {
    if (error is SocketException) {
      return '连接被拒绝：无法连接到服务器';
    } else if (error is TimeoutException) {
      return '连接超时：服务器响应时间过长';
    } else if (error is HandshakeException) {
      return 'SSL 握手失败：证书验证失败';
    } else if (error is FormatException) {
      return '格式错误：URL 或数据格式不正确';
    } else {
      return '连接失败：$error';
    }
  }

  /// 生成用户友好的错误提示
  static String getUserFriendlyMessage(dynamic error) {
    if (error is SocketException) {
      return '无法连接到服务器，请检查：\n'
          '• 服务器地址是否正确\n'
          '• 服务器是否正在运行\n'
          '• 网络连接是否正常';
    } else if (error is TimeoutException) {
      return '连接超时，请检查：\n'
          '• 网络连接是否稳定\n'
          '• 服务器是否正常运行\n'
          '• 稍后重试';
    } else if (error is HandshakeException) {
      return 'SSL 证书验证失败，请检查：\n'
          '• 服务器证书是否有效\n'
          '• 如果是开发环境，尝试使用 ws:// 而非 wss://';
    } else {
      return '连接失败：${error.toString()}';
    }
  }

  /// 检查 URL 中是否包含 token
  static bool hasTokenInUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters.containsKey('token');
    } catch (e) {
      return false;
    }
  }

  /// 从 URL 中提取 token
  static String? extractTokenFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters['token'];
    } catch (e) {
      return null;
    }
  }

  /// 生成测试连接的建议
  static List<String> getConnectionTips() {
    return [
      '确保 URL 格式正确（ws:// 或 wss://）',
      '检查主机地址和端口号',
      '确认服务器正在运行',
      '验证网络连接是否正常',
      '如果使用 wss://，确保证书有效',
      '检查防火墙设置',
      '确认 token 认证信息正确',
    ];
  }
}
