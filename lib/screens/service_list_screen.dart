/// 服务列表页面
///
/// 显示所有服务，支持切换、编辑和删除
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_config.dart';
import '../providers/service_manager_provider.dart';
import 'settings_screen.dart';

/// 服务列表页面
class ServiceListScreen extends ConsumerWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceManager = ref.watch(serviceManagerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('服务列表'),
        centerTitle: true,
      ),
      body: serviceManager.isLoading
          ? const Center(child: CircularProgressIndicator())
          : serviceManager.services.isEmpty
              ? _buildEmptyState(context)
              : _buildServiceList(context, ref, serviceManager),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addService(context),
        icon: const Icon(Icons.add),
        label: const Text('添加服务'),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有添加服务',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加第一个服务',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  /// 构建服务列表
  Widget _buildServiceList(
    BuildContext context,
    WidgetRef ref,
    ServiceManagerState serviceManager,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: serviceManager.services.length,
      itemBuilder: (context, index) {
        final service = serviceManager.services[index];
        final isActive = service.id == serviceManager.activeServiceId;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(
                isActive ? Icons.check_circle : Icons.cloud,
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              service.name,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  service.wsUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (isActive) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '当前使用',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editService(context, service);
                    break;
                  case 'delete':
                    _deleteService(context, ref, service);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('编辑'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 8),
                      Text('删除'),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _switchService(context, ref, service),
            onLongPress: () => _editService(context, service),
          ),
        );
      },
    );
  }

  /// 切换服务
  Future<void> _switchService(
    BuildContext context,
    WidgetRef ref,
    ServiceConfig service,
  ) async {
    final notifier = ref.read(serviceManagerProvider.notifier);
    final success = await notifier.setActiveService(service.id);

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已切换到 ${service.name}')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('切换服务失败')),
        );
      }
    }
  }

  /// 添加服务
  void _addService(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  /// 编辑服务
  void _editService(BuildContext context, ServiceConfig service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(editingService: service),
      ),
    );
  }

  /// 删除服务
  Future<void> _deleteService(
    BuildContext context,
    WidgetRef ref,
    ServiceConfig service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除服务'),
        content: Text('确定要删除服务 "${service.name}" 吗？\n\n此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final notifier = ref.read(serviceManagerProvider.notifier);
      final success = await notifier.deleteService(service.id);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已删除 ${service.name}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除服务失败')),
          );
        }
      }
    }
  }
}
