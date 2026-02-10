/// 服务配置存储服务
///
/// 管理服务配置的持久化存储
library;

import 'package:hive_flutter/hive_flutter.dart';
import '../models/service_config.dart';
import '../utils/constants.dart';

/// 服务存储服务（单例）
class ServiceStorage {
  static ServiceStorage? _instance;
  Box<ServiceConfig>? _box;

  // 私有构造函数
  ServiceStorage._();

  /// 获取单例实例
  static ServiceStorage get instance {
    if (_instance == null) {
      throw StateError('ServiceStorage 未初始化，请先调用 initialize()');
    }
    return _instance!;
  }

  /// 静态初始化方法
  static void initialize(Box<ServiceConfig> box) {
    _instance = ServiceStorage._();
    _instance!._box = box;
    print('ServiceStorage 已初始化');
  }

  /// 确保 Box 已打开
  void _ensureInitialized() {
    if (_box == null || !_box!.isOpen) {
      throw StateError('ServiceStorage 未初始化，请先调用 initialize()');
    }
  }

  /// 保存服务列表
  Future<void> saveServices(List<ServiceConfig> services) async {
    _ensureInitialized();

    // 清空现有数据
    await _box!.clear();

    // 保存新数据
    final map = {for (var service in services) service.id: service};
    await _box!.putAll(map);

    print('已保存 ${services.length} 个服务配置');
  }

  /// 加载服务列表
  List<ServiceConfig> loadServices() {
    _ensureInitialized();

    final services = _box!.values.toList();
    print('已加载 ${services.length} 个服务配置');

    return services;
  }

  /// 保存单个服务
  Future<void> saveService(ServiceConfig service) async {
    _ensureInitialized();
    await _box!.put(service.id, service);
    print('已保存服务: ${service.name}');
  }

  /// 删除服务
  Future<void> deleteService(String serviceId) async {
    _ensureInitialized();
    await _box!.delete(serviceId);
    print('已删除服务: $serviceId');
  }

  /// 获取服务
  ServiceConfig? getService(String serviceId) {
    _ensureInitialized();
    return _box!.get(serviceId);
  }

  /// 检查服务是否存在
  bool hasService(String serviceId) {
    _ensureInitialized();
    return _box!.containsKey(serviceId);
  }

  /// 获取服务数量
  int getServiceCount() {
    _ensureInitialized();
    return _box!.length;
  }

  /// 清空所有服务
  Future<void> clearAll() async {
    _ensureInitialized();
    await _box!.clear();
    print('已清空所有服务配置');
  }

  /// 关闭存储
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      print('服务存储已关闭');
    }
  }

  /// 压缩数据库
  Future<void> compact() async {
    _ensureInitialized();
    await _box!.compact();
    print('服务存储已压缩');
  }
}
