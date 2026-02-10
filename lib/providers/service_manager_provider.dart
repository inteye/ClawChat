/// 服务管理状态管理
///
/// 管理多个服务配置的添加、删除、更新和切换
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_config.dart';
import '../services/service_storage.dart';

/// 服务管理状态类
class ServiceManagerState {
  final List<ServiceConfig> services;
  final String? activeServiceId;
  final bool isLoading;
  final String? error;

  const ServiceManagerState({
    this.services = const [],
    this.activeServiceId,
    this.isLoading = false,
    this.error,
  });

  ServiceManagerState copyWith({
    List<ServiceConfig>? services,
    String? activeServiceId,
    bool? isLoading,
    String? error,
  }) {
    return ServiceManagerState(
      services: services ?? this.services,
      activeServiceId: activeServiceId ?? this.activeServiceId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// 获取当前激活的服务
  ServiceConfig? get activeService {
    if (activeServiceId == null) return null;
    try {
      return services.firstWhere((s) => s.id == activeServiceId);
    } catch (e) {
      return null;
    }
  }

  /// 是否有激活的服务
  bool get hasActiveService => activeService != null;

  /// 服务数量
  int get serviceCount => services.length;

  /// 是否有服务
  bool get hasServices => services.isNotEmpty;
}

/// 服务管理器
class ServiceManagerNotifier extends StateNotifier<ServiceManagerState> {
  final ServiceStorage _storage;

  ServiceManagerNotifier(this._storage) : super(const ServiceManagerState()) {
    _loadServices();
  }

  /// 加载服务列表
  Future<void> _loadServices() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final services = _storage.loadServices();

      // 查找激活的服务
      String? activeId;
      for (var service in services) {
        if (service.isActive) {
          activeId = service.id;
          break;
        }
      }

      state = ServiceManagerState(
        services: services,
        activeServiceId: activeId,
        isLoading: false,
      );

      print('已加载 ${services.length} 个服务，激活服务: $activeId');
    } catch (e) {
      state = ServiceManagerState(
        isLoading: false,
        error: '加载服务失败: $e',
      );
      print('加载服务失败: $e');
    }
  }

  /// 添加服务
  Future<bool> addService(ServiceConfig service) async {
    // 验证服务配置
    if (!service.isValid) {
      state = state.copyWith(error: '服务配置无效');
      return false;
    }

    // 检查是否已存在同名服务
    if (state.services.any((s) => s.name == service.name)) {
      state = state.copyWith(error: '服务名称已存在');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newServices = [...state.services, service];
      await _storage.saveServices(newServices);

      state = state.copyWith(
        services: newServices,
        isLoading: false,
      );

      print('已添加服务: ${service.name}');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '添加服务失败: $e',
      );
      print('添加服务失败: $e');
      return false;
    }
  }

  /// 删除服务
  Future<bool> deleteService(String serviceId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newServices =
          state.services.where((s) => s.id != serviceId).toList();
      await _storage.saveServices(newServices);

      // 如果删除的是激活的服务，清除激活状态
      String? newActiveId = state.activeServiceId;
      if (state.activeServiceId == serviceId) {
        newActiveId = null;
      }

      state = ServiceManagerState(
        services: newServices,
        activeServiceId: newActiveId,
        isLoading: false,
      );

      print('已删除服务: $serviceId');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '删除服务失败: $e',
      );
      print('删除服务失败: $e');
      return false;
    }
  }

  /// 更新服务
  Future<bool> updateService(ServiceConfig service) async {
    // 验证服务配置
    if (!service.isValid) {
      state = state.copyWith(error: '服务配置无效');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final newServices = state.services.map((s) {
        return s.id == service.id ? service : s;
      }).toList();

      await _storage.saveServices(newServices);

      state = state.copyWith(
        services: newServices,
        isLoading: false,
      );

      print('已更新服务: ${service.name}');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '更新服务失败: $e',
      );
      print('更新服务失败: $e');
      return false;
    }
  }

  /// 切换激活的服务
  Future<bool> setActiveService(String? serviceId) async {
    // 如果设置为 null，清除激活状态
    if (serviceId == null) {
      state = state.copyWith(isLoading: true, error: null);

      try {
        final newServices = state.services.map((s) {
          return s.copyWith(isActive: false);
        }).toList();

        await _storage.saveServices(newServices);

        state = ServiceManagerState(
          services: newServices,
          activeServiceId: null,
          isLoading: false,
        );

        print('已清除激活服务');
        return true;
      } catch (e) {
        state = state.copyWith(
          isLoading: false,
          error: '清除激活服务失败: $e',
        );
        return false;
      }
    }

    // 检查服务是否存在
    if (!state.services.any((s) => s.id == serviceId)) {
      state = state.copyWith(error: '服务不存在');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 更新所有服务的激活状态
      final newServices = state.services.map((s) {
        return s.copyWith(isActive: s.id == serviceId);
      }).toList();

      await _storage.saveServices(newServices);

      state = ServiceManagerState(
        services: newServices,
        activeServiceId: serviceId,
        isLoading: false,
      );

      print('已切换激活服务: $serviceId');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '切换激活服务失败: $e',
      );
      print('切换激活服务失败: $e');
      return false;
    }
  }

  /// 获取服务
  ServiceConfig? getService(String serviceId) {
    try {
      return state.services.firstWhere((s) => s.id == serviceId);
    } catch (e) {
      return null;
    }
  }

  /// 重新加载服务列表
  Future<void> reloadServices() async {
    await _loadServices();
  }

  /// 清除错误
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// 清空所有服务
  Future<bool> clearAllServices() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _storage.clearAll();

      state = const ServiceManagerState(
        services: [],
        activeServiceId: null,
        isLoading: false,
      );

      print('已清空所有服务');
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '清空服务失败: $e',
      );
      print('清空服务失败: $e');
      return false;
    }
  }
}

/// ServiceStorage Provider
final serviceStorageProvider = Provider<ServiceStorage>((ref) {
  return ServiceStorage.instance;
});

/// 服务管理 Provider
final serviceManagerProvider =
    StateNotifierProvider<ServiceManagerNotifier, ServiceManagerState>((ref) {
  final storage = ref.watch(serviceStorageProvider);
  return ServiceManagerNotifier(storage);
});

/// 便捷访问器
extension ServiceManagerProviderExtension on WidgetRef {
  /// 当前激活的服务
  ServiceConfig? get activeService =>
      read(serviceManagerProvider).activeService;

  /// 是否有激活的服务
  bool get hasActiveService => read(serviceManagerProvider).hasActiveService;

  /// 所有服务列表
  List<ServiceConfig> get services => read(serviceManagerProvider).services;

  /// 服务数量
  int get serviceCount => read(serviceManagerProvider).serviceCount;
}
