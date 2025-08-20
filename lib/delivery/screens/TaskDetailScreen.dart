import 'package:flutter/material.dart';
import 'TaskListScreen.dart';
import 'PreDeliveryScanScreen.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskItem task;
  final List<TaskItem> allTasks;

  const TaskDetailScreen(
      {super.key, required this.task, required this.allTasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GLS')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 顶部蓝条（显示数量）
          Container(
            height: 36,
            color: Colors.lightBlue,
            alignment: Alignment.center,
            child: Text('${allTasks.length}',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ),
          // #订单号 + DELIVERY
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text('#${task.id}',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('DELIVERY',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          _tile(icon: Icons.home, title: 'Address', child: Text(task.address)),
          _tile(
            icon: Icons.access_time,
            title: 'Time',
            child: Text(task.timeWindow,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          _tile(
            icon: Icons.person,
            title: 'Contact Name',
            child: Text(task.contactName),
          ),
          _tile(
            icon: Icons.notifications,
            title: 'Delivery Notification',
            trailing: const Icon(Icons.refresh),
            child: const SizedBox.shrink(),
          ),
          _tile(
            icon: Icons.bookmark,
            title: 'Remarks',
            child: const Text(''),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'transactionId: ${task.id}${DateTime.now().toUtc().toIso8601String()}',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    // 点击 SETTINGS 按钮的逻辑
                  },
                  icon: const Icon(Icons.settings, color: Colors.white),
                  label: const Text('SETTINGS',
                      style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    // 修改跳转逻辑为新的页面 NewScreen
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) => const NewScreen(),
                    //   ),
                    // );
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text('CONFIRM',
                      style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title, style: const TextStyle(fontSize: 18)),
          trailing: trailing,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: child,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
