import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mighty_delivery/extensions/extension_util/context_extensions.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:mighty_delivery/extensions/text_styles.dart';
import 'package:mighty_delivery/main.dart';
import 'package:mighty_delivery/main/models/PendingRequest.dart';
import 'package:mighty_delivery/main/services/PendingRequestService.dart';
import 'package:mighty_delivery/main/utils/dynamic_theme.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({Key? key}) : super(key: key);

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  final _service = PendingRequestService.instance;
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('待处理请求'),
        backgroundColor: ColorUtils.colorPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryAll,
            tooltip: '重试全部',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmClearAll,
            tooltip: '清空全部',
          ),
        ],
      ),
      body: StreamBuilder<List<PendingRequest>>(
        stream: _service.requestsStream,
        initialData: _service.pendingRequests,
        builder: (context, snapshot) {
          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '没有待处理的请求',
                    style: secondaryTextStyle(size: 16),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 统计信息
              Container(
                padding: const EdgeInsets.all(16),
                color: ColorUtils.colorPrimary.withOpacity(0.1),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        '待处理',
                        requests
                            .where((r) => r.status == RequestStatus.pending)
                            .length,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '重试中',
                        requests
                            .where((r) => r.status == RequestStatus.retrying)
                            .length,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        '失败',
                        requests
                            .where((r) => r.status == RequestStatus.failed)
                            .length,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ),

              // 请求列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return _buildRequestCard(request);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(PendingRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部：类型和状态
            Row(
              children: [
                // 类型图标
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(request.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(request.type),
                    color: _getTypeColor(request.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.typeLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.taskName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 状态标签
                _buildStatusBadge(request.status),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // 详细信息
            _buildInfoRow('任务 ID', request.taskId),
            const SizedBox(height: 6),
            _buildInfoRow(
              '创建时间',
              DateFormat('yyyy-MM-dd HH:mm:ss').format(request.createdAt),
            ),
            if (request.retryCount > 0) ...[
              const SizedBox(height: 6),
              _buildInfoRow('重试次数', '${request.retryCount}'),
            ],
            if (request.errorMessage != null) ...[
              const SizedBox(height: 6),
              _buildInfoRow('错误信息', request.errorMessage!, isError: true),
            ],

            const SizedBox(height: 12),

            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _confirmDelete(request),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('删除'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: request.status == RequestStatus.retrying
                      ? null
                      : () => _retryRequest(request),
                  icon: request.status == RequestStatus.retrying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh, size: 18),
                  label: Text(
                      request.status == RequestStatus.retrying ? '重试中' : '重试'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorUtils.colorPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RequestStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case RequestStatus.pending:
        color = Colors.orange;
        label = '待处理';
        icon = Icons.pending_outlined;
        break;
      case RequestStatus.retrying:
        color = Colors.blue;
        label = '重试中';
        icon = Icons.refresh;
        break;
      case RequestStatus.failed:
        color = Colors.red;
        label = '失败';
        icon = Icons.error_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isError ? Colors.red : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(RequestType type) {
    switch (type) {
      case RequestType.pickup:
        return Colors.blue;
      case RequestType.delivery:
        return Colors.green;
      case RequestType.proofOfDelivery:
        return Colors.purple;
      case RequestType.taskStatus:
        return Colors.orange;
    }
  }

  IconData _getTypeIcon(RequestType type) {
    switch (type) {
      case RequestType.pickup:
        return Icons.local_shipping_outlined;
      case RequestType.delivery:
        return Icons.done_all;
      case RequestType.proofOfDelivery:
        return Icons.camera_alt_outlined;
      case RequestType.taskStatus:
        return Icons.update;
    }
  }

  Future<void> _retryRequest(PendingRequest request) async {
    setState(() => _isRetrying = true);
    final success = await _service.retryRequest(request.id);
    setState(() => _isRetrying = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '重试成功' : '重试失败，请检查网络连接'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _retryAll() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);
    await _service.retryAll();
    setState(() => _isRetrying = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已完成批量重试'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _confirmDelete(PendingRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这个待处理请求吗？\n\n任务: ${request.taskName}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.removeRequest(request.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
      }
    }
  }

  Future<void> _confirmClearAll() async {
    if (_service.pendingRequests.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: Text('确定要清空所有 ${_service.pendingCount} 个待处理请求吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已清空所有待处理请求')),
        );
      }
    }
  }
}
