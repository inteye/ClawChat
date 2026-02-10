/// 服务配置模型
/// 
/// 简化的 OpenClaw 服务配置
library;

import 'package:hive/hive.dart';

part 'service_config.g.dart';

/// 服务配置模型
@HiveType(typeId: 2)
class ServiceConfig {
  /// 服务唯一标识
  @HiveField(0)
  final String id;

  /// 服务名称
  @HiveField(1)
  final String name;

  /// WebSocket URL
  @HiveField(2)
  final String wsUrl;

  /// 认证 Token
  @HiveField(3)
  final String token;

  /// 是否为当前激活的服务
  @HiveField(4)
  final bool isActive;

  /// 创建时间
  @HiveField(5)
  final DateTime createdAt;

  const ServiceConfig({
    required this.id,
    required this.name,
    required this.wsUrl,
    required this.token,
    this.isActive = false,
    required this.createdAt,
  });

  /// 创建新服务
  factory ServiceConfig.create({
    required String name,
    required String wsUrl,
    required String token,
  }) {
    return ServiceConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      wsUrl: wsUrl,
      token: token,
      createdAt: DateTime.now(),
    );
  }

  /// 验证配置是否有效
  bool get isValid {
    if (name.isEmpty) return false;
    if (wsUrl.isEmpty) return false;
    if (!wsUrl.startsWith('wss://') && !wsUrl.startsWith('ws://')) {
      return false;
    }
    if (token.isEmpty) return false;
    return true;
  }

  /// 复制并更新配置
  ServiceConfig copyWith({
    String? id,
    String? name,
    String? wsUrl,
    String? token,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ServiceConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      wsUrl: wsUrl ?? this.wsUrl,
      token: token ?? this.token,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'wsUrl': wsUrl,
      'token': token,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 从 JSON 创建
  factory ServiceConfig.fromJson(Map<String, dynamic> json) {
    return ServiceConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      wsUrl: json['wsUrl'] as String,
      token: json['token'] as String,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'ServiceConfig(id: $id, name: $name, wsUrl: $wsUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
