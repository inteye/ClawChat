/// 配置数据模型
///
/// 存储 OpenClaw Gateway 连接配置
///
/// @deprecated 此模型包含过多字段，建议使用 [ServiceConfig] 进行多服务管理。
/// 保留此模型仅用于向后兼容。
library;

import 'package:hive/hive.dart';

part 'config.g.dart';

/// 配置模型
///
/// @deprecated 建议使用 [ServiceConfig] 代替，它提供了更简洁的服务配置管理。
/// 此模型将在未来版本中移除。
@HiveType(typeId: 1)
class Config {
  /// Gateway WebSocket URL
  @HiveField(0)
  final String gatewayUrl;

  /// 认证密码（可选）
  @HiveField(1)
  final String? password;

  /// 是否自动重连
  @HiveField(2)
  final bool autoReconnect;

  /// 重连间隔（毫秒）
  @HiveField(3)
  final int reconnectInterval;

  /// 最大重连次数
  @HiveField(4)
  final int maxReconnectAttempts;

  /// Agent ID（可选，指定路由到特定 Agent）
  @HiveField(5)
  final String? agentId;

  /// Gateway Token（用于认证，优先于 password）
  @HiveField(6)
  final String? token;

  /// 角色（operator, system 等）
  @HiveField(7)
  final String role;

  /// 权限范围列表
  @HiveField(8)
  final List<String> scopes;

  /// 协议最小版本
  @HiveField(9)
  final int minProtocol;

  /// 协议最大版本
  @HiveField(10)
  final int maxProtocol;

  const Config({
    required this.gatewayUrl,
    this.password,
    this.autoReconnect = true,
    this.reconnectInterval = 3000,
    this.maxReconnectAttempts = 5,
    this.agentId,
    this.token,
    this.role = 'operator',
    this.scopes = const ['operator.read', 'operator.write'],
    this.minProtocol = 3,
    this.maxProtocol = 3,
  });

  /// 默认配置
  factory Config.defaultConfig() {
    return const Config(
      gatewayUrl: '',
      autoReconnect: true,
      reconnectInterval: 3000,
      maxReconnectAttempts: 5,
      role: 'operator',
      scopes: ['operator.read', 'operator.write'],
      minProtocol: 3,
      maxProtocol: 3,
    );
  }

  /// 验证配置是否有效
  bool get isValid {
    if (gatewayUrl.isEmpty) return false;
    if (!gatewayUrl.startsWith('wss://') && !gatewayUrl.startsWith('ws://')) {
      return false;
    }
    return true;
  }

  /// 是否强制使用安全连接
  bool get isSecure => gatewayUrl.startsWith('wss://');

  /// 复制并更新配置
  Config copyWith({
    String? gatewayUrl,
    String? password,
    bool? autoReconnect,
    int? reconnectInterval,
    int? maxReconnectAttempts,
    String? agentId,
    String? token,
    String? role,
    List<String>? scopes,
    int? minProtocol,
    int? maxProtocol,
  }) {
    return Config(
      gatewayUrl: gatewayUrl ?? this.gatewayUrl,
      password: password ?? this.password,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      reconnectInterval: reconnectInterval ?? this.reconnectInterval,
      maxReconnectAttempts: maxReconnectAttempts ?? this.maxReconnectAttempts,
      agentId: agentId ?? this.agentId,
      token: token ?? this.token,
      role: role ?? this.role,
      scopes: scopes ?? this.scopes,
      minProtocol: minProtocol ?? this.minProtocol,
      maxProtocol: maxProtocol ?? this.maxProtocol,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'gatewayUrl': gatewayUrl,
      'password': password,
      'autoReconnect': autoReconnect,
      'reconnectInterval': reconnectInterval,
      'maxReconnectAttempts': maxReconnectAttempts,
      'agentId': agentId,
      'token': token,
      'role': role,
      'scopes': scopes,
      'minProtocol': minProtocol,
      'maxProtocol': maxProtocol,
    };
  }

  /// 从 JSON 创建
  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      gatewayUrl: json['gatewayUrl'] as String,
      password: json['password'] as String?,
      autoReconnect: json['autoReconnect'] as bool? ?? true,
      reconnectInterval: json['reconnectInterval'] as int? ?? 3000,
      maxReconnectAttempts: json['maxReconnectAttempts'] as int? ?? 5,
      agentId: json['agentId'] as String?,
      token: json['token'] as String?,
      role: json['role'] as String? ?? 'operator',
      scopes: (json['scopes'] as List<dynamic>?)?.cast<String>() ??
          const ['operator.read', 'operator.write'],
      minProtocol: json['minProtocol'] as int? ?? 3,
      maxProtocol: json['maxProtocol'] as int? ?? 3,
    );
  }

  @override
  String toString() {
    return 'Config(gatewayUrl: $gatewayUrl, autoReconnect: $autoReconnect, role: $role, scopes: $scopes, agentId: $agentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Config &&
        other.gatewayUrl == gatewayUrl &&
        other.password == password &&
        other.autoReconnect == autoReconnect &&
        other.reconnectInterval == reconnectInterval &&
        other.maxReconnectAttempts == maxReconnectAttempts &&
        other.agentId == agentId &&
        other.token == token &&
        other.role == role &&
        _listEquals(other.scopes, scopes) &&
        other.minProtocol == minProtocol &&
        other.maxProtocol == maxProtocol;
  }

  @override
  int get hashCode {
    return Object.hash(
      gatewayUrl,
      password,
      autoReconnect,
      reconnectInterval,
      maxReconnectAttempts,
      agentId,
      token,
      role,
      Object.hashAll(scopes),
      minProtocol,
      maxProtocol,
    );
  }

  /// Helper method to compare lists
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
