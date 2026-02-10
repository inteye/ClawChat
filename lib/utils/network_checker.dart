/// 网络检查工具
///
/// 提供网络连接状态检查和诊断功能
library;

import 'dart:io';
import 'dart:async';

/// 网络检查结果
class NetworkCheckResult {
  final bool isConnected;
  final String? error;
  final Map<String, dynamic> details;

  const NetworkCheckResult({
    required this.isConnected,
    this.error,
    this.details = const {},
  });

  @override
  String toString() {
    if (isConnected) {
      return '✅ 网络连接正常\n详情: $details';
    } else {
      return '❌ 网络连接异常\n错误: $error\n详情: $details';
    }
  }
}

/// 网络检查器
class NetworkChecker {
  NetworkChecker._();

  /// 检查网络连接状态
  static Future<NetworkCheckResult> checkConnection() async {
    final details = <String, dynamic>{};

    try {
      // 1. 检查网络接口
      final interfaces = await NetworkInterface.list();
      details['interfaces'] = interfaces.length;
      details['interfaceNames'] = interfaces.map((i) => i.name).toList();

      if (interfaces.isEmpty) {
        return NetworkCheckResult(
          isConnected: false,
          error: '未找到网络接口',
          details: details,
        );
      }

      // 2. 检查是否有活动的网络地址
      var hasActiveAddress = false;
      for (var interface in interfaces) {
        if (interface.addresses.isNotEmpty) {
          hasActiveAddress = true;
          details['activeInterface'] = interface.name;
          details['addresses'] =
              interface.addresses.map((a) => a.address).toList();
          break;
        }
      }

      if (!hasActiveAddress) {
        return NetworkCheckResult(
          isConnected: false,
          error: '没有活动的网络地址',
          details: details,
        );
      }

      // 3. 测试 DNS 解析
      try {
        final dnsStart = DateTime.now();
        final addresses = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));
        final dnsTime = DateTime.now().difference(dnsStart).inMilliseconds;

        details['dnsResolution'] = 'success';
        details['dnsTime'] = '${dnsTime}ms';
        details['dnsAddresses'] = addresses.map((a) => a.address).toList();
      } catch (e) {
        details['dnsResolution'] = 'failed';
        details['dnsError'] = e.toString();
        return NetworkCheckResult(
          isConnected: false,
          error: 'DNS 解析失败: $e',
          details: details,
        );
      }

      // 4. 测试互联网连接（ping 公共服务器）
      try {
        final pingStart = DateTime.now();
        final socket = await Socket.connect(
          'google.com',
          80,
          timeout: const Duration(seconds: 5),
        );
        final pingTime = DateTime.now().difference(pingStart).inMilliseconds;
        socket.destroy();

        details['internetConnection'] = 'success';
        details['pingTime'] = '${pingTime}ms';
      } catch (e) {
        details['internetConnection'] = 'failed';
        details['pingError'] = e.toString();
        return NetworkCheckResult(
          isConnected: false,
          error: '无法连接到互联网: $e',
          details: details,
        );
      }

