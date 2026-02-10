/// 验证器工具类
///
/// 提供各种输入验证功能
library;

import '../utils/constants.dart';
import '../utils/connection_diagnostics.dart';

/// 验证器类
class Validators {
  Validators._();

  /// 验证 WebSocket URL
  static String? validateWebSocketUrl(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.invalidUrl;
    }

    // 使用 ConnectionDiagnostics 进行详细验证
    final error = ConnectionDiagnostics.validateUrl(value);
    if (error != null) {
      return error;
    }

    // 可选：强制使用 wss:// (安全连接) - 注释掉以允许 ws://
    // if (!value.startsWith('wss://')) {
    //   return ErrorMessages.urlMustBeSecure;
    // }

    return null;
  }

  /// 验证 WebSocket URL（宽松模式，允许 ws:// 和 wss://）
  static String? validateWebSocketUrlPermissive(String? value) {
    if (value == null || value.isEmpty) {
      return ErrorMessages.invalidUrl;
    }

    // 使用 ConnectionDiagnostics 进行验证
    return ConnectionDiagnostics.validateUrl(value);
  }

  /// 获取 URL 解析信息（用于调试）
  static Map<String, dynamic> getUrlInfo(String url) {
    return ConnectionDiagnostics.parseUrl(url);
  }

  /// 验证密码（可选）
  static String? validatePassword(String? value) {
    // 密码是可选的，所以空值也是有效的
    if (value == null || value.isEmpty) {
      return null;
    }

    // 可以添加密码强度验证
    // 这里暂时不做限制
    return null;
  }

  /// 验证消息内容
  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ErrorMessages.messageEmpty;
    }

    if (value.length > AppConstants.maxMessageLength) {
      return ErrorMessages.messageTooLong;
    }

    return null;
  }

  /// 验证端口号
  static String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 端口是可选的
    }

    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      return '端口号必须在 1-65535 之间';
    }

    return null;
  }

  /// 清理和标准化 URL
  static String normalizeUrl(String url) {
    String normalized = url.trim();

    // 移除末尾的斜杠
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  }

  /// 检查是否为安全连接
  static bool isSecureUrl(String url) {
    return url.startsWith('wss://');
  }

  /// 从 URL 提取主机名
  static String? extractHost(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return null;
    }
  }

  /// 从 URL 提取端口
  static int? extractPort(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.port;
    } catch (e) {
      return null;
    }
  }
}
