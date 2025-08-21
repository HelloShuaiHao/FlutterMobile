import 'package:flutter/material.dart';
import 'TaskListScreen.dart';

class PreDeliveryScanScreen extends StatelessWidget {
  final List<TaskItem> tasks;
  const PreDeliveryScanScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final scannedSummary =
        tasks.fold<int>(0, (sum, t) => sum + t.modules.length); // 示例数字

    return Scaffold(
      appBar: AppBar(
        title: const Text('PRE-DELIVERY SCAN'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text('Scanned summary: $scannedSummary',
                    style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                      'Available Routes: 1\n1st Timeframe: 08:00 AM',
                      style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final t = tasks[i];
                return _orderCard(t);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 64,
          child: ElevatedButton.icon(
            onPressed: () {
              // 跳转到 TaskListScreen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TaskListScreen()),
              );
            },
            icon: const Icon(Icons.arrow_right_alt, size: 28),
            label: const Text('PROCEED', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderCard(TaskItem t) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部蓝条含订单ID与时间窗
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'ORDER ID: ',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                            children: [
                              TextSpan(
                                text: t.id,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('(${t.timeWindow})',
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('486018',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.local_shipping, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // 模块列表（绿色条）
            ...t.modules.map(
              (m) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text('Module: ${m.name}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(m.code,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