      return NetworkCheckResult(
        isConnected: true,
        details: details,
      );
    } catch (e) {
      return NetworkCheckResult(
        isConnected: false,
        error: '网络检查失败: $e',
        details: details,
      );
    }
  }

  /// 检查特定主机的连接性
  static Future<bool> canReachHost(String host, int port) async {
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 测试 DNS 解析
  static Future<List<String>> resolveDns(String host) async {
    try {
      final addresses = await InternetAddress.lookup(host);
      return addresses.map((a) => a.address).toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取本地网络信息
  static Future<Map<String, dynamic>> getLocalNetworkInfo() async {
    final info = <String, dynamic>{};

    try {
      final interfaces = await NetworkInterface.list();
      final interfaceList = <Map<String, dynamic>>[];

      for (var interface in interfaces) {
        final interfaceInfo = <String, dynamic>{
          'name': interface.name,
          'index': interface.index,
          'addresses': [],
        };

        for (var addr in interface.addresses) {
          interfaceInfo['addresses'].add({
            'address': addr.address,
            'type': addr.type.name,
            'isLoopback': addr.isLoopback,
            'isLinkLocal': addr.isLinkLocal,
            'isMulticast': addr.isMulticast,
          });
        }

        interfaceList.add(interfaceInfo);
      }

      info['interfaces'] = interfaceList;
      info['interfaceCount'] = interfaces.length;
    } catch (e) {
      info['error'] = e.toString();
    }

    return info;
  }

  /// 诊断网络问题
  static Future<String> diagnoseNetworkIssues() async {
    final buffer = StringBuffer();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('🔍 网络诊断报告');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln();

    // 1. 检查网络接口
    buffer.writeln('📡 步骤 1: 检查网络接口');
    try {
      final interfaces = await NetworkInterface.list();
      if (interfaces.isEmpty) {
        buffer.writeln('   ❌ 未找到网络接口');
        buffer.writeln('   💡 请检查设备的网络设置');
      } else {
        buffer.writeln('   ✅ 找到 ${interfaces.length} 个网络接口');
        for (var interface in interfaces) {
          buffer.writeln('   - ${interface.name}');
          for (var addr in interface.addresses) {
            buffer.writeln('     • ${addr.address} (${addr.type.name})');
          }
        }
      }
    } catch (e) {
      buffer.writeln('   ❌ 检查失败: $e');
    }
    buffer.writeln();

    // 2. 测试 DNS 解析
    buffer.writeln('🌐 步骤 2: 测试 DNS 解析');
    final testHosts = ['google.com', 'cloudflare.com', 'baidu.com'];
    var dnsSuccess = 0;

    for (var host in testHosts) {
      try {
        final start = DateTime.now();
        final addresses = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 5));
        final time = DateTime.now().difference(start).inMilliseconds;
        buffer.writeln('   ✅ $host: ${addresses.first.address} (${time}ms)');
        dnsSuccess++;
      } catch (e) {
        buffer.writeln('   ❌ $host: 解析失败 ($e)');
      }
    }

    if (dnsSuccess == 0) {
      buffer.writeln('   💡 DNS 解析完全失败，可能的原因:');
      buffer.writeln('      1. 没有网络连接');
      buffer.writeln('      2. DNS 服务器不可用');
      buffer.writeln('      3. 防火墙阻止了 DNS 查询');
    }
    buffer.writeln();

    // 3. 测试互联网连接
    buffer.writeln('🔌 步骤 3: 测试互联网连接');
    final testServers = [
      {'host': 'google.com', 'port': 80},
      {'host': 'cloudflare.com', 'port': 80},
      {'host': '8.8.8.8', 'port': 53}, // Google DNS
    ];
    var connectionSuccess = 0;

    for (var server in testServers) {
      final host = server['host'] as String;
      final port = server['port'] as int;
      try {
        final start = DateTime.now();
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(seconds: 5),
        );
        final time = DateTime.now().difference(start).inMilliseconds;
        socket.destroy();
        buffer.writeln('   ✅ $host:$port 连接成功 (${time}ms)');
        connectionSuccess++;
      } catch (e) {
        buffer.writeln('   ❌ $host:$port 连接失败');
      }
    }

    if (connectionSuccess == 0) {
      buffer.writeln('   💡 无法连接到互联网，可能的原因:');
      buffer.writeln('      1. 设备未连接到网络');
      buffer.writeln('      2. 网络需要认证（如 WiFi 登录页面）');
      buffer.writeln('      3. 防火墙阻止了所有出站连接');
      buffer.writeln('      4. 代理设置问题');
    }
    buffer.writeln();

    // 4. 总结
    buffer.writeln('📊 诊断总结');
    if (dnsSuccess > 0 && connectionSuccess > 0) {
      buffer.writeln('   ✅ 网络连接正常');
      buffer.writeln('   - DNS 解析: $dnsSuccess/${testHosts.length} 成功');
      buffer.writeln('   - 互联网连接: $connectionSuccess/${testServers.length} 成功');
    } else if (dnsSuccess > 0) {
      buffer.writeln('   ⚠️  DNS 可用但无法建立连接');
      buffer.writeln('   💡 可能是防火墙或代理问题');
    } else {
      buffer.writeln('   ❌ 网络连接异常');
      buffer.writeln('   💡 请检查设备的网络设置');
    }

    buffer.writeln();
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    return buffer.toString();
  }

  /// 获取网络诊断建议
  static List<String> getNetworkTroubleshootingTips() {
    return [
      '检查设备是否连接到 WiFi 或移动网络',
      '尝试打开浏览器访问网页，确认网络可用',
      '检查是否需要通过登录页面认证（如公共 WiFi）',
      '确认没有启用飞行模式',
      '尝试重启网络连接（关闭后重新打开 WiFi）',
      '检查防火墙或 VPN 设置',
      '确认 DNS 设置正确（可以尝试使用 8.8.8.8）',
      '如果使用代理，确认代理设置正确',
      '尝试连接到其他网络进行测试',
      '重启设备后重试',
    ];
  }

  /// 检查是否有网络权限（主要用于移动平台）
  static Future<bool> hasNetworkPermission() async {
    try {
      // 尝试进行一个简单的网络操作
      await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      return true;
    } catch (e) {
      // 如果是权限问题，通常会抛出特定的异常
      if (e.toString().contains('permission') ||
          e.toString().contains('denied')) {
        return false;
      }
      // 其他错误（如网络不可用）不代表没有权限
      return true;
    }
  }

  /// 测试特定 URL 的连接性
  static Future<Map<String, dynamic>> testUrl(String url) async {
    final result = <String, dynamic>{};

    try {
      // 解析 URL
      final uri = Uri.parse(url);
      result['url'] = url;
      result['scheme'] = uri.scheme;
      result['host'] = uri.host;
      result['port'] =
          uri.hasPort ? uri.port : (uri.scheme == 'wss' ? 443 : 80);

      // 测试 DNS
      try {
        final dnsStart = DateTime.now();
        final addresses = await InternetAddress.lookup(uri.host)
            .timeout(const Duration(seconds: 5));
        result['dnsResolution'] = 'success';
        result['dnsTime'] = DateTime.now().difference(dnsStart).inMilliseconds;
        result['ipAddresses'] = addresses.map((a) => a.address).toList();
      } catch (e) {
        result['dnsResolution'] = 'failed';
        result['dnsError'] = e.toString();
        return result;
      }

      // 测试 TCP 连接
      try {
        final port = uri.hasPort ? uri.port : (uri.scheme == 'wss' ? 443 : 80);
        final tcpStart = DateTime.now();
        final socket = await Socket.connect(
          uri.host,
          port,
          timeout: const Duration(seconds: 10),
        );
        result['tcpConnection'] = 'success';
        result['tcpTime'] = DateTime.now().difference(tcpStart).inMilliseconds;
        result['localAddress'] = socket.address.address;
        result['remoteAddress'] = socket.remoteAddress.address;
        socket.destroy();
      } catch (e) {
        result['tcpConnection'] = 'failed';
        result['tcpError'] = e.toString();
      }
    } catch (e) {
      result['error'] = e.toString();
    }

    return result;
  }
}
